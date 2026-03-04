-- gems-commands script
--- @author Nperma
print("(Loaded) gems-commands script for GTPS Cloud")

local DEV_ROLE_ID = getHighestPriorityRole().roleID

registerLuaCommand({
  command = 'setgems',
  description = 'GemsCommands',
  roleRequired = DEV_ROLE_ID
})

registerLuaCommand({
  command = 'addgems',
  description = 'GemsCommands',
  roleRequired = DEV_ROLE_ID
})

registerLuaCommand({
  command = 'removegems',
  description = 'GemsCommands',
  roleRequired = DEV_ROLE_ID
})

onPlayerCommandCallback(function(world, player, message)
  local command, args = message:match("^(%S+)%s*(.*)$")
  command = command:lower()

  if command and (command == 'setgems' or command == 'addgems' or command == 'removegems') and player:hasRole(DEV_ROLE_ID) then
    local arg1, arg2 = args:match("^(%S+)%s*(%S*)$")
    if not arg1 or not arg2 then
      player:onConsoleMessage("Usage: /" .. command .. " <player> <amount>")
      return true
    end

    local target = getPlayerByName('/' .. arg1)
    local amount = tonumber(arg2)

    if not target then
      player:onConsoleMessage("Player not found.")
      return true
    end

    if not amount then
      player:onConsoleMessage("Invalid amount.")
      return true
    end
    if #target ~= 0 and amount then
      if command == 'addgems' then
        target[1]:addGems(amount, 1, 1)
      elseif command == 'removegems' then
        target[1]:removeGems(
          amount, 1, 1)
      else
        target[1]:setGems(amount, 1, 1)
      end
      player:onConsoleMessage("Success update gems")
    end
    return true
  end
end)
