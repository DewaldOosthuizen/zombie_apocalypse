# Add gdlint Pre-commit Check and Fix Existing Linting Violations

## Overview

The project ships a `.gdlintrc` but has no `gdlint` hook in `.pre-commit-config.yaml`
and no CI step to enforce it. As a result, style violations have accumulated in the two
core scripts: `scripts/generic_character_behaviour.gd` contains magic numbers, a
five-level-deep `_area_checks()`, and a monolithic `_handle_timers()` that mixes four
unrelated timer concerns; `scripts/generic_bullet_behaviour.gd` uses hard-coded scale
tuples and position offsets. Adding enforcement now — while the codebase is small —
prevents these patterns from compounding as more characters and levels are added.

## Issues

### Issue 1 — gdlint hook absent from .pre-commit-config.yaml

**File:** `.pre-commit-config.yaml`
**Problem:** The file only contains a `no-home-paths` hook. There is no `gdlint` hook,
so the linting rules defined in `.gdlintrc` are never enforced locally.
**Fix:**
```yaml
# Before — no gdlint hook present
repos:
  - repo: local
    hooks:
      - id: no-home-paths
        ...

# After — gdlint hook added
repos:
  - repo: local
    hooks:
      - id: no-home-paths
        ...
      - id: gdlint
        name: GDScript lint
        language: system
        entry: gdlint
        files: \.(gd)$
        types: [file]
```

### Issue 2 — No gdlint step in CI

**File:** `.github/workflows/` (new file `ci.yml` or extension of existing workflow)
**Problem:** There is no CI workflow that runs `gdlint`, so violations pass undetected
in pull requests even if the pre-commit hook is bypassed.
**Fix:**
```yaml
# After — new CI step
- name: Lint GDScript
  run: |
    pip install gdtoolkit
    gdlint scripts/**/*.gd tests/**/*.gd
```

### Issue 3 — Magic numbers in generic_character_behaviour.gd

**File:** `scripts/generic_character_behaviour.gd` (lines 99, 186, 225, 229)
**Problem:** Raw numeric literals are used inline for deceleration factor, health snap
precision, low-health threshold, and bullet position offsets. Their intent is unclear
without reading surrounding context.
**Fix:**
```gdscript
# Before (line 99)
player_speed_x -= movement_multiplier * 2 * delta

# After — named constant declared in the constants block
const MOVEMENT_DECELERATION_FACTOR = 2
player_speed_x -= movement_multiplier * MOVEMENT_DECELERATION_FACTOR * delta

# Before (line 186)
elif ((snapped(health, 0.2) / snapped(max_health, 0.2) * 100) < 40):

# After
const HEALTH_SNAP_PRECISION = 0.2
const LOW_HEALTH_THRESHOLD_PERCENT = 40
elif ((snapped(health, HEALTH_SNAP_PRECISION) / snapped(max_health, HEALTH_SNAP_PRECISION) * 100) < LOW_HEALTH_THRESHOLD_PERCENT):

# Before (lines 225, 229)
bullet.position = self.get_position() - Vector2(-20, 5)
bullet.position = self.get_position() - Vector2(20, 5)

# After
const BULLET_OFFSET_X = 20
const BULLET_OFFSET_Y = 5
bullet.position = self.get_position() - Vector2(-BULLET_OFFSET_X, BULLET_OFFSET_Y)
bullet.position = self.get_position() - Vector2(BULLET_OFFSET_X, BULLET_OFFSET_Y)
```

### Issue 4 — Magic scale values in generic_bullet_behaviour.gd

