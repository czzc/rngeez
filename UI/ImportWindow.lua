--[[
    UI/ImportWindow.lua
    Scrollable preview window for Rarity data import.

    Shows a list of items that would be updated, with old->new attempt counts
    and "found" tags. Accept button triggers the import; Cancel dismisses.

    Styled to match the tracker window (dark backdrop, accent highlights).
]]

local addonName, ns = ...
local C = ns.Constants

local ImportWindow = {}
ns.ImportWindow = ImportWindow

---------------------------------------------------------------------------
-- FRAME (lazy-initialized on first Show)
---------------------------------------------------------------------------

local frame, profileLabel, summaryText, scrollFrame, content
local acceptBtn, noteText
local rowPool = {}

local function EnsureFrame()
    if frame then return end

    frame = CreateFrame("Frame", "RNGeezImportFrame", UIParent, "BackdropTemplate")
    frame:SetSize(400, 460)
    frame:SetPoint("CENTER")
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

    table.insert(UISpecialFrames, "RNGeezImportFrame")

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Import from Rarity")
    title:SetTextColor(C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3])

    profileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -14)
    profileLabel:SetTextColor(0.6, 0.6, 0.6)

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetSize(20, 20)

    local sep = frame:CreateTexture(nil, "OVERLAY")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -32)
    sep:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -32)
    sep:SetColorTexture(1, 1, 1, 0.08)

    summaryText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summaryText:SetPoint("TOPLEFT", 12, -38)
    summaryText:SetTextColor(0.7, 0.7, 0.7)

    -- Scroll frame
    scrollFrame = CreateFrame("ScrollFrame", "RNGeezImportScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -56)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 62)

    content = CreateFrame("Frame", nil, scrollFrame)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    scrollFrame:SetScript("OnSizeChanged", function(_, width)
        content:SetWidth(width)
    end)

    -- Footer
    local footerSep = frame:CreateTexture(nil, "OVERLAY")
    footerSep:SetHeight(1)
    footerSep:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 58)
    footerSep:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 58)
    footerSep:SetColorTexture(1, 1, 1, 0.08)

    noteText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noteText:SetPoint("BOTTOMLEFT", 12, 42)
    noteText:SetText("A backup will be created. Use /rng restorebackup to undo.")
    noteText:SetTextColor(0.5, 0.5, 0.5)

    acceptBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
    acceptBtn:SetSize(90, 26)
    acceptBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -110, 10)
    acceptBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    acceptBtn:SetBackdropColor(0.15, 0.4, 0.15, 0.9)
    acceptBtn:SetBackdropBorderColor(0.3, 0.7, 0.3, 0.6)

    local acceptText = acceptBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    acceptText:SetPoint("CENTER")
    acceptText:SetText("Accept")

    local cancelBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
    cancelBtn:SetSize(90, 26)
    cancelBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 10)
    cancelBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    cancelBtn:SetBackdropColor(0.15, 0.15, 0.2, 0.8)
    cancelBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

    local cancelText = cancelBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cancelText:SetPoint("CENTER")
    cancelText:SetText("Cancel")

    cancelBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
end

---------------------------------------------------------------------------
-- ROW POOL
---------------------------------------------------------------------------

local function GetRow(parent, index)
    if rowPool[index] then
        rowPool[index]:Show()
        return rowPool[index]
    end

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(20)

    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.nameText:SetPoint("LEFT", 4, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWidth(200)

    row.changeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.changeText:SetPoint("RIGHT", -4, 0)
    row.changeText:SetJustifyH("RIGHT")

    row.bg = row:CreateTexture(nil, "BACKGROUND")
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

function ImportWindow:Show(changes, summary, profileName, onAccept)
    EnsureFrame()

    profileLabel:SetText("Profile: \"" .. (profileName or "?") .. "\"")

    -- Summary text
    local parts = {}
    if summary.attempts > 0 then
        table.insert(parts, summary.attempts .. " attempt updates")
    end
    if summary.found > 0 then
        table.insert(parts, summary.found .. " newly found")
    end
    if summary.uptodate > 0 then
        table.insert(parts, summary.uptodate .. " up to date")
    end
    summaryText:SetText(summary.matched .. " matched  -  " .. table.concat(parts, "  |  "))

    -- Reset note text for fresh import
    noteText:SetText("A backup will be created. Use /rng restorebackup to undo.")

    -- Build rows
    local yOffset = 0
    local rowCount = 0

    if #changes == 0 then
        local row = GetRow(content, 1)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        row:SetPoint("RIGHT", content, "RIGHT")
        row.nameText:SetText("Nothing to import - all items are up to date.")
        row.nameText:SetTextColor(0.5, 0.5, 0.5)
        row.nameText:SetWidth(380)
        row.changeText:SetText("")
        row.changeText:SetTextColor(0.7, 0.7, 0.7)
        row.bg:SetColorTexture(0, 0, 0, 0)
        rowCount = 1
        acceptBtn:Hide()
    else
        for i, change in ipairs(changes) do
            local row = GetRow(content, i)
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
            row:SetPoint("RIGHT", content, "RIGHT")

            -- Item name
            row.nameText:SetText((change.name or ""):gsub("|", "||"))
            row.nameText:SetTextColor(1, 1, 1)
            row.nameText:SetWidth(200)

            -- Reset color state before conditional override
            row.changeText:SetTextColor(0.7, 0.7, 0.7)

            -- Change description
            local desc = {}
            if change.deltaAttempts > 0 then
                table.insert(desc, string.format("%d -> %d",
                    change.oldAttempts, change.newAttempts))
            end
            if change.newlyFound then
                table.insert(desc, "|cFF33FF33found|r")
            end

            row.changeText:SetText(table.concat(desc, "  "))
            if change.deltaAttempts > 0 then
                row.changeText:SetTextColor(
                    C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3])
            end

            -- Alternating background
            if i % 2 == 0 then
                row.bg:SetColorTexture(1, 1, 1, 0.03)
            else
                row.bg:SetColorTexture(0, 0, 0, 0)
            end

            yOffset = yOffset + 20
            rowCount = i
        end
        acceptBtn:Show()
    end

    HideUnusedRows(rowCount + 1)
    content:SetHeight(math.max(1, yOffset))

    -- Wire accept button
    acceptBtn:SetScript("OnClick", function()
        if onAccept then
            local counts = onAccept()
            summaryText:SetText(string.format(
                "|cFF33FF33Import complete!|r  %d attempts updated  |  %d found  |  %d find histories",
                counts.attempts, counts.found, counts.finds))
            acceptBtn:Hide()
            noteText:SetText("Import applied. Use /rng restorebackup to undo if needed.")
        end
    end)

    frame:Show()
end

function ImportWindow:Hide()
    if frame then frame:Hide() end
end
