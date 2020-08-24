dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")


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
  local power = 140

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

  -- Give a little push
  local velComponent = EntityGetFirstComponentIncludingDisabled(entity, "VelocityComponent")
  local vel_x, vel_y = GameGetVelocityCompVelocity(entity)

  local shoot_angle = vec_to_rad(vel_x, vel_y)
  local angle = exit_angle - shoot_angle
  local vel_x_exit, vel_y_exit = vec_rotate(vel_x, vel_y, angle)

  local power = 1.5
  PhysicsApplyForce(entity, vel_x_exit*power, vel_y_exit*power)
end


function teleport(entity, to_portal)
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


function collision_trigger(entity)
  local to_portal = get_target(EntityGetName(GetUpdatedEntityID()))
  if (to_portal == nil or to_portal == 0) then
    return
  end

  local key = "PG_LAST_TELEPORT_"..entity
  local last_teleport = tonumber(GlobalsGetValue(key, "-999"))

  if (GameGetFrameNum() - last_teleport > 5) then
    GlobalsSetValue(key, GameGetFrameNum())

    teleport(entity, to_portal)
  end
end
