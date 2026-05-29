extends GutTest

var _char

func before_each():
	_char = load("res://scripts/generic_character_behaviour.gd").new()

func after_each():
	_char.free()

func test_shoot_bullet_with_null_bullet_scene_pushes_error_and_returns():
	_char.bullet_scene = null
	_char.action1 = false
	_char.ammo = 5
	_char._shoot_bullet(10)
	assert_false(_char.action1, "action1 must remain false when bullet_scene is null")
	assert_eq(_char.ammo, 5, "ammo must not be decremented when bullet_scene is null")

func test_shoot_bullet_with_zero_ammo_is_noop():
	# Use a non-null sentinel for bullet_scene — the ammo guard fires before
	# instantiate() is ever called, so we only need a non-null reference here.
	_char.bullet_scene = load("res://scripts/generic_character_behaviour.gd")
	_char.action1 = false
	_char.ammo = 0
	_char._shoot_bullet(10)
	assert_false(_char.action1, "action1 must remain false when ammo is 0")
	assert_eq(_char.ammo, 0, "ammo must not go negative when already 0")

func test_take_damage_reduces_health_when_no_energy():
	_char.health = 100
	_char.energy = 0
	_char.invincible = false
	_char._take_damage(30)
	assert_eq(_char.health, 70, "Health should drop by damage amount when energy is 0")

func test_take_damage_drains_energy_before_health():
	_char.health = 100
	_char.energy = 50
	_char.invincible = false
	_char._take_damage(30)
	assert_eq(_char.energy, 20, "Energy should absorb the damage first")
	assert_eq(_char.health, 100, "Health must be untouched while energy remains")

func test_take_damage_spills_over_from_energy_to_health():
	# Energy is 10, damage is 30 — 10 absorbed by energy, 20 spills to health
	_char.health = 100
	_char.energy = 10
	_char.invincible = false
	_char._take_damage(30)
	assert_eq(_char.energy, 0, "Energy must be floored to 0")
	assert_eq(_char.health, 80, "Remaining 20 damage must spill to health")

func test_take_damage_blocked_when_invincible():
	_char.health = 100
	_char.energy = 0
	_char.invincible = true
	_char._take_damage(50)
	assert_eq(_char.health, 100, "Invincible character must take no damage")

func test_take_damage_sets_blood_flag():
	_char.health = 100
	_char.energy = 0
	_char.invincible = false
	_char.blood = false
	_char._take_damage(10)
	assert_true(_char.blood, "blood flag must be set true after taking damage")

func test_take_damage_does_not_set_blood_when_invincible():
	_char.invincible = true
	_char.blood = false
	_char._take_damage(10)
	assert_false(_char.blood, "blood flag must remain false when invincible")

func test_invincibility_timer_increments_while_invincible():
	# Safe: only reads invincibleTimer after delta — no playerSprite access
	# because invincibleTimer (0 + 0.1) does NOT exceed invincibleTime (3)
	_char.invincible = true
	_char.invincibleTimer = 0.0
	_char.flickerTimer = 0.0
	_char.blood = false     # guard against bloodParticle branch
	# playerSprite is null but the reset branch (L172) is NOT reached
	_char._handle_timers(0.1)
	assert_almost_eq(_char.invincibleTimer, 0.1, 0.001,
		"invincibleTimer should increment by delta each frame")

func test_invincibility_timer_resets_after_duration():
	# playerSprite MUST be assigned — L173 executes playerSprite.visible = true
	var stub_sprite = AnimatedSprite2D.new()
	_char.playerSprite = stub_sprite
	_char.invincible = true
	_char.invincibleTimer = 3.1   # already past invincibleTime (3)
	_char.flickerTimer = 0.0
	_char.blood = false            # guard against bloodParticle branch
	_char._handle_timers(0.0)
	assert_false(_char.invincible,
		"invincible must be cleared once invincibleTimer exceeds invincibleTime")
	assert_eq(_char.invincibleTimer, 0,
		"invincibleTimer must reset to 0 after expiry")
	stub_sprite.free()
