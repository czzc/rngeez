--[[
    UI/MinimapButton.lua
    Creates the minimap button using LibDataBroker + LibDBIcon.
    
    This is the small icon that sits on the minimap ring. Players can:
    - Left-click: Toggle the tooltip (Phase 4)
    - Right-click: Toggle options (Phase 5)
    
    WHY LIBDATABROKER?
    It's the universal standard for WoW minimap/broker plugins. Any data
    broker display addon (Titan Panel, Bazooka, ChocolateBar, etc.) can
    pick up our plugin automatically. LibDBIcon handles the minimap icon.
    
    PHASE 1: Just gets the button rendering. Click actions are stubs.
]]

local addonName, ns = ...
local C = ns.Constants

local MinimapButton = {}
ns.MinimapButton = MinimapButton

---------------------------------------------------------------------------
-- LIBDATABROKER PLUGIN
-- This creates the data object that broker addons display.
---------------------------------------------------------------------------
function MinimapButton:Init()
    -- LibDataBroker might not be available if the lib failed to load
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    if not LDB then
        ns.RNGeez:Debug("LibDataBroker not available - skipping minimap button.")
        return
    end

    local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)

    -- Create the data object (this is what broker addons read)
    local dataObj = LDB:NewDataObject("RNGeez", {
        type = "data source",
        text = "RNGeez",
        icon = "Interface\\Icons\\INV_Misc_Coin_02",

        -- Tooltip on hover (minimap button or broker display)
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("RNGeez v1.0.0", C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3])
            tooltip:AddLine("Rare drop farming tracker", 1, 1, 1)
            tooltip:AddLine(" ")

            -- Show a quick summary of tracking status
            local total, enabled, found = 0, 0, 0
            ns.ForEachItem(function(_, item)
                total = total + 1
                if item.enabled ~= false then enabled = enabled + 1 end
                if item.found then found = found + 1 end
            end)

            tooltip:AddDoubleLine("Tracking:", tostring(enabled) .. " items",
                0.8, 0.8, 0.8, 1, 1, 1)
            tooltip:AddDoubleLine("Found:", tostring(found) .. " / " .. tostring(total),
                0.8, 0.8, 0.8, 1, 1, 1)

            tooltip:AddLine(" ")
            tooltip:AddLine("Left-click: Toggle tracker", 0.5, 0.5, 0.5)
            tooltip:AddLine("Right-click: Options", 0.5, 0.5, 0.5)
        end,

        -- Click handler
        OnClick = function(self, button)
            if button == "LeftButton" then
                if ns.Tooltip then ns.Tooltip:Toggle() end
            elseif button == "RightButton" then
                if ns.Tooltip then ns.Tooltip:Toggle() end
            end
        end,
    })

    -- Register with LibDBIcon for the minimap button
    if LDBIcon then
        LDBIcon:Register("RNGeez", dataObj, ns.settings.minimapButton)
        ns.RNGeez:Debug("Minimap button registered via LibDBIcon.")
    end

    -- Store references for later updates
    self.dataObj = dataObj
    self.ldbIcon = LDBIcon
end

-- Update the broker text (shown in broker bar addons, not minimap).
-- Called after attempt changes.
function MinimapButton:UpdateText(text)
    if self.dataObj then
        self.dataObj.text = text or "RNGeez"
    end
end
