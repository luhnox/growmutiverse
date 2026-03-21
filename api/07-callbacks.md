# Callbacks API

> Sumber: [Skoobz Docs](https://docs.skoobz.dev/structures/callback) + [Nperma Docs](https://docs.nperma.my.id/docs/callback-event.html)

Callbacks adalah event handlers yang trigger saat aksi game tertentu terjadi.
- `return true` = **prevent** default behavior
- `return false` = **allow** default behavior

---

## Global Tick

```lua
-- (Nperma only) Global tick setiap 100ms
onTick(function()
end)
```

---

## World & Player Tick

```lua
-- ⚠️ Dipanggil setiap 100ms PER WORLD — jaga agar ringan!
onWorldTick(function(world)
end)

-- ⚠️ Dipanggil setiap 1000ms PER PLAYER
onPlayerTick(function(player)
end)
```

---

## Login & Connection

```lua
onPlayerLoginCallback(function(player)
end)

onPlayerFirstTimeLoginCallback(function(player)
end)

onPlayerDisconnectCallback(function(player)
end)

-- (Nperma only) Saat player register akun baru
onPlayerRegisterCallback(function(world, player)
end)
```

---

## World Enter/Leave

```lua
onPlayerEnterWorldCallback(function(world, player)
end)

onPlayerLeaveWorldCallback(function(world, player)
end)

onPlayerEnterDoorCallback(function(world, player, targetWorldName, doorID)
    -- return true = prevent enter
end)

-- (Nperma only) World loaded/offloaded dari memory
onWorldLoaded(function(world)
end)

onWorldOffloaded(function(world)
end)
```

---

## Commands & Dialog

```lua
onPlayerCommandCallback(function(world, player, fullCommand)
    -- return false = disable command
end)

-- Alias: onPlayerDialogCallback / onPlayerDialogResponseCallback
onPlayerDialogCallback(function(world, player, data)
    -- data["dialog_name"] = string
    -- data["buttonClicked"] = string
    -- return true = prevent default
end)
```

---

## Tile Interactions

```lua
onTilePunchCallback(function(world, avatar, tile)
    -- return true = prevent breaking
end)

onTilePlaceCallback(function(world, player, tile, placingID)
    -- return true = prevent placement
end)

onTileWrenchCallback(function(world, player, tile)
    -- return true = prevent default wrench
end)

-- (Nperma only) Tile break event
onTileBreakCallback(function(world, player, tile)
end)

onPlayerActivateTileCallback(function(world, player, tile)
    -- Triggers: Legendary Orb, Wolf Totem, Spirit Board, dll
    -- return true = block default behavior
end)
```

---

## Player Combat & Death

```lua
onPlayerPunchPlayerCallback(function(player, world, target_player)
    -- Note: parameter order (player, world) berbeda dari biasa!
end)

-- (Nperma only) parameter order berbeda:
-- onPlayerPunchPlayerCallback(function(world, player, second_player)

onPlayerPunchNPCCallback(function(player, world, target_npc)
end)

onPlayerKillCallback(function(world, player, killedPlayer)
end)

onPlayerDeathCallback(function(world, player, isRespawn)
end)

-- Punch position (air punch detection)
onPlayerPunchCallback(function(world, player, x, y)
end)
```

---

## Items: Drop, Pickup, Equip

```lua
onPlayerDropCallback(function(world, player, itemID, itemCount)
    -- return true = prevent drop
end)

onPlayerPickupItemCallback(function(world, player, itemID, itemCount)
    -- return true = prevent pickup
end)

onPlayerEquipClothingCallback(function(world, player, itemID)
    -- return true = prevent equip
end)

onPlayerUnequipClothingCallback(function(world, player, itemID)
    -- return true = prevent unequip
end)

-- (Nperma only) AFTER equip/unequip berhasil
onPlayerEquippedClothingCallback(function(world, player, item_id)
end)

onPlayerUnequippedClothingCallback(function(world, player, item_id)
end)
```

---

## Consumable

```lua
onPlayerConsumableCallback(function(world, player, tile, clickedPlayer, itemID)
    -- clickedPlayer bisa nil
    -- return true = prevent default use
end)
```

---

## Farming & Trees

```lua
onPlayerPlantCallback(function(world, player, tile)
end)

onPlayerHarvestCallback(function(world, player, tile)
end)

onPlayerSpliceSeedCallback(function(world, player, tile, seed_id)
    -- return true = block splicing
end)
```

---

## Fishing

```lua
onPlayerCatchFishCallback(function(world, player, itemID, itemCount)
end)

onPlayerTrainFishCallback(function(world, player)
end)
```

---

## Economy & Gems

```lua
onPlayerGemsObtainedCallback(function(world, player, amount)
end)

onPlayerEarnGrowtokenCallback(function(world, player, itemCount)
end)

onPlayerXPCallback(function(world, player, amount)
end)

onPlayerLevelUPCallback(function(world, player, currentLevel)
    -- return true = block level-up
end)
```

---

## Minigames & Activities

```lua
onPlayerCrimeCallback(function(world, player, itemID, itemCount)
end)

onPlayerSurgeryCallback(function(world, player, reward_id, reward_count, target_player)
    -- target_player = nil jika Surg-E machine
end)

onPlayerGeigerCallback(function(world, player, itemID, itemCount)
end)

onPlayerCatchGhostCallback(function(world, player, itemID, itemCount)
end)

onPlayerFirePutOutCallback(function(world, player, tile)
end)

onPlayerStartopiaCallback(function(world, player, item_id, item_count)
end)

onPlayerCookingCallback(function(world, player, item_id, item_count)
end)

onPlayerDungeonEntitySlainCallback(function(world, player, entity_type)
end)

onPlayerProviderCallback(function(world, player, tile, itemID, itemCount)
end)

onPlayerHarmonicCallback(function(world, player, tile, itemID, itemCount)
end)
```

---

## Vending & Storage

```lua
onPlayerVendingBuyCallback(function(world, player, tile, item_id, item_count)
    -- return true = block purchase
end)

onPlayerDepositCallback(function(world, player, tile, itemid, itemcount)
    -- Donation box / storage box
    -- return true = block deposit
end)
```

---

## Trading & Recycling (Nperma Only)

```lua
onPlayerTradeCallback(function(world, player1, player2, items1, items2)
end)

onPlayerTrashCallback(function(world, player, item_id, item_amount)
    -- return true = prevent trashing
end)

onPlayerRecycleCallback(function(world, player, item_id, item_amount, gems_earned)
    -- return true = prevent recycling
end)

onPlayerConvertItemCallback(function(world, player, item_id)
    -- Double-tap convert (100 WL -> 1 DL)
    -- return true = prevent default
end)
```

---

## Social (Nperma Only)

```lua
onPlayerWrenchCallback(function(world, player, wrenchingPlayer)
    -- wrenchingPlayer:getType() == 25 untuk Lua NPC
end)

onPlayerAddFriendCallback(function(world, player, addedPlayer)
end)

onPlayerBoostClaimCallback(function(player)
end)

onPlayerDNACallback(function(world, player, resultID, resultAmount)
end)
```

---

## Generic Action (Nperma Only)

```lua
onPlayerActionCallback(function(world, player, data)
    -- data["action"] = action name
end)
```

---

## Low-Level Packets (Nperma Only)

```lua
onPlayerVariantCallback(function(player, variant, delay, netID)
end)

onPlayerRawPacketCallback(function(player, data)
end)
```

---

## Server Events

```lua
onAutoSaveRequest(function()
    -- Dipanggil periodik, gunakan saveDataToServer() di sini
end)

-- (Nperma only) Event changed
onEventChangedCallback(function(newEventID, oldEventID)
end)
```

---

## HTTP Request Handler

```lua
onHTTPRequest(function(req)
    -- req.method = "get" / "post"
    -- req.path = "/endpoint"
    -- req.body = string (POST body)
    -- req.headers = table
    -- HARUS return response table!
    return {
        status = 200,
        body = "OK",
        headers = { ["Content-Type"] = "text/plain" }
    }
end)
```

URL format: `https://api.gtps.cloud/g-api/{server_port}/...`

---

## Discord Callbacks

```lua
onDiscordBotReadyCallback(function()
end)

onDiscordSlashCommandCallback(function(event)
    -- event:getCommandName()
    -- event:getParameter(name)
    -- event:thinking() / event:thinking(1) untuk ephemeral
    -- event:editOriginalResponse(content, components, flags)
    -- event:getPlayer() -- jika user linked, return GTPS player
end)

onDiscordMessageCreateCallback(function(event)
    -- event:getContent()
    -- event:getChannelID()
    -- event:getAuthorID()
    -- event:getMentionedUsers()
    -- event:isBot()
    -- event:reply(content, components, flags, mention_replied_user)
end)

onDiscordButtonClickCallback(function(event)
    -- event:getCustomID()
    -- event:reply(content, components, flags)
    -- event:dialog(dialogData)
end)

onDiscordFormSubmitCallback(function(event)
    -- event:getCustomID()
    -- event:getValue(fieldID)
    -- event:reply(content, components, flags)
end)
```
