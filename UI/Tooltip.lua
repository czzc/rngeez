--[[
    UI/Tooltip.lua
    The main RNGeez tracker window.
    
    TWO UI ELEMENTS:
    1. Minimap hover tooltip - simple summary (tracking count, found count)
    2. Tracker window - full persistent frame opened on click
       - Items grouped by expansion with collapsible headers
       - Each item: icon, name, attempt count, luck color
       - Hover item → WoW item tooltip
       - Settings panel: font size, opacity, accent color, sort order, etc.
    
    SETTINGS (stored in RNGeezDB.settings.tracker):
        opacity, scale, width, height, locked, accentColor,
        sortOrder, showFound, fontSize, anchorPoint, anchorX, anchorY
]]

local addonName, ns = ...
local C = ns.Constants

local Tooltip = {}
ns.Tooltip = Tooltip

---------------------------------------------------------------------------
-- DEFAULT TRACKER SETTINGS
---------------------------------------------------------------------------
local TRACKER_DEFAULTS = {
    opacity     = 0.92,
    scale       = 1.0,
    width       = 340,
    height      = 500,
    locked      = false,
    accentColor = { 0.94, 0.76, 0.20 },  -- Gold, fitting for RNGeez
    sortOrder   = "expansion",            -- "expansion", "attempts", "luck", "alpha"
    showFound   = false,                  -- Show already-obtained items?
    fontSize    = "small",                -- "small", "medium", "large"
}

-- Accent color presets
local COLOR_PRESETS = {
    { name = "Gold",    color = { 0.94, 0.76, 0.20 } },
    { name = "Ocean",   color = { 0.30, 0.75, 0.95 } },
    { name = "Ember",   color = { 0.95, 0.45, 0.25 } },
    { name = "Jade",    color = { 0.30, 0.85, 0.55 } },
    { name = "Violet",  color = { 0.65, 0.40, 0.95 } },
    { name = "Rose",    color = { 0.92, 0.45, 0.60 } },
    { name = "Frost",   color = { 0.70, 0.88, 0.95 } },
    { name = "Blood",   color = { 0.85, 0.15, 0.20 } },
}

-- Font objects by size setting
local FONT_OBJECTS = {
    small  = { item = "GameFontNormalSmall",    header = "GameFontNormal" },
    medium = { item = "GameFontNormal",         header = "GameFontNormalLarge" },
    large  = { item = "GameFontNormalLarge",     header = "GameFontNormalHuge" },
}

-- Expansion display order (chronological)
local EXPANSION_ORDER = {
    C.Expansions.CLASSIC, C.Expansions.TBC, C.Expansions.WOTLK,
    C.Expansions.CATA, C.Expansions.MOP, C.Expansions.WOD,
    C.Expansions.LEGION, C.Expansions.BFA, C.Expansions.SHADOWLANDS,
    C.Expansions.DRAGONFLIGHT, C.Expansions.TWW, C.Expansions.MIDNIGHT,
    C.Expansions.SPECIAL,
}

-- Track which expansion groups are collapsed (persisted in settings)
local collapsedGroups = {}  -- Set during Init from tsettings

-- Luck colors - delegates to AttemptTracker so thresholds stay in sync
local function GetLuckColor(attempts, chance)
    if not attempts or not chance or chance <= 0 or attempts <= 0 then
        return 0.5, 0.5, 0.5  -- Gray for no attempts
    end
    local prob = ns.AttemptTracker:GetProbability(attempts, chance)
    local _, color = ns.AttemptTracker:GetLuckAssessment(prob)
    return color[1], color[2], color[3]
end

---------------------------------------------------------------------------
-- SETTINGS ACCESSOR
-- Tracker settings live under RNGeezDB.settings.tracker
-- Lazily initialized on first access.
---------------------------------------------------------------------------
local tsettings  -- Shortcut ref, set during Init

local function GetAccent()
    if not tsettings then return 0.94, 0.76, 0.20 end
    return tsettings.accentColor[1], tsettings.accentColor[2], tsettings.accentColor[3]
end

local function GetFontObj()
    return FONT_OBJECTS[tsettings and tsettings.fontSize or "small"]
end

---------------------------------------------------------------------------
-- MAIN TRACKER FRAME
---------------------------------------------------------------------------

