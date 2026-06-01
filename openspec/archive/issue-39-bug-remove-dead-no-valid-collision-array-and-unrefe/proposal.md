# Proposal: Issue #39 — Remove dead `no_valid_collision` and wire `BULLET_SCALE_POWER_*` into `_get_scale_for_power()`

## Overview

`scripts/generic_bullet_behaviour.gd` declares three constants (`BULLET_SCALE_POWER_0`,
`BULLET_SCALE_POWER_1`, `BULLET_SCALE_POWER_2`) whose values are duplicated as magic
literals inside `_get_scale_for_power()`, making the constants ghost symbols that have
no effect. It also retains a `no_valid_collision` array (line 20) that was superseded by
`_non_brick_hit_count` and is never read or written. Both artefacts inflate cognitive
overhead and risk misleading future contributors. The fix is to delete `no_valid_collision`
and wire the three constants into `_get_scale_for_power()` so the named values become
the single source of truth for bullet scale per power level.

## Issues

### Issue 1

**File:** `scripts/generic_bullet_behaviour.gd`

**Problem:** `no_valid_collision` (line 20) is declared but never read or written after
its introduction. Its purpose was superseded by `_non_brick_hit_count` (line 25), which
is the variable actually incremented in `_remove_if_brick()` and checked in
`_animate_bullet()`. The orphan array adds noise and confusion.

**Fix:** Delete line 20 (`var no_valid_collision = []`) entirely.

Before:
```gdscript
var no_valid_collision = []
var delta_time: float = 0.0
```

After:
```gdscript
var delta_time: float = 0.0
```

### Issue 2

**File:** `scripts/generic_bullet_behaviour.gd`

**Problem:** `BULLET_SCALE_POWER_0/1/2` (lines 6-8) are defined but never referenced.
`_get_scale_for_power()` (lines 53-59) returns identical Vector2 literals inline,
creating duplicate magic numbers. Any developer who edits the constants will see no
behavioural change, which is a silent correctness trap.

**Fix:** Replace the inline Vector2 literals inside `_get_scale_for_power()` with the
existing constants so they become the authoritative values.

Before:
```gdscript
func _get_scale_for_power(p: int) -> Vector2:
    if p == 0:
        return Vector2(0.2, 0.2)
    elif p == 1:
        return Vector2(0.21, 0.22)
    else:
        return Vector2(0.22, 0.23)
```

After:
```gdscript
func _get_scale_for_power(p: int) -> Vector2:
    if p == 0:
        return BULLET_SCALE_POWER_0
    elif p == 1:
        return BULLET_SCALE_POWER_1
    else:
        return BULLET_SCALE_POWER_2
```
