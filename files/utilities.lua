function physics_enabled(entity, enable)
  for _, physComp in pairs({"PhysicsBodyComponent", "PhysicsBody2Component"}) do
    local phys1 = EntityGetComponentIncludingDisabled(entity, "PhysicsBodyComponent")
    if phys1 then
      for _, comp in ipairs(phys1) do
        GamePrint(comp)
        EntitySetComponentIsEnabled(entity, comp, enable)
      end
    end
  end
end

function remove_joints(entity)
  local removable_components = {"PhysicsJointComponent", "PhysicsJoint2Component", "PhysicsJoint2MutatorComponent"}
  for _, jointComp in pairs(removable_components) do
    local joints = EntityGetComponentIncludingDisabled(entity, jointComp)
    if joints then
      for _, comp in ipairs(joints) do
        EntityRemoveComponent(entity, comp)
      end
    end
  end
end

function vec_to_rad(x, y)
  return math.atan2(y, x)
end


function get_target(portal_type)
  if portal_type == "portal_blue" then
    return EntityGetWithName("portal_orange")
  end
  return EntityGetWithName("portal_blue")
end


----------------------------------------------------------------
-- GENERAL UTILITIES
----------------------------------------------------------------

-- Missing Python?
function float(var)
  return tonumber(var)
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


function debug_entity(e)
    local parent = EntityGetParent(e)
    local children = EntityGetAllChildren(e)
    local comps = EntityGetAllComponents(e)

    print("--- ENTITY DATA ---")
    print("Parent: ["..parent.."] " .. (EntityGetName(parent) or "nil"))

    print(" Entity: ["..str(e).."] " .. (EntityGetName(e) or "nil"))
    print("  Tags: " .. (EntityGetTags(e) or "nil"))
    if (comps ~= nil) then
      for _, comp in ipairs(comps) do
          print("  Comp: ["..comp.."] " .. (ComponentGetTypeName(comp) or "nil"))
      end
    end

    if children == nil then return end

    for _, child in ipairs(children) do
        local comps = EntityGetAllComponents(child)
        print("  Child: ["..child.."] " .. EntityGetName(child))
        for _, comp in ipairs(comps) do
            print("   Comp: ["..comp.."] " .. (ComponentGetTypeName(comp) or "nil"))
        end
    end
    print("--- END ENTITY DATA ---")
end


function debug_component(comp)
  print("--- COMPONENT DATA ---")
  print(str(ComponentGetMembers(comp)))
  print("--- END COMPONENT DATA ---")
end
