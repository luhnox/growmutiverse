print('(example-telephone-modify) for GTPS Cloud | by Nperma')

-- required use module DialogWrapper
local DialogWrapper = require('dialog-wrapper')

onPlayerDialogCallback(function(world, player, data)
  player:onConsoleMessage(json.encode(data, 4))
  if data['dialog_name'] == 'phonecall' then
    if data['num'] and tonumber(data['num']) == 6767 then
      DialogWrapper:create('bank-example-phone', {
        title = { label = 'Bank Phone', icon = 242 },
        color = '`o',
        addExitButton = true,
        fields = {
          'add_smalltext|See your balance at here|',
          'add_spacer|small|',
          {
            element = 'add_custom_button',
            name = 'dummy_wl',
            args = {
              icon = 242
            }
          },
          ('add_custom_label|Your Balance:|target:dummy_wl;left:1;top:0.5;|')
        },
      }, function(world, player, data)

      end)
      return true
    end
  end
end)