**File:** `scripts/generic_bullet_behaviour.gd` (lines 34–38, 58–60)
**Problem:** Bullet scale values (`0.2`, `0.21`, `0.22`, `0.23`) and muzzle position
offsets (`-20`, `20`, `1`) are raw literals with no names to communicate their purpose.
**Fix:**
```gdscript
# Before (lines 34–38)
if (power == 0):
    self.scale = Vector2(0.2, 0.2)
elif (power == 1):
    self.scale = Vector2(0.21, 0.22)
elif (power == 2):
    self.scale = Vector2(0.22, 0.23)

# After
const BULLET_SCALE_POWER_0 = Vector2(0.20, 0.20)
const BULLET_SCALE_POWER_1 = Vector2(0.21, 0.22)
const BULLET_SCALE_POWER_2 = Vector2(0.22, 0.23)

if (power == 0):
    self.scale = BULLET_SCALE_POWER_0
elif (power == 1):
    self.scale = BULLET_SCALE_POWER_1
elif (power == 2):
    self.scale = BULLET_SCALE_POWER_2

# Before (lines 58–60)
muzzle.position = self.position - Vector2(-20, 1)
muzzle.position = self.position - Vector2(20, 1)

# After
const MUZZLE_OFFSET_X = 20
const MUZZLE_OFFSET_Y = 1
muzzle.position = self.position - Vector2(-MUZZLE_OFFSET_X, MUZZLE_OFFSET_Y)
muzzle.position = self.position - Vector2(MUZZLE_OFFSET_X, MUZZLE_OFFSET_Y)
```

### Issue 5 — _area_checks() nesting depth exceeds three levels

**File:** `scripts/generic_character_behaviour.gd` (lines 235–264)
**Problem:** `_area_checks()` handles two distinct collision domains (attack area and
character area) in one function, reaching five levels of nesting in the character area
branch. This violates the single-responsibility principle and makes the logic hard to
follow and test in isolation.
**Fix:** Extract into two private functions:
```gdscript
# Before — single monolithic function
func _area_checks():
    var objects_in_attack_area = get_node("AttackArea2D").get_overlapping_bodies()
    if (objects_in_attack_area and objects_in_attack_area.size() != 0):
        for body in objects_in_attack_area:
            if (body and !body.is_queued_for_deletion() and health > 0):
                ...  # attack logic (3 levels deep)

    var areas_in_character_area = get_node("CharacterArea2D").get_overlapping_areas()
    if (areas_in_character_area and areas_in_character_area.size() != 0):
        for area in areas_in_character_area:
            if (area and !area.is_queued_for_deletion() and health > 0):
                ...  # receive-damage logic (5 levels deep)

# After — delegating wrapper + two focused functions
func _area_checks():
    _process_attack_area()
    _process_character_area()

func _process_attack_area():
    var bodies = get_node("AttackArea2D").get_overlapping_bodies()
    if not bodies or bodies.size() == 0:
        return
    for body in bodies:
        if body and !body.is_queued_for_deletion() and health > 0:
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
        if area and !area.is_queued_for_deletion() and health > 0:
            var parent = area.get_parent()
            if area.is_in_group("enemy_attack"):
                _apply_incoming_damage(parent)

func _apply_incoming_damage(parent):
    if parent.health <= 0 or not (parent.action1 or parent.action2 or parent.action3):
        return
    if dazed or action1 or action2 or action3:
        return
    if parent.action1:
        _take_damage(parent.action1_damage)
    elif parent.action2:
        _take_damage(parent.action2_damage)
    elif parent.action3:
        _take_damage(parent.action3_damage)
```

### Issue 6 — _handle_timers() handles four unrelated concerns

**File:** `scripts/generic_character_behaviour.gd` (lines 126–198)
**Problem:** `_handle_timers()` manages the glide, daze, blood/invincibility, and
death timers in a single 73-line function. Each concern is independent; mixing them
makes it harder to locate a specific timer's logic and raises cyclomatic complexity.
**Fix:** Extract each timer block into a dedicated private function:
```gdscript
# Before — one 73-line function
func _handle_timers(delta):
    if (disable_gravity):      # glide timer
        ...
    if (dazed):                # daze timer
        ...
    if (blood):                # blood / invincibility timer
        ...
    if (health <= 0):          # death timer
        ...
    if (invincible):           # flicker timer
        ...

# After — thin dispatcher + four focused functions
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
        _handle_death_state(delta)
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
    _handle_flicker()

func _handle_death_state(delta):
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

func _handle_flicker():
    if flicker_timer <= 0.12 or health <= 0:
        return
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
    flicker_timer = 0
```
