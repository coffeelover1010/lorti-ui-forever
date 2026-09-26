-- Lorti UI Forever: Forever adaptation, 2026-09-20.
-- Copyright (C) 2026 Videocat (coffeelover1010). GPL-3.0-only.
-- Based on Lorti UI / Lorti UI Classic; see NOTICE.md and LICENSE.
local _, ns = ...
local dark = {
    "PlayerFrame.PlayerFrameContainer.FrameTexture",
    "PlayerFrame.PlayerFrameContainer.AlternatePowerFrameTexture",
    "PlayerFrame.PlayerFrameContainer.VehicleFrameTexture",
    "PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle",
    "PetFrameTexture", "PlayerFrameTexture",
    "TargetFrame.TargetFrameContainer.FrameTexture",
    "FocusFrame.TargetFrameContainer.FrameTexture",
    "TargetFrame.totFrame.FrameTexture", "FocusFrame.totFrame.FrameTexture",
    "TargetFrame.TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle",
    "FocusFrame.TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle",
    "PlayerCastingBarFrame.Border", "CastingBarFrame.Border", "PetCastingBarFrame.Border",
    "TargetFrameSpellBar.Border", "FocusFrameSpellBar.Border",
    "MirrorTimer1.Border", "MirrorTimer2.Border", "MirrorTimer3.Border",
    "MirrorTimer1Border", "MirrorTimer2Border", "MirrorTimer3Border",
}
local medium = {
    "MainActionBar.BorderArt",
    "MainActionBar.EndCaps.LeftEndCap.Texture", "MainActionBar.EndCaps.RightEndCap.Texture",
    "MainMenuBarLeftEndCap", "MainMenuBarRightEndCap", "StanceBarLeft", "StanceBarMiddle", "StanceBarRight",
}
local windows = {
    "CharacterFrame", "PaperDollFrame", "PetPaperDollFrame", "SpellBookFrame", "PlayerSpellsFrame",
    "SkillFrame", "ReputationFrame", "HonorFrame", "MerchantFrame", "LootFrame", "QuestFrame",
    "QuestLogFrame", "GossipFrame", "FriendsFrame", "MailFrame", "BankFrame",
    "TradeFrame", "ItemTextFrame", "TrainerFrame", "ClassTrainerFrame", "AuctionHouseFrame",
    "PVEFrame", "WorldMapFrame", "GameMenuFrame", "SettingsPanel", "HelpFrame", "TimeManagerFrame",
    "StopwatchFrame", "StopwatchTabFrame",
}
local pieces = { "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
    "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "TopBorder", "BottomBorder", "LeftBorder",
    "RightBorder", "PortraitFrame", "TitleBg", "Bg", "Background", "Border",
    "TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Bottom", "Left", "Right", "Center" }

local function decorate(frame)
    if not ns.Safe(frame) then return end
    for _, key in ipairs(pieces) do ns.Tint(frame[key], 0.35) end
    -- Never infer region purpose by its numeric position: Forever has added
    -- text, status fills and icons between the old Classic border regions.
    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if ns.Safe(region) and region.GetName then
                local name = region:GetName() or ""
                if name:find("Border") or name:find("Corner") or name:find("Background") or
                    name:match("Bg$") then ns.Tint(region, 0.35) end
            end
        end
    end
end

local function apply()
    for _, path in ipairs(dark) do ns.Tint(ns.Resolve(path), 0.05) end
    for _, path in ipairs(medium) do ns.Tint(ns.Resolve(path), 0.35) end
    for i = 1, 4 do
        ns.Tint(ns.Resolve("PartyFrame.MemberFrame" .. i .. ".Texture"), 0.05)
        ns.Tint(ns.Resolve("PartyFrame.MemberFrame" .. i .. ".PetFrame.Texture"), 0.05)
        ns.Tint(_G["PartyMemberFrame" .. i .. "Texture"], 0.05)
    end
    for i = 1, 40 do decorate(ns.Resolve("CompactRaidFrame" .. i)) end
    for group = 1, 8 do
        decorate(ns.Resolve("CompactRaidGroup" .. group .. "BorderFrame"))
        for member = 1, 5 do decorate(ns.Resolve("CompactRaidGroup" .. group .. "Member" .. member)) end
    end
    decorate(ns.Resolve("CompactRaidFrameContainerBorderFrame"))
    decorate(ns.Resolve("CompactRaidFrameManager"))
