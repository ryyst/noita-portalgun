dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/utilities.lua")

-- Match these with the values from base projectile / action
VELOCITY = 950
COOLDOWN = 30

local gun = GetUpdatedEntityID()
local player = get_players()[1]
local ctrlComponent = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
local holding_mouse2 = ComponentGetValue2(ctrlComponent, "mButtonDownRightClick")


function shoot()
  local x, y = EntityGetTransform(gun)
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
  if GameGetFrameNum() - last_shot > COOLDOWN then
    shoot()

    -- Remove any existing siblings upon shooting a new portal
    remove_portal_siblings("portal_orange")
  end
end