local frame = CreateFrame("Frame", "RNGeezTrackerFrame", UIParent, "BackdropTemplate")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetResizeBounds(280, 250, 600, 800)
frame:SetFrameStrata("HIGH")
frame:Hide()

local function ApplyFrameStyle()
    if not tsettings then return end
    local r, g, b = GetAccent()

    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(0.06, 0.06, 0.10, tsettings.opacity)
    frame:SetBackdropBorderColor(r, g, b, 0.4)
    frame:SetScale(tsettings.scale)
    frame:SetSize(tsettings.width, tsettings.height)
end

-- Top accent stripe
local topStripe = frame:CreateTexture(nil, "OVERLAY")
topStripe:SetHeight(2)
topStripe:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
topStripe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)

---------------------------------------------------------------------------
-- TITLE BAR
---------------------------------------------------------------------------

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetHeight(28)
titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function()
    if not tsettings or not tsettings.locked then frame:StartMoving() end
end)
titleBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    if tsettings then
        local point, _, _, x, y = frame:GetPoint()
        tsettings.anchorPoint = point
        tsettings.anchorX = x
        tsettings.anchorY = y
    end
end)

-- Title text
local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
titleText:SetText("RNGeez")

-- Summary text (right side of title bar)
local summaryText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
summaryText:SetPoint("RIGHT", titleBar, "RIGHT", -60, 0)
summaryText:SetTextColor(0.6, 0.6, 0.6)

-- Close button
local closeBtn = CreateFrame("Button", nil, titleBar)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -8, 0)
closeBtn:SetNormalFontObject("GameFontNormalSmall")
closeBtn:SetText("x")
closeBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
closeBtn:SetScript("OnClick", function() frame:Hide() end)
closeBtn:SetScript("OnEnter", function(self) self:GetFontString():SetTextColor(1, 0.3, 0.3) end)
closeBtn:SetScript("OnLeave", function(self) self:GetFontString():SetTextColor(0.5, 0.5, 0.5) end)

-- Settings gear button
local gearBtn = CreateFrame("Button", nil, titleBar)
gearBtn:SetSize(16, 16)
gearBtn:SetPoint("RIGHT", closeBtn, "LEFT", -6, 0)
local gearIcon = gearBtn:CreateTexture(nil, "ARTWORK")
gearIcon:SetAllPoints()
gearIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
gearIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
gearIcon:SetDesaturated(true)
gearIcon:SetVertexColor(0.6, 0.6, 0.6)
gearBtn:SetScript("OnEnter", function() gearIcon:SetVertexColor(1, 1, 1); gearIcon:SetDesaturated(false) end)
gearBtn:SetScript("OnLeave", function() gearIcon:SetVertexColor(0.6, 0.6, 0.6); gearIcon:SetDesaturated(true) end)

-- Separator
local sep = frame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -32)
sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -32)
sep:SetColorTexture(1, 1, 1, 0.08)

---------------------------------------------------------------------------
-- SCROLL FRAME
---------------------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", "RNGeezTrackerScroll", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -36)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 24)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetHeight(1)
scrollFrame:SetScrollChild(content)

-- Update content width when scroll frame resizes
scrollFrame:SetScript("OnSizeChanged", function(self, width, height)
    content:SetWidth(width)
end)

-- Resize handle
local resizer = CreateFrame("Button", nil, frame)
resizer:SetSize(16, 16)
resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
resizer:SetScript("OnMouseDown", function()
    if not tsettings or not tsettings.locked then frame:StartSizing("BOTTOMRIGHT") end
end)
resizer:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
    if tsettings then
        tsettings.width = frame:GetWidth()
        tsettings.height = frame:GetHeight()
    end
    -- RefreshDisplay is defined later in the file; call through Tooltip:Refresh
    if ns.Tooltip then ns.Tooltip:Refresh() end
end)

-- Footer
local footerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
footerText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 6)
footerText:SetTextColor(0.4, 0.4, 0.4)

---------------------------------------------------------------------------
-- ROW RENDERING
-- We use a pool of frames that get reused on each refresh.
-- Two types: expansion headers and item rows.
---------------------------------------------------------------------------

local rowPool = {}
local ROW_HEIGHT_ITEM = 24
local ROW_HEIGHT_HEADER = 22
local ROW_SPACING = 1

