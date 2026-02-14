print('(example-kits) for GTPS Cloud | by Nperma')
--- /kits

local database = require('db-wrapper').wrapper --- required Database Module


local Configuration = {
  xpPerBreakBlock = 20,
  xpPerPlaceBlock = 4,

  command = 'kits',

  dialog = {
    titleLabel = 'Kits Season 1',
    titleIcon = 1366,
  },

  maxLevel = 100,
  data = {
    {
      --- @property level number
      --- @property icon itemID|number
      --- @property description item description
      --- @property prizes[]
      level = 5,
      icon = 1404,
      description = 'Super Capek',
      prizes = {
        --- @key itemID number
        --- @value amount number
        [3104] = 1
      }
    }, {
    level = 10,
    icon = 406,
    description = 'Best `#Consumeable`o `oof the Time!!',
    prizes = {
      [406] = 140
    }
  }, {
    level = 15,
    icon = 20584,
    description = 'Mostly `##Farmable',
    prizes = {
      [20584] = 160
    }
  },
    {
      level = 20,
      icon = 10838,
      description = 'Fishing Pack Give some fishing starter Packs',
      prizes = {
        [3042] = 1,
        [2912] = 1,
        [3016] = 16
      }
    }, {
    level = 25,
    icon = 528,
    description = 'Buff and Multiple',
    prizes = {
      [528] = 1,
      [4604] = 2,
      [1474] = 5
    }
  }, {
    level = 35,
    icon = 20700,
    description = 'Cheat buff gained some `#Buff',
    prizes = {
      [20700] = 1,
      [20648] = 1
    }
  }, {
    level = 45,
    icon = 4992,
    description = 'Anti Gravity',
    prizes = {
      [4992] = 1
    }
  }, {
    level = 55,
    icon = 4994,
    description = 'Idk',
    prizes = {
      [4994] = 1
    }
  }
  }
}

local player_old_db, player_old_table = loadStringFromServer('nperma_player_db'), {}

local player_db = database('player_db_nperma')

if player_old_db then
  player_old_table = json.decode(player_old_db)
end

local KitByLevel = {}

for _, kit in ipairs(Configuration.data) do
  KitByLevel[kit.level] = kit
end

local function calcRequireExp(level)
  return 100 + (level * 50)
end

local function getKitData(player)
  local uid = tostring(player:getUserID())

  if not player_db.has(uid) then
    player_db.set(uid, {})
  end

  local dataPlayer = player_db.get(uid) or {}

  if player_old_table[uid] and player_old_table[uid].kits ~= nil then
    dataPlayer.kits = player_old_table[uid].kits
    player_db.set(dataPlayer)
  end

  if dataPlayer.kits == nil then
    dataPlayer.kits = {
      level = 1,
      exp = 0,
      requireExp = calcRequireExp(1),
      claimed = {},
      __temp = ''
    }

    player_db.set(uid, dataPlayer)
  else
    if dataPlayer.kits.level == nil or dataPlayer.kits.level < 1 then
      dataPlayer.kits.level = 1
      player_db.set(uid, dataPlayer)
    end

    if dataPlayer.kits.requireExp == nil then
      dataPlayer.kits.requireExp = calcRequireExp(dataPlayer.kits.level)
      player_db.set(uid, dataPlayer)
    end

    if dataPlayer.kits.claimed == nil then
      dataPlayer.kits.claimed = {}
      player_db.set(uid, dataPlayer)
    end
  end

  return dataPlayer
end

local function giveKit(player, kit)
  local text = '`2Claim Kits:\n`o'
  for itemID, amount in pairs(kit.prizes) do
    text = text .. getItem(itemID):getName() .. ' ' .. amount .. 'x\n'
    if not player:changeItem(itemID, amount, 0) then
      player:changeItem(itemID, amount, 1)
    end
  end
end

local function checkKit(player, kitData, unlockedLevel)
  local kit = KitByLevel[unlockedLevel]

  if kit ~= nil then
    if kitData.claimed[unlockedLevel] ~= true and kitData.__temp ~= unlockedLevel then
      kitData.__temp = unlockedLevel
      player:onConsoleMessage(
        '`#KIT UNLOCKED!`'
      )
    end
  end
end

local function addExp(player, amount)
  local kitData = getKitData(player)

  if kitData.level >= Configuration.maxLevel then
    return
  end

  kitData.exp = kitData.exp + amount

  local L = kitData.level
  local base = 100 + (L * 50)
  local step = 50
  local exp = kitData.exp

  local n = math.floor(
    (-(2 * base - step) + math.sqrt((2 * base - step) ^ 2 + 8 * step * exp))
    / (2 * step)
  )

  if n <= 0 then
    return
  end

  if L + n > Configuration.maxLevel then
    n = Configuration.maxLevel - L
  end

  local usedExp = n * (2 * base + (n - 1) * step) / 2

  kitData.exp = kitData.exp - usedExp
  kitData.level = L + n
  kitData.requireExp = calcRequireExp(kitData.level)

  player:onConsoleMessage('`#LEVEL UP!` Level ' .. kitData.level)

  checkKit(player, kitData, kitData.level)
end

onTileBreakCallback(function(world, player, tile)
  addExp(player, Configuration.xpPerBreakBlock)
end)

onTilePlaceCallback(function(world, player, tile)
  addExp(player, Configuration.xpPerPlaceBlock)
end)

registerLuaCommand({
  command = Configuration.command,
  description = 'kits commmand',
  roleRequired = 0
})

