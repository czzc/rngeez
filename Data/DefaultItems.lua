--[[
    Data/DefaultItems.lua
    The shipped item database — curated entries for popular farming targets.
    
    See Bootstrap.lua for merge logic. Detection config comes from here;
    progress data (attempts, found, etc.) lives in SavedVariables.
    
    ENCOUNTER IDs:  (✓) = confirmed live, (?) = needs verification
    SPELL IDs:      Used for collection ownership detection
    STATISTIC IDs:  Used for Blizzard kill-count sync
]]

local addonName, ns = ...
local C = ns.Constants

ns.DefaultItems = {

    ---------------------------------------------------------------------------
    -- THE BURNING CRUSADE
    ---------------------------------------------------------------------------

    ["Ashes of Al'ar"] = {
        itemId = 32458, spellId = 40192,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TBC,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 733 },           -- Kael'thas (✓ confirmed)
            npcIds = { 19622 },
            statisticIds = { 1088 },
        },
    },

    ["Fiery Warhorse's Reins"] = {
        itemId = 30480, spellId = 36702,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TBC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 16152, 15550 },
        },
    },

    ["Reins of the Raven Lord"] = {
        itemId = 32768, spellId = 41252,
        type = C.ItemTypes.MOUNT, chance = 67,
        expansion = C.Expansions.TBC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 23035 },
        },
    },

    ---------------------------------------------------------------------------
    -- WRATH OF THE LICH KING
    ---------------------------------------------------------------------------

    ["Invincible's Reins"] = {
        itemId = 50818, spellId = 72286,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 856 },
            npcIds = { 36597 },
            statisticIds = { 4688 },
            difficulties = { [C.Difficulties.RAID_25_HEROIC] = true },
        },
    },

    ["Mimiron's Head"] = {
        itemId = 45693, spellId = 63796,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1143 },
            npcIds = { 33288 },
            statisticIds = { 2869, 2883 },
        },
    },

    ["Reins of the Blue Proto-Drake"] = {
        itemId = 44151, spellId = 59996,
        type = C.ItemTypes.MOUNT, chance = 77,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 26693, 174062 },
        },
    },

    ["Reins of the Onyxian Drake"] = {
        itemId = 49636, spellId = 69395,
        type = C.ItemTypes.MOUNT, chance = 77,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1084 },
            npcIds = { 10184 },
        },
    },

    ["Reins of the Green Proto-Drake"] = {
        itemId = 44707, spellId = 61294,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 39878 },
        },
    },

    ["Sea Turtle"] = {
        itemId = 46109, spellId = 64731,
        type = C.ItemTypes.MOUNT, chance = 10000,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ---------------------------------------------------------------------------
    -- CATACLYSM
    ---------------------------------------------------------------------------

    ["Experiment 12-B"] = {
        itemId = 78919, spellId = 110039,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1297 },          -- Ultraxion (✓ confirmed)
            npcIds = { 55294 },
            statisticIds = { 6161, 6162 },
        },
    },

    ["Flametalon of Alysrazor"] = {
        itemId = 71665, spellId = 101542,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1206 },          -- (?)
            npcIds = { 52530 },
            statisticIds = { 5970, 5971 },
        },
    },

    ["Reins of the Drake of the South Wind"] = {
        itemId = 63041, spellId = 88744,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1032 },          -- (?)
            npcIds = { 46753 },
            statisticIds = { 5576, 5577 },
        },
    },

    ---------------------------------------------------------------------------
    -- MISTS OF PANDARIA
    ---------------------------------------------------------------------------

    ["Reins of the Astral Cloud Serpent"] = {
        itemId = 87777, spellId = 127170,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1500 },
            npcIds = { 60410 },
            statisticIds = { 6797, 6798, 7924, 7923 },
            difficulties = {
                [C.Difficulties.RAID_10_NORMAL] = true,
                [C.Difficulties.RAID_25_NORMAL] = true,
                [C.Difficulties.RAID_10_HEROIC] = true,
                [C.Difficulties.RAID_25_HEROIC] = true,
            },
        },
    },

    ["Clutch of Ji-Kun"] = {
        itemId = 95059, spellId = 139448,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1573 },
            npcIds = { 69712 },
            statisticIds = { 8171, 8169, 8172, 8170 },
            difficulties = {
                [C.Difficulties.RAID_10_NORMAL] = true,
                [C.Difficulties.RAID_25_NORMAL] = true,
                [C.Difficulties.RAID_10_HEROIC] = true,
                [C.Difficulties.RAID_25_HEROIC] = true,
            },
        },
    },

    ["Reins of the Thundering Cobalt Cloud Serpent"] = {
        itemId = 95057, spellId = 139442,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 69099 },               -- Nalak (world boss)
        },
    },

    ---------------------------------------------------------------------------
    -- WARLORDS OF DRAENOR
    ---------------------------------------------------------------------------

    ["Ironhoof Destroyer"] = {
        itemId = 116660, spellId = 171621,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1748 },
            npcIds = { 77325 },
            statisticIds = { 9365 },
        },
    },

    ---------------------------------------------------------------------------
    -- LEGION
    ---------------------------------------------------------------------------

    ["Midnight's Eternal Reins"] = {
        itemId = 142236, spellId = 229499,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 114262 },
        },
    },

    ---------------------------------------------------------------------------
    -- DRAGONFLIGHT — Raid mounts (now soloable in 12.0)
    ---------------------------------------------------------------------------

    -- Vault of the Incarnates: Raszageth drakewatcher manuscript
    ["Renewed Proto-Drake: Embodiment of the Storm-Eater"] = {
        itemId = 201790, spellId = 0,         -- Customization, not a mount spell
        type = C.ItemTypes.ITEM,              -- It's a manuscript, not a mount
        chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2607 },          -- Raszageth (?)
            npcIds = { 199031 },
        },
    },

    -- Aberrus: Sarkareth drakewatcher manuscript
    ["Highland Drake: Embodiment of the Hellforged"] = {
        itemId = 205876, spellId = 0,
        type = C.ItemTypes.ITEM,
        chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2685 },          -- Sarkareth (?)
            npcIds = { 203284 },
        },
    },

    -- Amirdrassil: Fyrakk mythic mount
    ["Reins of Anu'relos, Flame's Guidance"] = {
        itemId = 210061, spellId = 424484,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2677 },          -- Fyrakk (?)
            npcIds = { 204931 },
            statisticIds = { 19386 },
            difficulties = { [C.Difficulties.MYTHIC_RAID] = true },
        },
    },

    -- Amirdrassil: Fyrakk blazing manuscript (all difficulties)
    ["Renewed Proto-Drake: Embodiment of the Blazing"] = {
        itemId = 210062, spellId = 0,
        type = C.ItemTypes.ITEM,
        chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2677 },          -- Fyrakk (?)
            npcIds = { 204931 },
        },
    },

    -- Dragonflight world drops
    ["Reins of the Liberated Slyvern"] = {
        itemId = 201440, spellId = 359622,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 195353 },              -- Breezebiter
        },
    },

    ["Cobalt Shalewing"] = {
        itemId = 205203, spellId = 408647,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 203625 },              -- Karokta
        },
    },

    ---------------------------------------------------------------------------
    -- THE WAR WITHIN — Raid mounts
    ---------------------------------------------------------------------------

    ["Reins of the Sureki Skyrazor"] = {
        itemId = 224147, spellId = 451486,
        type = C.ItemTypes.MOUNT, chance = 150,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2922 },          -- Queen Ansurek (?)
            npcIds = { 218370 },
            statisticIds = { 40295, 40296, 40297, 40298 },
        },
    },

    ["Prototype A.S.M.R."] = {
        itemId = 236960, spellId = 1221155,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2963 },          -- Chrome King Gallywix (?)
            npcIds = { 241526 },
            statisticIds = { 41330, 41329, 41328, 41327 },
            difficulties = {
                [C.Difficulties.NORMAL_RAID] = true,
                [C.Difficulties.HEROIC_RAID] = true,
                [C.Difficulties.MYTHIC_RAID] = true,
                [C.Difficulties.LFR] = true,
            },
        },
    },

    -- TWW world drops
    ["Beledar's Spawn"] = {
        itemId = 223315, spellId = 448941,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 207802 },
        },
    },

    ["Regurgitated Mole Reins"] = {
        itemId = 223501, spellId = 449258,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 220285 },
        },
    },

    ["Salvaged Goblin Gazillionaire's Flying Machine"] = {
        itemId = 229953, spellId = 466026,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 234621 },              -- Gallagio Garbage
        },
    },

    ["Darkfuse Spy-Eye"] = {
        itemId = 229955, spellId = 466027,
        type = C.ItemTypes.MOUNT, chance = 25,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 231310 },              -- Darkfuse Precipitant
        },
    },

    ---------------------------------------------------------------------------
    -- MIDNIGHT — Raid mount
    ---------------------------------------------------------------------------

    ["Ashes of Belo'ren"] = {
        itemId = 0, spellId = 1242904,        -- Item ID TBD (raid not open yet)
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            -- March on Quel'Danas: Midnight Falls (Mythic only)
            -- Encounter ID needs verification when raid opens March 31
            encounterIds = {},
            npcIds = {},
            difficulties = { [C.Difficulties.MYTHIC_RAID] = true },
        },
    },

    ---------------------------------------------------------------------------
    -- MIDNIGHT — Zone rare drops (ZONE_KILL: any rare in the zone)
    -- Map IDs confirmed by Zac in-game
    ---------------------------------------------------------------------------

    ["Cerulean Hawkstrider"] = {
        itemId = 257156, spellId = 0,         -- Spell ID TBD
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2395 },               -- Eversong Woods (✓ confirmed)
        },
    },

    ["Cobalt Dragonhawk"] = {
        itemId = 257147, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2395 },               -- Eversong Woods (✓ confirmed)
        },
    },

    ["Amani Sharptalon"] = {
        itemId = 257152, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2437, 2536 },               -- Zul'Aman (✓ confirmed)
        },
    },

    ["Escaped Witherbark Pango"] = {
        itemId = 257200, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2437, 2536 },               -- Zul'Aman (✓ confirmed)
        },
    },

    ["Rootstalker Grimlynx"] = {
        itemId = 246735, spellId = 0, -- TODO Phase 3: look up real spellId (0 breaks ownership detection)
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2413 },               -- Harandar
        },
    },

    ["Vibrant Petalwing"] = {
        itemId = 252012, spellId = 0, -- TODO Phase 3: look up real spellId (0 breaks ownership detection)
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2413 },               -- Harandar
        },
    },

    ["Augmented Stormray"] = {
        itemId = 257085, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2405 },               -- Voidstorm (✓ confirmed)
        },
    },

    ["Sanguine Harrower"] = {
        itemId = 260635, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.ZONE_KILL,
            requiresRare = true,
            mapIds = { 2405 },               -- Voidstorm (✓ confirmed)
        },
    },

    ---------------------------------------------------------------------------
    -- MIDNIGHT — Special drops
    ---------------------------------------------------------------------------

    -- Hatches from Nether-Warped Egg after 7 days
    ["Nether-Warped Drake"] = {
        itemId = 260916, spellId = 0,
        type = C.ItemTypes.MOUNT, chance = 1,  -- Guaranteed from egg? TBD
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 268730 },        -- Nether-Warped Egg
        },
    },

    -- Fishing in Voidstorm
    ["Lost Nether Drake"] = {
        itemId = 268730, spellId = 0,          -- This is the egg item
        type = C.ItemTypes.MOUNT, chance = 1000,  -- Drop rate TBD, likely rare
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.FISHING,
            mapIds = { 2405 },               -- Voidstorm (✓ confirmed)
        },
    },



}