local function GetRow(index)
    if rowPool[index] then
        rowPool[index]:Show()
        return rowPool[index]
    end

    local row = CreateFrame("Frame", nil, content)
    row:SetHeight(ROW_HEIGHT_ITEM)
    row:EnableMouse(true)

    -- Hover highlight
    row.highlight = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(1, 1, 1, 0.04)
    row.highlight:Hide()

    -- Collapse arrow (only visible on headers)
    row.arrow = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.arrow:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.arrow:Hide()

    -- Item icon (hidden for headers)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(20, 20)
    row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Primary text (item name or expansion header)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -80, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(false)

    -- Right-side text (attempt count or item count for headers)
    row.rightText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.rightText:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.rightText:SetJustifyH("RIGHT")

    -- Store metadata
    row.itemData = nil
    row.isHeader = false
    row.expKey = nil  -- Set on headers for collapse toggling

    -- Hover handlers
    row:SetScript("OnEnter", function(self)
        self.highlight:Show()
        -- Show item tooltip if this is an item row
        if self.itemData and self.itemData.itemId and self.itemData.itemId > 0 then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local _, link = C_Item.GetItemInfo(self.itemData.itemId)
            if link then
                GameTooltip:SetHyperlink(link)
            else
                GameTooltip:SetText(self.itemData.name or "Unknown")
            end
            -- Add our tracking info below the item tooltip
            GameTooltip:AddLine(" ")
            local r, g, b = GetAccent()
            GameTooltip:AddLine("RNGeez Tracking", r, g, b)
            local attempts = self.itemData.attempts or 0
            local chance = self.itemData.chance or 100
            if attempts > 0 then
                local summary = ns.AttemptTracker:GetSummaryText(self.itemData)
                GameTooltip:AddLine(summary, 1, 1, 1)
            else
                GameTooltip:AddLine("No attempts yet", 0.5, 0.5, 0.5)
            end
            if self.itemData.found then
                GameTooltip:AddLine("Obtained!", 0.2, 1.0, 0.2)
            end
            GameTooltip:Show()
        elseif self.isHeader then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Click to expand/collapse", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function(self)
        self.highlight:Hide()
        GameTooltip:Hide()
    end)

    -- Click handler
    row:SetScript("OnMouseDown", function(self, button)
        if self.isHeader and self.expKey then
            -- Left-click headers: toggle collapse
            collapsedGroups[self.expKey] = not collapsedGroups[self.expKey]
            if tsettings then
                tsettings.collapsedGroups = collapsedGroups
            end
            if ns.Tooltip then ns.Tooltip:Refresh() end
        elseif button == "RightButton" and self.itemData and ns.CharacterBreakdown then
            -- Right-click items: show per-character breakdown
            ns.CharacterBreakdown:Show(self.itemData)
        end
    end)

    rowPool[index] = row
    return row
end

local function HideAllRows()
    for _, row in ipairs(rowPool) do row:Hide() end
end

---------------------------------------------------------------------------
-- DATA GATHERING
-- Collects items from ns.items and ns.custom, groups by expansion,
-- sorts within groups based on settings.
---------------------------------------------------------------------------

local function GatherItems()
    local byExpansion = {}
    local totalTracking = 0
    local totalFound = 0

    -- Helper to process items from a table
    local function processItems(itemTable)
        for name, item in pairs(itemTable) do
            if item.enabled ~= false then
                totalTracking = totalTracking + 1
                if item.found then totalFound = totalFound + 1 end

                -- Skip found items if setting says so
                if not item.found or tsettings.showFound then
                    local exp = item.expansion or "classic"
                    if not byExpansion[exp] then byExpansion[exp] = {} end
                    table.insert(byExpansion[exp], item)
                end
            end
        end
    end

    processItems(ns.items or {})
    processItems(ns.custom or {})

    -- Sort within each expansion group
    local sortFunc
    local order = tsettings and tsettings.sortOrder or "expansion"

    if order == "attempts" then
        sortFunc = function(a, b) return (a.attempts or 0) > (b.attempts or 0) end
    elseif order == "luck" then
        sortFunc = function(a, b)
            local probA = ns.AttemptTracker:GetProbability(a.attempts or 0, a.chance or 0)
            local probB = ns.AttemptTracker:GetProbability(b.attempts or 0, b.chance or 0)
            return probA > probB
        end
    elseif order == "alpha" then
        sortFunc = function(a, b) return (a.name or "") < (b.name or "") end
    else
        -- Default (expansion): sort by attempts within each group
        sortFunc = function(a, b) return (a.attempts or 0) > (b.attempts or 0) end
    end

    for _, items in pairs(byExpansion) do
        table.sort(items, sortFunc)
    end

    return byExpansion, totalTracking, totalFound
