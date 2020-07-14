-- Clears all wind loop components from any entities that may have it.
function clear_wind_loop(entities)
	if (table.maxn(entities) == 0) then
		return
	end
	for i,entity_id in ipairs(entities) do
		if (entity_id ~= nil or 0) then
			local audioloop_components = EntityGetComponent(entity_id, "AudioLoopComponent")
			local has_windloop = false
			if audioloop_components ~= nil then
				for i,audioloop_component in ipairs(audioloop_components)
				do
					repeat
						if (string.match(ComponentGetValue(audioloop_component, "event_name"), "wind_movement/loop") == nil) then
							has_windloop = false
							do break end
						else
							has_windloop = true
							local vel_x, vel_y = GameGetVelocityCompVelocity(entity_id)
							if ((vel_x < 0.1 and vel_y < 0.1) or (vel_x < .9 and vel_y < 0.1)) then
								EntityRemoveComponent(entity_id, audioloop_component)
								EntityRemoveTag(entity_id, "wind_affected")
							end
						end
						if (i == table.maxn(audioloop_components) and not has_windloop) then
							EntityRemoveTag(entity_id, "wind_affected")
							break
						end
					until true
				end
			end
		end
	end
end

clear_wind_loop(EntityGetWithTag("wind_affected"))