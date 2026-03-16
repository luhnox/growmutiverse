---@meta
--- GrowSoft / GTPS Cloud LuaScript API Definitions
--- IntelliSense only (NOT executed)
---
--- Primary documentation references:
--- https://docs.nperma.my.id/
--- https://docs.skoobz.dev/
---
--- This file is intentionally focused on practical IntelliSense coverage for
--- the documented runtime API surface used by GrowSoft / GTPS Cloud scripts.

-- =========================================================
-- DATA TYPES
-- =========================================================

---@class CommandData
---@field command string
---@field description string
---@field roleRequired? number

---@class EventData
---@field id number
---@field title string
---@field description string
---@field message string

---@class SidebarButton
---@field active boolean
---@field buttonAction string
---@field buttonTemplate string
---@field counter number
---@field counterMax number
---@field itemIdIcon number
---@field name string
---@field order number
---@field rcssClass string
---@field text string

---@class DialogAdvancedSyntax
---@field add_progress_bar string
---@field set_default_color string
---@field set_bg_color string
---@field set_border_color string
---@field add_label string
---@field add_label_with_icon string
---@field add_button string
---@field add_button_with_icon string
---@field add_small_font_button string
---@field add_smalltext string
---@field add_textbox string
---@field add_text_input string
---@field add_checkbox string
---@field add_spacer string
---@field add_quick_exit string
---@field add_item_picker string
---@field add_player_info string
---@field add_banner string
---@field add_big_banner string
---@field add_searchable_item_list string
---@field embed_data string
---@field end_dialog string
---@field disable_resize string
---@field community_hub_type string

DialogAdvancedSyntax = {
  set_default_color = 'set_default_color|color',
  set_bg_color = 'set_bg_color|r,g,b,a|',
  set_border_color = 'set_border_color|r,g,b,a|',
  add_label = 'add_label|size|message|alignment',
  add_label_with_icon = 'add_label_with_icon|size|message|alignment|iconID',
  add_button = 'add_button|name|label|flags|0|0',
  add_button_with_icon = 'add_button_with_icon|name|text|options|itemID|...|',
  add_small_font_button = 'add_small_font_button|name|label|flags|0|0',
  add_smalltext = 'add_smalltext|message|',
  add_textbox = 'add_textbox|message|',
  add_text_input = 'add_text_input|name|message|defaultInput|length',
  add_checkbox = 'add_checkbox|name|message|checked',
  add_spacer = 'add_spacer|size|',
  add_quick_exit = 'add_quick_exit|',
  add_item_picker = 'add_item_picker|name|message|placeholder|',
  add_player_info = 'add_player_info|name|level|exp|expRequired',
  add_banner = 'add_banner|imagePath|x|y|',
  add_big_banner = 'add_big_banner|imagePath|x|y|text|',
  add_searchable_item_list = 'add_searchable_item_list|data|options|searchFixedName',
  embed_data = 'embed_data|embed|data|',
  end_dialog = 'end_dialog|dialog_id|Close?|Ok?',
  disable_resize = 'disable_resize|',
  community_hub_type = 'community_hub_type|hubType|',
  --- Syntax: add_progress_bar|name|size|text|current|max|color|
  add_progress_bar = 'add_progress_bar|name|size|text|current|max|color|'
}

-- =========================================================
-- GLOBAL UTILITIES
-- =========================================================

---@class Json
---@field encode fun(value: any): string
---@field decode fun(text: string): any
json = {}

---@class Timer
---@field setInterval fun(interval: number, callback: fun()): any
---@field setTimeout fun(timeout: number, callback: fun()): any
---@field clear fun(id: any): any
timer = {}

---@class FileSystem
---@field exists fun(path: string): boolean
---@field read fun(path: string): string
---@field write fun(path: string, content: string): boolean
---@field delete fun(path: string): boolean
file = {}

---@class Directory
---@field exists fun(path: string): boolean
---@field create fun(path: string): boolean
---@field delete fun(path: string): boolean
dir = {}

---@class SQLDatabaseConnection
---@field query fun(self: SQLDatabaseConnection, sql: string, params?: any[]): any[]
---@field close fun(self: SQLDatabaseConnection)

---@class SQLDatabase
---@field open fun(dbPath: string): SQLDatabaseConnection
sqlite = {}

---@class Http
---@field get fun(url,headers)
---@field post fun(url,headers,postData)
http = {}

---@class Bit
---@field band fun(any)
---@field lshift fun(any)
bit = {}

-- =========================================================
-- ROLE
-- =========================================================

---@class Role
---@field roleID number
---@field rolePrice number
---@field roleName string
---@field roleItemID number
---@field textureName string
---@field textureXY string
---@field discordRoleID string
---@field roleDescription string
---@field namePrefix string
---@field chatPrefix string
---@field dailyRewardDiamondLocksCount number
---@field rolePriority number
---@field computedFlags number
---@field allowCommands string[]
---@field allowCommandsFromRoles number[]

-- =========================================================
-- ITEM
-- =========================================================

--- @class ItemEffect
--- @field item_id number
--- @field extra_gems number,
--- @field extra_xp number
--- @field one_hit 1|0
--- @field break_range number
--- @field build_range number

---@class Subscription
---@field getType fun(self: Subscription): number
---@field getExpireTime fun(self: Subscription): number
---@field getActivationTime fun(self: Subscription): number
---@field isPermanent fun(self: Subscription): boolean
---@field getNextRewardTime fun(self: Subscription): number
---@field setExpireTime fun(self: Subscription, timestamp: number)
---@field setNextRewardTime fun(self: Subscription, timestamp: number)

---@class TitleInfo
---@field titleID number
---@field titleName string
---@field titleLabel string
---@field titleDisplay string
---@field titleFlagItemID number
---@field isActive boolean

---@class BlessingInfo
---@field id number
---@field name string

---@class PlaymodInfo
---@field id number
---@field name string
---@field equipInfo string
---@field removeInfo string
---@field iconId number
---@field skinUint number

---@class InventoryItem
---@field itemID number
---@field count number

---@class LeaderboardEntry
---@field name string
---@field wins? number
---@field balance? number

