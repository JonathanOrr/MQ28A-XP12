include("FLT_SYS/libs/numerical_math.lua")
include("FLT_SYS/libs/angular_rates.lua")
include("FLT_SYS/libs/PID.lua")
include("FLT_SYS/libs/signal_processing.lua")
include("FLT_SYS/libs/longitudinal_dynamics.lua")
include("FLT_SYS/libs/lateral_dynamics.lua")
include("FLT_SYS/libs/directional_dynamics.lua")

addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW")

set(Override_control_surfaces, 1)
function onPlaneLoaded() set(Override_control_surfaces, 1) end
function onAirportLoaded() set(Override_control_surfaces, 1) end
function onModuleShutdown() set(Override_control_surfaces, 0) end

FBW.PIDs = {}

components = {
    FCTL_main {},
    FBW_main {},
}

function update()
    if get(DELTA_TIME) ~= 0 then
        updateAll(components)
    end
end