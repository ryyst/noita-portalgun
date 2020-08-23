dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/portalgun/files/companion/speak.lua")

local help_texts = {
  "Ow!",
  "Ouch!",
  "OUCH",
  "OW",
  "Help!",
  "Help me!",
  "HELP!",
  "Please don't hurt me!",
  "Oof!",
  "I'm under attack!",
  "Taking damage!",
  "Friend?",
}

function physics_body_modified(is_destroyed)
  if is_destroyed then
    GamePrintImportant("You murdered your best friend?", "You are a truly horrible person")
  else
    call_help()
  end
end

function call_help()
  SetRandomSeed(GameGetFrameNum(), GameGetFrameNum()+7)

  local cube = GetUpdatedEntityID()
  local roll = Random(1, #help_texts)

  speak(cube, help_texts[roll])
end
