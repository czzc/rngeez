--[[
    Data/Spells.lua
    Lookup table of spell IDs the addon needs to track.
    
    When a player casts a spell, we check this table to see if it's relevant.
    If it is, we store what "type" of action it was (Fishing, Mining, etc.)
    so the detection engine knows how to interpret the next loot event.
    
    For example: player casts Fishing (spell 131474) → we flag isFishing = true
    → when LOOT_READY fires, we know the loot came from fishing, not a kill.
    
    These IDs change rarely, but when Blizzard adds a new racial or profession
    variant, a new entry needs to be added here.
]]

local addonName, ns = ...

-- Maps spell ID → action type string
-- Action types: "Fishing", "Mining", "Skinning", "Herb Gathering",
--               "Opening", "Pick Lock", "Disenchanting", "Prospecting",
--               "Milling", "Archaeology"
ns.RelevantSpells = {
    -----------------------------------------------------------------
    -- FISHING
    -- All known fishing spell variants across races and expansions
    -----------------------------------------------------------------
    [131474]  = "Fishing",      -- Base fishing spell
    [131490]  = "Fishing",      -- Fishing (alternate)
    [243756]  = "Fishing",      -- Fishing (Legion+)

    -----------------------------------------------------------------
    -- OPENING
    -- "Opening" is the generic interact-with-world-object spell.
    -- Covers chests, crates, lockboxes, quest objects, etc.
    -----------------------------------------------------------------
    [3365]    = "Opening",       -- Opening (generic)
    [6478]    = "Opening",       -- Opening (alternate)
    [6247]    = "Opening",       -- Opening (alternate)
    [21651]   = "Opening",       -- Opening (alternate)
    [22810]   = "Opening",       -- Opening (alternate)
    [61437]   = "Opening",       -- Opening (alternate)
    [68398]   = "Opening",       -- Opening (alternate)
    [174732]  = "Opening",       -- Opening (WoD+)
    [345071]  = "Opening",       -- Opening (Shadowlands objects)
    [312881]  = "Opening",       -- Searching mailbox (Horrific Visions)

    -----------------------------------------------------------------
    -- MINING
    -----------------------------------------------------------------
    [2575]    = "Mining",        -- Mining (base)
    [195122]  = "Mining",        -- Mining (Legion)
    [366260]  = "Mining",        -- Mining (Dragonflight)

    -----------------------------------------------------------------
    -- SKINNING
    -----------------------------------------------------------------
    [8617]    = "Skinning",      -- Skinning (base)
    [194174]  = "Skinning",      -- Skinning (Legion)
    [366262]  = "Skinning",      -- Skinning (Dragonflight)

    -----------------------------------------------------------------
    -- HERB GATHERING
    -----------------------------------------------------------------
    [2366]    = "Herb Gathering", -- Herb Gathering (base)
    [195114]  = "Herb Gathering", -- Herb Gathering (Legion)
    [366252]  = "Herb Gathering", -- Herb Gathering (Dragonflight)

    -----------------------------------------------------------------
    -- PICK LOCK (Rogue)
    -----------------------------------------------------------------
    [1804]    = "Pick Lock",

    -----------------------------------------------------------------
    -- DISENCHANTING
    -----------------------------------------------------------------
    [13262]   = "Disenchanting",

    -----------------------------------------------------------------
    -- PROSPECTING / MILLING
    -----------------------------------------------------------------
    [31252]   = "Prospecting",
    [51005]   = "Milling",
}

-- Reverse lookup: which action types should PREVENT normal NPC loot detection?
-- If a player is mining a node and gets loot, we don't want to count that as
-- an NPC kill attempt. These spells "override" normal loot handling.
ns.LootBlockingSpellTypes = {
    ["Fishing"]        = true,
    ["Mining"]         = true,
    ["Skinning"]       = true,
    ["Herb Gathering"] = true,
    ["Opening"]        = true,
    ["Pick Lock"]      = true,
    ["Disenchanting"]  = true,
    ["Prospecting"]    = true,
    ["Milling"]        = true,
    ["Archaeology"]    = true,
}
