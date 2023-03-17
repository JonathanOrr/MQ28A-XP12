-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: main_menu.lua 
-- Short description: The file containing the functions related to the X-Plane
--                    menu 
-------------------------------------------------------------------------------

function Show_hide_PID_UI()
  FBW_PID_debug_window:setIsVisible(not FBW_PID_debug_window:isVisible())
end

-- create top level menu in plugins menu
Menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "MQ28" )
-- add a submenu
Menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, Menu_master)

-- DEBUG submenu
Menu_debug_item	= sasl.appendMenuItem (Menu_main, "Debug" )
Menu_debug	= sasl.createMenu ("", Menu_main, Menu_debug_item)
ShowHidePIDUI	= sasl.appendMenuItem(Menu_debug, "Show/Hide PID UI", Show_hide_PID_UI)