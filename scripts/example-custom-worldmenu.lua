print('(example-telephone-modify) for GTPS Cloud | by Nperma')

local DialogWrapper = require('dialog-wrapper') --- require dialog-wrapper module

local MAX_ITEMS_PER_PAGE = 10

local function createPlayerListDialog(player, page)
  page = page or 1

  local players = getAllPlayers()
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

    embeds[#embeds + 1] = {
      element = 'add_custom_button',
      name = 'player_' .. i,
      args = {
        textLabel = ply:getName(),
        middle_colour = 3952825855,
        border_colour = 3952825855
      }
    }

    embeds[#embeds + 1] = 'add_custom_break|'
  end

  embeds[#embeds + 1] = 'add_custom_margin|x:0;y:8|'

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

  DialogWrapper:create('dialog_view_balance', {
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
      local selected = getAllPlayers()[tonumber(playerIndex)]
      if selected then
        player:onConsoleMessage(selected:getBankBalance())
      end
    end
    return true
  end):show(player)
end

onPlayerDialogCallback(function(world, player, data)
  if data['dialog_name'] == 'phonecall' then
    if data['dial'] and tonumber(data['dial']) == 67675 then
      DialogWrapper:create('bank-mobile-services', {
        title = { label = 'Mobile Transfer', icon = 2208 },
        color = '`o',
        addExitButton = true,
        fields = {

          'add_smalltext| Send and receive balance directly between players.|',
          'add_spacer|small|',
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
            name = 'send_balance',
            args = {
              textLabel = 'Send',
              border_colour = 1353665791,
              middle_colour = 1353665791
            }
          },

          {
            element = 'add_custom_button',
            name = 'request_balance',
            args = {
              anchor = 'send_balance',
              left = 1.05,
              middle_colour = 130154495,
              border_colour = 130154495,
              textLabel = 'Request'
            }
          }

        },
      }, (function(world, player, data)
        local button = data['buttonClicked']

        if button == 'view_balance' then
          createPlayerListDialog(player, 1)
          return true
        end
        return true
      end)):show(player)
      return true
    end
  end
end)
