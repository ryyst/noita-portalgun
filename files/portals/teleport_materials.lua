function get_target(portal_type)
  if portal_type == "portal_blue" then
    return EntityGetWithName("portal_orange")
  end
  return EntityGetWithName("portal_blue")
end


function EntityGetValue(entity, component_name, attr_name)
  return ComponentGetValue2(
    EntityGetFirstComponentIncludingDisabled(entity, component_name), attr_name
  )
end

function str(var)
  if type(var) == 'table' then
    local s = '{ '
    for k,v in pairs(var) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. str(v) .. ','
    end
    return s .. '} '
  end
  return tostring(var)
end


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
    GamePrint("FOUND: " .. name .. " " .. str(v))
    GameCreateParticle( name, x, y, 5, 40, 20, false)

    allMaterials[k] = 0
    hasIngested = true
  end
end

if hasIngested then
  --ComponentSetValue2(matInv, "count_per_material_type", allMaterials)
end