-- ---------------------------------------------------------------------------
-- AUTO-GENERATED ENTRIES
-- Added by generate-items.js on 2026-03-05T16:50:11.758Z
-- 179 new mounts from DB2 data
-- NPC IDs marked TODO need in-game verification
-- 
-- Split into multiple tables to avoid WoW Lua's
-- "function or expression too complex" limit.
-- ---------------------------------------------------------------------------

local generatedItems_1 = {

    ["Felsteel Annihilator"] = {
        itemId = 123890, spellId = 182912,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1799 },  -- Archimonde (Hellfire Citadel)
            statisticIds = {},
        },
    },

    ["Kor'kron Juggernaut"] = {
        itemId = 104253, spellId = 148417,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1623 },  -- Garrosh Hellscream (Siege of Orgrimmar)
            statisticIds = {},
        },
    },

    ["Deathcharger's Reins"] = {
        itemId = 13335, spellId = 17481,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CLASSIC,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 484 },  -- Lord Aurius Rivendare (Stratholme - Service Entrance)
            statisticIds = {},
        },
    },

    ["Swift White Hawkstrider"] = {
        itemId = 35513, spellId = 46628,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.TBC,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1894 },  -- Kael'thas Sunstrider (Magisters' Terrace)
            statisticIds = {},
        },
    },

    ["Reins of the Azure Drake"] = {
        itemId = 43952, spellId = 59567,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1094 },  -- Malygos (The Eye of Eternity)
            statisticIds = {},
        },
    },

    ["Reins of the Blue Drake"] = {
        itemId = 43953, spellId = 59568,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1094 },  -- Malygos (The Eye of Eternity)
            statisticIds = {},
        },
    },

    ["Reins of the Twilight Drake"] = {
        itemId = 43954, spellId = 59571,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1090 },  -- Sartharion (The Obsidian Sanctum)
            statisticIds = {},
        },
    },

    ["Reins of the Black Drake"] = {
        itemId = 43986, spellId = 59650,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1090 },  -- Sartharion (The Obsidian Sanctum)
            statisticIds = {},
        },
    },

    ["Reins of the Grand Black War Mammoth"] = {
        itemId = 43959, spellId = 61465,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1126, 1127, 1128, 1129 },  -- Archavon the Stone Watcher, Emalon the Storm Watcher, Koralon the Flame Watcher, Toravon the Ice Watcher (Vault of Archavon)
            statisticIds = {},
        },
    },

    ["Reins of the Blazing Drake"] = {
        itemId = 77067, spellId = 107842,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1299 },  -- Madness of Deathwing (Dragon Soul)
            statisticIds = {},
        },
    },

    ["Life-Binder's Handmaiden"] = {
        itemId = 77069, spellId = 107845,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1299 },  -- Madness of Deathwing (Dragon Soul)
            statisticIds = {},
        },
    },

    ["Smoldering Egg of Millagazor"] = {
        itemId = 69224, spellId = 97493,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1203 },  -- Ragnaros (Firelands)
            statisticIds = {},
        },
    },

    ["Reins of the Vitreous Stone Drake"] = {
        itemId = 63043, spellId = 88746,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1059 },  -- Slabhide (The Stonecore)
            statisticIds = {},
        },
    },

    ["Reins of the Drake of the North Wind"] = {
        itemId = 63040, spellId = 88742,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1041 },  -- Altairus (The Vortex Pinnacle)
            statisticIds = {},
        },
    },

    ["Armored Razzashi Raptor"] = {
        itemId = 68823, spellId = 96491,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1179 },  -- Bloodlord Mandokir (Zul'Gurub)
            statisticIds = {},
        },
    },

    ["Swift Zulian Panther"] = {
        itemId = 68824, spellId = 96499,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1180 },  -- High Priestess Kilnara (Zul'Gurub)
            statisticIds = {},
        },
    },

    ["Spawn of Horridon"] = {
        itemId = 93666, spellId = 136471,
        type = C.ItemTypes.MOUNT, chance = 66,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1575 },  -- Horridon (Throne of Thunder)
            statisticIds = {},
        },
    },

    ["Fiendish Hellfire Core"] = {
        itemId = 137575, spellId = 171827,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1866 },  -- Gul'dan (The Nighthold)
            statisticIds = {},
        },
    },

    ["Living Infernal Core"] = {
        itemId = 137574, spellId = 213134,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 1866 },  -- Gul'dan (The Nighthold)
            statisticIds = {},
        },
    },

    ["Abyss Worm"] = {
        itemId = 143643, spellId = 232519,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2037 },  -- Mistress Sassz'ine (Tomb of Sargeras)
            statisticIds = {},
        },
    },

    ["G.M.O.D."] = {
        itemId = 166518, spellId = 289083,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2276, 2281 },  -- High Tinker Mekkatorque, Lady Jaina Proudmoore (Battle of Dazar'alor)
            statisticIds = {},
        },
    },

    ["Glacial Tidestorm"] = {
        itemId = 166705, spellId = 289555,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2281 },  -- Lady Jaina Proudmoore (Battle of Dazar'alor)
            statisticIds = {},
        },
    },

    ["Sharkbait's Favorite Crackers"] = {
        itemId = 159842, spellId = 254813,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2096 },  -- Harlan Sweete (Freehold)
            statisticIds = {},
        },
    },

    ["Ny'alotha Allseer"] = {
        itemId = 174872, spellId = 308814,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2344 },  -- N'Zoth the Corruptor (Ny'alotha, the Waking City)
            statisticIds = {},
        },
    },

    ["Mechagon Peacekeeper"] = {
        itemId = 168826, spellId = 299158,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2291 },  -- HK-8 Aerial Oppression Unit (Operation: Mechagon)
            statisticIds = {},
        },
    },

    ["Underrot Crawg Harness"] = {
        itemId = 160829, spellId = 273541,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2123 },  -- Unbound Abomination (The Underrot)
            statisticIds = {},
        },
    },

    ["Vengeance's Reins"] = {
        itemId = 186642, spellId = 351195,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2435 },  -- Sylvanas Windrunner (Sanctum of Domination)
            statisticIds = {},
        },
    },

    ["Sanctum Gloomcharger's Reins"] = {
        itemId = 186656, spellId = 354351,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2429 },  -- The Nine (Sanctum of Domination)
            statisticIds = {},
        },
    },

    ["Fractal Cypher of the Zereth Overseer"] = {
        itemId = 190768, spellId = 368158,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2537 },  -- The Jailer (Sepulcher of the First Ones)
            statisticIds = {},
        },
    },

    ["Cartel Master's Gearglider"] = {
        itemId = 186638, spellId = 353263,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2442 },  -- So'leah (Tazavesh, the Veiled Market)
            statisticIds = {},
        },
    },

    ["Marrowfang's Reins"] = {
        itemId = 181819, spellId = 336036,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2390 },  -- Nalthor the Rimebinder (The Necrotic Wake)
            statisticIds = {},
        },
    },

    ["Wick's Lead"] = {
        itemId = 225548, spellId = 449264,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2788 },  -- The Darkness (Darkflame Cleft)
            statisticIds = {},
        },
    },

    ["Reins of the Ascendant Skyrazor"] = {
        itemId = 224151, spellId = 451491,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 2922 },  -- Queen Ansurek (Nerub-ar Palace)
            statisticIds = {},
        },
    },

    ["Keys to the Big G"] = {
        itemId = 235626, spellId = 1217760,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 3016 },  -- Chrome King Gallywix (Liberation of Undermine)
            statisticIds = {},
        },
    },

    ["Lucent Hawkstrider"] = {
        itemId = 260231, spellId = 1265784,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 3074 },  -- Degentrius (Magisters' Terrace)
            statisticIds = {},
        },
    },

    ["Unbound Star-Eater"] = {
        itemId = 243061, spellId = 1234573,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 3135 },  -- Dimensius, the All-Devouring (Manaforge Omega)
            statisticIds = {},
        },
    },

    ["Spectral Hawkstrider"] = {
        itemId = 262914, spellId = 1263635,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = { 3059 },  -- The Restless Heart (Windrunner Spire)
            statisticIds = {},
        },
    },

    ["Pond Nettle"] = {
        itemId = 152912, spellId = 253711,
        type = C.ItemTypes.MOUNT, chance = 2000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ["Great Sea Ray"] = {
        itemId = 163131, spellId = 278803,
        type = C.ItemTypes.MOUNT, chance = 10000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ["Reins of the White Polar Bear"] = {
        itemId = 43962, spellId = 54753,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 44751 },  -- Hyldnir Spoils
        },
    },

    ["Amani Battle Bear"] = {
        itemId = 69747, spellId = 98204,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},  -- TODO: find item ID for "Kasha's Bag"
        },
    },

    ["Reins of the Red Primal Raptor"] = {
        itemId = 94291, spellId = 138641,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 94296 },  -- Cracked Primal Egg
        },
    },

    ["Reins of the Black Primal Raptor"] = {
        itemId = 94292, spellId = 138642,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 94296 },  -- Cracked Primal Egg
        },
    },

    ["Reins of the Green Primal Raptor"] = {
        itemId = 94293, spellId = 138643,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 94296 },  -- Cracked Primal Egg
        },
    },

    ["Voidtalon of the Dark Star"] = {
        itemId = 121815, spellId = 179478,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},  -- TODO: find item ID for "Voidtalon Egg"
        },
    },

    ["Leywoven Flying Carpet"] = {
        itemId = 143764, spellId = 233364,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 146900 },  -- Nightfallen Cache
        },
    },

    ["Darkspore Mana Ray"] = {
        itemId = 152843, spellId = 235764,
        type = C.ItemTypes.MOUNT, chance = 16,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 153190 },  -- Fel-Spotted Egg
        },
    },

    ["Wild Dreamrunner"] = {
        itemId = 147804, spellId = 242875,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 146898 },  -- Dreamweaver Cache
        },
    },

    ["Vibrant Mana Ray"] = {
        itemId = 152842, spellId = 253106,
        type = C.ItemTypes.MOUNT, chance = 16,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 153190 },  -- Fel-Spotted Egg
        },
    },

    ["Felglow Mana Ray"] = {
        itemId = 152841, spellId = 253108,
        type = C.ItemTypes.MOUNT, chance = 16,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 153190 },  -- Fel-Spotted Egg
        },
    },

    ["Scintillating Mana Ray"] = {
        itemId = 152840, spellId = 253109,
        type = C.ItemTypes.MOUNT, chance = 16,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 153190 },  -- Fel-Spotted Egg
        },
    },

    ["Bulbous Necroray"] = {
        itemId = 184160, spellId = 344574,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 184158 },  -- Oozing Necroray Egg
        },
    },

    ["Infested Necroray"] = {
        itemId = 184161, spellId = 344576,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 184158 },  -- Oozing Necroray Egg
        },
    },

    ["Pestilent Necroray"] = {
        itemId = 184162, spellId = 344575,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 184158 },  -- Oozing Necroray Egg
        },
    },

    ["Zenet Hatchling"] = {
        itemId = 198825, spellId = 385266,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 200879 },  -- Zenet Egg
        },
    },

    ["Reins of the Winter Night Dreamsaber"] = {
        itemId = 210059, spellId = 424476,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},  -- TODO: find item ID for "Dreamseed Cache"
        },
    },

    ["Shadowbound Leash"] = {
        itemId = 239563, spellId = 1228865,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 239546 },  -- Confiscated Cultist's Bag
        },
    },

    ["Curious Slateback"] = {
        itemId = 242734, spellId = 1233561,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},  -- TODO: find item ID for "Wriggling Pinnacle Cache"
        },
    },

    ["Reins of the Contained Stormarion Defender"] = {
        itemId = 257180, spellId = 1261334,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = { 260979 },  -- Victorious Stormarion Cache
        },
    },

}
for name, data in pairs(generatedItems_1) do
    ns.DefaultItems[name] = data
