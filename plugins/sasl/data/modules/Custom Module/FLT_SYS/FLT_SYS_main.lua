addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW")

set(Override_control_surfaces, 1)
function onPlaneLoaded() set(Override_control_surfaces, 1) end
function onAirportLoaded() set(Override_control_surfaces, 1) end
function onModuleShutdown() set(Override_control_surfaces, 0) end

FCTL = {}
FBW = {}

components = {
    FCTL_main {},
    --FBW {},
}

function update()
    if get(DELTA_TIME) ~= 0 then
        updateAll(components)
    end
end