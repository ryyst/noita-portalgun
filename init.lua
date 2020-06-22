ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/portalgun/files/actions.lua")


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
    "mods/portalgun/files/portalgun/gun.xml",
  }

  give_player_items(inv_quick, items_quick)
end
