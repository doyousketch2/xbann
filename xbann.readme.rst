**installation requirements**

HexChat seems to exclusively use Lua version 5.3  and  Gtk+2.0
      https://hexchat.readthedocs.io/en/latest/script_lua.html

===============================================================================
-------------------------------------------------------------------------------
**step 1)  open Terminal, copy into hexchat/addons dir**

      cd ~/.config/hexchat/addons/
      curl https://raw.githubusercontent.com/doyousketch2/xbann/xbann.lua -o xbann.lua
      curl https://raw.githubusercontent.com/doyousketch2/xbann/xbann.window.module -o xbann.window.module
      curl https://raw.githubusercontent.com/doyousketch2/xbann/xbann.readme.rst -o xbann.readme.rst

-----------------------------------------------------------------------------------------------------------------------
**step 2)  make sure you have HexChat's Lua plugin, Gtk+2.0 and GObject libs with dev-headers**

      sudo apt update  &&  sudo apt install hexchat-lua libgtk2.0-dev gobject-introspection libgirepository1.0-dev

-----------------------------------------------------------------------------------------------------------------------
**step 3)  check your Lua version, to see if using 5.3**

      lua -v

      **if it doesn't say:   "Lua 5.3.5  Copyright (C) 1994-2018 Lua.org, PUC-Rio"**
            *then you can install 5.3*

                  sudo apt install lua5.3 luarocks

            *or use LuaVer*  --  https://dhavalkapil.com/luaver

                  sudo apt install libreadline-dev
                  curl https://raw.githubusercontent.com/dhavalkapil/luaver/v1.0.0/install.sh -o install.sh  &&  . ./install.sh
                  luaver use 5.3.5  &&  luaver use-luarocks 3.2.0

-----------------------------------------------------------------------------------------------------------------------
**step 4)  Lua needs to access lgi to draw windows in HexChat**

      *Dynamic Lua binding to GObject libraries using GObject-Introspection*
               ...just a fancy way of saying  "using Lua to draw stuff on your screen"

            luarocks install lgi

      *if using LuaVer, create dir in your Lua path*

          [ ! -d /usr/local/share/lua/5.3 ]  &&  sudo mkdir  /usr/local/share/lua/5.3
          [ ! -d /usr/local/lib/lua/5.3 ]  &&  sudo mkdir  /usr/local/lib/lua/5.3

      *if using LuaVer, create softlinks, so HexChat can find them*

          sudo ln -s ~/.luaver/luarocks/3.2.0_5.3/share/lua/5.3/lgi.lua  /usr/local/share/lua/5.3/lgi.lua
          sudo ln -s ~/.luaver/luarocks/3.2.0_5.3/share/lua/5.3/lgi  /usr/local/share/lua/5.3/lgi
          sudo ln -s ~/.luaver/luarocks/3.2.0_5.3/lib/lua/5.3/lgi  /usr/local/lib/lua/5.3/lgi

-----------------------------------------------------------------------------------------------------------------------
**step 5)  binser is a simple Lua serializer, to save settings.  originally for Love2D savegames**

            luarocks install binser

      *if using LuaVer, create softlinks*

          sudo ln -s ~/.luaver/luarocks/3.2.0_5.3/share/lua/5.3/binser.lua  /usr/local/share/lua/5.3/binser.lua

=======================================================================================================================
**step 6)  load HexChat, or if HexChat is already open, then type in HexChat**

            /lua load xbann.lua

            /xban

      *if for some reason, you ever need to clear settings, and revert to default values*

            /xban clear

=======================================================================================================================

