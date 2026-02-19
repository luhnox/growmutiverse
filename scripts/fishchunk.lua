print("(Fish Chunk)")

local commandData = {
  command = "sellchunk",
  roleRequired = 0,
  description = "sell fish chunk"
}

local Configuration = {
  stock = 2000,
  resetEvery = 259200 --- seconds
}

local function LogMessage(p, msg, use)
  use = use or 0
  if use ~= 1 then p:onTalkBubble(p:getNetID(), msg, 1) end
  if use ~= 2 then p:onConsoleMessage(msg) end
end

local dir_path, file_name = 'currentState/npermaData/', 'fishchunk-stock.txt'
local file_path = dir_path .. file_name

if not dir.exists(dir_path) then dir.create(dir_path) end
local stock = Configuration.stock

local bonus = {
  { id = 2914,  amount = { 1, 5 }, chance = 15 },
  { id = 3014,  amount = { 1, 5 }, chance = 15 },
  { id = 3012,  amount = { 1, 5 }, chance = 10 },
  { id = 3016,  amount = { 1, 1 }, chance = 5 },
  { id = 3018,  amount = { 1, 1 }, chance = 5 },
  { id = 5528,  amount = { 1, 1 }, chance = 3 },
  { id = 3432,  amount = { 1, 1 }, chance = 0.1 },
  { id = 10262, amount = { 1, 1 }, chance = 0.01 },
  { id = 3044,  amount = { 1, 1 }, chance = 0.001 }
}

--- @param seconds number
--- @return string
local function formatTime(seconds)
  seconds = math.max(0, tonumber(seconds) or 0)
  local days = math.floor(seconds / 86400)
  local hours = math.floor((seconds % 86400) / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = math.floor(seconds % 60)

  if days > 0 then
    return tostring(days .. ' days')
  elseif hours > 0 then
    return string.format("%dh %dm", hours, minutes)
  elseif minutes >= 1 then
    return string.format("%dm %ds", minutes, secs)
  else
    return string.format('%ds', secs)
  end
end

local temp = 0
onTick(function()
  if ((os.time() % Configuration.resetEvery) == 0) and temp ~= os.time() then
    file.write(file_path,
      tostring(Configuration.stock))
  end
end)

registerLuaCommand(commandData)

onPlayerCommandCallback(function(world, player, command)
  if command:lower() == "sellchunk" then
    local itemData = getItem(3468)
    if file.exists(file_path) then stock = tonumber(file.read(file_path)) or stock end

    if stock <= 0 then
      local now = os.time()
      local nextReset = (math.floor(now / Configuration.resetEvery) + 1) * Configuration.resetEvery
      local remain = nextReset - now

      LogMessage(player, '`4>> Stock is empty, the stock will reset in ' .. formatTime(remain))
      return true
    end

    local items = math.min(player:getItemAmount(itemData:getID()), stock)

    if items == 0 then
      LogMessage(player, "You don't have any fish chunk!", 1)
      return true
    end
    stock = math.max(stock - items)
    file.write(file_path, tostring(stock, 0))


    player:changeItem(itemData:getID(), -items, 0)

    local balance_rate = math.max(math.random(items / 2, items), 1)
    player:addBankBalance(balance_rate)

    LogMessage(player, "You sold " .. items .. " chunk and received " .. balance_rate .. " balance (wl).", 0)
    for _, v in ipairs(bonus) do
      if math.random(1, 100) <= v.chance then
        local amt = math.random(v.amount[1], v.amount[2])
        player:changeItem(v.id, amt, 0)
        LogMessage(player, "you got " .. amt .. "x " .. getItem(v.id):getName(), 0)
        player:playAudio("coin_flip.wav")
      end
    end
    return true
  end
end)
