extends Node2D

# Declare member variables here. Examples:
signal level_exited()
signal level_entered()

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("level_entered")

func _exit_tree():
	emit_signal("level_exited")
