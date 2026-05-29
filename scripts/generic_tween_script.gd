extends Node2D

# Constants
@export var move_direction_x = 0 # -1 = left, 1 = right
@export var move_direction_y = 0 # -1 = up, 1 = down
@export var can_tween = false
@export var move_distance_x = 0
@export var move_distance_y = 0
@export var tween_duration = 4 # duration of tween moving from position

var tween_node # set this node inside the _ready function of child node extending this script
var tween_running = false
var movement_position
var trans_type = Tween.TRANS_LINEAR
var ease_type = Tween.EASE_IN_OUT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _start_tween_process():
	if (tween_node and !tween_running && can_tween):
		tween_running = true

		# check if the signal is connected
		if (!tween_node.is_connected("finished", Callable(self, "_on_tween_completed"))):
			# connect the signal, once tween is completed it will call the _on_tween_completed method
			tween_node.connect("finished", Callable(self, "_on_tween_completed"))

		# tween properties
		var tween = tween_node.tween_property(self, "position", movement_position, tween_duration)
		tween.set_trans(trans_type)
		tween.set_ease(ease_type)


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


func _on_tween_completed(object, key):
	_change_x_direction()
	_change_y_direction()

	movement_position = self.position + Vector2(
		move_distance_x * move_direction_x,
		move_distance_y * move_direction_y)
	tween_running = false
