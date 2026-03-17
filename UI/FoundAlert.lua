--[[
    UI/FoundAlert.lua
    Achievement-style popup when a tracked item is obtained.
    
    BEHAVIOR:
    - Slides down from the top of the screen
    - Shows item icon with golden glow pulse
    - "OBTAINED!" header with item name
    - "After X attempts" with luck assessment
    - Plays a sound
    - Auto-dismisses after 6 seconds with a fade-out
    - Queue system: if multiple items found at once, shows them sequentially
    - Only fires for items with > 0 attempts (skips collection scan on login)
    
    Styled to match the modern dark UI of the tracker and Nemo.
]]

local addonName, ns = ...
local C = ns.Constants

local FoundAlert = {}
ns.FoundAlert = FoundAlert

---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------

local ALERT_WIDTH = 320
local ALERT_HEIGHT = 80
local SLIDE_DURATION = 0.4
local DISPLAY_DURATION = 6.0
local FADE_DURATION = 1.0
local SLIDE_DISTANCE = 100

-- Achievement earned fanfare — the classic "you did it!" sound
local ALERT_SOUND = SOUNDKIT.UI_RAID_BOSS_DEFEATED or 8459

---------------------------------------------------------------------------
-- ALERT FRAME
---------------------------------------------------------------------------

local alert = CreateFrame("Frame", "RNGeezFoundAlert", UIParent, "BackdropTemplate")
alert:SetSize(ALERT_WIDTH, ALERT_HEIGHT)
alert:SetPoint("TOP", UIParent, "TOP", 0, SLIDE_DISTANCE)
alert:SetFrameStrata("TOOLTIP")
alert:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
})
alert:SetBackdropColor(0.06, 0.06, 0.10, 0.95)
alert:SetBackdropBorderColor(C.Colors.ACCENT[1], C.Colors.ACCENT[2], C.Colors.ACCENT[3], 0.6)
alert:Hide()

-- Top accent stripe
local stripe = alert:CreateTexture(nil, "OVERLAY")
stripe:SetHeight(2)
stripe:SetPoint("TOPLEFT", alert, "TOPLEFT", 1, -1)
stripe:SetPoint("TOPRIGHT", alert, "TOPRIGHT", -1, -1)
stripe:SetColorTexture(0.94, 0.76, 0.20, 0.9)

-- Bottom accent stripe
local stripeBottom = alert:CreateTexture(nil, "OVERLAY")
stripeBottom:SetHeight(2)
stripeBottom:SetPoint("BOTTOMLEFT", alert, "BOTTOMLEFT", 1, 1)
stripeBottom:SetPoint("BOTTOMRIGHT", alert, "BOTTOMRIGHT", -1, 1)
stripeBottom:SetColorTexture(0.94, 0.76, 0.20, 0.9)

-- Icon glow (pulsing golden backdrop behind the icon)
local iconGlow = alert:CreateTexture(nil, "BACKGROUND")
iconGlow:SetSize(56, 56)
iconGlow:SetPoint("LEFT", alert, "LEFT", 10, 0)
iconGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
iconGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
iconGlow:SetVertexColor(0.94, 0.76, 0.20, 0.8)

-- Icon border (gold frame)
local iconBorder = alert:CreateTexture(nil, "ARTWORK", nil, 1)
iconBorder:SetSize(48, 48)
iconBorder:SetPoint("CENTER", iconGlow, "CENTER", 0, 0)
iconBorder:SetColorTexture(0.94, 0.76, 0.20, 0.4)

-- Item icon
local icon = alert:CreateTexture(nil, "ARTWORK", nil, 3)
icon:SetSize(44, 44)
icon:SetPoint("CENTER", iconGlow, "CENTER", 0, 0)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

-- "OBTAINED!" header
local headerText = alert:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerText:SetPoint("TOPLEFT", iconGlow, "TOPRIGHT", 10, -6)
headerText:SetText("OBTAINED!")
headerText:SetTextColor(0.94, 0.76, 0.20)

-- Item name
local nameText = alert:CreateFontString(nil, "OVERLAY", "GameFontNormal")
nameText:SetPoint("TOPLEFT", headerText, "BOTTOMLEFT", 0, -2)
nameText:SetPoint("RIGHT", alert, "RIGHT", -12, 0)
nameText:SetJustifyH("LEFT")
nameText:SetWordWrap(false)
nameText:SetTextColor(1, 1, 1)

-- Attempt summary line
local attemptText = alert:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
attemptText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
attemptText:SetPoint("RIGHT", alert, "RIGHT", -12, 0)
attemptText:SetJustifyH("LEFT")
attemptText:SetTextColor(0.6, 0.6, 0.6)

-- Click to dismiss
alert:EnableMouse(true)
alert:SetScript("OnMouseDown", function()
    animPhase = "fade_out"
    animStartTime = GetTime()
end)

