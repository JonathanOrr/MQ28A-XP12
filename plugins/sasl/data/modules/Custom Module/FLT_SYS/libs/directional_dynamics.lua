function Theoretical_R()
    local msin = function (a) return math.sin(a) end
    local mcos = function (a) return math.cos(a) end
    local g = get(Weather_g)
    local TAS_MS = Math_clamp_lower(get(TAS_ms), 0.1)
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_ROLL = math.rad(get(Flightmodel_roll))

    return (g / TAS_MS) * (msin(RAD_ROLL) * mcos(RAD_VPATH)) --+ get(Total_lateral_g_load))
end