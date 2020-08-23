dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")

local portal = GetUpdatedEntityID()
local portal_type = EntityGetName(portal)

-- Remove any siblings also when portals are initialized, for
-- the rare case of you getting two projectiles off before either
-- hits a wall (easier under water).
remove_portal_siblings(portal_type, portal)

local isBlue = portal_type == "portal_blue"
local global = isBlue and "PG_BLUE_SHOT_ANGLE" or "PG_ORANGE_SHOT_ANGLE"

local shooting_angle = tonumber(GlobalsGetValue(global, "0"))
local x, y = EntityGetTransform(portal)

-- Adjust angle and position so that the portal is always facing Minä.
EntitySetTransform(portal, x, y, -shooting_angle)
