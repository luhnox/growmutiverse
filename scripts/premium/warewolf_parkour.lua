print("(Loaded) Wolf Whistle script - 10 Minute Wolf Hunt")

local WOLF_WHISTLE_ID = 2992
local WOLF_WORLDS = { "WOLFWORLD_1", "WOLFWORLD_2", "WOLFWORLD_3", "WOLFWORLD_4", "WOLFWORLD_5" }
local COUNTDOWN_DURATION = 900 -- 15 minutes in seconds
local COWARDLY_WEAKNESS_MOD = -15982 -- Custom mod ID for cowardly weakness
local MOD_DURATION = 600 -- 10 minutes penalty
local WOLF_REWARD_ITEM_ID = 4354

local wolf_hunt_active = {}
local wolf_hunt_timers = {}
local wolf_claimed = {}
local wolf_end_times = {}  -- [userID] = os.time() bitis zamani

local RANDOM_REWARDS = {
    "Red Coat",
    "Wolfman Mask",
    "Fuzzy Pants",
    "Vile Vial - Lupus",
    "Wolf Totem|3",
    "Massive Fang|5",
    "Wolfy Block|5",
    "Tousled Hair",
    "Snow Goggles",
    "Hot Dog Hat",
    "Jujutsu Hair",
    "Jujutsu Shirt",
    "Jujutsu Pants",
    "Jujutsu Scarf",
    "Jujutsu Shoes",
    "Weather Machine - Black Hole",
    "Wolf Gate",
    "Dark Castle Stone|10",
    "Dark Castle Stone Background|10",
    "Dark Castle Door|5",
    "Dark Castle Turret|10",
    "Dire Wolf Mask",
    "Howling Wolf Emblem",
    "Wolf Tamer's Glove",
    "Riding War Wolf",
    "Wolf Whistle",
    "Gemmin' Juice",
    "Wolf Skull Shoulders",
    "Raven Wings",
    "No-Face",
    "Howler",
    "Anvil",
    "Mountain Dire Wolf"
}

-- ================== Helper Functions ==================
local function getItemIDByName(itemName)
    if not itemName then return nil end
    
    -- Search through items by checking each possible ID
    -- This is a brute force search, but works without getItems() function
    for id = 1, 25000 do
        local item = getItem(id)
        if item then
            local name = item:getName()
            if name and name:lower() == itemName:lower() then
                return id
            end
        end
    end
    
    return nil
end

-- ================== Mod Registration ==================
local cowardlyWeaknessModData = {
    modID = COWARDLY_WEAKNESS_MOD,
    modName = "Howlin' Mad",
    onAddMessage = "`oYou feel the Howlin' Mad take hold...",
    onRemoveMessage = "`oYour Wolf Whistle crumbles to dust.",
    iconID = 2992  -- Use wolf icon or similar
}

if registerLuaPlaymod then
    registerLuaPlaymod(cowardlyWeaknessModData)
end

-- ===============================================
-- 🐺 CONSUMABLE CALLBACK
-- ===============================================

