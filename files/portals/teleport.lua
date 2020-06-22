
function get_target(portal_type)
  if portal_type == "portal_blue" then
    return EntityGetWithName("portal_orange")
  end
  return EntityGetWithName("portal_blue")
end


function teleport(colliding_entity_id)
  local portal = GetUpdatedEntityID()
  local portal_type = EntityGetName(portal)
  local target = get_target(portal_type)

  local x, y = EntityGetTransform(target)
  EntitySetTransform(colliding_entity_id, x, y)
  GlobalsSetValue("PG_LAST_TELEPORT", GameGetFrameNum())
end


function collision_trigger( colliding_entity_id )
  local last_teleport = tonumber(GlobalsGetValue("PG_LAST_TELEPORT", "-999"))
  if GameGetFrameNum() - last_teleport > 20 then
    teleport(colliding_entity_id)
  end

end
