print('(custom-store) for GTPS Cloud | by Nperma')

local file_path = 'config/stores/store.json'

local data = {}

if file.exists(file_path) then
  local raw = file.read(file_path)
  if raw and raw ~= '' then
    data = json.decode(raw) or {}
  end
end

local DEV_ROLE_ID = getHighestPriorityRole().roleID

registerLuaCommand({
  command = 'customstore',
  description = 'Custom Store',
  roleRequired = DEV_ROLE_ID
})

local function formatNum(num)
  local formattedNum = tostring(num)
  formattedNum = formattedNum:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  formattedNum = formattedNum:gsub("^,", "")
  return formattedNum
end

local store_data = data.Store or {}
for i = 1, #store_data do
  local item = store_data[i]
  if item and item.Category then
    data[item.Category] = data[item.Category] or {}
    data[item.Category][#data[item.Category] + 1] = item
  end
end

local function CustomStoreUI(player)
  local dialog = {
    'set_default_color|`o',
    'add_label_with_icon|big|Custom Store|left|9438|',
    'add_spacer|small|',
  }

  for category, _ in pairs(data) do
    dialog[#dialog + 1] = 'add_button|' .. category .. '|Edit ' .. category .. '|noflags|0|0|'
  end

  dialog[#dialog + 1] = 'add_quick_exit|\nend_dialog|cstore||'

  player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, player, dta)
    if dta['dialog_name'] == 'cstore' then
      local button = dta['buttonClicked']
      if data[button] then
        local dialog = {
          'set_default_color|`o',
          'add_label_with_icon|big|Custom Category: ' .. button .. '|left|9438|',
          'add_spacer|small|',
        }

        dialog[#dialog + 1] = 'add_button|back|Back|noflags|0|0|'

        for i = 1, #data[button] do
          local storeItem = data[button][i]
          dialog[#dialog + 1] = string.format(
            'add_custom_button|store_%s_%d|image:%s;frame:%s;image_size:256,160;|\nadd_custom_button|dummy|state:disabled;anchor:store_%s_%d;icon:9438;width:0.4;margin:-20,20;left:0;|',
            button,
            i,
            storeItem.Texture or '',
            storeItem.TextureXY or '',
            button,
            i
          )
        end

        dialog[#dialog + 1] = 'add_quick_exit|\nend_dialog|cstore_||'
        player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, player, dtta)
          if dtta['buttonClicked'] == 'back' then
            CustomStoreUI(player)
            return true
          elseif dtta['buttonClicked']:match('^store_(.+)_(%d+)$') then
            local cat, index = dtta['buttonClicked']:match('^store_(.+)_(%d+)$')
            player:onConsoleMessage('clicked ' .. cat .. ' ' .. index)
            return true
          end
        end)
      end
      return true
    end
  end)
end

onPlayerCommandCallback(function(world, player, message)
  local command = message:lower():match("^(%S+)")
  if command == 'customstore' and player:hasRole(DEV_ROLE_ID) then
    CustomStoreUI(player)
    return true
  end
end)
