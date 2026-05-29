# Guard Against Null bullet_scene and Zero Ammo in _shoot_bullet

## Overview

`generic_character_behaviour.gd::_shoot_bullet()` contains two defects that
cause either a hard crash or corrupt game state. First, it calls
`bullet_scene.instantiate()` on line 211 without checking whether
`bullet_scene` was ever assigned; the variable is declared on line 68 with no
default value, so any character subclass that omits the assignment crashes at
runtime with a null-dereference. Second, `ammo -= 1` executes on line 215
unconditionally after instantiation, meaning a caller that fires with zero
ammo will push ammo negative and enter an invalid state. Both issues are
silent failures in release builds with no recovery path for the player.

## Issues

### Issue 1 — Null dereference crash when bullet_scene is unassigned

**File:** `scripts/generic_character_behaviour.gd` (line 211)

**Problem:**
`bullet_scene` is declared on line 68 as a bare `var` with no default value
(`null`). `_shoot_bullet()` calls `bullet_scene.instantiate()` immediately
without a null check. Any character subclass that forgets to assign the scene,
or any code path that calls `_shoot_bullet` before scene loading completes,
raises an unhandled null-dereference and halts the game.

**Fix:**
```gdscript
# Before (lines 209-211)
func _shoot_bullet(power):
    action1 = true
    var bullet = bullet_scene.instantiate()

# After
func _shoot_bullet(power):
    if bullet_scene == null:
        push_error("_shoot_bullet called but bullet_scene is not assigned on " + name)
        return
    if ammo <= 0:
        return
    action1 = true
    var bullet = bullet_scene.instantiate()
```

### Issue 2 — ammo decremented before guard, allows negative ammo

**File:** `scripts/generic_character_behaviour.gd` (line 215)

**Problem:**
`ammo -= 1` is placed after `bullet_scene.instantiate()` but there is no
guard that prevents the call when `ammo == 0`. If `_shoot_bullet` is ever
invoked with zero ammo (race condition, AI error, or missing caller-side
check), ammo becomes negative. Downstream logic that tests `ammo > 0` to
decide whether to shoot will behave incorrectly for the rest of the
character's lifetime.

**Fix:**
The `ammo <= 0` guard added in Issue 1 (early return before any mutation)
fully resolves this. `ammo -= 1` remains at its current position (line 215)
and is only reached when both guards pass. No change to the surrounding
directional logic is required.

### Issue 3 — No assertion in subclass _ready() for missing bullet_scene

**File:** All character scenes that call `_shoot_bullet` (Robot, Male Ninja,
future Adventure Girl — their GDScript extends `generic_character_behaviour.gd`)

**Problem:**
There is no _ready()-time assertion to catch a missing `bullet_scene`
assignment at startup. The error surfaces only at the moment of first fire,
which may be deep into a play session and difficult to trace back to
configuration.

**Fix:**
In each character subclass `_ready()` that configures the character as one
capable of shooting, add:
```gdscript
# Example — robot_character.gd (or equivalent subclass)
func _ready():
    # ... existing setup ...
    assert(bullet_scene != null, name + ": bullet_scene must be assigned before entering the scene tree")
```
This converts a hard-to-diagnose runtime crash into an immediate, clearly
labelled assertion failure during development.
