dofile_once("mods/portalgun/files/utilities.lua")

-- TODO: Make this work.
--
-- This is disabled for now, as the current implementation
-- starts creating a lot of crazy alchemical concoctions out of
-- singular materials. Guaranteed creepy liquid in notime.


local portal = GetUpdatedEntityID()
local portal_type = EntityGetName(portal)
local target = get_target(portal_type)

local matInv = EntityGetFirstComponentIncludingDisabled(portal, "MaterialInventoryComponent")
local allMaterials = ComponentGetValue2(matInv, "count_per_material_type")

local hasIngested = false
for k, v in pairs(allMaterials) do
  if v > 0 then
    local x, y = EntityGetTransform(target)
    local name = CellFactory_GetName(k)
    --GamePrint("FOUND: " .. name .. " " .. str(v))
    --GameCreateParticle( name, x, y, 5, 40, 20, false)

    allMaterials[k] = 0
    hasIngested = true
  end
end

if hasIngested then
  -- This produces the error:
  -- "ComponentSetValue2 - field 'count_per_material_type' has unsupported type."
  --ComponentSetValue2(matInv, "count_per_material_type", allMaterials)
end