---@class Item
---@field getName fun(self: Item): string
---@field getID fun(self: Item): number
---@field getRarity fun(self: Item): number
---@field getActionType fun(self: Item): number
---@field getGrowTime fun(self: Item): number
---@field setGrowTime fun(self: Item, seconds: number)
---@field setActionType fun(self: Item, type: number)
---@field setDescription fun(self: Item, text: string)
---@field getCategoryType fun(self: Item): number
---@field getEditableType fun(self: Item): number
---@field setCategoryType fun(self: Item, value: number)
---@field setEditableType fun(self: Item, value: number)
---@field setPrice fun(self: Item, price: number)
---@field isObtainable fun(self: Item): boolean
---@field getPricedRarity fun(self: Item): string
---@field getTexture fun(self: Item): string
---@field getTextureX fun(self: Item): number
---@field getTextureY fun(self: Item): number
---@field getEffect fun(self: Item): ItemEffect
---@field setEffect fun(self: Item, effect: ItemEffect)

-- =========================================================
-- TILE
-- =========================================================

---@class Tile
---@field getTileID fun(self: Tile): number
---@field getPosX fun(self: Tile): number
---@field getPosY fun(self: Tile): number
---@field getTileForeground fun(self: Tile): number
---@field getTileBackground fun(self: Tile): number
---@field getTileData fun(self: Tile, property: string): any
---@field setTileData fun(self: Tile, property: string, value: any)
---@field getTileItem fun(self: Tile): Item
---@field getFlags fun(self: Tile): any
---@field setFlags fun(self: Tile, flags: any)

-- =========================================================
-- DROP
-- =========================================================

---@class Drop
---@field getUID fun(self: Drop): number
---@field getItemID fun(self: Drop): number
---@field getPosX fun(self: Drop): number
---@field getPosY fun(self: Drop): number
---@field getItemCount fun(self: Drop): number
---@field getFlags fun(self: Drop): number

-- =========================================================
-- DiscordBot
-- =========================================================

---@class DiscordCommandData
---@field type 'number'|'string'|'float'|'boolean'|'user'|'channel'|'role'
---@field name string
---@field description string
---@field required boolean

---@class DiscordBot
---@field messageCreate fun(channel_id_string: string, message: string, components?: table|0, flags?: table|0, type?: any): nil
---@field messageEdit fun(message_id_string: string, channel_id_string: string, content: string, components?: table|0, flags?: table|0, type?: any): nil
---@field messageDelete fun(channel_id_string: string, message_id_string: string): nil
---@field directMessageCreate fun(user_id_string: string, message: string, components?: table|0, flags?: table|0, type?: any): nil
---@field globalCommandCreate fun(commandName: string, description: string, options?: DiscordCommandData[]): nil
---@field guildMemberAddRole fun(guild_id_string: string, user_id_string: string, role_id_string: string): nil
---@field guildMemberRemoveRole fun(guild_id_string: string, user_id_string: string, role_id_string: string): nil
---@field guildMemberSetNickname fun(guild_id_string: string, user_id_string: string, nickname: string): nil
DiscordBot = {}

-- =========================================================
-- PLAYER & NPC
-- =========================================================

---@class Autofarm
---@field getSlots fun(self: Autofarm): number
---@field setSlots fun(self: Autofarm, value:number)
---@field getTargetBlockID fun(self: Autofarm): number
---@field setTargetBlockID fun(self: Autofarm, blockID: number)