end

---------------------------------------------------------------------------
-- DISPLAY REFRESH
---------------------------------------------------------------------------

local function RefreshDisplay()
    HideAllRows()

    if not tsettings then return end

    local r, g, b = GetAccent()
    topStripe:SetColorTexture(r, g, b, 0.8)
    titleText:SetTextColor(r, g, b)

    local byExpansion, totalTracking, totalFound = GatherItems()
    local display = totalTracking - totalFound

    summaryText:SetText(string.format("%d/%d found", totalFound, totalTracking))

    local rowIndex = 0
    local yOffset = 0
    local fonts = GetFontObj()

    local sortOrder = tsettings.sortOrder or "expansion"

    -- If sorting by expansion, use expansion headers
    -- Otherwise, flatten everything into one list
    if sortOrder == "expansion" then
        for _, expKey in ipairs(EXPANSION_ORDER) do
            local items = byExpansion[expKey]
            if items and #items > 0 then
                local isCollapsed = collapsedGroups[expKey]

                -- Expansion header row
                rowIndex = rowIndex + 1
                local headerRow = GetRow(rowIndex)
                headerRow:SetHeight(ROW_HEIGHT_HEADER)
                headerRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
                headerRow:SetPoint("RIGHT", content, "RIGHT", 0, 0)
                headerRow.isHeader = true
                headerRow.itemData = nil
                headerRow.expKey = expKey

                -- Collapse arrow
                headerRow.arrow:Show()
                headerRow.arrow:SetText(isCollapsed and "+" or "-")
                headerRow.arrow:SetTextColor(r, g, b, 0.6)

                -- Style as header
                headerRow.icon:Hide()
                headerRow.text:SetFontObject(fonts.header)
                headerRow.text:SetPoint("LEFT", headerRow.arrow, "RIGHT", 4, 0)
                headerRow.text:SetText(C.ExpansionLabels[expKey] or expKey)
                headerRow.text:SetTextColor(r, g, b, 0.9)
                headerRow.rightText:SetFontObject(fonts.item)
                headerRow.rightText:SetText(#items)
                headerRow.rightText:SetTextColor(0.4, 0.4, 0.4)

                yOffset = yOffset + ROW_HEIGHT_HEADER + ROW_SPACING

                -- Skip item rows if this group is collapsed
                if not isCollapsed then
                -- Item rows under this header
                for _, item in ipairs(items) do
                    rowIndex = rowIndex + 1
                    local row = GetRow(rowIndex)
                    row:SetHeight(ROW_HEIGHT_ITEM)
                    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
                    row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
                    row.isHeader = false
                    row.itemData = item

                    -- Icon
                    row.icon:Show()
                    row.icon:SetPoint("LEFT", row, "LEFT", 14, 0)  -- Indented under header
                    local icon = ns.ItemResolver:GetIcon(item.itemId)
                    row.icon:SetTexture(icon)

                    -- Item name
                    row.text:SetFontObject(fonts.item)
                    row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
                    row.text:SetText(item.name or "Unknown")

                    if item.found then
                        row.text:SetTextColor(0.3, 0.3, 0.3)
                        row.rightText:SetFontObject(fonts.item)
                        row.rightText:SetText("Obtained")
                        row.rightText:SetTextColor(0.2, 0.6, 0.2)
                    else
                        local lr, lg, lb = GetLuckColor(item.attempts or 0, item.chance or 100)
                        row.text:SetTextColor(1, 1, 1)
                        row.rightText:SetFontObject(fonts.item)
                        local attempts = item.attempts or 0
                        if attempts > 0 then
                            row.rightText:SetText(attempts .. " att.")
                            row.rightText:SetTextColor(lr, lg, lb)
                        else
                            row.rightText:SetText("")
                        end
                    end

                    yOffset = yOffset + ROW_HEIGHT_ITEM + ROW_SPACING
                end
                end  -- if not isCollapsed
            end
        end
    else
        -- Flat list (no expansion headers)
        -- Gather all items into one array
        local allItems = {}
        for _, items in pairs(byExpansion) do
            for _, item in ipairs(items) do
                table.insert(allItems, item)
            end
        end

        -- Re-sort the flat list
        local sortFunc
        if sortOrder == "attempts" then
            sortFunc = function(a, b) return (a.attempts or 0) > (b.attempts or 0) end
        elseif sortOrder == "luck" then
            sortFunc = function(a, b)
                local probA = ns.AttemptTracker:GetProbability(a.attempts or 0, a.chance or 0)
                local probB = ns.AttemptTracker:GetProbability(b.attempts or 0, b.chance or 0)
                return probA > probB
            end
        else
            sortFunc = function(a, b) return (a.name or "") < (b.name or "") end
        end
        table.sort(allItems, sortFunc)

        for _, item in ipairs(allItems) do
            rowIndex = rowIndex + 1
            local row = GetRow(rowIndex)
            row:SetHeight(ROW_HEIGHT_ITEM)
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
            row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            row.isHeader = false
            row.itemData = item

            row.icon:Show()
            row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)
            local icon = ns.ItemResolver:GetIcon(item.itemId)
            row.icon:SetTexture(icon)

            row.text:SetFontObject(fonts.item)
            row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
            row.text:SetText(item.name or "Unknown")

            if item.found then
                row.text:SetTextColor(0.3, 0.3, 0.3)
                row.rightText:SetFontObject(fonts.item)
                row.rightText:SetText("Obtained")
                row.rightText:SetTextColor(0.2, 0.6, 0.2)
            else
                local lr, lg, lb = GetLuckColor(item.attempts or 0, item.chance or 100)
                row.text:SetTextColor(1, 1, 1)
                row.rightText:SetFontObject(fonts.item)
                local attempts = item.attempts or 0
                if attempts > 0 then
                    row.rightText:SetText(attempts .. " att.")
                    row.rightText:SetTextColor(lr, lg, lb)
                else
                    row.rightText:SetText("")
                end
            end

            yOffset = yOffset + ROW_HEIGHT_ITEM + ROW_SPACING
        end
    end

    content:SetHeight(math.max(yOffset, 1))
    footerText:SetText(display .. " remaining")
