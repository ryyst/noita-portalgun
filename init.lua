ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/portalgun/files/actions.lua")
ModRegisterAudioEventMappings("mods/portalgun/files/audio_events.txt") -- Use this to register custom fmod events. Event mapping files can be generated via File -> Export GUIDs in FMOD Studio.

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


function OnPlayerSpawned( player_entity )
  local inv_quick = EntityGetWithName("inventory_quick")
  local items_quick = {
    "mods/portalgun/files/gun/entity.xml",
  }

  give_player_items(inv_quick, items_quick)
  
  EntityAddComponent(player_entity, "LuaComponent",
  {
	script_source_file="mods/portalgun/files/gun/portalgun_activate.lua",
	execute_every_n_frame="5"
  })
end
