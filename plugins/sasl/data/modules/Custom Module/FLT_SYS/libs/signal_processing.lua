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

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- RATE COMPUTATION
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
RateCmp = {lastTime = 0, lastVal = 0, rate = 0}

function RateCmp:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function RateCmp:getRate(currVal)
    self.rate = (currVal - self.lastVal) / (get(TIME) - self.lastTime)
    self.lastTime = get(TIME)
    self.lastVal = currVal
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- FILTERS
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- ** Instructions **
-- Create a table with two parameters: the current x value and the cut frequency in Hz:
--
-- data = {
--    x = 0,
--    cut_frequency = 10
-- }
--
-- Then, set data.x to the proper value and call the filter (e.g. y = high_pass_filter(data)) to get
-- the filtered value (y). The next time, set again data.x and recall the filter funciton.
--
-- VERY IMPORTANT (1): the variable you pass to the filter function must be preserved across filter
--                     invocations. (The filter writes stuffs inside data!)
-- VERY IMPORTANT (2): the filter function expects data FOR EACH frame after the first invocation,
--                     otherwise garbage will be computed.

LowPass = {freq = 10}

function LowPass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function LowPass:filterOut(x)
    local dt = get(DELTA_TIME)
    local RC = 1 / (2*math.pi * self.freq)
    local a = dt / (RC + dt)

    if self.prev_y == nil then
        self.prev_y = a * x
    else
        self.prev_y = a * x + (1-a) * self.prev_y
    end

    return self.prev_y
end

HighPass = LowPass:new()

function HighPass:filterOut(x)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi * self.freq)
    local a = RC / (RC + dt)

    if self.prev_x == nil then
        self.prev_x = x
        self.prev_y = x
        return x
    else
        self.prev_y = a * (self.prev_y + x - self.prev_x)
        self.prev_x = x
    end

    return self.prev_y
end