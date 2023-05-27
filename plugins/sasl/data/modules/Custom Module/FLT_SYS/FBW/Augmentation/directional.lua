FBW.PIDs.r = PID:new{kp = 60, kd = 1, minout = -30, maxout = 30}
--FBW.PIDs.r = PID:new{kp = 100000, kd = 1, minout = -100000, maxout = 100000}

function update()
    if get(Front_gear_on_ground) == 1 and get(Left_gear_on_ground) == 1 and get(Right_gear_on_ground) == 1 then
        FBW.PIDs.r.I = 0
    end

    FBW.PIDs.r.kp = Math_rescale(150, 120, 200, 60, get(TAS_ms) * 1.94384)
    FBW.PIDs.r.kd = Math_rescale(150, 5, 200, 1, get(TAS_ms) * 1.94384)

    set(FBW_YAW_DEF,
        FBW.PIDs.r:computePID(
            Theoretical_R() + 0.5 * get(FCTL_INPUT_YAW),
            get(Flightmodel_r)
        )
    )
end