end
table.insert(ns.modules, { option = "frames", apply = apply })

local function applyTooltips()
    for _, name in ipairs({ "GameTooltip", "ShoppingTooltip1", "ShoppingTooltip2", "ItemRefTooltip" }) do
        local frame = ns.Resolve(name)
        if frame then decorate(frame.NineSlice); ns.Hook(frame, "Show", ns.Queue) end
    end
end
table.insert(ns.modules, { option = "tooltips", apply = applyTooltips })

local function applyWindows()
    for _, name in ipairs(windows) do
        local frame = ns.Resolve(name)
        if frame then
            decorate(frame); decorate(frame.NineSlice); decorate(frame.Inset)
            if frame.Inset then decorate(frame.Inset.NineSlice) end
            ns.Hook(frame, "Show", ns.Queue)
        end
    end
end

local function applyBags()
    local combined = ns.Resolve("ContainerFrameCombinedBags")
    if combined then
        decorate(combined); decorate(combined.NineSlice); decorate(combined.Inset)
        if combined.Inset then decorate(combined.Inset.NineSlice) end
        ns.Hook(combined, "Show", ns.Queue)
    end
    for i = 1, 13 do
        local frame = ns.Resolve("ContainerFrame" .. i)
        if frame then
            decorate(frame); decorate(frame.NineSlice)
            ns.Hook(frame, "Show", ns.Queue)
        end
    end
end

local function applyMinimap()
    for _, path in ipairs({
    "MinimapCompassTexture", "MinimapCompassTextureUnderlay", "MinimapBorder", "MiniMapMailBorder",
    }) do ns.Tint(ns.Resolve(path), 0.05) end
    decorate(ns.Resolve("MinimapCluster.BorderTop"))
end

table.insert(ns.modules, { option = "windows", apply = applyWindows })
table.insert(ns.modules, { option = "minimap", apply = applyMinimap })

table.insert(ns.modules, { option = "bags", apply = applyBags })

local function applyMenu()
    ns.Tint(ns.Resolve("MicroMenu.BorderArt"), 0.35)
    ns.Tint(ns.Resolve("MicroMenu.BackgroundArt"), 0.35)
    for _, name in ipairs({ "CharacterMicroButton", "ProfessionMicroButton", "PlayerSpellsMicroButton", "TalentMicroButton", "SpellbookMicroButton", "AchievementMicroButton", "LegacyMicroButton", "QuestLogMicroButton", "HousingMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "HelpMicroButton", "StoreMicroButton", "MainMenuMicroButton" }) do
        local button = ns.Resolve(name)
        if button then
            ns.Tint(button.Background, 0.35)
            ns.Tint(button.PushedBackground, 0.35)
        end
    end
end
table.insert(ns.modules, { option = "menu", apply = applyMenu })

-- Explicit artwork only; never visit bag icons or status-bar fill textures.
local function tintDividers(frame, xp)
    for _, key in ipairs({ "HorizontalDividersPool", "VerticalDividersPool" }) do
        local pool = frame[key]
        if pool and pool.EnumerateActive then
            for divider in pool:EnumerateActive() do
                if ns.Safe(divider) then
                    if xp then ns.Tint(divider.BarDividerTexture, 0.35)
                    else decorate(divider) end
                end
            end
        end
    end
    ns.Hook(frame, "UpdateDividers", ns.Queue)
end

local function applyBagBarArtwork()
    local frame = ns.Resolve("BagsBar")
    if frame then
        ns.Tint(frame.BorderArt, 0.35)
        tintDividers(frame, false)
    end
end
table.insert(ns.modules, { option = "bagbar", apply = applyBagBarArtwork })

local function applyXPBar()
    -- Blizzard reuses these container borders for XP and reputation bars.
    for _, name in ipairs({ "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer" }) do
        local frame = ns.Resolve(name)
        if frame then
            ns.Tint(frame.BarFrameTexture, 0.35)
            tintDividers(frame, true)
        end
    end
end
table.insert(ns.modules, { option = "xpbar", apply = applyXPBar })
