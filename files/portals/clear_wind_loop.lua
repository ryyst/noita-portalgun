-- Clears all wind loop components from any entities that may have it.
function clear_wind_loop(entities)
  if (table.maxn(entities) == 0) then
    return
  end
  for i,entity_id in ipairs(entities) do
    if (entity_id ~= nil or 0) then
      local audioloop_components = EntityGetComponent(entity_id, "AudioLoopComponent", "wind_effect")
      if (audioloop_components ~= nil and table.maxn(audioloop_components) > 0) then
        local vel_x, vel_y = GameGetVelocityCompVelocity(entity_id)
        if ((vel_x < 0.1 and vel_y < 0.1) or (vel_x < .9 and vel_y < 0.1)) then
          EntityRemoveComponent(entity_id, audioloop_components[1])
          EntityRemoveTag(entity_id, "wind_affected")
        end
      else
        EntityRemoveTag(entity_id, "wind_affected")
      end
    end
  end
end

clear_wind_loop(EntityGetWithTag("wind_affected"))
