print('(Extract O-Snap) Loaded')
--- FREE SCRIPT | https://github.com/nperma

onPlayerConsumableCallback(function(world, player, tile, clickedPlayer, itemID)
  if itemID == 6140 then
    local dialog = {
      'set_default_color|`o',
      'add_label_with_icon|big|' .. getItem(itemID):getName() .. '|left|6140|\n',
      'add_custom_margin|x:0;y:10|'
    }

    local drops = world:getDroppedItems()
    if drops then
      for i = 1, #drops do
        local drop = drops[i]
        local uid = drop:getUID()
        local item, px, py = getItem(drop:getItemID()), drop:getPosX(), drop:getPosY()
        local itemName, itemID = item:getName(), item:getID()
        dialog[#dialog + 1] = ('add_label_with_icon_button|medium|' .. itemName .. ' ' .. drop:getItemCount() .. 'x|left|' .. itemID .. '|' .. i .. '-' .. uid .. '|\nadd_custom_margin|x:0;y:2|')
      end
    else
      dialog[#dialog + 1] = 'add_textbox|Dropped items not found|'
    end

    dialog[#dialog + 1] = 'add_custom_margin|x:0;y:10|'
    dialog[#dialog + 1] = 'add_smalltext|`3INFO:`o Click on the Icon item to hook the item|'

    dialog[#dialog + 1] = 'add_quick_exit|\nend_dialog|o_snap_ui||close|'
    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, player, data)
      local button = data['buttonClicked']
      if button and button:match('^(%d+)%-(%d+)$') then
        local index, uid = button:match('^(%d+)%-(%d+)$')
        index, uid = tonumber(index), tonumber(uid)
        local drops = world:getDroppedItems()
        if drops and drops[index] and drops[index]:getUID() == uid then
          local item = getItem(drops[index]:getItemID())
          local drop = drops[index]
          local px, py = drop:getPosX(), drop:getPosY()
          local pPos, tPos = world:getTile(math.floor(player:getPosX() / 32), math.floor(player:getPosY() / 32)),
              world:getTile(math.floor(px / 32), math.floor(py / 32))
          local foundPath = world:findPathByTile( --- @diagnostic disable-line
            pPos,
            tPos,                                 --- @diagnostic disable-line
            world:getWorldSizeX(),
            world:getWorldSizeY())
          if #foundPath ~= 0 then
            local npc = world:createNPC('``', px, py)
            world:setClothing(npc, 1904)
            world:setClothing(npc, 3774)
            world:updateClothing(npc)
            world:useItemEffect(
              npc:getNetID(),
              item:getID(),
              player:getNetID(),
              0
            )
            world:removeDroppedItem(uid) --- @diagnostic disable-line
            world:removeNPC(npc)
            if not player:changeItem(itemID, drop:getItemCount(), 0) then
              player:changeItem(itemID, drop:getItemCount(),
                1)
            end
            player:changeItem(6140, -1, 0)
            player:onTalkBubble(player:getNetID(), 'picked up ' .. item:getName() .. ' ' .. drop:getItemCount() .. 'x', 0)
          else
            player:onTalkBubble(player:getNetID(), '`4item cannot be picked up', 0)
          end
        else
          player:onConsoleMessage('`4>> Item not found!!')
        end
      end
    end)
    return true
  end
end)
