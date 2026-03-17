--[[
    Detection/BagHandler.lua
    Monitors bag inventory changes for USE_ITEM detection.
    
    USE CASE:
    Some items come from opening containers. Example: Mysterious Egg hatches
    into a Cracked Egg after 7 days, and you open it for a chance at the
    Green Proto-Drake. The detection config says:
        sourceItemIds = { 39878 }  -- Cracked Egg
    
    When the player uses/opens one of these items, its bag count decreases.
    We snapshot tracked source item quantities on BAG_UPDATE_DELAYED and
    compare to the previous snapshot. If quantity decreased, it's an attempt.
    
    WHY BAG_UPDATE_DELAYED?
    BAG_UPDATE fires multiple times during a single bag change operation
    (once per slot affected). BAG_UPDATE_DELAYED fires once after all
    changes are settled. More efficient and less error-prone.
]]

local addonName, ns = ...
local C = ns.Constants

local BagHandler = {}
ns.BagHandler = BagHandler

---------------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------------

-- Snapshot of source item quantities: { [itemId] = count }
-- Taken after each BAG_UPDATE_DELAYED so we can detect decreases.
local previousCounts = {}

-- Flag to skip the first update (on login, bags are "changing" as they load)
local initialSnapshotTaken = false

---------------------------------------------------------------------------
-- BAG SCANNING
---------------------------------------------------------------------------

-- Count how many of a specific item the player has across all bags.
--
-- @param itemId (number) - The item to count
-- @return (number) - Total quantity across all bags
local function GetBagItemCount(itemId)
    local total = 0

    -- Bag indices: 0 = backpack, 1-4 = equipped bags
    -- In Dragonflight+, NUM_BAG_SLOTS may be higher with reagent bags
    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == itemId then
                total = total + (info.stackCount or 1)
            end
        end
    end

    return total
end

-- Build a set of all source item IDs we need to track.
-- Iterates all items with USE_ITEM detection method and collects their
-- sourceItemIds into a flat set.
--
-- @return (table) - { [itemId] = true } of items to monitor
local function GetTrackedSourceItems()
    local tracked = {}

    ns.ForEachItem(function(_, item)
        if item.detection and item.detection.method == C.Methods.USE_ITEM then
            if item.detection.sourceItemIds then
                for _, sourceId in ipairs(item.detection.sourceItemIds) do
                    tracked[sourceId] = true
                end
            end
        end
    end)

    return tracked
end

-- Take a snapshot of all tracked source item quantities.
--
-- @return (table) - { [itemId] = count }
local function SnapshotCounts()
    local counts = {}
    local tracked = GetTrackedSourceItems()

    for itemId in pairs(tracked) do
        counts[itemId] = GetBagItemCount(itemId)
    end

    return counts
end

---------------------------------------------------------------------------
-- BAG_UPDATE_DELAYED HANDLER
---------------------------------------------------------------------------
local function OnBagUpdateDelayed(event)
    -- Skip the first update - bags are still loading from the server.
    -- We take our initial snapshot here instead of acting on it.
    if not initialSnapshotTaken then
        previousCounts = SnapshotCounts()
        initialSnapshotTaken = true
        ns.RNGeez:Debug("BagHandler: Initial snapshot taken (%d tracked source items).",
            ns.RNGeez:CountTable(previousCounts))
        return
    end

    -- Take a new snapshot and compare
    local newCounts = SnapshotCounts()

    for itemId, oldCount in pairs(previousCounts) do
        local newCount = newCounts[itemId] or 0

        if newCount < oldCount then
            -- Quantity decreased - the player used/opened this item
            local consumed = oldCount - newCount

            ns.RNGeez:Debug("BagHandler: Item %d decreased by %d (%d → %d)",
                itemId, consumed, oldCount, newCount)

            -- Fire USE_ITEM detection for each consumed unit
            for i = 1, consumed do
                ns.DetectionEngine:ProcessAttempt(C.Methods.USE_ITEM, {
                    itemId = itemId,
                })
            end
        end
    end

    -- Update the snapshot for next comparison
    previousCounts = newCounts
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function BagHandler:Init()
    ns.EventBus:RegisterWoWEvent("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)

    -- Take initial snapshot after a short delay (let bags finish loading)
    C_Timer.After(3.0, function()
        if not initialSnapshotTaken then
            previousCounts = SnapshotCounts()
            initialSnapshotTaken = true
            ns.RNGeez:Debug("BagHandler: Delayed initial snapshot taken.")
        end
    end)

    ns.RNGeez:Debug("BagHandler initialized.")
end
