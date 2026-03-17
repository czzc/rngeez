--[[
    Core/DetectionEngine.lua
    The central routing engine. This is where the data-driven design pays off.
    
    ROLE:
    The detection engine doesn't directly process game events. Instead, it:
    1. Initializes all detection handler modules (LootHandler, CombatHandler, etc.)
    2. Provides the shared API that handlers call when they detect something
    3. Routes handler confirmations to the AttemptTracker
    
    FLOW:
    Game Event (e.g., ENCOUNTER_END)
        → CombatHandler processes it, extracts encounter ID
        → CombatHandler calls DetectionEngine:ProcessAttempt(method, context)
        → DetectionEngine iterates ALL tracked items
        → For each item whose detection.method matches:
            → Check if the context matches the item's detection config
            → If yes: AttemptTracker:AddAttempt(item)
    
    This means adding a new detection method requires:
    1. A new handler module in Detection/ (registers for the right WoW events)
    2. A new method key in Constants.Methods
    3. A new matching function in DetectionEngine (the MethodMatchers table)
    4. Items in the database declare the new method - done.
    
    JS ANALOGY:
    Think of this like a Redux middleware/reducer combo. The handlers are
    action creators that dispatch { type: "BOSS_KILL", payload: { encounterId: 856 } }.
    The engine is the reducer that checks every item in state against the action.
]]

local addonName, ns = ...
local C = ns.Constants

local DetectionEngine = {}
ns.DetectionEngine = DetectionEngine

---------------------------------------------------------------------------
-- STATE
-- Tracks recent activity to prevent double-counting within the same
-- game event cycle. Reset each detection pass.
---------------------------------------------------------------------------

-- The "last spell action" - set by SpellHandler when a relevant spell fires.
-- Cleared after loot processing. Prevents mining/fishing loot from being
-- counted as NPC kills.
DetectionEngine.lastSpellAction = nil

-- The node/object name from the last "Opening" cast.
-- Used by OPEN_NODE detection.
DetectionEngine.lastNodeName = nil

-- Set of NPC IDs that were looted in the current LOOT_READY event.
-- Extracted from loot source GUIDs. Used by NPC_KILL and ZONE_KILL.
DetectionEngine.lootedNpcIds = {}

-- Current map ID (updated on zone changes and loot events)
DetectionEngine.currentMapId = nil

---------------------------------------------------------------------------
-- METHOD MATCHERS
-- Each function takes an item's detection config and a context table,
-- returning true if the context matches and an attempt should count.
-- 
-- Context tables vary by method:
-- BOSS_KILL:  { encounterId, difficultyId }
-- NPC_KILL:   { npcId }
-- ZONE_KILL:  { mapId }
-- FISHING:    { mapId }
-- OPEN_NODE:  { nodeName, mapId }
-- USE_ITEM:   { itemId }
-- SPELL_CAST: { spellId }
---------------------------------------------------------------------------
local MethodMatchers = {}

-- Shared helper: check if a value exists in an array-style table.
local function ArrayContains(array, value)
    if not array or not value then return false end
    for _, v in ipairs(array) do
        if v == value then return true end
    end
    return false
end

-- Shared helper: check if a mapId matches a detection.mapIds list.
-- Returns true if no restriction exists (mapIds is nil).
local function MatchesMap(detection, mapId)
    if not detection.mapIds then return true end
    return mapId and ArrayContains(detection.mapIds, mapId)
end

MethodMatchers[C.Methods.BOSS_KILL] = function(detection, context)
    if not ArrayContains(detection.encounterIds, context.encounterId) then
        return false
    end
    -- Check difficulty restriction if present
    if detection.difficulties then
        return detection.difficulties[context.difficultyId] == true
    end
    return true
end

MethodMatchers[C.Methods.NPC_KILL] = function(detection, context)
    return ArrayContains(detection.npcIds, context.npcId)
end

MethodMatchers[C.Methods.ZONE_KILL] = function(detection, context)
    if not context.mapId then return false end
    if detection.requiresRare and not context.isRare then return false end
    return ArrayContains(detection.mapIds, context.mapId)
end

MethodMatchers[C.Methods.FISHING] = function(detection, context)
    return MatchesMap(detection, context.mapId)
end

MethodMatchers[C.Methods.OPEN_NODE] = function(detection, context)
    if not ArrayContains(detection.nodes, context.nodeName) then
        return false
    end
    return MatchesMap(detection, context.mapId)
end

