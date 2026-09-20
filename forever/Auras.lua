-- Lorti UI Forever: Forever adaptation, 2026-09-20.
-- Copyright (C) 2026 Videocat (coffeelover1010). GPL-3.0-only.
-- Based on Lorti UI / Lorti UI Classic; see NOTICE.md and LICENSE.
local _, ns = ...
local styled = setmetatable({}, { __mode = "k" })
local function style(button)
    if not ns.Safe(button) or styled[button] then return end
    local icon = button.Icon or button.icon
    if not ns.Safe(icon) or not icon.SetTexCoord then return end
    styled[button] = true
    ns.counts.auras = ns.counts.auras + 1
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    local edge = ns.Outline(button, icon, true)
    -- Keep dispel/weapon-enchant colours above the decorative outline.
    edge:SetDrawLayer("ARTWORK", 1)
    if button.Duration then button.Duration:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE") end
    if button.Count then button.Count:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE") end
end

local function apply()
    for _, name in ipairs({ "BuffFrame", "DebuffFrame", "ExternalDefensivesFrame" }) do
        local frame = ns.Resolve(name)
        if frame then
            for _, button in ipairs(frame.auraFrames or {}) do style(button) end
            ns.Hook(frame, "UpdateAuraButtons", ns.Queue)
        end
    end
    -- Legacy exposed auras can still be used by compatible layout addons.
    -- Forever's forbidden target/focus aura objects deliberately stay native.
    for _, prefix in ipairs({ "BuffButton", "DebuffButton", "TempEnchant", "TargetFrameBuff",
        "TargetFrameDebuff", "FocusFrameBuff", "FocusFrameDebuff" }) do
        for i = 1, 40 do
            local button = _G[prefix .. i]
            if ns.Safe(button) and not styled[button] then
                local icon = button.Icon or _G[prefix .. i .. "Icon"]
                if icon then
                    -- Avoid adding field aliases to Blizzard's secure frames.
                    if button.Icon then style(button)
                    elseif ns.Safe(icon) and icon.SetTexCoord then
                        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        ns.Outline(button, icon, true)
                        styled[button] = true
                        ns.counts.auras = ns.counts.auras + 1
                    end
                end
            end
        end
    end
end
table.insert(ns.modules, { option = "auras", apply = apply })
