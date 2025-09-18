extends Node2D

var tweenNode # set this node inside the _ready function of child node extending this script

var tweenRunning = false
@export var moveDirectionX = 0 # -1 = left, 1 = right
@export var moveDirectionY = 0 # -1 = up, 1 = down
@export var canTween = false
@export var moveDistanceX = 0 
@export var moveDistanceY = 0
var movementPosition
@export var tweenDuration = 4 # duration of tween moving from position
var trans_type = Tween.TRANS_LINEAR
var ease_type = Tween.EASE_IN_OUT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _start_tween_process():
	if (tweenNode and !tweenRunning && canTween):
		tweenRunning = true
		
		# check if the signal is connected
		if (!tweenNode.is_connected("finished", Callable(self, "_on_tween_completed"))):
			# connect the signal, once tween is completed it will call the _on_tween_completed method
			tweenNode.connect("finished", Callable(self, "_on_tween_completed"))
		
		# tween properties
		var tween = tweenNode.tween_property(self, "position", movementPosition, tweenDuration)
		tween.set_trans(trans_type)
		tween.set_ease(ease_type)


func _set_initial_movement(initPosition):
	if (canTween):
		movementPosition = initPosition + Vector2(moveDistanceX * moveDirectionX, moveDistanceY * moveDirectionY)


func _change_x_direction():
	# change x direction
	if (moveDirectionX == 1):
		moveDirectionX = -1
	elif (moveDirectionX == -1):
		moveDirectionX = 1


func _change_y_direction():
	# change y direction
	if (moveDirectionY == 1):
		moveDirectionY = -1
	elif (moveDirectionY == -1):
		moveDirectionY = 1


func _on_tween_completed(object, key):
	_change_x_direction()
	_change_y_direction()
	
	movementPosition = self.position + Vector2(moveDistanceX * moveDirectionX, moveDistanceY * moveDirectionY)
	tweenRunning = false