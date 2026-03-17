--[[
    Detection/LootHandler.lua
    Processes LOOT_READY events to detect NPC kills and zone kills.
    
    LOOT_READY fires when a loot window opens. We use GetLootSourceInfo()
    to figure out WHAT we're looting (NPC GUID → NPC ID). This covers:
    
    - NPC_KILL: Looting a specific NPC ID
    - ZONE_KILL: Looting any NPC in a specific zone
    
    IMPORTANT: We check the lastSpellAction from SpellHandler to make sure
    we're not counting mining/skinning/fishing loot as NPC kills. If the
    last spell was a gathering profession, we skip NPC detection entirely
    and let the appropriate handler (SpellHandler/FishingHandler) take over.
    
    WOW API NOTE:
    LOOT_READY fires with autoLoot (boolean) as its argument.
    GetNumLootItems() returns how many items are in the loot window.
    GetLootSourceInfo(slotIndex) returns the GUID of the source for each slot.
]]

local addonName, ns = ...
local C = ns.Constants

local LootHandler = {}
ns.LootHandler = LootHandler

-- Deduplication cache: { [npcId] = timestamp }
-- Prevents double-counting when WoW fires LOOT_READY multiple times
-- for the same loot window (which it does sometimes).
local recentlyProcessed = {}
local DEDUP_WINDOW = 1.0  -- Ignore duplicate NPC IDs within 1 second

---------------------------------------------------------------------------
-- LOOT_READY HANDLER
---------------------------------------------------------------------------
local function OnLootReady(event, autoLoot)
    -- If the last spell action was a gathering/interaction spell,
    -- this loot isn't from an NPC kill. Let the SpellHandler route it.
    local lastAction = ns.DetectionEngine.lastSpellAction
    if lastAction and ns.LootBlockingSpellTypes[lastAction] then

        -- FISHING COMBAT CHECK: If the last action was fishing but the player
        -- is in combat, this loot is from a kill, not from fishing. Failed
        -- fishing casts still fire SPELLCAST_SUCCEEDED, so the fishing flag
        -- can be stale when the player starts fighting mobs. Clear it and
        -- fall through to normal NPC loot processing.
        if lastAction == "Fishing" and UnitAffectingCombat("player") then
            ns.RNGeez:Debug("LOOT_READY: Fishing flag cleared (player in combat, not a real catch)")
            ns.DetectionEngine.lastSpellAction = nil
            ns.DetectionEngine.lastNodeName = nil
            -- Don't return — fall through to NPC processing below
        else
            ns.RNGeez:Debug("LOOT_READY skipped: blocked by spell action '%s'", lastAction)

            -- Route to the appropriate detection method
            if lastAction == "Opening" then
                local nodeName = ns.DetectionEngine.lastNodeName
                local mapId = ns.DetectionEngine:GetCurrentMapId()
                if nodeName then
                    ns.RNGeez:Debug("Routing to OPEN_NODE: '%s' in map %s",
                        nodeName, tostring(mapId))
                    ns.DetectionEngine:ProcessAttempt(C.Methods.OPEN_NODE, {
                        nodeName = nodeName,
                        mapId    = mapId,
                    })
                end
            elseif lastAction == "Fishing" then
                local mapId = ns.DetectionEngine:GetCurrentMapId()
                ns.RNGeez:Debug("Routing to FISHING: map %s", tostring(mapId))
                ns.DetectionEngine:ProcessAttempt(C.Methods.FISHING, {
                    mapId = mapId,
                })
            end

            -- Clear the spell action now that we've handled it
            ns.DetectionEngine.lastSpellAction = nil
            ns.DetectionEngine.lastNodeName = nil
            return
        end
    end

    -- Clear any stale spell action
    ns.DetectionEngine.lastSpellAction = nil
    ns.DetectionEngine.lastNodeName = nil

    -- Extract NPC IDs from loot sources
    -- Each slot in the loot window can come from a different source GUID.
    -- We collect unique NPC IDs to avoid double-counting.
    local processedNpcs = {}
    local hadNewNpcs = false        -- Did we process at least one non-deduped NPC?
    local numItems = GetNumLootItems()

    for slot = 1, numItems do
        -- GetLootSourceInfo might be tainted in 12.0+, so pcall it
        local ok, sources = pcall(GetLootSourceInfo, slot)
        if ok and sources then
            -- sources is a GUID string
            local npcId = ns.RNGeez:GetNPCIDFromGUID(sources)
            if npcId and not processedNpcs[npcId] then
                processedNpcs[npcId] = true

                -- Time-based dedup: skip if we JUST processed this NPC
                -- (WoW sometimes fires LOOT_READY twice for the same window)
                local now = GetTime()
                if recentlyProcessed[npcId] and (now - recentlyProcessed[npcId]) < DEDUP_WINDOW then
                    ns.RNGeez:Debug("LOOT_READY: NPC %d from slot %d (deduped, skipping)", npcId, slot)
                else
                    recentlyProcessed[npcId] = now
                    hadNewNpcs = true

                    ns.RNGeez:Debug("LOOT_READY: NPC %d from slot %d", npcId, slot)

                    -- Route to NPC_KILL detection
                    ns.DetectionEngine:ProcessAttempt(C.Methods.NPC_KILL, {
                        npcId = npcId,
                    })
                end
            end
        end
    end

    -- Also check for ZONE_KILL — any NPC kill in a tracked zone.
    -- Only fire if we processed at least one NEW (non-deduped) NPC.
    -- This prevents WoW's duplicate LOOT_READY events from double-counting
    -- zone kills.
    --
    -- Also check if any of the looted NPCs were flagged as rare by
    -- the RareTracker module. We pass this along so the ZONE_KILL
    -- matcher can require rares-only for zone drop mounts.
    if hadNewNpcs then
        local mapId = ns.DetectionEngine:GetCurrentMapId()
        if mapId then
            -- Check if any looted NPC was a rare (cache first, then fallback)
            local lootedRare = false
            if ns.RareTracker then
                for npcId in pairs(processedNpcs) do
                    if ns.RareTracker:IsRare(npcId) then
                        lootedRare = true
                        break
                    end
                end
            end

            -- Fallback: if the cache missed, check the current target directly.
            -- During LOOT_READY the dead mob is typically still targeted, and
            -- UnitClassification works on dead units in retail WoW.
            if not lootedRare and UnitExists("target") then
                local classification = UnitClassification("target")
                if classification == "rare" or classification == "rareelite" then
                    local guid = UnitGUID("target")
                    if guid then
                        local targetNpcId = ns.RNGeez:GetNPCIDFromGUID(guid)
                        if targetNpcId and processedNpcs[targetNpcId] then
                            lootedRare = true
                            -- Backfill the cache for future reference
                            if ns.RareTracker then
                                ns.RareTracker:FlagRare(targetNpcId)
                            end
                            ns.RNGeez:Debug("LOOT_READY: Rare fallback — NPC %d classified as %s via target",
                                targetNpcId, classification)
                        end
                    end
                end
            end

            ns.DetectionEngine:ProcessAttempt(C.Methods.ZONE_KILL, {
                mapId = mapId,
                isRare = lootedRare,
            })
        end
    end
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function LootHandler:Init()
    ns.EventBus:RegisterWoWEvent("LOOT_READY", OnLootReady)
    ns.RNGeez:Debug("LootHandler initialized.")
end
