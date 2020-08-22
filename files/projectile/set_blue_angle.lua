
--
-- Save the rotation so we can adjust portal correctly when it spawns
--
function shot(projectile)
  local gun = GetUpdatedEntityID()
  local x, y = EntityGetTransform(gun)
  local mouse_x, mouse_y = DEBUG_GetMouseWorld()

  -- Calculate the aiming angle manually, because getting projectile's
  -- rotation directly turned out highly unreliable.
  local angle = 0 - math.atan2( mouse_y - y, mouse_x - x )

  GlobalsSetValue("PG_BLUE_SHOT_ANGLE", angle)
end
