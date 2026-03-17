--[[
    Detection/SpellHandler.lua
    Tracks player spellcasts to provide context for loot events.
    
    WHY THIS EXISTS:
    When LOOT_READY fires, we need to know HOW the player obtained that loot.
    Was it from killing an NPC? Fishing? Mining a node? Opening a chest?
    
    WoW doesn't tell us this directly in the loot event. Instead, we track
    the player's last relevant spellcast and store it on the DetectionEngine.
    When LOOT_READY fires, LootHandler checks this flag to route correctly.
    
    EVENTS:
    UNIT_SPELLCAST_SUCCEEDED - fires when any unit completes a cast.
    We filter to "player" and check against our RelevantSpells table.
    
    UNIT_SPELLCAST_SENT - fires earlier (when cast begins). We use this
    for "Opening" casts to capture the target name (the node/chest),
    because by the time SUCCEEDED fires, the target info may be gone.
]]

local addonName, ns = ...
local C = ns.Constants

local SpellHandler = {}
ns.SpellHandler = SpellHandler

---------------------------------------------------------------------------
-- SPELLCAST HANDLERS
---------------------------------------------------------------------------

-- Capture "Opening" target names on cast start.
-- UNIT_SPELLCAST_SENT args: unit, target, castGUID, spellID
local function OnSpellcastSent(event, unit, target, castGUID, spellID)
    if unit ~= "player" then return end

    local action = ns.RelevantSpells[spellID]
    if not action then return end

    -- For "Opening" spells, capture what we're opening (the target name).
    -- This is the chest/node/crate name that OPEN_NODE items match against.
    if action == "Opening" and target then
        ns.DetectionEngine.lastNodeName = target
        ns.RNGeez:Debug("SPELLCAST_SENT: Opening '%s' (spell %d)", target, spellID)
    end
end

-- On successful cast completion, flag the action type.
-- UNIT_SPELLCAST_SUCCEEDED args: unit, castGUID, spellID
local function OnSpellcastSucceeded(event, unit, castGUID, spellID)
    if unit ~= "player" then return end

    local action = ns.RelevantSpells[spellID]
    if not action then return end

    -- Store the action type so LootHandler knows how to route the next loot
    ns.DetectionEngine.lastSpellAction = action
    ns.RNGeez:Debug("SPELLCAST_SUCCEEDED: %s (spell %d)", action, spellID)

    -- For SPELL_CAST detection method items, fire immediately (no loot needed).
    -- Example: some items proc from casting a specific spell, not from looting.
    ns.DetectionEngine:ProcessAttempt(C.Methods.SPELL_CAST, {
        spellId = spellID,
    })
end

---------------------------------------------------------------------------
-- CLEAR STALE STATE
-- After a timeout, clear the spell action flag. This prevents a stale
-- flag from mis-routing a loot event that happens much later.
--
-- The timeout varies by action type:
-- - Fishing: 30 seconds (bobber can sit for 15-25 seconds before a bite)
-- - Everything else: 5 seconds (looting happens almost immediately)
--
-- We use a generation counter instead of cancelling timers (C_Timer.After
-- can't be cancelled in all WoW versions). Each new spell bumps the
-- generation; when the timer fires, it only clears if the generation
-- hasn't changed (meaning no new spell was cast in the meantime).
---------------------------------------------------------------------------
local clearGeneration = 0

-- Timeout per action type (seconds)
local ACTION_TIMEOUTS = {
    ["Fishing"]         = 30.0,   -- Bobber wait time can be long
    ["Opening"]         = 5.0,
    ["Mining"]          = 5.0,
    ["Skinning"]        = 5.0,
    ["Herb Gathering"]  = 5.0,
    ["Pick Lock"]       = 5.0,
    ["Disenchanting"]   = 5.0,
    ["Prospecting"]     = 5.0,
    ["Milling"]         = 5.0,
}
local DEFAULT_TIMEOUT = 5.0

local function ScheduleClear()
    -- Bump the generation so any previous timer becomes a no-op
    clearGeneration = clearGeneration + 1
    local myGeneration = clearGeneration

    -- Pick the right timeout for the current action
    local action = ns.DetectionEngine.lastSpellAction
    local timeout = (action and ACTION_TIMEOUTS[action]) or DEFAULT_TIMEOUT

    C_Timer.After(timeout, function()
        -- Only clear if no newer spell has been cast since we scheduled this
        if clearGeneration == myGeneration and ns.DetectionEngine.lastSpellAction then
            ns.RNGeez:Debug("Clearing stale spell action: %s (after %.0fs)",
                ns.DetectionEngine.lastSpellAction, timeout)
            ns.DetectionEngine.lastSpellAction = nil
            ns.DetectionEngine.lastNodeName = nil
        end
    end)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------
function SpellHandler:Init()
    ns.EventBus:RegisterWoWEvent("UNIT_SPELLCAST_SENT", OnSpellcastSent)
    ns.EventBus:RegisterWoWEvent("UNIT_SPELLCAST_SUCCEEDED", function(event, ...)
        OnSpellcastSucceeded(event, ...)
        ScheduleClear()
    end)

    ns.RNGeez:Debug("SpellHandler initialized.")
end
