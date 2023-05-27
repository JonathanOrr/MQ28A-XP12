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
-- File: main.lua
-- Short description: The main file for the project
-------------------------------------------------------------------------------

include("cockpit_commands.lua")
include("cockpit_datarefs.lua")
include("dynamic_datarefs.lua")
include("failures_datarefs.lua")
include("global_variables.lua")
include("global_functions.lua")
include("graphics_helpers.lua")
include("global_constants.lua")
include("FLT_SYS/FBW/PID_arrays.lua")

sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)


-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

-- Initialize the random seed for math.random
math.randomseed( os.time() )

addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS")

position = {0, 0, 1024, 1024}
size = { 1024, 1024 }

panelWidth3d = 1024
panelHeight3d = 1024

components = {
  HUD {},
  FLT_SYS_main {}
}

include(moduleDirectory .. "/main_windows.lua")
include(moduleDirectory .. "/main_menu.lua")

