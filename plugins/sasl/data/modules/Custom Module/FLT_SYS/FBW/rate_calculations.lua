-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

local msin = function (x) return math.sin(math.rad(x)) end
local mcos = function (x) return math.cos(math.rad(x)) end
local mtan = function (x) return math.tan(math.rad(x)) end


FBW.angular_rates ={
    Theta = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)

           return get(Flightmodel_q) * mcos(roll) + get(Flightmodel_r) * msin(roll)
        end
    },
    Phi = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)
            local pitch = get(Flightmodel_pitch)

           return get(Flightmodel_p) + (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) * mtan(pitch)
        end
    },
    Psi = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)
            local pitch = get(Flightmodel_pitch)

           return (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) / mcos(pitch)
        end
    },
}

local function update_angular_rates(table)
    for key, value in pairs(table) do
        -- Ignore non-dataref based rates
        value.rad = value.compute()
        value.deg = (value.rad / math.pi) * 180
    end
end

function update()
    update_angular_rates(FBW.angular_rates)
end