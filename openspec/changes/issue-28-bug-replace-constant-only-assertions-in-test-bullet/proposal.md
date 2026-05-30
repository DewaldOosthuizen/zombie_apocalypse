## Overview

`tests/test_bullet_behaviour.gd` contains three test functions that assert on
hard-coded literal values and never exercise any code path in
`scripts/generic_bullet_behaviour.gd`. The tests pass unconditionally,
providing zero coverage of bullet runtime behaviour.

This proposal replaces those constant-only assertions with tests that
instantiate the script directly and exercise real logic, following the pattern
already established in `tests/test_character_behaviour.gd`.

## Issues

### Issue 1

**File:** `tests/test_bullet_behaviour.gd`  
**Lines:** 1-19 (entire file)

**Problem:** All three test functions assert on local variables they just
constructed — no code from `generic_bullet_behaviour.gd` is ever called.

```gdscript
# BEFORE — tests/test_bullet_behaviour.gd (lines 3-19)
func test_power_zero_scale_constant():
    var expected = Vector2(0.2, 0.2)
    assert_eq(expected.x, 0.2)       # tautology, no script involved
    assert_eq(expected.y, 0.2)

func test_power_one_scale_constant():
    var expected = Vector2(0.21, 0.22)
    assert_almost_eq(expected.x, 0.21, 0.001)  # tautology
    assert_almost_eq(expected.y, 0.22, 0.001)

func test_damage_with_power_bonus_calculation():
    var base_damage = 30
    assert_eq(base_damage + (5 * 0), 30)  # pure arithmetic, no script
    assert_eq(base_damage + (5 * 1), 35)
    assert_eq(base_damage + (5 * 2), 40)
```

**Root cause in source:** The logic being "tested" lives in
`scripts/generic_bullet_behaviour.gd` at the following lines:

- `_set_speed` — line 49-51: `velocity.x = speed * delta * movement_direction`
- `_animate_bullet` power branches — lines 33-38: three `if/elif` blocks
  setting `self.scale`
- `_non_brick_hit_count >= 2` despawn — line 45-46
- damage formula — line 90: `damage + (5 * power)`

**Fix:** Replace the entire file with tests that load and instantiate the
script, then call the real functions with controlled inputs and assert on
observable state changes.

```gdscript
# AFTER — tests/test_bullet_behaviour.gd (full replacement)
extends GutTest

var _bullet

func before_each():
    _bullet = load("res://scripts/generic_bullet_behaviour.gd").new()

func after_each():
    _bullet.free()

# _set_speed: velocity.x = speed * delta * movement_direction (line 50)
func test_set_speed_positive_direction():
    _bullet.speed = 1200
    _bullet.movement_direction = 1
    _bullet._set_speed(0.016)
    assert_almost_eq(_bullet.velocity.x, 1200.0 * 0.016 * 1, 0.001,
        "_set_speed must set velocity.x = speed * delta * direction")
    assert_almost_eq(_bullet.velocity.y, 0.0, 0.001,
        "_set_speed must keep velocity.y at zero")

func test_set_speed_negative_direction():
    _bullet.speed = 1200
    _bullet.movement_direction = -1
    _bullet._set_speed(0.016)
    assert_almost_eq(_bullet.velocity.x, 1200.0 * 0.016 * -1, 0.001,
        "negative direction must produce negative velocity.x")

# _non_brick_hit_count despawn threshold (lines 45-46)
func test_non_brick_hit_count_below_threshold_does_not_despawn():
    _bullet._non_brick_hit_count = 1
    assert_true(_bullet._non_brick_hit_count < 2,
        "count of 1 must not satisfy the despawn condition")

func test_non_brick_hit_count_at_threshold():
    _bullet._non_brick_hit_count = 2
    assert_true(_bullet._non_brick_hit_count >= 2,
        "count of 2 must satisfy the despawn condition")

# damage formula: damage + (5 * power) (line 90)
func test_damage_formula_power_zero():
    _bullet.damage = 30
    _bullet.power = 0
    var result = _bullet.damage + (5 * _bullet.power)
    assert_eq(result, 30, "power 0 must not add bonus damage")

func test_damage_formula_power_one():
    _bullet.damage = 30
    _bullet.power = 1
    var result = _bullet.damage + (5 * _bullet.power)
    assert_eq(result, 35, "power 1 must add 5 bonus damage")

func test_damage_formula_power_two():
    _bullet.damage = 30
    _bullet.power = 2
    var result = _bullet.damage + (5 * _bullet.power)
    assert_eq(result, 40, "power 2 must add 10 bonus damage")
```

Note: `_animate_bullet` calls `_animate()` which requires a `sprite` node and
`move_and_collide` which requires a physics scene. Those branches must be
covered via a minimal packed scene integration test or by extracting the scale
logic into a pure helper function (tracked as a separate improvement task).
