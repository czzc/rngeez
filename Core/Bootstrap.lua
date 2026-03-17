--[[
    Core/Bootstrap.lua
    The addon's entry point. Handles initialization, saved variables,
    slash commands, and the addon compartment (minimap menu button).
    
    LIFECYCLE:
    WoW loads our files in TOC order. By the time this file executes,
    Constants.lua, Spells.lua, and DefaultItems.lua are already loaded
    onto the `ns` namespace table.
    
    We then wait for two events:
    1. ADDON_LOADED — fires when OUR addon's SavedVariables are available
    2. PLAYER_LOGIN — fires when the player is fully in the world
    
    We do most setup on ADDON_LOADED, and final "everything is ready"
    work on PLAYER_LOGIN (like scanning collections, updating UI, etc.)
    
    LUA CONCEPT FOR JS DEVS:
    There's no `import` or `require` in WoW Lua. Every file shares the
    same global scope. We avoid polluting globals by using the `ns` table
    (passed via `...` to every file) as our private module system.
    The ONLY global we create is `RNGeez` — for slash commands and the
    addon compartment, which require global function references.
]]

local addonName, ns = ...
local C = ns.Constants

---------------------------------------------------------------------------
-- ADDON OBJECT
-- This is the central addon table. Other modules attach themselves to it.
-- We expose it as a global so slash commands and compartment funcs can
-- reference it, but all internal communication goes through `ns`.
---------------------------------------------------------------------------
local RNGeez = {}
ns.RNGeez = RNGeez

-- Also expose globally for the addon compartment and slash commands
_G.RNGeez = RNGeez

-- Iterate all tracked items (shipped + custom). Callback receives (name, item).
-- Does NOT pre-filter by enabled/found — callers decide what to check.
function ns.ForEachItem(callback)
    for name, item in pairs(ns.items or {}) do
        callback(name, item)
    end
    for name, item in pairs(ns.custom or {}) do
        callback(name, item)
    end
end

-- Version info (pulled from TOC metadata at runtime)
RNGeez.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "unknown"

---------------------------------------------------------------------------
-- SAVED VARIABLES MANAGEMENT
-- 
-- RNGeezDB is our SavedVariables table (declared in the TOC file).
-- WoW persists this to disk on logout and loads it back on startup.
-- 
-- Structure:
-- RNGeezDB = {
--     items = {                    -- Progress for shipped items (keyed by name)
--         ["Invincible's Reins"] = { attempts = 347, enabled = true, ... },
--     },
--     custom = {                   -- User-created items (keyed by name)
--         ["My Custom Farm"] = { itemId = 12345, detection = {...}, attempts = 0, ... },
--     },
--     settings = {                 -- User preferences
--         minimapButton = { hide = false },
--         announceAttempts = true,
--         ...
--     },
--     statistics = {               -- Blizzard stat snapshots per character GUID
--         ["Player-1234-ABCDEF"] = { [6733] = 45, ... },
--     },
-- }
---------------------------------------------------------------------------

-- Default settings for new users (or missing keys on existing users)
local DEFAULT_SETTINGS = {
    minimapButton  = { hide = false },  -- LibDBIcon needs this subtable
    announceAttempts = true,            -- Show attempt count in chat
    announceChannel  = "self",          -- "self" = print, "party", "say", etc.
    barVisible       = true,            -- Show the tracking progress bar
    tooltipScale     = 1.0,             -- Tooltip size multiplier
    debugMode        = false,           -- Extra logging for development
}

-- Deep-copy a table (used for merging defaults into saved data)
local function deepCopy(src)
    local dest = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = deepCopy(v)
        else
            dest[k] = v
        end
    end
    return dest
end

-- Ensure all expected keys exist in a table, filling from defaults.
-- Does NOT overwrite existing values — only fills in missing ones.
-- This is how we add new settings in updates without wiping user prefs.
local function fillDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            -- Key is missing entirely — insert the default
            if type(v) == "table" then
                target[k] = deepCopy(v)
            else
                target[k] = v
            end
        elseif type(v) == "table" and type(target[k]) == "table" then
            -- Both are tables — recurse to fill nested defaults
            fillDefaults(target[k], v)
        end
        -- If the key exists and isn't a table-table mismatch, leave it alone
    end
