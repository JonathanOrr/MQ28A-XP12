FBW.PIDs.r = PID:new{kp = 10, kd = 1, minout = -30, maxout = 30}
--FBW.PIDs.r = PID:new{kp = 100000, kd = 1, minout = -100000, maxout = 100000}

function update()
    set(FBW_YAW_DEF,
        FBW.PIDs.r:computePID(
            Theoretical_R() + get(FCTL_INPUT_YAW) * 0.25,
            get(Flightmodel_r)
        )
    )
end
