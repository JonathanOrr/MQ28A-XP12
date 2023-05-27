include("FLT_SYS/libs/signal_processing.lua")
include("FLT_SYS/libs/angular_rates.lua")

local tunnerkP = createGlobalPropertyf("MQ28/dynamics/FBW/livetuning/kp", 1, false, true, false)
local tunnerkI = createGlobalPropertyf("MQ28/dynamics/FBW/livetuning/ki", 0, false, true, false)
local tunnerkD = createGlobalPropertyf("MQ28/dynamics/FBW/livetuning/kd", 0, false, true, false)

local test_tbl = {
    x = 0,
    y = 0,
    w = 700,
    h = 500,
    xlim = 5, --in seconds
    ylim = {-2, 2},
    xbars = {1, 2, 3, 4},
    ybars = nil,
    data = {},
    dt = {},
}

local function Grapher_update(tbl, data_tble)
    if get(DELTA_TIME) == 0 then return end

    --sum the elapsed time
    local time = 0
    local dt_to_del = 0
    for i = 1, #tbl.dt do
        if time > tbl.xlim then
            dt_to_del = #tbl.dt - i
            break
        else
            time = time + tbl.dt[i]
        end
    end

    --initialize or add to value history
    for key, val in pairs(data_tble) do
        if not tbl.data[key] then
            tbl.data[key] = {
                color = val.color,
                graph = val.graph,
                number = val.number,
                value = {
                    val.value
                },
            }
        else
            for i = 1, dt_to_del do
                table.remove(tbl.data[key].value, 1)
            end

            table.insert(tbl.data[key].value, val.value)
        end
    end

    --process dt table
    for i = 1, dt_to_del do
        table.remove(tbl.dt, 1)
    end

    table.insert(tbl.dt, get(DELTA_TIME))
end


local function Grapher_draw_function(tbl, funcs)
    sasl.gl.setClipArea(tbl.x, tbl.y, tbl.w, tbl.h)

    local txt_drawn = 0
    for key, val in pairs(funcs) do
        for i = 1, val.sample do
            local x = Math_rescale(1, val.dom[1], val.sample, val.dom[2], i)
            local x_next = Math_rescale(1, val.dom[1], val.sample, val.dom[2], i + 1)
            local y = val.func(x)
            local y_next = val.func(x_next)

            sasl.gl.drawLine(
                Math_rescale_no_lim(val.dom[1],  tbl.x,  val.dom[2], tbl.x + tbl.w, x),
                Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, y),
                Math_rescale_no_lim(val.dom[1],  tbl.x,  val.dom[2], tbl.x + tbl.w, x_next),
                Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, y_next),
                val.color
            )
        end

        sasl.gl.drawText(Font_B612MONO_regular, tbl.x + tbl.w - 5, tbl.y + tbl.h - 15 - 15 * txt_drawn, key, 12, false, false, TEXT_ALIGN_RIGHT, val.color)
        txt_drawn = txt_drawn + 1
    end

    sasl.gl.resetClipArea()
end


