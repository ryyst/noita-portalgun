dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")


-- TODO: Does this need to be matched as well? And to what?
-- Blue projectile is a dynamic entity, not a static value to be fetched anytime.
VELOCITY = 950

-- CLICK HANDLER
local player = get_players()[1]
local ctrlComponent = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
local holding_mouse2 = ComponentGetValue2(ctrlComponent, "mButtonDownRightClick")

-- COOLDOWN
local wand = get_held_item(player)
local abilityComp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
local reload_time = ComponentObjectGetValue2(abilityComp, "gun_config", "reload_time")


function shoot()
  local x, y = EntityGetTransform(wand)
  local mouse_x, mouse_y = DEBUG_GetMouseWorld()

  local angle = 0 - math.atan2( mouse_y - y, mouse_x - x )
  local vel_x = math.cos( angle ) * VELOCITY
  local vel_y = 0 - math.sin( angle ) * VELOCITY

  shoot_projectile(player, "mods/portalgun/files/projectile/orange.xml", x, y, vel_x, vel_y)

  -- Save the frame we shot our projectile, for manual cooldown calculation.
  GlobalsSetValue("PG_ORANGE_SHOT_FRAME", GameGetFrameNum())

  -- Save the rotation so we can adjust portal correctly when it spawns.
  GlobalsSetValue("PG_ORANGE_SHOT_ANGLE", angle)
end


if (holding_mouse2) then
  local last_shot = tonumber(GlobalsGetValue("PG_ORANGE_SHOT_FRAME", "-999"))

  if GameGetFrameNum() - last_shot > reload_time then
    shoot()

    -- Remove any existing siblings upon shooting a new portal
    remove_portal_siblings("portal_orange")
  end
end