end

---------------------------------------------------------------------------
-- SETTINGS PANEL
---------------------------------------------------------------------------

local settingsFrame = CreateFrame("Frame", "RNGeezSettingsFrame", UIParent, "BackdropTemplate")
settingsFrame:SetSize(300, 400)
settingsFrame:SetPoint("CENTER")
settingsFrame:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
})
settingsFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.96)
settingsFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
settingsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
settingsFrame:SetFrameStrata("DIALOG")
settingsFrame:Hide()

local sTitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sTitle:SetPoint("TOPLEFT", 12, -10)
sTitle:SetText("RNGeez Settings")

local sClose = CreateFrame("Button", nil, settingsFrame)
sClose:SetSize(16, 16)
sClose:SetPoint("TOPRIGHT", -8, -8)
sClose:SetNormalFontObject("GameFontNormalSmall")
sClose:SetText("x")
sClose:GetFontString():SetTextColor(0.5, 0.5, 0.5)
sClose:SetScript("OnClick", function() settingsFrame:Hide() end)

-- Helper: create slider (deferred init, same pattern as Nemo)
local function CreateSlider(parent, label, min, max, step, yOffset, getter, setter, formatFunc)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(260, 40)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, yOffset)

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetTextColor(0.8, 0.8, 0.8)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 0, -14)
    slider:SetSize(240, 14)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText("")
    slider.High:SetText("")

    local fmtFunc = formatFunc or function(v) return string.format("%.0f%%", v * 100) end

    local function UpdateLabel()
        local val = slider:GetValue()
        text:SetText(label .. ": " .. fmtFunc(val))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        setter(value)
        UpdateLabel()
        ApplyFrameStyle()
        RefreshDisplay()
    end)

    slider.getter = getter
    slider.UpdateLabel = UpdateLabel
    return slider
end

-- Opacity slider
local opacitySlider = CreateSlider(settingsFrame, "Background Opacity",
    0.2, 1.0, 0.05, -36,
    function() return tsettings and tsettings.opacity or 0.92 end,
    function(v) if tsettings then tsettings.opacity = v end end
)

