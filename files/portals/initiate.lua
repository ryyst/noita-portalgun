local portal = GetUpdatedEntityID()
local portal_type = EntityGetName(portal)

local clones = EntityGetWithTag(portal_type)

for _, sibling in ipairs(clones) do
  if sibling ~= portal then
    EntityKill(sibling)
  end
end


-- Adjust angle and position

local angle

if portal_type == "portal_blue" then
  angle = tonumber(GlobalsGetValue("PG_BLUE_SHOT_ANGLE", "0"))
else
  angle = tonumber(GlobalsGetValue("PG_ORANGE_SHOT_ANGLE", "0"))
end

local x, y = EntityGetTransform(portal)

EntitySetTransform(portal, x, y, -angle)