MethodMatchers[C.Methods.USE_ITEM] = function(detection, context)
    return ArrayContains(detection.sourceItemIds, context.itemId)
end

MethodMatchers[C.Methods.SPELL_CAST] = function(detection, context)
    return ArrayContains(detection.spellIds, context.spellId)
end

---------------------------------------------------------------------------
-- PRIMARY API
-- Called by detection handlers after they extract relevant data from
-- game events. Iterates all tracked items and fires attempts for matches.
---------------------------------------------------------------------------

-- Process a detected event against all tracked items.
--
-- @param method (string) - One of Constants.Methods
-- @param context (table) - Method-specific data extracted by the handler
-- @return (number) - How many items matched (for debug)
function DetectionEngine:ProcessAttempt(method, context)
    local matcher = MethodMatchers[method]
    if not matcher then
        ns.RNGeez:Debug("No matcher for method '%s'", tostring(method))
        return 0
    end

    local matchCount = 0
    local source
    if ns.settings and ns.settings.debugMode then
        source = string.format("%s: %s", method, self:ContextToString(context))
    end

    -- Check both shipped and custom items
    ns.ForEachItem(function(_, item)
        local detection = item.detection
        if detection and detection.method == method then
            if matcher(detection, context) then
                ns.AttemptTracker:AddAttempt(item, source)
                matchCount = matchCount + 1
            end
        end
    end)

    -- Fire the detection cycle event (UI refresh trigger)
    ns.EventBus:FireAddonEvent(ns.Events.DETECTION_CYCLE)

    return matchCount
end

-- Convenience: process a boss kill from ENCOUNTER_END data.
--
-- @param encounterId (number) - DungeonEncounterID from ENCOUNTER_END
-- @param success (boolean) - Was the boss killed? (checked before calling ProcessAttempt)
-- @param difficultyId (number) - Instance difficulty
function DetectionEngine:OnBossKill(encounterId, success, difficultyId)
    if not success then return end

    self:ProcessAttempt(C.Methods.BOSS_KILL, {
        encounterId  = encounterId,
        difficultyId = difficultyId,
    })
end

-- Convenience: process an NPC kill from loot data.
--
-- @param npcId (number) - The NPC ID extracted from the GUID
function DetectionEngine:OnNpcKill(npcId)
    self:ProcessAttempt(C.Methods.NPC_KILL, { npcId = npcId })
end

---------------------------------------------------------------------------
-- UTILITY
---------------------------------------------------------------------------

-- Get the current map ID from the C_Map API.
-- Returns nil if unavailable (loading screen, etc.)
function DetectionEngine:GetCurrentMapId()
    local mapId = C_Map.GetBestMapForUnit("player")
    self.currentMapId = mapId
    return mapId
end

-- Convert a context table to a debug-friendly string.
-- @param context (table) - The context table
-- @return (string) - Human-readable representation
function DetectionEngine:ContextToString(context)
    if not context then return "{}" end

    local parts = {}
    for k, v in pairs(context) do
        table.insert(parts, string.format("%s=%s", k, tostring(v)))
    end
    return table.concat(parts, ", ")
end

---------------------------------------------------------------------------
-- INIT
-- Initializes all detection handler sub-modules.
-- Called from Bootstrap:FinishInit() after EventBus is ready.
---------------------------------------------------------------------------
function DetectionEngine:Init()
    -- Initialize each handler module (they register their own events)
    if ns.LootHandler   then ns.LootHandler:Init()   end
    if ns.CombatHandler then ns.CombatHandler:Init() end
    if ns.BagHandler    then ns.BagHandler:Init()    end
    if ns.SpellHandler  then ns.SpellHandler:Init()  end
    if ns.RareTracker   then ns.RareTracker:Init()   end
    if ns.StatisticsHandler then ns.StatisticsHandler:Init() end
    if ns.ItemResolver  then ns.ItemResolver:Init()  end

    -- Listen for zone changes to keep currentMapId fresh
    ns.EventBus:RegisterWoWEvent("ZONE_CHANGED_NEW_AREA", function()
        self:GetCurrentMapId()
    end)
    ns.EventBus:RegisterWoWEvent("ZONE_CHANGED", function()
        self:GetCurrentMapId()
    end)

    -- Cache the initial map ID
    self:GetCurrentMapId()

    ns.RNGeez:Debug("DetectionEngine initialized with %d default items.",
        ns.RNGeez:CountTable(ns.DefaultItems))
end
