function physics_body_modified(is_destroyed)
  if is_destroyed then
    GamePrintImportant("You murdered your best friend?", "You are a truly horrible person")
  else
    GamePrint("Ow! Please don't hurt me!")
  end
end