local function Grapher_draw(tbl)
    sasl.gl.setClipArea(tbl.x, tbl.y, tbl.w, tbl.h)
    sasl.gl.drawRectangle(tbl.x, tbl.y, tbl.w, tbl.h, UI_DARK_GREY)

    --darw background
    sasl.gl.drawLine(
        0,
        Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, 0),
        tbl.x + tbl.w,
        Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, 0),
        ECAM_GREY
    )

    if tbl.xbars then
        for key, val in pairs(tbl.xbars) do
            sasl.gl.drawLine(Math_rescale(0, tbl.x, tbl.xlim, tbl.x + tbl.w, val), tbl.y, Math_rescale(0, tbl.x, tbl.xlim, tbl.x + tbl.w, val), tbl.y + tbl.h, ECAM_GREY)
        end
    end

    if tbl.ybars then
        for key, val in pairs(tbl.ybars) do
            sasl.gl.drawLine(tbl.x, Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val), tbl.x + tbl.w, Math_rescale(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val), ECAM_GREY)
        end
    end

    --draw data lins
    local txt_drawn = 0
    for key, val in pairs(tbl.data) do
        local time = 0
        for i = 1, #tbl.dt - 1 do
            if val.graph then
                sasl.gl.drawLine(
                    Math_rescale_no_lim(0,           tbl.x,    tbl.xlim, tbl.x + tbl.w,             time),
                    Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h,     val.value[i]),
                    Math_rescale_no_lim(0,           tbl.x,    tbl.xlim, tbl.x + tbl.w, time + tbl.dt[i]),
                    Math_rescale_no_lim(tbl.ylim[1], tbl.y, tbl.ylim[2], tbl.y + tbl.h, val.value[i + 1]),
                    val.color
                )
            end

            time = time + tbl.dt[i]

            if i == #tbl.dt - 1 then
                local txt = key
                if val.number then
                    txt = txt .. ": " .. Round_fill(val.value[#val.value], 4)
                end

                sasl.gl.drawText(Font_B612MONO_regular, tbl.x + 5, tbl.y + tbl.h - 15 - 15 * txt_drawn, txt, 12, false, false, TEXT_ALIGN_LEFT, val.color)
                txt_drawn = txt_drawn + 1
            end
        end
    end

    sasl.gl.resetClipArea()
end

local function initPIDTunner(PIDobj)
    set(tunnerkP, PIDobj.kp)
    set(tunnerkI, PIDobj.ki)
    set(tunnerkD, PIDobj.kd)
end

local function PIDTunner(PIDobj)
    PIDobj.kp = get(tunnerkP)
    PIDobj.ki = get(tunnerkI)
    PIDobj.kd = get(tunnerkD)
end

local xprevAP = 0
local yprevAP = 0

-- Define the filter function
local function allpass_filter(x, breakfreq, sampfreq)
    if get(DELTA_TIME) == 0 then return 0 end
    local dt = get(DELTA_TIME)

    -- Define the filter coefficients
    local a = (math.tan(math.pi * breakfreq * dt) - 1) / 
              (math.tan(math.pi * breakfreq * dt) + 1)-- the feedback coefficient
    
    -- Calculate the filter output
    local y = a*x + xprevAP - a*yprevAP
    
    -- Update the filter state variables
    xprevAP = x
    yprevAP = y
    
    -- Return the filter output
    return y
end

local vpprevSAP = 0
local vprevSAP = 0

local function secOrdAPfilter(x, breakfreq, BW)
    if get(DELTA_TIME) == 0 then return 0 end
    local dt = get(DELTA_TIME)

    -- Define the filter coefficients
    local c = (math.tan(math.pi * BW * dt) - 1) /
              (math.tan(math.pi * BW * dt) + 1)
    local d = -math.cos(2*math.pi * breakfreq * dt)

    -- Calculate the filter output
    local v = x - d*(1-c)*vprevSAP + c*vpprevSAP
    local y = -c*v + d*(1-c)*vprevSAP + vpprevSAP

    vpprevSAP = vprevSAP
    vprevSAP = v

    -- Return the filter output
    return y
end

local function f(x)
    return math.floor(math.cos(2*math.pi*x)) + 0.1*(math.random() - 0.5)*2 --+ 0.1*math.cos(10*2*math.pi*x)
end


local LowPass = {freq = 10}

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

local newLP = LowPass:new{freq=1}
local newLP2 = LowPass:new{freq=1}
local newLP3 = LowPass:new{freq=1}

local CL = globalProperty("sim/flightmodel/misc/cl_overall")
local CD = globalProperty("sim/flightmodel/misc/cd_overall")

initPIDTunner(FBW.PIDs.q)
function update()
    if not FBW_PID_debug_window:isVisible() then return end

    --PIDTunner(FBW.PIDs.q)

    newLP.freq = get(tunnerkD)
    newLP2.freq = get(tunnerkD)
    newLP3.freq = get(tunnerkD)

    local temp = get(Alpha)--f(get(TIME))
    local cascadefilt = newLP:filterOut(temp)
    cascadefilt = newLP2:filterOut(cascadefilt)
    Grapher_update(test_tbl, {
        ["P PID err"] = {graph = true, number = true, color = ECAM_RED, value = get(CL)},--FBW.PIDs.q.error},
        --["P PID P"] = {graph = true, number = true, color = ECAM_WHITE, value = FBW.PIDs.q.P},
        --["P PID I"] = {graph = true, number = true, color = ECAM_BLUE, value = FBW.PIDs.q.I},
        --["P PID D"] = {graph = true, number = true, color = ECAM_GREEN, value = FBW.PIDs.q.D},
        --["P PID output"] = {graph = true, number = true, color = ECAM_YELLOW, value = FBW.PIDs.q.output},
        --["raw"] = {graph = true, number = true, color = ECAM_WHITE, value = getVpathQ()},
        --["filtered"] = {graph = true, number = true, color = ECAM_YELLOW, value = 0.5*temp + 0.5*allpass_filter(temp, get(tunnerkP))},
        --["old filter"] = {graph = true, number = true, color = ECAM_GREEN, value = newLP3:filterOut(cascadefilt)},
    })
end

function draw()
    Grapher_draw(test_tbl)
    Grapher_draw_function(test_tbl, {
        --sin = {color = ECAM_MAGENTA, func = function(x) return math.sin(math.rad(x)) end, dom = {-180, 180}, sample = 50},
    })
end