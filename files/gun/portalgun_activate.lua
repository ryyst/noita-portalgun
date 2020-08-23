function enabled_changed(entity, is_enabled)
  --When the player switches to the portalgun, play the activation sound
  if is_enabled then
    local x, y = EntityGetTransform(entity)
    GamePlaySound(
      "mods/portalgun/files/audio/Desktop/portal.snd",
      "event_cues/pick_item_portalgun/create",
      x, y
    )
  end
end
