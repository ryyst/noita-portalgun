dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")

-- Entity types enum
PHYSICS = 1
ANIMAL = 2
PROJECTILE = 3


-- Applies a wind effect and plays a little tune which changes depending on the speed of the entity.
function apply_wind_looop(entity_id)
  if (string.match(EntityGetTags(entity_id), "wand") ~= nil) then
    return
  end

  local audioloop_components = EntityGetComponent(entity_id, "AudioLoopComponent", "wind_effect")
  if (audioloop_components ~= nil and table.maxn(audioloop_components) > 0) then
    if (not EntityHasTag(entity_id, "wind_affected")) then
      EntityAddTag(entity_id, "wind_affected")
    end
  else
    local new_audio_comp = EntityAddComponent(entity_id, "AudioLoopComponent", {
      _tags="wind_effect",
      file="mods/portalgun/files/audio/Desktop/portal.snd",
      event_name="misc/wind_movement/loop",
      set_speed_parameter="1",
      auto_play_if_enabled="1"
    })

    if (not EntityHasTag(entity_id, "wind_affected")) then
      EntityAddTag(entity_id, "wind_affected")
    end
  end
end


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
    return
  end

  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)

  -- Turn the projectile to face the portal exit angle, persisting the input velocity
  local shoot_angle = vec_to_rad(vel_x, vel_y)
  local angle = exit_angle - shoot_angle
  local vx, vy = vec_rotate(vel_x, vel_y, angle)
  ComponentSetValue2(velComponent, "mVelocity", vx, vy)

  -- Allow entities to kill themselves with their own projectiles.
  -- NOTE: This also applies to the player. We could easily filter it out,
  -- but I think this might be more "fun".
  local projComponent = EntityGetFirstComponentIncludingDisabled(entity, "ProjectileComponent")
  ComponentSetValue2(projComponent, "friendly_fire", true)
  ComponentSetValue2(projComponent, "collide_with_shooter_frames", 1)
end


function _teleport_animal(entity, to_portal)
  local x, y, exit_angle = get_portal_transform(to_portal)

  local from_x, from_y = get_portal_transform(GetUpdatedEntityID())

  -- Play enter portal sound effect
  if (EntityGetName(GetUpdatedEntityID()) == "portal_blue") then
    GamePlaySound("mods/portalgun/files/audio/Desktop/portal.snd", "misc/portal_blue_enter/create", from_x, from_y)
  elseif (EntityGetName(GetUpdatedEntityID()) == "portal_orange") then
    GamePlaySound("mods/portalgun/files/audio/Desktop/portal.snd", "misc/portal_orange_enter/create", from_x, from_y)
  end

  -- Set teleport position infront of the portal
  -- TODO: Try out the GetGoodPlaceForBody() tms.
  local distance = 7
  local to_x = x + math.cos( exit_angle ) * distance
  local to_y = y + math.sin( exit_angle ) * distance

  EntitySetTransform(entity, to_x, to_y)

  local dataComponent = EntityGetFirstComponentIncludingDisabled(entity, "CharacterDataComponent")
  if not dataComponent then
    return
  end

  -- Turn the entering entity to face the portal exit angle, persisting the input velocity
  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)
  local entry_angle = vec_to_rad(vel_x, vel_y)
  local turn_angle = exit_angle - entry_angle
  local vel_x_exit, vel_y_exit = vec_rotate(vel_x, vel_y, turn_angle)

  -- Give a little push coming out of the portal
  local power = 80

  ComponentSetValue2(dataComponent, "mVelocity", vel_x_exit*power, vel_y_exit*power)

  -- Play exit portal sound effect
  if (EntityGetName(to_portal) == "portal_blue") then
    GamePlaySound("mods/portalgun/files/audio/Desktop/portal.snd", "misc/portal_blue_exit/create", to_x, to_y)
  elseif (EntityGetName(to_portal) == "portal_orange") then
    GamePlaySound("mods/portalgun/files/audio/Desktop/portal.snd", "misc/portal_orange_exit/create", to_x, to_y)
  end

  apply_wind_looop(entity)
end


function _teleport_physicsobject(entity, to_portal)
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

  local velComponent = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)

  local shoot_angle = vec_to_rad(vel_x, vel_y)
  local angle = exit_angle - shoot_angle
  local vel_x_exit, vel_y_exit = vec_rotate(vel_x, vel_y, angle)

  local magnitude = get_magnitude(vel_x_exit, vel_y_exit)
  local power = get_scaled_power(magnitude)

  -- Don't let the objects just go back-and-forth endlessly:
  -- * +1 to help when the velocities are 0.
  -- * Give them a little extra push calculated via magnitude.
  vel_x_exit = (vel_x_exit + 1) * power
  vel_y_exit = (vel_y_exit + 1) * power

  PhysicsApplyForce(entity, vel_x_exit, vel_y_exit)
end


function get_entity_type(entity, etype)
  local isPhysics = EntityHasTag(entity, "item_physics") or
    EntityHasTag(entity, "prop_physics") or
    EntityGetComponent(entity, "PhysicsBodyComponent") or
    EntityGetComponent(entity, "PhysicsBody2Component")

  local isNotInInventory = EntityGetParent(entity) == 0

  if (isPhysics and isNotInInventory) then
    return PHYSICS

  elseif EntityHasTag(entity, "projectile") then
    return PROJECTILE

  elseif EntityHasTag(entity, "mortal") then
    return ANIMAL
  end
end


function collision_trigger(entity)
  local to_portal = get_target(EntityGetName(GetUpdatedEntityID()))
  if (to_portal == nil or to_portal == 0) then
    return
  end

  local key = "PG_LAST_TELEPORT_"..entity
  local last_teleport = tonumber(GlobalsGetValue(key, "-999"))

  local etype = get_entity_type(entity)

  -- Give physics object a bit longer cooldown, to get through properly
  local cooldown = etype == PHYSICS and 10 or 5

  if (GameGetFrameNum() - last_teleport > cooldown) then
    GlobalsSetValue(key, GameGetFrameNum())

    if etype == PHYSICS then
      _teleport_physicsobject(entity, to_portal)

    elseif etype == PROJECTILE then
      _teleport_projectile(entity, to_portal)

    elseif etype == ANIMAL then
      _teleport_animal(entity, to_portal)
    end
  end
end
