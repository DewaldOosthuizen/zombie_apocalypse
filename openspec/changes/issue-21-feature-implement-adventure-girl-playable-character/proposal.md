# FEATURE: Implement Adventure Girl Playable Character Scene

## Overview

Adventure Girl has a complete sprite asset set under
`resources/characters/adventure_girl/png/` (Dead, Idle, Jump, Melee, Run, Shoot,
Slide — seven groups) but no scene file and no character script exist. The README
marks her status as "Work in progress". This changeset completes the character
implementation by creating `scenes/characters/adventure_girl/Character_Scene.tscn`
and `scripts/adventure_girl.gd`, wiring her seven animation states into the
`generic_character_behaviour.gd` base class, and updating the README.

The key constraint that distinguishes this from a naive template copy is the
animation-state mismatch. The robot scene embeds ten named SpriteFrames entries
including `jump_melee`, `jump_shoot`, `run_shoot`, and `walk`. Adventure Girl has
NO assets for those four states and they must never appear in her scene file.
The ninja scene is a closer structural match (it shares jump_melee, jump_shoot,
slide, melee, idle, dead, jump) but also references `jump_glide` and `walk` which
Adventure Girl does not have. This spec therefore mandates a clean build from the
ninja template with an explicit list of entries to remove and a confirmed mapping
table for every SpriteFrames animation name.

---

## Issue 1 — No Adventure Girl scene file

**File:** `scenes/characters/adventure_girl/Character_Scene.tscn` (does not exist)

**Problem:**
No scene file exists for Adventure Girl. The level cannot instantiate or offer her
as a playable character.

**Fix:**

Create `scenes/characters/adventure_girl/Character_Scene.tscn` using the ninja
scene `scenes/characters/ninja/Character_Scene.tscn` as the structural template.

Start from the ninja template and apply the following changes:

1. Replace all occurrences of `female_ninja_` and `male_ninja_` in animation
   names with `female_adventure_girl_` and `male_adventure_girl_` respectively.

2. REMOVE these four ninja SpriteFrames entries entirely — Adventure Girl has
   no assets for them and they must not be present in the final scene:
   - `female_ninja_jump_glide` (no Jump_Glide assets exist)
   - `male_ninja_jump_glide`   (no Jump_Glide assets exist)
   - `female_ninja_walk`       (use Run assets instead; see mapping table below)
   - `male_ninja_walk`         (use Run assets instead; see mapping table below)

3. ADD two entries that the ninja scene does not have:
   - `female_adventure_girl_run`  (backed by `Run (N).png` assets)
   - `male_adventure_girl_run`    (backed by `Run (N).png` assets — same assets,
     Adventure Girl's sprite sheet is gender-neutral in art; both gender variants
     reference the same Run frames)

4. Update the AnimatedSprite `script/source_code` reference to point to
   `res://scripts/adventure_girl.gd` instead of the inline ninja script.

Complete SpriteFrames animation mapping table (sprite folder name ->
SpriteFrames entry name -> asset path pattern):

| Sprite folder | SpriteFrames name (female)           | SpriteFrames name (male)            | Asset path                                           |
|---------------|--------------------------------------|-------------------------------------|------------------------------------------------------|
| Dead          | female_adventure_girl_dead           | male_adventure_girl_dead            | res://resources/characters/adventure_girl/png/Dead (N).png |
| Idle          | female_adventure_girl_idle           | male_adventure_girl_idle            | res://resources/characters/adventure_girl/png/Idle (N).png |
| Jump          | female_adventure_girl_jump           | male_adventure_girl_jump            | res://resources/characters/adventure_girl/png/Jump (N).png |
| Melee         | female_adventure_girl_melee          | male_adventure_girl_melee           | res://resources/characters/adventure_girl/png/Melee (N).png |
| Run           | female_adventure_girl_run            | male_adventure_girl_run             | res://resources/characters/adventure_girl/png/Run (N).png  |
| Shoot         | female_adventure_girl_shoot          | male_adventure_girl_shoot           | res://resources/characters/adventure_girl/png/Shoot (N).png|
| Slide         | female_adventure_girl_slide          | male_adventure_girl_slide           | res://resources/characters/adventure_girl/png/Slide (N).png|

Final SpriteFrames entries count: 14 (7 animation states x 2 gender prefixes).
The following robot-only and ninja-only states must NOT appear in the Adventure
Girl scene:
- jump_melee   (robot + ninja have it; no Adventure Girl assets)
- jump_shoot   (robot + ninja have it; no Adventure Girl assets)
- run_shoot    (robot only; no Adventure Girl assets)
- walk         (robot + ninja use walk; Adventure Girl uses run instead)
- jump_glide   (ninja only; no Adventure Girl assets)

Before (robot template excerpt — states that must NOT be copied):
```
"name": "male_robot_jump_melee",
"name": "male_robot_jump_shoot",
"name": "male_robot_run_shoot",
"name": "male_robot_walk",
```

After (Adventure Girl scene — the equivalent block):
```
"name": "male_adventure_girl_run",
"name": "female_adventure_girl_run",
```

---

## Issue 2 — No Adventure Girl script

**File:** `scripts/adventure_girl.gd` (does not exist)

**Problem:**
No GDScript subclass exists for Adventure Girl. The `generic_character_behaviour.gd`
base class uses `type` and `gender` to compose animation names at line 356:

