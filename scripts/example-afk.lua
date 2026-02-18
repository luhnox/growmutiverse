print('(example-afk) for GTPS Cloud | by Nperma')

math.randomseed(os.time())

---@class AfkRewardItem
---@field chance number
---@field amount number
---@field multiple boolean?
---@field multiple_max number?

---@class AfkRewardRange
---@field min number
---@field max number

---@class AfkRewardConfig
---@field exp AfkRewardRange
---@field gems AfkRewardRange
---@field multiple boolean
---@field items table<number, AfkRewardItem>

---@class AfkConfiguration
---@field duration number
---@field reward AfkRewardConfig

---@type AfkConfiguration
local Configuration = {
  duration = 600,

  reward = {
    exp = { min = 1, max = 10 },
    gems = { min = 3, max = 50 },

    multiple = true,

    items = {
      [242] = {
        chance = 0.01,
        amount = math.random(1, 5),
        multiple = false,
        multiple_max = 200
      },

      [7188] = {
        chance = 0.0001,
        amount = 1,
        multiple = false
      }
    }
  }
}

local afkData = {}

local function randRange(range)
  return math.random(range.min, range.max)
end

local isAfk = {}

local function resetAfk(player)
  local uid = player:getUserID()
  if isAfk[uid] ~= nil then
    player:onConsoleMessage('Player no Longer AFK')
    isAfk[uid] = nil
  end
  local name = player:getName()
  local pos = { x = player:getPosX(), y = player:getPosY() }

  afkData[name] = {
    x = pos.x,
    y = pos.y,
    lastMove = os.time()
  }
end

--- @param player Player
local function giveRewards(player)
  local reward = Configuration.reward

  local exp = randRange(reward.exp)
  local gems = randRange(reward.gems)

  if reward.multiple then
    local multi = math.random(1, 3)
    exp = exp * multi
    gems = gems * multi
  end

  player:setXP(player:getXP() + exp)
  player:addGems(gems, 1, 1) --- @diagnostic disable-line

  for itemId, data in pairs(reward.items) do
    if math.random() * 100 <= data.chance then
      local amount = data.amount or 1

      if data.multiple and data.multiple_max then
        amount = amount * math.random(1, data.multiple_max)
      end

      if not player:changeItem(itemId, amount, 0) then
        player:changeItem(itemId, amount, 1)
      end
      player:onConsoleMessage('you got ' ..
        getItem(itemId):getName() .. ' ' .. amount .. 'x with chance ' .. tostring(data.chance))
    end
  end
end

onTilePunchCallback(function(world, player, tile)
  resetAfk(player)
end)


onPlayerTick(function(player)
  if player:getWorld() == nil then return end
  local name, user = player:getName(), player:getUserID()
  local pos = { x = player:getPosX(), y = player:getPosY() }

  local data = afkData[name]
  if not data then
    resetAfk(player)
    return
  end

  if data.x ~= pos.x or data.y ~= pos.y then
    resetAfk(player)
    return
  end

  ---player:onConsoleMessage(os.time() - data.lastMove)

  if isAfk[user] ~= nil then giveRewards(player) end

  if os.time() - data.lastMove >= Configuration.duration then
    if isAfk[user] == nil then
      player:onConsoleMessage('`oYou are now AFK')
      if math.random(0, 1) == 1 then
        player:sendVariant({
          "OnAddNotification",
          "interface/atomic_button.rttex",
          "`#AFK Detected",
          "audio/hub_open.wav",
          0
        })
      else
        player:onConsoleMessage('`#** Afk Detected')
        player:playAudio('audio/msg.wav')
      end
      isAfk[user] = true
    end
    data.lastMove = os.time()
  end
end)
