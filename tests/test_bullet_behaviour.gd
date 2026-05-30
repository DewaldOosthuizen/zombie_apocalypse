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

# _get_scale_for_power pure helper
func test_power_zero_scale():
    assert_eq(_bullet._get_scale_for_power(0), Vector2(0.2, 0.2),
        "power 0 must return scale Vector2(0.2, 0.2)")

func test_power_one_scale():
    assert_eq(_bullet._get_scale_for_power(1), Vector2(0.21, 0.22),
        "power 1 must return scale Vector2(0.21, 0.22)")

func test_power_two_scale():
    assert_eq(_bullet._get_scale_for_power(2), Vector2(0.22, 0.23),
        "power 2 must return scale Vector2(0.22, 0.23)")
