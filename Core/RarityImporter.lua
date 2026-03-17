--[[
    Core/RarityImporter.lua
    Imports attempt data from the Rarity addon's SavedVariables.

    Rarity stores data in RarityDB (global, AceDB profile format):
        RarityDB.profiles["Default"].groups.{pets|mounts|items}.["Item Name"] = {
            attempts = 477,   -- Total attempts
            found = true,     -- Item obtained
            finds = { ... },  -- Find history
        }

    Items are keyed by exact name - same as RNGeez. We match on name,
    import attempts (upward only), found status, and find history.
]]

local addonName, ns = ...

local RarityImporter = {}
ns.RarityImporter = RarityImporter

local RARITY_GROUPS = { "pets", "mounts", "items" }

---------------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------------

local function forEachRarityItem(profile, callback)
    local groups = profile.groups
    if not groups then return end
    for _, groupName in ipairs(RARITY_GROUPS) do
        local group = groups[groupName]
        if group then
            for name, data in pairs(group) do
                callback(strtrim(name), data, groupName)
            end
        end
    end
end

local function findRNGeezItem(name)
    if ns.items and ns.items[name] then return ns.items[name] end
    if ns.custom and ns.custom[name] then return ns.custom[name] end
    return nil
end

-- Deep-copy only the progress fields we need for backup/restore.
local function copyProgress(item)
    local copy = {
        attempts        = item.attempts,
        sessionAttempts = item.sessionAttempts,
        found           = item.found,
        enabled         = item.enabled,
    }
    if item.finds then
        copy.finds = {}
        for i, f in ipairs(item.finds) do
            copy.finds[i] = { attempts = f.attempts, timestamp = f.timestamp }
        end
    end
    return copy
end

---------------------------------------------------------------------------
-- PROFILE RESOLUTION
---------------------------------------------------------------------------

function RarityImporter:GetProfile()
    if not _G.RarityDB then
        return nil, nil, "Rarity data not found. Is Rarity installed?"
    end

    local profiles = _G.RarityDB.profiles
    if not profiles then
        return nil, nil, "RarityDB has no profiles."
    end

    -- Try current character's profile
    local profileName
    local playerName = UnitName("player")
    local realm = GetRealmName()
    if playerName and realm then
        local key = playerName .. " - " .. realm
        local keys = _G.RarityDB.profileKeys
        if keys and keys[key] then
            profileName = keys[key]
        end
    end

    -- Fall back to "Default"
    if not profileName or not profiles[profileName] then
        profileName = "Default"
    end

    -- Fall back to first available profile
    if not profiles[profileName] then
        for name, _ in pairs(profiles) do
            profileName = name
            break
        end
    end

    local profile = profiles[profileName]
    if not profile then
        return nil, nil, "No usable Rarity profile found."
    end

    return profile, profileName, nil
end

---------------------------------------------------------------------------
-- SCAN CHANGES
---------------------------------------------------------------------------

