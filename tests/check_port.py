"""Offline contracts; requires lupa with its Lua 5.1 runtime. Not a game test."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [ROOT / s.strip().replace('\\', '/') for s in
           (ROOT / 'LortiUIForever.toc').read_text().splitlines()
           if s.strip() and not s.startswith('#')]

MOCK = r'''
timers, events, messages = {}, {}, {}
combat = false
STANDARD_TEXT_FONT = 'font'
SlashCmdList = {}
C_AddOns = { IsAddOnLoaded = function() return false end }
C_Timer = { After = function(_, fn) table.insert(timers, fn) end }
function InCombatLockdown() return combat end
function GetBuildInfo() return '1.60.1', '69913', '', 16001 end
function print(text) table.insert(messages, text) end
function hooksecurefunc(object, method, hook)
    local original = object[method]
    object[method] = function(self, ...)
        local result = original(self, ...)
        hook(self, ...)
        return result
    end
    object.hooks = (object.hooks or 0) + 1
end
function object(kind, name)
    local o = { kind = kind, name = name, hooks = 0, regions = {} }
    function o:IsForbidden() return self.forbidden end
    function o:IsObjectType(t) return self.kind == t end
    function o:GetName() return self.name end
    function o:GetRegions() return unpack(self.regions) end
    function o:SetVertexColor(...) self.color = {...} end
    function o:SetTexture(t) self.texture = t end
    function o:SetAtlas(t) self.atlas = t end
    function o:SetTexCoord(...) self.coords = {...} end
    function o:SetPoint(...) self.point = {...} end
    function o:SetAllPoints(t) self.anchor = t end
    function o:SetAlpha(a) self.alpha = a end
    function o:SetDrawLayer(...) end
    function o:SetFont(...) self.font = {...} end
    function o:GetFrameLevel() return 3 end
    function o:SetFrameLevel(n) end
    function o:EnableMouse(b) end
    function o:SetBackdrop(t) self.backdrop = t end
    function o:SetBackdropBorderColor(...) end
    function o:CreateTexture() local t = object('Texture'); table.insert(self.regions, t); return t end
    function o:Show() end
    function o:Update() end
    function o:UpdateHotkeys() end
    function o:UpdateAuraButtons() end
    function o:GetNormalTexture() return self.normal end
    function o:GetPushedTexture() return self.pushed end
    function o:RegisterEvent(event) events[event] = events[event] or {}; table.insert(events[event], self) end
    function o:SetScript(event, fn) self[event] = fn end
    return o
end
function CreateFrame(kind, name, parent, template)
    assert(not combat or parent == nil, 'Child frame created during combat')
    local o = object(kind, name); o.parent = parent; o.template = template
    return o
end
function fire(event, ...)
    for _, frame in ipairs(events[event] or {}) do frame.OnEvent(frame, event, ...) end
end
function drain()
    local n = 0
    while #timers > 0 do n = n + 1; assert(n < 20, 'timer loop'); table.remove(timers, 1)() end
end
function setupObjects()
    PlayerFrame = { PlayerFrameContainer = { FrameTexture = object('Texture') } }
    ActionButton1 = object('Button', 'ActionButton1')
    ActionButton1.icon = object('Texture')
    ActionButton1.normal = object('Texture')
    ActionButton1.pushed = object('Texture')
    ActionButton1.TextOverlayContainer = { HotKey = object('FontString'), Count = object('FontString') }
    ActionButton1.Name = object('FontString')
    ActionButton1.Border = object('Texture')
    ActionButton1.cooldown = object('Cooldown')
    BuffFrame = object('Frame')
    local aura = object('Button')
    aura.Icon = object('Texture'); aura.Duration = object('FontString')
    aura.DebuffBorder = object('Texture')
    BuffFrame.auraFrames = { aura }
    TargetFrameBuff1 = setmetatable({ IsForbidden = function() return true end }, {
        __index = function() error('Forbidden object touched') end })
end
'''

def runtime(setup='', saved=''):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(MOCK + saved + setup)
    ns = lua.table()
    for path in SOURCES:
        assert path.is_file(), path
        lua.execute('return assert(loadstring(...))', path.read_text())('LortiUIForever', ns)
    lua.execute("fire('ADDON_LOADED', 'LortiUIForever'); fire('PLAYER_LOGIN'); drain()")
    return lua, ns

lua, ns = runtime()
assert ns.counts.textures == 0
lua.execute("setupObjects(); fire('ADDON_LOADED', 'Blizzard_BuffFrame'); drain()")
assert ns.counts.buttons == 1 and ns.counts.auras == 1
lua.execute(r'''
assert(ActionButton1.normal.texture == 'Interface\\AddOns\\LortiUIForever\\textures\\gloss')
assert(ActionButton1.Name.alpha == 0 and ActionButton1.TextOverlayContainer.HotKey.alpha == 1)
assert(ActionButton1.Border.color == nil and ActionButton1.cooldown.point == nil)
assert(BuffFrame.auraFrames[1].DebuffBorder.color == nil)
local tex = PlayerFrame.PlayerFrameContainer.FrameTexture
local hooks = tex.hooks
tex:SetVertexColor(1, 1, 1); assert(tex.color[1] == 0.05)
for i = 1, 10 do fire('PLAYER_ENTERING_WORLD'); drain() end
assert(tex.hooks == hooks)
ActionButton1.normal:SetAtlas('reset'); assert(ActionButton1.normal.texture:find('gloss'))
''')
assert ns.counts.buttons == 1 and ns.counts.auras == 1
lua.execute('''
combat = true
ActionButton2 = object('Button', 'ActionButton2')
ActionButton2.icon = object('Texture'); ActionButton2.normal = object('Texture')
fire('SPELLS_CHANGED'); drain()
assert(ActionButton2.normal.texture == nil)
combat = false; fire('PLAYER_REGEN_ENABLED'); drain()
assert(ActionButton2.normal.texture ~= nil)
SlashCmdList.LORTIUIFOREVER('off'); assert(not LortiUIForeverDB.enabled)
''')
lua, ns = runtime('setupObjects()', 'LortiUIForeverDB = {enabled=false}\n')
assert ns.counts.buttons == 0 and ns.counts.textures == 0
lua, ns = runtime('setupObjects()', 'LortiUIForeverDB = {buttons=false, hotkeys=false, macronames=true}\n')
assert ns.counts.buttons == 0 and ns.counts.auras == 1
lua, ns = runtime('setupObjects()', 'LortiUIForeverDB = {hotkeys=false, macronames=true}\n')
lua.execute('assert(ActionButton1.Name.alpha == 1 and ActionButton1.TextOverlayContainer.HotKey.alpha == 0)')
lua, ns = runtime('setupObjects(); C_AddOns.IsAddOnLoaded = function(n) return n == "Masque" end')
assert ns.counts.buttons == 0
lua, ns = runtime('setupObjects(); combat = true')
assert ns.counts.buttons == 0
lua.execute("combat = false; fire('PLAYER_REGEN_ENABLED'); drain()")
assert ns.counts.buttons == 1
lua, ns = runtime('setupObjects()', 'LortiUIForeverDB = "invalid"\n')
assert ns.counts.buttons == 1
lua.execute('''
local button = object('Button')
button.icon = object('Texture'); button.normal = object('Texture')
SpellFlyout = object('Frame')
SpellFlyout.buttonPool = { EnumerateActive = function()
    local done = false
    return function() if not done then done = true; return button end end
end }
fire('SPELLS_CHANGED'); drain()
assert(button.normal.texture ~= nil)
''')
assert ns.counts.buttons == 2
print('PASS: Lua 5.1 syntax and offline compatibility contracts (not a live-client test).')
