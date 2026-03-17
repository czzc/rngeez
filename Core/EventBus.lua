--[[
    Core/EventBus.lua
    Lightweight event registration and dispatch system.
    
    Replaces AceEvent-3.0 with ~80 lines instead of pulling in the full
    Ace3 dependency tree. Handles two types of events:
    
    1. WOW EVENTS — Blizzard system events (LOOT_READY, ENCOUNTER_END, etc.)
       These fire from the game engine. We register a frame to listen for them.
    
    2. ADDON EVENTS — Internal events we define ourselves (TITHE_ATTEMPT_ADDED, etc.)
       These let our modules communicate without tight coupling.
       Think of them like a pub/sub bus or Angular's EventEmitter.
    
    USAGE:
        ns.EventBus:RegisterWoWEvent("LOOT_READY", handler)
        ns.EventBus:RegisterAddonEvent("TITHE_ATTEMPT_ADDED", handler)
        ns.EventBus:FireAddonEvent("TITHE_ATTEMPT_ADDED", itemName, newCount)
        ns.EventBus:UnregisterWoWEvent("LOOT_READY", handler)
    
    WHY NOT ACE3?
    AceEvent is great, but it pulls in AceAddon, CallbackHandler, and several
    other libs. For our use case — registering ~10 WoW events and firing a
    handful of internal ones — this is simpler, smaller, and has zero deps.
]]

local addonName, ns = ...

local EventBus = {}
ns.EventBus = EventBus

---------------------------------------------------------------------------
-- INTERNAL STATE
---------------------------------------------------------------------------

-- Events that are protected/restricted in 12.0+ (Midnight).
-- Attempting to RegisterEvent() for these on a third-party frame triggers
-- ADDON_ACTION_FORBIDDEN. We skip them entirely and use alternative
-- detection paths instead.
local BLOCKED_EVENTS = {
    ["COMBAT_LOG_EVENT_UNFILTERED"] = true,
    -- Add more here as Blizzard restricts additional events in future patches
}

-- The hidden frame that listens for WoW events
local eventFrame = CreateFrame("Frame")

-- Registry of WoW event handlers.
-- Structure: { ["EVENT_NAME"] = { handler1, handler2, ... } }
-- Multiple handlers can register for the same event.
local wowHandlers = {}

-- Registry of addon (internal) event handlers.
-- Same structure as wowHandlers but for our custom events.
local addonHandlers = {}

-- Track whether Init() has been called (prevents double-init)
local initialized = false

---------------------------------------------------------------------------
-- WOW EVENT MANAGEMENT
---------------------------------------------------------------------------

-- Register a handler function for a WoW system event.
-- handler receives: (event, ...) where ... are event-specific args.
-- Wraps the registration in pcall so a protected/removed event doesn't
-- crash the entire addon on a new patch.
function EventBus:RegisterWoWEvent(event, handler)
    -- Block known protected events in 12.0+ to avoid ADDON_ACTION_FORBIDDEN.
    -- WoW fires this enforcement BEFORE pcall can catch it, so we must
    -- prevent the registration entirely rather than trying to recover.
    if BLOCKED_EVENTS[event] then
        ns.RNGeez:Debug("Skipping protected event '%s' (blocked in 12.0+).", event)
        return false
    end

    if not wowHandlers[event] then
        wowHandlers[event] = {}

        -- Tell the frame to actually listen for this event.
        -- pcall protects us if Blizzard removes or protects the event
        -- in a future patch — we'll just silently skip it instead of crashing.
        local success, err = pcall(function()
            eventFrame:RegisterEvent(event)
        end)

        if not success then
            ns.RNGeez:Debug("Failed to register event '%s': %s", event, tostring(err))
            wowHandlers[event] = nil
            return false
        end
    end

    table.insert(wowHandlers[event], handler)
    return true
end

