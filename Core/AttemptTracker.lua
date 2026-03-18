--[[
    Core/AttemptTracker.lua
    Manages attempt counting, probability calculations, and session tracking.
    
    This is the "math brain" of the addon. When the detection engine confirms
    an attempt for an item, it calls AttemptTracker:AddAttempt(). This module
    then:
    1. Increments the attempt counter
    2. Recalculates probability
    3. Fires the ATTEMPT_ADDED addon event (so UI can update)
    4. Optionally announces the attempt to chat
    
    PROBABILITY MODEL:
    Uses the complement method: P(drop in N tries) = 1 - (1 - 1/chance)^N
    This is identical to Rarity's math - it's just basic probability,
    not anything proprietary.
    
    "LUCK" ASSESSMENT:
    If P > 0.5 (50%), the player has done more attempts than the median.
    We display a human-readable luck assessment so players know if they're
    getting shafted by RNG or if their farm is still "on pace."
]]

local addonName, ns = ...
local C = ns.Constants

local AttemptTracker = {}
ns.AttemptTracker = AttemptTracker

---------------------------------------------------------------------------
-- ATTEMPT MANAGEMENT
---------------------------------------------------------------------------

-- Add one attempt to an item. This is the primary entry point called by
-- all detection handlers.
-- 
-- @param item (table) - The item entry from ns.items or ns.custom
-- @param source (string) - Human-readable source for debug logging
--                          (e.g., "ENCOUNTER_END: Lich King", "LOOT_READY: NPC 36597")
function AttemptTracker:AddAttempt(item, source)
    if not item then return end
    if item.found and not item.repeatable then return end
    if item.enabled == false then return end

    -- Increment account-wide and session counters
    item.attempts = (item.attempts or 0) + 1
    item.sessionAttempts = (item.sessionAttempts or 0) + 1

    -- Attribute to current character
    if ns.charDB and ns.charDB.items and item.name then
        ns.charDB.items[item.name] = (ns.charDB.items[item.name] or 0) + 1
    end

    -- Log the attempt in debug mode
    ns.RNGeez:Debug("Attempt #%d for %s (source: %s)",
        item.attempts, item.name or "unknown", source or "unknown")

    -- Announce to chat if enabled
    if ns.settings.announceAttempts then
        self:AnnounceAttempt(item)
    end

    -- Fire the addon event so UI modules can react
    ns.EventBus:FireAddonEvent(ns.Events.ATTEMPT_ADDED,
        item.name, item, item.attempts)
end

-- Manually set the attempt count for an item.
-- Used when syncing from Blizzard statistics or for manual corrections.
-- Only updates if the new count is HIGHER (prevents accidental data loss).
--
-- @param item (table) - The item entry
-- @param count (number) - The new attempt count
-- @param source (string) - Why we're syncing (for debug)
-- @param skipCharAttribution (boolean) - If true, don't attribute delta to current character
function AttemptTracker:SyncAttempts(item, count, source, skipCharAttribution)
    if not item or not count then return end
    count = tonumber(count)
    if not count then return end
    if count <= (item.attempts or 0) then return end

    local delta = count - (item.attempts or 0)
    ns.RNGeez:Debug("Syncing attempts for %s: %d → %d (+%d, source: %s)",
        item.name or "unknown", item.attempts or 0, count, delta, source or "unknown")

    item.attempts = count

    -- Attribute the synced delta to the current character
    if not skipCharAttribution and ns.charDB and ns.charDB.items and item.name then
        ns.charDB.items[item.name] = (ns.charDB.items[item.name] or 0) + delta
    end
end

---------------------------------------------------------------------------
-- ITEM FOUND
---------------------------------------------------------------------------

