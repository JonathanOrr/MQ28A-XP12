include("libs/geo-helpers.lua")

size = {256, 256}
position = {768, 0, 256, 256}

local mcos = math.cos
local msin = math.sin
local mtan = math.tan
local mcosd = function(a) return math.cos(math.rad(a)) end
local msind = function(a) return math.sin(math.rad(a)) end
local mtand = function(a) return math.tan(math.rad(a)) end

--camera definition
local XINF = 1 --just so matrix operations works (when projected at infinity the x values cancels)
local fov = math.deg(math.atan(0.176)) * 2
local ez = 1 / mtand(fov/2);

--3D rotation matrices
local function Rx(a, vec)
    local output = {}
    output[1] = vec[1]
    output[2] = mcosd(a) * vec[2] - msind(a) * vec[3]
    output[3] = msind(a) * vec[2] + mcosd(a) * vec[3]
    return output
end
local function Ry(a, vec)
    local output = {}
    output[1] =  mcosd(a) * vec[1] + msind(a) * vec[3]
    output[2] =  vec[2]
    output[3] = -msind(a) * vec[1] + mcosd(a) * vec[3]
    return output
end
local function Rz(a, vec)
    local output = {}
    output[1] = mcosd(a) * vec[1] - msind(a) * vec[2]
    output[2] = msind(a) * vec[1] + mcosd(a) * vec[2]
    output[3] = vec[3]
    return output
end

local testRwy = {{-37.731185, 144.892862}, {-37.731576, 144.892883}, {-37.730985, 144.914668}, {-37.730594, 144.914655}}

function draw()
    --sasl.gl.drawCircle(128, 128, 128, true, {0,1,0})
    local rwyPoly = {}
    for _, coord in ipairs(testRwy) do
        local dist = GC_distance_km(get(Aircraft_lat), get(Aircraft_long), coord[1], coord[2]) * 1000
        local bear = get_earth_bearing(get(Aircraft_lat), get(Aircraft_long), coord[1], coord[2])
        --bear = (bear + 180) % 360 - 180
        --local angle = -math.deg(math.atan((get(ACF_elevation) - 74.473) / dist))

        --intrinsic rotation yaw -> pitch -> roll
        --local Vec3d = Rx(get(Flightmodel_roll), Ry(get(Flightmodel_pitch) - angle, Rz(bear - get(Flightmodel_true_heading), {XINF, 0, 0})))
        local Vec3d = Rx(get(Flightmodel_roll), Ry(get(Flightmodel_pitch), Rz(bear - get(Flightmodel_true_heading), {dist, 0, (74.473 - get(ACF_elevation))})))

        --3d -> 2d projection
        local bx = ez * Vec3d[2] / Vec3d[1]
        local by = ez * Vec3d[3] / Vec3d[1]
        local lineXcent = size[1]/2 + bx * size[1]/2
        local lineYcent = size[2]/2 + by * size[2]/2

        -- sasl.gl.drawCircle(
        --     lineXcent,
        --     lineYcent,
        --     5,
        --     true,
        --     {0,1,0}
        -- )
        table.insert(rwyPoly, lineXcent)
        table.insert(rwyPoly, lineYcent)
    end
    sasl.gl.drawConvexPolygon(rwyPoly, false, 2, {0,1,0})

    local pitchLadder = {-30, -25, -20, -15, -10 , -5, 0, 5, 10, 15, 20, 25, 30, get(Vpath)}
    for key, val in ipairs(pitchLadder) do
        --intrinsic rotation yaw -> pitch -> roll
        --the final coordinate z''' points to the sky y''' points to the right wing x''' points out the nose
        --CAUTION it's a left hand coordinate system, cross product does not work...
        local Vec3d
        if key == #pitchLadder then
            Vec3d = Rx(get(Flightmodel_roll), Ry(get(Flightmodel_pitch) - val, Rz(get(Flightmodel_true_track) - get(Flightmodel_true_heading), {XINF, 0, 0})))
        else
            Vec3d = Rx(get(Flightmodel_roll), Ry(get(Flightmodel_pitch) - val, {XINF, 0, 0}))
        end

        --3d -> 2d projection
        local bx = ez * Vec3d[2] / Vec3d[1]
        local by = ez * Vec3d[3] / Vec3d[1]

        --2d image rotation
        --local x = bx * mcosd(get(Flightmodel_roll)) - by * msind(get(Flightmodel_roll))
        --local y = bx * msind(get(Flightmodel_roll)) + by * mcosd(get(Flightmodel_roll))

        local lineXcent = size[1]/2 + bx * size[1]/2
        local lineYcent = size[2]/2 + by * size[2]/2

        sasl.gl.drawCircle(
            lineXcent,
            lineYcent,
            5,
            true,
            {0,1,0}
        )
        sasl.gl.drawRotatedText(
            Font_ECAMfont,
            lineXcent,
            lineYcent,
            lineXcent,
            lineYcent,
            -get(Flightmodel_roll),
            Round_fill(val, 1),
            20,
            false,
            false,
            TEXT_ALIGN_CENTER,
            {0,1,0}
        )

        if key == #pitchLadder then
            sasl.gl.drawCircle(
                lineXcent,
                lineYcent,
                5,
                true,
                {0,1,0}
            )
        else
            --sasl.gl.drawWideLine(lineXcent - 80 * mcosd(get(Flightmodel_roll))), lineYcent - 80 * msind(get(Flightmodel_roll))), lineXcent + 80 * mcosd(get(Flightmodel_roll))), lineYcent + 80 * msind(get(Flightmodel_roll))), 2, {1, 0, 0})
        end
    end
end