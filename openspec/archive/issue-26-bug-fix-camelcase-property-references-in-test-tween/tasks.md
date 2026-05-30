# Tasks: Fix camelCase Property References in test_tween_script.gd

## Property Renames

- [ ] Replace all `moveDirectionX` references with `move_direction_x` (file: `tests/test_tween_script.gd`, lines 12, 14, 17, 19, 22, 24, 44, 66, 73)
- [ ] Replace all `moveDirectionY` references with `move_direction_y` (file: `tests/test_tween_script.gd`, lines 28, 30, 33, 35, 38, 40, 45, 67, 73)
- [ ] Replace `canTween` with `can_tween` (file: `tests/test_tween_script.gd`, line 43)
- [ ] Replace all `tweenRunning` references with `tween_running` (file: `tests/test_tween_script.gd`, lines 53, 55, 60, 71)
- [ ] Replace all `movementPosition` references with `movement_position` (file: `tests/test_tween_script.gd`, lines 49, 73)
- [ ] Replace all `moveDistanceX` references with `move_distance_x` (file: `tests/test_tween_script.gd`, lines 46, 68)
- [ ] Replace all `moveDistanceY` references with `move_distance_y` (file: `tests/test_tween_script.gd`, lines 47, 69)

## Dead Test Removal

- [ ] Remove `test_on_tween_completed_clears_active_tween` entirely — asserts on `_active_tween` which does not exist in `generic_tween_script.gd` (file: `tests/test_tween_script.gd`, lines 58–63)

## Call Signature Fix

- [ ] Update all `_tween._on_tween_completed()` call sites to pass the required two arguments: `_tween._on_tween_completed(null, "")` (file: `tests/test_tween_script.gd`, lines 54, 61, 72)

## Verification

- [ ] Confirm no camelCase property references remain in `tests/test_tween_script.gd`
- [ ] Confirm `_active_tween` no longer appears anywhere in `tests/test_tween_script.gd`
- [ ] Run GUT test suite headlessly and confirm tests produce genuine pass/fail results (not vacuous passes)
- [ ] Confirm `test_change_x_direction_toggles_positive_to_negative` and `test_change_x_direction_toggles_negative_to_positive` now exercise the real `move_direction_x` field
- [ ] Confirm `test_on_tween_completed_resets_running_flag` exercises the real `tween_running` field
- [ ] Confirm `test_set_initial_movement_computes_correct_target_x` exercises the real `movement_position` field
