extends "res://scripts/generic_character_behaviour.gd"

# Dino character
# - No gender prefix in animation names (dino_idle, dino_run, etc.)
# - Assets: Dead, Idle, Jump, Run, Walk  — no Melee, Shoot, or Slide
# - Action1 (shoot), Action2 (melee), Action3 (slide): all silenced
# - Stomp mechanic: when falling downward and the StompArea2D at the
#   dino's feet overlaps an enemy_character, that enemy is instantly killed.

const STOMP_MIN_VELOCITY = 100.0  # minimum downward speed to trigger stomp

var _stomp_area: Area2D
var _stomped_this_jump := false  # prevent multi-kill on same landing


func _ready():
	type = "dino"
	gender = ""  # unused — _change_sprite_animation builds "dino_<anim>" directly
	player_sprite = get_node("AnimatedSprite")
	if (!get_tree().root.is_queued_for_deletion()):
		_setup_collision()
		_stomp_area = get_node("StompArea2D")
		velocity = Vector2(0, 0)
		facing_direction = 1
		player_sprite.animation = "dino_idle"
		player_sprite.play()
		_emit_character_ready()


func _physics_process(delta):
	if player_sprite == null:
		return
	_handle_input()
	super._start_process(delta)
	if health > 0:
		super._area_checks()
		_check_stomp()
	_reset_character_sprite_states(delta)


# --- Input ---------------------------------------------------------------

func _handle_input():
	if health <= 0 or dazed:
		movement_direction = 0
		return

	if Input.is_action_pressed("move_left"):
		_move_left()
	elif Input.is_action_pressed("move_right"):
		_move_right()
	else:
		movement_direction = 0

	if Input.is_action_just_pressed("move_jump") and current_jump_count < max_jump_count:
		player_speed_y = -JUMPFORCE
		current_jump_count += 1
		_stomped_this_jump = false  # reset stomp flag on each new jump
		repeat_frames = false
		_change_sprite_animation("jump")

	# action1, action2, action3 intentionally silenced — dino has no shoot/melee/slide


# --- Stomp mechanic ------------------------------------------------------

func _check_stomp():
	# Only stomp when falling downward fast enough
	if player_speed_y < STOMP_MIN_VELOCITY or _stomped_this_jump:
		return
	var bodies = _stomp_area.get_overlapping_bodies()
	for body in bodies:
		if body == null or body.is_queued_for_deletion():
			continue
		if body.is_in_group("enemy_character") and body.health > 0:
			body._take_damage(body.health + 1)  # instant kill regardless of enemy health
			body._daze()
			_stomped_this_jump = true
			# Small upward bounce to feel responsive
			player_speed_y = -JUMPFORCE * 0.5
			current_jump_count = 1  # allow one more jump after stomp


# --- Animation override --------------------------------------------------
# Dino has no gender prefix; animation names are dino_<anim> directly.

func _change_sprite_animation(animation_text):
	if player_sprite == null:
		return
	player_sprite.animation = "dino_" + animation_text


func _reset_character_sprite_states(delta):
	if player_sprite == null:
		return
	if health <= 0:
		_change_sprite_animation("dead")
		repeat_frames = false
		disable_gravity = false
	elif dazed:
		_change_sprite_animation("idle")
		disable_gravity = false
	elif action1 or action2 or action3:
		# All actions silenced — clear flags immediately
		action1 = false
		action2 = false
		action3 = false
		repeat_frames = true
		disable_gravity = false
		if movement_direction == 0:
			_change_sprite_animation("idle")
		else:
			_change_sprite_animation("run")
		_default_collision()
	elif current_jump_count > 0:
		# In air — hold jump animation, do not override with idle/run
		_change_sprite_animation("jump")
	elif not action1 and not action2 and not action3 and current_jump_count == 0:
		_default_collision()
		repeat_frames = true
		if movement_direction == 0:
			_change_sprite_animation("idle")
		else:
			_change_sprite_animation("run")
		disable_gravity = false


# --- No-op action overrides (document intent explicitly) -----------------

# Dino has no projectile weapon — silently ignore shoot requests.
func _shoot_bullet(_power):
	pass


# Dino has no melee attack — action2 never activates attack collision.
func _melee_attack_collision():
	pass


# Dino has no slide — action3 is a no-op.
func _slide_attack_collision():
	pass
