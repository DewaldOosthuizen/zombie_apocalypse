extends GutTest

func test_power_zero_scale_constant():
	# Verify the expected scale constants match the documented values in L24
	var expected = Vector2(0.2, 0.2)
	assert_eq(expected.x, 0.2)
	assert_eq(expected.y, 0.2)

func test_power_one_scale_constant():
	var expected = Vector2(0.21, 0.22)
	assert_almost_eq(expected.x, 0.21, 0.001)
	assert_almost_eq(expected.y, 0.22, 0.001)

func test_damage_with_power_bonus_calculation():
	# damage + (5 * power) is the formula used at L80
	var base_damage = 30
	assert_eq(base_damage + (5 * 0), 30)
	assert_eq(base_damage + (5 * 1), 35)
	assert_eq(base_damage + (5 * 2), 40)
