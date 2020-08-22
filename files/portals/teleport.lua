dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")



-- Return with the correct alignment pre-calculated
function get_portal_transform(portal)
  local x, y, rot = EntityGetTransform(portal)
  return x, y, rot - math.pi
end


function _teleport_projectile(entity, to_portal)
  local x, y, exit_angle = get_portal_transform(to_portal)

  EntitySetTransform(entity, x, y)

  -- Projectiles
  local velComponent = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
  if not velComponent then
    GamePrint("PROJECTILE DIDN'T HAVE VELCOMPONENT, WHY?")
    return
  end

  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)
  GamePrint("velocities: " .. vel_x .. " " .. vel_y)

  -- Turn the projectile to face the portal exit angle, persisting the input velocity
  local shoot_angle = vec_to_rad(vel_x, vel_y)
  local angle = exit_angle - shoot_angle
  local vx, vy = vec_rotate(vel_x, vel_y, angle)
  ComponentSetValue2(velComponent, "mVelocity", vx, vy)
end


function _teleport_animal(entity, to_portal)
  local x, y, exit_angle = get_portal_transform(to_portal)

  -- Set teleport position infront of the portal
  -- TODO: Try out the GetGoodPlaceForBody() tms.
  local distance = 7
  local to_x = x + math.cos( exit_angle ) * distance
  local to_y = y + math.sin( exit_angle ) * distance

  EntitySetTransform(entity, to_x, to_y)

  local dataComponent = EntityGetFirstComponentIncludingDisabled(entity, "CharacterDataComponent")
  if not dataComponent then
    GamePrint("ANIMAL DIDN'T HAVE DATACOMPONENT? WHY?")
    return
  end

  -- Turn the entering entity to face the portal exit angle, persisting the input velocity
  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)
  local entry_angle = vec_to_rad(vel_x, vel_y)
  local turn_angle = exit_angle - entry_angle
  local vel_x_exit, vel_y_exit = vec_rotate(vel_x, vel_y, turn_angle)

  -- Give a little push coming out of the portal
  local power = 140

  print("animmal velocities:", vel_x_exit, vel_y_exit)
  ComponentSetValue2(dataComponent, "mVelocity", vel_x_exit*power, vel_y_exit*power)
end


function _teleport_physicsobject(entity, to_portal)
  GamePrint("OBJECT DETECTED!")
  local x, y, exit_angle = get_portal_transform(to_portal)

  -- Disable physics
  remove_joints(entity)
  physics_enabled(entity, false)

  -- Teleport infront of the portal
  local distance = 7
  local to_x = x + math.cos( exit_angle ) * distance
  local to_y = y + math.sin( exit_angle ) * distance

  EntitySetTransform(entity, to_x, to_y)

  -- Re-enable physics
  physics_enabled(entity, true)

  -- Give a little push
  local velComponent = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)

  local shoot_angle = vec_to_rad(vel_x, vel_y)
  local angle = exit_angle - shoot_angle
  local vel_x_exit, vel_y_exit = vec_rotate(vel_x, vel_y, angle)

  local power = 1.5
  PhysicsApplyForce(entity, vel_x_exit*power, vel_y_exit*power)
end


function teleport(entity)
  local to_portal = get_target(EntityGetName(GetUpdatedEntityID()))

  local isPhysics = EntityHasTag(entity, "item_physics") or
    EntityHasTag(entity, "prop_physics") or
    EntityGetComponent(entity, "PhysicsBodyComponent") or
    EntityGetComponent(entity, "PhysicsBody2Component")

  if isPhysics then
    local isNotInInventory = EntityGetParent(entity) == 0
    if isNotInInventory then
      _teleport_physicsobject(entity, to_portal)
    end
  elseif EntityHasTag(entity, "projectile") then
    _teleport_projectile(entity, to_portal)
  elseif EntityHasTag(entity, "mortal") then
    _teleport_animal(entity, to_portal)
  end
end


function collision_trigger(colliding_entity_id)
  local last_teleport = tonumber(GlobalsGetValue("PG_LAST_TELEPORT", "-999"))
  if GameGetFrameNum() - last_teleport > 5 then
    GlobalsSetValue("PG_LAST_TELEPORT", GameGetFrameNum())
    teleport(colliding_entity_id)
  end
end
