function _add_text_component(entity, text)
  if not entity or entity == 0 then return end

  local textComponent = EntityGetFirstComponentIncludingDisabled(
    entity, "SpriteComponent", "speech_text"
  )
  if textComponent then
    EntityRemoveComponent(entity, textComponent)
  end


  EntityAddComponent( entity, "SpriteComponent", {
    _tags = "enabled_in_world,speech_text",
    image_file = "data/fonts/font_pixel_white.xml",
    emissive = "1",
    is_text_sprite = "1",
    offset_x = string.len(text)*1.9,
    offset_y = "26",
    alpha = "0.80",
    update_transform = "1",
    update_transform_rotation = "0",
    text = text,
    has_special_scale = "1",
    special_scale_x = "0.7",
    special_scale_y = "0.7",
    z_index = "-9000"
  })
end

function stop_speak()
  local entity = EntityGetWithName("best_friends_forever")
  local textComponent = EntityGetFirstComponentIncludingDisabled(
    entity, "SpriteComponent", "speech_text"
  )

  if textComponent then
    EntityRemoveComponent(entity, textComponent)
  end
end

function speak(entity, text)
  _add_text_component(entity, text)

  SetTimeOut(2, "mods/portalgun/files/companion/speak.lua", "stop_speak")
end

