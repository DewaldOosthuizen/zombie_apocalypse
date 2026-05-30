# Add gdlint Pre-Commit Hook and Fix Existing Linting Violations

## Overview

The project ships `.gdlintrc` and `.pre-commit-config.yaml` but the pre-commit
configuration does not include a `gdlint` hook, meaning lint violations in
GDScript files are only caught by the CI workflow (`gdlint.yml`), not locally
before commits. Additionally, `generic_character_behaviour.gd` and
`generic_bullet_behaviour.gd` contain magic numbers used directly in arithmetic
and deeply nested conditional blocks that reduce readability and maintainability.
Extracting these into named constants and smaller focused functions eliminates
ambiguity and reduces cyclomatic complexity.

## Issues

### Issue 1 — Pre-commit config missing gdlint hook

**File:** `.pre-commit-config.yaml`

**Problem:**
The pre-commit configuration only contains a `no-home-paths` pygrep hook.
There is no `gdlint` hook, so developers can commit GDScript violations
without any local feedback. The CI workflow (`gdlint.yml`) catches them only
after push.

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

# After — add gdlint hook under the existing local repo
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
        types: [file]
```

### Issue 2 — gdlint CI does not cover tests directory

**File:** `.github/workflows/gdlint.yml` (line 17)

**Problem:**
The CI step runs `gdlint scripts/` which only covers the `scripts/` directory.
Any `.gd` files added to `tests/` or other directories escape lint enforcement.

**Fix:**
```yaml
# Before
- name: GDScript lint
  run: gdlint scripts/

# After
- name: GDScript lint
  run: gdlint scripts/ tests/
```

### Issue 3 — Magic bullet position offset numbers in generic_character_behaviour.gd

**File:** `scripts/generic_character_behaviour.gd` (lines 225–229)

**Problem:**
`Vector2(-20, 5)` and `Vector2(20, 5)` are used directly when positioning a
fired bullet. The values `20` and `5` carry no semantic meaning at the call
site. A reader must infer that these are barrel/muzzle offsets relative to the
character origin.

**Fix:**
```gdscript
# Before
bullet.position = self.get_position() - Vector2(-20, 5)
# ...
bullet.position = self.get_position() - Vector2(20, 5)

# After — add named constants near the top of the file
const BULLET_OFFSET_X: int = 20
const BULLET_OFFSET_Y: int = 5

bullet.position = self.get_position() - Vector2(-BULLET_OFFSET_X, BULLET_OFFSET_Y)
# ...
bullet.position = self.get_position() - Vector2(BULLET_OFFSET_X, BULLET_OFFSET_Y)
```

### Issue 4 — Magic health threshold and snap precision in generic_character_behaviour.gd

**File:** `scripts/generic_character_behaviour.gd` (line 186)

**Problem:**
The expression `(snapped(health, 0.2) / snapped(max_health, 0.2) * 100) < 40`
embeds three magic numbers: `0.2` (snap precision), `100` (percentage scale),
and `40` (low-health threshold percentage). These cannot be understood without
reading surrounding comments, and changing the threshold requires hunting for
the literal.

**Fix:**
```gdscript
# Before
elif ((snapped(health, 0.2) / snapped(max_health, 0.2) * 100) < 40):

# After — add named constants
const LOW_HEALTH_THRESHOLD_PERCENT: int = 40
const HEALTH_SNAP_PRECISION: float = 0.2
const PERCENT_SCALE: int = 100

elif ((snapped(health, HEALTH_SNAP_PRECISION) / snapped(max_health, HEALTH_SNAP_PRECISION) * PERCENT_SCALE) < LOW_HEALTH_THRESHOLD_PERCENT):
```

### Issue 5 — Magic bullet scale values in generic_bullet_behaviour.gd

**File:** `scripts/generic_bullet_behaviour.gd` (lines 32–38)

**Problem:**
`Vector2(0.2, 0.2)`, `Vector2(0.21, 0.22)`, and `Vector2(0.22, 0.23)` are used
to scale the bullet sprite based on power level. The values have no names and
cannot be understood at a glance. Future power levels would extend a magic-number
sequence.

**Fix:**
```gdscript
# Before
if (power == 0):
    self.scale = Vector2(0.2, 0.2)
elif (power == 1):
    self.scale = Vector2(0.21, 0.22)
elif (power == 2):
    self.scale = Vector2(0.22, 0.23)

# After — add named constants
const BULLET_SCALE_POWER_0: Vector2 = Vector2(0.2, 0.2)
const BULLET_SCALE_POWER_1: Vector2 = Vector2(0.21, 0.22)
const BULLET_SCALE_POWER_2: Vector2 = Vector2(0.22, 0.23)

if (power == 0):
    self.scale = BULLET_SCALE_POWER_0
elif (power == 1):
    self.scale = BULLET_SCALE_POWER_1
elif (power == 2):
    self.scale = BULLET_SCALE_POWER_2
```

### Issue 6 — _area_checks() exceeds three nesting levels

**File:** `scripts/generic_character_behaviour.gd` (lines 235–259)

**Problem:**
`_area_checks()` handles two distinct concerns — attack-area collision and
character-area collision — in a single function. The character-area block reaches
five levels of conditional nesting, making it hard to follow and test in
isolation.

**Fix:**
Extract into two private functions:

```gdscript
# Before
func _area_checks():
    var objects_in_attack_area = get_node("AttackArea2D").get_overlapping_bodies()
    if (objects_in_attack_area and objects_in_attack_area.size() != 0):
        for body in objects_in_attack_area:
            # ... (attack logic, 3 levels deep)

    var areas_in_character_area = get_node("CharacterArea2D").get_overlapping_areas()
    if (areas_in_character_area and areas_in_character_area.size() != 0):
        for area in areas_in_character_area:
            # ... (take-damage logic, 5 levels deep)

# After
func _area_checks():
    _process_attack_area()
    _process_character_area()

func _process_attack_area():
    var objects = get_node("AttackArea2D").get_overlapping_bodies()
    if not objects or objects.size() == 0:
        return
    for body in objects:
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
        if parent.health <= 0 or not (parent.action1 or parent.action2 or parent.action3) or dazed:
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

### Issue 7 — _handle_timers() mixes four unrelated timer concerns

**File:** `scripts/generic_character_behaviour.gd` (lines 126–198)

**Problem:**
`_handle_timers(delta)` manages glide, daze, blood/invincibility, and death
timers in a single 70-line function. Each block is guarded by a different state
flag and operates on different variables. Adding a new timer concern requires
editing this already-complex function.

**Fix:**
Extract each block into a dedicated private function:

```gdscript
# Before
func _handle_timers(delta):
    if (disable_gravity):
        # glide logic ...
    if (dazed):
        # daze logic ...
    if (blood):
        # blood/invincibility logic ...
    if (health <= 0):
        # death logic ...
    if (invincible):
        # flicker logic ...

# After
func _handle_timers(delta):
    _tick_glide_timer(delta)
    _tick_daze_timer(delta)
    _tick_blood_timer(delta)
    _tick_death_timer(delta)
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

func _tick_blood_timer(delta):
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

func _tick_death_timer(delta):
    if health > 0:
        return
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

func _tick_invincibility_timer(delta):
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
```