onPlayerConsumableCallback(function(world, player, tile, clickedPlayer, itemID)
    if itemID ~= WOLF_WHISTLE_ID then return false end
    
    -- Check if USER has Cowardly Weakness mod
    if player:getMod(COWARDLY_WEAKNESS_MOD) then
        player:onTalkBubble(player:getNetID(), "`wYou still have Howlin' Mad! Can't use Wolf Whistle!", 1)
        return true
    end
    
    -- Check if player is already in a wolfworld
    if world:getName():lower():find("wolfworld_") then
        player:onTalkBubble(player:getNetID(), "`wYou can't use this while in a wolf world!``", 1)
        return true
    end
    
    -- Consume the item (-1)
    player:changeItem(WOLF_WHISTLE_ID, -1, 0)

    player:onTalkBubble(player:getNetID(), "`6I SHALL FACE THE WOLF!!!", 1)
    
    -- Random wolf world selection
    local randomWorld = WOLF_WORLDS[math.random(1, #WOLF_WORLDS)]
    
    print("[WOLF WHISTLE] Player " .. player:getName() .. " activated Wolf Whistle!")
    print("[WOLF WHISTLE] Sending to: " .. randomWorld)
    
    -- Teleport to wolf world after 3 seconds
    timer.setTimeout(2, function()
        if player:isOnline() then
            player:enterWorld(randomWorld, "", 1)
        end
    end)
    
    return true
end)

-- ===============================================
-- 🌍 WORLD ENTER CALLBACK
-- ===============================================

onPlayerEnterWorldCallback(function(world, player)
    local worldName = world:getName()
    
    -- Check if player enters WOLFWORLD_1/2/3/4/5
    if string.match(worldName, "WOLFWORLD_[12345]") then
        local userID = player:getUserID()
        wolf_hunt_active[userID] = true

        -- Kalan sure hesapla (disconnect sonrasi geri dondu mu?)
        local remaining = COUNTDOWN_DURATION
        if wolf_end_times[userID] then
            remaining = wolf_end_times[userID] - os.time()
            if remaining <= 0 then
                -- Sure dolmus, gonder
                wolf_hunt_active[userID] = nil
                wolf_end_times[userID] = nil
                player:enterWorld("", "", 1)
                player:onTalkBubble(player:getNetID(), "`wYour wolf hunt time has ended!", 1)
                return
            end
        else
            wolf_end_times[userID] = os.time() + COUNTDOWN_DURATION
        end

        print("[WOLF WHISTLE] Player " .. player:getName() .. " entered " .. worldName .. " (" .. remaining .. "s remaining)")

        player:sendVariant({"OnCountdownStart", remaining, -1}, 0, player:getNetID())

        local timerId = timer.setTimeout(remaining, function()
            if player:isOnline() then
                wolf_hunt_active[userID] = nil
                wolf_hunt_timers[userID] = nil
                wolf_end_times[userID] = nil
                player:enterWorld("", "", 1)
                player:onTalkBubble(player:getNetID(), "`wYour wolf hunt time has ended!", 1)
                print("[WOLF WHISTLE] Sent " .. player:getName() .. " back to START")
            end
        end)

        wolf_hunt_timers[userID] = timerId
    end
end)

-- ===============================================
-- 🏃 WORLD LEAVE CALLBACK (PENALTY MOD)
-- ===============================================

onPlayerLeaveWorldCallback(function(world, player)
    local worldName = world:getName()
    local userID = player:getUserID()
    
    -- Check if player leaves WOLFWORLD early (before countdown ends)
    if string.match(worldName, "WOLFWORLD_[12345]") and wolf_hunt_active[userID] then
        -- Disconnect ile mi cikiyor kontrol et (isOnline false = disconnect)
        if player:isOnline() then
            -- Gercek erken cikis - penalty uygula
            print("[WOLF WHISTLE] Player " .. player:getName() .. " left hunt early - penalty!")
            player:addMod(COWARDLY_WEAKNESS_MOD, MOD_DURATION)
            if wolf_hunt_timers[userID] then
                timer.clear(wolf_hunt_timers[userID])
                wolf_hunt_timers[userID] = nil
            end
            wolf_hunt_active[userID] = nil
            wolf_end_times[userID] = nil
            wolf_claimed[userID] = nil
        end
        -- Disconnect ise LeaveWorld once cagrilir, DisconnectCallback sonra - orada handle ediyoruz
    end
end)

-- ===============================================
-- 🚪 DISCONNECT CLEANUP
-- ===============================================

onPlayerDisconnectCallback(function(player)
    local userID = player:getUserID()

    if wolf_hunt_active[userID] then
        -- Sure dolmadan disconnect: endTime koru, geri gelince devam etsin
        -- Erken cikis sayilmaz (disconnect), sadece timer iptal et
        if wolf_hunt_timers[userID] then
            timer.clear(wolf_hunt_timers[userID])
            wolf_hunt_timers[userID] = nil
        end
        -- hunt_active ve end_times koru - geri gelince devam edecek
        print("[WOLF WHISTLE] Player disconnected during hunt, timer paused.")
    end

    wolf_claimed[userID] = nil
    print("[WOLF WHISTLE] Cleaned up hunt data for user: " .. userID)
end)

-- ===============================================
-- 🗿 WOLF TOTEM TILE ACTIVATION
-- ===============================================

local WOLF_TOTEM_ID = 2994
local wolf_claimed = {}  -- spam koruması

onPlayerActivateTileCallback(function(world, player, tile)
    if tile:getTileID() ~= WOLF_TOTEM_ID then return false end

    local userID = player:getUserID()

    -- Spam koruması
    if wolf_claimed[userID] then return true end

    -- Hunt aktif değilse engelle
    if not wolf_hunt_active[userID] then
        player:onTalkBubble(player:getNetID(), "`wYou need to use a Wolf Whistle first!", 1)
        return true
    end

    -- Penalty mod varsa engelle
    if player:getMod(COWARDLY_WEAKNESS_MOD) then return true end

    -- Kilitle
    wolf_claimed[userID] = true

    -- Totem'in koordinatı (tile pos zaten pixel cinsinden)
    local tX = tile:getPosX() * 32
    local tY = tile:getPosY() * 32

    -- Ana ödül
    if not player:changeItem(WOLF_REWARD_ITEM_ID, 1, 0) then
        world:spawnItem(tX, tY, WOLF_REWARD_ITEM_ID, 1)
    end

    -- Random ödül
    local randomRewardName = ""
    if #RANDOM_REWARDS > 0 then
        local rewardString = RANDOM_REWARDS[math.random(1, #RANDOM_REWARDS)]
        local itemName, amount = rewardString:match("^(.+)|(%d+)$")
        if not amount then itemName = rewardString; amount = 1
        else amount = tonumber(amount) end
        local rewardID = getItemIDByName(itemName)
        if rewardID and rewardID > 0 then
            randomRewardName = itemName
            if not player:changeItem(rewardID, amount, 0) then
                world:spawnItem(tX, tY, rewardID, amount)
            end
        end
    end

    -- Mesaj
    local msg = "`9You have been granted " .. (randomRewardName ~= "" and randomRewardName or "a reward") .. " by the Wolf Spirit!"
    player:onConsoleMessage(msg)
    player:onTalkBubble(player:getNetID(), msg, 1)

    -- Efekt ve ses
    player:playAudio("level_up.wav")
    local cx = player:getPosX() + 15
    local cy = player:getPosY() + 15
    -- Sadece oyuncunun kendisine particle 46
    if player.onParticleEffect then
        player:onParticleEffect(46, cx, cy, 0, 0, 0)
    end

    -- Countdown sıfırla
    player:sendVariant({"OnCountdownStart", 0, -1}, 0, player:getNetID())

    -- Timer iptal et (basarili tamamlama - cooldown YOK)
    if wolf_hunt_timers[userID] then
        timer.clear(wolf_hunt_timers[userID])
        wolf_hunt_timers[userID] = nil
    end
    wolf_hunt_active[userID] = nil

    -- 5 saniye sonra teleport
    timer.setTimeout(5, function()
        wolf_claimed[userID] = nil
        if player:isOnline() then
            player:enterWorld("", "", 1)
        end
    end)

    return true
end)

-- ===============================================
-- 🐺 ADMIN COMMAND - /wolf
-- ===============================================

onPlayerCommandCallback(function(world, player, fullCommand)
    if not fullCommand then return false end
    
    local cmd = fullCommand:match("^(%S+)"):lower()
    
    if cmd == "wolf" then
        -- Check if player is DEV (role 51)
        if not player:hasRole(51) then
            player:onConsoleMessage("`4Unknown command.`o Enter `$/?`` for a list of valid commands.")
            return true
        end
        
        -- Remove Cowardly Weakness mod
        if player:getMod(COWARDLY_WEAKNESS_MOD) then
            player:removeMod(COWARDLY_WEAKNESS_MOD)
            player:playAudio("audio/success.wav")
            print("[WOLF COMMAND] Admin " .. player:getName() .. " removed Cowardly Weakness mod")
        else
            print("[WOLF COMMAND] Admin " .. player:getName() .. " tried to remove Cowardly Weakness mod but didn't have it")
        end
        
        return true
    end

    if cmd == "ghost" or cmd == "superbreak" or cmd == "longpunch" or cmd == "tpclick" or cmd == "invis" then
       if world:getName():lower():find("wolfworld_") then
            if not player:hasRole(51) then
                player:onConsoleMessage("`oCommand blocked in Mine World!``")
                return true
            end
        end
    end
    
    return false
end)

print(">> (Success) Wolf Whistle 10-Minute Hunt System Loaded!")