---@class Player
---@field getBlockPosX fun(self: Player): number --- tile position
---@field getBlockPosY fun(self: Player): number --- tile position
---@field enterWorld fun(self: Player, worldName: string, worldIDdoor: string,notification: number)
---@field getWorld fun(self: Player): World
---@field getRole fun(self: Player): Role
---@field getBankBalance fun(self: Player): number
---@field setBankBalance fun(self: Player, value: number)
---@field onConsoleMessage fun(self: Player, text: string|number)
---@field onTalkBubble fun(self: Player, netID: number, text: string, condition: number)
---@field getName fun(self: Player): string
---@field getIP fun(self: Player): string
---@field getRID fun(self: Player): number
---@field getUserID fun(self: Player): number
---@field getNetID fun(self: Player): number
---@field sendVariant fun(self: Player, variants: any[], delay?: number, netID?: number)
---@field onDialogRequest fun(self: Player, dialog: string, delay?: number, callback?: fun(world: World, player: Player, data: string[]): boolean|nil)
---@field hasRole fun(self: Player, roleID: number): boolean
---@field hasActiveBlessing fun(self: Player): boolean
---@field addBlessing fun(self: Player, name: string)
---@field getPosX fun(self: Player): number
---@field getPosY fun(self: Player): number
---@field getItemAmount fun(self: Player, itemID: number): number
---@field changeItem fun(self: Player, itemID: number, amount: number, toBackpack: number): boolean
---@field playAudio fun(self: Player, filePath: string,delay?: number)
---@field onParticleEffect fun(self: Player, particleID: number,tileX:number,tileY:number,none1:number,none2:number,none3:number)
---@field addBankBalance fun(self: Player, amount:number)
---@field isOnline fun(self: Player): boolean
---@field enterWorld fun(self: Player, worldName: string,worldIDdoor: string)
---@field getLevel fun(self: Player): number
---@field addLevel fun(self: Player, amount: number)
---@field removeLevel fun(self: Player, amount: number)
---@field setLevel fun(self: Player, level: number)
---@field setXP fun(self: Player, amount: number)
---@field removeXP fun(self: Player, amount: number)
---@field getGems fun(self: Player): number
---@field addGems fun(self: Player, amount: number, sendPacket?: boolean, isDisplay?: boolean)
---@field removeGems fun(self: Player, amount: number, sendPacket?: boolean, isDisplay?: boolean)
---@field setGems fun(self: Player, amount: number)
---@field getCoins fun(self: Player): number
---@field addCoins fun(self: Player, amount: number, sendPacket?: boolean)
---@field removeCoins fun(self: Player, amount: number, sendPacket?: boolean)
---@field setCoins fun(self: Player, amount: number)
---@field ban fun(self: Player, length_seconds: number, reason: string, banned_by_player?: Player, ban_device?: boolean, ban_ip?: boolean)
---@field disconnect fun(self: Player)
---@field sendAction fun(self: Player, actionString: string)
---@field doAction fun(self: Player, actionString: string)
---@field getCountry fun(self: Player): string
---@field setCountry fun(self: Player, countryCode: string)
---@field getPlatform fun(self: Player): string
---@field getInventoryItems fun(self: Player): Item[]
---@field getInventorySize fun(self: Player): number
---@field isMaxInventorySpace fun(self: Player): boolean
---@field upgradeInventorySpace fun(self: Player, amount: number)
---@field getFriends fun(self: Player): Player[]
---@field addFriend fun(self: Player, targetPlayer: Player)
---@field removeFriend fun(self: Player, targetPlayer: Player)
---@field getPlaytime fun(self: Player): number
---@field getOnlineStatus fun(self: Player): number
---@field removeBankBalance fun(self: Player, amount: number)
---@field getWorldName fun(self: Player): string
---@field onTextOverlay fun(self: Player, text: string)
---@field getCleanName fun(self: Player): string
---@field setRole fun(self: Player, roleID: number)
---@field getMod fun(self: Player, playModID: number)
---@field addMod fun(self: Player, modID: number, durationSeconds: number)
---@field removeMod fun(self: Player, modID: number)
---@field hasTitle fun(self: Player, id: number): boolean
---@field addTitle fun(self: Player, id: number)
---@field removeTitle fun(self: Player, id: number)
---@field getType fun(self: Player): number
---@field isFacingLeft fun(self: Player): boolean
---@field addMail fun(self: Player, mailDataTable: table)
---@field clearMailbox fun(self: Player)
---@field setNickname fun(self: Player, name: string)
---@field resetNickname fun(self: Player)
---@field getClothingItemID fun(self: Player, slot: number): number
---@field getBackpackUsedSize fun(self: Player): number
---@field setNextDialogRGBA fun(self: Player, r: number, g: number, b: number, a: number)
---@field setNextDialogBorderRGBA fun(self: Player, r: number, g: number, b: number, a: number)
---@field resetDialogColor fun(self: Player)
---@field setCountryFlagForeground fun(self: Player, itemID: number)
---@field getCountryFlagForeground fun(self: Player): number
---@field setCountryFlagBackground fun(self: Player, itemID: number)
---@field getCountryFlagBackground fun(self: Player): number
---@field getHomeWorldID fun(self: Player): number
---@field getGuildID fun(self: Player): number
---@field getDiscordID fun(self: Player): string
---@field getAccountCreationDateStr fun(self: Player): string
---@field getEmail fun(self: Player): string
---@field setPassword fun(self: Player, newPassword: string)
---@field checkPassword fun(self: Player, password: string): boolean
---@field getGender fun(self: Player): number
---@field hasBlessing fun(self: Player, blessingID: number): boolean
---@field removeBlessing fun(self: Player, blessingID: number)
---@field addFriend fun(self: Player, target: Player)
---@field removeFriend fun(self: Player, target: Player)
---@field getOwnedWorlds fun(self: Player): World[]
---@field getRecentWorlds fun(self: Player): number[]
---@field getAccessWorlds fun(self: Player): World[]
---@field getPing fun(self: Player): number
---@field getDungeonScrolls fun(self: Player): number
---@field setDungeonScrolls fun(self: Player, amount: number)
---@field setStats fun(self: Player, type: number, amount: number)
---@field hasGrowID fun(self: Player): boolean
---@field getXP fun(self: Player): number
---@field setCustomAutofarmDelay fun(self: Player, delayMS: number): nil
---@field hasMod fun(self: Player, playModID: number): nil
---@field updateStats fun(self: Player, world: World, StatsID: number, param3: number)
---@field getAutofarm fun(self: Player): Autofarm
---@field getStats fun(self: Player, Stats_type: number): number
---@field getRealName fun(self: Player): string
---@field getMiddlePosX fun(self: Player): number
---@field getMiddlePosY fun(self: Player): number
---@field getExpansiveInventoryEnabled fun(self: Player): boolean
---@field setExpansiveInventoryEnabled fun(self: Player, enabled: boolean)
---@field getClothes fun(self: Player, slot: number): number
---@field setClothes fun(self: Player, slot: number, itemID: number)
---@field getClothesColor fun(self: Player, slot: number): number
---@field setClothesColor fun(self: Player, slot: number, color: number)
---@field onTradeScanUI fun(self: Player)
---@field onGrow4GoodUI fun(self: Player)
---@field onGuildNotebookUI fun(self: Player)
---@field onGrowmojiUI fun(self: Player)
---@field onGrowpassUI fun(self: Player)
---@field onNotebookUI fun(self: Player)
---@field onBillboardUI fun(self: Player)
---@field onPersonalizeWrenchUI fun(self: Player)
---@field onOnlineStatusUI fun(self: Player)
---@field onFavItemsUI fun(self: Player)
---@field onCoinsBankUI fun(self: Player)
---@field onUnlinkDiscordUI fun(self: Player)
---@field onLinkDiscordUI fun(self: Player)
---@field onClothesUI fun(self: Player, targetPlayer?: Player)
---@field onAchievementsUI fun(self: Player, targetPlayer?: Player)
---@field onTitlesUI fun(self: Player, targetPlayer?: Player)
---@field onWrenchIconsUI fun(self: Player, targetPlayer?: Player)
---@field onNameIconsUI fun(self: Player, targetPlayer?: Player)
---@field onVouchersUI fun(self: Player)
---@field onMentorshipUI fun(self: Player)
---@field onBackpackUI fun(self: Player, targetPlayer?: Player)
---@field onStorePurchaseResult fun(self: Player)
---@field onRedeemMenu fun(self: Player)
---@field onGrow4GoodDonate fun(self: Player)
---@field getRealCleanName fun(self: Player): string
---@field lower fun(self: Player): string
---@field addRole fun(self: Player, roleID: number)
---@field removeRole fun(self: Player, roleID: number)
---@field getRoles fun(self: Player): Role[]
---@field getUnlockedAchievementsCount fun(self: Player): number
---@field getAchievementsCount fun(self: Player): number
---@field getGameVersion fun(self: Player): number
---@field setBubbleChatColor fun(self: Player, color: number)
---@field setBubbleStyle fun(self: Player, style: number)
---@field getRequiredXP fun(self: Player): number
---@field getLifeGoals fun(self: Player): table[]
---@field getBiweeklyQuests fun(self: Player): table[]
---@field getSubscription fun(self: Player, type: number): Subscription|nil
---@field addSubscription fun(self: Player, type: number, expireTimestamp: number): Subscription
---@field removeSubscription fun(self: Player, type: number)
---@field getTitles fun(self: Player): TitleInfo[]
---@field getActiveTitles fun(self: Player): TitleInfo[]
---@field getItemEffects fun(self: Player): ItemEffect
---@field getClassicProfileContent fun(self: Player, category: any, flags?: any): any
---@field addGrowpassPoints fun(self: Player, points: number)
---@field adjustBlockHitCount fun(self: Player, amount: number)
---@field getAdjustedBlockHitCount fun(self: Player): number
---@field setTotalPunchedBlocks fun(self: Player, count: number)
---@field getSmallLockedWorlds fun(self: Player): number[]
---@field getIPHistory fun(self: Player): string[]
---@field getRIDHistory fun(self: Player): string[]
---@field setAAPEnabled fun(self: Player, enabled: 0|1)
---@field setAAP fun(self: Player, enabled: boolean)
---@field setFlag fun(self: Player, flag: number, enabled: boolean)
---@field setGodMode fun(self: Player, enabled: boolean)
---@field setGuildName fun(self: Player, name: string)
---@field setBadge fun(self: Player, badgeID: number)
---@field getPlaymodStatus fun(self: Player): any
---@field setPlaymodStatus fun(self: Player, status: any)
---@field getOwnerRole fun(self: Player): number
---@field setOwnerRole fun(self: Player, roleID: number)
---@field getTransformProfileButtons fun(self: Player): table
---@field setEmail fun(self: Player, email: string)
---@field setAccountLevel fun(self: Player, level: number)
---@field addNote fun(self: Player, note: string)
---@field setBroadcastWorld fun(self: Player, worldName: string)

