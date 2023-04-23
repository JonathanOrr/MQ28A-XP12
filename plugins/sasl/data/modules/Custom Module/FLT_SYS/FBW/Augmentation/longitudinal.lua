FBW.PIDs.q = BPPID:new{kp = 15, ki = 50, kbp = 1, minout = -30, maxout = 30}
--FBW.PIDs.q = BPPID:new{kp = 300000, ki = 2000000, kd = 0, kbp = 1, minout = -200000, maxout = 200000}
FBW.PIDs.alphaMax = BPPID:new{kp = 1.25, ki = 0.85, kd = 0.5, kbp = 1, minout = -30, maxout = 30}
FBW.PIDs.alphaMin = BPPID:new{kp = 1.25, ki = 0.85, kd = 0.5, kbp = 1, minout = -30, maxout = 30}
--FBW.PIDs.alphaMax = BPPID:new{kp = 2500, ki = 5000, kd = 1250, kbp = 1, minout = -200000, maxout = 200000}
--FBW.PIDs.alphaMin = BPPID:new{kp = 2500, ki = 5000, kd = 1250, kbp = 1, minout = -200000, maxout = 200000}

--====input processing====
local function X_to_G(x)
    local max_G = 12
    local min_G = -2

    local G_load_input_table = {
        {-1, min_G},
        {0,  Neutral_Nz()},
        {1,  max_G},
    }

    return Table_interpolate(G_load_input_table, x)
end
--========================


function update()
    local PO = (
            FCTL.L_FLAPERON.def - get(FBW_ROLL_DEF) +
            FCTL.R_FLAPERON.def + get(FBW_ROLL_DEF) +
            FCTL.L_RUDDERVATOR.def + get(FBW_YAW_DEF) +
            FCTL.R_RUDDERVATOR.def - get(FBW_YAW_DEF)
    ) / 4
    --FBW.PIDs.q:backPropagation(PO)

    FBW.PIDs.q:backPropagation(get(FBW_PITCH_DEF))
    FBW.PIDs.alphaMin:backPropagation(get(FBW_PITCH_DEF))
    FBW.PIDs.alphaMax:backPropagation(get(FBW_PITCH_DEF))

    FBW.PIDs.q:computePID(
        Theoretical_Q(X_to_G(get(FCTL_INPUT_Y))),
        get(Flightmodel_q)
    )
    FBW.PIDs.alphaMin:computePID(
        -10,--SmoothRescale(1.5, 0, 20, 1, 45, get(FCTL_INPUT_Y)),
        get(Alpha)
    )

    FBW.PIDs.alphaMax:computePID(
        50, --SmoothRescale(1.5, 0, 0, 1, 45, get(FCTL_INPUT_Y)),
        get(Alpha)
    )

    set(FBW_PITCH_DEF,
        math.max(math.min(FBW.PIDs.q.output, FBW.PIDs.alphaMax.output), FBW.PIDs.alphaMin.output)
        --FBW.PIDs.q.output
    )
end