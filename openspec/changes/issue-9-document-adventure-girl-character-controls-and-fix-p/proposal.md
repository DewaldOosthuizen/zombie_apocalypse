# Proposal — Issue #9
# Document Adventure Girl character controls and fix project name mismatch


## Problem

Two independent documentation issues exist in the repository.

### 1. project.godot — wrong config/name (line 18)

The Godot project file declares:

    config/name="Retro_Apocalyse"

This is wrong on two counts:
- "Apocalyse" is a typo (missing 'p') — correct spelling is "Apocalypse".
- The name itself ("Retro_Apocalypse") does not match the repository title, README
  heading, and all external references, which consistently use "Zombie Apocalypse".

Every player sees this string in their OS window title bar. The mismatch undermines
the project's identity from the first moment of execution.

### 2. README.md — Adventure Girl is undocumented

resources/characters/adventure_girl/png/ contains a full animation sprite set:
  Idle (10 frames), Dead (10 frames), Jump (10 frames), Melee (7 frames),
  Run (8 frames), Shoot (3 frames), Slide (5 frames)

No Godot scene file (.tscn) exists for Adventure Girl, so she is not yet playable.
However, her presence as a resource is visible to every contributor who clones the
repo. The README documents Robot and Male Ninja controls but has no entry for
Adventure Girl at all — contributors cannot tell whether she is planned, in-progress,
or abandoned.

### 3. CHANGELOG.md — stale content / potential name references

CHANGELOG.md currently contains plugin-style changelog boilerplate (entries about
"inspector" and "control node" selection) that appears to be copy-pasted from the
GUT addon or another plugin — it does not describe Zombie Apocalypse milestones.
It should be replaced with accurate project history and must not reference the old
incorrect project name.


## Solution

### Fix 1 — project.godot line 18

Before:
```
config/name="Retro_Apocalyse"
```

After:
```
config/name="Zombie Apocalypse"
```

File: project.godot, line 18. Single-character-plus-word change. No other lines
in this file are affected.

---

### Fix 2 — README.md — add Adventure Girl section and Characters table

Current state (lines 21–41): README documents ROBOT CONTROLS and MALE NINJA
CONTROLS only. Nothing follows except a screenshot and the Running Tests section.

Insert the following block immediately after line 41 (after the Male Ninja section,
before the screenshot on line 42):

```markdown
### ADVENTURE GIRL CONTROLS

> **Status:** Work in progress — sprite assets are present
> (Idle, Dead, Jump, Melee, Run, Shoot, Slide) but no playable scene exists yet.
> Controls below reflect the shared input map and will be confirmed once the
> character scene is implemented.

* MOVEMENTS
  * A, LEFT ARROW        - move left
  * D, RIGHT ARROW       - move right
  * W, SPACE, UP ARROW   - jump
* ATTACKS
  * CTRL   - slide
  * Z      - shoot
  * X      - melee
```

Then insert the following Characters overview table after the CONTROLS section
(between line 41 and the Adventure Girl block above, or as a new ## Characters
section after ## CONTROLS):

```markdown
## Characters

| Character      | Scene file present | Animations available          | Status          |
|----------------|--------------------|-------------------------------|-----------------|
| Robot          | Yes                | Full set                      | Playable        |
| Male Ninja     | Yes                | Full set                      | Playable        |
| Adventure Girl | No                 | Idle, Dead, Jump, Melee, Run, Shoot, Slide | Work in progress |
```

---

### Fix 3 — CHANGELOG.md — replace plugin boilerplate with project history

Current content is a copy-paste from an unrelated plugin (references "inspector",
"control node", "F12", "assetlib"). Replace the entire file with accurate Zombie
Apocalypse project history. At minimum:

Before (lines 1–21):
```
Changelog
============

This is a high-level changelog for each released versions of the plugin.
For a more detailed list of past and incoming changes, see the commit history.


0.2
----

- Selecting nodes also opens them in the regular inspector (errors expected, this is a hack)
- Pressing F12 attempts to select the control node below the mouse


0.1
----

- Plugin available on the assetlib
- Browse editor scene tree
- Highlight control nodes when selected in the tree
```

After:
```
# Changelog — Zombie Apocalypse

All notable changes to **Zombie Apocalypse** are documented here.
For the full commit history see the repository log.

## Unreleased

- Corrected project name in project.godot (was "Retro_Apocalyse", now "Zombie Apocalypse")
- Documented Adventure Girl character (WIP) in README
- Added Characters overview table to README

## 0.2

- Migrated project from Godot 3 to Godot 4
- Updated node types: CharacterBody2D, AnimatedSprite2D, Sprite2D
- Modernised GDScript syntax (@export, @onready, Callable)
- Updated signal connections and scene instantiation
- DisplayServer API for fullscreen handling
- Updated Tween API

## 0.1

- Initial project: Robot and Male Ninja playable characters
- Basic zombie enemy AI
- 2D side-scrolling world scene
```