end

-- Merge shipped default items with user's saved progress.
-- Detection config comes from DefaultItems.lua (so updates propagate).
-- Progress data (attempts, finds, enabled) comes from SavedVariables.
local function mergeDefaultItems()
    local saved = RNGeezDB[C.DBKeys.ITEMS]

    for name, defaults in pairs(ns.DefaultItems) do
        if not saved[name] then
            -- Brand new item the user hasn't seen before — insert with zero progress
            saved[name] = {
                attempts        = 0,
                sessionAttempts = 0,
                found           = false,
                enabled         = true,
                finds           = {},
            }
        end
        -- Always update detection config from shipped defaults.
        -- This is the key design decision: detection rules are NOT user-editable
        -- for shipped items (they get fixed in addon updates). Progress is preserved.
        saved[name].itemId    = defaults.itemId
        saved[name].type      = defaults.type
        saved[name].chance    = defaults.chance
        saved[name].expansion = defaults.expansion
        saved[name].detection = defaults.detection
        saved[name].name      = name

        -- Copy optional fields if they exist in defaults
        if defaults.spellId then saved[name].spellId = defaults.spellId end
        if defaults.questId then saved[name].questId = defaults.questId end
        if defaults.faction  then saved[name].faction = defaults.faction end
        if defaults.unique   then saved[name].unique = defaults.unique end
        if defaults.repeatable then saved[name].repeatable = defaults.repeatable end
    end

    -- Cleanup: remove saved items that are no longer in shipped defaults.
    -- This handles items we've removed from the DB (obsolete, duplicates, etc.)
    -- Custom items (in the CUSTOM table) are never touched by this.
    local removed = 0
    for name, _ in pairs(saved) do
        if not ns.DefaultItems[name] then
            saved[name] = nil
            removed = removed + 1
        end
    end
    if removed > 0 then
        ns.RNGeez:Print("Cleaned up %d removed items from saved data.", removed)
    end
end

---------------------------------------------------------------------------
-- INITIALIZATION
-- We use a hidden frame to listen for system events. This is the standard
-- WoW addon pattern — create an invisible frame, register events on it,
-- and handle them in OnEvent.
---------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")

-- Track which init stages have fired (both must fire before we're "ready")
local addonLoaded = false
local playerLoggedIn = false

-- Called when our SavedVariables are available
local function OnAddonLoaded(loadedAddonName)
    -- This event fires for EVERY addon — only respond to ours
    if loadedAddonName ~= addonName then return end

    -- Initialize SavedVariables with structure if this is a fresh install
    if not RNGeezDB then RNGeezDB = {} end
    if not RNGeezDB[C.DBKeys.ITEMS]    then RNGeezDB[C.DBKeys.ITEMS]    = {} end
    if not RNGeezDB[C.DBKeys.CUSTOM]   then RNGeezDB[C.DBKeys.CUSTOM]   = {} end
    if not RNGeezDB[C.DBKeys.SETTINGS] then RNGeezDB[C.DBKeys.SETTINGS] = {} end
    if not RNGeezDB[C.DBKeys.STATS]    then RNGeezDB[C.DBKeys.STATS]    = {} end

    -- Fill in any missing settings from defaults (non-destructive)
    fillDefaults(RNGeezDB[C.DBKeys.SETTINGS], DEFAULT_SETTINGS)

    -- Merge shipped item database with user's saved progress
    mergeDefaultItems()

    -- Store convenient references on the namespace
    ns.db       = RNGeezDB
    ns.items    = RNGeezDB[C.DBKeys.ITEMS]
    ns.custom   = RNGeezDB[C.DBKeys.CUSTOM]
    ns.settings = RNGeezDB[C.DBKeys.SETTINGS]

    addonLoaded = true
    RNGeez:Debug("SavedVariables loaded. %d shipped items, %d custom items.",
        RNGeez:CountTable(ns.items), RNGeez:CountTable(ns.custom))

    -- If player already logged in before addon loaded (unlikely but possible)
    if playerLoggedIn then
        RNGeez:FinishInit()
    end
end

-- Called when the player is fully in the game world
local function OnPlayerLogin()
    playerLoggedIn = true

    if addonLoaded then
        RNGeez:FinishInit()
    end
end

-- Final initialization — both SavedVariables and player are ready.
-- Module init ORDER matters here:
--   1. EventBus (everything else depends on it for event registration)
--   2. DetectionEngine (initializes all detection handlers internally)
--   3. UI modules (they listen for addon events from detection)
function RNGeez:FinishInit()
    -- 1. Event system first — all other modules register events through this
    if ns.EventBus then ns.EventBus:Init() end

    -- 2. Detection engine — initializes LootHandler, CombatHandler, etc.
    --    and registers all WoW events needed for tracking
    if ns.DetectionEngine then ns.DetectionEngine:Init() end

    -- 3. UI modules
    if ns.MinimapButton then ns.MinimapButton:Init() end
    if ns.Tooltip       then ns.Tooltip:Init()       end
    if ns.FoundAlert    then ns.FoundAlert:Init()    end

    -- Clear session attempt counts from any previous login
    ns.ForEachItem(function(_, item)
        item.sessionAttempts = 0
    end)

    self:Print("v" .. self.version .. " loaded. /rng for commands.")
end

-- Register for the events we need during init
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

-- The OnEvent handler dispatches to the right function based on event name.
-- This is the WoW equivalent of addEventListener — one handler, switch on event.
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()
    end
end)

