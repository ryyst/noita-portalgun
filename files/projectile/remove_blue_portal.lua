
local clones = EntityGetWithTag("portal_blue")

for _, sibling in ipairs(clones) do
  if sibling ~= portal then
    EntityKill(sibling)
  end
end