---@class NPC
---@return Player

-- =========================================================
-- WORLD
-- =========================================================

---@class punishmentType
---@field Ban number
---@field Mute number
punishmentType = {
  Ban = 1,
  Mute = 2,
}

---@class punishmentData
---@field invokerID number
---@field userID number
---@field reason string
---@field type punishmentType
---@field expires number
---@field IP number
punishmentData = {}

---@class World
---@field getName fun(self: World): string
---@field getID fun(self: World): number
---@field getTiles fun(self: World): Tile[]
---@field getWorldLock fun(self: World): Tile|nil
---@field getOwner fun(self: World): Player|nil
---@field getWorldType fun(self: World): string
---@field setOwner fun(self: World, userID: number)
---@field getDroppedItems fun(self: World): Drop[]
---@field getTileDroppedItems fun(self: World, tile: Tile): Drop[]
---@field getWorldSizeX fun(self: World): number
---@field getWorldSizeY fun(self: World): number
---@field getPlayers fun(self: World): Player[]
---@field hasFlag fun(self: World, id: number): boolean
---@field spawnItem fun(self: World, x: number, y: number, itemID: number, amount: number, condition?: 1|0): Drop
---@field removeDroppedItem fun(self: World, dropUID: number)
---@field updateClothing fun(self: World, player: Player|NPC)
---@field setClothing fun(self: World, target: Player|NPC, itemID: number)
---@field hasAccess fun(self: World, user: Player|NPC): boolean
---@field addAccess fun(self: World, user: Player|NPC, permission: 0|1)
---@field removeAccess fun(self: World, user: Player|NPC)
---@field hasTileAccess fun(self: World, user: Player|NPC, tile: Tile): boolean
---@field addTileAccess fun(self: World, user: Player|NPC, tile: Tile)
---@field removeTileAccess fun(self: World, user: Player|NPC, tile: Tile)
---@field createNPC fun(self: World, name: string, x: number, y: number)
---@field findNPCByName fun(self: World, npcName: string)
---@field removeNPC fun(self: World, npc: NPC)
---@field setPlayerCount fun(self: World, count: number)
---@field setLobbyWorld fun(self: World, lobbyWorldName: string)
---@field setTileForeground fun(self: World, tile: Tile, itemID: number, isVisual?: 1|0, player?: Player)
---@field setTileBackground fun(self: World, tile: Tile, itemID: number, isVisual?: 1|0, player?: Player)
---@field getTile fun(self: World, tileX: number, tileY: number): Tile
---@field useItemEffect fun(self: World, senderNetID: number, itemID: number, targetNetID: number, delay: number)
---@field setPlayerPosition fun(self: World, player: Player|NPC, posX: number, posY: number)---@field spawnGems fun(self: World, x: number, y: number, amount: number, player?: Player)
---@field kill fun(self: World, player: Player)
---@field punchTile fun(self: World, tile: Tile)
---@field updateTile fun(self: World, tile: Tile)
---@field getVisiblePlayersCount fun(self: World): number
---@field getPlayersCount fun(self: World, includeInvisible?: boolean): number
---@field getSizeX fun(self: World): number
---@field getSizeY fun(self: World): number
---@field setWeather fun(self: World, weatherID: number)
---@field isGameActive fun(self: World): boolean
---@field isGameActive fun(self: World, gameID: number): boolean
---@field new fun(self: World, name: string, sizeX: number, sizeY: number, worldType: string)
---@field newFromTemplate fun(self: World, name: string, templateFile: string)
---@field save fun(self: World)
---@field delete fun(self: World)
---@field removeOwner fun(self: World)
---@field removeAllTileAccess fun(self: World)
---@field spawnGems fun(self: World, x: number, y: number, amount: number, player?: Player)
---@field onCreateChatBubble fun(self: World, x: number, y: number, text: string, netID?: number)
---@field onCreateExplosion fun(self: World, x: number, y: number, radius: number, power: number)
---@field getPlatformByNetID fun(self: World, netID: number): any
---@field removeAllObjects fun(self: World)
---@field addXP fun(self: World, player: Player, amount: number)
---@field adjustGems fun(self: World, player: Player, tile: Tile, gemCount: number, value: number)
---@field onLoot fun(self: World, player: Player, tile: Tile, gemCount: number)
---@field getTilesByActionType fun(self: World, actionType: number): Tile[]
---@field onGameWinHighestScore fun(self: World)
---@field sendPlayerMessage fun(self: World, player: Player, message: string)
---@field redeemCode fun(self: World, player: Player, code: string)
---@field getMagplantRemoteTile fun(self: World, player: Player): Tile|nil
---@field useConsumable fun(self: World, player: Player,tile: Tile, itemID: number, condition?: 1|0): boolean
---@field findPathByTile fun(start_tile: Tile, end_tile: Tile, DistanceX: number, DistanceY: number): {x:number,y:number}[]|nil
---@field addPunishment fun(self: World, player: Player, type: punishmentType, length_seconds: number, reason: string, punish_by_userID: number)
---@field getAllPunishments fun(self: World): punishmentData[]
---@field removePunishment fun(self: World,player: Player, punishmentID: punishmentType)
---@field clearPunishment fun(self: World, player: Player, punishmentID: punishmentType)
---@field getPunishment fun(self: World,player: Player, punishmentID: punishmentType): punishmentData|nil
---@field spawnGhost fun(self: World, tile: Tile, ghostType: number, userID_spawner: number, despawnIn: number,m_speed: number)
---@field getCurseThemeByNetID fun(self: World, netID: number): number|nil
---@field setCurseTheme fun(self: World, netID: number, themeID: number)
---@field getLeaderboard fun(self: World, type: number): LeaderboardEntry[]
---@field getLeaderboardByWins fun(self: World): LeaderboardEntry[]
---@field getLeaderboardByBalance fun(self: World): LeaderboardEntry[]
---@field addWorldMenuButtonCallback fun(self: World, text: string, id: string)

