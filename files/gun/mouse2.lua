dofile_once("data/scripts/lib/utilities.lua")

local gun = GetUpdatedEntityID()
local player = get_players()[1]
local ctrlComponent = EntityGetFirstComponentIncludingDisabled(player, "ControlsComponent")
local holding_mouse2 = ComponentGetValue2(ctrlComponent, "mButtonDownRightClick")

function shoot()
  local x, y = EntityGetTransform(gun)
  local mouse_x, mouse_y = DEBUG_GetMouseWorld()
  local vel = 650

  local angle = 0 - math.atan2( mouse_y - y, mouse_x - x )
  GlobalsSetValue("PG_ORANGE_SHOT_ANGLE", angle)  -- for later use

  local vel_x = math.cos( angle ) * vel
  local vel_y = 0 - math.sin( angle ) * vel

  shoot_projectile(player, "mods/portalgun/files/projectile/orange.xml", x, y, vel_x, vel_y)

  -- I just can't get `script_wait_frames` to work
  GlobalsSetValue("PG_ORANGE_SHOT_FRAME", GameGetFrameNum())
end

if (holding_mouse2) then
  local last_shot = tonumber(GlobalsGetValue("PG_ORANGE_SHOT_FRAME", "-999"))
  if GameGetFrameNum() - last_shot > 30 then
    shoot()
  end
end
