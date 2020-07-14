dofile_once("data/scripts/lib/utilities.lua")

local player = GetUpdatedEntityID()
local player_x, player_y = EntityGetTransform(player)
local gun = EntityGetClosestWithTag(player_x, player_y, "portalgun")

local inventory = EntityGetFirstComponent(player, "Inventory2Component")
local active_wand = ComponentGetValueInt(inventory, "mActiveItem")

--When the player switches to the portalgun, play the activation sound
if (active_wand == gun and tonumber(GlobalsGetValue("PG_IS_ACTIVE", 1)) == 0) then
	local x, y = EntityGetTransform(gun)
	GamePlaySound("mods/portalgun/files/audio/Desktop/portal.snd", "event_cues/pick_item_portalgun/create", x, y)
	GlobalsSetValue("PG_IS_ACTIVE", 1)
end

if (active_wand ~= gun) then
	GlobalsSetValue("PG_IS_ACTIVE", 0)
end