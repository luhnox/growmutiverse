-- test-lua script
print("(Loaded) time script for GTPS Cloud")

local MONTH_NAMES = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}

local function getOrdinal(n)
  local d = n % 10
  if d == 1 and n ~= 11 then return "st" end
  if d == 2 and n ~= 12 then return "nd" end
  if d == 3 and n ~= 13 then return "rd" end
  return "th"
end

local function formatTime(ts, offsetHours)
  local offset = (offsetHours or 0) * 3600
  ts = ts + offset

  local sec = ts % 60
  local min = math.floor(ts / 60) % 60
  local hour24 = math.floor(ts / 3600) % 24

  local days = math.floor(ts / 86400)

  local year = 1970
  local month = 1
  local day = 1

  local function isLeap(y)
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
  end

  local monthDays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

  while true do
    local yDays = isLeap(year) and 366 or 365
    if days < yDays then break end
    days = days - yDays
    year = year + 1
  end

  monthDays[2] = isLeap(year) and 29 or 28

  for i = 1, 12 do
    if days < monthDays[i] then
      month = i
      day = days + 1
      break
    end
    days = days - monthDays[i]
  end

  local ampm = hour24 >= 12 and "PM" or "AM"
  local hour12 = hour24 % 12
  if hour12 == 0 then hour12 = 12 end

  return {
    year = year,
    month = month,
    day = day,
    hour = hour12,
    minute = min,
    second = sec,
    ampm = ampm
  }
end


onPlayerCommandCallback(function(world, player, command)
  if command:lower() == "time" then
    local now = os.time()
    local t = formatTime(now, 7) -- WIB

    local text =
        "`2Asia/Jakarta (UTC+7) " ..
        t.day .. getOrdinal(t.day) .. ", " ..
        MONTH_NAMES[t.month] .. " " ..
        string.format("%02d:%02d %s.", t.hour, t.minute, t.ampm)

    player:onConsoleMessage(text)

    return true
  end
end)
