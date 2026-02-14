local DB = {}
local SQL = {}
local JSON = {}

local json_directory = "currentState/luaData"
local json_cache = {}

local function ensureDir()
  if dir.exists(json_directory) == false then
    dir.create(json_directory)
  end
end

local function jsonPath(id)
  return json_directory .. "/" .. id .. ".json"
end

local function loadJSON(id)
  ensureDir()

  if json_cache[id] == nil then
    if file.exists(jsonPath(id)) then
      local raw = file.read(jsonPath(id))
      local decoded = json.decode(raw)
      if type(decoded) == "table" then
        json_cache[id] = decoded
      else
        json_cache[id] = {}
      end
    else
      json_cache[id] = {}
      file.write(jsonPath(id), "{}")
    end
  end
end

local function flushJSON(id)
  local data = json_cache[id]
  file.write(jsonPath(id), json.encode(data, 2))
end

function JSON.open(identifier)
  loadJSON(identifier)

  local function set(key, value)
    json_cache[identifier][tostring(key)] = value
    flushJSON(identifier)
  end

  local function get(key)
    return json_cache[identifier][tostring(key)]
  end

  local function has(key)
    return json_cache[identifier][tostring(key)] ~= nil
  end

  local function delete(key)
    json_cache[identifier][tostring(key)] = nil
    flushJSON(identifier)
  end

  local function keys()
    return json_cache[identifier]
  end

  local function values()
    local out = {}
    for _, v in pairs(json_cache[identifier]) do
      out[#out + 1] = v
    end
    return out
  end

  local function close()
  end

  return {
    set = set,
    get = get,
    has = has,
    delete = delete,
    keys = keys,
    values = values,
    close = close
  }
end

function SQL.open(identifier)
  local raw = sqlite.open(identifier .. ".db")

  raw:query([[
        CREATE TABLE IF NOT EXISTS kv (
            key   TEXT PRIMARY KEY,
            value TEXT
        )
    ]])

  local function set(key, value)
    raw:query(
      "INSERT OR REPLACE INTO kv(key, value) VALUES (?, ?)",
      key,
      tostring(value)
    )
  end

  local function get(key)
    local rows = raw:query(
      "SELECT value FROM kv WHERE key = ? LIMIT 1",
      key
    )
    if rows ~= nil and rows[1] ~= nil then
      return rows[1].value
    end
    return nil
  end

  local function has(key)
    local rows = raw:query(
      "SELECT 1 FROM kv WHERE key = ? LIMIT 1",
      key
    )
    return rows ~= nil and rows[1] ~= nil
  end

  local function delete(key)
    raw:query("DELETE FROM kv WHERE key = ?", key)
  end

  local function keys()
    local out = {}
    local rows = raw:query("SELECT key, value FROM kv")
    if rows ~= nil then
      for _, row in ipairs(rows) do
        out[row.key] = row.value
      end
    end
    return out
  end

  local function values()
    local out = {}
    local rows = raw:query("SELECT value FROM kv")
    if rows ~= nil then
      for _, row in ipairs(rows) do
        out[#out + 1] = row.value
      end
    end
    return out
  end

  local function close()
    raw:close()
  end

  return {
    set = set,
    get = get,
    has = has,
    delete = delete,
    keys = keys,
    values = values,
    close = close
  }
end

local function Database(identifier, mode)
  local selectedMode = mode or "json"

  local backend

  if selectedMode == "sql" then
    backend = SQL.open(identifier)
  else
    backend = JSON.open(identifier)
  end

  return {
    set = backend.set,
    get = backend.get,
    has = backend.has,
    delete = backend.delete,
    keys = backend.keys,
    values = backend.values,
    close = backend.close
  }
end

DB.SQL = SQL
DB.JSON = JSON
DB.wrapper = Database

return DB