-- Scale slider
local scaleSlider = CreateSlider(settingsFrame, "Frame Scale",
    0.6, 1.5, 0.05, -86,
    function() return tsettings and tsettings.scale or 1.0 end,
    function(v) if tsettings then tsettings.scale = v end end
)

-- Accent color presets
local colorLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
colorLabel:SetPoint("TOPLEFT", 16, -140)
colorLabel:SetText("Accent Color")
colorLabel:SetTextColor(0.8, 0.8, 0.8)

for i, preset in ipairs(COLOR_PRESETS) do
    local btn = CreateFrame("Button", nil, settingsFrame)
    local col = math.floor((i - 1) % 4)
    local row = math.floor((i - 1) / 4)
    btn:SetSize(52, 24)
    btn:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 16 + (col * 62), -156 - (row * 30))

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(preset.color[1], preset.color[2], preset.color[3], 0.8)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER")
    btnText:SetText(preset.name)
    btnText:SetTextColor(0, 0, 0)

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(1, 1, 1, 0.3)
    border:Hide()

    btn:SetScript("OnEnter", function() border:Show() end)
    btn:SetScript("OnLeave", function() border:Hide() end)
    btn:SetScript("OnClick", function()
        if tsettings then
            tsettings.accentColor = { preset.color[1], preset.color[2], preset.color[3] }
            ApplyFrameStyle()
            RefreshDisplay()
            local r, g, b = GetAccent()
            sTitle:SetTextColor(r, g, b)
        end
    end)
end

-- Sort order dropdown buttons
-- Shared button styling helpers
local BUTTON_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
}

local function ApplyButtonStyle(btn)
    btn:SetBackdrop(BUTTON_BACKDROP)
    btn:SetBackdropColor(0.15, 0.15, 0.2, 0.8)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
end

local function UpdateButtonHighlights(buttons, field, activeValue)
    local r, g, b = GetAccent()
    for _, btn in ipairs(buttons) do
        if btn[field] == activeValue then
            btn:SetBackdropBorderColor(r, g, b, 0.8)
            btn.btnText:SetTextColor(r, g, b)
        else
            btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
            btn.btnText:SetTextColor(0.7, 0.7, 0.7)
        end
    end
end

local sortLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sortLabel:SetPoint("TOPLEFT", 16, -224)
sortLabel:SetText("Sort Order")
sortLabel:SetTextColor(0.8, 0.8, 0.8)

local sortOptions = {
    { key = "expansion", label = "By Expansion" },
    { key = "attempts",  label = "By Attempts" },
    { key = "luck",      label = "By Luck" },
    { key = "alpha",     label = "Alphabetical" },
}

local sortButtons = {}
for i, opt in ipairs(sortOptions) do
    local btn = CreateFrame("Button", nil, settingsFrame, "BackdropTemplate")
    local col = math.floor((i - 1) % 2)
    local row = math.floor((i - 1) / 2)
    btn:SetSize(120, 22)
    btn:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 16 + (col * 128), -240 - (row * 26))
    ApplyButtonStyle(btn)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER")
    btnText:SetText(opt.label)

    btn.key = opt.key
    btn.btnText = btnText
    sortButtons[i] = btn

    btn:SetScript("OnClick", function(self)
        if tsettings then
            tsettings.sortOrder = self.key
            UpdateButtonHighlights(sortButtons, "key", tsettings.sortOrder)
            RefreshDisplay()
        end
    end)
end

-- Font size buttons
local fontLabel = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fontLabel:SetPoint("TOPLEFT", 16, -300)
fontLabel:SetText("Font Size")
fontLabel:SetTextColor(0.8, 0.8, 0.8)

local fontOptions = { "small", "medium", "large" }
local fontButtons = {}

for i, size in ipairs(fontOptions) do
    local btn = CreateFrame("Button", nil, settingsFrame, "BackdropTemplate")
    btn:SetSize(76, 22)
    btn:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 16 + ((i - 1) * 84), -316)
    ApplyButtonStyle(btn)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btnText:SetPoint("CENTER")
    btnText:SetText(size:sub(1, 1):upper() .. size:sub(2))

    btn.size = size
    btn.btnText = btnText
    fontButtons[i] = btn

    btn:SetScript("OnClick", function(self)
        if tsettings then
            tsettings.fontSize = self.size
            UpdateButtonHighlights(fontButtons, "size", tsettings.fontSize)
            RefreshDisplay()
        end
    end)
