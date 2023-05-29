--common lib--
local function mathSign(val)
    return val > 0 and 1 or (val == 0 and 0 or -1)
end

--Draw 3D library--
D3D = {}
D3D.static = {}

--Class declarations-- ================================================= as separators
D3D.static.vec2 = {}
D3D.vec2 = {x=0, y=0}

function D3D.vec2:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Properties --

function D3D.vec2:magnitude()
    return math.sqrt(self.x^2 + self.y^2)
end

function D3D.vec2:normalized()
    local mag = self:magnitude()
    local normX, normY = self.x / mag, self.y / mag
    local normVec = self:new{x = normX, y = normY}

    return normVec
end

function D3D.vec2:sqrMagnitude()
    return self.x^2 + self.y^2
end

-- Public Methods --

--- Returns true if the given vector is exactly equal to this vector.
function D3D.vec2:Equals(other)
    local equal = true

    if other.x ~= self.x then equal = false end
    if other.y ~= self.y then equal = false end

    return equal
end

--- Makes this vector have a magnitude of 1.
-- TODO: check if this thing worls
function D3D.vec2:Normalize()
    local mag = self:magnitude()
    self.x, self.y = self.x / mag, self.y / mag
end

--- Returns a formatted string for this vector.
function D3D.vec2:ToString(fmt)
    return string.format(fmt, self.x, self.y)
end

-- Static Methods --

--- Gets the unsigned angle in degrees between from and to.
D3D.static.vec2.Angle = function (from, to)
    local magf, magt = from:magnitude(), to:magnitude()
    local dot = from.x*to.x + from.y*to.y

    return math.deg(math.acos(dot / (magf * magt)))
end

--- Returns a copy of vector with its magnitude clamped to maxLength.
--- @param maxLength number
--TODO: check if this thing works
D3D.static.vec2.ClampMagnitude = function (vec, maxLength)
    local mag = vec:magnitude()
    local scale = math.min(maxLength, mag) / mag
    local clampedX, clampedY = vec.x * scale, vec.y * scale

    return D3D.vec2:new{x = clampedX, y = clampedY}
end

--- Returns the distance between a and b.
D3D.static.vec2.Distance = function (a, b)
    local diffX, diffY = a.x - b.x, a.y - b.y

    return math.sqrt(diffX^2 + diffY^2)
end

--- Dot Product of two vectors.
D3D.static.vec2.Dot = function (lhs, rhs)
    return lhs.x*rhs.x + lhs.y*rhs.y
end

--- Returns a vector that is made from the largest components of two vectors.
D3D.static.vec2.Max = function (lhs, rhs)
    local maxX, maxY = math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y)
    return D3D.vec2:new{x = maxX, y = maxY}
end

--- Returns a vector that is made from the smallest components of two vectors.
D3D.static.vec2.Min = function (lhs, rhs)
    local minX, minY = math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y)
    return D3D.vec2:new{x = minX, y = minY}
end

--- Returns the 2D vector perpendicular to this 2D vector. The result is always rotated 90-degrees in a counter-clockwise direction for a 2D coordinate system where the positive Y axis goes up.
D3D.static.vec2.Perpendicular = function (inDirection)
    local xPer = math.cos(math.rad(90)) * inDirection.x - math.sin(math.rad(90)) * inDirection.y
    local yPer = math.sin(math.rad(90)) * inDirection.x + math.cos(math.rad(90)) * inDirection.y

    return D3D.vec2:new{x = xPer, y = yPer}
end

--- Gets the signed angle in degrees between from and to.
D3D.static.vec2.SignedAngle = function (from, to)
    local unsignedAngle = D3D.static.vec2.Angle(from, to)
    local crossMag = from.x*to.y - from.y*to.x
    local sign = mathSign(crossMag)

    return sign * unsignedAngle
end
--====================================================================================
D3D.static.vec3 = {}
D3D.vec3 = {x=0, y=0, z=0}

function D3D.vec3:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Properties --

--- Returns the length of this vector
function D3D.vec3:magnitude()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

--- Returns this vector with a magnitude of 1
function D3D.vec3:normalized()
    local mag = self:magnitude()
    local normX, normY, normZ = self.x / mag, self.y / mag, self.z / mag
    local normVec = self:new{x = normX, y = normY, z = normZ}

    return normVec
end

