dofile_once("data/scripts/lib/utilities.lua")

----------------------------------------------------------------
-- PORTAL UTILITIES
----------------------------------------------------------------

function physics_enabled(entity, enable)
  for _, comp_name in pairs({"PhysicsBodyComponent", "PhysicsBody2Component"}) do
    local comps = EntityGetComponentIncludingDisabled(entity, comp_name)
    if not comps then return end

    for _, comp in ipairs(comps) do
      EntitySetComponentIsEnabled(entity, comp, enable)
    end
  end
end

function remove_joints(entity)
  local removable_components = {
    "PhysicsJointComponent", "PhysicsJoint2Component", "PhysicsJoint2MutatorComponent"
  }
  for _, comp_name in pairs(removable_components) do
    local comps = EntityGetComponentIncludingDisabled(entity, comp_name)
    if not comps then return end

    for _, comp in ipairs(comps) do
      EntityRemoveComponent(entity, comp)
    end
  end
end


function get_target(portal_type)
  if portal_type == "portal_blue" then
    return EntityGetWithName("portal_orange")
  end
  return EntityGetWithName("portal_blue")
end


function remove_portal_siblings(portal_type, current)
  local clones = EntityGetWithTag(portal_type)

  for _, sibling in ipairs(clones) do
    if sibling ~= current then
      local x, y = EntityGetTransform(sibling)
      GamePlaySound(
        "mods/portalgun/files/audio/Desktop/portal.snd",
        "misc/portal_orange_close/create",
        x, y
      )
      EntityKill(sibling)
    end
  end
end


function get_scaled_power(magnitude)
  if magnitude < 5 then return 20
  elseif magnitude < 10 then return 10
  elseif magnitude < 20 then return 5
  elseif magnitude < 40 then return 3
  elseif magnitude < 120 then return 1.5
  else return 1 end
end


function vec_to_rad(x, y)
  return math.atan2(y, x)
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
