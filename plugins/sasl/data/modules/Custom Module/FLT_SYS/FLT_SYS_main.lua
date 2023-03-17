addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW")

FLT_SYS = {
    ctlSurfs = {},
}

components = {
    FCTL_main {},
    --FBW {},
}

function update()
    if get(DELTA_TIME) ~= 0 then
        updateAll(components)
    end
end