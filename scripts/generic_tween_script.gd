extends Node2D

# Constants
@export var move_direction_x = 0 # -1 = left, 1 = right
@export var move_direction_y = 0 # -1 = up, 1 = down
@export var can_tween = false
@export var move_distance_x = 0
@export var move_distance_y = 0
@export var tween_duration = 4 # duration of tween moving from position

var tween_running = false
var movement_position
var trans_type = Tween.TRANS_LINEAR
var ease_type = Tween.EASE_IN_OUT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _start_tween_process():
	if (!tween_running && can_tween):
		tween_running = true

		# Create a new Tween via the Node API (Godot 4 — Tween is not a scene node)
		var tween = create_tween()
		tween.finished.connect(_on_tween_completed)

		# tween properties
		var tweener = tween.tween_property(self, "position", movement_position, tween_duration)
		tweener.set_trans(trans_type)
		tweener.set_ease(ease_type)


func _set_initial_movement(init_position):
	if (can_tween):
		movement_position = init_position + Vector2(
			move_distance_x * move_direction_x,
			move_distance_y * move_direction_y)


func _change_x_direction():
	# change x direction
	if (move_direction_x == 1):
		move_direction_x = -1
	elif (move_direction_x == -1):
		move_direction_x = 1


func _change_y_direction():
	# change y direction
	if (move_direction_y == 1):
		move_direction_y = -1
	elif (move_direction_y == -1):
		move_direction_y = 1


func _on_tween_completed():
	_change_x_direction()
	_change_y_direction()

	movement_position = self.position + Vector2(
		move_distance_x * move_direction_x,
		move_distance_y * move_direction_y)
	tween_running = false
