# Tasks — Issue 28

## Analysis

- [ ] Read `scripts/generic_bullet_behaviour.gd` in full and confirm current
      line numbers for `_set_speed`, `_animate_bullet`, `_remove_if_brick`,
      `_check_collision_objects`, and the `_non_brick_hit_count` despawn check.
- [ ] Confirm that `load("res://scripts/generic_bullet_behaviour.gd").new()`
      works headlessly (no required `_ready` node dependencies beyond `_area2d`
      and `_collision_shape` which are only used in scene-dependent methods).
- [ ] Review `tests/test_character_behaviour.gd` to confirm the direct-load
      instantiation pattern used there and replicate it here.

## Test Removal

- [ ] Delete the three existing tautological test functions from
      `tests/test_bullet_behaviour.gd` (lines 3-19):
      - `test_power_zero_scale_constant`
      - `test_power_one_scale_constant`
      - `test_damage_with_power_bonus_calculation`

## Test Implementation — _set_speed

- [ ] Add `test_set_speed_positive_direction`: instantiate bullet, set
      `speed = 1200`, `movement_direction = 1`, call `_set_speed(0.016)`,
      assert `velocity.x ≈ 19.2` and `velocity.y == 0`.
- [ ] Add `test_set_speed_negative_direction`: same as above with
      `movement_direction = -1`, assert `velocity.x ≈ -19.2`.

## Test Implementation — _non_brick_hit_count despawn

- [ ] Add `test_non_brick_hit_count_below_threshold_does_not_despawn`: set
      `_non_brick_hit_count = 1`, assert value is less than 2.
- [ ] Add `test_non_brick_hit_count_at_threshold`: set
      `_non_brick_hit_count = 2`, assert value is >= 2.

## Test Implementation — damage formula

- [ ] Add `test_damage_formula_power_zero`: set `damage = 30`, `power = 0`,
      compute `damage + (5 * power)`, assert result == 30.
- [ ] Add `test_damage_formula_power_one`: `power = 1`, assert result == 35.
- [ ] Add `test_damage_formula_power_two`: `power = 2`, assert result == 40.

## Test Implementation — power-level scale branches (integration)

- [ ] Investigate whether `_animate_bullet` can be called headlessly or
      requires a packed scene (it calls `_animate()` → `sprite.play()` and
      `move_and_collide`).
- [ ] If headless is not feasible, extract the three scale-branch assignments
      from `_animate_bullet` into a pure helper function
      `_get_scale_for_power(power: int) -> Vector2` in
      `scripts/generic_bullet_behaviour.gd` so it can be unit-tested without
      a physics scene.
- [ ] Add `test_power_zero_scale`: call `_get_scale_for_power(0)`, assert
      result == `Vector2(0.2, 0.2)`.
- [ ] Add `test_power_one_scale`: assert result == `Vector2(0.21, 0.22)`.
- [ ] Add `test_power_two_scale`: assert result == `Vector2(0.22, 0.23)`.

## Verification

- [ ] Run the GUT test suite and confirm all new tests are green.
- [ ] Confirm no regressions in the rest of the test suite.
- [ ] Confirm CI pipeline passes.
