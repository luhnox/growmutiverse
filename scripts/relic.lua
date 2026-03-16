print('(relic-system) for GTPS Cloud | by Copilot')

local ROLE_DEVELOPER = 51
local RELIC_DATA_KEY = 'relic_system_v1'
local RELIC_OPEN_COST_GEMS = 100000

local RELIC_MAIN_DIALOG = 'relic_main_panel'
local RELIC_OPEN_CONFIRM_DIALOG = 'relic_open_confirm_panel'
local RELIC_ADMIN_DIALOG = 'relic_admin_panel'
local RELIC_ADMIN_BUILDER_DIALOG = 'relic_admin_builder_panel'
local RELIC_CANCEL_CONFIRM_DIALOG = 'relic_cancel_confirm_panel'

local QUEST_TYPES = { 'BREAK', 'PUT', 'PLANT', 'HARVEST' }
local QUEST_LABEL = {
  BREAK = 'Break',
  PUT = 'Put',
  PLANT = 'Plant',
  HARVEST = 'Harvest'
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
  if type(raw) ~= 'string' then return nil end

  local year, month = raw:match('^(%d%d%d%d)%-(%d%d)$')
  if not year or not month then return nil end

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

  local y, m = monthKey:match('^(%d%d%d%d)%-(%d%d)$')
  if not y or not m then return monthKey end
  return m .. '/' .. y
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

local loadedRelicDB = loadDataFromServer(RELIC_DATA_KEY)
local relicDB = {
  players = {},
  monthlyCampaigns = {},
  lastCampaignID = 0
}

local function sanitizeCampaign(rawCampaign, fallbackMonthKey)
  if type(rawCampaign) ~= 'table' then
    return nil
  end

  local monthKey = normalizeMonthKey(rawCampaign.monthKey)
  if not monthKey then
    monthKey = normalizeMonthKey(fallbackMonthKey) or getCurrentMonthKey()
  end

  local enabledTypes = {}
  local enabledCount = 0

  if type(rawCampaign.enabledTypes) == 'table' then
    for i = 1, #QUEST_TYPES do
      local questType = QUEST_TYPES[i]
      if rawCampaign.enabledTypes[questType] then
        enabledTypes[questType] = true
        enabledCount = enabledCount + 1
      end
    end
  end

  if enabledCount == 0 then
    enabledTypes.BREAK = true
  end

  local campaign = {
    id = math.floor(tonumber(rawCampaign.id) or 0),
    monthKey = monthKey,
    rewardItemID = math.floor(tonumber(rawCampaign.rewardItemID) or 0),
    rewardAmount = math.floor(tonumber(rawCampaign.rewardAmount) or 0),
    totalStages = math.floor(tonumber(rawCampaign.totalStages) or 0),
    targetCount = math.floor(tonumber(rawCampaign.targetCount) or 0),
    enabledTypes = enabledTypes,
    createdBy = tonumber(rawCampaign.createdBy) or 0,
    createdAt = tonumber(rawCampaign.createdAt) or 0
  }

  if campaign.rewardItemID <= 0 then return nil end
  if campaign.rewardAmount <= 0 then return nil end
  if campaign.totalStages <= 0 then return nil end
  if campaign.targetCount <= 0 then return nil end

  return campaign
end

local function boolVal(v)
  return v == true or v == 1
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
local showRelicCancelConfirmPanel

local function markDirty()
  dirty = true
end

local function saveRelicData(force)
  if force or dirty then
    saveDataToServer(RELIC_DATA_KEY, relicDB)
    dirty = false
  end
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

local function getEnabledTypeList(enabledTypes)
  local list = {}
  for i = 1, #QUEST_TYPES do
    local questType = QUEST_TYPES[i]
    if enabledTypes and enabledTypes[questType] then
      list[#list + 1] = questType
    end
  end
  return list
end

local function pickRandomQuestType(enabledTypes)
  local available = getEnabledTypeList(enabledTypes)
  if #available == 0 then return nil end
  return available[math.random(1, #available)]
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

local function ensureMonthData(record, monthKey, campaign)
  local monthData = record.months[monthKey]

  if type(monthData) ~= 'table' then
    monthData = {
      opened = false,
      campaignID = 0,
      stage = 1,
      progress = 0,
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
    monthData.completed = false
    monthData.claimed = false
    monthData.questType = nil
    markDirty()
  end

  if record.claimedCampaigns[tostring(campaign.id)] then
    monthData.opened = true
    monthData.completed = true
    monthData.claimed = true
    monthData.stage = campaign.totalStages
    monthData.progress = campaign.targetCount
    monthData.questType = monthData.questType or (pickRandomQuestType(campaign.enabledTypes) or 'BREAK')
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

local function questStatusLines(monthData, campaign)
  local currentProgress = math.max(0, math.floor(tonumber(monthData.progress) or 0))
  local bar, percent = buildProgressBar(currentProgress, campaign.targetCount, 12)

  local stageLine = string.format(
    'Stage %d/%d - %s',
    monthData.stage,
    campaign.totalStages,
    QUEST_LABEL[monthData.questType] or tostring(monthData.questType or '-'),
    campaign.targetCount
  )

  local progressLine = string.format('Progress ')
  local progressPercent = string.format('%d%%', percent)

  return stageLine, progressLine, progressPercent, currentProgress, campaign.targetCount, bar
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
end

local function broadcastQuestCompletion(player, campaign, rewardText)
  local playerName = player.getCleanName and player:getCleanName() or player:getName()
--   local monthText = monthLabel(campaign.monthKey or getCurrentMonthKey())
  local message = string.format('`5>> `w%s `5has completed the `#Relic Quest Expedition `5and claimed the legendary `w%s `5!\xE2\x9C\xA8 <<``', playerName, rewardText) --playerName, rewardText, monthText

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

  local gems = player:getGems()
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
  monthData.questType = pickRandomQuestType(campaign.enabledTypes) or 'BREAK'

  markDirty()
  saveRelicData(true)

  player:onTalkBubble(
    player:getNetID(),
    string.format('`2Relic quest %s started. Cost: %d Gems.', monthLabel(monthKey), RELIC_OPEN_COST_GEMS),
    0
  )
end

local function progressQuest(player, actionType)
  local monthKey = getCurrentMonthKey()
  local campaign = getCampaignForMonth(monthKey)
  if not campaign then return end

  local record = ensurePlayerRecord(player)
  local monthData = ensureMonthData(record, monthKey, campaign)

  if not monthData.opened or monthData.completed then return end
  if monthData.questType ~= actionType then return end

  monthData.progress = (monthData.progress or 0) + 1

  if monthData.progress < campaign.targetCount then
    markDirty()
    return
  end

  if monthData.stage >= campaign.totalStages then
    monthData.progress = campaign.targetCount
    monthData.completed = true
    player:onTalkBubble(player:getNetID(), '`2All stages completed! Open /relic to claim your reward.', 0)
    markDirty()
    return
  end

  local completedStage = monthData.stage
  monthData.stage = monthData.stage + 1
  monthData.progress = 0
  monthData.questType = pickRandomQuestType(campaign.enabledTypes) or monthData.questType

  player:onTalkBubble(
    player:getNetID(),
    string.format(
      '`2Stage %d completed! Stage %d: %s %d.',
      completedStage,
      monthData.stage,
      QUEST_LABEL[monthData.questType] or monthData.questType,
      campaign.targetCount
    ),
    0
  )

  markDirty()
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
  monthData.completed = false
  monthData.questType = nil

  markDirty()
  saveRelicData(true)

  player:onTalkBubble(player:getNetID(), '`4Quest cancelled. Gems are not refunded.', 0)
end

local function getAdminDraft(player)
  local uid = tostring(player:getUserID())
  local draft = adminDraftByUser[uid]

  if type(draft) ~= 'table' then
    draft = {
      monthKey = getCurrentMonthKey(),
      rewardItemID = '242',
      rewardAmount = '1',
      questTotal = '10',
      targetCount = '500',
      enabledTypes = {
        BREAK = true,
        PUT = true,
        PLANT = true,
        HARVEST = true
      }
    }
    adminDraftByUser[uid] = draft
  end

  return draft
end

local function updateDraftFromDialogData(draft, data)
  local monthKey = data['campaign_month']
  local rewardItemID = data['reward_item_id']
  local rewardAmount = data['reward_amount']
  local questTotal = data['quest_total']
  local targetCount = data['target_count']

  if monthKey and monthKey ~= '' then draft.monthKey = monthKey end
  if rewardItemID and rewardItemID ~= '' then draft.rewardItemID = rewardItemID end
  if rewardAmount and rewardAmount ~= '' then draft.rewardAmount = rewardAmount end
  if questTotal and questTotal ~= '' then draft.questTotal = questTotal end
  if targetCount and targetCount ~= '' then draft.targetCount = targetCount end
end

local function createCampaignFromDraft(player, draft)
  local monthKey = normalizeMonthKey(draft.monthKey)
  local rewardItemID = math.floor(tonumber(draft.rewardItemID) or 0)
  local rewardAmount = math.floor(tonumber(draft.rewardAmount) or 0)
  local questTotal = math.floor(tonumber(draft.questTotal) or 0)
  local targetCount = math.floor(tonumber(draft.targetCount) or 0)

  if not monthKey then
    player:onTalkBubble(player:getNetID(), '`4Month format must be YYYY-MM, for example: 2026-04', 0)
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

  if targetCount <= 0 then
    player:onTalkBubble(player:getNetID(), '`4Target per stage must be greater than 0.', 0)
    return false
  end

  local enabled = {}
  local enabledCount = 0
  for i = 1, #QUEST_TYPES do
    local questType = QUEST_TYPES[i]
    if draft.enabledTypes[questType] then
      enabled[questType] = true
      enabledCount = enabledCount + 1
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
    rewardAmount = rewardAmount,
    totalStages = questTotal,
    targetCount = targetCount,
    enabledTypes = enabled,
    createdBy = player:getUserID(),
    createdAt = os.time()
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

showRelicOpenConfirmPanel = function(player)
  local monthKey = getCurrentMonthKey()
  local campaign = getCampaignForMonth(monthKey)

  if not campaign then
    player:onTalkBubble(player:getNetID(), '`4No relic quest campaign is available for this month.', 0)
    return
  end

  local dialog = {
    'set_default_color|`o',
    'add_label|big|`w\xE2\x9A\xA0 Confirm Expedition``|left|',
    'add_spacer|small|',
    'add_textbox|`oYou are about to begin the `5Relic Quest Expedition``.|left|',
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

    return true
  end)
end

showRelicMainPanel = function(player)
  local monthKey = getCurrentMonthKey()
  local campaign = getCampaignForMonth(monthKey)
  local record = ensurePlayerRecord(player)
  local monthData = ensureMonthData(record, monthKey, campaign)

  local dialog = {
    'set_default_color|`o',
    'add_label_with_icon|big|Relic Quest Panel|left|6016|',
    'add_smalltext|`wActive Month: `o' .. monthLabel(monthKey) .. '|',
    'add_spacer|small|'
  }

  if not campaign then
    dialog[#dialog + 1] = 'add_smalltext|`4No active relic campaign for this month.|'
  else
    dialog[#dialog + 1] = 'add_smalltext|`wReward: `o' .. campaign.rewardAmount .. 'x ' .. getItemName(campaign.rewardItemID) .. ' (`wID ' .. campaign.rewardItemID .. '`o)|'
    dialog[#dialog + 1] = 'add_spacer|small|'

    if not monthData.opened then
      dialog[#dialog + 1] = 'add_smalltext|`4You have not started this month\'s relic quest.|'
      dialog[#dialog + 1] = 'add_smalltext|`wStart cost: `4' .. RELIC_OPEN_COST_GEMS .. ' Gems|'
      dialog[#dialog + 1] = 'add_button|open_monthly_quest|Start This Month\'s Quest|noflags|0|0|'
    else
      local stageLine, progressLine, progressPercent, progressCurrent, progressMax = questStatusLines(monthData, campaign)
      dialog[#dialog + 1] = 'add_progress_bar|`w' .. stageLine .. '|small|`w' .. progressLine .. '|' .. progressCurrent .. '|' .. progressMax .. '|`w' .. progressPercent ..'|`2|'

      if monthData.completed then
        if monthData.claimed then
          dialog[#dialog + 1] = 'add_smalltext|`2Status: Reward already claimed (one time per account).|'
        else
          dialog[#dialog + 1] = 'add_button|claim_reward|Claim Reward|noflags|0|0|'
        end
      else
        dialog[#dialog + 1] = 'add_spacer|small|'
        dialog[#dialog + 1] = 'add_button|cancel_quest_btn|`4Cancel Quest``|noflags|0|0|'
      end
    end
  end

  dialog[#dialog + 1] = 'add_spacer|small|'
  dialog[#dialog + 1] = 'add_button|refresh_panel|Refresh|noflags|0|0|'

  if player:hasRole(ROLE_DEVELOPER) then
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

    if button == 'refresh_panel' then
      showRelicMainPanel(p)
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
      local typeList = table.concat(getEnabledTypeList(campaign.enabledTypes), ', ')
      if typeList == '' then typeList = '-' end

      dialog[#dialog + 1] = 'add_smalltext|`w' .. monthLabel(monthKey) .. ' `o- Reward ' .. campaign.rewardAmount .. 'x ' .. getItemName(campaign.rewardItemID) .. ', Stages ' .. campaign.totalStages .. ', Target ' .. campaign.targetCount .. ', Types ' .. typeList .. '|'
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

    local y, m = button:match('^edit_month_(%d%d%d%d)_(%d%d)$')
    if y and m then
      local monthKey = monthKeyFromYearMonth(tonumber(y), tonumber(m))
      local draft = getAdminDraft(p)
      draft.monthKey = monthKey

      local campaign = getCampaignForMonth(monthKey)
      if campaign then
        draft.rewardItemID = tostring(campaign.rewardItemID)
        draft.rewardAmount = tostring(campaign.rewardAmount)
        draft.questTotal = tostring(campaign.totalStages)
        draft.targetCount = tostring(campaign.targetCount)
        draft.enabledTypes = {}

        for i = 1, #QUEST_TYPES do
          local questType = QUEST_TYPES[i]
          draft.enabledTypes[questType] = campaign.enabledTypes and campaign.enabledTypes[questType] == true or false
        end
      end

      showRelicAdminBuilderPanel(p)
      return true
    end

    return true
  end)
end

showRelicAdminBuilderPanel = function(player)
  local draft = getAdminDraft(player)

  local function toggleText(questType)
    return string.format('[%s] %s', draft.enabledTypes[questType] and 'ON' or 'OFF', questType)
  end

  local dialog = {
    'set_default_color|`o',
    'set_bg_color|0,0,0,150|',
    'add_label_with_icon|big|Relic Campaign Editor|left|6016|',
    'add_smalltext|`wSet month (YYYY-MM), reward, targets, and quest types.|',
    'add_spacer|small|',
    'add_text_input|campaign_month|Campaign Month (YYYY-MM)|' .. draft.monthKey .. '|7|',
    'add_text_input|reward_item_id|Reward Item ID|' .. draft.rewardItemID .. '|10|',
    'add_text_input|reward_amount|Reward Amount|' .. draft.rewardAmount .. '|6|',
    'add_text_input|quest_total|Total Stages (example 10)|' .. draft.questTotal .. '|4|',
    'add_text_input|target_count|Target per Stage (example 500)|' .. draft.targetCount .. '|8|',
    'add_spacer|small|',
    'add_button|toggle_break|' .. toggleText('BREAK') .. '|noflags|0|0|',
    'add_button|toggle_put|' .. toggleText('PUT') .. '|noflags|0|0|',
    'add_button|toggle_plant|' .. toggleText('PLANT') .. '|noflags|0|0|',
    'add_button|toggle_harvest|' .. toggleText('HARVEST') .. '|noflags|0|0|',
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
    if button == 'toggle_break' then
      localDraft.enabledTypes.BREAK = not localDraft.enabledTypes.BREAK
      showRelicAdminBuilderPanel(p)
      return true
    end

    if button == 'toggle_put' then
      localDraft.enabledTypes.PUT = not localDraft.enabledTypes.PUT
      showRelicAdminBuilderPanel(p)
      return true
    end

    if button == 'toggle_plant' then
      localDraft.enabledTypes.PLANT = not localDraft.enabledTypes.PLANT
      showRelicAdminBuilderPanel(p)
      return true
    end

    if button == 'toggle_harvest' then
      localDraft.enabledTypes.HARVEST = not localDraft.enabledTypes.HARVEST
      showRelicAdminBuilderPanel(p)
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
    'add_label|big|`w\xE2\x9A\xA0 Cancel Quest``|left|',
    'add_spacer|small|',
    'add_textbox|`oAre you sure you want to cancel this month\'s relic quest?``|left|',
    'add_spacer|small|',
    'add_textbox|`8Your progress will be lost and `4Gems will not be refunded``.``|left|',
    'add_spacer|small|',
    'add_button|confirm_cancel_quest|`4Yes, Cancel Quest``|noflags|0|0|',
    'add_button|back_from_cancel|`2No, Continue Quest``|noflags|0|0|',
    'add_quick_exit|',
    'end_dialog|' .. RELIC_CANCEL_CONFIRM_DIALOG .. '||'
  }

  player:onDialogRequest(table.concat(dialog, '\n'), 0, function(world, p, data)
    if data['dialog_name'] ~= RELIC_CANCEL_CONFIRM_DIALOG then return end

    local button = data['buttonClicked']
    if button == 'confirm_cancel_quest' then
      cancelQuest(p)
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

  if parts[1] ~= 'relic' then
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
  progressQuest(player, 'BREAK')
end)

onTilePlaceCallback(function(world, player, tile)
  progressQuest(player, 'PUT')
end)

onPlayerPlantCallback(function(world, player, tile)
  progressQuest(player, 'PLANT')
end)

onPlayerHarvestCallback(function(world, player, tile)
  progressQuest(player, 'HARVEST')
end)

onAutoSaveRequest(function()
  saveRelicData(false)
end)
