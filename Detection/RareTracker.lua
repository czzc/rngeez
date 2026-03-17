--[[
    Detection/RareTracker.lua
    Tracks NPC IDs that the player has recently targeted and identified as rare.
    
    PROBLEM:
    ZONE_KILL detection fires on any NPC kill in a zone. But the zone-drop
    mounts only come from rare mobs, not trash. By the time LOOT_READY fires,
    the mob is dead and UnitClassification("target") returns "normal".
    
    SOLUTION:
    We watch PLAYER_TARGET_CHANGED and check UnitClassification("target")
    while the mob is alive. If it's "rare" or "rareelite", we store the
    NPC ID in a short-lived cache. When LootHandler fires ZONE_KILL, we
    pass along whether any of the looted NPCs were flagged as rares.
    
    ALSO WATCHES:
    - UPDATE_MOUSEOVER_UNIT: catches rares the player mouses over
    - NAME_PLATE_UNIT_ADDED: catches rares that appear on nameplates
    
    This casts a wide net — if the player even glances at a rare, we flag it.
]]

local addonName, ns = ...

local RareTracker = {}
ns.RareTracker = RareTracker

---------------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------------

-- Cache of NPC IDs confirmed as rare: { [npcId] = expirationTime }
-- Entries expire after 60 seconds to prevent stale data from piling up.
local rareCache = {}
local CACHE_DURATION = 60.0

---------------------------------------------------------------------------
-- CORE API
---------------------------------------------------------------------------

-- Check if a given NPC ID has been flagged as a rare recently.
--
-- @param npcId (number) — The NPC ID to check
-- @return (boolean) — true if this NPC was seen as rare/rareelite
function RareTracker:IsRare(npcId)
    if not npcId then return false end

    local expiration = rareCache[npcId]
    if expiration and GetTime() < expiration then
        return true
    end

    -- Expired or not found — clean it up
    if expiration then
        rareCache[npcId] = nil
    end

    return false
end

-- Flag an NPC ID as rare. Called when we detect a rare via unit checks,
-- and as a fallback from LootHandler when the target is still available.
--
-- @param npcId (number) — The NPC ID to flag
function RareTracker:FlagRare(npcId)
    if not npcId then return end

    -- Only log the first time we see this NPC (avoid spam from nameplates)
    if not rareCache[npcId] or GetTime() >= rareCache[npcId] then
        ns.RNGeez:Debug("RareTracker: Flagged NPC %d as rare", npcId)
    end

    rareCache[npcId] = GetTime() + CACHE_DURATION
end

---------------------------------------------------------------------------
-- UNIT SCANNING
-- Checks a unit token (target, mouseover, nameplateN) for rare classification
-- and extracts + flags its NPC ID.
---------------------------------------------------------------------------

local function CheckUnit(unit)
    if not UnitExists(unit) then return end

    -- Only care about enemies (not friendly NPCs or players)
    if not UnitCanAttack("player", unit) then return end

    local classification = UnitClassification(unit)
    if classification == "rare" or classification == "rareelite" then
        -- Extract NPC ID from the unit's GUID
        local guid = UnitGUID(unit)
        if guid then
            local npcId = ns.RNGeez:GetNPCIDFromGUID(guid)
            if npcId then
                RareTracker:FlagRare(npcId)
            end
        end
    end
end

---------------------------------------------------------------------------
-- EVENT HANDLERS
---------------------------------------------------------------------------

local function OnTargetChanged()
    CheckUnit("target")
end

local function OnMouseoverChanged()
    CheckUnit("mouseover")
end

local function OnNameplateAdded(event, unitToken)
    CheckUnit(unitToken)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function RareTracker:Init()
    ns.EventBus:RegisterWoWEvent("PLAYER_TARGET_CHANGED", OnTargetChanged)
    ns.EventBus:RegisterWoWEvent("UPDATE_MOUSEOVER_UNIT", OnMouseoverChanged)
    ns.EventBus:RegisterWoWEvent("NAME_PLATE_UNIT_ADDED", OnNameplateAdded)

    ns.RNGeez:Debug("RareTracker initialized.")
end
