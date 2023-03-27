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
    PVdelta = 0,
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
    self.PVdelta = self.PV - last_PV
    self.error = SP - self.PV

    --P--
    self.P = self.kp * self.error
    --I--
    self:integration()
    --D-- (dPVdt to avoid derivative bump)
    self.D = self.kd * -self.PVdelta / get(DELTA_TIME)

    return self:getOutput()
end
--====================================================================================
BPAWPID = PID:new{
    kbp = 1,
    kaw = 0,
    BP = 0,
    plantOutput = 0,
}

function BPAWPID:backPropagation(PO)
    self.plantOutput = PO
    self.BP = self.kbp * (self.plantOutput - self.output)
end

function BPAWPID:integration()
    if self.kaw < 0 then sasl.logError("Why is the anti-windup gain < 0, that makes no sense") end
    local awfactor = Math_clamp(self.kaw * math.abs(self.PVdelta), 0, 1)

    self.I = Math_clamp(self.I + self.ki * self.error * awfactor * get(DELTA_TIME) + self.BP, self.minout, self.maxout)
end
--====================================================================================
BPAWFFPID = BPAWPID:new{
    FF = 0,
}

function BPAWFFPID:backPropagation(PO)
    self.plantOutput = PO - self.FF
    self.BP = self.kbp * (self.plantOutput - self.output)

    --reset FF sum to begin the new FF cycle
    --remember there can be multiple FF inputs
    self.FF = 0
end

function BPAWFFPID:feedForward(kff, FFPV)
    self.FF = self.FF + kff * FFPV
end

function BPAWFFPID:getOutput()
    self.output = Math_clamp(self.P + self.I + self.D, self.minout, self.maxout)

    return self.output + self.FF
end
--====================================================================================