end

local generatedItems_2 = {

    ["Blue Qiraji Resonating Crystal"] = {
        itemId = 21218, spellId = 25953,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CLASSIC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: World Drop in Temple of Ahn'Qiraj
        },
    },

    ["Red Qiraji Resonating Crystal"] = {
        itemId = 21321, spellId = 26054,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CLASSIC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 15311, 15250, 15247, 15246, 15264, 15262, 15277, 15312, 15252, 15249 },  -- World Drop in Temple of Ahn'Qiraj
        },
    },

    ["Yellow Qiraji Resonating Crystal"] = {
        itemId = 21324, spellId = 26055,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CLASSIC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: World Drop in Temple of Ahn'Qiraj
        },
    },

    ["Green Qiraji Resonating Crystal"] = {
        itemId = 21323, spellId = 26056,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CLASSIC,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: World Drop in Temple of Ahn'Qiraj
        },
    },

    ["Reins of the Bronze Drake"] = {
        itemId = 43951, spellId = 59569,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Infinite Corruptor in The Culling of Stratholme
        },
    },

    ["Reins of the Time-Lost Proto-Drake"] = {
        itemId = 44168, spellId = 60002,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOTLK,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time-Lost Proto-Drake in The Storm Peaks
        },
    },

    ["Illidari Doomhawk"] = {
        itemId = 186469, spellId = 62048,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SPECIAL,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Doomwalker in Tanaris
        },
    },

    ["Reins of the Phosphorescent Stone Drake"] = {
        itemId = 63042, spellId = 88718,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Aeonaxx in Deepholm
        },
    },

    ["Reins of the Grey Riding Camel"] = {
        itemId = 63046, spellId = 88750,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 43214 },  -- Dormus the Camel-Hoarder in Feralas
        },
    },

    ["Reins of Poseidus"] = {
        itemId = 67151, spellId = 98718,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Poseidus in Vashj'ir
        },
    },

    ["Reins of the Heavenly Onyx Cloud Serpent"] = {
        itemId = 87771, spellId = 127158,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Sha of Anger in Kun-Lai Summit
        },
    },

    ["Son of Galleon's Saddle"] = {
        itemId = 89783, spellId = 130965,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Galleon in Valley of the Four Winds
        },
    },

    ["Reins of the Thundering Ruby Cloud Serpent"] = {
        itemId = 224374, spellId = 132036,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Alani in Vale of Eternal Blossoms
        },
    },

    ["Reins of the Cobalt Primordial Direhorn"] = {
        itemId = 94228, spellId = 138423,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Oondasta in Isle of Giants
        },
    },

    ["Reins of the Amber Primordial Direhorn"] = {
        itemId = 94230, spellId = 138424,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 69841 },  -- Zandalari Warbringer in Dread Wastes, Kun-Lai Summit, Townlong Steppes, Valley of the Four Winds
        },
    },

    ["Reins of the Slate Primordial Direhorn"] = {
        itemId = 94229, spellId = 138425,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 69769 },  -- Zandalari Warbringer in Dread Wastes, Krasarang Wilds, Kun-Lai Summit, Townlong Steppes, Valley of the Four Winds
        },
    },

    ["Reins of the Jade Primordial Direhorn"] = {
        itemId = 94231, spellId = 138426,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 69842 },  -- Zandalari Warbringer in Dread Wastes, Kun-Lai Summit, Townlong Steppes, Valley of the Four Winds
        },
    },

    ["Reins of the Thundering Onyx Cloud Serpent"] = {
        itemId = 104269, spellId = 148476,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 73167 },  -- Huolon in Timeless Isle
        },
    },

    ["Tundra Icehoof"] = {
        itemId = 116658, spellId = 171619,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 95044, 95054, 95053, 95056 },  -- Vengeance, Deathtalon, Terrorfist, Doomroller in Tanaan Jungle
        },
    },

    ["Bloodhoof Bull"] = {
        itemId = 116659, spellId = 171620,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Nakk the Thunderer in Nagrand
        },
    },

    ["Mottled Meadowstomper"] = {
        itemId = 116661, spellId = 171622,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Luk'hok in Nagrand
        },
    },

    ["Armored Razorback"] = {
        itemId = 116669, spellId = 171630,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 95044, 95054, 95053, 95056 },  -- Vengeance, Deathtalon, Terrorfist, Doomroller in Tanaan Jungle
        },
    },

    ["Great Greytusk"] = {
        itemId = 116674, spellId = 171636,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Gorok in Frostfire Ridge
        },
    },

    ["Sapphire Riverbeast"] = {
        itemId = 116767, spellId = 171824,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Silthide in Talador
        },
    },

    ["Swift Breezestrider"] = {
        itemId = 116773, spellId = 171830,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Pathrunner in Shadowmoon Valley
        },
    },

    ["Warsong Direfang"] = {
        itemId = 116780, spellId = 171837,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 95044, 95054, 95053, 95056 },  -- Vengeance, Deathtalon, Terrorfist, Doomroller in Tanaan Jungle
        },
    },

    ["Sunhide Gronnling"] = {
        itemId = 116792, spellId = 171849,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Poundfist in Gorgrond
        },
    },

    ["Garn Nighthowl"] = {
        itemId = 116794, spellId = 171851,
        type = C.ItemTypes.MOUNT, chance = 1,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 81001 },  -- Nok-Karosh in Frostfire Ridge
        },
    },

    ["Mastercraft Gravewing"] = {
        itemId = 186479, spellId = 215545,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Stygian Stonecrusher in Korthia
        },
    },

    ["Shadowy Reins of the Accursed Wrathsteed"] = {
        itemId = 142233, spellId = 238454,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Lord Hel'Nurath in Broken Shore
        },
    },

    ["Maddened Chaosrunner"] = {
        itemId = 152814, spellId = 253058,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 126852 },  -- Wrangler Kravos in Eredath
        },
    },

    ["Antoran Charhound"] = {
        itemId = 152816, spellId = 253088,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Shatug in Antorus, the Burning Throne
        },
    },

    ["Lambent Mana Ray"] = {
        itemId = 152844, spellId = 253107,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 126867 },  -- Venomtail Skyfin in Eredath
        },
    },

    ["Crimson Slavermaw"] = {
        itemId = 152905, spellId = 253661,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 122958 },  -- Blistermaw in Antoran Wastes
        },
    },

    ["Acid Belcher"] = {
        itemId = 152904, spellId = 253662,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 126912 },  -- Skreeg the Devourer in Eredath
        },
    },

    ["Mummified Raptor Skull"] = {
        itemId = 159921, spellId = 266058,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: King Dazar in Kings' Rest
        },
    },

    ["Nazjatar Blood Serpent"] = {
        itemId = 161479, spellId = 275623,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Adherent of the Abyss in Stormsong Valley
        },
    },

    ["Broken Highland Mustang"] = {
        itemId = 163578, spellId = 279457,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142739 },  -- Knight-Captain Aldrin in Arathi Highlands
        },
    },

    ["Highland Mustang"] = {
        itemId = 163579, spellId = 279456,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142741 },  -- Doomrider Helgrim in Arathi Highlands
        },
    },

    ["Swift Albino Raptor"] = {
        itemId = 163644, spellId = 279569,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142709 },  -- Beastrider Kama in Arathi Highlands
        },
    },

    ["Lil' Donkey"] = {
        itemId = 163646, spellId = 279608,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142423 },  -- Overseer Krix in Arathi Highlands
        },
    },

    ["Skullripper"] = {
        itemId = 163645, spellId = 279611,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142437 },  -- Skullripper in Arathi Highlands
        },
    },

    ["Witherbark Direwing"] = {
        itemId = 163706, spellId = 279868,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 142692 },  -- Nimar the Slayer in Arathi Highlands
        },
    },

    ["Caged Bear"] = {
        itemId = 166438, spellId = 288438,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 149652 },  -- Blackpaw in Darkshore
        },
    },

    ["Ashenvale Chimaera"] = {
        itemId = 166432, spellId = 288495,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 148787 },  -- Alash'anir in Darkshore
        },
    },

    ["Frightened Kodo"] = {
        itemId = 166433, spellId = 288499,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Frightened Kodo in Darkshore
        },
    },

    ["Umber Nightsaber"] = {
        itemId = 166803, spellId = 288503,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 148037 },  -- Athil Dewfire in Darkshore
        },
    },

    ["Captured Kaldorei Nightsaber"] = {
        itemId = 166437, spellId = 288505,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 149655 },  -- Shadowclaw in Darkshore
        },
    },

    ["Rusted Keys to the Junkheap Drifter"] = {
        itemId = 168370, spellId = 297157,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 152182 },  -- Rustfeather in Mechagon
        },
    },

    ["Slightly Damp Pile of Fur"] = {
        itemId = 174842, spellId = 298367,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 138794 },  -- Dunegorger Kraulok in Vol'dun
        },
    },

    ["Silent Glider"] = {
        itemId = 169163, spellId = 300149,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 152290 },  -- Soundless in Nazjatar
        },
    },

    ["Clutch of Ha-Li"] = {
        itemId = 173887, spellId = 312751,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157153 },  -- Ha-Li in Vale of Eternal Blossoms
        },
    },

    ["Mawsworn Soulhunter"] = {
        itemId = 184167, spellId = 312762,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 174861 },  -- Gorged Shadehound in The Maw
        },
    },

    ["Swift Gloomhoof"] = {
        itemId = 180728, spellId = 312767,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Night Mare in Ardenweald
        },
    },

    ["Sundancer"] = {
        itemId = 180773, spellId = 312765,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Sundancer in Bastion
        },
    },

    ["Horrid Dredwing"] = {
        itemId = 180461, spellId = 332882,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 165290 },  -- Harika the Horrid in Revendreth
        },
    },

    ["Ivory Cloud Serpent"] = {
        itemId = 174752, spellId = 315014,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Ivory Cloud Serpent in Vale of Eternal Blossoms
        },
    },

    ["Reins of the Drake of the Four Winds"] = {
        itemId = 174641, spellId = 315847,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157134 },  -- Ishak of the Four Winds in Uldum
        },
    },

}
for name, data in pairs(generatedItems_2) do
    ns.DefaultItems[name] = data
