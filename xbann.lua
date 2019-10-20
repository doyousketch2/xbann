-----------------------------------------------------------
--     @Doyousketch2           AGPL-3           Oct 1, 2019
--            https://www.gnu.org/licenses/agpl-3.0.en.html
-----------------------------------------------------------
local name  = 'xbann.lua'
local version  = '2019.1020'
local description  = "Kick the $#!7 out'a spammers"
local author  = '@Doyousketch2'

hexchat .register(  name,  version,  description  )

hexchat .print(  string.format( '%s  ver. %s loaded  --  using %s', name, version, _VERSION )  )
hexchat .print(  '  ' ..description  )
hexchat .print(  '    by:  ' ..author  )

local binser  = require( 'binser' )

--=========================================================

--    sudo apt update && sudo apt install gobject-introspection libgirepository1.0-dev libgtk2.0-dev

--    luarocks install lgi
--    luarocks install binser

--=========================================================
--  variable declaration

local print_debug_msgs  = false   --  set to  true  if you want to see excess jibberish.

--  mods, and other notables;  safety measure so ya don't accidentally ban somebody
local exempt_users  = {  'VanessaE',  'BakerPrime',  'bulldog1',  'CAMc',  'Chalo',  'cheapie',
                          'CWz',  'deezl',  'deltasquared',  'thetaepsilon',  'LadyPyle',  'Sokomine',   }

local IRC_channels  = {  '#ve-minetest-servers',  '#testing_testing'  }

--=========================================================
--  file paths

local filename_with_path  = debug .getinfo(1) .source :sub( 2 )  --  strip the @ sign
local delimiter  = filename_with_path :reverse() :find( '/' )

--    @/home/username/.config/hexchat/addons/xbann.lua
--    |                                     |
--    strip this                            delimiter

local filename  = filename_with_path :sub(  -delimiter +1  )
local current_dir  = filename_with_path :sub(  1,  -delimiter  )

local savename  = 'xbann.settings'
local savename_with_path  = current_dir ..savename

local window_module_name  = 'xbann.window.module'

dofile( current_dir ..'xbann.defaults' )

local NICK  = ''   --   IRC name, used for logging into bots
local CHAN  = ''   --   IRC channel, only execute script on allowed channels

--=========================================================
--  define functions

local function debug_print( text )
    if print_debug_msgs then   print( text )   end
end


local function debug_form_print( form,  str1, str2, str3, str4 )
    local s1  = str1 or ''
    local s2  = str2 or ''
    local s3  = str3 or ''
    local s4  = str4 or ''

    debug_print(  string.format( form,  s1, s2, s3, s4 )  )
end


local function sleep( seconds )
    local future  = os.clock() +seconds
    repeat until os.clock() >= future
end

--[[  word and word_eol parameters similar to Python, but count begins at 1
      https://hexchat.readthedocs.io/en/latest/script_python.html#word-and-word-eol

/xban player for reason

    word[1]  is   xban
    word[2]  is   player
    word[3]  is   for
    word[4]  is   reason

    word_eol[1]  is   xban player for reason
    word_eol[2]  is   player for reason
    word_eol[3]  is   for reason
    word_eol[4]  is   reason

]]--

