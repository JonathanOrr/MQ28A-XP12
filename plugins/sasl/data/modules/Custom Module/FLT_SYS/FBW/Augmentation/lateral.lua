local fphiDotLimit = Lagrange_interpolation(
    {50, 114, 155, 195, 236, 300},
    {35, 170, 250, 315, 350, 360}
)

--====input processing====
local function X_to_P(x)
    local pitch = get(Flightmodel_pitch)
    local Plim = fphiDotLimit(Math_clamp(get(TAS_ms) * 1.944, 50, 300))
    local neutralPComp = get(Flightmodel_p_deg) - PhiDot:deg()

    --pitch is to ensure no strange behaviours while pulling a vertical loop
    --or pretty much anything invloving extreme pitch attitudes
    local compFactor = 1
    if pitch < 0 then
        compFactor = SmoothRescale(1.45, -70, 0, -60, 1, pitch)
    else
        compFactor = SmoothRescale(1.45, 60, 1, 70, 0, pitch)
    end

    local P_input_table = {
        {-1, -Plim + compFactor * neutralPComp},
        {0,          compFactor * neutralPComp},
        {1,   Plim + compFactor * neutralPComp},
    }

    return Table_interpolate(P_input_table, x)
end
--========================

FBW.PIDs.p = BPPID:new{kp = 0.125, ki = 1, kbp = 0, minout = -30, maxout = 30}

function update()
    local PO = (
            FCTL.L_FLAPERON.def - get(FBW_PITCH_DEF) +
            FCTL.R_FLAPERON.def - get(FBW_PITCH_DEF)
    ) / 2
    FBW.PIDs.p:backPropagation(PO)

    set(FBW_ROLL_DEF,
        FBW.PIDs.p:computePID(
            X_to_P(get(FCTL_INPUT_X)),
            get(Flightmodel_p_deg)
        )
    )
end