-- =========================================================
-- GLOBAL FUNCTIONS
-- =========================================================

---@param commandData CommandData
function registerLuaCommand(commandData) end

--- @return number
function getCurrentServerDailyEvent() end

--- @return number
function getRequiredEvent() end

--- @return number
function getCurrentServerEvent() end

---@param worldID number
---@return World
function getWorld(worldID) end

---@param playerID number
---@return Player
function getPlayer(playerID) end

---@param itemID number
---@return Item
function getItem(itemID) end

---@return Item
function getIOTMItem() end

--- @param value number
function setGemEvent(value) end

--- @param value number
function setXPEvent(value) end

--- @return number
function getGemEvent() end

--- @return number
function getXPEvent() end

---@return Role
function getHighestPriorityRole() end

---@return table[]
function getEvents() end

---@return table[]
function getDailyEvents() end

---@param object {modID: number,modName: string, onAddMessage: string, onRemoveMessage: string, iconID: number, changeSkin: table,modState: table}
function registerLuaPlaymod(object) end

---@return Role[]
function getRoles() end

---@param eventData EventData
function registerLuaEvent(eventData) end

---@param eventData EventData
function registerLuaDailyEvent(eventData) end

---@return number
function getCurrentServerEvent() end

---@param sidebarJson string
function addSidebarButton(sidebarJson) end

---@param text string
function parseText(text) end

---@param user_id number
function deleteAccount(user_id) end

---@param world_id number
function deleteWorld(world_id) end

---@param event_id any
function setEvent(event_id) end

---@param event_id any
function setDailyEvent(event_id) end

---@param in_seconds number
---@param full_restart 1|0
---@param message string
function queueRestart(in_seconds, full_restart, message) end

--- @return World[]
function getActiveWorlds() end

---@return World[]
function getServerWorlds() end

--- @param worldName string
--- @return World
function getWorldByName(worldName) end

--- @param worldName string
function setBroadcastWorld(worldName) end

---@param userID number
---@param itemID number
function addDailyOfferPurchased(userID, itemID) end

---@return table[]
function getEventOffers() end

---@return table[]
function getActiveDailyOffers() end

---@return number
function getRealGTItemsCount() end

---@param redeemData table
---@return string
function createRedeemCode(redeemData) end

---@return any
function getTopPlayerByBalance() end

---@return any
function getTopWorldByVisitors() end

---@return PlaymodInfo[]
function getPlaymods() end

---@param player Player
function savePlayer(player) end

---@param world World
function saveWorld(world) end

---@param rid string
---@return Player|nil
function getPlayerByRID(rid) end

---@return TitleInfo[]
function getTitles() end

---@return BlessingInfo[]
function blessingGetAll() end

---@param blessingID number
---@return Player[]
function blessingGetPlayersByBlessingID(blessingID) end

---@param player Player
---@param blessingID number
---@param duration number
function blessingGivePlayerBlessing(player, blessingID, duration) end

---@return number
function getRoleQuestDay() end

---@return number
function getExpireTime() end

---@return number
function getServerTime() end

---@return string
function getNewsBanner() end

---@return number, number
function getNewsBannerDimensions() end

---@return string
function getTodaysDate() end

---@return table[]
function getTodaysEvents() end

---@return string
function getCurrentEventDescription() end

---@return string
function getCurrentDailyEventDescription() end

---@return string
function getCurrentRoleDayDescription() end

---@param count number
function setMaxPlayers(count) end

---@return table
function getJimDailyQuest() end

---@param buttonDef string|table
---@param callback fun(player: Player): boolean|nil
function addSocialPortalButton(buttonDef, callback) end

---@param worldID number
---@param displayName string
---@param color string|number
---@param priority number
function addWorldMenuWorld(worldID, displayName, color, priority) end

---@param worldID number
function removeWorldMenuWorld(worldID) end

---@param hidden 0|1
function hideWorldMenuDefaultSpecialWorlds(hidden) end

---@param text string
---@param id string
function registerWorldMenuButton(text, id) end

---@param id string
function unregisterWorldMenuButton(id) end

---@return table[]
function storeGetAllStores() end

---@param storeID number
---@return table|nil
function storeGetStore(storeID) end

---@param storeID number
---@param userID number
function storeAddOwner(storeID, userID) end

---@param storeID number
---@param userID number
function storeRemoveOwner(storeID, userID) end

---@param storeID number
---@param name string
function storeSetName(storeID, name) end

---@param storeID number
---@param seconds number
function storeSetDuration(storeID, seconds) end

---@param storeID number
function storeDestroy(storeID) end

---@param player Player
---@param item any
---@param isSuccess boolean
function onPurchaseItem(player, item, isSuccess) end

