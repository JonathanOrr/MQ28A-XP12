FBW.PIDs.q = BPPID:new{kp = -20, ki = -55, kbp = 1, minout = -30, maxout = 30}
FBW.PIDs.alpha = BPPID:new{kp = 0.8, ki = 1.2, kd = 0.25, kbp = 1, minout = -30, maxout = 30}

--====input processing====
local function X_to_G(x)
    local max_G = 9
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
            FCTL.L_FLAPERON.def - get(FCTL_INPUT_X) *  30 +
            FCTL.R_FLAPERON.def - get(FCTL_INPUT_X) * -30 +
            FCTL.L_RUDDERVATOR.def - get(FCTL_INPUT_YAW) *  30 +
            FCTL.R_RUDDERVATOR.def - get(FCTL_INPUT_YAW) * -30
    ) / 4
    FBW.PIDs.q:backPropagation(PO)

    set(FBW_PITCH_DEF,
        FBW.PIDs.q:computePID(
            Theoretical_Q(X_to_G(get(FCTL_INPUT_Y))),
            get(Flightmodel_q)
        )
    )
end