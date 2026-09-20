# Lorti UI Forever â€” local beta port

This ports the original Lorti UI Classic 1.1.0 appearance onto Forever's native UI.
It uses the original gloss, pushed-button, flash and shadow artwork. It darkens
the player, target, focus, pet and party borders, minimap ring, gryphons, supported
window borders and exposed raid borders. Buttons and accessible player buff icons
use Lorti's cropped icons, outline fonts and shadows.

## Install and use

The install folder must be `Interface/AddOns/LortiUIForever`. Only copy
`LortiUIForever.toc`, `forever/`, `textures/`, `LICENSE` and the documentation into it. The old Classic TOC,
`config.lua` and `core/` are reference source and must not be loaded in Forever.

Enable **Lorti UI Forever** in the character screen's AddOns list, then log in.
For a clear visual check, disable the overlapping Gryphon UI skins and any older
Lorti install. This port does not change their settings. If the client does not
detect the new addon after `/reload`, return to the character screen or restart it.

- `/lorti` shows client/build details, options and numbers of styled objects.
- `/lorti off` or `/lorti on` disables or enables the port after `/reload`.
- `/lorti frames on|off` toggles dark frame artwork.
- `/lorti buttons on|off` toggles action and bag button styling.
- `/lorti auras on|off` toggles accessible buff/debuff icon styling.
- `/lorti hotkeys on|off` shows or hides keybind text.
- `/lorti macronames on|off` shows or hides macro names.

All changes take effect after `/reload`. Keybind text starts on; macro names start
off, matching the Classic source. Masque skips this port's button module.

## Forever differences

Forever keeps its frame shapes, layout, health/power bars, buff positions and
native controls. This is a Lorti skin, not a reconstruction of Classic geometry.
The old Classic elite/rare replacement art does not fit Forever's atlases, so
Forever's classification art stays intact. The old spellbook parchment overlay
also stays off because its hard-coded Classic dimensions do not fit the new UI.

The original error-message filter, hidden PvP indicators, minimap button hiding
and buff dragging code are not loaded. Native behaviour and useful indicators
remain available. Edit Mode controls frame positions. Protected target/focus aura
objects that Forever marks forbidden stay native; the port does not bypass that
restriction. Third-party bar addons and every load-on-demand window are not yet
certified. Darkening a supported border does not promise full-window coverage.

## Validation

Development reference: extracted Blizzard UI source `1.60.1.69893`, including
Camelot overrides and shared/Mainline templates used by that client. Installed
client metadata on 2026-09-20 reports `1.60.1.69913`; the manifest targets `16001`.
The extraction is an older build and is not evidence of live compatibility.

Offline checks cover Lua 5.1 parsing, missing/late frames, duplicate hooks, combat
deferral, forbidden objects, saved settings and new-style buttons/buffs. An install
receipt records copied-file hashes. These checks do not prove in-game rendering,
combat safety or taint behaviour.

In-game check still needed:

1. Enable the port with overlapping skins disabled. Run `/lorti` and check for errors.
2. Check the player, target, elite/rare target, focus, pet, party and raid borders.
3. Use actions, keybinds, stance/pet buttons and spell flyouts. Check cooldowns,
   equipped borders, proc alerts and unusable/out-of-range indicators.
4. Gain and cancel a buff; check durations, debuff colours and weapon enchants.
5. Open bags, spellbook, character, merchant, map and tooltips. Try Edit Mode.
6. Repeat targeting/actions in combat, then leave combat. `/reload` and check again.

If an error appears, record the first full error and `/lorti` output.

## Credits and license

This is an unofficial port of Lorti UI. It is not an official release by the
original authors, and it is not affiliated with Blizzard Entertainment.

- Original Lorti UI: **Lorti / lortipwnz** — https://www.curseforge.com/wow/addons/lorti_ui
- Classic adaptation: **Chordsy and the upstream contributors**.
- Source used: https://github.com/EzioAu/Lorti-UI-Classic
- Upstream revision: `7e0cf9162b6752adf20ead39d2ce0f992ed7b61b` (Classic 1.1.0).
- Forever adaptation and maintenance: **Videocat / coffeelover1010**.

Released under the **GNU General Public License version 3 (GPLv3)**. See
[LICENSE](LICENSE) and [NOTICE.md](NOTICE.md). The original project's license is
published at https://www.curseforge.com/wow/addons/lorti_ui/license.
The upstream snapshot omitted a license file; this distribution includes it.
Original code and artwork remain credited to their respective authors.
