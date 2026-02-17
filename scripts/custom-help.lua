print('(custom-help) for GTPS Cloud | by Nperma')

local command = require('command-handler')
print(command:getCommands())

local RoleObject = getRoles()

local RoleIndex = {}
for i = 1, #RoleObject do
  local role = RoleObject[i]
  RoleIndex[role.roleID] = role
end

local function collectRoles(player)
  local roles = {}
  local visited = {}

  local function addRole(roleID)
    if visited[roleID] then return end
    visited[roleID] = true

    local role = RoleIndex[roleID]
    if not role then return end

    roles[#roles + 1] = role

    if role.allowCommandsFromRoles then
      for i = 1, #role.allowCommandsFromRoles do
        addRole(role.allowCommandsFromRoles[i])
      end
    end
  end

  for i = 1, #RoleObject do
    local role = RoleObject[i]
    if player:hasRole(role.roleID) then
      addRole(role.roleID)
    end
  end

  table.sort(roles, function(a, b)
    return (a.rolePriority or 0) < (b.rolePriority or 0)
  end)

  return roles
end

onPlayerCommandCallback(function(world, player, message)
  local command = message:lower():match("^(%S+)$")
  if command == 'help' then
    local roles = collectRoles(player)

    local text = {
      '`6>> Command List of `3GrowP Beta', --- Change this
    }

    local commandOwner = {}

    for i = 1, #roles do
      local role = roles[i]

      local roleName = role.roleName or 'unknown'
      local cmdList = role.allowCommands or {}

      text[#text + 1] =
          string.format('`o[ %s `o] (%d commands)', role.namePrefix .. roleName, #cmdList)

      if #cmdList > 0 then
        table.sort(cmdList)

        local lines = {}

        for c = 1, #cmdList do
          local cmd = cmdList[c]
          local owner = commandOwner[cmd]

          if owner then
            lines[#lines + 1] =
                string.format('%s `4(used %s)`o', cmd, owner)
          else
            commandOwner[cmd] = roleName
            lines[#lines + 1] =
                string.format('%s', cmd)
          end
        end

        text[#text + 1] = table.concat(lines, ', ')
      end
    end

    player:onConsoleMessage(table.concat(text, '\n'))
    return true
  end
end)
