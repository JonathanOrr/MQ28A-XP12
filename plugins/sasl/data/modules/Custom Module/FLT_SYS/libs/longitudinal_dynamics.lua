function Theoretical_Q(Nz)
    local g         = get(Weather_g)
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_BANK  = math.rad(get(Flightmodel_roll))
    local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

    return (g / TAS_MS) * (Nz - math.cos(RAD_VPATH) * math.cos(RAD_BANK))
end

function Neutral_Nz()
    local MAX_BANK_COMP = 45
    local RAD_VPATH = math.rad(get(Vpath))
    local BANK = get(Flightmodel_roll)

    local RAD_BANK_ClAMPED = 0
    if BANK >= -90 and BANK <= 90 then
        RAD_BANK_ClAMPED = math.rad(Math_clamp(BANK, -MAX_BANK_COMP, MAX_BANK_COMP))
    elseif BANK <= -90 then
        RAD_BANK_ClAMPED = math.rad(Math_clamp(BANK, -180, -180 + MAX_BANK_COMP))
    elseif BANK >= 90 then
        RAD_BANK_ClAMPED = math.rad(Math_clamp(BANK, 180 - MAX_BANK_COMP, 180))
    end

    return math.cos(RAD_VPATH) / math.cos(RAD_BANK_ClAMPED)
end

function ComputeCSTAR(Nz, Q)
    local Vco = 120
    local g   = get(Weather_g)
    return Nz + (Vco * Q) / g
end