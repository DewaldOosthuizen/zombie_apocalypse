# Proposal: Move _area_checks() from _process to _physics_process

## Overview

`scripts/adventure_girl.gd` currently calls `_area_checks()` inside `_process(_delta)`, which
fires every rendered frame (60–144 Hz at vsync). `_area_checks()` issues two physics server
queries (`get_overlapping_bodies()` / `get_overlapping_areas()`), but Godot 4 only refreshes
overlap data during the physics tick (`_physics_process`, default 60 Hz). This means render-frame
calls between ticks return stale data and waste CPU on redundant array traversal. Worse, when
multiple render frames fall between a single physics tick, `_area_checks()` may apply damage
more than once per tick — a latent double-damage gameplay bug. The fix is to remove the
`_process` override entirely and call `_area_checks()` once per physics tick at the top of
`_physics_process`, before `control_character` and `_start_process`.

## Issues

### Issue 1

**File:** `scripts/adventure_girl.gd`
**Problem:** `_process(_delta)` at lines 22–23 calls `_area_checks()` on every render frame.
Overlap data is only valid after a physics tick, so queries between ticks return stale results
and run redundant array traversal. Multiple render frames within a single physics tick can also
trigger `_area_checks()` more than once, risking double-application of damage.
**Fix:** Delete the entire `_process` override (lines 22–24). Add `_area_checks()` as the first
call inside `_physics_process` (line 26), before `control_character(delta)` and
`_start_process(delta)`. Also remove the `set_process(true)` call in `_ready` (line 19) since
the override will no longer exist.

Before:
```gdscript
func _process(_delta):
    _area_checks()


func _physics_process(delta):
    control_character(delta)
    _start_process(delta)
```

After:
```gdscript
func _physics_process(delta):
    _area_checks()
    control_character(delta)
    _start_process(delta)
```

### Issue 2

**File:** `scripts/adventure_girl.gd`
**Problem:** `_ready()` at line 19 calls `set_process(true)`. Once the `_process` override is
removed this call is redundant and misleading — it enables a callback that no longer exists in
this script.
**Fix:** Remove the `set_process(true)` line from `_ready()`.