---@param player Player
---@param itemID number
function onPurchaseItemReq(player, itemID) end

---@param itemID number
function getEcoQuantity(itemID) end

---@param itemID number
function getEcoQuantityPlayers(itemID) end

---@param itemID number
function getEcoQuantityWorlds(itemID) end

-- =========================================================
-- CALLBACKS
-- =========================================================

---@class DiscordSlashStructure
---@field getPlayer fun(self: DiscordSlashStructure): Player
---@field getCommandName fun(self: DiscordSlashStructure): string
---@field getChannelID fun(self: DiscordSlashStructure): string
---@field getAuthorID fun(self: DiscordSlashStructure): string
---@field getMessageID fun(self: DiscordSlashStructure): string
---@field getRoles fun(self: DiscordSlashStructure): string[]
---@field editOriginalResponse fun(self: DiscordSlashStructure, content: string, components?: table|any, flags?: table|any): nil
---@field thinking fun(self: DiscordSlashStructure): nil
---@field isBot fun(self: DiscordSlashStructure): boolean
---@field getParameter fun(self: DiscordSlashStructure, paramName: string): any
---@field reply fun(self: DiscordSlashStructure, message: string, components?: table|any, flags?: table|any, mentionUser?: 0|1): nil

---@class DiscordButtonStruture
---@field getCustomID fun(self: DiscordButtonStruture): string
---@field reply fun(self: DiscordButtonStruture, message: string, components?: table|any, flags?: table|any, mentionUser?: 0|1): nil
---@field getContent fun(self: DiscordButtonStruture): string
---@field getChannelID fun(self: DiscordButtonStruture): string
---@field getAuthorID fun(self: DiscordButtonStruture): string
---@field getMessageID fun(self: DiscordButtonStruture): string
---@field getRoles fun(self: DiscordButtonStruture): string[]
---@field getPlayer fun(self: DiscordButtonStruture): Player
---@field editOriginalResponse fun(self: DiscordButtonStruture, content: string, components?: table|any, flags?: table|any): nil
---@field isBot fun(self: DiscordButtonStruture): boolean
---@field dialog fun(self: DiscordButtonStruture, dialogData: table): nil

---@class DiscordMessageStructure
---@field reply fun(self: DiscordMessageStructure, message: string, components?: table|any, flags?: table|any, mentionUser?: 0|1): nil
---@field editOriginalResponse fun(self: DiscordMessageStructure, content: string, components?: table|any, flags?: table|any): nil
---@field getContent fun(self: DiscordMessageStructure): string
---@field getChannelID fun(self: DiscordMessageStructure): string
---@field getAuthorID fun(self: DiscordMessageStructure): string
---@field getMessageID fun(self: DiscordMessageStructure): string
---@field getMentionedUsers fun(self: DiscordMessageStructure): string[]
---@field getRoles fun(self: DiscordMessageStructure): string[]
---@field getPlayer fun(self: DiscordMessageStructure): Player
---@field editOriginalResponse fun(self: DiscordMessageStructure, content: string, components?: table|0, flags?: table|0): nil
---@field isBot fun(self: DiscordMessageStructure): boolean

---@class DiscordFormSubmitStructure
---@field getCustomID fun(self: DiscordFormSubmitStructure): string
---@field getValue fun(self: DiscordFormSubmitStructure, fieldID: string): string
---@field getChannelID fun(self: DiscordFormSubmitStructure): string
---@field getAuthorID fun(self: DiscordFormSubmitStructure): string
---@field getRoles fun(self: DiscordFormSubmitStructure): string[]
---@field getPlayer fun(self: DiscordFormSubmitStructure): Player
---@field reply fun(self: DiscordFormSubmitStructure, message: string, components?: table|any, flags?: table|any, mentionUser?: 0|1): nil
---@field isBot fun(self: DiscordFormSubmitStructure): boolean

---@param callback fun(e: DiscordButtonStruture): boolean|nil
function onDiscordButtonClickCallback(callback) end

---@param callback fun(e: DiscordSlashStructure): boolean|nil
function onDiscordSlashCommandCallback(callback) end

---@param callback fun(): nil
function onDiscordBotReadyCallback(callback) end

---@param callback fun(e: DiscordMessageStructure): boolean|nil
function onDiscordMessageCreateCallback(callback) end

---@param callback fun(e: DiscordFormSubmitStructure): boolean|nil
function onDiscordFormSubmitCallback(callback) end

---@param callback fun(player: Player): boolean|nil
function onPlayerFirstTimeLoginCallback(callback) end

--- @param callback fun(world: World, player: Player, tile: Tile): boolean
function onPlayerActivateTileCallback(callback) end

---@param callback fun(world: World, player: Player, message: string): boolean|nil
function onPlayerCommandCallback(callback) end

---@param callback fun(world: World, player: Player, npc: Player): boolean|nil
function onPlayerPunchNPCCallback(callback) end

---@param callback fun(world: World, player: Player, target: Player): boolean|nil
function onPlayerPunchPlayerCallback(callback) end

---@param callback fun(world: World,player: Player, itemID: number, itemCount: number): boolean|nil
function onPlayerCatchFishCallback(callback) end

---@param callback fun(player: Player)
function onPlayerLoginCallback(callback) end

---@param callback fun(world: World, player: Player): any
function onPlayerLeaveWorldCallback(callback) end

--- @param callback fun(world: World, player: Player, wrenchingPlayer: Player): boolean|nil
function onPlayerWrenchCallback(callback) end

---@param callback fun(world: World, player: Player, data: string[]): boolean|nil
function onPlayerDialogCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number): boolean|nil
function onPlayerEquipClothingCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number): boolean|nil
function onPlayerUnequipClothingCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number)
function onPlayerEquippedClothingCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number)
function onPlayerUnequippedClothingCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemcount: number): boolean|nil
function onPlayerPickupItemCallback(callback) end

---@param callback fun(player: Player)
function onPlayerBlessingClaimCallback(callback) end

---@param callback fun(world: World, player: Player)
function onPlayerEnterWorldCallback(callback) end

---@param callback fun(player: Player)
function onPlayerBoostClaimCallback(callback) end

---@param callback fun()
function onAutoSaveRequest(callback) end

