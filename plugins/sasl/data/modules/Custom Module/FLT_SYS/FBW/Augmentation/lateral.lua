local fphiDotLimit = Lagrange_interpolation(
    {50, 114, 155, 195, 236, 300},
    {35, 170, 250, 315, 350, 360}
)

FBW.PIDs.phidot = BPPID:new{kp = 0.125, ki = 1, kbp = 0, minout = -30, maxout = 30}

function update()
    local PO = (
            FCTL.L_FLAPERON.def - get(FBW_PITCH_DEF) +
            FCTL.R_FLAPERON.def - get(FBW_PITCH_DEF)
    ) / 2
    FBW.PIDs.phidot:backPropagation(PO)

    local output = FBW.PIDs.phidot:computePID(
        fphiDotLimit(Math_clamp(get(TAS_ms) * 1.944, 50, 300)) * get(FCTL_INPUT_X),
        PhiDot:deg()
    )
    set(FBW_ROLL_DEF,
        output
    )
end