
local clones = EntityGetWithTag("portal_blue")

for _, sibling in ipairs(clones) do
  if sibling ~= portal then
    local x, y = EntityGetTransform(sibling)
    GamePlaySound(
      "mods/portalgun/files/audio/Desktop/portal.snd",
      "misc/portal_blue_close/create",
      x, y
    )
    EntityKill(sibling)
  end
end
