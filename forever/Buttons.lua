-- Lorti UI Forever: Forever adaptation, 2026-09-20.
-- Copyright (C) 2026 Videocat (coffeelover1010). GPL-3.0-only.
-- Based on Lorti UI / Lorti UI Classic; see NOTICE.md and LICENSE.
local _, ns = ...
local styled = setmetatable({}, { __mode = "k" })
local prefixes = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
    "MultiBarRightButton", "MultiBarLeftButton", "MultiBar5Button", "MultiBar6Button",
    "MultiBar7Button", "PetActionButton", "StanceButton", "PossessButton", "OverrideActionBarButton" }

local function child(button, field, suffix)
    if button[field] then return button[field] end
    local name = button:GetName()
    return name and _G[name .. (suffix or field)]
end

local function style(button)
    if not ns.Safe(button) or styled[button] then return end
    local icon = child(button, "icon", "Icon") or button.Icon or child(button, "IconTexture")
    if not ns.Safe(icon) or not icon.SetTexCoord or not button.GetNormalTexture then return end
    local normal = button:GetNormalTexture()
    if not ns.Safe(normal) then return end
    styled[button] = true
    ns.counts.buttons = ns.counts.buttons + 1
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    -- Keep native masks, button geometry, cooldowns, checked state and overlays.
    local function normalArt()
        normal:SetTexture(ns.media .. "gloss")
        normal:SetTexCoord(0, 1, 0, 1)
    end
    normalArt()
    normal:SetAllPoints(button)
    ns.Tint(normal, 0.37, 0.3, 0.3)
    ns.Hook(normal, "SetAtlas", normalArt)
    local pushed = button.GetPushedTexture and button:GetPushedTexture()
    if ns.Safe(pushed) then pushed:SetTexture(ns.media .. "pushed"); pushed:SetAllPoints(button) end
    local flash = child(button, "Flash")
    if ns.Safe(flash) then flash:SetTexture(ns.media .. "flash") end
    ns.Tint(button.SlotArt, 0.2)
    -- An independent outline provides the original shadow without replacing
    -- item quality/equipped borders or Blizzard's cooldown frame.
    local edge = ns.Outline(button, button, false)
    edge:SetAlpha(0.35)
    local overlay = button.TextOverlayContainer
    local hotkey = overlay and overlay.HotKey or child(button, "HotKey")
    local count = overlay and overlay.Count or child(button, "Count")
    local label = child(button, "Name")
    for _, text in pairs({ hotkey = hotkey, count = count, label = label }) do
        if ns.Safe(text) and text.SetFont then text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE") end
    end
    local function textVisibility()
        if ns.Safe(hotkey) then hotkey:SetAlpha(ns.db.hotkeys and 1 or 0) end
        if ns.Safe(label) then label:SetAlpha(ns.db.macronames and 1 or 0) end
    end
    textVisibility()
    ns.Hook(button, "UpdateHotkeys", textVisibility)
    ns.Hook(button, "Update", textVisibility)
end

local function apply()
    -- Masque owns buttons when installed; do not compete for their textures.
    if C_AddOns and C_AddOns.IsAddOnLoaded("Masque") then return end
    for _, prefix in ipairs(prefixes) do
        for i = 1, 12 do style(_G[prefix .. i]) end
    end
    style(_G.MainMenuBarBackpackButton)
    for i = 0, 3 do style(_G["CharacterBag" .. i .. "Slot"]) end
    if SpellFlyout and ns.Safe(SpellFlyout) then
        ns.Hook(SpellFlyout, "Show", ns.Queue)
        if SpellFlyout.buttonPool and SpellFlyout.buttonPool.EnumerateActive then
            for button in SpellFlyout.buttonPool:EnumerateActive() do style(button) end
        end
        for i = 1, 30 do style(_G["SpellFlyoutButton" .. i]) end
    end
end
table.insert(ns.modules, { option = "buttons", apply = apply })
