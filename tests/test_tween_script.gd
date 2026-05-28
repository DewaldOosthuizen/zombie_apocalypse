extends GutTest

var _tween

func before_each():
	_tween = load("res://scripts/generic_tween_script.gd").new()

func after_each():
	_tween.free()

func test_change_x_direction_toggles_positive_to_negative():
	_tween.moveDirectionX = 1
	_tween._change_x_direction()
	assert_eq(_tween.moveDirectionX, -1)

func test_change_x_direction_toggles_negative_to_positive():
	_tween.moveDirectionX = -1
	_tween._change_x_direction()
	assert_eq(_tween.moveDirectionX, 1)

func test_change_x_direction_noop_when_zero():
	_tween.moveDirectionX = 0
	_tween._change_x_direction()
	assert_eq(_tween.moveDirectionX, 0,
		"Zero direction should not toggle — no movement axis configured")

func test_change_y_direction_toggles_positive_to_negative():
	_tween.moveDirectionY = 1
	_tween._change_y_direction()
	assert_eq(_tween.moveDirectionY, -1)

func test_change_y_direction_toggles_negative_to_positive():
	_tween.moveDirectionY = -1
	_tween._change_y_direction()
	assert_eq(_tween.moveDirectionY, 1)

func test_change_y_direction_noop_when_zero():
	_tween.moveDirectionY = 0
	_tween._change_y_direction()
	assert_eq(_tween.moveDirectionY, 0)

func test_set_initial_movement_computes_correct_target_x():
	_tween.canTween = true
	_tween.moveDirectionX = 1
	_tween.moveDirectionY = 0
	_tween.moveDistanceX = 100
	_tween.moveDistanceY = 0
	_tween._set_initial_movement(Vector2(50, 50))
	assert_eq(_tween.movementPosition, Vector2(150, 50),
		"target X must be origin.x + distance * direction")