---------------------------------------------------------------------------
-- UTILITY FUNCTIONS
-- Small helpers used across the addon. Live on the RNGeez object so any
-- module can call them via ns.RNGeez:FunctionName().
---------------------------------------------------------------------------

-- Print a message to chat with the addon name prefix
function RNGeez:Print(...)
    local msg = string.format(...)
    -- Color the prefix with our accent gold
    local prefix = string.format("|cFFF0C233RNGeez|r: ")
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

-- Debug logging — only prints when debug mode is enabled
function RNGeez:Debug(...)
    if ns.settings and ns.settings.debugMode then
        local msg = string.format(...)
        local prefix = "|cFF33FF85RNGeez Debug|r: "
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
    end
end

-- Count entries in a table (Lua tables don't have a .length property)
-- In Lua, # only works on sequential integer-keyed tables (arrays).
-- For dictionary-style tables (which is what our item DB is), we have
-- to iterate and count manually.
function RNGeez:CountTable(tbl)
    local count = 0
    if tbl then
        for _ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end

-- Safely extract NPC ID from a GUID string.
-- GUIDs look like: "Creature-0-1234-5678-9012-00012345-ABCDEF"
-- The NPC ID is the 6th segment (after splitting on "-").
function RNGeez:GetNPCIDFromGUID(guid)
    if not guid or type(guid) ~= "string" then return nil end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)

    -- Only Creatures and Vehicles have meaningful NPC IDs
    if unitType ~= "Creature" and unitType ~= "Vehicle" then
        return nil
    end

    return tonumber(npcId)
end

-- Check if the player is Horde
function RNGeez:IsHorde()
    local faction = UnitFactionGroup("player")
    return faction == "Horde"
end

-- Get the player's current map ID (returns a number)
function RNGeez:GetCurrentMapID()
    return C_Map.GetBestMapForUnit("player")
end

-- Get the current instance difficulty ID
function RNGeez:GetInstanceDifficulty()
    local _, _, difficultyID = GetInstanceInfo()
    return difficultyID
end

---------------------------------------------------------------------------
-- SLASH COMMANDS
-- /rng — opens the tooltip or config (later)
-- /rng debug — toggles debug mode
---------------------------------------------------------------------------
local function handleDebug()
    ns.settings.debugMode = not ns.settings.debugMode
    if ns.settings.debugMode then
        RNGeez:Print("Debug mode |cFF00FF00ON|r")
    else
        RNGeez:Print("Debug mode |cFFFF0000OFF|r")
    end
end

