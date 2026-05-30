# Add gdlint Pre-commit Check and Fix Existing Linting Violations

## Overview

The project ships a `.gdlintrc` configuration and a `.pre-commit-config.yaml`, but
`gdlint` is not wired as a pre-commit hook and there is no CI step enforcing it.
Without enforcement, style violations accumulate silently. A review of the two core
scripts reveals inline magic numbers, deeply nested conditional blocks exceeding three
levels, and monolithic timer functions handling four unrelated concerns. Addressing
these issues now, while the codebase is small, prevents compounding maintenance debt
as the character roster and level count grow.

## Issues

### Issue 1 — gdlint hook absent from .pre-commit-config.yaml

**File:** `.pre-commit-config.yaml` (line 1–8)
**Problem:** The file only contains a `no-home-paths` pygrep hook. There is no
`gdlint` hook, so developers can commit GDScript with linting violations without any
local warning.
**Fix:**
```yaml
# Before
repos:
  - repo: local
    hooks:
      - id: no-home-paths
        name: No absolute home-directory paths
        language: pygrep
        entry: '(/[h]ome/[^/]+/|C:\\[U]sers\\[^\\]+\\)'
        exclude: '^(.*\.md|openspec/).*'

# After — add gdlint hook below the existing entry
repos:
  - repo: local
    hooks:
      - id: no-home-paths
        name: No absolute home-directory paths
        language: pygrep
        entry: '(/[h]ome/[^/]+/|C:\\[U]sers\\[^\\]+\\)'
        exclude: '^(.*\.md|openspec/).*'
      - id: gdlint
        name: GDScript lint
        language: system
        entry: gdlint
        files: '\.(gd)$'
        pass_filenames: true
```

### Issue 2 — No CI step for gdlint

**File:** `.github/workflows/` (no existing gdlint step)
**Problem:** gdlint is never executed in CI, so violations introduced on any branch
can be merged without detection. The pre-commit hook is the first gate, but CI is the
mandatory gate for all contributors including those who skip pre-commit.
**Fix:**
```yaml
# Add a new job or step to the existing CI workflow:
- name: GDScript lint
  run: |
    pip install gdtoolkit
    gdlint scripts/**/*.gd tests/**/*.gd
```

### Issue 3 — Magic numbers in generic_bullet_behaviour.gd

**File:** `scripts/generic_bullet_behaviour.gd` (lines 34–38, 58–60)
**Problem:** Bullet scale values (`0.2`, `0.21`, `0.22`, `0.23`) and muzzle offset
values (`-20`, `1`, `20`, `1`) are hardcoded inline, making their intent opaque and
any adjustment error-prone.
**Fix:**
```gdscript
# Before (lines 34–38)
if (power == 0):
    self.scale = Vector2(0.2, 0.2)
elif (power == 1):
    self.scale = Vector2(0.21, 0.22)
elif (power == 2):
    self.scale = Vector2(0.22, 0.23)

# Before (lines 57–60)
if (movement_direction == 1):
    muzzle.position = self.position - Vector2(-20, 1)
else:
    muzzle.position = self.position - Vector2(20, 1)

# After — extract to named constants at top of file
const BULLET_SCALE_POWER_0 = Vector2(0.20, 0.20)
const BULLET_SCALE_POWER_1 = Vector2(0.21, 0.22)
const BULLET_SCALE_POWER_2 = Vector2(0.22, 0.23)
const MUZZLE_OFFSET_X = 20
const MUZZLE_OFFSET_Y = 1

# _animate_bullet usage:
if (power == 0):
    self.scale = BULLET_SCALE_POWER_0
elif (power == 1):
    self.scale = BULLET_SCALE_POWER_1
elif (power == 2):
    self.scale = BULLET_SCALE_POWER_2

# _create_muzzle usage:
if (movement_direction == 1):
    muzzle.position = self.position - Vector2(-MUZZLE_OFFSET_X, MUZZLE_OFFSET_Y)
else:
    muzzle.position = self.position - Vector2(MUZZLE_OFFSET_X, MUZZLE_OFFSET_Y)
```

### Issue 4 — Magic numbers in generic_character_behaviour.gd

**File:** `scripts/generic_character_behaviour.gd` (lines 99, 186, 225, 229)
**Problem:** Several inline literals obscure business logic:
- `* 2` (line 99) — deceleration factor applied to movement multiplier
- `snapped(..., 0.2)` and `/ 100` and `< 40` (line 186) — low-health threshold calculation
- `Vector2(-20, 5)` and `Vector2(20, 5)` (lines 225, 229) — bullet spawn offset

**Fix:**
```gdscript
# Before (line 99)
player_speed_x -= movement_multiplier * 2 * delta

# Before (line 186)
elif ((snapped(health, 0.2) / snapped(max_health, 0.2) * 100) < 40):

# Before (lines 225, 229)
bullet.position = self.get_position() - Vector2(-20, 5)
bullet.position = self.get_position() - Vector2(20, 5)

# After — add to the Constants section (after line 13)
const MOVEMENT_DECELERATION_FACTOR = 2
const HEALTH_SNAP_PRECISION = 0.2
const LOW_HEALTH_THRESHOLD_PERCENT = 40
const BULLET_OFFSET_X = 20
const BULLET_OFFSET_Y = 5

# Updated usages:
player_speed_x -= movement_multiplier * MOVEMENT_DECELERATION_FACTOR * delta

elif ((snapped(health, HEALTH_SNAP_PRECISION) / snapped(max_health, HEALTH_SNAP_PRECISION) * 100) < LOW_HEALTH_THRESHOLD_PERCENT):

bullet.position = self.get_position() - Vector2(-BULLET_OFFSET_X, BULLET_OFFSET_Y)
bullet.position = self.get_position() - Vector2(BULLET_OFFSET_X, BULLET_OFFSET_Y)
```

