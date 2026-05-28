# Tasks: Enforce GDScript Naming Conventions and Fix Typos

## Preparation

- [ ] Install gdtoolkit locally: `pip install gdtoolkit`
- [ ] Run `gdlint scripts/` and capture the baseline violation report to confirm
      all issues identified in proposal.md are present
- [ ] Identify every .tscn scene file that references @export variables from
      the four scripts (search for camelCase property names in .tscn files):
      `grep -rn "playerSpeedX\|maxJumpCount\|maxSpeed\|action1Damage\|action2Damage\|action3Damage\|characterScale\|mainCharacter\|moveDirectionX\|moveDirectionY\|canTween\|moveDistanceX\|moveDistanceY\|tweenDuration" --include="*.tscn" .`


## generic_character_behaviour.gd — Identifier Renames

- [ ] Rename `playerSprite` → `player_sprite` (all occurrences)
- [ ] Rename `playerSpeedX` → `player_speed_x` (all occurrences)
- [ ] Rename `playerSpeedY` → `player_speed_y` (all occurrences)
- [ ] Rename `facingDirection` → `facing_direction` (all occurrences)
- [ ] Rename `movementDirection` → `movement_direction` (all occurrences)
- [ ] Rename `currentJumpCount` → `current_jump_count` (all occurrences)
- [ ] Rename `movementMultiplier` → `movement_multiplier` (all occurrences)
- [ ] Rename `stationaryVelocity` → `stationary_velocity` (all occurrences)
- [ ] Rename `@export maxJumpCount` → `@export max_jump_count` and update all .tscn references
- [ ] Rename `@export maxSpeed` → `@export max_speed` and update all .tscn references
- [ ] Rename `@export action1Damage` → `@export action1_damage` and update all .tscn references
- [ ] Rename `@export action2Damage` → `@export action2_damage` and update all .tscn references
- [ ] Rename `@export action3Damage` → `@export action3_damage` and update all .tscn references
- [ ] Rename `@export characterScale` → `@export character_scale` and update all .tscn references
- [ ] Rename `@export mainCharacter` → `@export main_character` and update all .tscn references
- [ ] Rename `deathTime` → `death_time` (all occurrences)
- [ ] Rename `deathTimer` → `death_timer` (all occurrences)
- [ ] Rename `flickerTimer` → `flicker_timer` (all occurrences)
- [ ] Rename `invincibleTime` → `invincible_time` (all occurrences)
- [ ] Rename `invincibleTimer` → `invincible_timer` (all occurrences)
- [ ] Rename `dazedTime` → `dazed_time` (all occurrences)
- [ ] Rename `dazedTimer` → `dazed_timer` (all occurrences)
- [ ] Rename `glideTimer` → `glide_timer` (all occurrences)
- [ ] Rename `glideTime` → `glide_time` (all occurrences)
- [ ] Rename `repeatFrames` → `repeat_frames` (all occurrences)
- [ ] Rename `disableGravity` → `disable_gravity` (all occurrences)
- [ ] Rename `shieldIndicator` → `shield_indicator` (all occurrences)
- [ ] Rename `bloodParticle_scene` → `blood_particle_scene` (all occurrences)
- [ ] Rename local `collidedObject1` → `collided_object1`
- [ ] Rename local `collidedObject2` → `collided_object2`
- [ ] Rename local `objectsInAttackArea` → `objects_in_attack_area`
- [ ] Rename local `areasInCharacterArea` → `areas_in_character_area`
- [ ] Rename local `bulletSprite` → `bullet_sprite` (in `_shoot_bullet`)
- [ ] Rename parameter `damageAmount` → `damage_amount` (in `_take_damage`)
- [ ] Rename parameter `animationText` → `animation_text` (in `_change_sprite_animation`)


## generic_character_behaviour.gd — Comment Typo Fixes

- [ ] Line 11: fix "scriptt" → "script" in comment
- [ ] Line 13: fix "moveing" → "moving" in comment
- [ ] Line 80: fix "behavioyr" → "behaviour" in comment
- [ ] Line 145: fix "blodd" → "blood" in comment
- [ ] Line 163: remove stale `#warning-ignore:return_value_discarded` (not valid in Godot 4)


## generic_bullet_behaviour.gd — Identifier Renames

- [ ] Rename `movementDirection` → `movement_direction` (all occurrences, including
      cross-script assignment at generic_character_behaviour.gd line 220/224)
- [ ] Rename `noValidCollision` → `no_valid_collision` (all occurrences)
- [ ] Rename `deltaTime` → `delta_time` (all occurrences)
- [ ] Rename `bricksParticle_scene` → `bricks_particle_scene` (all occurrences)
- [ ] Rename local `objectParent` → `object_parent` in `_remove_if_brick`


## generic_bullet_behaviour.gd — Comment Typo Fix

- [ ] Line 34: fix "disapears" → "disappears" in comment


## generic_tween_script.gd — Identifier Renames

- [ ] Rename `tweenNode` → `tween_node` (all occurrences)
- [ ] Rename `tweenRunning` → `tween_running` (all occurrences)
- [ ] Rename `@export moveDirectionX` → `@export move_direction_x` and update all .tscn references
- [ ] Rename `@export moveDirectionY` → `@export move_direction_y` and update all .tscn references
- [ ] Rename `@export canTween` → `@export can_tween` and update all .tscn references
- [ ] Rename `@export moveDistanceX` → `@export move_distance_x` and update all .tscn references
- [ ] Rename `@export moveDistanceY` → `@export move_distance_y` and update all .tscn references
- [ ] Rename `movementPosition` → `movement_position` (all occurrences)
- [ ] Rename `@export tweenDuration` → `@export tween_duration` and update all .tscn references


## generic_level_script.gd — Signal Name Standardisation

- [ ] Rename signal `exit_level` → `level_exited` (declaration on line 4)
- [ ] Rename signal `entered_level` → `level_entered` (declaration on line 5)
- [ ] Update `emit_signal("entered_level")` → `emit_signal("level_entered")` (line 9)
- [ ] Update `emit_signal("exit_level")` → `emit_signal("level_exited")` (line 12)
- [ ] Search all .tscn files and other .gd scripts for connections to `exit_level` or
      `entered_level` and update them to the new names:
      `grep -rn "exit_level\|entered_level" --include="*.tscn" --include="*.gd" .`


## Scene File Updates

- [ ] For every @export rename above, open each affected .tscn file and update the
      property key in the [node] section to match the new snake_case name
- [ ] Verify no .tscn file still references any old camelCase property name after
      the rename pass: `grep -rn "playerSpeedX\|maxJumpCount\|moveDirectionX\|canTween\|tweenDuration" --include="*.tscn" .`


## CI and Linting Infrastructure

- [ ] Create `.gdlintrc` at project root with `max-line-length: 120`
- [ ] Create `.github/workflows/gdlint.yml` (or add a step to an existing workflow)
      that installs gdtoolkit and runs `gdlint scripts/` on push and pull_request
- [ ] Confirm `gdlint scripts/` exits with zero violations locally before pushing


## Verification

- [ ] Run `gdlint scripts/` — must exit 0 with zero violations
- [ ] Open the project in the Godot editor — no missing-property warnings in the
      inspector for any scene that uses the renamed @export variables
- [ ] Run the game and verify all four character scripts, bullet scripts, tween
      objects, and level transitions behave identically to before the rename
- [ ] Confirm signal connections (`level_entered`, `level_exited`) fire correctly
      by testing level load and unload in-engine
