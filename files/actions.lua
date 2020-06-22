dofile_once("data/scripts/lib/utilities.lua")

MOD_PATH = "mods/portalgun/files/"

-- TODO: get rid of this and add it manually
table.insert( actions,
{
  id                = "PORTAL",
  name              = "Blue Portal",
  description       = "Enables higher cognitive functions involving portals",
  sprite            = MOD_PATH .. "projectile/magazine.png",
  type              = ACTION_TYPE_PROJECTILE,
  spawn_level       = "0,4,5,6",
  spawn_probability = "1,1,1,1",
  price             = 600,
  mana              = 0,
  max_uses          = -1,
  action = function()
    add_projectile(MOD_PATH .. "projectile/blue.xml")
    c.damage_critical_chance = 0
  end,
})
