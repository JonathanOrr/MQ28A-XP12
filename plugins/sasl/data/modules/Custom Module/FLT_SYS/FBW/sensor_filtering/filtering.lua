FBW.filtered_sensors = {
    AoA = {
        filter = LowPass:new{freq = 0.25},
        output = 0,
        x = function ()
            return adirs_get_avg_aoa()
        end,
    },

    IAS = {
        filter = LowPass:new{freq = 2},
        output = 0,
        x = function ()
            return adirs_get_avg_ias()
        end,
    },
    TAS = {
        filter = LowPass:new{freq = 2},
        output = 0,
        x = function ()
            return adirs_get_avg_tas()
        end,
    },

    HP_NX = {
        filter = HighPass:new{freq = 1.4},
        output = 0,
        x = function ()
            return get(Total_lateral_g_load)
        end,
    },

    GS_TAS_DELTA = {
        filter = HighPass:new{freq = 10},
        output = 0,
        x = function ()
            return (get(TAS_ms) * 1.94384 - get(Ground_speed_kts))
        end,
    },
}

function update()
    if get(DELTA_TIME) == 0 then return end

    for _, tbl in pairs(FBW.filtered_sensors) do
        tbl.output = tbl.filter:filterOut(tbl.x())
    end
end