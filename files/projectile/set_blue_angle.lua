-- Set the rotation so we can adjust portal when it spawns
local projectile = GetUpdatedEntityID()
local x, y, rot = EntityGetTransform(projectile)
GlobalsSetValue("PG_BLUE_SHOT_ANGLE", -rot)