local function xbann_function( word, word_eol )
    CHAN  = hexchat .get_info( 'channel' )
    NICK  = hexchat .get_info( 'nick' )
    ARGS  = word_eol[2]

    local found_channel  = false
    --  the or pipe brackets are so it's easy to see where the parameter starts and stops, in case of a space
    debug_form_print(  'NICK ||%s||   CHAN ||%s||   ARGS ||%s||',  NICK, CHAN, ARGS  )

    for channel = 1, #IRC_channels do
        if IRC_channels[ channel ] == CHAN then

            debug_print( 'filename  ||' ..filename ..'||' )
            debug_print( 'current_dir  ||' ..current_dir ..'||' )

            found_channel  = true
            break
        end  --  if CHAN
    end  --  #IRC_channels

    -----------------------------------

    if found_channel then
        debug_print(  'found channel:  ' ..CHAN  )

        local function readit()
            return binser .readFile( savename_with_path )
        end

        local status, return_value  = pcall( readit )

        if not status then   print( 'Err: ' ..return_value )
        else
            local decoded, len  = return_value[1], return_value[2]
            debug_print(  'decoded: ' ..type( decoded )  )

            if decoded and decoded .save_version == xb .save_version and ARGS ~= 'clear' then

                for primary_key, primary_value in pairs( decoded ) do
                    if type( primary_value ) == 'table' then  --  scan for a table within the table

                        if primary_key == 'reasons' then  --  indexed sub-table
                            for secondary_index, secondary_value in ipairs( primary_value ) do
                                xb [ primary_key ] [ secondary_index ]  = secondary_value

                                debug_form_print(  '%s: %s: %s',  primary_key,  secondary_index,  secondary_value  )
                            end  --  indexed sub-table

                        elseif primary_key == 'servers' then  --  keyed sub-table
                            for secondary_key, secondary_value in pairs( primary_value ) do
                                xb [ primary_key ] [ secondary_key ]  = secondary_value

                                debug_form_print(  '%s: %s: %s',  primary_key,  secondary_key,  secondary_value  )
                            end  --  keyed sub-table

                        end  --  primary_key
                    else  --  not a table, regular key value pair
                        if primary_key ~= 'password' then  --  print all other k, v pairs
                            xb [ primary_key ]  = primary_value
                            debug_form_print(  '%s: %s',  primary_key,  primary_value  )
                        end  --  don't print password out during debugging, for safety purposes
                    end  --  if primary == 'table'
                end  --  k,v in pairs( decoded )

            else  --  couldn't decode
                generate_new  = true
            end  --  decoded
        end  --  err

        if generate_new then
            dofile( current_dir ..'xbann.defaults' )
            debug_print( 'Generating new ' ..savename )
        end

        --  would have used a module   require( 'window' )   with   window.lua
        --  but HexChat automatically loads and runs scripts of filetype  ".lua"

        dofile(  current_dir ..window_module_name  )

    end  --  found_channel

    return hexchat .EAT_ALL  --  keep the  /xban  command internal, so freenode doesn't run it
end  -- xbann_function()

--=========================================================

function xbann_actions()

    debug_form_print(  'xbann_actions: login_type: %s',  xb .login_type  )

    if xb .kick_type then

        for e = 1, #exempt_users do
            if xb .user == exempt_users[ e ] then
                debug_form_print(  'exempt: %s',  xb .user  )

                xb .kick_type  = false
                break
            end
        end  --  #exempt_users

        -------------------------------------

        debug_form_print(  'kick_type: %s',  xb .kick_type  )

        if xb .kick_type then  --  kickable
            for server, active in pairs( xb .servers ) do

                if active and server ~= 'All' then
                    debug_form_print(  'Server: %s, Active: %s', server, active  )

                    local VEserver  = 'VE-' ..server

                    if xb .login_type == 'Login' then  --  /msg <bot> login Sketch2 <password>

                        local Login_string  = string.format(  'login %s %s',  NICK,  xb .password  )
                        hexchat .emit_print(  'Message Send',  VEserver,  Login_string  )

                        debug_print(  VEserver,  Login_string  )

                    end  --  if .login_type

                    ---------------------------------------

                    sleep( 0.15 )  --  pause for a moment, to deter being considered an IRC spambot

                    local Kick_string
                    if xb .shout then  --  say in chat    VEserver, cmd kick user reason
                        Kick_string  = string.format(  '%s, cmd %s %s %s',  VEserver,  xb .kick_type,  xb .user,  xb .reason  )
                        hexchat .emit_print(  'Channel Message',  NICK,  Kick_string  )

                    else  --  /msg VEserver cmd kick user reason
                        Kick_string  = string.format(  'cmd %s %s %s',  xb .kick_type,  xb .user,  xb .reason  )
                        hexchat .emit_print(  'Message Send',  VEserver,  Kick_string  )
                    end

                    debug_print(  VEserver,  Kick_string  )

                    ---------------------------------------

                    sleep( 0.15 )  --  pause for a moment, to deter being considered an IRC spambot

                    if xb .logout then  --  /msg <bot> logout
                        hexchat .emit_print(  'Message Send',  VEserver,  'logout'  )

                        debug_print(  VEserver,  'logout'  )
                    end  --  if .logout

                end  --  if active
            end  --  k,v in servers
        end  --  kickable

        -------------------------------

        if not xb .save_password then   xb .password  = ''   end

        binser .writeFile(  savename_with_path,  xb  )

    end  --  kick_type
end  --  xbann_actions()

--=========================================================
--  main loop

hexchat .hook_command(  'xban',  xbann_function,  'popup for xbann'  )
hexchat .hook_command(  'xbann',  xbann_function,  'popup for xbann'  )

--=========================================================
--  eof

