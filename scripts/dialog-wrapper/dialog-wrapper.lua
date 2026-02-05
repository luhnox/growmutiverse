-- class by @Nperma | github: @nperma

-- Fluent dialog builder with inline callback support
-- Compatible with openDialog(dialogString, callback)


--- require player wrapper
local CPlayer = require("player-wrapper")

---@class DialogWrapper
---@field name string               @ Dialog identifier
---@field dialog string             @ Built dialog string
---@field callback fun(world: World, player: PlayerWrapper, data: table)|nil
local DialogWrapper = {}
DialogWrapper.__index = DialogWrapper

---@class DialogTitleTable
---@field label string
---@field align? '"left"'|'"center"'|'"right"'
---@field icon? number

---@class DialogFieldTable
---@field element string
---@field name? string
---@field args? table<number|string, any>

---@class DialogStructure
---@field title string|DialogTitleTable
---@field color? string
---@field disableResize? boolean
---@field addExitButton? boolean
---@field fields? (string|DialogFieldTable)[]

---@param title string|DialogTitleTable
---@return string
local function buildTitle(title)
  if type(title) == "string" then
    return "add_label|big|" .. title .. "|left|\n"
  elseif type(title) == "table" then
    local label = title.label or ""
    local align = title.align or "left"
    local icon  = title.icon

    if icon then
      return "add_label_with_icon|big|" .. label .. "|" .. align .. "|" .. icon .. "|\n"
    end

    return "add_label|big|" .. label .. "|" .. align .. "|\n"
  end

  return ""
end

---@param field string|DialogFieldTable
---@return string
local function buildField(field)
  if type(field) == "string" then
    return field .. "\n"
  end

  if type(field) == "table" and field.element then
    local line = field.element

    if field.name then
      line = line .. "|" .. field.name
    end

    if field.args then
      local argStr = ""
      for k, v in pairs(field.args) do
        if type(k) == "number" then
          argStr = argStr .. "|" .. tostring(v)
        else
          argStr = argStr .. k .. ":" .. tostring(v) .. ";"
        end
      end
      line = line .. "|" .. argStr
    end

    return line .. "|\n"
  end

  return ""
end

---Create a dialog instance (chainable)
---@param dialog_name string
---@param structure DialogStructure
---@param callback? fun(world: World, player: PlayerWrapper, data: table)
---@param template? '"simple"'
---@return DialogWrapper
function DialogWrapper:create(dialog_name, structure, callback, template)
  template = template or "simple"

  ---@type DialogWrapper
  local self = setmetatable({}, DialogWrapper)
  self.name = dialog_name
  self.callback = callback

  local dialog = ""
  local color = structure.color and ('set_default_color|' .. structure.color .. '\n') or ""
  local disableResize = structure.disableResize and "disable_resize|\n" or ""
  local exitBtn = structure.addExitButton ~= false and "add_quick_exit|\n" or ""

  if template == "simple" then
    dialog = dialog
        .. color
        .. disableResize
        .. buildTitle(structure.title)

    if structure.fields then
      for _, field in ipairs(structure.fields) do
        dialog = dialog .. buildField(field)
      end
    end

    dialog = dialog
        .. exitBtn
        .. "end_dialog|" .. dialog_name .. "||"
  end

  self.dialog = dialog
  return self
end

---Show dialog to player
---@param player Player
function DialogWrapper:show(player)
  CPlayer.register(player):openDialog(
    self.dialog,
    ---Dialog return callback
    ---@param world World
    ---@param p Player
    ---@param data table
    function(world, p, data)
      if self.callback and data['dialog_name'] == self.name then
        return self.callback(
          world,
          CPlayer.register(p),
          data
        )
      end
    end
  )
end

return DialogWrapper
