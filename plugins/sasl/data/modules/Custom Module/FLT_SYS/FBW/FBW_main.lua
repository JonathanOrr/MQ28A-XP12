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
-- File: FBW_main.lua
-- Short description: Fly-by-wire main file
-------------------------------------------------------------------------------
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/FBW/Augmentation")

components = {
    longitudinal {},
    lateral {},
    directional {},
}

function update()
    updateAll(components)

    local maxL = 100000
    local maxM = 18000
    local maxN = 100000

    local TASL = SmoothRescale(2.5, 0, 0, 70, maxL, get(TAS_ms) * 1.944)
    local TASM = SmoothRescale(2.5, 0, 0, 70, maxM, get(TAS_ms) * 1.944)
    local TASN = SmoothRescale(2.5, 0, 0, 70, maxN, get(TAS_ms) * 1.944)

    FBW.PIDs.p.maxout,               FBW.PIDs.p.minout = TASL, -TASL
    FBW.PIDs.q.maxout,               FBW.PIDs.q.minout = TASM, -TASM
    FBW.PIDs.alphaMin.maxout, FBW.PIDs.alphaMin.minout = TASM, -TASM
    FBW.PIDs.alphaMax.maxout, FBW.PIDs.alphaMax.minout = TASM, -TASM
    FBW.PIDs.r.maxout,               FBW.PIDs.r.minout = TASN, -TASN
end
