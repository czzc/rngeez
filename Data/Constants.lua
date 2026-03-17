--[[
    Data/Constants.lua
    Shared constants used across the entire addon.
    Detection methods, expansion categories, instance difficulties, etc.
    
    This file is loaded FIRST (before Core) so all other files can reference
    these values without worrying about load order.
]]

-- Grab the addon namespace table that WoW passes to every file in this addon.
-- addonName = "RNGeez" (string), ns = shared namespace table (empty at first).
-- Every .lua file in the TOC receives the same `ns` table, so it acts as our
-- private cross-file communication channel - like a shared module scope.
local addonName, ns = ...

-- Create the constants sub-table on the namespace
ns.Constants = {}
local C = ns.Constants

---------------------------------------------------------------------------
-- DETECTION METHODS
-- Each tracked item declares one of these to tell the engine HOW to count
-- attempts. The DetectionEngine routes game events to the right handler
-- based on this value.
---------------------------------------------------------------------------
C.Methods = {
    BOSS_KILL   = "BOSS_KILL",   -- Raid/dungeon boss via ENCOUNTER_END
    NPC_KILL    = "NPC_KILL",    -- Specific NPC looted via LOOT_READY
    ZONE_KILL   = "ZONE_KILL",   -- Any NPC kill in a target zone
    FISHING     = "FISHING",     -- Fishing cast in a target zone
    OPEN_NODE   = "OPEN_NODE",   -- Opening a world object (chests, crates, etc.)
    USE_ITEM    = "USE_ITEM",    -- Consuming/opening a bag item
    SPELL_CAST  = "SPELL_CAST",  -- Specific spell successfully cast
    -- STATISTIC is not a detection method - no matcher exists for it.
    -- Items use detection.statisticIds for syncing via StatisticsHandler,
    -- which polls the Blizzard statistics API directly.
    STATISTIC   = "STATISTIC",
}

---------------------------------------------------------------------------
-- ITEM TYPES
-- What category of collectible this item belongs to.
-- Used for filtering in the tooltip and UI.
---------------------------------------------------------------------------
C.ItemTypes = {
    MOUNT = "mount",
    PET   = "pet",
    TOY   = "toy",
    ITEM  = "item",   -- Transmog, recipes, misc drops
}

---------------------------------------------------------------------------
-- EXPANSION CATEGORIES
-- Used for grouping/sorting items in the tooltip.
-- Keys match the category field on item entries.
---------------------------------------------------------------------------
C.Expansions = {
    CLASSIC       = "classic",
    TBC           = "tbc",
    WOTLK         = "wotlk",
    CATA          = "cata",
    MOP           = "mop",
    WOD           = "wod",
    LEGION        = "legion",
    BFA           = "bfa",
    SHADOWLANDS   = "shadowlands",
    DRAGONFLIGHT  = "dragonflight",
    TWW           = "tww",
    MIDNIGHT      = "midnight",
    SPECIAL       = "special",      -- Anniversary events, limited-time, etc.
}

-- Human-readable labels for each expansion (used in UI display)
C.ExpansionLabels = {
    [C.Expansions.CLASSIC]      = "Classic",
    [C.Expansions.TBC]          = "The Burning Crusade",
    [C.Expansions.WOTLK]        = "Wrath of the Lich King",
    [C.Expansions.CATA]         = "Cataclysm",
    [C.Expansions.MOP]          = "Mists of Pandaria",
    [C.Expansions.WOD]          = "Warlords of Draenor",
    [C.Expansions.LEGION]       = "Legion",
    [C.Expansions.BFA]          = "Battle for Azeroth",
    [C.Expansions.SHADOWLANDS]  = "Shadowlands",
    [C.Expansions.DRAGONFLIGHT] = "Dragonflight",
    [C.Expansions.TWW]          = "The War Within",
    [C.Expansions.MIDNIGHT]     = "Midnight",
    [C.Expansions.SPECIAL]      = "Special Events",
}

---------------------------------------------------------------------------
-- INSTANCE DIFFICULTIES
-- Blizzard's difficulty IDs, used to restrict items to specific modes.
-- e.g., a mount that only drops on Mythic would have difficulties = { [16] = true }
---------------------------------------------------------------------------
C.Difficulties = {
    NORMAL_DUNGEON     = 1,
    HEROIC_DUNGEON     = 2,
    RAID_10_NORMAL     = 3,
    RAID_25_NORMAL     = 4,
    RAID_10_HEROIC     = 5,
    RAID_25_HEROIC     = 6,
    LEGACY_LFR         = 7,
    NORMAL_RAID        = 14,
    HEROIC_RAID        = 15,
    MYTHIC_RAID        = 16,
    LFR                = 17,
    MYTHIC_DUNGEON     = 23,
    TIMEWALKING        = 24,
    TIMEWALKING_RAID   = 33,
}

---------------------------------------------------------------------------
-- ADDON COLORS
-- Consistent color palette for all UI elements.
-- Format: { r, g, b } where each value is 0-1.
---------------------------------------------------------------------------
C.Colors = {
    -- Primary accent - a warm gold, like a coin. Fitting for "Tithe."
    ACCENT     = { 0.94, 0.76, 0.20 },  -- #F0C233
    -- Text colors
    WHITE      = { 1.0,  1.0,  1.0  },
    GRAY       = { 0.5,  0.5,  0.5  },
    GREEN      = { 0.2,  1.0,  0.2  },  -- Found / lucky
    RED        = { 1.0,  0.2,  0.2  },  -- Unlucky
    YELLOW     = { 1.0,  1.0,  0.2  },  -- Warnings / highlights
    -- Item quality colors (matching WoW's standard)
    EPIC       = { 0.64, 0.21, 0.93 },
    RARE       = { 0.0,  0.44, 0.87 },
    UNCOMMON   = { 0.12, 1.0,  0.0  },
}

---------------------------------------------------------------------------
-- SAVED VARIABLE KEYS
-- Centralized key names so we don't scatter magic strings everywhere.
---------------------------------------------------------------------------
C.DBKeys = {
    ITEMS      = "items",      -- Shipped item progress data
    CUSTOM     = "custom",     -- User-created item entries
    SETTINGS   = "settings",   -- Addon preferences
    STATS      = "statistics", -- Blizzard statistic snapshots per character
    CHARACTERS = "characters", -- Per-character roster with attempt snapshots
}
