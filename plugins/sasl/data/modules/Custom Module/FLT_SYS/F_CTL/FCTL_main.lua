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

set(Override_forces, 1)
function onPlaneLoaded() set(Override_forces, 1) end
function onAirportLoaded() set(Override_forces, 1) end
function onModuleShutdown() set(Override_forces, 0) end

function update()
    set(Flightmodel_TOT_NRM_FORCE,
        get(Flightmodel_GEAR_NRM_FORCE) +
        get(Flightmodel_PROP_NRM_FORCE) +
        get(Flightmodel_AERO_NRM_FORCE)
    )
    set(Flightmodel_TOT_AXL_FORCE,
        get(Flightmodel_GEAR_AXL_FORCE) +
        get(Flightmodel_PROP_AXL_FORCE) +
        get(Flightmodel_AERO_AXL_FORCE)
    )
    set(Flightmodel_TOT_SDE_FORCE,
        get(Flightmodel_GEAR_SDE_FORCE) +
        get(Flightmodel_PROP_SDE_FORCE) +
        get(Flightmodel_AERO_SDE_FORCE)
    )

    set(Flightmodel_TOT_L,
        get(Flightmodel_GEAR_L) +
        get(Flightmodel_MASS_L) +
        get(Flightmodel_PROP_L) +
        get(Flightmodel_AERO_L) +
        get(FBW_ROLL_DEF)
    )
    set(Flightmodel_TOT_M,
        get(Flightmodel_GEAR_M) +
        get(Flightmodel_MASS_M) +
        get(Flightmodel_PROP_M) +
        get(Flightmodel_AERO_M) +
        get(FBW_PITCH_DEF)
    )
    set(Flightmodel_TOT_N,
        get(Flightmodel_GEAR_N) +
        get(Flightmodel_MASS_N) +
        get(Flightmodel_PROP_N) +
        get(Flightmodel_AERO_N) +
        get(FBW_YAW_DEF)
    )

    FCTL.LE_SLAT:alphaDeploy()

    FCTL.L_FLAPERON:actuate(-get(FCTL_INPUT_Y) * 30 + get(FCTL_INPUT_X) * 30)
    FCTL.R_FLAPERON:actuate(-get(FCTL_INPUT_Y) * 30 - get(FCTL_INPUT_X) * 30)

    FCTL.L_RUDDERVATOR:actuate(-get(FCTL_INPUT_Y) * 30 - get(FCTL_INPUT_YAW) * 30)
    FCTL.R_RUDDERVATOR:actuate(-get(FCTL_INPUT_Y) * 30 + get(FCTL_INPUT_YAW) * 30)
end