--Class declarations-- ================================================= as separators
PID = {
    kp = 0,
    ki = 0,
    kd = 0,

    P = 0,
    I = 0,
    D = 0,

    maxout = 1,
    minout = -1,

    PV = 0,
    error = 0,
    output = 0,
}

function PID:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function PID:integration()
    self.I = Math_clamp(self.I + self.ki * self.error * get(DELTA_TIME), self.minout, self.maxout)
end

function PID:getOutput()
    self.output = Math_clamp(self.P + self.I + self.D, self.minout, self.maxout)

    return self.output
end

function PID:computePID(SP, PV)
    if get(DELTA_TIME) == 0 then return 0 end

    local last_PV = self.PV
    self.PV = PV
    self.error = SP - self.PV

    --P--
    self.P = self.kp * self.error
    --I--
    self:integration()
    --D-- (dPVdt to avoid derivative bump)
    self.D = self.kd * (last_PV - self.PV) / get(DELTA_TIME)

    return self:getOutput()
end
--====================================================================================
BPPID = PID:new{
    kbp = 1,
    BP = 0,
    plantOutput = 0,
}

function BPPID:backPropagation(PO)
    self.plantOutput = PO
    self.BP = self.kbp * (self.plantOutput - self.output)
end

function BPPID:integration()
    self.I = Math_clamp(self.I + self.ki * self.error * get(DELTA_TIME) + self.BP, self.minout, self.maxout)
end
--====================================================================================
BPFFPID = BPPID:new{
    FF = 0,
}

function BPFFPID:backPropagation(PO)
    self.plantOutput = PO - self.FF
    self.BP = self.kbp * (self.plantOutput - self.output)

    --reset FF sum to begin the new FF cycle
    --remember there can be multiple FF inputs
    self.FF = 0
end

function BPFFPID:feedForward(kff, FFPV)
    self.FF = self.FF + kff * FFPV
end

function BPFFPID:getOutput()
    self.output = Math_clamp(self.P + self.I + self.D, self.minout, self.maxout)

    return self.output + self.FF
end
--====================================================================================


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


function high_pass_filter(data)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi*data.cut_frequency)
    local a = RC / (RC + dt)

    if data.prev_x_value == nil then
        data.prev_x_value = data.x
        data.prev_y_value = data.x
        return data.x
    else
        data.prev_y_value = a * (data.prev_y_value + data.x - data.prev_x_value)
        data.prev_x_value = data.x
    end

    return data.prev_y_value
end

function low_pass_filter(data)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi*data.cut_frequency)
    local a = dt / (RC + dt)

    if data.prev_y_value == nil then
        data.prev_y_value = a * data.x
    else
        data.prev_y_value = a * data.x + (1-a) * data.prev_y_value
    end

    return data.prev_y_value
end