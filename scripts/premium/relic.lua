    print('(relic-system) for GTPS Cloud | by Copilot')

    local ROLE_DEVELOPER = 51
    local RELIC_DATA_KEY = 'relic_system'
        local RELIC_PERSISTENCE_ENABLED = true
    print('(relic-system) persistence mode: ' .. (RELIC_PERSISTENCE_ENABLED and 'ON' or 'OFF'))
    local RELIC_OPEN_COST_GEMS = 100000
    local WOLF_TOTEM_ID = 2994

    local RELIC_MAIN_DIALOG = 'relic_main_panel'
    local RELIC_OPEN_CONFIRM_DIALOG = 'relic_open_confirm_panel'
    local RELIC_ADMIN_DIALOG = 'relic_admin_panel'
    local RELIC_ADMIN_BUILDER_DIALOG = 'relic_admin_builder_panel'
    local RELIC_ADMIN_TYPE_DIALOG_PREFIX = 'relic_admin_type_panel_'
    local RELIC_CANCEL_CONFIRM_DIALOG = 'relic_cancel_confirm_panel'

    local QUEST_TYPES = {
    'BREAK',
    'PUT',
    'PLANT',
    'HARVEST',
    'EARN_GEMS',
    'EARN_XP',
    'DELIVER_GEMS',
    'FINISH_SURGERY',
    'FINISH_CRIME',
    'FINISH_GEIGER',
    'FINISH_WOLF'
    }

    local QUEST_LABEL = {
    BREAK = 'Break',
    PUT = 'Put',
    PLANT = 'Plant',
    HARVEST = 'Harvest',
    EARN_GEMS = 'Earn Gems',
    EARN_XP = 'Earn XP',
    DELIVER_GEMS = 'Deliver Gems',
    FINISH_SURGERY = 'Finish Surgery',
    FINISH_CRIME = 'Finish Crime',
    FINISH_GEIGER = 'Finish Geiger',
    FINISH_WOLF = 'Wolf World'
    }

    local seedOffset = 0
    if type(getServerID) == 'function' then
    seedOffset = getServerID() or 0
    end

    local seedTime = 0
    if type(os) == 'table' and type(os.time) == 'function' then
    seedTime = tonumber(os.time()) or 0
    end

    if type(math) == 'table' and type(math.randomseed) == 'function' then
    math.randomseed(seedTime + (tonumber(seedOffset) or 0))
    end

    local function boolVal(value)
    return value == true or value == 1
    end

    local function trimString(value)
    if type(value) ~= 'string' then
        return ''
    end

    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
    end

    local function normalizeStoredText(value)
    if type(value) ~= 'string' then
        return ''
    end

    local cleaned = value:gsub('[\r\n|]+', ' ')
    cleaned = cleaned:gsub('%s+', ' ')
    return trimString(cleaned)
    end

    local function getDefaultTargetForQuestType(questType)
    if questType == 'BREAK' or questType == 'PUT' or questType == 'PLANT' or questType == 'HARVEST' then
        return 500
    end

    if questType == 'EARN_GEMS' or questType == 'EARN_XP' or questType == 'DELIVER_GEMS' then
        return 500
    end

    return 1
    end

    local function getDefaultDraftQuestEnabled(questType)
    return questType == 'BREAK' or questType == 'PUT' or questType == 'PLANT' or questType == 'HARVEST'
    end

    local function normalizeTargetRange(minValue, maxValue, fallbackValue)
    local minTarget = math.floor(tonumber(minValue) or 0)
    local maxTarget = math.floor(tonumber(maxValue) or 0)
    local fallbackTarget = math.floor(tonumber(fallbackValue) or 0)

    if minTarget <= 0 and fallbackTarget > 0 then
        minTarget = fallbackTarget
    end

    if maxTarget <= 0 and fallbackTarget > 0 then
        maxTarget = fallbackTarget
    end

    if minTarget <= 0 and maxTarget > 0 then
        minTarget = maxTarget
    end

    if maxTarget <= 0 and minTarget > 0 then
        maxTarget = minTarget
    end

    if minTarget <= 0 or maxTarget <= 0 then
        return nil, nil
    end

    if maxTarget < minTarget then
        minTarget, maxTarget = maxTarget, minTarget
    end

    return minTarget, maxTarget
    end

    local function civilFromUnixDays(daysSinceEpoch)
    local z = daysSinceEpoch + 719468
    local era

    if z >= 0 then
        era = math.floor(z / 146097)
    else
        era = math.floor((z - 146096) / 146097)
    end

    local doe = z - era * 146097
    local yoe = math.floor((doe - math.floor(doe / 1460) + math.floor(doe / 36524) - math.floor(doe / 146096)) / 365)
    local y = yoe + era * 400
    local doy = doe - (365 * yoe + math.floor(yoe / 4) - math.floor(yoe / 100))
    local mp = math.floor((5 * doy + 2) / 153)
    local m = mp + ((mp < 10) and 3 or -9)

    if m <= 2 then
        y = y + 1
    end

    return y, m
    end

    local function unixDaysFromCivil(year, month, day)
    local y = year
    local m = month

    if m <= 2 then
        y = y - 1
    end

    local era
    if y >= 0 then
        era = math.floor(y / 400)
    else
        era = math.floor((y - 399) / 400)
    end

    local yoe = y - era * 400
    local shiftedMonth = m + ((m > 2) and -3 or 9)
    local doy = math.floor((153 * shiftedMonth + 2) / 5) + day - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy

    return era * 146097 + doe - 719468
    end

    local function getCurrentMonthKey()
    local now = 0

    if type(os) == 'table' and type(os.time) == 'function' then
        now = os.time() or 0
    end

    if type(now) ~= 'number' then
        return '1970-01'
    end

    local daysSinceEpoch = math.floor(now / 86400)
    local year, month = civilFromUnixDays(daysSinceEpoch)
    return string.format('%04d-%02d', year, month)
    end

    local function normalizeMonthKey(raw)
    if type(raw) ~= 'string' then
        return nil
    end

    local year, month = raw:match('^(%d%d%d%d)%-(%d%d)$')
    if not year or not month then
        return nil
    end

    local monthNum = tonumber(month)
    if not monthNum or monthNum < 1 or monthNum > 12 then
        return nil
    end

    return string.format('%04d-%02d', tonumber(year), monthNum)
    end

    local function monthLabel(monthKey)
    if type(monthKey) ~= 'string' then
        return tostring(monthKey or '-')
    end

    local year, month = monthKey:match('^(%d%d%d%d)%-(%d%d)$')
    if not year or not month then
        return monthKey
    end

    return month .. '/' .. year
    end

    local function monthKeyFromYearMonth(year, month)
    return string.format('%04d-%02d', year, month)
    end

    local function yearFromMonthKey(monthKey)
    local normalized = normalizeMonthKey(monthKey)
    if not normalized then
        return 1970
    end

    local year = normalized:match('^(%d%d%d%d)%-%d%d$')
    return tonumber(year) or 1970
    end

    local function getSecondsUntilMonthlyReset()
    if type(os) ~= 'table' or type(os.time) ~= 'function' then
        return 0
    end

    local currentMonthKey = getCurrentMonthKey()
    local yearText, monthText = currentMonthKey:match('^(%d%d%d%d)%-(%d%d)$')
    local year = tonumber(yearText) or 1970
    local month = tonumber(monthText) or 1

    if month >= 12 then
        year = year + 1
        month = 1
    else
        month = month + 1
    end

    local nextMonthStart = unixDaysFromCivil(year, month, 1) * 86400
    local now = tonumber(os.time()) or 0
    local remaining = nextMonthStart - now

    if remaining < 0 then
        return 0
    end

    return remaining
    end

    local function getMonthlyResetLabel()
    local secondsRemaining = getSecondsUntilMonthlyReset()
    local daysRemaining = math.ceil(secondsRemaining / 86400)

    if daysRemaining < 0 then
        daysRemaining = 0
    end

    if daysRemaining == 1 then
        return '1 day before reset'
    end

    return tostring(daysRemaining) .. ' days before reset'
    end

    local function getItemName(itemID)
    local item = getItem(itemID)
    if item and item.getName then
        local name = item:getName()
        if name and name ~= '' then
        return name
        end
    end

    return 'Item #' .. tostring(itemID)
    end

    local function getCampaignRewardTitle(campaign)
    if type(campaign) ~= 'table' then
        return 'Relic'
    end

    local title = normalizeStoredText(campaign.rewardItemTitle)
    if title ~= '' then
        return title
    end

    return getItemName(campaign.rewardItemID)
    end

    local function getCampaignRewardDescription(campaign)
    if type(campaign) ~= 'table' then
        return 'Complete every stage before the monthly reset to claim the featured relic reward.'
    end

    local description = normalizeStoredText(campaign.rewardItemDescription)
    if description ~= '' then
        return description
    end

    return 'Complete every stage before the monthly reset to claim the featured relic reward.'
    end

    local function sanitizeQuestConfig(rawConfig, questType, legacyEnabled, legacyTarget)
    local defaultTarget = getDefaultTargetForQuestType(questType)
    local enabled = legacyEnabled == true
    local minSource = legacyTarget
    local maxSource = legacyTarget

    if type(rawConfig) == 'table' then
        if rawConfig.enabled ~= nil then
        enabled = boolVal(rawConfig.enabled)
        end

        minSource = rawConfig.minTarget or rawConfig.targetCount or minSource
        maxSource = rawConfig.maxTarget or rawConfig.targetCount or maxSource
    end

    local minTarget, maxTarget = normalizeTargetRange(minSource, maxSource, defaultTarget)

    return {
        enabled = enabled,
        minTarget = minTarget or defaultTarget,
        maxTarget = maxTarget or defaultTarget
    }
    end

    local function sanitizeCampaign(rawCampaign, fallbackMonthKey)
    if type(rawCampaign) ~= 'table' then
        return nil
    end

    local monthKey = normalizeMonthKey(rawCampaign.monthKey)
    if not monthKey then
        monthKey = normalizeMonthKey(fallbackMonthKey) or getCurrentMonthKey()
    end

    local legacyEnabledTypes = type(rawCampaign.enabledTypes) == 'table' and rawCampaign.enabledTypes or nil
    local legacyTarget = math.floor(tonumber(rawCampaign.targetCount) or 0)
    local rawQuestConfigs = type(rawCampaign.questConfigs) == 'table' and rawCampaign.questConfigs or nil

    local questConfigs = {}
    local enabledCount = 0
    for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local config = sanitizeQuestConfig(
        rawQuestConfigs and rawQuestConfigs[questType] or nil,
        questType,
        legacyEnabledTypes and legacyEnabledTypes[questType] == true or false,
        legacyTarget
        )

        questConfigs[questType] = config
        if config.enabled then
        enabledCount = enabledCount + 1
        end
    end

    if enabledCount == 0 then
        local defaultTarget = legacyTarget > 0 and legacyTarget or getDefaultTargetForQuestType('BREAK')
        questConfigs.BREAK = {
        enabled = true,
        minTarget = defaultTarget,
        maxTarget = defaultTarget
        }
    end

    local campaign = {
        id = math.floor(tonumber(rawCampaign.id) or 0),
        monthKey = monthKey,
        rewardItemID = math.floor(tonumber(rawCampaign.rewardItemID) or 0),
        rewardItemTitle = normalizeStoredText(rawCampaign.rewardItemTitle),
        rewardItemDescription = normalizeStoredText(rawCampaign.rewardItemDescription),
        rewardAmount = math.floor(tonumber(rawCampaign.rewardAmount) or 0),
        totalStages = math.floor(tonumber(rawCampaign.totalStages) or 0),
        questConfigs = questConfigs,
        createdBy = tonumber(rawCampaign.createdBy) or 0,
        createdAt = tonumber(rawCampaign.createdAt) or 0
    }

    if campaign.rewardItemID <= 0 then return nil end
    if campaign.rewardAmount <= 0 then return nil end
    if campaign.totalStages <= 0 then return nil end

    return campaign
    end

    local function sanitizePlayer(rawPlayer)
    local cleaned = {
        months = {},
        claimedCampaigns = {}
    }

    if type(rawPlayer) ~= 'table' then
        return cleaned
    end

    local claimedSource = nil
    if type(rawPlayer.claimedCampaigns) == 'table' then
        claimedSource = rawPlayer.claimedCampaigns
    elseif type(rawPlayer.claimed) == 'table' then
        claimedSource = rawPlayer.claimed
    end

    if claimedSource then
        for campaignID, isClaimed in pairs(claimedSource) do
        if isClaimed then
            cleaned.claimedCampaigns[tostring(campaignID)] = true
        end
        end
    end

    if type(rawPlayer.months) == 'table' then
        for rawMonthKey, rawMonthData in pairs(rawPlayer.months) do
        local monthKey = normalizeMonthKey(tostring(rawMonthKey))

        if monthKey and type(rawMonthData) == 'table' then
            local monthData = {
            opened = boolVal(rawMonthData.opened),
            campaignID = math.floor(tonumber(rawMonthData.campaignID) or 0),
            stage = math.max(1, math.floor(tonumber(rawMonthData.stage) or 1)),
            progress = math.max(0, math.floor(tonumber(rawMonthData.progress) or 0)),
            stageTarget = math.max(0, math.floor(tonumber(rawMonthData.stageTarget or rawMonthData.targetCount) or 0)),
            completed = boolVal(rawMonthData.completed),
            claimed = boolVal(rawMonthData.claimed),
            questType = nil
            }

            local questType = tostring(rawMonthData.questType or '')
            for i = 1, #QUEST_TYPES do
            if questType == QUEST_TYPES[i] then
                monthData.questType = questType
                break
            end
            end

            cleaned.months[monthKey] = monthData
        end
        end
    end

    return cleaned
    end

    local loadedRelicDB = {}
    if RELIC_PERSISTENCE_ENABLED then
        local rawLoadedRelicDB = loadDataFromServer(RELIC_DATA_KEY)
        if type(rawLoadedRelicDB) == 'table' then
            loadedRelicDB = rawLoadedRelicDB
        end
    end

    local relicDB = {
    players = {},
    monthlyCampaigns = {},
    lastCampaignID = 0
    }

    if type(loadedRelicDB) == 'table' then
    relicDB.lastCampaignID = math.floor(tonumber(loadedRelicDB.lastCampaignID) or 0)

    if type(loadedRelicDB.monthlyCampaigns) == 'table' then
        for monthKey, rawCampaign in pairs(loadedRelicDB.monthlyCampaigns) do
        local campaign = sanitizeCampaign(rawCampaign, tostring(monthKey))
        if campaign then
            relicDB.monthlyCampaigns[campaign.monthKey] = campaign
            if campaign.id > relicDB.lastCampaignID then
            relicDB.lastCampaignID = campaign.id
            end
        end
        end
    end

    if type(loadedRelicDB.activeCampaign) == 'table' then
        local legacyCampaign = sanitizeCampaign(loadedRelicDB.activeCampaign, loadedRelicDB.activeCampaign.monthKey)
        if legacyCampaign and not relicDB.monthlyCampaigns[legacyCampaign.monthKey] then
        relicDB.monthlyCampaigns[legacyCampaign.monthKey] = legacyCampaign
        if legacyCampaign.id > relicDB.lastCampaignID then
            relicDB.lastCampaignID = legacyCampaign.id
        end
        end
    end

    if type(loadedRelicDB.players) == 'table' then
        for uid, rawPlayer in pairs(loadedRelicDB.players) do
        relicDB.players[tostring(uid)] = sanitizePlayer(rawPlayer)
        end
    end
    end

    local adminDraftByUser = {}
    local adminYearPageByUser = {}
    local dirty = false

    registerLuaCommand({
    command = 'relic',
    description = 'Relic quests panel (/relic admin for Developer)',
    roleRequired = 0
    })

    local showRelicMainPanel
    local showRelicOpenConfirmPanel
    local showRelicAdminPanel
    local showRelicAdminBuilderPanel
    local showRelicAdminTypeConfigPanel
    local showRelicCancelConfirmPanel

    local function markDirty()
    dirty = true
    end

    local function saveRelicData(force)
            if not RELIC_PERSISTENCE_ENABLED then
                dirty = false
                return
            end

    if force or dirty then
        saveDataToServer(RELIC_DATA_KEY, relicDB)
        dirty = false
    end
    end

    local function getCampaignQuestConfig(campaign, questType)
    if type(campaign) ~= 'table' or type(campaign.questConfigs) ~= 'table' then
        return nil
    end

    local config = campaign.questConfigs[questType]
    if type(config) ~= 'table' then
        return nil
    end

    return config
    end

    local function getEnabledQuestTypes(questConfigs)
    local list = {}
    for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local config = type(questConfigs) == 'table' and questConfigs[questType] or nil
        if type(config) == 'table' and config.enabled then
        list[#list + 1] = questType
        end
    end
    return list
    end

    local function getQuestTargetLabel(minTarget, maxTarget)
    local minValue = math.floor(tonumber(minTarget) or 0)
    local maxValue = math.floor(tonumber(maxTarget) or 0)

    if minValue <= 0 and maxValue <= 0 then
        return 'unset'
    end

    if minValue <= 0 then minValue = maxValue end
    if maxValue <= 0 then maxValue = minValue end

    if minValue == maxValue then
        return tostring(minValue)
    end

    return tostring(minValue) .. '-' .. tostring(maxValue)
    end

    local function getEnabledQuestSummary(questConfigs)
    local list = {}
    for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local config = type(questConfigs) == 'table' and questConfigs[questType] or nil
        if type(config) == 'table' and config.enabled then
        list[#list + 1] = (QUEST_LABEL[questType] or questType) .. ' ' .. getQuestTargetLabel(config.minTarget, config.maxTarget)
        end
    end

    if #list == 0 then
        return '-'
    end

    if #list <= 3 then
        return table.concat(list, ', ')
    end

    return list[1] .. ', ' .. list[2] .. ', ' .. list[3] .. ' +' .. tostring(#list - 3)
    end

    local function pickRandomQuestType(questConfigs)
    local available = getEnabledQuestTypes(questConfigs)
    if #available == 0 then
        return nil
    end

    return available[math.random(1, #available)]
    end

    local function pickQuestTarget(config)
    if type(config) ~= 'table' then
        return 1
    end

    local minTarget = math.max(1, math.floor(tonumber(config.minTarget) or 1))
    local maxTarget = math.max(minTarget, math.floor(tonumber(config.maxTarget) or minTarget))

    if minTarget == maxTarget then
        return minTarget
    end

    return math.random(minTarget, maxTarget)
    end

    local function getCampaignForMonth(monthKey)
    local campaign = relicDB.monthlyCampaigns[monthKey]
    if type(campaign) ~= 'table' then
        return nil
    end

    return campaign
    end

    local function countMonthlyCampaigns()
    local count = 0
    for _ in pairs(relicDB.monthlyCampaigns) do
        count = count + 1
    end
    return count
    end

    local function ensurePlayerRecord(player)
    local uid = tostring(player:getUserID())
    local record = relicDB.players[uid]

    if type(record) ~= 'table' then
        record = {
        months = {},
        claimedCampaigns = {}
        }
        relicDB.players[uid] = record
        markDirty()
    end

    if type(record.months) ~= 'table' then
        record.months = {}
        markDirty()
    end

    if type(record.claimedCampaigns) ~= 'table' then
        record.claimedCampaigns = {}
        markDirty()
    end

    return record
    end

    local function assignStageObjective(monthData, campaign, preferredQuestType)
    if type(monthData) ~= 'table' or type(campaign) ~= 'table' then
        return false
    end

    local nextQuestType = preferredQuestType
    local config = getCampaignQuestConfig(campaign, nextQuestType)

    if not config or not config.enabled then
        nextQuestType = pickRandomQuestType(campaign.questConfigs) or 'BREAK'
        config = getCampaignQuestConfig(campaign, nextQuestType)
    end

    if not config then
        local defaultTarget = getDefaultTargetForQuestType(nextQuestType)
        config = {
        enabled = true,
        minTarget = defaultTarget,
        maxTarget = defaultTarget
        }
    end

    local nextTarget = pickQuestTarget(config)
    local changed = monthData.questType ~= nextQuestType or monthData.stageTarget ~= nextTarget

    monthData.questType = nextQuestType
    monthData.stageTarget = nextTarget

    if changed then
        markDirty()
    end

    return changed
    end

    local function ensureMonthData(record, monthKey, campaign)
    local monthData = record.months[monthKey]

    if type(monthData) ~= 'table' then
        monthData = {
        opened = false,
        campaignID = 0,
        stage = 1,
        progress = 0,
        stageTarget = 0,
        completed = false,
        claimed = false,
        questType = nil
        }
        record.months[monthKey] = monthData
        markDirty()
    end

    if not campaign then
        return monthData
    end

    if monthData.campaignID ~= campaign.id then
        monthData.opened = false
        monthData.campaignID = campaign.id
        monthData.stage = 1
        monthData.progress = 0
        monthData.stageTarget = 0
        monthData.completed = false
        monthData.claimed = false
        monthData.questType = nil
        markDirty()
    end

    if monthData.stage < 1 then
        monthData.stage = 1
        markDirty()
    end

    if monthData.progress < 0 then
        monthData.progress = 0
        markDirty()
    end

    if record.claimedCampaigns[tostring(campaign.id)] then
        monthData.opened = true
        monthData.completed = true
        monthData.claimed = true
        monthData.stage = campaign.totalStages

        if monthData.questType == nil then
        monthData.questType = pickRandomQuestType(campaign.questConfigs) or 'BREAK'
        markDirty()
        end

        if monthData.stageTarget <= 0 then
        monthData.stageTarget = math.max(monthData.progress, 1)
        markDirty()
        end

        if monthData.progress < monthData.stageTarget then
        monthData.progress = monthData.stageTarget
        markDirty()
        end

        return monthData
    end

    if monthData.opened and not monthData.completed then
        local config = getCampaignQuestConfig(campaign, monthData.questType)
        if not config or not config.enabled or monthData.stageTarget <= 0 then
        assignStageObjective(monthData, campaign, monthData.questType)
        end
    end

    return monthData
    end

    local function getAdminYearPage(player)
    local uid = tostring(player:getUserID())
    local page = adminYearPageByUser[uid]

    if type(page) ~= 'number' then
        page = 0
        adminYearPageByUser[uid] = page
    end

    return page
    end

    local function setAdminYearPage(player, page)
    local uid = tostring(player:getUserID())
    local safePage = math.floor(tonumber(page) or 0)

    if safePage < -20 then safePage = -20 end
    if safePage > 20 then safePage = 20 end

    adminYearPageByUser[uid] = safePage
    end

    local function buildProgressBar(current, target, width)
    local safeTarget = math.max(1, math.floor(tonumber(target) or 1))
    local safeCurrent = math.max(0, math.floor(tonumber(current) or 0))
    local barWidth = math.max(5, math.floor(tonumber(width) or 12))

    if safeCurrent > safeTarget then
        safeCurrent = safeTarget
    end

    local percent = math.floor((safeCurrent * 100) / safeTarget)
    local fill = math.floor((percent * barWidth) / 100)

    if fill < 0 then fill = 0 end
    if fill > barWidth then fill = barWidth end

    return string.rep('#', fill) .. string.rep('-', barWidth - fill), percent
    end

    local function getCurrentStageTarget(monthData, campaign)
    local stageTarget = math.max(0, math.floor(tonumber(monthData.stageTarget) or 0))
    if stageTarget > 0 then
        return stageTarget
    end

    local config = getCampaignQuestConfig(campaign, monthData.questType)
    if config then
        return math.max(1, math.floor(tonumber(config.minTarget) or 1))
    end

    return 1
    end

    local function getQuestObjectiveText(questType, target)
    local amount = math.max(1, math.floor(tonumber(target) or 1))

    if questType == 'BREAK' then return 'Break ' .. amount .. ' blocks' end
    if questType == 'PUT' then return 'Put ' .. amount .. ' blocks' end
    if questType == 'PLANT' then return 'Plant ' .. amount .. ' seeds' end
    if questType == 'HARVEST' then return 'Harvest ' .. amount .. ' trees' end
    if questType == 'EARN_GEMS' then return 'Earn ' .. amount .. ' gems' end
    if questType == 'EARN_XP' then return 'Earn ' .. amount .. ' XP' end
    if questType == 'DELIVER_GEMS' then return 'Deliver ' .. amount .. ' gems' end
    if questType == 'FINISH_SURGERY' then return 'Finish ' .. amount .. ' surgeries' end
    if questType == 'FINISH_CRIME' then return 'Finish ' .. amount .. ' crimes' end
    if questType == 'FINISH_GEIGER' then return 'Finish ' .. amount .. ' geiger hunts' end
    if questType == 'FINISH_WOLF' then return 'Finish ' .. amount .. ' wolf worlds' end

    return tostring(amount)
    end

    local function questStatusLines(monthData, campaign)
    local targetCount = getCurrentStageTarget(monthData, campaign)
    local currentProgress = math.max(0, math.floor(tonumber(monthData.progress) or 0))
    local _, percent = buildProgressBar(currentProgress, targetCount, 12)

    if currentProgress > targetCount then
        currentProgress = targetCount
    end

    local stageLine = string.format(
        '%d/%d',
        monthData.stage,
        campaign.totalStages
    )

    return stageLine, currentProgress, targetCount
    end

    local function getPlayerStandingTile(world, player)
    if type(world) ~= 'table' or type(player) ~= 'table' then
        return nil
    end

    local tileX = 0
    local tileY = 0

    if player.getBlockPosX and player.getBlockPosY then
        tileX = player:getBlockPosX() or 0
        tileY = player:getBlockPosY() or 0
    else
        tileX = math.floor((player:getPosX() or 0) / 32)
        tileY = math.floor((player:getPosY() or 0) / 32)
    end

    return world:getTile(tileX, tileY)
    end

    local function tryAutoUseReward(player, itemID, amount)
    local world = player:getWorld()
    if not world then
        return 0
    end

    local tile = getPlayerStandingTile(world, player)
    if not tile then
        return 0
    end

    local total = math.max(0, math.floor(tonumber(amount) or 0))
    local usedCount = 0

    for _ = 1, total do
        local used = world:useConsumable(player, tile, itemID, 1)
        if not used then
        break
        end
        usedCount = usedCount + 1
    end

    return usedCount
    end

    local function playRewardCelebration(player, itemID, isAutoUsed)
    local world = player:getWorld()
    if not world then
        return
    end

    local netID = player:getNetID()
    world:useItemEffect(netID, itemID, netID, 0)

    local tileX = player.getBlockPosX and player:getBlockPosX() or math.floor((player:getPosX() or 0) / 32)
    local tileY = player.getBlockPosY and player:getBlockPosY() or math.floor((player:getPosY() or 0) / 32)
    local particleID = isAutoUsed and 46 or 38
    player:onParticleEffect(particleID, tileX, tileY, 0, 0, 0)
    player:sendVariant({"OnParticleEffect", 90, player:getPosX(), player:getPosY()})
    player:playAudio("audio/explosion.wav")
    end

    local function broadcastQuestCompletion(player, campaign, rewardText)
    local playerName = player.getCleanName and player:getCleanName() or player:getName()
    local message = string.format('`5>> `w%s `5has completed the `#%s Quest Expedition `5and claimed the legendary `w%s `5!✨ <<``', playerName, getCampaignRewardTitle(campaign), rewardText)

    local candidates = {}

    if getServerPlayers then
        local onlinePlayers = getServerPlayers()
        if type(onlinePlayers) == 'table' then
        for i = 1, #onlinePlayers do
            candidates[#candidates + 1] = onlinePlayers[i]
        end
        end
    end

    if #candidates == 0 and getAllPlayers then
        local allPlayers = getAllPlayers()
        if type(allPlayers) == 'table' then
        for i = 1, #allPlayers do
            candidates[#candidates + 1] = allPlayers[i]
        end
        end
    end

    if type(candidates) == 'table' then
        local seen = {}
        for i = 1, #candidates do
        local target = candidates[i]
        if target and target.onConsoleMessage then
            local key = tostring(target:getUserID() or target:getNetID() or i)
            if not seen[key] then
            seen[key] = true
            target:onConsoleMessage(message)
            end
        end
        end
    end
    end

    local function buildDefaultAdminDraft(monthKey)
    local questConfigs = {}
    for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local defaultTarget = getDefaultTargetForQuestType(questType)
        questConfigs[questType] = {
        enabled = getDefaultDraftQuestEnabled(questType),
        minTarget = tostring(defaultTarget),
        maxTarget = tostring(defaultTarget)
        }
    end

    return {
        monthKey = monthKey or getCurrentMonthKey(),
        rewardItemID = '242',
        rewardItemTitle = 'Relic',
        rewardItemDescription = 'Complete every stage before the monthly reset to claim this relic reward.',
        rewardAmount = '1',
        questTotal = '10',
        questConfigs = questConfigs
    }
    end

    local function getAdminDraft(player)
    local uid = tostring(player:getUserID())
    local draft = adminDraftByUser[uid]

    if type(draft) ~= 'table' then
        draft = buildDefaultAdminDraft(getCurrentMonthKey())
        adminDraftByUser[uid] = draft
    end

    return draft
    end

    local function setAdminDraft(player, monthKey, campaign)
    local uid = tostring(player:getUserID())
    local draft = buildDefaultAdminDraft(monthKey)

    if type(campaign) == 'table' then
        draft.rewardItemID = tostring(campaign.rewardItemID)
        draft.rewardItemTitle = getCampaignRewardTitle(campaign)
        draft.rewardItemDescription = getCampaignRewardDescription(campaign)
        draft.rewardAmount = tostring(campaign.rewardAmount)
        draft.questTotal = tostring(campaign.totalStages)

        for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local config = getCampaignQuestConfig(campaign, questType)
        if config then
            draft.questConfigs[questType] = {
            enabled = config.enabled == true,
            minTarget = tostring(config.minTarget),
            maxTarget = tostring(config.maxTarget)
            }
        end
        end
    end

    adminDraftByUser[uid] = draft
    return draft
    end

    local function ensureDraftQuestConfig(draft, questType)
    if type(draft.questConfigs) ~= 'table' then
        draft.questConfigs = {}
    end

    local config = draft.questConfigs[questType]
    if type(config) ~= 'table' then
        local defaultTarget = getDefaultTargetForQuestType(questType)
        config = {
        enabled = getDefaultDraftQuestEnabled(questType),
        minTarget = tostring(defaultTarget),
        maxTarget = tostring(defaultTarget)
        }
        draft.questConfigs[questType] = config
    end

    if config.enabled == nil then
        config.enabled = false
    end

    if config.minTarget == nil then
        config.minTarget = ''
    end

    if config.maxTarget == nil then
        config.maxTarget = ''
    end

    return config
    end

    local function updateDraftFromDialogData(draft, data)
    if data['reward_item_id'] ~= nil then draft.rewardItemID = data['reward_item_id'] end
    if data['reward_item_title'] ~= nil then draft.rewardItemTitle = data['reward_item_title'] end
    if data['reward_item_description'] ~= nil then draft.rewardItemDescription = data['reward_item_description'] end
    if data['reward_amount'] ~= nil then draft.rewardAmount = data['reward_amount'] end
    if data['quest_total'] ~= nil then draft.questTotal = data['quest_total'] end
    end

    local function updateDraftQuestConfigFromDialogData(draftQuestConfig, data)
    if data['quest_min_target'] ~= nil then draftQuestConfig.minTarget = data['quest_min_target'] end
    if data['quest_max_target'] ~= nil then draftQuestConfig.maxTarget = data['quest_max_target'] end
    end

    local function parseDraftQuestRange(draftQuestConfig, questType)
    if not draftQuestConfig.enabled then
        return 0, 0, nil
    end

    local minTarget, maxTarget = normalizeTargetRange(draftQuestConfig.minTarget, draftQuestConfig.maxTarget, nil)
    if not minTarget or not maxTarget then
        return nil, nil, '`4' .. (QUEST_LABEL[questType] or questType) .. ' quest needs a minimum or maximum target greater than 0.'
    end

    return minTarget, maxTarget, nil
    end

    local function getDraftQuestSummary(draft, questType)
    local config = ensureDraftQuestConfig(draft, questType)
    local status = config.enabled and 'ON' or 'OFF'
    local rangeText = getQuestTargetLabel(config.minTarget, config.maxTarget)
    return string.format('%s [%s] Target %s', QUEST_LABEL[questType] or questType, status, rangeText)
    end

    local function createCampaignFromDraft(player, draft)
    local monthKey = normalizeMonthKey(draft.monthKey)
    local rewardItemID = math.floor(tonumber(draft.rewardItemID) or 0)
    local rewardAmount = math.floor(tonumber(draft.rewardAmount) or 0)
    local questTotal = math.floor(tonumber(draft.questTotal) or 0)
    local rewardItemTitle = normalizeStoredText(draft.rewardItemTitle)
    local rewardItemDescription = normalizeStoredText(draft.rewardItemDescription)

    if not monthKey then
        player:onTalkBubble(player:getNetID(), '`4Invalid campaign month selected.', 0)
        return false
    end

    if rewardItemID <= 0 then
        player:onTalkBubble(player:getNetID(), '`4Reward Item ID must be greater than 0.', 0)
        return false
    end

    if rewardAmount <= 0 then
        player:onTalkBubble(player:getNetID(), '`4Reward amount must be greater than 0.', 0)
        return false
    end

    if questTotal <= 0 then
        player:onTalkBubble(player:getNetID(), '`4Total stages must be greater than 0.', 0)
        return false
    end

    local questConfigs = {}
    local enabledCount = 0

    for i = 1, #QUEST_TYPES do
        local questType = QUEST_TYPES[i]
        local draftQuestConfig = ensureDraftQuestConfig(draft, questType)
        local minTarget, maxTarget, errorText = parseDraftQuestRange(draftQuestConfig, questType)

        if errorText then
        player:onTalkBubble(player:getNetID(), errorText, 0)
        return false
        end

        if draftQuestConfig.enabled then
        enabledCount = enabledCount + 1
        questConfigs[questType] = {
            enabled = true,
            minTarget = minTarget,
            maxTarget = maxTarget
        }
        else
        questConfigs[questType] = {
            enabled = false,
            minTarget = 0,
            maxTarget = 0
        }
        end
    end

    if enabledCount == 0 then
        player:onTalkBubble(player:getNetID(), '`4At least one quest type must be enabled.', 0)
        return false
    end

    local replacing = relicDB.monthlyCampaigns[monthKey] ~= nil

    relicDB.lastCampaignID = relicDB.lastCampaignID + 1
    relicDB.monthlyCampaigns[monthKey] = {
        id = relicDB.lastCampaignID,
        monthKey = monthKey,
        rewardItemID = rewardItemID,
        rewardItemTitle = rewardItemTitle,
        rewardItemDescription = rewardItemDescription,
        rewardAmount = rewardAmount,
        totalStages = questTotal,
        questConfigs = questConfigs,
        createdBy = player:getUserID(),
        createdAt = type(os) == 'table' and type(os.time) == 'function' and os.time() or 0
    }

    markDirty()
    saveRelicData(true)

    if replacing then
        player:onTalkBubble(
        player:getNetID(),
        string.format('`2Campaign for %s replaced with ID #%d.', monthLabel(monthKey), relicDB.lastCampaignID),
        0
        )
    else
        player:onTalkBubble(
        player:getNetID(),
        string.format('`2Campaign ID #%d created for %s.', relicDB.lastCampaignID, monthLabel(monthKey)),
        0
        )
    end

    return true
    end

    local function openMonthlyQuest(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)
    if not campaign then
        player:onTalkBubble(player:getNetID(), '`4No relic quest campaign is available for this month.', 0)
        return
    end

    local record = ensurePlayerRecord(player)
    local monthData = ensureMonthData(record, monthKey, campaign)

    if monthData.opened then
        player:onTalkBubble(player:getNetID(), '`4You already started this month\'s relic quest.', 0)
        return
    end

    local gems = tonumber(player:getGems()) or 0
    if gems < RELIC_OPEN_COST_GEMS then
        player:onTalkBubble(player:getNetID(), '`4Not enough Gems to start this month\'s relic quest.', 0)
        return
    end

    player:removeGems(RELIC_OPEN_COST_GEMS, 1, 1)

    monthData.opened = true
    monthData.stage = 1
    monthData.progress = 0
    monthData.completed = false
    monthData.claimed = false
    monthData.stageTarget = 0
    monthData.questType = nil

    assignStageObjective(monthData, campaign, nil)

    markDirty()
    saveRelicData(true)

    player:onTalkBubble(
        player:getNetID(),
        string.format('`2%s Quest Expedition started. Cost: %d Gems.', getCampaignRewardTitle(campaign), RELIC_OPEN_COST_GEMS),
        0
    )
    end

    local function progressQuest(player, actionType, amount)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)
    if not campaign then return end

    local record = ensurePlayerRecord(player)
    local monthData = ensureMonthData(record, monthKey, campaign)

    if not monthData.opened or monthData.completed then return end
    if monthData.questType ~= actionType then return end

    local stageTarget = getCurrentStageTarget(monthData, campaign)
    local addAmount = math.max(0, math.floor(tonumber(amount) or 1))
    if addAmount <= 0 then return end

    monthData.progress = (monthData.progress or 0) + addAmount

    if monthData.progress < stageTarget then
        markDirty()
        return
    end

    monthData.progress = stageTarget

    if monthData.stage >= campaign.totalStages then
        monthData.completed = true
        player:onTalkBubble(player:getNetID(), '`2All stages completed! Open /relic to claim your reward.', 0)
        markDirty()
        return
    end

    local completedStage = monthData.stage
    monthData.stage = monthData.stage + 1
    monthData.progress = 0
    monthData.stageTarget = 0
    assignStageObjective(monthData, campaign, nil)

    player:onTalkBubble(
        player:getNetID(),
        string.format(
        '`2Stage %d completed! Stage %d: %s.',
        completedStage,
        monthData.stage,
        getQuestObjectiveText(monthData.questType, monthData.stageTarget)
        ),
        0
    )

    player:onConsoleMessage(
        string.format(
        '`w%s `ohas completed Stage %d of the `$%s Quest Expedition`o!',
        player.getCleanName and player:getCleanName() or player:getName(),
        completedStage,
        getCampaignRewardTitle(campaign),
        getQuestObjectiveText(monthData.questType, monthData.stageTarget)
        )
    )

    markDirty()
    end

    local function submitGemDelivery(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)
    if not campaign then
        return
    end

    local record = ensurePlayerRecord(player)
    local monthData = ensureMonthData(record, monthKey, campaign)

    if not monthData.opened or monthData.completed or monthData.questType ~= 'DELIVER_GEMS' then
        return
    end

    local targetCount = getCurrentStageTarget(monthData, campaign)
    local requiredGems = targetCount - math.max(0, math.floor(tonumber(monthData.progress) or 0))
    if requiredGems <= 0 then
        return
    end

    local currentGems = tonumber(player:getGems()) or 0
    if currentGems < requiredGems then
        player:onTalkBubble(player:getNetID(), '`4You do not have enough Gems to deliver.', 0)
        return
    end

    player:removeGems(requiredGems, 1, 1)
    progressQuest(player, 'DELIVER_GEMS', requiredGems)
    end

    local function claimRelicReward(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)

    if not campaign then
        player:onTalkBubble(player:getNetID(), '`4No relic quest campaign is available for this month.', 0)
        return
    end

    local record = ensurePlayerRecord(player)
    local monthData = ensureMonthData(record, monthKey, campaign)

    if not monthData.opened then
        player:onTalkBubble(player:getNetID(), '`4You have not started this month\'s relic quest yet.', 0)
        return
    end

    if not monthData.completed then
        player:onTalkBubble(player:getNetID(), '`4You have not completed all quest stages yet.', 0)
        return
    end

    local campaignIDKey = tostring(campaign.id)
    if record.claimedCampaigns[campaignIDKey] then
        player:onTalkBubble(player:getNetID(), '`4This campaign reward has already been claimed on your account.', 0)
        return
    end

    local gaveReward = player:changeItem(campaign.rewardItemID, campaign.rewardAmount, 0)
    if not gaveReward then
        gaveReward = player:changeItem(campaign.rewardItemID, campaign.rewardAmount, 1)
    end

    if not gaveReward then
        player:onTalkBubble(player:getNetID(), '`4Your inventory is full. Free up space and try claiming again.', 0)
        return
    end

    local rewardName = getItemName(campaign.rewardItemID)
    local rewardAmount = math.max(0, math.floor(tonumber(campaign.rewardAmount) or 0))
    local usedCount = tryAutoUseReward(player, campaign.rewardItemID, rewardAmount)
    local storedCount = rewardAmount - usedCount
    local isAutoUsed = usedCount > 0

    record.claimedCampaigns[campaignIDKey] = true
    monthData.claimed = true

    markDirty()
    saveRelicData(true)

    playRewardCelebration(player, campaign.rewardItemID, isAutoUsed)

    local announceRewardText = string.format('%dx %s', rewardAmount, rewardName)
    if isAutoUsed and storedCount > 0 then
        announceRewardText = string.format('%dx %s (`2%d auto-used`o, `3%d stored`o)', rewardAmount, rewardName, usedCount, storedCount)
    elseif isAutoUsed then
        announceRewardText = string.format('%dx %s (`2auto-used`o)', rewardAmount, rewardName)
    end
    broadcastQuestCompletion(player, campaign, announceRewardText)

    if isAutoUsed and storedCount > 0 then
        player:onTalkBubble(
        player:getNetID(),
        string.format('`2Reward claimed: %dx %s (`2%d auto-used`2, `3%d stored in inventory`2).', rewardAmount, rewardName, usedCount, storedCount),
        0
        )
    elseif isAutoUsed then
        player:onTalkBubble(
        player:getNetID(),
        string.format('`2Reward claimed and auto-used: %dx %s.', rewardAmount, rewardName),
        0
        )
    else
        player:onTalkBubble(
        player:getNetID(),
        string.format('`2Reward claimed: %dx %s added to inventory.', rewardAmount, rewardName),
        0
        )
    end
    end

    local function cancelQuest(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)
    if not campaign then return end

    local record = ensurePlayerRecord(player)
    local monthData = record.months[monthKey]
    if type(monthData) ~= 'table' or not monthData.opened then return end

    monthData.opened = false
    monthData.stage = 1
    monthData.progress = 0
    monthData.stageTarget = 0
    monthData.completed = false
    monthData.questType = nil

    markDirty()
    saveRelicData(true)

    player:onTalkBubble(player:getNetID(), '`4Quest cancelled. Gems are not refunded.', 0)
    end

    showRelicOpenConfirmPanel = function(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)

    if not campaign then
        player:onTalkBubble(player:getNetID(), '`4No relic quest campaign is available for this month.', 0)
        return
    end

    local dialog = {
        'set_default_color|`o',
        'add_label|big|`w⚠ Confirm Expedition``|left|',
        'add_spacer|small|',
        'add_textbox|`oYou are about to begin the `5' .. getCampaignRewardTitle(campaign) .. ' Quest Expedition``.|left|',
        'add_textbox|`oThis will cost `#' .. RELIC_OPEN_COST_GEMS .. ' Gems``. This fee is `4non-refundable``.|left|',
        'add_spacer|small|',
        'add_textbox|`8If you cancel later, all progress and Gems will be lost.``|left|',
        'add_spacer|small|',
        'add_button|confirm_open_relic|`2Yes, Begin Expedition!``|noflags|0|0|',
        'add_button|cancel_open_relic|`4Cancel``|noflags|0|0|',
        'add_quick_exit|',
        'end_dialog|' .. RELIC_OPEN_CONFIRM_DIALOG .. '||'
    }

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= RELIC_OPEN_CONFIRM_DIALOG then return end

        local button = data['buttonClicked']
        if button == 'confirm_open_relic' then
        openMonthlyQuest(p)
        showRelicMainPanel(p)
        return true
        end

        if button == 'cancel_open_relic' then
        showRelicMainPanel(p)
        return true
        end

        return true
    end)
    end

    showRelicMainPanel = function(player)
    local monthKey = getCurrentMonthKey()
    local campaign = getCampaignForMonth(monthKey)
    local record = ensurePlayerRecord(player)
    local monthData = ensureMonthData(record, monthKey, campaign)
    local panelTitle = campaign and (getCampaignRewardTitle(campaign) .. ' Quest Expedition') or 'Relic Quest Expedition'
    local panelIcon = campaign and campaign.rewardItemID or 6016

    local dialog = {
        'set_default_color|`o',
        'add_label_with_icon|big|' .. panelTitle .. '|left|' .. tostring(panelIcon) .. '|',
        'add_smalltext|`wTime Remaining: `o' .. getMonthlyResetLabel() .. '|',
        'add_spacer|small|'
    }

    if not campaign then
        dialog[#dialog + 1] = 'add_smalltext|`4No active relic campaign for this month.|'
    else
        dialog[#dialog + 1] = 'add_textbox|`o' .. getCampaignRewardDescription(campaign) .. '|left|'
        dialog[#dialog + 1] = 'add_smalltext|`wReward: `o' .. campaign.rewardAmount .. 'x ' .. getItemName(campaign.rewardItemID) .. ' (`wID ' .. campaign.rewardItemID .. '`o)|'
        dialog[#dialog + 1] = 'add_spacer|small|'

        if not monthData.opened then
        dialog[#dialog + 1] = 'add_smalltext|`4You have not started this month\'s relic quest.|'
        dialog[#dialog + 1] = 'add_smalltext|`wStart cost: `4' .. RELIC_OPEN_COST_GEMS .. ' Gems|'
        dialog[#dialog + 1] = 'add_button|open_monthly_quest|Start This Month\'s Quest|noflags|0|0|'
        else
        local stageLine, progressCurrent, progressMax = questStatusLines(monthData, campaign)
        local stageCurrent = math.max(1, math.floor(tonumber(monthData.stage) or 1))
        local stageMax = math.max(1, math.floor(tonumber(campaign.totalStages) or 1))
        if stageCurrent > stageMax then
            stageCurrent = stageMax
        end

        dialog[#dialog + 1] = 'add_progress_bar|Objective|big|`wStage:|' .. stageCurrent .. '|' .. stageMax .. '|`o' .. stageCurrent .. '/' .. stageMax .. '|'
        dialog[#dialog + 1] = 'add_progress_bar|Quest|big|' .. getQuestObjectiveText(monthData.questType, getCurrentStageTarget(monthData, campaign)) .. '|' .. progressCurrent .. '|' .. progressMax .. '|`o' .. progressCurrent .. '/' .. progressMax .. '|'

        if monthData.completed then
            if monthData.claimed then
            dialog[#dialog + 1] = 'add_smalltext|`2Status: Reward already claimed (one time per account).|'
            else
            dialog[#dialog + 1] = 'add_button|claim_reward|Claim Reward|noflags|0|0|'
            end
        else
            dialog[#dialog + 1] = 'add_spacer|small|'

            if monthData.questType == 'DELIVER_GEMS' then
            dialog[#dialog + 1] = 'add_button|submit_delivery_gems|Deliver Gems For This Stage|noflags|0|0|'
            end

            dialog[#dialog + 1] = 'add_button|cancel_quest_btn|`4Give up Challange``|noflags|0|0|'
        end
        end
    end

    if player:hasRole(ROLE_DEVELOPER) then
        dialog[#dialog + 1] = 'add_spacer|small|'
        dialog[#dialog + 1] = 'add_button|open_admin_panel|Open Admin Panel|noflags|0|0|'
    end

    dialog[#dialog + 1] = 'add_quick_exit|'
    dialog[#dialog + 1] = 'end_dialog|' .. RELIC_MAIN_DIALOG .. '||'

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= RELIC_MAIN_DIALOG then return end

        local button = data['buttonClicked']
        if button == 'open_monthly_quest' then
        showRelicOpenConfirmPanel(p)
        return true
        end

        if button == 'submit_delivery_gems' then
        submitGemDelivery(p)
        showRelicMainPanel(p)
        return true
        end

        if button == 'claim_reward' then
        claimRelicReward(p)
        showRelicMainPanel(p)
        return true
        end

        if button == 'cancel_quest_btn' then
        showRelicCancelConfirmPanel(p)
        return true
        end

        if button == 'open_admin_panel' and p:hasRole(ROLE_DEVELOPER) then
        showRelicAdminPanel(p)
        return true
        end

        return true
    end)
    end

    showRelicAdminPanel = function(player)
    local currentMonth = getCurrentMonthKey()
    local currentYear = yearFromMonthKey(currentMonth)
    local page = getAdminYearPage(player)
    local viewYear = currentYear + page

    local dialog = {
        'set_default_color|`o',
        'set_bg_color|0,0,0,150|',
        'add_label_with_icon|big|Relic Admin Panel|left|6016|',
        'add_smalltext|`wDeveloper-only access.|',
        'add_smalltext|`wTotal campaigns stored: `o' .. countMonthlyCampaigns() .. '|',
        'add_smalltext|`wViewing year: `o' .. tostring(viewYear) .. '|',
        'add_spacer|small|'
    }

    for month = 1, 12 do
        local monthKey = monthKeyFromYearMonth(viewYear, month)
        local campaign = getCampaignForMonth(monthKey)

        if campaign then
        local title = getCampaignRewardTitle(campaign)
        local questSummary = getEnabledQuestSummary(campaign.questConfigs)
        dialog[#dialog + 1] = 'add_smalltext|`w' .. monthLabel(monthKey) .. ' `o- ' .. title .. ', Reward ' .. campaign.rewardAmount .. 'x ' .. getItemName(campaign.rewardItemID) .. ', Stages ' .. campaign.totalStages .. ', Quests ' .. questSummary .. '|'
        else
        dialog[#dialog + 1] = 'add_smalltext|`w' .. monthLabel(monthKey) .. ' `o- No campaign configured.|'
        end

        dialog[#dialog + 1] = 'add_button|edit_month_' .. tostring(viewYear) .. '_' .. string.format('%02d', month) .. '|Edit ' .. monthLabel(monthKey) .. '|noflags|0|0|'
        dialog[#dialog + 1] = 'add_spacer|small|'
    end

    dialog[#dialog + 1] = 'add_button|admin_prev_year|Prev Year|noflags|0|0|'
    dialog[#dialog + 1] = 'add_button|admin_next_year|Next Year|noflags|0|0|'
    dialog[#dialog + 1] = 'add_button|back_to_relic|Back|noflags|0|0|'
    dialog[#dialog + 1] = 'add_quick_exit|'
    dialog[#dialog + 1] = 'end_dialog|' .. RELIC_ADMIN_DIALOG .. '||'

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= RELIC_ADMIN_DIALOG then return end

        local button = data['buttonClicked']
        if button == 'admin_prev_year' then
        setAdminYearPage(p, getAdminYearPage(p) - 1)
        showRelicAdminPanel(p)
        return true
        end

        if button == 'admin_next_year' then
        setAdminYearPage(p, getAdminYearPage(p) + 1)
        showRelicAdminPanel(p)
        return true
        end

        if button == 'back_to_relic' then
        showRelicMainPanel(p)
        return true
        end

        local yearText, monthText = button:match('^edit_month_(%d%d%d%d)_(%d%d)$')
        if yearText and monthText then
        local monthKey = monthKeyFromYearMonth(tonumber(yearText), tonumber(monthText))
        local campaign = getCampaignForMonth(monthKey)
        setAdminDraft(p, monthKey, campaign)
        showRelicAdminBuilderPanel(p)
        return true
        end

        return true
    end)
    end

    showRelicAdminTypeConfigPanel = function(player, questType)
    if not QUEST_LABEL[questType] then
        showRelicAdminBuilderPanel(player)
        return
    end

    local draft = getAdminDraft(player)
    local draftQuestConfig = ensureDraftQuestConfig(draft, questType)
    local dialogName = RELIC_ADMIN_TYPE_DIALOG_PREFIX .. questType

    local dialog = {
        'set_default_color|`o',
        'set_bg_color|0,0,0,150|',
        'add_label_with_icon|big|' .. (QUEST_LABEL[questType] or questType) .. ' Quest Config|left|6016|',
        'add_smalltext|`wMonth: `o' .. monthLabel(draft.monthKey) .. '|',
        'add_smalltext|`wStatus: `o' .. (draftQuestConfig.enabled and 'Enabled' or 'Disabled') .. '|',
        'add_spacer|small|',
        'add_textbox|`oFill only minimum or maximum with the same value if you want an exact target. Example: 2 means this stage will always need 2.``|left|',
        'add_spacer|small|',
        'add_text_input|quest_min_target|Minimum Target|' .. tostring(draftQuestConfig.minTarget or '') .. '|8|',
        'add_text_input|quest_max_target|Maximum Target|' .. tostring(draftQuestConfig.maxTarget or '') .. '|8|',
        'add_spacer|small|',
        'add_button|toggle_type_enabled|' .. (draftQuestConfig.enabled and '`4Disable Quest Type' or '`2Enable Quest Type') .. '|noflags|0|0|',
        'add_button|save_type_config|Save Quest Type Config|noflags|0|0|',
        'add_button|type_back|Back|noflags|0|0|',
        'add_quick_exit|',
        'end_dialog|' .. dialogName .. '||'
    }

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= dialogName then return end

        local localDraft = getAdminDraft(p)
        local localQuestConfig = ensureDraftQuestConfig(localDraft, questType)
        updateDraftQuestConfigFromDialogData(localQuestConfig, data)

        local button = data['buttonClicked']
        if button == 'toggle_type_enabled' then
        localQuestConfig.enabled = not localQuestConfig.enabled
        showRelicAdminTypeConfigPanel(p, questType)
        return true
        end

        if button == 'save_type_config' then
        local _, _, errorText = parseDraftQuestRange(localQuestConfig, questType)
        if errorText then
            p:onTalkBubble(p:getNetID(), errorText, 0)
            showRelicAdminTypeConfigPanel(p, questType)
            return true
        end

        showRelicAdminBuilderPanel(p)
        return true
        end

        if button == 'type_back' then
        showRelicAdminBuilderPanel(p)
        return true
        end

        return true
    end)
    end

    showRelicAdminBuilderPanel = function(player)
    local draft = getAdminDraft(player)

    local dialog = {
        'set_default_color|`o',
        'set_bg_color|0,0,0,150|',
        'add_label_with_icon|big|Relic Campaign Editor|left|6016|',
        'add_smalltext|`wEditing month: `o' .. monthLabel(draft.monthKey) .. '|',
        'add_smalltext|`wSet reward presentation and quest stage pool for this month.|',
        'add_spacer|small|',
        'add_text_input|reward_item_id|Reward Item ID|' .. tostring(draft.rewardItemID or '') .. '|10|',
        'add_text_input|reward_item_title|Reward Item Title|' .. tostring(draft.rewardItemTitle or '') .. '|40|',
        'add_text_input|reward_item_description|Reward Item Description|' .. tostring(draft.rewardItemDescription or '') .. '|2000|',
        'add_text_input|reward_amount|Reward Amount|' .. tostring(draft.rewardAmount or '') .. '|6|',
        'add_text_input|quest_total|Total Stages (example 10)|' .. tostring(draft.questTotal or '') .. '|4|',
        'add_spacer|small|',
        'add_smalltext|`wQuest Type Rules|',
        'add_button|config_BREAK|' .. getDraftQuestSummary(draft, 'BREAK') .. '|noflags|0|0|',
        'add_button|config_PUT|' .. getDraftQuestSummary(draft, 'PUT') .. '|noflags|0|0|',
        'add_button|config_PLANT|' .. getDraftQuestSummary(draft, 'PLANT') .. '|noflags|0|0|',
        'add_button|config_HARVEST|' .. getDraftQuestSummary(draft, 'HARVEST') .. '|noflags|0|0|',
        'add_button|config_EARN_GEMS|' .. getDraftQuestSummary(draft, 'EARN_GEMS') .. '|noflags|0|0|',
        'add_button|config_EARN_XP|' .. getDraftQuestSummary(draft, 'EARN_XP') .. '|noflags|0|0|',
        'add_button|config_DELIVER_GEMS|' .. getDraftQuestSummary(draft, 'DELIVER_GEMS') .. '|noflags|0|0|',
        'add_button|config_FINISH_SURGERY|' .. getDraftQuestSummary(draft, 'FINISH_SURGERY') .. '|noflags|0|0|',
        'add_button|config_FINISH_CRIME|' .. getDraftQuestSummary(draft, 'FINISH_CRIME') .. '|noflags|0|0|',
        'add_button|config_FINISH_GEIGER|' .. getDraftQuestSummary(draft, 'FINISH_GEIGER') .. '|noflags|0|0|',
        'add_button|config_FINISH_WOLF|' .. getDraftQuestSummary(draft, 'FINISH_WOLF') .. '|noflags|0|0|',
        'add_spacer|small|',
        'add_button|create_campaign|Save Campaign|noflags|0|0|',
        'add_button|builder_back|Back|noflags|0|0|',
        'add_quick_exit|',
        'end_dialog|' .. RELIC_ADMIN_BUILDER_DIALOG .. '||'
    }

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= RELIC_ADMIN_BUILDER_DIALOG then return end

        local localDraft = getAdminDraft(p)
        updateDraftFromDialogData(localDraft, data)

        local button = data['buttonClicked']
        local questType = button:match('^config_(.+)$')
        if questType and QUEST_LABEL[questType] then
        showRelicAdminTypeConfigPanel(p, questType)
        return true
        end

        if button == 'create_campaign' then
        if createCampaignFromDraft(p, localDraft) then
            showRelicAdminPanel(p)
        else
            showRelicAdminBuilderPanel(p)
        end
        return true
        end

        if button == 'builder_back' then
        showRelicAdminPanel(p)
        return true
        end

        return true
    end)
    end

    showRelicCancelConfirmPanel = function(player)
    local dialog = {
        'set_default_color|`o',
        'add_label|big|Give up Challenge``|left|',
        'add_spacer|small|',
        'add_textbox|`oAre you sure you want to give up this month\'s relic challenge?``|left|',
        'add_spacer|small|',
        'add_textbox|`8Your progress will be lost and `4Gems will not be refunded``.``|left|',
        'add_spacer|small|',
        'add_button|confirm_cancel_quest|`4Yes, Give up Quest``|noflags|0|0|',
        'add_button|back_from_cancel|`2No, Continue Quest``|noflags|0|0|',
        'add_quick_exit|',
        'end_dialog|' .. RELIC_CANCEL_CONFIRM_DIALOG .. '||'
    }

    player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
        if data['dialog_name'] ~= RELIC_CANCEL_CONFIRM_DIALOG then return end

        local button = data['buttonClicked']
        if button == 'confirm_cancel_quest' then
        cancelQuest(p)
        showRelicMainPanel(p)
        return true
        end

        if button == 'back_from_cancel' then
        showRelicMainPanel(p)
        return true
        end

        return true
    end)
    end

    onPlayerCommandCallback(function(world, player, fullCommand)
    local parts = {}
    for token in (fullCommand or ''):gmatch('%S+') do
        parts[#parts + 1] = token:lower()
    end

    if parts[1] ~= 'relic' and parts[1] ~= '/relic' then
        return false
    end

    if parts[2] == 'admin' then
        if not player:hasRole(ROLE_DEVELOPER) then
        player:onTalkBubble(player:getNetID(), '`4Access denied. ROLE_DEVELOPER only.', 0)
        return true
        end

        showRelicAdminPanel(player)
        return true
    end

    showRelicMainPanel(player)
    return true
    end)

    onTileBreakCallback(function(world, player, tile)
    progressQuest(player, 'BREAK', 1)
    end)

    onTilePlaceCallback(function(world, player, tile)
    progressQuest(player, 'PUT', 1)
    end)

    onPlayerPlantCallback(function(world, player, tile)
    progressQuest(player, 'PLANT', 1)
    end)

    onPlayerHarvestCallback(function(world, player, tile)
    progressQuest(player, 'HARVEST', 1)
    end)

    onPlayerGemsObtainedCallback(function(world, player, amount)
    local gain = math.max(0, math.floor(tonumber(amount) or 0))
    if gain > 0 then
        progressQuest(player, 'EARN_GEMS', gain)
    end
    end)

    onPlayerXPCallback(function(world, player, amount)
    local gain = math.max(0, math.floor(tonumber(amount) or 0))
    if gain > 0 then
        progressQuest(player, 'EARN_XP', gain)
    end
    end)

    onPlayerSurgeryCallback(function(world, player, rewardID, rewardCount, targetPlayer)
    progressQuest(player, 'FINISH_SURGERY', 1)
    end)

    onPlayerCrimeCallback(function(world, player, itemID, itemCount)
    progressQuest(player, 'FINISH_CRIME', 1)
    end)

    onPlayerGeigerCallback(function(world, player, itemID, itemCount)
    progressQuest(player, 'FINISH_GEIGER', 1)
    end)

    onPlayerActivateTileCallback(function(world, player, tile)
    if tile:getTileID() == WOLF_TOTEM_ID then
        progressQuest(player, 'FINISH_WOLF', 1)
    end
    return false
    end)

    onAutoSaveRequest(function()
    saveRelicData(false)
    end)