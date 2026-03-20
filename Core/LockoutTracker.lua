--[[
    Core/LockoutTracker.lua
    Determines lockout status for tracked items on the current character.

    TWO SYSTEMS:
    A) Instance lockouts - scans saved instance data for BOSS_KILL items.
       Uses GetSavedInstanceInfo/GetSavedInstanceEncounterInfo to check
       if a boss is already killed this reset. Bridges our encounterIds
       to saved instance boss names via EJ_GetEncounterInfo.

    B) Quest-based lockouts - checks C_QuestLog.IsQuestFlaggedCompleted
       for items with a known questId (world rares, daily bosses).
       Auto-detects questIds by correlating ATTEMPT_ADDED events with
       QUEST_TURNED_IN timing. Candidates are promoted to confirmed
       after 2 correlated kills.

    TRANSIENT STATE:
    item.lockout = true/false/nil (recalculated each session, not saved)

    PERSISTED STATE (in SavedVariables):
    item.questId            - confirmed lockout quest ID
    item.questIdCandidates  - { [questId] = hitCount } unconfirmed
]]

local addonName, ns = ...
local C = ns.Constants

local LockoutTracker = {}
ns.LockoutTracker = LockoutTracker

---------------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------------

-- Session cache: encounterID -> lowercase boss name (from EJ API)
local encounterNameCache = {}

-- Active quest sniff: { itemName, timestamp }
local activeSniff = nil

-- Retry counter for EJ_GetEncounterInfo returning nil
local ejRetries = 0
local MAX_EJ_RETRIES = 3

---------------------------------------------------------------------------
-- ENCOUNTER NAME RESOLUTION
-- Bridges our encounterIds to the boss names returned by saved instance API.
---------------------------------------------------------------------------

local function GetEncounterName(encounterId)
    if encounterNameCache[encounterId] then
        return encounterNameCache[encounterId]
    end

    local name = EJ_GetEncounterInfo(encounterId)
    if name then
        local lower = strlower(name)
        encounterNameCache[encounterId] = lower
        return lower
    end

    return nil  -- Journal data not loaded yet
end

---------------------------------------------------------------------------
-- SYSTEM A: INSTANCE LOCKOUT SCAN
-- Checks saved instances for killed bosses and matches against BOSS_KILL items.
---------------------------------------------------------------------------

local function ScanInstances()
    -- Build lookup of killed bosses: killedBosses[lowerName][difficultyId] = true
    local killedBosses = {}
    local numSaved = GetNumSavedInstances()

    for i = 1, numSaved do
        local _, _, _, difficultyId, locked, _, _, _, _, _, numEncounters = GetSavedInstanceInfo(i)

        if locked and numEncounters then
            for j = 1, numEncounters do
                local bossName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                if isKilled and bossName then
                    local lower = strlower(bossName)
                    if not killedBosses[lower] then
                        killedBosses[lower] = {}
                    end
                    killedBosses[lower][difficultyId] = true
                end
            end
        end
    end

    -- Match against tracked BOSS_KILL items
    local ejMissing = false

    ns.ForEachItem(function(_, item)
        local detection = item.detection
        if not detection or detection.method ~= C.Methods.BOSS_KILL then return end
        if not detection.encounterIds or #detection.encounterIds == 0 then return end

        -- Use primary encounter ID
        local bossName = GetEncounterName(detection.encounterIds[1])
        if not bossName then
            ejMissing = true
            return  -- EJ data not available, leave lockout as nil
        end

        local killedDifficulties = killedBosses[bossName]
        if not killedDifficulties then
            item.lockout = false  -- Boss not killed on any difficulty
            return
        end

        if detection.difficulties then
            -- Item restricted to specific difficulties
            for diffId in pairs(detection.difficulties) do
                if killedDifficulties[diffId] then
                    item.lockout = true
                    return
                end
            end
            item.lockout = false  -- Killed on other difficulties, not the relevant one
        else
            -- No difficulty restriction - killed on any difficulty means locked
            item.lockout = true
        end
    end)

    return ejMissing
end

---------------------------------------------------------------------------
-- SYSTEM B: QUEST-BASED LOCKOUT SCAN
-- Checks quest completion for items with a known questId.
---------------------------------------------------------------------------

