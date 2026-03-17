--[[
    Detection/StatisticsHandler.lua
    Polls Blizzard's built-in kill-count statistics to sync attempt counts.
    
    WHY THIS EXISTS:
    If RNGeez misses a detection (addon was disabled, event taint, etc.),
    the player's attempt count drifts below their actual kill count.
    
    Blizzard tracks boss kills via the Statistics panel (Achievements → Stats).
    Each boss has a statistic ID that counts how many times you've killed it.
    We use GetStatistic(statId) to read this and sync our count upward.
    
    KEY RULE: We only sync UP, never down. If our count is higher than
    Blizzard's stat, we trust our count (it may include kills Blizzard
    doesn't track, like some world bosses).
    
    TIMING:
    We poll stats after ENCOUNTER_END (post-boss-kill) and on login.
    Not every frame — the API isn't fast and the data only changes on kills.
    We stagger polls with a timer to avoid hammering the API.
]]

local addonName, ns = ...
local C = ns.Constants

local StatisticsHandler = {}
ns.StatisticsHandler = StatisticsHandler

---------------------------------------------------------------------------
-- STATISTICS POLLING
---------------------------------------------------------------------------

-- Sync all items that have statisticIds defined.
-- Called after boss kills and on login (with delay).
function StatisticsHandler:SyncAll()
    ns.RNGeez:Debug("StatisticsHandler: Running sync pass...")

    ns.ForEachItem(function(_, item)
        if item.detection and item.detection.statisticIds then
            self:SyncItem(item)
        end
    end)
end

-- Sync a single item's attempts from Blizzard statistics.
--
-- @param item (table) — The item entry with detection.statisticIds
function StatisticsHandler:SyncItem(item)
    if not item.detection or not item.detection.statisticIds then return end

    -- Sum all statistic IDs for this item (some items have multiple)
    local totalKills = 0
    for _, statId in ipairs(item.detection.statisticIds) do
        -- GetStatistic returns a STRING, not a number. Often "--" for untracked.
        -- pcall because this API may be tainted in some scenarios.
        local ok, result = pcall(GetStatistic, statId)
        if ok and result then
            local kills = tonumber(result)
            if kills then
                totalKills = totalKills + kills
            end
        end
    end

    -- Sync upward only
    if totalKills > (item.attempts or 0) then
        ns.AttemptTracker:SyncAttempts(item, totalKills,
            "Blizzard statistics (stat IDs: " ..
            table.concat(item.detection.statisticIds, ",") .. ")")
    end
end

---------------------------------------------------------------------------
-- EVENT HANDLERS
---------------------------------------------------------------------------

-- After a boss kill, wait a few seconds for the stat to update, then sync.
local function OnEncounterEnd(event, encounterID, encounterName, difficultyID, groupSize, success)
    if success ~= 1 then return end

    -- Stagger the sync so the statistic has time to update server-side.
    -- 3 seconds is usually enough; WoW updates stats near-instantly but
    -- we want to avoid racing.
    C_Timer.After(3.0, function()
        StatisticsHandler:SyncAll()
    end)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function StatisticsHandler:Init()
    -- Sync after boss kills
    ns.EventBus:RegisterWoWEvent("ENCOUNTER_END", OnEncounterEnd)

    -- Sync on login after a longer delay (stats may not be ready immediately)
    C_Timer.After(10.0, function()
        StatisticsHandler:SyncAll()
    end)

    ns.RNGeez:Debug("StatisticsHandler initialized.")
end