```gdscript
# generic_character_behaviour.gd line 356
player_sprite.animation = gender + "_" + type + "_" + animation_text
```

Without a subclass setting `type = "adventure_girl"` and `gender = "female"` the
animation lookup will produce wrong names at runtime.

**Fix:**

Create `scripts/adventure_girl.gd`:

```gdscript
# Before: no file exists

# After: scripts/adventure_girl.gd
extends "res://scripts/generic_character_behaviour.gd"

func _ready():
    type = "adventure_girl"
    gender = "female"
    ._ready()

func control_character(delta):
    # Reset default behaviour
    ._reset_character_sprite_states(delta)

    # Shoot (action_1)
    if Input.is_action_just_pressed("action_1") and !action1 and !action2 and !action3 and ammo > 0:
        ._shoot_bullet(0)
        repeatFrames = false
        if currentJumpCount > 0:
            ._change_sprite_animation("jump")   # no jump_shoot asset; fall back to jump
        else:
            ._change_sprite_animation("shoot")
        ._emit_refresh_hud()

    # Melee (action_2)
    elif Input.is_action_just_pressed("action_2") and !action1 and !action2 and !action3:
        action2 = true
        repeatFrames = false
        ._melee_attack_collision()
        if currentJumpCount > 0:
            ._change_sprite_animation("jump")   # no jump_melee asset; fall back to jump
        else:
            ._change_sprite_animation("melee")

    # Slide (action_3)
    elif Input.is_action_just_pressed("action_3") and movementDirection != 0 and !action3:
        action3 = true
        repeatFrames = false
        ._change_sprite_animation("slide")
        ._slide_attack_collision()

    # Jump
    elif Input.is_action_just_pressed("move_jump") and currentJumpCount < max_jump_count and !action3:
        currentJumpCount += 1
        playerSprite.frame = 0
        repeatFrames = false
        action1 = false
        action2 = false
        action3 = false
        ._change_sprite_animation("jump")
        player_speed_y = -JUMPFORCE

    elif Input.is_action_pressed("move_left"):
        ._move_left()
    elif Input.is_action_pressed("move_right"):
        ._move_right()
    elif Input.is_action_pressed("respawn"):
        ._emit_reposition()
    else:
        movementDirection = 0
        if health <= 0:
            ._change_sprite_animation("dead")
            repeatFrames = false
        elif currentJumpCount == 0 and !action1 and !action2 and !action3:
            ._change_sprite_animation("idle")
            repeatFrames = true
```

Key decisions:
- No `jump_glide` double-jump mechanic (no asset); single jump only.
- `jump_shoot` and `jump_melee` fall back to `jump` animation — prevents requesting
  an animation name that has no SpriteFrames entry and would cause a runtime error.
- `run` is the walk equivalent: `generic_character_behaviour.gd` calls
  `_change_sprite_animation("walk")` at lines 310 and 318. This is handled by
  overriding `control_character` fully in the subclass and using `run` instead of
  `walk`. Alternatively, override `_change_sprite_animation` to remap `walk` -> `run`
  if minimal diff from the ninja template is preferred (either approach is acceptable;
  the full override is chosen here for clarity and to avoid ninja-specific state leakage).

---

## Issue 3 — generic_character_behaviour.gd calls "walk" not "run"

**File:** `scripts/generic_character_behaviour.gd` (lines 310, 318)

**Problem:**
The base class issues `_change_sprite_animation("walk")` for horizontal movement.
Adventure Girl has no `walk` animation; she has `run`. If Adventure Girl delegates
to the base class movement handling without override, the composed name
`female_adventure_girl_walk` will not resolve to any SpriteFrames entry.

**Fix (Option A — preferred: full override in subclass):**
The `adventure_girl.gd` script overrides `control_character` entirely, emitting
`run` instead of `walk` for the idle-movement states (see Issue 2 script above).
No change to `generic_character_behaviour.gd` is required.

**Fix (Option B — minimal: remap in _change_sprite_animation override):**

```gdscript
# In scripts/adventure_girl.gd — add after _ready():
func _change_sprite_animation(animation_text):
    var mapped = animation_text
    if animation_text == "walk":
        mapped = "run"
    ._change_sprite_animation(mapped)
```

Option A is specified in Issue 2 above. Option B is provided as a fallback if the
implementer prefers a thinner subclass.

---

## Issue 4 — Adventure Girl not selectable from level character selection

**File:** `scenes/World_Scene.tscn` and/or `scripts/generic_level_script.gd`

**Problem:**
The level's character-selection mechanism (exact node/signal TBD from scene
inspection) does not list Adventure Girl. Even with the scene created she will not
be reachable by the player.

**Fix:**
Inspect `scenes/World_Scene.tscn` and `scripts/generic_level_script.gd` to
identify how Robot and Ninja are registered. Add Adventure Girl using the same
mechanism. The exact line numbers depend on how the world scene stores the
character roster (array of scene paths, dictionary keyed by character name, etc.)
and must be confirmed during implementation.

---

## Issue 5 — README characters table not updated

**File:** `README.md`

**Problem:**
The characters table lists Adventure Girl as "Work in progress". After implementation
it must be updated to "Playable".

**Fix:**

Before:
```
| Adventure Girl | Work in progress |
```

After:
```
| Adventure Girl | Playable |
```

Also fill in the Adventure Girl controls block if it contains placeholder text.
