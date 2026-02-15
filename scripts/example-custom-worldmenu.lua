print('(example-custom-worldmenu) for GTPS Cloud | by Nperma')

local random = math.random
local lower = string.lower

math.randomseed(os.time())

local function getPlayerCount(id)
  local w = id and getWorld(id)
  return w and w:getVisiblePlayersCount() or 0
end

local function getOwnedSortedWorlds(player)
  local owned = player:getOwnedWorlds() or {}
  local smallLocks = player:getSmallLockedWorlds() or {}

  local lockMap = {}
  for i = 1, #smallLocks do
    lockMap[smallLocks[i]] = true
  end

  local result = {}

  for i = 1, #owned do
    local wid = owned[i]
    if not lockMap[wid] then
      result[#result + 1] = wid
    end
  end

  table.sort(result, function(a, b)
    local wa, wb = getWorld(a), getWorld(b)
    if wa and wb then
      return lower(wa:getName()) < lower(wb:getName())
    end
    return a < b
  end)

  return result
end

onWorldMenuRequest(function(player)
  local activeBuf = {}
  local recentBuf = {}
  local ownedBuf = {}

  local showRecently = random(0, 1) == 1
  local showMyWorlds = not showRecently

  local activeWorlds = getActiveWorlds()

  for i = 1, #activeWorlds do
    if i > 10 then break end

    local world = activeWorlds[i]
    local name = world:getName()

    if not name:match('_') then
      local color =
          random(0, 255) * 16777216 +
          random(0, 255) * 65536 +
          random(0, 255) * 256 +
          255

      activeBuf[#activeBuf + 1] =
          'add_floater|' ..
          name .. '|' ..
          name .. '|' ..
          world:getVisiblePlayersCount() ..
          '|0.5|' .. color
    end
  end

  if showRecently then
    local recent = player:getRecentWorlds()

    for i = 1, #recent do
      if i > 10 then break end

      local world = getWorld(recent[i])
      if world then
        local name = world:getName()

        recentBuf[#recentBuf + 1] =
            'add_floater|' ..
            name .. '|' ..
            name .. '|' ..
            world:getVisiblePlayersCount() ..
            '|0.5|2442236415'
      end
    end
  end

  if showMyWorlds then
    local owned = getOwnedSortedWorlds(player)

    for i = 1, #owned do
      if i > 10 then break end

      local world = getWorld(owned[i])
      if world then
        local name = world:getName()

        ownedBuf[#ownedBuf + 1] =
            'add_floater|' ..
            name .. '|' ..
            name .. '|' ..
            world:getVisiblePlayersCount() ..
            '|0.5|1140796415'
      end
    end
  end

  local menu = {
    'add_heading|Main World<ROW2>',
    'add_floater|NPERMA|ę START|' .. getPlayerCount(313) .. '|0.75|1353665791',
    'add_floater|REC|ā FEATURE|0|0.75|130154495',
    'add_heading|`t',
    'add_heading|World List<CR>',
    table.concat(activeBuf, '\n')
  }

  if showMyWorlds then
    menu[#menu + 1] = 'add_heading|My World<CR>'
    menu[#menu + 1] = table.concat(ownedBuf, '\n')
  end

  if showRecently then
    menu[#menu + 1] = 'add_heading|Recently World<CR>'
    menu[#menu + 1] = table.concat(recentBuf, '\n')
  end

  player:sendVariant({
    'OnRequestWorldSelectMenu',
    table.concat(menu, '\n') .. '\n'
  })

  return true
end)