-- Remove a specific handler for a WoW event.
-- If no handlers remain for that event, unregister the frame from it.
function EventBus:UnregisterWoWEvent(event, handler)
    local handlers = wowHandlers[event]
    if not handlers then return end

    for i = #handlers, 1, -1 do
        if handlers[i] == handler then
            table.remove(handlers, i)
            break
        end
    end

    -- If no handlers left, stop listening for this event entirely
    if #handlers == 0 then
        wowHandlers[event] = nil
        pcall(function()
            eventFrame:UnregisterEvent(event)
        end)
    end
end

---------------------------------------------------------------------------
-- ADDON (INTERNAL) EVENT MANAGEMENT
---------------------------------------------------------------------------

-- Register a handler for an internal addon event.
-- These are custom events we fire ourselves (e.g., "TITHE_ATTEMPT_ADDED").
function EventBus:RegisterAddonEvent(event, handler)
    if not addonHandlers[event] then
        addonHandlers[event] = {}
    end
    table.insert(addonHandlers[event], handler)
end

-- Remove a handler for an internal addon event.
function EventBus:UnregisterAddonEvent(event, handler)
    local handlers = addonHandlers[event]
    if not handlers then return end

    for i = #handlers, 1, -1 do
        if handlers[i] == handler then
            table.remove(handlers, i)
            break
        end
    end
end

-- Fire an internal addon event, passing any arguments to all handlers.
function EventBus:FireAddonEvent(event, ...)
    local handlers = addonHandlers[event]
    if not handlers then return end

    for _, handler in ipairs(handlers) do
        -- pcall so one bad handler doesn't break all listeners
        local success, err = pcall(handler, event, ...)
        if not success then
            ns.RNGeez:Debug("Error in addon event handler for '%s': %s", event, tostring(err))
        end
    end
end

---------------------------------------------------------------------------
-- FRAME EVENT DISPATCH
-- This is the single OnEvent handler for our hidden frame.
-- When a WoW event fires, we look up all registered handlers and call them.
---------------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handlers = wowHandlers[event]
    if not handlers then return end

    for _, handler in ipairs(handlers) do
        -- pcall each handler individually so one failure doesn't prevent
        -- other handlers from running. Especially important for combat log
        -- events where Blizzard's "secret value" taint can throw errors.
        local success, err = pcall(handler, event, ...)
        if not success then
            ns.RNGeez:Debug("Error handling WoW event '%s': %s", event, tostring(err))
        end
    end
end)

---------------------------------------------------------------------------
-- ADDON EVENT NAMES
-- Define our internal event names as constants to avoid typos.
-- These are the events modules can listen for.
---------------------------------------------------------------------------
ns.Events = {
    -- Fired when an attempt is counted for an item
    -- Args: (itemName, item, newAttemptCount)
    ATTEMPT_ADDED     = "TITHE_ATTEMPT_ADDED",

    -- Fired when an item is detected as obtained
    -- Args: (itemName, item, totalAttempts)
    ITEM_FOUND        = "TITHE_ITEM_FOUND",

    -- Fired when the detection engine finishes processing a loot event
    -- Args: (none) — UI can use this to refresh displays
    DETECTION_CYCLE   = "TITHE_DETECTION_CYCLE",

    -- Fired when settings change
    -- Args: (settingKey, newValue)
    SETTING_CHANGED   = "TITHE_SETTING_CHANGED",

    -- Fired when custom items are added/removed/edited
    -- Args: (itemName, action) where action = "add", "remove", "edit"
    CUSTOM_ITEM_CHANGED = "TITHE_CUSTOM_ITEM_CHANGED",
}

---------------------------------------------------------------------------
-- INIT
-- Called from Bootstrap.lua during FinishInit().
-- Registers the core WoW events that the detection engine needs.
-- Individual detection handlers will register their own specific events
-- when they initialize.
---------------------------------------------------------------------------
function EventBus:Init()
    if initialized then return end
    initialized = true

    ns.RNGeez:Debug("EventBus initialized.")
end
