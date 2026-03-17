--[[
    UI/CharacterBreakdown.lua
    Shows per-character attempt breakdown for a specific item.

    Opened by right-clicking an item in the tracker window.
    Displays each character's contribution to the total attempt count,
    with class-colored bars and an "Unattributed" row for historical data.
]]

local addonName, ns = ...
local C = ns.Constants

local CharacterBreakdown = {}
ns.CharacterBreakdown = CharacterBreakdown

-- WoW class colors (standard RAID_CLASS_COLORS fallback)
local CLASS_COLORS = {
    WARRIOR     = { 0.78, 0.61, 0.43 },
    PALADIN     = { 0.96, 0.55, 0.73 },
    HUNTER      = { 0.67, 0.83, 0.45 },
    ROGUE       = { 1.00, 0.96, 0.41 },
    PRIEST      = { 1.00, 1.00, 1.00 },
    DEATHKNIGHT = { 0.77, 0.12, 0.23 },
    SHAMAN      = { 0.00, 0.44, 0.87 },
    MAGE        = { 0.25, 0.78, 0.92 },
    WARLOCK     = { 0.53, 0.53, 0.93 },
    MONK        = { 0.00, 1.00, 0.60 },
    DRUID       = { 1.00, 0.49, 0.04 },
    DEMONHUNTER = { 0.64, 0.19, 0.79 },
    EVOKER      = { 0.20, 0.58, 0.50 },
}

local function GetClassColor(class)
    if class and CLASS_COLORS[class] then
        return unpack(CLASS_COLORS[class])
    end
    return 0.5, 0.5, 0.5
end

---------------------------------------------------------------------------
-- FRAME
---------------------------------------------------------------------------

local frame = CreateFrame("Frame", "RNGeezCharBreakdown", UIParent, "BackdropTemplate")
frame:SetSize(340, 380)
frame:SetPoint("CENTER", 200, 0)
frame:SetFrameStrata("DIALOG")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
})
frame:SetBackdropColor(0.06, 0.06, 0.10, 0.95)
frame:SetBackdropBorderColor(C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3], 0.6)
frame:Hide()

table.insert(UISpecialFrames, "RNGeezCharBreakdown")

-- Title (set dynamically)
local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("TOPLEFT", 12, -10)
titleText:SetTextColor(C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3])

-- Close button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
closeBtn:SetSize(20, 20)

-- Summary line
local summaryText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
summaryText:SetPoint("TOPLEFT", 12, -30)
summaryText:SetTextColor(0.7, 0.7, 0.7)

-- Separator
local sep = frame:CreateTexture(nil, "OVERLAY")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -46)
sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -46)
sep:SetColorTexture(1, 1, 1, 0.08)

---------------------------------------------------------------------------
-- SCROLL FRAME
---------------------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", "RNGeezCharBreakdownScroll", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -50)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 8)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetHeight(1)
scrollFrame:SetScrollChild(content)

scrollFrame:SetScript("OnSizeChanged", function(self, width)
    content:SetWidth(width)
end)

---------------------------------------------------------------------------
-- ROW POOL
---------------------------------------------------------------------------

local rowPool = {}
local ROW_HEIGHT = 24

local function GetRow(parent, index)
    if rowPool[index] then
        rowPool[index]:Show()
        return rowPool[index]
    end

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)

    -- Class color bar (left accent)
    row.classBar = row:CreateTexture(nil, "BACKGROUND")
    row.classBar:SetWidth(3)
    row.classBar:SetPoint("TOPLEFT", 0, -2)
    row.classBar:SetPoint("BOTTOMLEFT", 0, 2)

    -- Character name
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.nameText:SetPoint("LEFT", 10, 0)
    row.nameText:SetJustifyH("LEFT")

    -- Attempt count (right side)
    row.countText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.countText:SetPoint("RIGHT", -60, 0)
    row.countText:SetJustifyH("RIGHT")

    -- Percentage bar
    row.pctBar = row:CreateTexture(nil, "ARTWORK")
    row.pctBar:SetHeight(4)
    row.pctBar:SetPoint("BOTTOMLEFT", 10, 2)

    -- Alternating background
    row.bg = row:CreateTexture(nil, "BACKGROUND", nil, -1)
    row.bg:SetAllPoints()

    rowPool[index] = row
    return row
