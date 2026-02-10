print('(example-telephone-modify) for GTPS Cloud | by Nperma')

local DialogWrapper = require('dialog-wrapper') --- require dialog-wrapper module

local MAX_ITEMS_PER_PAGE = 10

local nPlayers = getAllPlayers()
local players = {}

local function createPlayerListDialog(player, page)
  page = page or 1
  for i = 1, #nPlayers do
    local ply = nPlayers[i]
    if ply and ply.getEmail and ply:getEmail() ~= '' then players[#players + 1] = ply end
  end
  local totalPlayers = #players
  local totalPages = math.max(1, math.ceil(totalPlayers / MAX_ITEMS_PER_PAGE))

  --- @diagnostic disable
  if page < 1 then page = 1 end
  if page > totalPages then page = totalPages end

  local startIndex = (page - 1) * MAX_ITEMS_PER_PAGE + 1
  local endIndex = math.min(startIndex + MAX_ITEMS_PER_PAGE - 1, totalPlayers)

  local embeds = {
    string.format('add_label|small|Select Player to see the Balance (Page %d/%d)|center|', page, totalPages),
    'add_spacer|small|'
  }

  for i = startIndex, endIndex do
    local ply = players[i]
    embeds[#embeds + 1] = ('add_button|player_' .. i .. '|' .. ply:getCleanName() .. ' View|noflags|0|0|\n')
  end

  embeds[#embeds + 1] = 'add_custom_margin|x:0;y:20|'

  if page > 1 then
    embeds[#embeds + 1] = {
      element = 'add_custom_button',
      name = 'prev_' .. (page - 1),
      args = {
        textLabel = 'Previous',
        middle_colour = 3135242239,
        border_colour = 3135242239
      }
    }
  end

  if page < totalPages then
    embeds[#embeds + 1] = {
      element = 'add_custom_button',
      name = 'next_' .. (page + 1),
      args = {
        textLabel = 'Next',
        middle_colour = 3135242239,
        border_colour = 3135242239,
        anchor = 'prev_' .. (page - 1),
        left = 1.05
      }
    }
  end

  DialogWrapper:create('mbank_select_vbalance', {
    title = { align = 'center', label = 'Player List' },
    disableResize = true,
    addExitButton = true,
    fields = embeds
  }, function(world, player, data)
    local button = data['buttonClicked']
    local playerIndex = button:match('player_(%d+)')

    local prevPage = button:match('prev_(%d+)')
    local nextPage = button:match('next_(%d+)')
    if prevPage then
      createPlayerListDialog(player, tonumber(prevPage))
    elseif nextPage then
      createPlayerListDialog(player, tonumber(nextPage))
    elseif playerIndex then
      local target = players[tonumber(playerIndex)]
      if target then
        (function()
          local targetOnline = target:isOnline()
          local color_bbt = targetOnline and '130154495' or '1616929023'
          local dialog = DialogWrapper:create('mbank_show_target_balance', {
            title = (target:getName() .. ' Balance'),
            addExitButton = true,
            fields = {
              'add_spacer|small|',
              'add_label_with_icon|small|' .. target:getBankBalance() .. ' wls|left|242|',
              'add_custom_margin|x:0;y:5|',
              ('add_custom_button|send_balance|state:' .. (targetOnline and 'enabled' or 'disabled') .. ';middle_colour:' .. color_bbt .. ';border_colour:' .. color_bbt .. ';textLabel:Send Balance;|'),
              'add_custom_button|back|textLabel:Back;anchor:send_balance;left:1.05;|'
            }
          }, (function(w, p, d)
            if d['buttonClicked'] == 'send_balance' then
              (function()
                DialogWrapper:create('mbank_send_balance_amount', {
                  title = "Send Balance to " .. target:getCleanName(),
                  addExitButton = true,
                  fields = {
                    'add_label|small|Enter amount to send|left|',
                    'add_spacer|small|',
                    'add_text_input|amount|amount||5|',
                    'add_spacer|small|',
                    'add_button|confirm_send|Send|'
                  }
                }, function(world, player, data)
                  if data['buttonClicked'] == 'confirm_send' then
                    local amount = tonumber(data['amount'])

                    if not amount or amount <= 0 then
                      player:onConsoleMessage("`4Invalid amount")
                      return true
                    end

                    if player:getName() == target:getName() then
                      player:onConsoleMessage("`4You cannot send balance to yourself")
                      return true
                    end


                    if not target or not target.getBankBalance then
                      player:onConsoleMessage("`4Target player no longer exists")
                      return true
                    end

                    local senderBalance = player:getBankBalance()

                    if senderBalance < amount then
                      player:onConsoleMessage("`4Insufficient balance")
                      return true
                    end
                    if targetOnline then
                      target:setBankBalance(target:getBankBalance() + amount)
                      player:setBankBalance(senderBalance - amount)
                      player:onConsoleMessage("`2Balance sent successfully!")
                      target:onConsoleMessage("`2You received balance from " .. player:getCleanName())
                    else
                      player:console('Target is Offline')
                    end



                    return true
                  end
                end):show(player)
              end)()
            elseif d['buttonClicked'] == 'back' then
              createPlayerListDialog(p, page)
              return true
            end
          end)):show(player)
        end)()
      end
    end
    return true
  end):show(player)
end

local function openBankPhone(world, player)
  DialogWrapper:create('vbank_mobb', {
    title = { label = 'Mobile Transfer', icon = 2208 },
    color = '`o',
    addExitButton = true,
    fields = {

      'add_smalltext| Send and receive balance directly between players.|',
      'add_custom_button|dummy_icon|icon:242;state:disabled;|',
      'add_custom_button|dummy_stack|textLabel:`oBalance;state:disabled;middle_colour:0;border_colour:0;|',
      'add_custom_label|`6' .. player:getBankBalance() .. '|target:dummy_stack;alignment:4;top:2;size:medium;left:0.01;|',
      'add_custom_break|',
      'reset_placement_x|',
      'add_custom_margin|x:0;y:-15|',
      'add_smalltext|`3TIP:`o Check your current balance before making any transaction.|',
      'add_custom_margin|x:0;y:5|',

      {
        element = 'add_custom_button',
        name = 'view_balance',
        args = {
          textLabel = 'Check Balance',
          middle_colour = 4086702591,
          border_colour = 4086702591,
        }
      },

      'add_custom_break|',
      'add_spacer|small|',
      'add_smalltext|`2INFO:`o Transfers and requests are processed instantly and cannot be undone.|',
      'add_custom_margin|x:0;y:5|',


      {
        element = 'add_custom_button',
        name = 'deposit',
        args = {
          textLabel = 'Deposit',
          border_colour = 1353665791,
          middle_colour = 1353665791
        }
      },

      {
        element = 'add_custom_button',
        name = 'withdraw',
        args = {
          anchor = 'send_balance',
          left = 1.05,
          middle_colour = 130154495,
          border_colour = 130154495,
          textLabel = 'Withdraw'
        }
      }

    },
  }, function(w, p, l)
    local button = l['buttonClicked']

    if button == 'view_balance' then
      createPlayerListDialog(p, 1)
      return true
    elseif button == 'withdraw' or button == 'deposit' then
      player:sendVariant({ "OnDialogRequestRML", "show_world_lock_storage" })
      return true
    end
  end):show(player)
end

onPlayerDialogCallback(function(world, player, data)
  if data['dialog_name'] == 'phonecall' then
    if data['dial'] and tonumber(data['dial']) == 67675 then
      openBankPhone(world, player)
      return true
    end
  end
end)
