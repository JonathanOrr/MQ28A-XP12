--Class declarations-- ================================================= as separators
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

FCTL.LE_SLAT = SlatsSys:new{dataref = Slats}

FCTL.L_FLAPERON = Flaperons:new{dataref = L_AIL}
FCTL.R_FLAPERON = Flaperons:new{dataref = R_AIL}

FCTL.L_RUDDERVATOR = Ruddervators:new{dataref = L_RUD}
FCTL.R_RUDDERVATOR = Ruddervators:new{dataref = R_RUD}

function update()
    FCTL.LE_SLAT:alphaDeploy()

    FCTL.L_FLAPERON:actuate(get(FBW_PITCH_DEF) + get(FCTL_INPUT_X) *  30)
    FCTL.R_FLAPERON:actuate(get(FBW_PITCH_DEF) + get(FCTL_INPUT_X) * -30)

    FCTL.L_RUDDERVATOR:actuate(get(FBW_PITCH_DEF) - get(FBW_YAW_DEF))
    FCTL.R_RUDDERVATOR:actuate(get(FBW_PITCH_DEF) + get(FBW_YAW_DEF))
end