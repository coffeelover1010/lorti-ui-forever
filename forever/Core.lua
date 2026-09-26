-- Lorti UI Forever: Forever adaptation, 2026-09-20.
-- Copyright (C) 2026 Videocat (coffeelover1010). GPL-3.0-only.
-- Based on Lorti UI / Lorti UI Classic; see NOTICE.md and LICENSE.
local addon, ns = ...
ns.media = "Interface\\AddOns\\" .. addon .. "\\textures\\"
ns.modules = {}
ns.counts = { textures = 0, buttons = 0, auras = 0 }
local defaults = { enabled = true, frames = true, minimap = true, windows = false, bags = false, bagbar = true, keyring = false, menu = false, xpbar = false, buttons = true, auras = true,
    tooltips = true, hotkeys = true, macronames = false }
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
    -- BackdropTemplate reads dimensions on resize. Aura dimensions can become
    -- secret in combat, so use fixed UVs and native anchors instead.
    local shadow = CreateFrame("Frame", nil, owner)
    shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 4, -4)
    shadow:SetFrameLevel(math.max(0, owner:GetFrameLevel() - 1))
    shadow:EnableMouse(false)
    local size = aura and 4 or 5
    local function corner(point, left, right)
        local texture = shadow:CreateTexture(nil, "BACKGROUND")
        texture:SetTexture(ns.media .. "outer_shadow")
        texture:SetVertexColor(0, 0, 0, 0.9)
        texture:SetTexCoord(left, right, 0.0625, 0.9375)
        texture:SetSize(size, size)
        texture:SetPoint(point, shadow, point)
        return texture
    end
    local tl = corner("TOPLEFT", 0.5078125, 0.6171875)
    local tr = corner("TOPRIGHT", 0.6328125, 0.7421875)
    local bl = corner("BOTTOMLEFT", 0.7578125, 0.8671875)
    local br = corner("BOTTOMRIGHT", 0.8828125, 0.9921875)
    local function side(first, firstPoint, last, lastPoint, left, right, horizontal)
        local texture = shadow:CreateTexture(nil, "BACKGROUND")
        texture:SetTexture(ns.media .. "outer_shadow")
        texture:SetVertexColor(0, 0, 0, 0.9)
        if horizontal then
            texture:SetHeight(size)
            texture:SetTexCoord(left, 0.9375, right, 0.9375,
                left, 0.0625, right, 0.0625)
            texture:SetPoint("TOPLEFT", first, firstPoint)
            texture:SetPoint("TOPRIGHT", last, lastPoint)
        else
            texture:SetWidth(size)
            texture:SetTexCoord(left, right, 0.0625, 0.9375)
            texture:SetPoint("TOPLEFT", first, firstPoint)
            texture:SetPoint("BOTTOMLEFT", last, lastPoint)
        end
    end
    side(tl, "TOPRIGHT", tr, "TOPLEFT", 0.2578125, 0.3671875, true)
    side(bl, "TOPRIGHT", br, "TOPLEFT", 0.3828125, 0.4921875, true)
    side(tl, "BOTTOMLEFT", bl, "TOPLEFT", 0.0078125, 0.1171875)
    side(tr, "BOTTOMLEFT", br, "TOPLEFT", 0.1328125, 0.2421875)
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
    printLine("0.1.3-beta | client " .. tostring(version) .. " (" .. tostring(build) ..
        "), interface " .. tostring(interface))
    printLine("Styled " .. ns.counts.textures .. " artwork textures, " .. ns.counts.buttons ..
        " buttons and " .. ns.counts.auras .. " aura icons this session.")
    for _, key in ipairs({ "enabled", "frames", "minimap", "windows", "bags", "bagbar", "keyring", "menu", "xpbar", "tooltips", "buttons", "auras", "hotkeys", "macronames" }) do
        printLine(key .. ": " .. (ns.db[key] and "on" or "off"))
    end
    printLine("Setting changes take effect after /reload. Live beta testing is still required.")
end

local function createSettings()
    if ns.settingsCategory or not Settings or not Settings.RegisterCanvasLayoutCategory then return end
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:Hide()
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Lorti UI Forever")
    local hint = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    hint:SetPoint("TOPLEFT", 16, -48)
    hint:SetText("Choose what Lorti changes, then click Reload UI to apply.")
    local rows = {
        { "enabled", "Enable Lorti" },
        { "frames", "Unit frames and action bar artwork" },
        { "minimap", "Minimap border" },
        { "windows", "Other windows (spellbook, quests and more)" },
        { "bags", "Bag windows" },
        { "bagbar", "Bag bar buttons" },
        { "keyring", "Key ring button" },
        { "menu", "Menu bar" },
        { "xpbar", "XP bar border (shared with reputation)" },
        { "tooltips", "Tooltip borders" },
        { "buttons", "Action buttons" },
        { "auras", "Buff and debuff icons" },
        { "hotkeys", "Show keybind text on styled buttons" },
        { "macronames", "Show macro names on styled buttons" },
    }
    local checks = {}
    local function refresh()
        for key, check in pairs(checks) do
            check:SetChecked(ns.db[key])
        end
    end
    for index, row in ipairs(rows) do
        local key = row[1]
        local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        check:SetPoint("TOPLEFT", 16, -78 - (index - 1) * 30)
        check:SetSize(26, 26)
        local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("LEFT", check, "RIGHT", 6, 0)
        label:SetText(row[2])
        check:SetScript("OnClick", function(self)
            ns.db[key] = self:GetChecked() and true or false
        end)
        checks[key] = check
    end
    local reload = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reload:SetPoint("TOPLEFT", 16, -98 - #rows * 30)
    reload:SetSize(140, 26)
    reload:SetText("Reload UI")
    reload:SetScript("OnClick", function()
        if not InCombatLockdown() then ReloadUI() end
    end)
    panel:SetScript("OnShow", function()
        refresh()
        reload:SetEnabled(not InCombatLockdown())
    end)
    panel:RegisterEvent("PLAYER_REGEN_DISABLED")
    panel:RegisterEvent("PLAYER_REGEN_ENABLED")
    panel:SetScript("OnEvent", function() reload:SetEnabled(not InCombatLockdown()) end)
    ns.RefreshSettings = refresh
    ns.settingsCategory = Settings.RegisterCanvasLayoutCategory(panel, "Lorti UI Forever")
    Settings.RegisterAddOnCategory(ns.settingsCategory)
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
        -- Preserve the old appearance when adding independent bag switches.
        if type(ns.db.bags) ~= "boolean" then ns.db.bags = ns.db.windows == true end
        if type(ns.db.bagbar) ~= "boolean" then ns.db.bagbar = ns.db.buttons ~= false end
        -- Tooltips previously followed frames. Preserve that choice on upgrade.
        if type(ns.db.tooltips) ~= "boolean" then
            ns.db.tooltips = ns.db.frames ~= false
        end
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
                if ns.RefreshSettings then ns.RefreshSettings() end
                printLine(key .. " " .. value .. ". Use /reload to apply.")
            else
                printLine("/lorti status | /lorti on|off | /lorti frames|minimap|windows|bags|bagbar|keyring|menu|xpbar|tooltips|buttons|auras|hotkeys|macronames on|off")
            end
        end
    elseif event == "PLAYER_LOGIN" then
        createSettings()
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