local function ScanQuests()
    ns.ForEachItem(function(_, item)
        local detection = item.detection
        if not detection then return end
        -- Skip BOSS_KILL items (handled by System A)
        if detection.method == C.Methods.BOSS_KILL then return end

        if item.questId then
            item.lockout = C_QuestLog.IsQuestFlaggedCompleted(item.questId)
        end
        -- Items without questId: lockout stays nil (no indicator shown)
    end)
end

---------------------------------------------------------------------------
-- QUEST ID AUTO-DETECTION
-- Correlates ATTEMPT_ADDED with QUEST_TURNED_IN to learn lockout questIds.
---------------------------------------------------------------------------

local SNIFF_WINDOW = 10  -- seconds to listen after an attempt

local function StartQuestSniff(_, itemName, item)
    if not item or not item.detection then return end
    -- Only sniff for non-BOSS_KILL items that don't already have a confirmed questId
    if item.detection.method == C.Methods.BOSS_KILL then return end
    if item.questId then return end

    activeSniff = {
        itemName  = itemName,
        timestamp = GetTime(),
    }

    ns.RNGeez:Debug("LockoutTracker: Quest sniff started for '%s'", itemName)
end

local function OnQuestTurnedIn(_, questId)
    if not activeSniff then return end
    if not questId then return end

    -- Check if still within the sniff window
    local elapsed = GetTime() - activeSniff.timestamp
    if elapsed > SNIFF_WINDOW then
        activeSniff = nil
        return
    end

    local itemName = activeSniff.itemName

    -- Find the item
    local item = (ns.items and ns.items[itemName]) or (ns.custom and ns.custom[itemName])
    if not item then
        activeSniff = nil
        return
    end

    -- Initialize candidates table if needed
    if not item.questIdCandidates then
        item.questIdCandidates = {}
    end

    -- Increment hit count for this candidate
    local hits = (item.questIdCandidates[questId] or 0) + 1
    item.questIdCandidates[questId] = hits

    ns.RNGeez:Debug("LockoutTracker: Quest %d candidate for '%s' (hits: %d)", questId, itemName, hits)

    -- Promote to confirmed after 2 correlated kills
    if hits >= 2 then
        item.questId = questId
        item.questIdCandidates = nil  -- Clean up candidates
        ns.RNGeez:Debug("LockoutTracker: Quest %d CONFIRMED for '%s'", questId, itemName)

        -- Immediately check this quest's completion status
        item.lockout = C_QuestLog.IsQuestFlaggedCompleted(questId)
        ns.EventBus:FireAddonEvent(ns.Events.LOCKOUT_UPDATED)
    end

    activeSniff = nil
end

---------------------------------------------------------------------------
-- FULL SCAN
-- Runs both systems and fires the update event.
---------------------------------------------------------------------------

local function FullScan()
    local ejMissing = ScanInstances()
    ScanQuests()

    ns.EventBus:FireAddonEvent(ns.Events.LOCKOUT_UPDATED)

    -- If EJ data wasn't available, retry after a delay
    if ejMissing and ejRetries < MAX_EJ_RETRIES then
        ejRetries = ejRetries + 1
        ns.RNGeez:Debug("LockoutTracker: EJ data missing, retry %d/%d in 2s", ejRetries, MAX_EJ_RETRIES)
        C_Timer.After(2, FullScan)
    end
end

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

function LockoutTracker:Scan()
    FullScan()
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------

function LockoutTracker:Init()
    -- Request raid lockout data from server
    RequestRaidInfo()

    -- Re-scan when saved instance data updates
    ns.EventBus:RegisterWoWEvent("UPDATE_INSTANCE_INFO", function()
        FullScan()
    end)

    -- Re-scan after a boss kill (delay for server-side lockout update)
    ns.EventBus:RegisterWoWEvent("ENCOUNTER_END", function(_, _, _, _, _, success)
        if success == 1 then
            C_Timer.After(1, function()
                RequestRaidInfo()
            end)
        end
    end)

    -- Quest sniffing: start window on attempt, capture on quest turn-in
    ns.EventBus:RegisterAddonEvent(ns.Events.ATTEMPT_ADDED, StartQuestSniff)
    ns.EventBus:RegisterWoWEvent("QUEST_TURNED_IN", OnQuestTurnedIn)

    -- Initial scan after short delay (lets EJ data and raid info load)
    C_Timer.After(1, FullScan)

    ns.RNGeez:Debug("LockoutTracker initialized.")
end
