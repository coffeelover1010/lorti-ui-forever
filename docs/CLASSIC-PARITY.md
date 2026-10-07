# Classic feature comparison

Compared on 2026-10-05 against the retained Classic 1.1.0 source in core/ and config.lua, not every later Lorti fork. This is source-level evidence, not proof of live rendering.

| Feature | Forever status |
| --- | --- |
| Bartender action and pet button borders | Added in 0.1.4-beta. Uses the installed LibActionButton registry, restores artwork after texture/atlas resets, discovers later action buttons, defers initial styling during combat. Live verification pending. |
| Dark gloss and outer shadows | Present. Normal tint is the original 0.37/0.3/0.3; the outer shadow is already black at 0.9 alpha. The 0.35 alpha in Buttons.lua belongs to an extra gloss outline, not the shadow. |
| Dominos integration | Missing: Classic explicitly enumerates DominosActionButton; Forever does not. |
| Classic icon crop and inset | Deliberately absent: current port preserves native masks, crop, anchors and cooldown geometry. Classic crops to 0.1–0.9 and insets icons by 2 pixels. |
| Button background and equipped appearance | Partial: original separate button_background layer and green tint of the normal border are not reproduced. Native slot backgrounds and equipped indicators remain. |
| Button configuration | No separate gloss switch, class-colour switch, background/shadow switches or stack-count visibility option. Original config.lua exposed colour/background/font/position settings; it is not loaded by Forever. Bartender retains its own label settings. |
| Buff/debuff layout | Missing: original movable anchors, row/column spacing, size, combined layout and duration formatting. Forever adds decorative borders/fonts to accessible native icons without rearranging them. |
| Target/focus auras | Partial: accessible legacy objects supported; forbidden objects skipped. |
| Elite/rare target artwork | Missing: original custom elite, rare and rare-elite textures are not applied; native artwork remains. |
| Raid/window/tooltip colours | Partial: named decorative pieces are tinted, but coverage and shades differ. Original raid and tooltip borders often use 0.05; generic Forever decoration uses 0.35. Exact visual parity is unverified. |
| Spellbook artwork | Missing: original custom QuestBG overlay is not reproduced. |
| Minimap behaviour | Not ported: original mouse-wheel handler and hidden calendar, zoom and map controls. Current port only styles borders. Native client functionality may already cover some behaviour. |
| UI suppression | Not ported: original error-message filtering, hidden PvP/group/absent-party indicators and player/pet hit text. These affect information, not just appearance. |
| Masque | Button styling yields when Masque is loaded. Current rule is broader than Classic, which yielded with Masque plus Bartender/Dominos. |
| Bartender flyouts/art bars | Not specifically integrated in this change. Native SpellFlyout handling remains; LAB flyouts and Bartender decorative bar art require a separate review. |

## Live check for 0.1.4-beta

With Lorti and Bartender enabled, and Masque disabled for this check: /reload, then /lorti status. Confirm dark borders on occupied/empty buttons and pet buttons; change pages, move an ability, change a Bartender profile and enable another bar. Check keybind/macro labels, cooldowns, equipped indicators and pet autocast remain correct. Enter and leave combat, cast with mouse and keybinds, and report the first Lua/blocked-action error. Offline mocks cannot establish rendering or taint safety.
