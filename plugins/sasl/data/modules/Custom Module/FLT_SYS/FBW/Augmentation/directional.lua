--FBW.PIDs.r = PID:new{kp = 60, kd = 1, minout = -30, maxout = 30}
FBW.PIDs.r = PID:new{kp = 100000, kd = 1, minout = -100000, maxout = 100000}

function update()
    set(FBW_YAW_DEF,
        FBW.PIDs.r:computePID(
            Theoretical_R(),
            get(Flightmodel_r)
        )
    )
end
