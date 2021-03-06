ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/portalgun/files/actions.lua")
ModLuaFileAppend("data/scripts/biomes/mountain/mountain_hall.lua", "mods/portalgun/files/companion/spawn.lua")
ModRegisterAudioEventMappings("mods/portalgun/files/audio_events.txt")


function give_player_items(inventory, items)
  for _, path in ipairs(items) do
    local item = EntityLoad(path)
    if item then
      EntityAddChild(inventory, item)
    else
      GamePrint("Couldn't load the item ["..path.."], something's terribly wrong!")
    end
  end
end


function OnPlayerSpawned(player)
  -- Load portalgun only for first spawn
  local LOAD_KEY = "PORTALGUN_FIRST_LOAD_DONE"
  if GlobalsGetValue(LOAD_KEY, "0") == "1" then return end
  GlobalsSetValue(LOAD_KEY, "1")
  ---

  local inv_quick = EntityGetWithName("inventory_quick")
  local items_quick = {
    "mods/portalgun/files/gun/entity.xml",
  }

  give_player_items(inv_quick, items_quick)
end