---------------------------------------------------------------------------
-- ANIMATION STATE
---------------------------------------------------------------------------

local animPhase = "idle"    -- "idle", "slide_in", "display", "fade_out"
local animStartTime = 0
local TARGET_Y = -20        -- Final resting position below top edge

---------------------------------------------------------------------------
-- QUEUE
-- Multiple finds at once (rare, but possible) get shown sequentially.
---------------------------------------------------------------------------

local alertQueue = {}

local function ShowAlert(itemName, item, attempts)
    -- Set icon
    local itemIcon = ns.ItemResolver:GetIcon(item.itemId)
    icon:SetTexture(itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")

    -- Set text
    nameText:SetText(itemName or "Unknown")

    if attempts and attempts > 0 then
        local summary = ns.AttemptTracker:GetSummaryText(item)
        attemptText:SetText("After " .. summary)
    else
        attemptText:SetText("Added to your collection!")
    end

    -- Reset position off-screen and start animation
    alert:ClearAllPoints()
    alert:SetPoint("TOP", UIParent, "TOP", 0, SLIDE_DISTANCE)
    alert:SetAlpha(0)
    alert:Show()

    animPhase = "slide_in"
    animStartTime = GetTime()

    -- Play sound
    if ALERT_SOUND then
        PlaySound(ALERT_SOUND)
    end
end

local function ProcessQueue()
    if #alertQueue == 0 then return end
    local data = table.remove(alertQueue, 1)
    ShowAlert(data.name, data.item, data.attempts)
end

---------------------------------------------------------------------------
-- ONUPDATE — drives the three-phase animation
---------------------------------------------------------------------------

local function OnUpdate(self, elapsed)
    if animPhase == "idle" then return end

    local now = GetTime()
    local dt = now - animStartTime

    if animPhase == "slide_in" then
        -- Ease-out cubic: fast start, gentle landing
        local progress = math.min(dt / SLIDE_DURATION, 1)
        local eased = 1 - (1 - progress) * (1 - progress) * (1 - progress)

        local y = SLIDE_DISTANCE - (SLIDE_DISTANCE + math.abs(TARGET_Y)) * eased
        alert:ClearAllPoints()
        alert:SetPoint("TOP", UIParent, "TOP", 0, y)
        alert:SetAlpha(eased)

        if progress >= 1 then
            animPhase = "display"
            animStartTime = now
            alert:SetAlpha(1)
        end

    elseif animPhase == "display" then
        -- Pulse the glow while displayed
        local pulse = (now * 2.5) % (math.pi * 2)
        iconGlow:SetAlpha(0.4 + 0.4 * math.sin(pulse))

        if dt >= DISPLAY_DURATION then
            animPhase = "fade_out"
            animStartTime = now
        end

    elseif animPhase == "fade_out" then
        local progress = math.min(dt / FADE_DURATION, 1)
        alert:SetAlpha(1 - progress)

        -- Slide up slightly as it fades
        local y = TARGET_Y - (20 * progress)
        alert:ClearAllPoints()
        alert:SetPoint("TOP", UIParent, "TOP", 0, y)

        if progress >= 1 then
            animPhase = "idle"
            alert:Hide()
            -- Process next in queue
            ProcessQueue()
        end
    end
end

alert:SetScript("OnUpdate", OnUpdate)

---------------------------------------------------------------------------
-- TEST COMMAND
-- /rng testalert — fires a fake alert for testing
---------------------------------------------------------------------------

function FoundAlert:TestAlert()
    local fakeItem = {
        name = "Invincible's Reins",
        itemId = 50818,
        spellId = 72286,
        attempts = 347,
        chance = 100,
    }
    ShowAlert("Invincible's Reins", fakeItem, 347)
end

---------------------------------------------------------------------------
-- INIT
---------------------------------------------------------------------------

function FoundAlert:Init()
    ns.EventBus:RegisterAddonEvent(ns.Events.ITEM_FOUND, function(event, itemName, item, attempts)
        -- Only show the alert for real drops (attempts > 0).
        -- Collection scan on login fires ITEM_FOUND with 0 attempts —
        -- we don't want 137 alert popups on every login.
        if attempts and attempts > 0 then
            if animPhase ~= "idle" then
                -- Currently showing an alert — queue this one
                table.insert(alertQueue, {
                    name = itemName,
                    item = item,
                    attempts = attempts,
                })
            else
                ShowAlert(itemName, item, attempts)
            end
        end

        ns.RNGeez:Debug("FoundAlert: %s (%d attempts)%s",
            itemName, attempts or 0,
            (attempts and attempts > 0) and " — ALERT!" or " — skipped (scan)")
    end)

    ns.RNGeez:Debug("FoundAlert initialized.")
end
