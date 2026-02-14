print('(xvent) for GTPS Cloud | by Nperma')

local data = loadDataFromServer("xvent_nperma") or {}
local data_map = {}
data_map.everyone_temp = data_map.everyone_temp or 0

local webhook_discord =
"WEBHOOK_URL"                 -- set to nil if you not need this
local offsetCoin = -10        -- make mutipleEvent x11 price changeToPwl 11pwl -> 1pwl start
local pricePerGems = 1000000  -- pricePerBoost in Gems
local changeToPWL = 9         -- change to pwl after multipleEvent x10, set to 0 if you want make currency only pwl
local durationInSecond = 3600 -- Multiple Event Duration
local reset_button_permission_role = getHighestPriorityRole().roleID

local function getTemp()
  local expire = data_map.temp or 0
  local now = os.time()
  local remain = expire - now
  if remain <= 0 then return 0 end
  return remain
end

local function setTemp()
  local now = os.time()
  if (data_map.temp or 0) > now then
    data_map.temp = data_map.temp + durationInSecond
  else
    data_map.temp = now + durationInSecond
  end
end

local function formatNum(num)
  local formattedNum = tostring(num)
  formattedNum = formattedNum:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  formattedNum = formattedNum:gsub("^,", "")
  return formattedNum
end

local function formatTime(t)
  if t <= 0 then return "Temporary Inactive" end
  local h = math.floor(t / durationInSecond)
  t = t % durationInSecond
  local m = math.floor(t / 60)
  local s = t % 60
  if h > 0 then return string.format("%d Hours %d Minutes %d Seconds Left", h, m, s) end
  if m > 0 then return string.format("%d Minutes %d Seconds Left", m, s) end
  return string.format("%d Seconds Left", s)
end

registerLuaCommand({
  command = "xvent",
  description = "See Multiple Events",
  roleRequired = 0
})

if data and (data_map.temp or 0) > os.time() and data_map.xvent ~= getGemEvent() then
  setGemEvent(data_map.xvent)
  setXPEvent(data_map.xvent)
end

onPlayerCommandCallback(function(_, user, cmd)
  if cmd:lower() == "xvent" then
    local gemEvent = (data_map and (data_map.temp or 0) > os.time()) and data_map.xvent or getGemEvent()
    local xpEvent = (data_map and (data_map.temp or 0) > os.time()) and data_map.xvent or getXPEvent()

    local currencyMode = (gemEvent > changeToPWL or xpEvent > changeToPWL) and "PWL" or "GEMS"
    local cost = currencyMode == "GEMS" and (gemEvent * pricePerGems) or (gemEvent + offsetCoin)

    local remain = getTemp()
    local tempText = formatTime(remain)

    user:onDialogRequest(
      "set_default_color|`o\n" ..
      "set_bg_color|0,0,0,150|\n" ..
      "add_label|big|Multiple Events|left|\n" ..
      "add_spacer|small|\n" ..
      string.format("add_label_with_icon|small|x%d|left|9438|\n", gemEvent) ..
      string.format("add_label_with_icon|small|x%d|left|1488|\n", xpEvent) ..
      string.format("add_smalltext|%s|\n", tempText) ..
      string.format("add_smalltext|Price: %s %s|\n", formatNum(cost), currencyMode) ..
      "add_spacer|small|\n" ..
      "add_custom_button|boost|textLabel:Boost Server;middle_colour:1353665791;border_colour:1353665791;|\n" ..
      (user:hasRole(reset_button_permission_role) and "add_custom_button|reset|textLabel:Reset;middle_colour:65535;border_colour:65535;anchor:boost;left:1.05;|\n" or "") ..
      "add_quick_exit|\n" ..
      "end_dialog|xevnt_dialog||"
    )
    return true
  end
  return false
end)

onTick(function()
  if getTemp() == 0 then
    if getGemEvent() > 1 then setGemEvent(1) end
    if getXPEvent() > 1 then setXPEvent(1) end
  end
end)

local temporary = {}

onPlayerDialogCallback(function(world, user, data)
  local dialog, click = data["dialog_name"], data["buttonClicked"]
  if dialog == "xevnt_dialog" then
    local gemEvent = (data_map and (data_map.temp or 0) > os.time()) and data_map.xvent or getGemEvent()
    local xpEvent = (data_map and (data_map.temp or 0) > os.time()) and data_map.xvent or getXPEvent()

    if click == "boost" then
      local currencyMode = (gemEvent > changeToPWL or xpEvent > changeToPWL) and "PWL" or "GEMS"

      if currencyMode == "GEMS" then
        local cost = pricePerGems * gemEvent
        if user:getGems() < cost then
          user:onTalkBubble(user:getNetID(), "`4Not enough Gems!", 0)
          return true
        end
        user:removeGems(cost, 1, 1) --- @diagnostic disable-line
      else
        local cost = gemEvent + offsetCoin
        if user:getCoins() < cost then
          user:onTalkBubble(user:getNetID(), "`4Not enough PWL!", 0)
          return true
        end
        user:removeCoins(cost, 1) --- @diagnostic disable-line
      end

      setGemEvent(gemEvent + 1)
      setXPEvent(xpEvent + 1)
      data_map.xvent = ((data_map and (data_map.temp or 0) > os.time()) and data_map.xvent or 1) + 1
      setTemp()

      local uid = user:getUserID()
      local canMention = false

      if not temporary[uid] or os.time() >= temporary[uid] then
        temporary[uid] = os.time() + 30
        canMention = true
      end
      user:onTalkBubble(user:getNetID(), "`2Boost Success!", 0)

      for _, pl in ipairs(getServerPlayers()) do
        pl:onConsoleMessage("`#** [BOOST] " .. user:getName() .. "`2 just boosted → x" .. getGemEvent())
        pl:playAudio("success.wav")
      end

      if webhook_discord then
        coroutine.wrap(function()
          local headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "Mozilla/5.0"
          }

          local playerDiscordID = user:getDiscordID()
          local mentionUser = '**' .. user:getCleanName() .. '**'

          if canMention and playerDiscordID ~= '0' then mentionUser = ("<@" .. playerDiscordID .. ">") end
          local sendEveryone = (getGemEvent() % 10 == 0)

          local jsonData = {
            content = mentionUser .. " just boosted the server! " .. (sendEveryone and "@everyone" or ""),
            embeds = { {
              title = "BOOST XVENT",
              description = "Server Just Received a Boost <a:Bot:1358132757590577194>",
              footer = { text = "play.growp.my.id" },
              color = 65280,
              fields = {
                {
                  name = "Boost",
                  value = "`x" .. getGemEvent() .. "` <a:prices:1441681247435751464>"
                }
              }
            } }
          }

          http.post(webhook_discord, headers, json.encode(jsonData))
        end)()
      end
    elseif click == "reset" then
      data_map.temp = 0
      data_map.xvent = 0
      setGemEvent(1)
      setXPEvent(1)
    end
    return true
  end
  return false
end)

onAutoSaveRequest(function()
  saveDataToServer("xvent_nperma", data)
end)

if data ~= nil then
  data_map = data
end
