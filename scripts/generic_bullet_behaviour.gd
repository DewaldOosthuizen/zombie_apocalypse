extends CharacterBody2D

# variables
var sprite

var movement_direction = 1
var speed = 1200
var power = 0
var damage = 30

var velocity = Vector2(0, 0)
var _area2d: Area2D          # cached in _ready() to avoid per-frame scene tree traversal
var _collision_shape: CollisionShape2D  # cached in _ready() to avoid per-frame scene tree traversal
var _non_brick_hit_count: int = 0  # replaces noValidCollision array; counts non-brick surface hits
var delta_time = 0

const bricks_particle_scene = preload("res://scenes/environment/Brick_1_Particle_Scene.tscn")
const blood_scene = preload("res://scenes/Blood_Particle_Scene.tscn")

func _ready():
	_area2d = get_node("Area2D")
	_collision_shape = get_node("CollisionShape2D")

func _animate_bullet(delta):
	delta_time += delta
	_set_speed(delta)
	_animate()
	
	if (power == 0):
		self.scale = Vector2(0.2, 0.2)
	elif (power == 1):
		self.scale = Vector2(0.21, 0.22)
	elif (power == 2):
		self.scale = Vector2(0.22, 0.23)
		
	var collider1 = move_and_collide(Vector2(velocity.x, velocity.y))
	_check_collision_objects()
	_remove_if_brick(collider1)
	
	# Ensures bullet disappears upon hitting invalid objects
	if (_non_brick_hit_count >= 2):
		self.queue_free()


func _set_speed(delta):
	velocity.x = speed * delta * movement_direction
	velocity.y = 0


func _create_muzzle(muzzle_scene):
	var muzzle = muzzle_scene.instantiate()
	
	if (movement_direction == 1):
		muzzle.position = self.position - Vector2(-20, 1)
	else:
		muzzle.position = self.position - Vector2(20, 1)
	
	get_tree().root.add_child(muzzle)


func _animate():
	sprite.play()


func _remove_if_brick(object):
	if (object and object.collider):
		var object_parent = object.collider.get_parent()
		if (object_parent.is_in_group("brick")):
			object_parent.break_object()
			if (power < 1):
				self.queue_free()
		elif (object_parent.is_in_group("power_up_brick")):
			object_parent.break_object()
			if (power < 1):
				self.queue_free()
		else:
			_non_brick_hit_count += 1


func _check_collision_objects():
	var area = _area2d.get_overlapping_bodies()
	if (area.size() != 0):
		for body in area:
			if (body.is_in_group("enemy_character")):
				_collision_shape.disabled = true
				body._take_damage(damage + (5 * power)) #take damage and increase damage based on power level of bullet
				self.queue_free()
				return
