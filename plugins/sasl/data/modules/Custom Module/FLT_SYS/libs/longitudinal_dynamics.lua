function Theoretical_Q(Nz)
    local g         = get(Weather_g)
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_BANK  = math.rad(get(Flightmodel_roll))
    local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

    return (g / TAS_MS) * (Nz - math.cos(RAD_VPATH) * math.cos(RAD_BANK))
end

function Neutral_Nz()
    local MAX_BANK_COMP = 45
    local INV_SMOOTH_MARGIN = 15
    local RAD_VPATH = math.rad(get(Vpath))
    local BANK = get(Flightmodel_roll)

    local RAD_BANK = math.rad(BANK)
    local RAD_BANK_ClAMPED = math.rad(Math_clamp(BANK, -MAX_BANK_COMP, MAX_BANK_COMP))
    local Nz = math.cos(RAD_VPATH) / math.cos(RAD_BANK)
    local limited_Nz = math.cos(RAD_VPATH) / math.cos(RAD_BANK_ClAMPED)

    local output = limited_Nz
    if BANK <= -180 + MAX_BANK_COMP then
        output = SmoothRescale(1.45, -180 + MAX_BANK_COMP - INV_SMOOTH_MARGIN, Nz, -180 + MAX_BANK_COMP, limited_Nz, BANK)
    elseif BANK >= 180 - MAX_BANK_COMP then
        output = SmoothRescale(1.45, 180 - MAX_BANK_COMP, limited_Nz, 180 - MAX_BANK_COMP + INV_SMOOTH_MARGIN, Nz, BANK)
    end

    return output
end

function ComputeCSTAR(Nz, Q)
    local Vco = 120
    local g   = get(Weather_g)
    return Nz + (Vco * Q) / g
end