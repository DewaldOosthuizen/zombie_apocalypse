# Tasks: Issue #39

## Dead Code Removal

- [ ] Delete `var no_valid_collision = []` from line 20 of `scripts/generic_bullet_behaviour.gd`

## Constant Wiring

- [ ] Replace `return Vector2(0.2, 0.2)` in `_get_scale_for_power()` with `return BULLET_SCALE_POWER_0`
- [ ] Replace `return Vector2(0.21, 0.22)` in `_get_scale_for_power()` with `return BULLET_SCALE_POWER_1`
- [ ] Replace `return Vector2(0.22, 0.23)` in `_get_scale_for_power()` with `return BULLET_SCALE_POWER_2`

## Verification

- [ ] Confirm no remaining references to `no_valid_collision` anywhere in the repository
- [ ] Confirm no duplicate inline Vector2 scale literals remain in `_get_scale_for_power()`
- [ ] Run `gdlint scripts/generic_bullet_behaviour.gd` and confirm zero new warnings
- [ ] Run full GUT test suite and confirm all existing tests pass
