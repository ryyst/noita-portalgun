dofile_once("data/scripts/lib/utilities.lua")

local portal = GetUpdatedEntityID()
local portal_type = EntityGetName(portal)

local clones = EntityGetWithTag(portal_type)

for _, sibling in ipairs(clones) do
  if sibling ~= portal then
    EntityKill(sibling)
  end
end


local isBlue = portal_type == "portal_blue"
local global = isBlue and "PG_BLUE_SHOT_ANGLE" or "PG_ORANGE_SHOT_ANGLE"

local shooting_angle = tonumber(GlobalsGetValue(global, "0"))
local x, y = EntityGetTransform(portal)

-- Adjust angle and position so that the portal is always facing Minä.
EntitySetTransform(portal, x, y, -shooting_angle)