--- Returns the squared length of this vector
function D3D.vec3:sqrMagnitude()
    return self.x^2 + self.y^2 + self.z^2
end

-- Public Methods --

--- Returns true if the given vector is exactly equal to this vector.
function D3D.vec3:Equals(other)
    local equal = true

    if other.x ~= self.x then equal = false end
    if other.y ~= self.y then equal = false end
    if other.z ~= self.z then equal = false end

    return equal
end

--- Makes this vector have a magnitude of 1.
-- TODO: check if this thing worls
function D3D.vec3:Normalize()
    local mag = self:magnitude()
    self.x, self.y, self.z = self.x / mag, self.y / mag, self.z / mag
end

--- Returns a formatted string for this vector.
function D3D.vec3:ToString(fmt)
    return string.format(fmt, self.x, self.y, self.z)
end

-- Static Methods --

--- Gets the unsigned angle in degrees between from and to.
D3D.static.vec3.Angle = function (from, to)
    local magf, magt = from:magnitude(), to:magnitude()
    local dot = from.x*to.x + from.y*to.y + from.z*to.z

    return math.deg(math.acos(dot / (magf * magt)))
end

--- Returns a copy of vector with its magnitude clamped to maxLength.
--- @param maxLength number
--TODO: check if this thing works
D3D.static.vec3.ClampMagnitude = function (vec, maxLength)
    local mag = vec:magnitude()
    local scale = math.min(maxLength, mag) / mag
    local clampedX, clampedY, clampedZ = vec.x * scale, vec.y * scale, vec.z * scale

    return D3D.vec3:new{x = clampedX, y = clampedY, z = clampedZ}
end

--- Cross Product of two vectors.
D3D.static.vec3.Cross = function(fir, sec)
    local crossX =  (fir.y*sec.z - fir.z*sec.y)
    local crossY = -(fir.x*sec.z - fir.z*sec.x)
    local crossZ =  (fir.x*sec.y - fir.y*sec.x)

    return D3D.vec3:new{x = crossX, y = crossY, z = crossZ}
end

--- Returns the distance between a and b.
D3D.static.vec3.Distance = function (a, b)
    local diffX, diffY, diffZ = a.x - b.x, a.y - b.y, a.z - b.z

    return math.sqrt(diffX^2 + diffY^2 + diffZ^2)
end

--- Dot Product of two vectors.
D3D.static.vec3.Dot = function (lhs, rhs)
    return lhs.x*rhs.x + lhs.y*rhs.y + lhs.z*rhs.z
end

--- Returns a vector that is made from the largest components of two vectors.
D3D.static.vec3.Max = function (lhs, rhs)
    local maxX, maxY, maxZ = math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y), math.max(lhs.z, rhs.z)
    return D3D.vec2:new{x = maxX, y = maxY, z = maxZ}
end

--- Returns a vector that is made from the smallest components of two vectors.
D3D.static.vec3.Min = function (lhs, rhs)
    local minX, minY, minZ = math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y), math.min(lhs.z, rhs.z)
    return D3D.vec2:new{x = minX, y = minY, z = minZ}
end

--- Projects a vector onto another vector.
D3D.static.vec3.Project = function (vector, onNormal)
    local dot = D3D.static.vec3.Dot(vector, onNormal)
    local magSqr = onNormal:sqrMagnitude()
    local projFac = dot / magSqr

    return D3D.vec3:new{x = onNormal.x * projFac, y = onNormal.y * projFac, z = onNormal.z * projFac}
end

D3D.static.vec3.ProjectOnPlane = function (vector, planeNormal)
    local distToPlane = D3D.static.vec3.Project(vector, planeNormal)

    return D3D.vec3:new{x = vector.x - distToPlane.x, y = vector.y - distToPlane.y, z = vector.z - distToPlane.z}
end

--- Calculates the signed angle between vectors from and to in relation to axis.
D3D.static.vec3.SignedAngle = function (from, to, axis)
    -- ((Va x Vb) . Vn) / (Va . Vb)
    -- frome https://stackoverflow.com/questions/5188561/signed-angle-between-two-3d-vectors-with-same-origin-within-the-same-plane
    local aCb = D3D.static.vec3.Cross(from, to)
    local aCbDn = D3D.static.vec3.Dot(aCb, axis)
    local aDb = D3D.static.vec3.Dot(from, to)

    return math.deg(math.atan2(aCbDn, aDb))
end
--====================================================================================