---@param callback fun(newEventID: number, oldEventID: number)
function onEventChangedCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile): boolean|nil
function onTilePunchCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, clickedPlayer: Player, itemID: number): boolean|nil
function onPlayerConsumableCallback(callback) end

---@param callback fun(player: Player, variants: any[], delay: number, netID: number)
function onPlayerVariantCallback(callback) end

---@param callback fun(world: World, player: Player, data: string[]): boolean|nil
function onPlayerActionCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile): boolean|nil
function onTileWrenchCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemCount: number): any
function onPlayerCrimeCallback(callback) end

---@param callback fun(world: World, player: Player, rewardID: number, rewardCount: number, targetPlayer: Player|nil): any
function onPlayerSurgeryCallback(callback) end

---@param callback fun(world: World, player: Player, killedPlayer: Player): any
function onPlayerKillCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, itemID: number, itemCount: number): any
function onPlayerProviderCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, itemID: number, itemCount: number): any
function onPlayerHarmonicCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemCount: number): any
function onPlayerGeigerCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemCount: number): any
function onPlayerCatchGhostCallback(callback) end

---@param callback fun(world: World, player: Player, amount: number): any
function onPlayerXPCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile): any
function onPlayerFirePutOutCallback(callback) end

---@param callback fun(world: World, player: Player, itemCount: number): any
function onPlayerEarnGrowtokenCallback(callback) end

---@param callback fun(world: World, player: Player): any
function onPlayerTrainFishCallback(callback) end

---@param callback fun(world: World, player: Player, amount: number): any
function onPlayerGemsObtainedCallback(callback) end

---@param callback fun(world: World, player: Player, currentLevel: number): boolean|nil
function onPlayerLevelUPCallback(callback) end

---@param callback fun(world: World, player: Player, x: number, y: number): any
function onPlayerPunchCallback(callback) end

---@param callback fun(): any
function onTick(callback) end

---@param callback fun(player: Player): any
function onPlayerTick(callback) end

---@param callback fun(world: World): any
function onWorldTick(callback) end

---@param callback fun(world: World): any
function onWorldLoaded(callback) end

---@param callback fun(world: World): any
function onWorldOffloaded(callback) end

---@param callback fun(player: Player, data: string, delay: number, netID: number): boolean|nil
function onPlayerVariantCallback(callback) end

---@param callback fun(world: World,player: Player, tile: Tile): boolean|nil
function onTileBreakCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile): boolean|nil
function onTilePlaceCallback(callback) end

---@param callback fun(world: World,player: Player)
function onPlayerRegisterCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemCount: number)
function onPlayerDropCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, itemID: number, itemCount: number): boolean|nil
function onPlayerDepositCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, seedID: number): boolean|nil
function onPlayerSpliceSeedCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile, itemID: number, itemCount: number): boolean|nil
function onPlayerVendingBuyCallback(callback) end

---@param callback fun(world: World, player: Player, resultID: number, resultAmount: number): any
function onPlayerDNACallback(callback) end

---@param callback fun(world: World, player1: Player, player2: Player, items1: InventoryItem[], items2: InventoryItem[]): any
function onPlayerTradeCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemAmount: number): boolean|nil
function onPlayerTrashCallback(callback) end

---@param callback fun(world: World, player: Player, addedPlayer: Player): any
function onPlayerAddFriendCallback(callback) end

---@param callback fun(player: Player, data: string): any
function onPlayerRawPacketCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number): boolean|nil
function onPlayerConvertItemCallback(callback) end

---@param callback fun(world: World, player: Player, targetWorldName: string, doorID: number): boolean|nil
function onPlayerEnterDoorCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile): boolean|nil
function onPlayerPlantCallback(callback) end

---@param callback fun(world: World, player: Player, tile: Tile)
function onPlayerHarvestCallback(callback) end

---@param callback fun(world: World, player: Player)
function onPlayerDeathCallback(callback) end

---@param callback fun(player: Player)
function onPlayerDisconnectCallback(callback) end

---@param callback fun(player: Player,cat: string,new_cat: string): boolean|nil
function onWorldMenuRequest(callback) end

---@param callback fun(world: World, player: Player, entity_type: string|number): boolean|nil
function onPlayerDungeonEntitySlainCallback(callback) end

---@param callback fun(world: World, player: Player, item_id: number, item_count: number)
function onPlayerStartopiaCallback(callback) end

---@param callback fun(world: World, player: Player, itemID: number, itemCount: number)
function onPlayerCookingCallback(callback) end

---@param callback fun(req): table({status: number, body: string, headers: table })
function onHTTPRequest(callback) end

-- =========================================================
-- SERVER STORAGE
-- =========================================================

---@param key string
---@param value string
function saveStringToServer(key, value) end

---@param key string
---@return string
function loadStringFromServer(key) end

--- Save Data into table
---
--- @usage
--- saveDataToServer('nperma_db', {'boolean'})
---
---@param key string -- key database
---@param data any -- value
function saveDataToServer(key, data) end

---@param key string
---@return any
function loadDataFromServer(key) end

--- get Server ID
--- @return number
function getServerID() end

--- get Server Name
--- @return string
function getServerName() end

---@return Player[]
function getAllPlayers() end

---@return number
function getMaxLevel() end

---@return ItemEffect[]
function getItemEffects() end

---@param name string
---@return Player|nil
function getPlayerByName(name) end

---@return number
function getItemsCount() end

function reloadScripts() end

---@return Player[]
function getServerPlayers() end

---@return number
function getServerDefaultPort() end

function getStoreItems() end

function getCurrencyMediumName() end

function getCurrencyIcon() end

-- =========================================================
-- MOD IDS
-- =========================================================

