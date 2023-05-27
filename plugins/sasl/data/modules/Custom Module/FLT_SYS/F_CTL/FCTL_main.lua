--Class declarations-- ================================================= as separators
ControlSurface = {
    multiDataref = false,
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
    if self.multiDataref then
        for _, dataref in ipairs(self.dataref) do
            set(dataref, self.def)
        end
    end

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
--=====================================================================================
SlatsSys = ControlSurface:new{
    defsmoothmargin = 0.1,
    maxdefspd = 1,

    maxdef = 1,
    mindef = 0
}

function SlatsSys:alphaDeploy()
    local slatDefReq = Math_rescale(10, self.mindef, 20, self.maxdef, get(Alpha))
    self:actuate(slatDefReq)
end
--=====================================================================================
local superManeuverSys = {
    L = {
        dataref = Flightmodel_PLG_L,
        limit = 0, --the total force the system can add
        maxTAS = 0, --the max speed where moment is added
        surfs = {
            {nil, reversed = false}, --surfaces that affects the moment forces
        }
    },
    M = {
        dataref = Flightmodel_PLG_M,
        limit = 0,
        maxTAS = 0,
        surfs = {
            {nil, reversed = false},
        }
    },
    N = {
        dataref = Flightmodel_PLG_N,
        limit = 0,
        maxTAS = 0,
        surfs = {
            {obj = nil, reversed = false},
        }
    },
}

function superManeuverSys:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function superManeuverSys:applyMoments()
    local momentAxis = {self.L, self.M, self.N}

    for _, axis in ipairs(momentAxis) do
        local totalDef = 0
        local maxTotalDef = 0
        for _, surfPair in ipairs(axis.surfs) do
            maxTotalDef = maxTotalDef + math.abs(surfPair.obj.maxdef)

            if surfPair.reversed then
                totalDef = totalDef - surfPair.obj.def
            else
                totalDef = totalDef + surfPair.obj.def
            end
        end

        local maxMoment = SmoothRescale(2.5, 0, 0, axis.maxTAS, axis.limit, get(TAS_ms) * 1.944)
        set(axis.dataref, maxMoment * (totalDef / maxTotalDef))
    end
end
--=====================================================================================

FCTL.LE_SLAT = SlatsSys:new{dataref = Slats}

FCTL.L_AIL = ControlSurface:new{dataref = L_AIL}
FCTL.R_AIL = ControlSurface:new{dataref = R_AIL}

FCTL.L_FLAPERON = ControlSurface:new{dataref = L_FLAPERON, multiDataref = true}
FCTL.R_FLAPERON = ControlSurface:new{dataref = R_FLAPERON, multiDataref = true}

FCTL.L_HSTABLITOR = ControlSurface:new{dataref = L_ELEV, multiDataref = true}
FCTL.R_HSTABLITOR = ControlSurface:new{dataref = R_ELEV, multiDataref = true}

FCTL.L_RUDDER = ControlSurface:new{dataref = L_RUD}
FCTL.R_RUDDER = ControlSurface:new{dataref = R_RUD}

FCTL.L_VEC = ControlSurface:new{dataref = L_VECT}
FCTL.R_VEC = ControlSurface:new{dataref = R_VECT}

local M28SuperManSys = superManeuverSys:new{
    L = {
        dataref = Flightmodel_PLG_L,
        limit = 500000, --the total force the system can add
        maxTAS = 70, --the max speed where moment is added
        surfs = {
            {obj = FCTL.L_FLAPERON, reversed = false},
            {obj = FCTL.R_FLAPERON, reversed = true},
        }
    },
    M = {
        dataref = Flightmodel_PLG_M,
        limit = 0,--500000,
        maxTAS = 70,
        surfs = {
            --{obj = FCTL.L_FLAPERON, reversed = true},
            --{obj = FCTL.R_FLAPERON, reversed = true},
            {obj = FCTL.L_HSTABLITOR, reversed = true},
            {obj = FCTL.R_HSTABLITOR, reversed = true},
        }
    },
    N = {
        dataref = Flightmodel_PLG_N,
        limit = 0,--500000,
        maxTAS = 70,
        surfs = {
            {obj = FCTL.L_RUDDER, reversed = true},
            {obj = FCTL.R_RUDDER, reversed = false},
        }
    },
}

function update()
    FCTL.LE_SLAT:alphaDeploy()

    FCTL.L_AIL:actuate( get(FBW_ROLL_DEF) - get(SPDBRK_RAT) * 30)--get(FBW_PITCH_DEF) + get(FBW_ROLL_DEF))
    FCTL.R_AIL:actuate(-get(FBW_ROLL_DEF) - get(SPDBRK_RAT) * 30)--get(FBW_PITCH_DEF) - get(FBW_ROLL_DEF))

    local flapDef = 30 * (get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment)) / 3
    FCTL.L_FLAPERON:actuate(Math_rescale(-60, -30, -30, 0, get(FBW_ROLL_DEF)) + Math_rescale(30, 0, 60,  30, get(FBW_ROLL_DEF)) + flapDef)
    FCTL.R_FLAPERON:actuate(Math_rescale(-60,  30, -30, 0, get(FBW_ROLL_DEF)) + Math_rescale(30, 0, 60, -30, get(FBW_ROLL_DEF)) + flapDef)

    FCTL.L_HSTABLITOR:actuate(-get(FBW_PITCH_DEF) + get(FBW_ROLL_DEF) / 2)
    FCTL.R_HSTABLITOR:actuate(-get(FBW_PITCH_DEF) - get(FBW_ROLL_DEF) / 2)

    FCTL.L_RUDDER:actuate(-get(FBW_YAW_DEF) + get(SPDBRK_RAT) * 30)
    FCTL.R_RUDDER:actuate( get(FBW_YAW_DEF) + get(SPDBRK_RAT) * 30)

    FCTL.L_VEC:actuate(-get(FBW_PITCH_DEF) + get(FBW_ROLL_DEF) / 2)
    FCTL.R_VEC:actuate(-get(FBW_PITCH_DEF) - get(FBW_ROLL_DEF) / 2)

    --M28SuperManSys:applyMoments()
end