end

-- Checkboxes
local showFoundCheck = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
showFoundCheck:SetSize(24, 24)
showFoundCheck:SetPoint("TOPLEFT", 12, -348)
showFoundCheck.text:SetText(" Show obtained mounts")
showFoundCheck.text:SetFontObject("GameFontNormalSmall")
showFoundCheck.text:SetTextColor(0.8, 0.8, 0.8)
showFoundCheck:SetScript("OnClick", function(self)
    if tsettings then
        tsettings.showFound = self:GetChecked()
        RefreshDisplay()
    end
end)

local lockCheck = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
lockCheck:SetSize(24, 24)
lockCheck:SetPoint("TOPLEFT", 12, -374)
lockCheck.text:SetText(" Lock frame position")
lockCheck.text:SetFontObject("GameFontNormalSmall")
lockCheck.text:SetTextColor(0.8, 0.8, 0.8)
lockCheck:SetScript("OnClick", function(self)
    if tsettings then
        tsettings.locked = self:GetChecked()
        resizer:SetShown(not tsettings.locked)
    end
end)

-- Sync settings panel state
local function SyncSettingsPanel()
    if not tsettings then return end
    local r, g, b = GetAccent()
    sTitle:SetTextColor(r, g, b)

    opacitySlider:SetValue(tsettings.opacity)
    opacitySlider.UpdateLabel()
    scaleSlider:SetValue(tsettings.scale)
    scaleSlider.UpdateLabel()

    showFoundCheck:SetChecked(tsettings.showFound)
    lockCheck:SetChecked(tsettings.locked)

    UpdateButtonHighlights(sortButtons, "key", tsettings.sortOrder)
    UpdateButtonHighlights(fontButtons, "size", tsettings.fontSize)
end

-- Wire gear button
gearBtn:SetScript("OnClick", function()
    if settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        SyncSettingsPanel()
        settingsFrame:Show()
    end
end)

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

function Tooltip:Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        RefreshDisplay()
        frame:Show()
    end
end

function Tooltip:Refresh()
    if frame:IsShown() then
        RefreshDisplay()
    end
end

function Tooltip:Init()
    -- Initialize tracker settings
    if not ns.settings.tracker then ns.settings.tracker = {} end

    -- Fill defaults
    for k, v in pairs(TRACKER_DEFAULTS) do
        if ns.settings.tracker[k] == nil then
            if type(v) == "table" then
                ns.settings.tracker[k] = {}
                for i, val in pairs(v) do ns.settings.tracker[k][i] = val end
            else
                ns.settings.tracker[k] = v
            end
        end
    end

    tsettings = ns.settings.tracker

    -- Load collapsed group state (or initialize)
    if not tsettings.collapsedGroups then tsettings.collapsedGroups = {} end
    collapsedGroups = tsettings.collapsedGroups

    -- Apply initial style
    ApplyFrameStyle()
    resizer:SetShown(not tsettings.locked)

    -- Restore position
    if tsettings.anchorPoint then
        frame:ClearAllPoints()
        frame:SetPoint(tsettings.anchorPoint, UIParent, tsettings.anchorPoint,
            tsettings.anchorX or 0, tsettings.anchorY or 0)
    else
        frame:SetPoint("RIGHT", UIParent, "RIGHT", -40, 0)
    end

    -- Listen for attempt changes to refresh display
    ns.EventBus:RegisterAddonEvent(ns.Events.ATTEMPT_ADDED, function()
        Tooltip:Refresh()
    end)
    ns.EventBus:RegisterAddonEvent(ns.Events.ITEM_FOUND, function()
        Tooltip:Refresh()
    end)

    -- Refresh when item info arrives (icons loading from server)
    -- Throttle to avoid refreshing on every single item info event
    local pendingRefresh = false
    ns.EventBus:RegisterWoWEvent("GET_ITEM_INFO_RECEIVED", function()
        if frame:IsShown() and not pendingRefresh then
            pendingRefresh = true
            C_Timer.After(0.5, function()
                pendingRefresh = false
                RefreshDisplay()
            end)
        end
    end)

    ns.RNGeez:Debug("Tracker window initialized.")
end
