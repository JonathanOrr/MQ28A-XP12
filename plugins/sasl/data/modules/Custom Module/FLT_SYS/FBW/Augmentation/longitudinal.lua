FBW.PIDs.q = BPPID:new{kp = 15, ki = 50, kbp = 1, minout = -30, maxout = 30}
--FBW.PIDs.q = BPPID:new{kp = 300000, ki = 2000000, kd = 0, kbp = 1, minout = -200000, maxout = 200000}
--FBW.PIDs.alphaMax = BPPID:new{kp = 0.32, ki = 0.6, kd = 0.30, kbp = 1, minout = -30, maxout = 30}
--FBW.PIDs.alphaMax = BPPID:new{kp = 2500, ki = 5000, kd = 1250, kbp = 1, minout = -200000, maxout = 200000}

--====input processing====
local function X_to_G(x)
    local max_G = 9.5
    local min_G = -3

    local G_load_input_table = {
        {-1, min_G},
        {0,  Neutral_Nz()},
        {1,  max_G},
    }

    return Table_interpolate(G_load_input_table, x)
end
local function X_to_Q(x)
    local max_Q = 20
    local min_Q = -20

    local Q_input_table = {
        {-1, math.rad(min_Q)},
        {0,  0},
        {1,  math.rad(max_Q)},
    }

    return Table_interpolate(Q_input_table, x)
end
--========================


function update()
    if get(Front_gear_on_ground) == 1 and get(Left_gear_on_ground) == 1 and get(Right_gear_on_ground) == 1 then
        FBW.PIDs.q.I = 0
    end

    FBW.PIDs.q.kp = Math_rescale(150, 45, 200, 20, get(TAS_ms) * 1.94384)
    FBW.PIDs.q.ki = Math_rescale(150, 85, 200, 120, get(TAS_ms) * 1.94384)
    FBW.PIDs.q.kd = Math_rescale(150, 10, 200, 0, get(TAS_ms) * 1.94384)

    local PO = (
        -FCTL.L_HSTABLITOR.def
        -FCTL.R_HSTABLITOR.def
    ) / 2

    FBW.PIDs.q:backPropagation(get(FBW_PITCH_DEF))

    local qDemand = Theoretical_Q(X_to_G(get(FCTL_INPUT_Y)))
    qDemand = Math_rescale(80, X_to_Q(get(FCTL_INPUT_Y)), 180, qDemand, get(TAS_ms) * 1.94384)
    FBW.PIDs.q:computePID(
        qDemand,
        get(Flightmodel_q)
    )

    set(FBW_PITCH_DEF, FBW.PIDs.q.output)
end