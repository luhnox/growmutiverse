-- Database Wrapper by @Nperma | github: @nperma

local DB = {}
local SQL = {}
local JSON = {}

local json_directory = "currentState/luaData"

function SQL.open(identifier)
  local raw = sqlite.open(identifier .. ".db")

  raw:query([[
        CREATE TABLE IF NOT EXISTS kv (
            key   TEXT PRIMARY KEY,
            value TEXT
        )
    ]])

  return {
    set = function(key, value)
      raw:query(
        "INSERT OR REPLACE INTO kv(key, value) VALUES (?, ?)",
        key,
        tostring(value)
      )
    end,

    get = function(key)
      local rows = raw:query(
        "SELECT value FROM kv WHERE key = ? LIMIT 1",
        key
      )
      return rows and rows[1] and rows[1].value or nil
    end,

    has = function(key)
      local rows = raw:query(
        "SELECT 1 FROM kv WHERE key = ? LIMIT 1",
        key
      )
      return rows and rows[1] ~= nil
    end,

    delete = function(key)
      raw:query("DELETE FROM kv WHERE key = ?", key)
    end,

    keys = function()
      local out = {}
      local rows = raw:query("SELECT key, value FROM kv")
      for _, row in ipairs(rows or {}) do
        out[row.key] = row.value
      end
      return out
    end,

    values = function()
      local out = {}
      local rows = raw:query("SELECT value FROM kv")
      for _, row in ipairs(rows or {}) do
        out[#out + 1] = row.value
      end
      return out
    end,

    close = function()
      raw:close()
    end
  }
end

local json_cache = {}

local function jsonPath(id)
  return json_directory .. "/" .. id .. ".json"
end

local function loadJSON(id)
  if json_cache[id] then return end

  if not dir.exists(json_directory) then
    dir.create(json_directory)
  end

  if file.exists(jsonPath(id)) then
    json_cache[id] = json.decode(file.read(jsonPath(id))) or {}
  else
    json_cache[id] = {}
    file.write(jsonPath(id), "{}")
  end
end

local function flushJSON(id)
  file.write(jsonPath(id), json.encode(json_cache[id], 2))
end

function JSON.open(identifier)
  loadJSON(identifier)

  return {
    set = function(key, value)
      json_cache[identifier][tostring(key)] = value
      flushJSON(identifier)
    end,

    get = function(key)
      return json_cache[identifier][tostring(key)]
    end,

    has = function(key)
      return json_cache[identifier][tostring(key)] ~= nil
    end,

    delete = function(key)
      json_cache[identifier][tostring(key)] = nil
      flushJSON(identifier)
    end,

    keys = function()
      return json_cache[identifier]
    end,

    values = function()
      local out = {}
      for _, v in pairs(json_cache[identifier]) do
        out[#out + 1] = v
      end
      return out
    end
  }
end

local function Database(identifier, mode)
  mode = mode or "json"

  local backend =
      (mode == "sql")
      and SQL.open(identifier)
      or JSON.open(identifier)

  return {
    set    = backend.set,
    get    = backend.get,
    has    = backend.has,
    delete = backend.delete,
    keys   = backend.keys,
    values = backend.values,
    close  = backend.close
  }
end

DB.SQL = SQL
DB.JSON = JSON
DB.wrapper = Database

return DB
