# Tasks: Fix Godot 3-Style Signal Callback Signature in generic_tween_script

## Code Fix

- [ ] Remove `_object` and `_key` parameters from `_on_tween_completed` signature, leaving `func _on_tween_completed():` (file: `scripts/generic_tween_script.gd`, line 57)
- [ ] Verify the `is_connected` guard at line 24 and the `connect` call at line 26 are unchanged and remain correct for Godot 4

## Testing

- [ ] Run GUT test `test_on_tween_completed_resets_running_flag` and confirm it passes with the corrected signature
- [ ] Manually verify at least one moving-platform scene: platform completes tween, reverses direction, and produces no runtime errors in the Godot 4 output console

## Verification

- [ ] Confirm no other scripts in the project override or extend `_on_tween_completed` with the old two-parameter signature
- [ ] Confirm `tween_running` resets to `false` after tween completion (no permanent freeze)
