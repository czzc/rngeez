--[[
    Core/ItemResolver.lua
    Handles two responsibilities:
    
    1. ITEM INFO CACHING
       WoW's C_Item.GetItemInfo() is async - the first call for an uncached
       item returns nil and fires GET_ITEM_INFO_RECEIVED when it's ready.
       We queue lookups and resolve them when the data arrives, so the rest
       of the addon can just ask "give me the icon for item 50818" without
       worrying about the async dance.
    
    2. COLLECTION OWNERSHIP CHECKS
       Scans the player's mounts, pets, and toys to determine which tracked
       items have been obtained. This runs periodically (not every frame)
       and on specific events like NEW_MOUNT_ADDED, NEW_PET_ADDED, etc.
    
    JS ANALOGY:
    Think of the item info cache like a service with a Map<itemId, Promise>.
    The collection scanner is like a polling interval that checks an API.
]]

local addonName, ns = ...
local C = ns.Constants

local ItemResolver = {}
ns.ItemResolver = ItemResolver

---------------------------------------------------------------------------
-- ITEM INFO CACHE
-- Maps itemId → { name, link, icon, quality }
-- Populated lazily as items are queried.
---------------------------------------------------------------------------
local infoCache = {}

-- Queue of itemIds waiting for data from the server.
-- When GET_ITEM_INFO_RECEIVED fires, we check this queue.
local pendingLookups = {}

-- Request item info for an item ID. Returns cached data immediately if
-- available, or nil if we need to wait for the server response.
--
-- @param itemId (number) - The WoW item ID
-- @return info (table|nil) - { name, link, icon, quality } or nil if pending
function ItemResolver:GetItemInfo(itemId)
    if not itemId then return nil end

    -- Check cache first
    if infoCache[itemId] then
        return infoCache[itemId]
    end

    -- Ask WoW for the data. GetItemInfo returns multiple values:
    -- name, link, quality, ilvl, reqLevel, class, subclass, maxStack,
    -- equipSlot, texture, sellPrice, ...
    local name, link, quality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId)

    if name then
        -- Data was already cached by the WoW client - store and return
        infoCache[itemId] = {
            name    = name,
            link    = link,
            icon    = icon,
            quality = quality,
        }
        return infoCache[itemId]
    else
        -- Not cached yet - mark as pending. WoW will fire
        -- GET_ITEM_INFO_RECEIVED when it arrives from the server.
        pendingLookups[itemId] = true
        return nil
    end
end

-- Get just the icon texture path for an item.
-- Returns a default question mark icon if the item isn't cached yet.
--
-- @param itemId (number) - The WoW item ID
-- @return (string) - Texture path for SetTexture()
function ItemResolver:GetIcon(itemId)
    local info = self:GetItemInfo(itemId)
    if info and info.icon then
        return info.icon
    end
    -- Default: question mark icon
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

---------------------------------------------------------------------------
-- GET_ITEM_INFO_RECEIVED HANDLER
-- Fires when the WoW client receives item data from the server.
-- We check if the item was in our pending queue and cache it.
---------------------------------------------------------------------------
local function OnItemInfoReceived(event, itemId, success)
    if not pendingLookups[itemId] then return end

    pendingLookups[itemId] = nil

    if success then
        -- Re-query now that the data is available
        local name, link, quality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId)
        if name then
            infoCache[itemId] = {
                name    = name,
                link    = link,
                icon    = icon,
                quality = quality,
            }
        end
    end
end

---------------------------------------------------------------------------
-- COLLECTION OWNERSHIP SCANNING
-- Checks whether tracked items have been obtained by scanning the player's
-- mount journal, pet journal, and toy box.
-- 
-- This is how we detect that the player has found something - not from
-- the loot event itself, but by noticing it appeared in their collection.
-- More reliable than checking loot contents, which can be buggy with
-- bonus rolls, group loot, etc.
---------------------------------------------------------------------------

-- Scan all tracked items and update their "found" status.
-- Called on login, and when we receive collection-change events.
function ItemResolver:ScanCollections()
    ns.RNGeez:Debug("Scanning collections for owned items...")

    local foundCount = 0

    ns.ForEachItem(function(_, item)
        if not item.found then
            local owned = self:IsItemOwned(item)
            if owned then
                ns.AttemptTracker:MarkFound(item)
                foundCount = foundCount + 1
            end
        end
    end)

    if foundCount > 0 then
        ns.RNGeez:Debug("Collection scan found %d newly obtained items.", foundCount)
    end
end

