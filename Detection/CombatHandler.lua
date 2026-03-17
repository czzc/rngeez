--[[
    Detection/CombatHandler.lua
    Handles boss kill detection via the ENCOUNTER_END event.
    
    WHY ENCOUNTER_END INSTEAD OF COMBAT_LOG?
    In Midnight (12.0+), Blizzard's "secret value" system taints unit names
    and GUIDs from CombatLogGetCurrentEventInfo(). ENCOUNTER_END is clean -
    it provides the encounter ID and success flag directly without taint.
    This is why we use it as our PRIMARY boss kill detection path.
    
    ENCOUNTER_END args:
        encounterID (number)  - DungeonEncounterID (matches Journal)
        encounterName (string) - Localized boss name  
        difficultyID (number) - Instance difficulty
        groupSize (number)    - Raid/party size
        success (number)      - 1 = kill, 0 = wipe
    
    FALLBACK PATH:
    For world bosses and old content without encounter IDs, we also listen
    for UNIT_DIED in the combat log. This path is wrapped in pcall() to
    handle taint errors gracefully.
]]

local addonName, ns = ...

local CombatHandler = {}
ns.CombatHandler = CombatHandler

---------------------------------------------------------------------------
-- ENCOUNTER_END HANDLER (Primary path - clean, no taint)
---------------------------------------------------------------------------
local function OnEncounterEnd(event, encounterID, encounterName, difficultyID, groupSize, success)
    -- success is 1 for kill, 0 for wipe
    if success ~= 1 then return end

    ns.RNGeez:Debug("ENCOUNTER_END: id=%d name='%s' diff=%d",
        encounterID or 0, encounterName or "?", difficultyID or 0)

    -- Route to the detection engine
    ns.DetectionEngine:OnBossKill(encounterID, true, difficultyID)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function CombatHandler:Init()
    -- ENCOUNTER_END is clean and non-protected in 12.0+.
    -- Covers all raid/dungeon bosses with encounter IDs.
    ns.EventBus:RegisterWoWEvent("ENCOUNTER_END", OnEncounterEnd)

    -- COMBAT_LOG_EVENT_UNFILTERED is protected in 12.0+ (ADDON_ACTION_FORBIDDEN).
    -- World bosses without encounter IDs use NPC_KILL detection via LOOT_READY.

    ns.RNGeez:Debug("CombatHandler initialized (ENCOUNTER_END only).")
end
