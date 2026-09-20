-- Lorti UI Forever: Forever adaptation, 2026-09-20.
-- Copyright (C) 2026 Videocat (coffeelover1010). GPL-3.0-only.
-- Based on Lorti UI / Lorti UI Classic; see NOTICE.md and LICENSE.
local addon, ns = ...
ns.media = "Interface\\AddOns\\" .. addon .. "\\textures\\"
ns.modules = {}
ns.counts = { textures = 0, buttons = 0, auras = 0 }
local defaults = { enabled = true, frames = true, buttons = true, auras = true,
    hotkeys = true, macronames = false }
local tinted = setmetatable({}, { __mode = "k" })
local hooked = setmetatable({}, { __mode = "k" })

function ns.Safe(object)
    return object and not (object.IsForbidden and object:IsForbidden())
end

function ns.Resolve(path)
    local object = _G
    for part in path:gmatch("[^.]+") do
        if not ns.Safe(object) then return end
        object = object[part]
    end
    if ns.Safe(object) then return object end
end

function ns.Hook(object, method, callback)
    if not ns.Safe(object) or type(object[method]) ~= "function" then return end
    local methods = hooked[object]
    if not methods then methods = {}; hooked[object] = methods end
    if methods[method] then return end
    methods[method] = true
    hooksecurefunc(object, method, callback)
end

-- Only decorative textures are passed here. Do not tint health, portraits,
-- reaction colours, PvP markers, quest icons, cooldowns or proc alerts.
function ns.Tint(texture, shade, green, blue)
    if not ns.Safe(texture) or not texture.IsObjectType or
        not texture:IsObjectType("Texture") then return end
    if tinted[texture] then return end
    tinted[texture] = true
    ns.counts.textures = ns.counts.textures + 1
    local changing = false
    local function apply()
        if changing then return end
        changing = true
        texture:SetVertexColor(shade, green or shade, blue or shade)
        changing = false
    end
    apply()
    ns.Hook(texture, "SetVertexColor", apply)
end

function ns.Outline(owner, anchor, aura)
    local edge = owner:CreateTexture(nil, "OVERLAY", nil, 1)
    edge:SetTexture(ns.media .. "gloss")
    edge:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
    edge:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
    edge:SetVertexColor(0.4, 0.35, 0.35)
    local shadow = CreateFrame("Frame", nil, owner, "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    shadow:SetFrameLevel(math.max(0, owner:GetFrameLevel() - 1))
    shadow:EnableMouse(false)
    shadow:SetBackdrop({ edgeFile = ns.media .. "outer_shadow", edgeSize = aura and 4 or 5,
        insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.9)
    return edge, shadow
end

local pending, ready, combatPending = false, false, false
local function apply()
    pending = false
    if not ready or not ns.db.enabled then return end
    if InCombatLockdown() then combatPending = true; return end
    combatPending = false
    for _, module in ipairs(ns.modules) do
        if ns.db[module.option] then module.apply() end
    end
end

function ns.Queue()
    if pending or not ready then return end
    pending = true
    C_Timer.After(0.1, apply)
end

local function printLine(text)
    print("|cffb8a5a5Lorti UI Forever:|r " .. text)
end

local function status()
    local version, build, _, interface = GetBuildInfo()
    printLine("0.1.0-beta | client " .. tostring(version) .. " (" .. tostring(build) ..
        "), interface " .. tostring(interface))
    printLine("Styled " .. ns.counts.textures .. " artwork textures, " .. ns.counts.buttons ..
        " buttons and " .. ns.counts.auras .. " aura icons this session.")
    for _, key in ipairs({ "enabled", "frames", "buttons", "auras", "hotkeys", "macronames" }) do
        printLine(key .. ": " .. (ns.db[key] and "on" or "off"))
    end
    printLine("Setting changes take effect after /reload. Live beta testing is still required.")
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD",
    "PLAYER_REGEN_ENABLED", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED",
    "PLAYER_FOCUS_CHANGED", "UPDATE_SHAPESHIFT_FORMS", "SPELLS_CHANGED" }) do
    events:RegisterEvent(event)
end
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addon then
        if type(LortiUIForeverDB) ~= "table" then LortiUIForeverDB = {} end
        ns.db = LortiUIForeverDB
        for key, value in pairs(defaults) do
            if type(ns.db[key]) ~= "boolean" then ns.db[key] = value end
        end
        SLASH_LORTIUIFOREVER1 = "/lorti"
        SLASH_LORTIUIFOREVER2 = "/lortiforever"
        SlashCmdList.LORTIUIFOREVER = function(message)
            local key, value = message:lower():match("^%s*(%S+)%s*(%S*)%s*$")
            if not key or key == "status" then status(); return end
            if key == "on" or key == "off" then value = key; key = "enabled" end
            if defaults[key] ~= nil and (value == "on" or value == "off") then
                ns.db[key] = value == "on"
                printLine(key .. " " .. value .. ". Use /reload to apply.")
            else
                printLine("/lorti status | /lorti on|off | /lorti frames|buttons|auras|hotkeys|macronames on|off")
            end
        end
    elseif event == "PLAYER_LOGIN" then
        ready = true
        if ns.db.enabled and C_AddOns and C_AddOns.IsAddOnLoaded then
            for _, other in ipairs({ "GryphonUI_ActionBars", "GryphonUI_PlayerFrame", "GryphonUI_UnitArtwork", "Lorti-UI-Classic" }) do
                if C_AddOns.IsAddOnLoaded(other) then
                    printLine("Another UI skin is loaded (" .. other .. "). Disable overlapping skins to check Lorti's appearance.")
                    break
                end
            end
        end
        ns.Queue()
    elseif event ~= "PLAYER_REGEN_ENABLED" or combatPending then
        ns.Queue()
    end
end)
