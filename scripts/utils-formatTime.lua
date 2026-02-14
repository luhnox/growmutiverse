--- @param ts number
--- @param offsetHours number
local function formatTime(ts, offsetHours)
  local offset = (offsetHours or 0) * 3600
  ts = ts + offset

  local sec = ts % 60
  local min = math.floor(ts / 60) % 60
  local hour = math.floor(ts / 3600) % 24

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

  return string.format(
    "%04d-%02d-%02d %02d:%02d:%02d",
    year, month, day, hour, min, sec
  )
end


--- @example
--- print(formatTime(os.time()))
--- print(formatTime(os.time(),7)) -- wib
