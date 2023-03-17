--initialise flight controls
set(Override_control_surfaces, 1)
function onPlaneLoaded() set(Override_control_surfaces, 1) end
function onAirportLoaded() set(Override_control_surfaces, 1) end
function onModuleShutdown() set(Override_control_surfaces, 0) end

--Class declarations-- ======================================= as separators
ControlSurface = {
    dataref = nil,

    def = 0,

    defsmoothmargin = 20, --degrees before target to start slowing down
    maxdefspd = 180, --deg/s

    maxdef = 30, --deg
    mindef = -30, --deg
}

function ControlSurface:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ControlSurface:writeDataref()
    set(self.dataref, self.def)
end

function ControlSurface:actuate(defreq)
    local defspd = 0
    if defreq < self.def then
        defspd = -self.maxdefspd
    elseif defreq > self.def then
        defspd = self.maxdefspd
    end

    --speed smoothing
    local absDefErr = math.abs(self.def - defreq)
    if absDefErr < self.defsmoothmargin then
        defspd = defspd * absDefErr / self.defsmoothmargin
    end

    --actuate the strokes
    self.def = Math_clamp(self.def + defspd * get(DELTA_TIME), self.mindef, self.maxdef)

    self:writeDataref()
end
--====================================================================================
Flaperons = ControlSurface:new()
--====================================================================================
Ruddervators = ControlSurface:new()

function Ruddervators:writeDataref()
    for i = 1, 10 do
        set(self.dataref[i], self.def)
    end
end
--=====================================================================================
SlatsSys = ControlSurface:new{
    defsmoothmargin = 0.1,
    maxdefspd = 1,

    maxdef = 1,
    mindef = 0
}

function SlatsSys:alphaDeploy()
    local slatDefReq = Math_rescale(9, self.mindef, 13, self.maxdef, get(Alpha))
    self:actuate(slatDefReq)
end
--=====================================================================================
PID = {
    kp = 0,
    ki = 0,
    kd = 0,

    P = 0,
    I = 0,
    D = 0,

    maxout = 1,
    minout = -1,

    error = 0,
    output = 0,
}

function PID:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function PID:compute(SP, PV)
    if get(DELTA_TIME) == 0 then return 0 end

    local lasterr = self.error
    local error = SP - PV
    self.error = error

    --P--
    self.P = self.kp * error

    --I--
    self.I = Math_clamp(self.I + self.ki * error * get(DELTA_TIME), self.minout, self.maxout)

    --D--
    self.D = self.kd * (error - lasterr) / get(DELTA_TIME)

    --PID--
    self.output = Math_clamp(self.P + self.I + self.D, self.minout, self.maxout)

    return self.output
end
--=====================================================================================

LE_SLAT = SlatsSys:new{dataref = Slats}

L_FLAPERON = Flaperons:new{dataref = L_AIL}
R_FLAPERON = Flaperons:new{dataref = R_AIL}

L_RUDDERVATOR = Ruddervators:new{dataref = L_RUD}
R_RUDDERVATOR = Ruddervators:new{dataref = R_RUD}

local function hypR()
    local msin = function (a) return math.sin(math.rad(a)) end
    local mcos = function (a) return math.cos(math.rad(a)) end
    local g = get(Weather_g)
    local TAS = Math_clamp_lower(get(TAS_ms), 0.1)
    local VPATH = get(Vpath)
    local ROLL = get(Flightmodel_roll)

    return (g/TAS) * (msin(ROLL) * mcos(VPATH) + get(Total_lateral_g_load))
end

local function GET_MANEUVER_Q(G)
    local g         = get(Weather_g)
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_BANK  = math.rad(get(Flightmodel_roll))
    local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

    return (g / TAS_MS) * (G - math.cos(RAD_VPATH) * math.cos(RAD_BANK))
end

local function NEU_FLT_G()
    local MAX_BANK_COMP = 45
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_BANK_ClAMPED = math.rad(Math_clamp(get(Flightmodel_roll), -MAX_BANK_COMP, MAX_BANK_COMP))

    return math.cos(RAD_VPATH) / math.cos(RAD_BANK_ClAMPED)
end

local function X_to_G(x)

    local G_load_input_table = {
        {-1, -1.5},
        {0,  NEU_FLT_G()},
        {1,  9},
    }

    return Table_interpolate(G_load_input_table, x)
end

local pitchPID = PID:new{kp = 20, ki = 55, kd = 0, minout = -30, maxout = 30}
local damperPID = PID:new{kp = 50, kd = 1, minout = -60, maxout = 60}

function update()
    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            LE_SLAT:alphaDeploy()

            local pitchoutput = pitchPID:compute(GET_MANEUVER_Q(X_to_G(get(FCTL_INPUT_Y))), get(Flightmodel_q))
            L_FLAPERON:actuate( get(FCTL_INPUT_X) * 30 - pitchoutput)
            R_FLAPERON:actuate(-get(FCTL_INPUT_X) * 30 - pitchoutput)

            local yawDamperOutput = damperPID:compute(hypR(), get(Flightmodel_r))
            L_RUDDERVATOR:actuate(-pitchoutput - yawDamperOutput)
            R_RUDDERVATOR:actuate(-pitchoutput + yawDamperOutput)
        end
    end
end