-- Called when the ItemResolver detects that the player has obtained an item.
-- Records the "find" event and fires the ITEM_FOUND addon event.
--
-- @param item (table) - The item entry
function AttemptTracker:MarkFound(item)
    if not item then return end

    item.found = true

    -- Record the find in the history log
    if not item.finds then item.finds = {} end
    table.insert(item.finds, {
        attempts  = item.attempts,
        timestamp = time(),     -- Lua's os.time equivalent in WoW
    })

    ns.RNGeez:Print("|cFF00FF00Found|r: %s after %d attempts!",
        item.name or "unknown", item.attempts or 0)

    -- Fire the addon event (FoundAlert.lua will pick this up)
    ns.EventBus:FireAddonEvent(ns.Events.ITEM_FOUND,
        item.name, item, item.attempts)
end

---------------------------------------------------------------------------
-- PROBABILITY MATH
---------------------------------------------------------------------------

-- Calculate the probability of having received at least one drop
-- in the given number of attempts.
--
-- @param attempts (number) - How many attempts the player has made
-- @param chance (number) - Drop rate denominator (100 = 1%, 200 = 0.5%)
-- @return (number) - Probability between 0 and 1
function AttemptTracker:GetProbability(attempts, chance)
    if not attempts or not chance then return 0 end
    if attempts <= 0 or chance <= 0 then return 0 end

    -- P(at least one drop) = 1 - (1 - 1/chance)^attempts
    -- This is the complement of "failed every single time"
    return 1 - math.pow(1 - (1 / chance), attempts)
end

-- Calculate how many attempts are needed to reach a given probability.
-- Useful for the "expected attempts" display.
--
-- @param targetProb (number) - Target probability (e.g., 0.5 for 50%)
-- @param chance (number) - Drop rate denominator
-- @return (number) - Number of attempts needed (rounded up)
function AttemptTracker:GetAttemptsForProbability(targetProb, chance)
    if not targetProb or not chance then return 0 end
    if targetProb <= 0 or targetProb >= 1 or chance <= 0 then return 0 end

    -- Solve: targetProb = 1 - (1 - 1/chance)^N for N
    -- N = log(1 - targetProb) / log(1 - 1/chance)
    return math.ceil(math.log(1 - targetProb) / math.log(1 - (1 / chance)))
end

-- Get a human-readable "luck assessment" string and color.
-- Returns a descriptor and an RGB color table.
--
-- @param probability (number) - Current probability (0-1)
-- @return label (string), color (table {r, g, b})
function AttemptTracker:GetLuckAssessment(probability)
    -- Thresholds are subjective but match common player expectations.
    -- Under 50% = you're still "on pace" or better.
    -- Over 50% = you're past the median, progressively unluckier.
    if probability < 0.25 then
        return "On pace",          C.Colors.GREEN
    elseif probability < 0.50 then
        return "A bit unlucky",    C.Colors.WHITE
    elseif probability < 0.75 then
        return "Unlucky",          C.Colors.YELLOW
    elseif probability < 0.90 then
        return "Very unlucky",     C.Colors.RED
    elseif probability < 0.99 then
        return "Extremely unlucky", C.Colors.RED
    else
        return "Cursed",           C.Colors.RED
    end
end

-- Build a formatted summary string for an item's current state.
-- Used by the tooltip and chat announcements.
--
-- @param item (table) - The item entry
-- @return (string) - Formatted summary like "347 attempts (86.7% - Very unlucky)"
function AttemptTracker:GetSummaryText(item)
    if not item then return "" end

    local attempts = item.attempts or 0
    local chance   = item.chance or 0

    if chance <= 0 then
        return string.format("%d attempts", attempts)
    end

    local prob  = self:GetProbability(attempts, chance)
    local pct   = prob * 100
    local label = self:GetLuckAssessment(prob)

    return string.format("%d attempts (%.1f%% - %s)", attempts, pct, label)
end

---------------------------------------------------------------------------
-- CHAT ANNOUNCEMENTS
---------------------------------------------------------------------------

-- Print an attempt update to chat.
-- Format: "Invincible's Reins: 348 attempts (86.9% - Very unlucky)"
function AttemptTracker:AnnounceAttempt(item)
    if not item then return end

    local summary = self:GetSummaryText(item)
    local name = item.name or "Unknown Item"

    -- For now, always print to self. Later we can add party/say channels.
    ns.RNGeez:Print("%s: %s", name, summary)
end
