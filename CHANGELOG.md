# Changelog

## 0.1.3-beta — 2026-09-26

- Added separate options for bag windows, bag bar, key ring, menu bar and XP bar borders.
- Added the missing bag bar outer border and dividers.
- Kept native icon artwork and cropping. XP and rested-XP colours stay unchanged.
- Shortened option labels and made room for all checkboxes.
- Existing bag settings keep their previous appearance. Key ring, menu and XP options start off.
- Replaced shadow backdrops with fixed texture pieces to avoid secret-size arithmetic.

Use Settings > AddOns > Lorti UI Forever, then Reload UI. The XP border is shared with reputation bars.

Appearance checked in game by the user. Lua 5.1 and offline compatibility checks passed; full combat and taint testing remains outstanding.

## 0.1.2-beta — 2026-09-20

- Added a separate Dark tooltip borders checkbox and `/lorti tooltips on|off` command.
- Existing installs keep their previous tooltip choice until it is changed. Use `/reload` to apply.

## 0.1.1-beta — 2026-09-20

- Added an in-game settings panel with a Reload UI button.
- Added separate minimap and window darkening options. Window darkening defaults to off.
- Added a Forever settings backup to help recover options across reloads.
- Lua syntax checked; live reload, combat and taint checks remain outstanding.

## 0.1.0-beta — 2026-09-20

- First unofficial Forever beta port of Lorti UI Classic 1.1.0.
- Dark native frame borders, glossy action buttons and accessible aura styling.
- Saved options and `/lorti` commands, with guards for combat and forbidden frames.
- Original Classic modules replaced by Forever modules in the release manifest.
- GPLv3 license, upstream credits and source references included.

Offline checks do not establish full in-game compatibility. Combat, raid and
taint testing remain outstanding.