function RarityImporter:ScanChanges()
    local profile, profileName, err = self:GetProfile()
    if not profile then
        return nil, nil, nil, err
    end

    local changes = {}
    local summary = { matched = 0, attempts = 0, found = 0, uptodate = 0 }

    forEachRarityItem(profile, function(name, rarityData, groupName)
        local item = findRNGeezItem(name)
        if not item then return end

        summary.matched = summary.matched + 1

        local rarityAttempts = rarityData.attempts or 0
        local currentAttempts = item.attempts or 0
        local deltaAttempts = rarityAttempts - currentAttempts
        if deltaAttempts < 0 then deltaAttempts = 0 end

        local newlyFound = (rarityData.found == true) and not item.found
        local hasFinds = rarityData.finds and #rarityData.finds > 0 and
                         (not item.finds or #item.finds == 0)

        if deltaAttempts > 0 or newlyFound or hasFinds then
            table.insert(changes, {
                name          = name,
                item          = item,
                rarityData    = rarityData,
                oldAttempts   = currentAttempts,
                newAttempts   = math.max(currentAttempts, rarityAttempts),
                deltaAttempts = deltaAttempts,
                newlyFound    = newlyFound,
                hasFinds      = hasFinds,
            })
            if deltaAttempts > 0 then summary.attempts = summary.attempts + 1 end
            if newlyFound then summary.found = summary.found + 1 end
        else
            summary.uptodate = summary.uptodate + 1
        end
    end)

    -- Sort by delta descending (biggest changes first)
    table.sort(changes, function(a, b)
        return a.deltaAttempts > b.deltaAttempts
    end)

    return changes, summary, profileName
end

---------------------------------------------------------------------------
-- BACKUP / RESTORE
---------------------------------------------------------------------------

function RarityImporter:BackupSavedVars()
    local backup = { timestamp = time(), items = {}, custom = {}, charItems = {} }

    if ns.items then
        for name, item in pairs(ns.items) do
            backup.items[name] = copyProgress(item)
        end
    end
    if ns.custom then
        for name, item in pairs(ns.custom) do
            backup.custom[name] = copyProgress(item)
        end
    end
    if ns.charDB and ns.charDB.items then
        for name, count in pairs(ns.charDB.items) do
            backup.charItems[name] = count
        end
    end

    RNGeezDB._backup = backup
    ns.RNGeez:Print("Backup created. Use |cFFF0C233/rng restorebackup|r to undo.")
end

function RarityImporter:RestoreBackup()
    local backup = RNGeezDB and RNGeezDB._backup
    if not backup then
        ns.RNGeez:Print("No backup found.")
        return
    end

    local restored = 0

    local function restoreTable(savedTable, backupTable)
        if not savedTable or not backupTable then return end
        for name, progress in pairs(backupTable) do
            local item = savedTable[name]
            if item then
                item.attempts        = progress.attempts
                item.sessionAttempts = progress.sessionAttempts
                item.found           = progress.found
                item.enabled         = progress.enabled
                if progress.finds then
                    item.finds = {}
                    for i, f in ipairs(progress.finds) do
                        item.finds[i] = { attempts = f.attempts, timestamp = f.timestamp }
                    end
                end
                restored = restored + 1
            end
        end
    end

    restoreTable(ns.items, backup.items)
    restoreTable(ns.custom, backup.custom)

    -- Restore per-character data
    if backup.charItems and ns.charDB then
        ns.charDB.items = {}
        for name, count in pairs(backup.charItems) do
            ns.charDB.items[name] = count
        end
    end

    RNGeezDB._backup = nil

    ns.EventBus:FireAddonEvent(ns.Events.DETECTION_CYCLE)
    ns.RNGeez:Print("Backup restored. %d items reverted to pre-import state.", restored)
end

---------------------------------------------------------------------------
-- EXECUTE IMPORT
---------------------------------------------------------------------------

function RarityImporter:ExecuteImport(changes)
    self:BackupSavedVars()

    local counts = { attempts = 0, found = 0, finds = 0 }

    for _, change in ipairs(changes) do
        local item = change.item
        local rarity = change.rarityData

        -- Sync attempts upward
        if change.deltaAttempts > 0 then
            ns.AttemptTracker:SyncAttempts(item, rarity.attempts, "Rarity import")
            counts.attempts = counts.attempts + 1
        end

        -- Mark as found
        if change.newlyFound then
            item.found = true
            counts.found = counts.found + 1
        end

        -- Import find history
        if change.hasFinds and rarity.finds then
            if not item.finds then item.finds = {} end
            if #item.finds == 0 then
                for _, f in ipairs(rarity.finds) do
                    table.insert(item.finds, {
                        attempts  = f.totalAttempts or f.attempts or 0,
                        timestamp = 0,
                    })
                end
                counts.finds = counts.finds + 1
            end
        end
    end

    ns.EventBus:FireAddonEvent(ns.Events.DETECTION_CYCLE)

    return counts
end

---------------------------------------------------------------------------
-- SLASH COMMAND ENTRY POINT
---------------------------------------------------------------------------

function RarityImporter:ShowImport()
    local changes, summary, profileName, err = self:ScanChanges()
    if not changes then
        ns.RNGeez:Print(err or "Unknown error reading Rarity data.")
        return
    end

    if ns.ImportWindow then
        ns.ImportWindow:Show(changes, summary, profileName, function()
            return self:ExecuteImport(changes)
        end)
    else
        ns.RNGeez:Print("Import window not available.")
    end
end