ModID = {
  duct_tape = 0,
  ninja = -1,
  ghost = -9,
  silence = -10,
  egged = -13,
  broadcast_cd = -15,
  soaked = -17,
  medusa = -18,
  winter_crown_red = -19,
  winter_green = -20,
  extra_chance_ghc = -23,
  spotlight = -24,
  radiation = -25,
  locks_restrict = -26,
  blueberry = -30,
  block_place = -31,
  block_break = -32,
  ghost_mind = -33,
  superbreak = -35,
  superbreak_cd = -36,
  more_gems_30_percent = -37,
  more_gems_cd = -38,
  sdb_cd = -39,
  name_change_cd = -43,
  recovery_surgery_cd = -44,
  malpractice_cd = -45,
  steady_hand = -46,
  skill_spice = -47,
  more_xp_from_surgery = -48,
  lupus = -49,
  chaos_infection = -50,
  fatty_liver = -51,
  moldy_guts = -52,
  ecto_b = -53,
  brainworm = -54,
  broken_heart = -55,
  chicken_feet = -56,
  gems_cut = -58,
  torn_punch = -59,
  more_gems_20_percent = -65,
  more_gems_30_golden_luck = -66,
  more_gems_30_and_1_hit = -67,
  easter_basket_cd = -68,
  mine_coin_cd = -70,
  ban = -75,
  ninja_2 = -76,
  sprite_eff_yellow = -78,
  sprite_eff_blue = -79,
  sprite_eff_green = -80,
  frozen = -81,
  time_skip_cd = -83,
  coffee = -84,
  tomato = -87,
  extra_xp_for_all_25_percent = -88,
  energy_ball_1 = -89,
  energy_ball_2 = -90,
  energy_ball_3 = -91,
  energy_ball_4 = -92,
  cursed = -93,
  ten_percent_chance_gems_break = -94,
  autofarm_in_front = -97,
  autofarm_magplant = -98,
  spam = -99,
  auto_pull_join = -100,
  auto_plant = -101,
  antibounce = -103,
  cheat_mod_fly = -104,
  super_speed = -105,
  gravity = -106,
  fast_drop = -107,
  fast_trash = -108,
  no_gem_drop = -109,
  spikeproof = -110,
  no_particle = -112,
  ninja_warp = -500,
  charged_rayman = -501,
  access_ghost = -502,
  ghost_immune = -503,
  chat_cd = -1000,
  green_beer = -1100,
}

ReplyFlags = {
  CROSSPOSTED = bit.lshift(1, 0),
  IS_CROSSPOST = bit.lshift(1, 1),
  SUPRESS_EMBEDS = bit.lshift(1, 2),
  SOURCE_MESSAGE_DELETED = bit.lshift(1, 3),
  URGENT = bit.lshift(1, 4),
  HAS_THREAD = bit.lshift(1, 5),
  EPHEMERAL = bit.lshift(1, 6),
  LOADING = bit.lshift(1, 7),
  THREAD_MENTION_FAILED = bit.lshift(1, 8),
  SUPRESS_NOTIFICATIONS = bit.lshift(1, 12),
  IS_VOICE_MESSAGE = bit.lshift(1, 13),
  HAS_SNAPSHOT = bit.lshift(1, 14),
  USING_COMPONENTS_V2 = bit.lshift(1, 15)
};

PlayerClothes = {
  HAIR = 0,
  SHIRT = 1,
  PANTS = 2,
  FEET = 3,
  FACE = 4,
  HAND = 5,
  BACK = 6,
  MASK = 7,
  NECKLACE = 8,
  ANCESTRAL = 9,
}

SubscriptionTypes = {
  SUPPORTER = 1,
  CHEMIST = 2,
  COOK = 3,
  FARMER = 4,
  FISHER = 5,
}

RoleFlags = {
  NONE = 0,
  CAN_USE_COMMANDS = bit.lshift(1, 0),
  CAN_BAN = bit.lshift(1, 1),
  CAN_MUTE = bit.lshift(1, 2),
  CAN_TELEPORT = bit.lshift(1, 3),
  CAN_WARP = bit.lshift(1, 4),
  CAN_PULL = bit.lshift(1, 5),
  CAN_KICK = bit.lshift(1, 6),
  CAN_EDIT_WORLD = bit.lshift(1, 7),
}

RoleProperties = {
  ID = 'roleID',
  PRICE = 'rolePrice',
  NAME = 'roleName',
  ITEM_ID = 'roleItemID',
  TEXTURE = 'textureName',
  TEXTURE_XY = 'textureXY',
  DISCORD_ROLE_ID = 'discordRoleID',
  DESCRIPTION = 'roleDescription',
  NAME_PREFIX = 'namePrefix',
  CHAT_PREFIX = 'chatPrefix',
  DAILY_REWARD_DIAMOND_LOCKS = 'dailyRewardDiamondLocksCount',
  PRIORITY = 'rolePriority',
  FLAGS = 'computedFlags',
}

ItemCategoryFlags = {
  NONE = 0,
  SEED = bit.lshift(1, 0),
  CLOTHING = bit.lshift(1, 1),
  CONSUMABLE = bit.lshift(1, 2),
  BACK = bit.lshift(1, 3),
  HAIR = bit.lshift(1, 4),
  FACE = bit.lshift(1, 5),
  HAND = bit.lshift(1, 6),
  SHIRT = bit.lshift(1, 7),
  PANTS = bit.lshift(1, 8),
  FEET = bit.lshift(1, 9),
}

ItemEditableFlags = {
  NONE = 0,
  TEXT = bit.lshift(1, 0),
  DOOR = bit.lshift(1, 1),
  LOCK = bit.lshift(1, 2),
  SIGN = bit.lshift(1, 3),
  LABEL = bit.lshift(1, 4),
}

TileDataProperties = {
  LABEL = 'label',
  DESTINATION = 'destination',
  LOCK_OWNER = 'lock_owner',
  ADMIN_IDS = 'admin_ids',
  GUILD_ID = 'guild_id',
  COUNTRY = 'country',
  NOTE = 'note',
  FLAGS = 'flags',
}

WorldFlags = {
  NONE = 0,
  NUKED = bit.lshift(1, 0),
  JAMMED = bit.lshift(1, 1),
  ANTI_GRAVITY = bit.lshift(1, 2),
  NO_PUNCH = bit.lshift(1, 3),
  NO_CLIP = bit.lshift(1, 4),
  ZOMBIE = bit.lshift(1, 5),
  PUBLIC = bit.lshift(1, 6),
}

GhostTypes = {
  FISH = 1,
  GHOST = 2,
  DEMON = 3,
  SPIRIT = 4,
}

WorldPunishment = punishmentType

-- NOTE: LAST TEST ID -1600, HAVENT CHECK THE + NUMBER
