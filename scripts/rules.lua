-- === World Rules & Welcome Script ===
print("(Loading) World Rules & Welcome Script v1.1 (Updated Colors)")

local RULES_DIALOG_NAME = "rules" -- Unique name for the dialog

-- === The Rules Text (Formatted for Dialog with New Colors) ===
local rulesDialogString = [[
set_default_color|`w
set_title|`9World & Server Rules
set_bg_color|0,0,0,150|
add_label|big|`5Welcome to GrowP! Please Read the rules:``|left|
add_spacer|small|
add_textbox|`2Please follow these rules while playing GrowP to ensure a fair and enjoyable experience for all. Breaking any of these may result in warnings, mutes, suspensions, or permanent bans.``|left|
add_spacer|small|
add_textbox|`4--- No Scamming ---``|left|
add_textbox|`wScamming in any form is strictly forbidden. This includes fake trades, donation boxes, drop games, or misleading messages.``|left|
add_spacer|small|
add_textbox|`4--- No Hacking, Glitching, or Duping ---``|left|
add_textbox|`wExploiting bugs, using illegal tools, or duplicating items will result in a permanent ban.``|left|
add_spacer|small|
add_textbox|`4--- Respect All Players ---``|left|
add_textbox|`wHarassment, threats, racism, hate speech, and toxicity are not tolerated — in-game or in chat.``|left|
add_spacer|small|
add_textbox|`4--- No Advertising ---``|left|
add_textbox|`wDo not advertise other Discord servers, Growtopia worlds, or external platforms without staff permission.``|left|
add_spacer|small|
add_textbox|`4--- No Inappropriate Content ---``|left|
add_textbox|`wInappropriate world names, signs, outfits, or messages will be removed and punished.``|left|
add_spacer|small|
add_textbox|`4--- No Impersonation ---``|left|
add_textbox|`wDo not pretend to be staff or other players. All real staff will have verified roles or tags.``|left|
add_spacer|small|
add_textbox|`4--- English in Public Chats ---``|left|
add_textbox|`wPlease use English in public chats to keep communication clear. Other languages are welcome in private or specified areas.``|left|
add_spacer|small|
add_textbox|`4--- Respect World Owners’ Rules ---``|left|
add_textbox|`wEach world may have its own additional rules — respect them or risk being banned from the world.``|left|
add_spacer|small|
add_textbox|`4--- Use Common Sense ---``|left|
add_textbox|`wIf it seems wrong, it probably is. When in doubt, ask a staff member.``|left|
add_spacer|big|
add_textbox|`eReminder:``|left|
add_textbox|`wViolating these rules may also affect your access to the Discord server. Be respectful, play fair, and help keep Growtopia fun for everyone!``|left|
add_spacer|small|
end_dialog|]] .. RULES_DIALOG_NAME .. [[|Okay||
]]

onPlayerDialogCallback(function(world, player, data)
  if data["dialog_name"] == "news" and data["buttonClicked"] == "aturan" then
    player:onDialogRequest(rulesDialogString)
    return true
  end
  return false
end)

onPlayerCommandCallback(function(world, player, fullCommand)
  local cmd, arg = fullCommand:match("^(%S+)%s*(.*)$")

  if cmd and cmd:lower() == "rules" or cmd:lower() == "aturan" then
    player:onDialogRequest(rulesDialogString)
  end
end)