end

local function HideUnusedRows(startIndex)
    for i = startIndex, #rowPool do
        if rowPool[i] then rowPool[i]:Hide() end
    end
end

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

function CharacterBreakdown:Show(item)
    if not item then return end

    local itemName = item.name or "?"
    local totalAttempts = item.attempts or 0

    titleText:SetText(itemName)
    summaryText:SetText(ns.AttemptTracker:GetSummaryText(item))

    -- Gather per-character data from the roster
    local roster = RNGeezDB and RNGeezDB[C.DBKeys.CHARACTERS] or {}
    local entries = {}
    local attributedTotal = 0

    for guid, charInfo in pairs(roster) do
        local charAttempts = 0
        if charInfo.items and charInfo.items[itemName] then
            charAttempts = charInfo.items[itemName]
        end
        if charAttempts > 0 then
            table.insert(entries, {
                name     = charInfo.name or "Unknown",
                realm    = charInfo.realm or "",
                class    = charInfo.class or "",
                attempts = charAttempts,
                guid     = guid,
            })
            attributedTotal = attributedTotal + charAttempts
        end
    end

    -- Sort by attempts descending
    table.sort(entries, function(a, b)
        return a.attempts > b.attempts
    end)

    -- Add "Unattributed" row if there's a gap
    local unattributed = totalAttempts - attributedTotal
    if unattributed > 0 then
        table.insert(entries, {
            name     = "Unattributed",
            realm    = "",
            class    = nil,
            attempts = unattributed,
            isUnattributed = true,
        })
    end

    -- Render rows
    local yOffset = 0
    local maxAttempts = (entries[1] and entries[1].attempts) or 1

    for i, entry in ipairs(entries) do
        local row = GetRow(content, i)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        row:SetPoint("RIGHT", content, "RIGHT")

        -- Class color bar
        if entry.isUnattributed then
            row.classBar:SetColorTexture(0.3, 0.3, 0.3, 0.6)
            row.nameText:SetText("Unattributed (historical)")
            row.nameText:SetTextColor(0.5, 0.5, 0.5)
        else
            local r, g, b = GetClassColor(entry.class)
            row.classBar:SetColorTexture(r, g, b, 0.8)
            row.nameText:SetText(entry.name)
            row.nameText:SetTextColor(r, g, b)
        end

        -- Attempt count
        row.countText:SetText(entry.attempts .. " attempts")
        row.countText:SetTextColor(0.8, 0.8, 0.8)

        -- Percentage bar (proportional to highest contributor)
        local pct = entry.attempts / math.max(maxAttempts, 1)
        local barWidth = math.max(1, pct * 200)
        row.pctBar:SetWidth(barWidth)
        if entry.isUnattributed then
            row.pctBar:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        else
            local r, g, b = GetClassColor(entry.class)
            row.pctBar:SetColorTexture(r, g, b, 0.2)
        end

        -- Alternating row bg
        if i % 2 == 0 then
            row.bg:SetColorTexture(1, 1, 1, 0.02)
        else
            row.bg:SetColorTexture(0, 0, 0, 0)
        end

        yOffset = yOffset + ROW_HEIGHT
    end

    if #entries == 0 then
        local row = GetRow(content, 1)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        row:SetPoint("RIGHT", content, "RIGHT")
        row.classBar:SetColorTexture(0, 0, 0, 0)
        row.nameText:SetText("No per-character data yet.")
        row.nameText:SetTextColor(0.5, 0.5, 0.5)
        row.countText:SetText("")
        row.pctBar:SetWidth(1)
        row.pctBar:SetColorTexture(0, 0, 0, 0)
        row.bg:SetColorTexture(0, 0, 0, 0)
        yOffset = ROW_HEIGHT
    end

    HideUnusedRows(#entries + 1)
    content:SetHeight(math.max(1, yOffset))

    frame:Show()
end

function CharacterBreakdown:Hide()
    frame:Hide()
end