end

local generatedItems_3 = {

    ["Mail Muncher"] = {
        itemId = 174653, spellId = 315987,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 160708 },  -- Mail Muncher in Horrific Visions
        },
    },

    ["Waste Marauder"] = {
        itemId = 174753, spellId = 316275,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157146 },  -- Rotfeaster in Uldum
        },
    },

    ["Malevolent Drone"] = {
        itemId = 174769, spellId = 316337,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162147 },  -- Corpse Eater in Uldum
        },
    },

    ["Ren's Stalwart Hound"] = {
        itemId = 174841, spellId = 316722,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157160 },  -- Houndlord Ren in Vale of Eternal Blossoms
        },
    },

    ["Xinlao"] = {
        itemId = 174840, spellId = 316723,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157466 },  -- Anh-De the Loyal in Vale of Eternal Blossoms
        },
    },

    ["Reins of the Colossal Slaughterclaw"] = {
        itemId = 182081, spellId = 327405,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Supplies of the Undying Army in Maldraxxus
        },
    },

    ["Spinemaw Gladechewer"] = {
        itemId = 180725, spellId = 334364,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Gormtamer Tizo in Ardenweald
        },
    },

    ["Bonehoof Tauralus"] = {
        itemId = 182075, spellId = 332457,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162586 },  -- Tahonta in Maldraxxus
        },
    },

    ["Armored Bonehoof Tauralus"] = {
        itemId = 181815, spellId = 332466,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 168147 },  -- Sabriel the Bonecleaver in Maldraxxus
        },
    },

    ["Blisterback Bloodtusk"] = {
        itemId = 182085, spellId = 332478,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162819 },  -- Warbringer Mal'korak in Maldraxxus
        },
    },

    ["Gorespine"] = {
        itemId = 182084, spellId = 332480,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162690 },  -- Nerissa Heartless in Maldraxxus
        },
    },

    ["Harvester's Dredwing Saddle"] = {
        itemId = 185996, spellId = 332904,
        type = C.ItemTypes.MOUNT, chance = 25,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Harvester's War Chest in The Maw
        },
    },

    ["Endmire Flyer Tether"] = {
        itemId = 180582, spellId = 332905,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 166521 },  -- Famu the Infinite in Revendreth
        },
    },

    ["Wild Glimmerfur Prowler"] = {
        itemId = 180730, spellId = 334366,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 168647 },  -- Valfir the Unrelenting in Ardenweald
        },
    },

    ["Slime-Covered Reins of the Hulking Deathroc"] = {
        itemId = 182079, spellId = 336042,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 157309 },  -- Violet Mistake in Maldraxxus
        },
    },

    ["Predatory Plagueroc"] = {
        itemId = 182080, spellId = 336045,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162741 },  -- Gieger in Maldraxxus
        },
    },

    ["Arboreal Gulper"] = {
        itemId = 182650, spellId = 339632,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Humon'gozz in Ardenweald
        },
    },

    ["Amber Ardenmoth"] = {
        itemId = 183800, spellId = 342666,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Wild Hunt Supplies in Ardenweald
        },
    },

    ["Deepstar Polyp"] = {
        itemId = 187676, spellId = 342680,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 180978 },  -- Hirukon in Zereth Mortis
        },
    },

    ["Gnawed Reins of the Battle-Bound Warhound"] = {
        itemId = 184062, spellId = 344228,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 162873, 162880, 162875, 162853, 162874, 162872 },  -- Theater of Pain in Maldraxxus
        },
    },

    ["Lord of the Corpseflies"] = {
        itemId = 186489, spellId = 347250,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Fleshwing in Korthia
        },
    },

    ["Tamed Mauler Harness"] = {
        itemId = 186641, spellId = 347536,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179472 },  -- Supplies of the Archivist's Codex in Korthia
        },
    },

    ["Beryl Shardhide"] = {
        itemId = 186644, spellId = 347810,
        type = C.ItemTypes.MOUNT, chance = 8,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Death's Advance Supplies in Korthia
        },
    },

    ["Chain of Bahmethra"] = {
        itemId = 185973, spellId = 352309,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179472 },  -- Tormentors of Torghast in The Maw
        },
    },

    ["Legsplitter War Harness"] = {
        itemId = 186000, spellId = 352441,
        type = C.ItemTypes.MOUNT, chance = 25,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: War Chest of the Wild Hunt in The Maw
        },
    },

    ["Undying Darkhound's Harness"] = {
        itemId = 186103, spellId = 352742,
        type = C.ItemTypes.MOUNT, chance = 25,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: War Chest of the Undying Army in The Maw
        },
    },

    ["Summer Wilderling Harness"] = {
        itemId = 186492, spellId = 353859,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Escaped Wilderling in Korthia
        },
    },

    ["Forsworn Aquilon"] = {
        itemId = 186483, spellId = 353877,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Wild Worldcracker in Korthia
        },
    },

    ["Soulbound Gloomcharger's Reins"] = {
        itemId = 186657, spellId = 354352,
        type = C.ItemTypes.MOUNT, chance = 8,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179472 },  -- Mysterious Gift from Ve'nari in The Maw
        },
    },

    ["Fallen Charger's Reins"] = {
        itemId = 186659, spellId = 354353,
        type = C.ItemTypes.MOUNT, chance = 7,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179460 },  -- Fallen Charger in The Maw
        },
    },

    ["Crimson Shardhide"] = {
        itemId = 186645, spellId = 354357,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179684 },  -- Malbog in Korthia
        },
    },

    ["Fierce Razorwing"] = {
        itemId = 186649, spellId = 354359,
        type = C.ItemTypes.MOUNT, chance = 8,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Death's Advance Supplies in Korthia
        },
    },

    ["Garnet Razorwing"] = {
        itemId = 186652, spellId = 354360,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 180160 },  -- Reliwik the Defiant in Korthia
        },
    },

    ["Rampaging Mauler"] = {
        itemId = 187183, spellId = 356501,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179472 },  -- Konthrogz the Obliterator in Korthia
        },
    },

    ["Sturdy Silver Mawrat Harness"] = {
        itemId = 188700, spellId = 363178,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179433, 176578, 169859, 159755, 153165, 171422, 153451, 159190, 151329, 151331, 155945, 170418, 156239, 155250, 155251, 157122, 153174, 156015, 185027, 185028, 153011 },  -- Torghast Layers 13 or higher in Torghast
        },
    },

    ["Horn of the White War Wolf"] = {
        itemId = 206673, spellId = 414316,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Reins of the Ravenous Black Gryphon"] = {
        itemId = 206674, spellId = 414323,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Gold-Toed Albatross"] = {
        itemId = 206675, spellId = 414324,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Felstorm Dragon"] = {
        itemId = 206676, spellId = 414326,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Sulfur Hound's Leash"] = {
        itemId = 206678, spellId = 414327,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Perfected Juggernaut"] = {
        itemId = 206679, spellId = 414328,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Reins of the Scourgebound Vanquisher"] = {
        itemId = 206680, spellId = 414334,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Time Rifts in Tyrhold Reservoir
        },
    },

    ["Azure Worldchiller"] = {
        itemId = 208572, spellId = 420097,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SPECIAL,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Doomwalker in Tanaris
        },
    },

    ["Alunira"] = {
        itemId = 223270, spellId = 447213,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 234621 },  -- Alunira in Isle of Dorn
        },
    },

    ["Dauntless Imperial Lynx"] = {
        itemId = 223318, spellId = 448979,
        type = C.ItemTypes.MOUNT, chance = 150,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 234621 },  -- Spreading the Light in Hallowfall
        },
    },

    ["Blackwater Bonecrusher"] = {
        itemId = 229937, spellId = 466001,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Blackwater Trove in Undermine
        },
    },

    ["Venture Co-ordinator"] = {
        itemId = 229951, spellId = 466022,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 239581 },  -- Venture Co. Trove in Undermine
        },
    },

    ["Bilgewater Bombardier"] = {
        itemId = 229957, spellId = 466024,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Bilgewater Trove in Undermine
        },
    },

    ["Violet Goblin Shredder"] = {
        itemId = 229947, spellId = 466021,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Shipping and Handling in Undermine
        },
    },

    ["Bronze Goblin Waveshredder"] = {
        itemId = 233064, spellId = 473188,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Darkfuse Trove in Undermine
        },
    },

    ["Reins of the Void-Scarred Gryphon"] = {
        itemId = 235700, spellId = 1218229,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Void-Scarred Gryphon in Vision of Stormwind (Revisited)
        },
    },

    ["Void-Forged Stallion's Reins"] = {
        itemId = 235705, spellId = 1218305,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Void-Forged Stallion in Vision of Stormwind (Revisited)
        },
    },

    ["Void-Scarred Pack Mother's Harness"] = {
        itemId = 235706, spellId = 1218306,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Void-Scarred Pack Mother in Vision of Orgrimmar (Revisited)
        },
    },

    ["Reins of the Void-Scarred Windrider"] = {
        itemId = 235707, spellId = 1218307,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Void-Scarred Windrider in Vision of Orgrimmar (Revisited)
        },
    },

    ["Pearlescent Krolusk"] = {
        itemId = 246067, spellId = 1240632,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 232195 },  -- Urmag in K'aresh
        },
    },

    ["Translocated Gorger"] = {
        itemId = 246159, spellId = 1241070,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Devourer Swarms in Tazavesh
        },
    },

    ["Sthaarbs's Last Lunch"] = {
        itemId = 246160, spellId = 1241076,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 234845 },  -- Sthaarbs in K'aresh
        },
    },

    ["Echo of Aln'sharan"] = {
        itemId = 256424, spellId = 1260356,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Aln'Sharan in Harandar
        },
    },

    ["Duskbrute Harrower"] = {
        itemId = 257176, spellId = 1261332,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MIDNIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},  -- TODO: Slayer's Duellum Trove in Masters' Perch
        },
    },

}
for name, data in pairs(generatedItems_3) do
    ns.DefaultItems[name] = data