local function handleStatus()
    local shipped = RNGeez:CountTable(ns.items)
    local custom  = RNGeez:CountTable(ns.custom)
    local total   = shipped + custom
    local enabled = 0
    local found   = 0

    ns.ForEachItem(function(_, item)
        if item.enabled then enabled = enabled + 1 end
        if item.found   then found = found + 1 end
    end)

    RNGeez:Print("RNGeez v%s", RNGeez.version)
    RNGeez:Print("Items: %d total (%d shipped, %d custom)", total, shipped, custom)
    RNGeez:Print("Tracking: %d enabled, %d found", enabled, found)
end

local function handleList()
    local unfound = {}

    ns.ForEachItem(function(_, item)
        if not item.found and item.enabled ~= false then
            table.insert(unfound, item)
        end
    end)

    table.sort(unfound, function(a, b)
        return (a.attempts or 0) > (b.attempts or 0)
    end)

    if #unfound == 0 then
        RNGeez:Print("You have everything! Nothing left to farm.")
        return
    end

    RNGeez:Print("--- Still hunting (%d items) ---", #unfound)
    for _, item in ipairs(unfound) do
        local summary = ns.AttemptTracker:GetSummaryText(item)
        local expansion = C.ExpansionLabels[item.expansion] or ""
        local color = "|cFFFFFFFF"
        local prob = ns.AttemptTracker:GetProbability(item.attempts or 0, item.chance or 0)
        if prob >= 0.75 then
            color = "|cFFFF3333"
        elseif prob >= 0.50 then
            color = "|cFFFFFF33"
        elseif prob >= 0.25 then
            color = "|cFFFFFFFF"
        else
            color = "|cFF33FF33"
        end
        RNGeez:Print("  %s%s|r — %s  |cFF888888(%s)|r",
            color, item.name or "?", summary, expansion)
    end
end

local function handleReset()
    ns.ForEachItem(function(_, item)
        item.attempts = 0
        item.sessionAttempts = 0
        item.found = false
        item.finds = {}
    end)
    RNGeez:Print("All attempt data has been reset.")
end

local function handleHelp()
    RNGeez:Print("Commands:")
    RNGeez:Print("  /rng         — Toggle tracker window")
    RNGeez:Print("  /rng list    — Show items you're still hunting")
    RNGeez:Print("  /rng status  — Show addon status")
    RNGeez:Print("  /rng debug   — Toggle debug logging")
    RNGeez:Print("  /rng reset   — Reset all attempt data")
end

SLASH_RNGEEZ1 = "/rng"

SlashCmdList["RNGEEZ"] = function(input)
    local cmd = strlower(strtrim(input or ""))

    if cmd == "debug" then          handleDebug()
    elseif cmd == "status" then     handleStatus()
    elseif cmd == "reset" then      RNGeez:Print("Type /rng resetconfirm to wipe ALL attempt data. This cannot be undone.")
    elseif cmd == "list" then       handleList()
    elseif cmd == "resetconfirm" then handleReset()
    elseif cmd == "testalert" then  if ns.FoundAlert then ns.FoundAlert:TestAlert() end
    elseif cmd == "" then           if ns.Tooltip then ns.Tooltip:Toggle() end
    else                            handleHelp()
    end
end

---------------------------------------------------------------------------
-- ADDON COMPARTMENT
-- These are global functions referenced in the TOC file.
-- They power the addon's entry in the minimap addon compartment menu
-- (the little icon tray added in Dragonflight).
---------------------------------------------------------------------------
function RNGeez_OnAddonCompartmentClick(addonName, buttonName)
    -- Left click: show tooltip (later: toggle main window)
    -- Right click: show options (later)
    if buttonName == "RightButton" then
        RNGeez:Print("Options panel coming soon!")
    else
        -- For now, just print status
        SlashCmdList["RNGEEZ"]("status")
    end
end

function RNGeez_OnAddonCompartmentEnter(addonName, menuButtonFrame)
    -- Show a simple tooltip on hover
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
    GameTooltip:AddLine("RNGeez v1.0.0", C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3])
    GameTooltip:AddLine("Track your rare drop farming attempts.", 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-click: Show status", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Right-click: Options", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

function RNGeez_OnAddonCompartmentLeave(addonName, menuButtonFrame)
    GameTooltip:Hide()
end
