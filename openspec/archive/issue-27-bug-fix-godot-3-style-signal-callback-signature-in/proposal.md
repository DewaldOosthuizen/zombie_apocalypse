# Fix Godot 3-Style Signal Callback Signature in generic_tween_script

## Overview

`scripts/generic_tween_script.gd` carries a two-parameter `_on_tween_completed(_object, _key)`
signature that was valid under the Godot 3 Tween API. In Godot 4 the `Tween.finished` signal
emits no arguments. When the tween completes, Godot 4 calls the connected callable with zero
arguments; the declared two-parameter signature does not match and raises a runtime error. This
silently freezes all moving platforms in every level on first tween completion. The fix is a
one-line signature change — removing the two unused parameters.

## Issues

### Issue 1 — Godot 3-style two-parameter callback signature on `_on_tween_completed`

**File:** `scripts/generic_tween_script.gd` (line 57)

**Problem:**
`_on_tween_completed` declares `(_object, _key)`, mirroring the Godot 3
`Tween.tween_completed(object, key)` signal. In Godot 4, `Tween.finished` emits no arguments.
Godot 4's callable system enforces arity strictly: calling a Callable that declares N parameters
with 0 arguments raises an error at runtime. Because the connection is established inside an
`is_connected` guard (line 24–26), it is created exactly once; the error fires on first tween
completion, leaving `tween_running = true` permanently and breaking all tween-driven platform
movement for the remainder of the session.

**Fix:**

```gdscript
# Before (Godot 3 style — line 57)
func _on_tween_completed(_object, _key):
	_change_x_direction()
	_change_y_direction()

	movement_position = self.position + Vector2(
		move_distance_x * move_direction_x,
		move_distance_y * move_direction_y)
	tween_running = false

# After (Godot 4 style — Tween.finished emits no args)
func _on_tween_completed():
	_change_x_direction()
	_change_y_direction()

	movement_position = self.position + Vector2(
		move_distance_x * move_direction_x,
		move_distance_y * move_direction_y)
	tween_running = false
```

The `connect` call at line 26 already uses the correct Godot 4 form
(`Callable(self, "_on_tween_completed")`); the `is_connected` guard at line 24 must be
preserved to prevent duplicate connections on repeated `_start_tween_process` calls.
No other files require changes for this fix.
