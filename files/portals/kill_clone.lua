local portal = GetUpdatedEntityID()
local portal_type = EntityGetName(portal)

local clones = EntityGetWithTag(portal_type)

for _, sibling in ipairs(clones) do
  if sibling ~= portal then
    EntityKill(sibling)
  end
end
