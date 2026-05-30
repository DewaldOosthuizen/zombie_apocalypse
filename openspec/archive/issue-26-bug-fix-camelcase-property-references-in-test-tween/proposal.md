# Fix camelCase Property References in test_tween_script.gd

## Overview

`tests/test_tween_script.gd` references properties using camelCase identifiers
(`moveDirectionX`, `canTween`, `tweenRunning`, `movementPosition`, `moveDistanceX`,
`moveDistanceY`) while the actual source `scripts/generic_tween_script.gd` declares
all variables in snake_case. GDScript silently creates dynamic properties on assignment,
so every test sets a phantom field, reads it back unchanged, and asserts success against
data the real code never touches. All nine tests pass vacuously and cover nothing. Any
regression in `generic_tween_script.gd` is completely invisible to the test suite.

## Issues

### Issue 1 — `moveDirectionX` used instead of `move_direction_x`

**File:** `tests/test_tween_script.gd` (lines 12, 14, 17, 19, 22, 24, 44, 66, 73)
**Problem:** camelCase reference creates a new dynamic property; the real `move_direction_x`
declared on line 4 of `generic_tween_script.gd` is never read or mutated.
**Fix:**
```gdscript
# Before
_tween.moveDirectionX = 1
_tween._change_x_direction()
assert_eq(_tween.moveDirectionX, -1)

# After
_tween.move_direction_x = 1
_tween._change_x_direction()
assert_eq(_tween.move_direction_x, -1)
```

### Issue 2 — `moveDirectionY` used instead of `move_direction_y`

**File:** `tests/test_tween_script.gd` (lines 28, 30, 33, 35, 38, 40, 45, 67, 73)
**Problem:** Same dynamic-property pitfall as Issue 1, affecting the Y-axis direction tests.
**Fix:**
```gdscript
# Before
_tween.moveDirectionY = 1
_tween._change_y_direction()
assert_eq(_tween.moveDirectionY, -1)

# After
_tween.move_direction_y = 1
_tween._change_y_direction()
assert_eq(_tween.move_direction_y, -1)
```

### Issue 3 — `canTween` used instead of `can_tween`

**File:** `tests/test_tween_script.gd` (line 43)
**Problem:** `can_tween` guards the `_set_initial_movement` logic (line 35 of source).
Setting `_tween.canTween = true` never enables the guard; the assertion in
`test_set_initial_movement_computes_correct_target_x` therefore tests nothing real.
**Fix:**
```gdscript
# Before
_tween.canTween = true

# After
_tween.can_tween = true
```

### Issue 4 — `tweenRunning` used instead of `tween_running`

**File:** `tests/test_tween_script.gd` (lines 53, 55, 60, 71)
**Problem:** `tween_running` is set to `false` by `_on_tween_completed` (line 64 of source).
Using `tweenRunning` means the pre-condition write and the post-condition read are both
against a shadow field, not the real flag.
**Fix:**
```gdscript
# Before
_tween.tweenRunning = true
_tween._on_tween_completed()
assert_false(_tween.tweenRunning, "tweenRunning must be cleared after tween completes")

# After
_tween.tween_running = true
_tween._on_tween_completed()
assert_false(_tween.tween_running, "tween_running must be cleared after tween completes")
```

### Issue 5 — `movementPosition` used instead of `movement_position`

**File:** `tests/test_tween_script.gd` (lines 49, 73)
**Problem:** `movement_position` is the variable updated by `_set_initial_movement` and
`_on_tween_completed`. Asserting on `movementPosition` reads a phantom field that is
always null/zero.
**Fix:**
```gdscript
# Before
assert_eq(_tween.movementPosition, Vector2(150, 50), "target X must be origin.x + distance * direction")

# After
assert_eq(_tween.movement_position, Vector2(150, 50), "target X must be origin.x + distance * direction")
```

### Issue 6 — `moveDistanceX` / `moveDistanceY` used instead of `move_distance_x` / `move_distance_y`

**File:** `tests/test_tween_script.gd` (lines 46, 47, 68, 69)
**Problem:** Same phantom-field pattern. The source uses `move_distance_x` and
`move_distance_y` (lines 7–8 of source) in the `_set_initial_movement` and
`_on_tween_completed` calculations.
**Fix:**
```gdscript
# Before
_tween.moveDistanceX = 100
_tween.moveDistanceY = 0

# After
_tween.move_distance_x = 100
_tween.move_distance_y = 0
```

### Issue 7 — `test_on_tween_completed_clears_active_tween` asserts on non-existent `_active_tween`

**File:** `tests/test_tween_script.gd` (lines 58–63)
**Problem:** `_active_tween` does not exist in `generic_tween_script.gd`. The test
sets a phantom field to null, calls `_on_tween_completed`, and asserts it is still null —
vacuously true and unrelated to any real behaviour. The `_on_tween_completed` signature in
the source also requires two parameters (`_object`, `_key`) that are not passed.
**Fix:**
Remove `test_on_tween_completed_clears_active_tween` entirely. The meaningful
post-conditions of `_on_tween_completed` are already covered by Issues 4 and 5 after
those fixes are applied.

### Issue 8 — `_on_tween_completed` called with zero arguments in tests

**File:** `tests/test_tween_script.gd` (lines 54, 61, 72)
**Problem:** The source declares `func _on_tween_completed(_object, _key)` (line 57 of
source). All three test call sites invoke `_tween._on_tween_completed()` with no
arguments, which will raise a runtime argument-count error in Godot 4.
**Fix:**
```gdscript
# Before
_tween._on_tween_completed()

# After
_tween._on_tween_completed(null, "")
```