-- Check if a specific item is owned by the player.
-- Dispatches to the appropriate API based on item type.
--
-- @param item (table) - The item entry
-- @return (boolean) - true if the player has this item
function ItemResolver:IsItemOwned(item)
    if not item then return false end

    local itemType = item.type

    if itemType == C.ItemTypes.MOUNT then
        return self:IsMountOwned(item)
    elseif itemType == C.ItemTypes.PET then
        return self:IsPetOwned(item)
    elseif itemType == C.ItemTypes.TOY then
        return self:IsToyOwned(item)
    else
        -- Generic items: check if it's in the player's bags
        -- (or just return false - manual marking for misc items)
        return false
    end
end

-- Check if a mount is owned via the mount journal.
-- Uses spellId if available (more reliable), falls back to iterating the journal.
--
-- @param item (table) - The item entry (needs .spellId or .itemId)
-- @return (boolean)
function ItemResolver:IsMountOwned(item)
    -- If we have a spell ID, we can use the direct lookup
    if item.spellId then
        -- C_MountJournal.GetMountFromSpell might not exist in all versions,
        -- so we fall back to iterating. But first, try the quick route.
        local mountIDs = C_MountJournal.GetMountIDs()
        for _, mountId in ipairs(mountIDs) do
            local name, spellId, _, _, _, _, _, _, _, _, isCollected =
                C_MountJournal.GetMountInfoByID(mountId)
            if spellId == item.spellId and isCollected then
                return true
            end
        end
    end

    -- Fallback: We don't have a quick way to go from itemId → mount ownership.
    -- For now, return false and rely on the spellId path.
    -- Phase 3 will ensure all mount entries have spellIds.
    return false
end

-- Check if a battle pet is owned via the pet journal.
--
-- @param item (table) - The item entry (needs .itemId)
-- @return (boolean)
function ItemResolver:IsPetOwned(item)
    if not item.itemId then return false end

    -- C_PetJournal.GetNumCollectedInfo returns (numCollected, limit) for a speciesId.
    -- We'd need to map itemId → speciesId, which requires additional data.
    -- For Phase 1, return false. Phase 3 will add creatureId / speciesId fields.
    -- TODO: Implement pet ownership check when we add speciesId to item entries
    return false
end

-- Check if a toy is owned via the toy box.
--
-- @param item (table) - The item entry (needs .itemId)
-- @return (boolean)
function ItemResolver:IsToyOwned(item)
    if not item.itemId then return false end

    -- PlayerHasToy is the simplest ownership check in WoW's API
    return PlayerHasToy(item.itemId)
end

---------------------------------------------------------------------------
-- EVENT REGISTRATION
-- Listen for events that indicate collections changed.
---------------------------------------------------------------------------
function ItemResolver:Init()
    -- Item info from server
    ns.EventBus:RegisterWoWEvent("GET_ITEM_INFO_RECEIVED", OnItemInfoReceived)

    -- Collection change events - trigger a rescan
    local function onCollectionChange()
        -- Slight delay to let the API update before we query it.
        -- C_Timer.After is the WoW equivalent of setTimeout.
        C_Timer.After(1.0, function()
            ItemResolver:ScanCollections()
        end)
    end

    ns.EventBus:RegisterWoWEvent("NEW_MOUNT_ADDED", onCollectionChange)
    ns.EventBus:RegisterWoWEvent("COMPANION_LEARNED", onCollectionChange)
    ns.EventBus:RegisterWoWEvent("NEW_TOY_ADDED", onCollectionChange)

    -- Resolve missing mount spellIds, then scan collections.
    -- Delayed 5 seconds to let the mount journal and collections API load.
    C_Timer.After(5.0, function()
        self:ResolveSpellIds()
        self:ScanCollections()
    end)

    ns.RNGeez:Debug("ItemResolver initialized.")
end

---------------------------------------------------------------------------
-- SPELL ID RESOLUTION
-- Many mount entries ship with spellId = 0 because the correct spellId
-- wasn't known at data entry time. We resolve them at runtime using
-- C_MountJournal.GetMountFromItem(), which maps itemId → mountId.
---------------------------------------------------------------------------

function ItemResolver:ResolveSpellIds()
    local resolved = 0

    ns.ForEachItem(function(_, item)
        if item.type ~= C.ItemTypes.MOUNT then return end
        if (item.spellId or 0) ~= 0 then return end
        if not item.itemId then return end

        local mountID = C_MountJournal.GetMountFromItem(item.itemId)
        if not mountID then return end

        local _, spellId = C_MountJournal.GetMountInfoByID(mountID)
        if spellId and spellId > 0 then
            item.spellId = spellId
            resolved = resolved + 1
            ns.RNGeez:Print("Resolved mount: %s → spellId %d", item.name or "?", spellId)
        end
    end)

    if resolved > 0 then
        ns.RNGeez:Debug("Resolved %d mount spellIds from the mount journal.", resolved)
    end
end