end

-- ---------------------------------------------------------------------------
-- ADDITIONAL ENTRIES (from public mount data)
-- 63 mounts with NPC IDs and drop rates populated
-- ---------------------------------------------------------------------------

local generatedItems_4 = {

    ["Captured Dune Scavenger"] = {
        itemId = 163576, spellId = 237286,
        type = C.ItemTypes.MOUNT, chance = 3000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 128682, 123774, 136191, 134429, 129778, 134427, 129652, 134560, 134103, 128678, 123773, 134559, 123775, 128749, 127406, 122746, 123864, 136545, 122782, 123863 },
        },
    },

    ["Chewed-On Reins of the Terrified Pack Mule"] = {
        itemId = 163574, spellId = 260174,
        type = C.ItemTypes.MOUNT, chance = 4000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 131534, 133892, 133889, 141642, 131519, 137134, 133736, 131530, 131529 },
        },
    },

    ["Reins of a Tamed Bloodfeaster"] = {
        itemId = 163575, spellId = 243795,
        type = C.ItemTypes.MOUNT, chance = 3000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 126888, 126187, 133077, 122239, 127919, 120607, 136639, 127224, 136293, 133279, 133063, 128734, 127928, 120606, 124547, 124688 },
        },
    },

    ["Goldenmane's Reins"] = {
        itemId = 163573, spellId = 260175,
        type = C.ItemTypes.MOUNT, chance = 3000,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 129750, 131646, 135585, 138167, 138332, 141143, 137202, 138168, 130641, 131166, 138226, 130897, 135584, 140209, 137893, 138170, 137156, 130006, 131404, 136158, 130039, 132226, 138340, 137155, 130531 },
        },
    },

    ["Blackpaw"] = {
        itemId = 166428, spellId = 288438,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 149660 },
        },
    },

    ["Kaldorei Nightsaber"] = {
        itemId = 166435, spellId = 288505,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 149663 },
        },
    },

    ["Captured Umber Nightsaber"] = {
        itemId = 166434, spellId = 288503,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Royal Snapdragon"] = {
        itemId = 169198, spellId = 294038,
        type = C.ItemTypes.MOUNT, chance = 19,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 152182 },
        },
    },

    ["Rusty Mechanocrawler"] = {
        itemId = 168823, spellId = 291492,
        type = C.ItemTypes.MOUNT, chance = 333,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 154342, 151934 },
        },
    },

    ["Twilight Avenger"] = {
        itemId = 163584, spellId = 279466,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Craghorn Chasm-Leaper"] = {
        itemId = 163583, spellId = 279467,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Qinsho's Eternal Hound"] = {
        itemId = 163582, spellId = 279469,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ["Squawks"] = {
        itemId = 163586, spellId = 254811,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ["Surf Jelly"] = {
        itemId = 163585, spellId = 278979,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.FISHING,
            requiresPool = false,
        },
    },

    ["Risen Mare"] = {
        itemId = 166466, spellId = 288722,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Island Thunderscale"] = {
        itemId = 166467, spellId = 288721,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Bloodgorged Hunter"] = {
        itemId = 166468, spellId = 288720,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Stonehide Elderhorn"] = {
        itemId = 166470, spellId = 288712,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.BFA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Scepter of Azj'Aqir"] = {
        itemId = 64883, spellId = 92155,
        type = C.ItemTypes.MOUNT, chance = 500,
        expansion = C.Expansions.CATA,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Plainswalker Bearer"] = {
        itemId = 192791, spellId = 374196,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},
        },
    },

    ["Verdant Skitterfly"] = {
        itemId = 192764, spellId = 374048,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 201181, 200960, 200584, 200904, 200956, 201013, 200610, 200721, 200911, 200600, 200717, 200978, 200885, 200681, 200579, 200537 },
        },
    },

    ["Ancient Salamanther"] = {
        itemId = 192772, spellId = 374090,
        type = C.ItemTypes.MOUNT, chance = 80,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 201181, 200960, 200584, 200904, 200956, 201013, 200610, 200721, 200911, 200600, 200717, 200978, 200885, 200681, 200579, 200537 },
        },
    },

    ["Gooey Snailemental"] = {
        itemId = 192785, spellId = 374157,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 203625 },
        },
    },

    ["Flaming Shalewing Subject 01"] = {
        itemId = 205204, spellId = 408651,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Reins of the Springtide Dreamtalon"] = {
        itemId = 210769, spellId = 426955,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Reins of the Morning Flourish Dreamsaber"] = {
        itemId = 210057, spellId = 424482,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Reins of the Rekindled Dreamstag"] = {
        itemId = 209950, spellId = 423877,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.DRAGONFLIGHT,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Cloudwing Hippogryph"] = {
        itemId = 147806, spellId = 242881,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Highmountain Elderhorn"] = {
        itemId = 147807, spellId = 242874,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Torn Invitation"] = {
        itemId = 140495, spellId = 171850,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Valarjar Stormwing"] = {
        itemId = 147805, spellId = 242882,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Smoldering Ember Wyrm"] = {
        itemId = 142552, spellId = 231428,
        type = C.ItemTypes.MOUNT, chance = 5,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Vile Fiend"] = {
        itemId = 152790, spellId = 243652,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 127288 },
        },
    },

    ["Biletooth Gnasher"] = {
        itemId = 152903, spellId = 253660,
        type = C.ItemTypes.MOUNT, chance = 30,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 126040, 126199 },
        },
    },

    ["Avenging Felcrusher"] = {
        itemId = 153044, spellId = 254259,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Blessed Felcrusher"] = {
        itemId = 153043, spellId = 254258,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Glorious Felcrusher"] = {
        itemId = 153042, spellId = 254069,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.LEGION,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Shackled Ur'zul"] = {
        itemId = 152789, spellId = 243651,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Reins of the Bone-White Primal Raptor"] = {
        itemId = 94290, spellId = 138640,
        type = C.ItemTypes.MOUNT, chance = 9999,
        expansion = C.Expansions.MOP,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Hopecrusher Gargon"] = {
        itemId = 180581, spellId = 312753,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 166679 },
        },
    },

    ["Phalynx of Humility"] = {
        itemId = 180762, spellId = 334386,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Silessa's Battle Harness"] = {
        itemId = 183798, spellId = 333023,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 166521 },
        },
    },

    ["Impressionable Gorger Spawn"] = {
        itemId = 180583, spellId = 333027,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 160821 },
        },
    },

    ["Ascended Skymane"] = {
        itemId = 183741, spellId = 342335,
        type = C.ItemTypes.MOUNT, chance = 20,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Dusklight Razorwing"] = {
        itemId = 186651, spellId = 354361,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 182120 },
        },
    },

    ["Darkmaul"] = {
        itemId = 186646, spellId = 354358,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 182120 },
        },
    },

    ["Iska's Mawrat Leash"] = {
        itemId = 190765, spellId = 368105,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 182120 },
        },
    },

    ["Spectral Mawrat's Tail"] = {
        itemId = 190766, spellId = 368128,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.SHADOWLANDS,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 179433, 176578, 169859, 159755, 153165, 171422, 153451, 159190, 151329, 151331, 155945, 170418, 156239, 155250, 155251, 157122, 153174, 156015, 185027, 185028, 153011 },
        },
    },

    ["Machine Defense Unit 1-11"] = {
        itemId = 223269, spellId = 448188,
        type = C.ItemTypes.MOUNT, chance = 10,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Personalized Goblin S.C.R.A.Per"] = {
        itemId = 229949, spellId = 466020,
        type = C.ItemTypes.MOUNT, chance = 33,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Steamwheedle Supplier"] = {
        itemId = 229943, spellId = 466014,
        type = C.ItemTypes.MOUNT, chance = 3,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 239581 },
        },
    },

    ["Void-Scarred Lynx"] = {
        itemId = 239563, spellId = 1228865,
        type = C.ItemTypes.MOUNT, chance = 125,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 239581 },
        },
    },

    ["Nesting Swarmite"] = {
        itemId = 223265, spellId = 447189,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.TWW,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 239581 },
        },
    },

    ["Bristling Hellboar"] = {
        itemId = 128481, spellId = 190690,
        type = C.ItemTypes.MOUNT, chance = 5000,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Garn Steelmaw"] = {
        itemId = 116779, spellId = 171836,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Giant Coldsnout"] = {
        itemId = 116673, spellId = 171635,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.USE_ITEM,
            sourceItemIds = {},
        },
    },

    ["Reins of the Crimson Water Strider"] = {
        itemId = 87791, spellId = 127271,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 81171, 85715 },
        },
    },

    ["Riding Turtle"] = {
        itemId = 23720, spellId = 30174,
        type = C.ItemTypes.MOUNT, chance = 200,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 81171, 85715 },
        },
    },

    ["Shadowhide Pearltusk"] = {
        itemId = 116663, spellId = 171624,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = {},
        },
    },

    ["Smoky Direwolf"] = {
        itemId = 116786, spellId = 171843,
        type = C.ItemTypes.MOUNT, chance = 50,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.NPC_KILL,
            npcIds = { 95044, 95054, 95053, 95056 },
        },
    },

    ["Wild Goretusk"] = {
        itemId = 116671, spellId = 171633,
        type = C.ItemTypes.MOUNT, chance = 1000,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Solar Spirehawk"] = {
        itemId = 116771, spellId = 171828,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

    ["Reins of the Infinite Timereaver"] = {
        itemId = 133543, spellId = 201098,
        type = C.ItemTypes.MOUNT, chance = 100,
        expansion = C.Expansions.WOD,
        detection = {
            method = C.Methods.BOSS_KILL,
            encounterIds = {},
        },
    },

}
for name, data in pairs(generatedItems_4) do
    ns.DefaultItems[name] = data
end
