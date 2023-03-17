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
-- File: main_windows.lua 
-- Short description: The file containing the code for the windows
-------------------------------------------------------------------------------

addSearchPath(moduleDirectory .. "/Custom Module/debug_windows/")

 --windows
PID_UI_window = contextWindow {
  name = "PID TUNING UI";
  position = { 150 , 150 , 600, 300 };
  noBackground = true ;
  proportional = false ;
  minimumSize = { 600 , 300 };
  maximumSize = { 600 , 300 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false ;
  components = {
    PID_UI {position = { 0 , 0 , 600 , 300 }}
  };
}

--FLT SYS debug windows--
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/Debug")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW/Debug")

FBW_PID_debug_window = contextWindow {
  name = "FBW PID DEBUG";
  position = { 100 , 100 , 700 , 500 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 700 , 500 };
  maximumSize = { 700 , 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = false;
  components = {
    PID {position = { 0 , 0 , 700 , 500 }}
  };
}

--[[FBW_PID_debug_window = contextWindow {
  name = "FBW 3D DEBUG";
  position = { 100 , 100 , 500 , 500 };
  noBackground = true ;
  proportional = true ;
  minimumSize = { 500 , 500 };
  maximumSize = { 500 , 500 };
  gravity = { 0 , 1 , 0 , 1 };
  visible = true;
  components = {
    Render {position = { 0 , 0 , 500 , 500 }}
  };
}]]