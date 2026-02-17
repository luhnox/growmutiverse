-- Command Wrapper Module (Native Style, Clean Flow)
-- by @Nperma

local Command = {}
local CommandData = {}
local commandNames = {}

local CPlayer = require('player-wrapper')

local function tableContains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

---comment
---@param option {name: string, description?: string, aliases?: string[], roleRequired?: number, permission?: number, permissions?: number[]}
---@param callback fun(world: World, player: PlayerWrapper, data: {command: string, args: string[], message: string}): boolean
function Command.register(option, callback)
  if option == nil or option.name == nil then
    print("[Command] register failed: command is missing")
    return
  end

  if type(callback) ~= "function" then
    print("[Command] register failed: callback must be function (" .. option.name .. ")")
    return
  end

  local name = option.name:lower()

  local requiredRole =
      (option.permissions and option.permissions[1])
      or option.permission
      or option.roleRequired
      or 0

  local entry = {
    command = name,
    roleRequired = requiredRole,
    aliases = option.aliases,
    permissions = option.permissions or {},
    callback = callback
  }

  CommandData[name] = entry
  commandNames[#commandNames + 1] = name

  if option.aliases then
    for _, alias in ipairs(option.aliases) do
      if type(alias) == "string" then
        CommandData[alias:lower()] = entry
      end
    end
  end

  registerLuaCommand({
    command = name,
    description = option.description or "",
    roleRequired = requiredRole
  })
end

function Command.getCommands()
  return commandNames
end

function Command.handle(world, sender, fullCommand)
  if fullCommand ~= nil then
    local command, args = fullCommand:match("^(%S+)%s*(.*)$")

    if command ~= nil then
      command = command:lower()
      local data = CommandData[command]
      local player = CPlayer.register(sender)
      if data ~= nil then
        if data.callback ~= nil and data.roleRequired == 0 or player:hasRole(data.roleRequired) or #data.permissions > 1 and tableContains(data.permissions, player:getRole().roleID) then
          return data.callback(world, player, { command = command, args = args, message = fullCommand })
        end

        return true
      end
    end
  end
end

onPlayerCommandCallback(Command.handle)

return Command