local function kitDialog(player)
  local kitData = getKitData(player)
  local dialog = {
    'set_default_color|`o',
    'set_bg_color|0,0,0,150|',
    ('add_custom_button|iconID|icon:' .. Configuration.dialog.titleIcon .. ';margin:0.5,0;state:disabled|'),
    ('add_progress_bar|' .. Configuration.dialog.titleLabel .. '|big||' .. kitData.exp .. '|' .. calcRequireExp(kitData.level) .. '|' .. kitData.level .. ' (' .. kitData.exp .. '/' .. calcRequireExp(kitData.level) .. ')|4294967295|'),
    'reset_placement_x|',
    'add_spacer|small|'
  }

  dialog[#dialog + 1] = 'add_label|small|Kits are `2unlocked `oby reaching the required kit levels:|left|'
  dialog[#dialog + 1] =
  'add_label|small|`4NOTE`o: You don\'t have access to claim any Kits, `9tap on a reward `oto request|left|'
  dialog[#dialog + 1] = 'add_spacer|small|'
  dialog[#dialog + 1] = 'text_scaling_string|kuontoleqwoe|'


  for i, item in ipairs(Configuration.data) do
    dialog[#dialog + 1] = ('add_button_with_icon|kit_' .. i .. '|' .. ((not kitData.claimed[item.level] and kitData.level >= item.level) and ('`2' .. math.min(kitData.level, item.level) .. '/' .. item.level) or (kitData.claimed[item.level] and kitData.level >= item.level) and '`oclaimed' or ('`4' .. math.min(kitData.level, item.level) .. '/' .. item.level)) .. '|' .. ((not kitData.claimed[item.level] and kitData.level >= item.level) and 'staticYellowFrame' or (kitData.claimed[item.level] and kitData.level >= item.level) and 'staticBlueFrame' or 'staticGreyFrame') .. (((not kitData.claimed[item.level] and kitData.level >= item.level) and ',enabled' or (kitData.claimed[item.level] and kitData.level >= item.level) and ',visibled' or ',disabled')) .. '|' .. item.icon .. '||')
  end
  dialog[#dialog + 1] = 'add_button_with_icon||END_LIST|noflags|0||'
  dialog[#dialog + 1] = 'add_spacer|small|'
  dialog[#dialog + 1] = 'add_smalltext|`4Note`o: Kit XP entirely separate from regular XP...|'
  dialog[#dialog + 1] =
  'add_smalltext|To get kit XP (not via gems like regular XP), you can do one of the following activities:|'
  dialog[#dialog + 1] = 'add_smalltext|- Breaking Blocks|'
  dialog[#dialog + 1] = 'add_smalltext|- Placing Blocks|'
  dialog[#dialog + 1] = 'end_dialog|kits|Thanks for the info||'
  player:onDialogRequest(table.concat(dialog, '\n'))
end

onPlayerCommandCallback(function(world, player, fullCommand)
  local command, args = fullCommand:match("^(%S+)%s*(.*)$")
  if command:lower() == Configuration.command then
    if args ~= '' then
      local sub, value = args:match("^(%S+)%s*(%d*)$")
      local isDev = player:hasRole(getHighestPriorityRole().roleID)
      if isDev then
        if sub == 'xp' then
          local amount = tonumber(value)

          if amount ~= nil and amount > 0 then
            addExp(player, amount)
            player:onConsoleMessage('`2Added Kit XP: `o' .. amount)
          else
            player:onConsoleMessage('Usage: /kits xp <amount>')
          end
        end
      end
      return true
    else
      kitDialog(player)
      return true
    end
  end
end)

onPlayerDialogCallback(function(world, player, data)
  if data['dialog_name'] == 'kits' then
    local button = data['buttonClicked']

    if button ~= nil then
      local idx = button:match('^kit_(%d+)$')

      if idx ~= nil then
        local index = tonumber(idx)
        local kitData = getKitData(player)
        local kit = Configuration.data[index]

        if kit ~= nil then
          if kitData.level >= kit.level then
            if kitData.claimed[kit.level] ~= true then
              giveKit(player, kit)
              kitData.claimed[kit.level] = true
            else
              player:onConsoleMessage('`4Kit already claimed')
            end
          else
            local kit_desc = {
              'set_default_color|`o',
              'set_bg_color|0,0,0,150|',
              ('add_label_with_icon|big|Kit Reward' .. index .. ' (' .. kitData.level .. '/' .. kit.level .. ')|left|' .. kit.icon '|'),
              ('add_smalltext|' .. kit.description .. '|'),
              'add_spacer|small|',
              'add_textbox|[ Rewards ]:|',
            }

            for itemID, amount in ipairs(kit.prizes) do
              kit_desc[#kit_desc + 1] = ('add_label_with_icon|small|' .. getItem(itemID):getName() .. ' ' .. amount .. 'x|left|' .. itemID .. '|')
            end

            kit_desc[#kit_desc + 1] = 'add_spacer|small|'
            kit_desc[#kit_desc + 1] =
            'add_custom_button|back|textLabel:Back;middle_colour:130154495;border_colour:130154495;|'
            kit_desc[#kit_desc + 1] =
            'add_custom_button|back|textLabel:Back;middle_colour:130154495;border_colour:130154495;|'
            kit_desc[#kit_desc + 1] = 'end_dialog|kit_desc||'

            player:onDialogRequest(table.concat(kit_desc, '\n'))
          end
        end
      end
    end

    --kitDialog(player)
    return true
  end

  if data['dialog_name'] == 'kit_desc' then
    if data['buttonClicked'] == 'back' then
      kitDialog(player)
    end
    return true
  end
end)

onAutoSaveRequest(function()
  saveStringToServer('nperma_player_db', json.encode(player_old_table))
end)