### Issue 5 — _area_checks() nesting depth exceeds three levels

**File:** `scripts/generic_character_behaviour.gd` (lines 235–264)
**Problem:** `_area_checks()` contains five levels of nesting in the enemy-attack
branch (line 257–264), violating the three-level maximum. The function also handles
two distinct responsibilities — attack-area logic and character-area logic — coupling
unrelated concerns.
**Fix:**
```gdscript
# Before — single monolithic function with 5-level nesting (lines 235–264)
func _area_checks():
    var objects_in_attack_area = get_node("AttackArea2D").get_overlapping_bodies()
    if (objects_in_attack_area and objects_in_attack_area.size() != 0):
        for body in objects_in_attack_area:
            if (body and !body.is_queued_for_deletion() and health > 0):
                # ... up to 5 levels deep

# After — split into two focused functions
func _area_checks():
    _process_attack_area()
    _process_character_area()

func _process_attack_area():
    var bodies = get_node("AttackArea2D").get_overlapping_bodies()
    if not bodies or bodies.size() == 0:
        return
    for body in bodies:
        if not body or body.is_queued_for_deletion() or health <= 0:
            continue
        var parent = body.get_parent()
        if body.is_in_group("enemy_character"):
            if action2:
                body._take_damage(action2_damage)
                body._daze()
            elif action3:
                body._take_damage(action3_damage)
                body._daze()
        elif parent.is_in_group("brick") or parent.is_in_group("power_up_brick"):
            parent.break_object()

func _process_character_area():
    var areas = get_node("CharacterArea2D").get_overlapping_areas()
    if not areas or areas.size() == 0:
        return
    for area in areas:
        if not area or area.is_queued_for_deletion() or health <= 0:
            continue
        var parent = area.get_parent()
        if not area.is_in_group("enemy_attack"):
            continue
        var enemy_is_acting = parent.action1 or parent.action2 or parent.action3
        if parent.health <= 0 or not enemy_is_acting or dazed:
            continue
        if action1 or action2 or action3:
            continue
        if parent.action1:
            _take_damage(parent.action1_damage)
        elif parent.action2:
            _take_damage(parent.action2_damage)
        elif parent.action3:
            _take_damage(parent.action3_damage)
```

### Issue 6 — _handle_timers() handles four unrelated concerns in one function

**File:** `scripts/generic_character_behaviour.gd` (lines 126–198)
**Problem:** `_handle_timers()` is a 72-line function that owns glide, daze, blood/
invincibility spawn, and the flicker visual effect. Each concern is logically
independent; bundling them makes future modification error-prone and the function
unreadable as state grows.
**Fix:**
```gdscript
# Before — one monolithic function (lines 126–198)
func _handle_timers(delta):
    if (disable_gravity):
        glide_timer += delta
        # ...
    if (dazed):
        dazed_timer += delta
        # ...
    if (blood):
        # blood + invincibility spawn logic ...
    if (health <= 0):
        # death timer logic ...
    if (invincible):
        # flicker timer logic ...

# After — delegate to four focused private functions
func _handle_timers(delta):
    _tick_glide_timer(delta)
    _tick_daze_timer(delta)
    _tick_blood_timer(delta)
    _tick_invincibility_timer(delta)

func _tick_glide_timer(delta):
    if not disable_gravity:
        return
    glide_timer += delta
    if glide_timer > glide_time:
        glide_timer = 0
        disable_gravity = false

func _tick_daze_timer(delta):
    if not dazed:
        return
    dazed_timer += delta
    if dazed_timer > dazed_time:
        dazed = false
        dazed_timer = 0

func _tick_blood_timer(_delta):
    if not blood:
        return
    blood = false
    if invincible:
        return
    invincible = true
    var particle_effect = BLOOD_PARTICLE_SCENE.instantiate()
    particle_effect.modulate = blood_colour
    particle_effect.get_node(".").set_emitting(true)
    particle_effect.position = self.get_position()
    get_tree().root.add_child(particle_effect)
    _emit_refresh_hud()

func _tick_invincibility_timer(delta):
    if health <= 0:
        _change_sprite_animation("dead")
        repeat_frames = false
        dazed = false
        death_timer += delta
        velocity.x = 0
        velocity.y = 0
        if death_timer > death_time:
            velocity.y = 1
            death_timer = 0
            _emit_reload()
    if not invincible:
        return
    flicker_timer += delta
    invincible_timer += delta
    if invincible_timer > invincible_time:
        player_sprite.visible = true
        invincible = false
        invincible_timer = 0
        flicker_timer = 0
        shield_indicator = false
        player_sprite.modulate = Color("#ffffff")
    if flicker_timer > 0.12 and health > 0:
        _apply_flicker_colour()
        flicker_timer = 0

func _apply_flicker_colour():
    if shield_indicator:
        if player_sprite.modulate == Color("#ffffff"):
            player_sprite.modulate = Color("#1d68c9")
        else:
            player_sprite.modulate = Color("#ffffff")
    elif (snapped(health, HEALTH_SNAP_PRECISION) / snapped(max_health, HEALTH_SNAP_PRECISION) * 100) < LOW_HEALTH_THRESHOLD_PERCENT:
        if player_sprite.modulate == Color("#ffffff"):
            player_sprite.modulate = Color("#dd1717")
        else:
            player_sprite.modulate = Color("#ffffff")
    else:
        player_sprite.visible = not player_sprite.visible
```
