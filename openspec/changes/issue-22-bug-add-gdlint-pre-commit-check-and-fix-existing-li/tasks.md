# Tasks: Add gdlint Pre-commit Check and Fix Existing Linting Violations

## Pre-commit and CI Enforcement

- [ ] Add `gdlint` hook to `.pre-commit-config.yaml` targeting `**/*.gd` files (file: `.pre-commit-config.yaml`)
- [ ] Verify `gdlint` is installed in the dev environment (`pip install gdtoolkit`) and document in README or dev-setup notes
- [ ] Create or extend a CI workflow to run `gdlint scripts/**/*.gd tests/**/*.gd` as a blocking step (file: `.github/workflows/ci.yml`)
- [ ] Confirm `pre-commit run --all-files` passes with zero gdlint violations after all fixes are applied

## Named Constants — generic_character_behaviour.gd

- [ ] Declare `const MOVEMENT_DECELERATION_FACTOR = 2` in the constants block (file: `scripts/generic_character_behaviour.gd`, line ~10)
- [ ] Declare `const HEALTH_SNAP_PRECISION = 0.2` in the constants block (file: `scripts/generic_character_behaviour.gd`)
- [ ] Declare `const LOW_HEALTH_THRESHOLD_PERCENT = 40` in the constants block (file: `scripts/generic_character_behaviour.gd`)
- [ ] Declare `const BULLET_OFFSET_X = 20` and `const BULLET_OFFSET_Y = 5` in the constants block (file: `scripts/generic_character_behaviour.gd`)
- [ ] Replace inline `* 2` with `* MOVEMENT_DECELERATION_FACTOR` in `_animate_player()` (line ~99)
- [ ] Replace inline `snapped(..., 0.2)` literals with `HEALTH_SNAP_PRECISION` in `_handle_timers()` (line ~186)
- [ ] Replace `< 40` threshold literal with `< LOW_HEALTH_THRESHOLD_PERCENT` (line ~186)
- [ ] Replace `Vector2(-20, 5)` and `Vector2(20, 5)` in `_shoot_bullet()` with constant-backed expressions (lines ~225, ~229)

## Named Constants — generic_bullet_behaviour.gd

- [ ] Declare `const BULLET_SCALE_POWER_0`, `BULLET_SCALE_POWER_1`, `BULLET_SCALE_POWER_2` for the three scale vectors (file: `scripts/generic_bullet_behaviour.gd`, lines ~34–38)
- [ ] Replace the three inline `Vector2` scale literals with the new constants in `_animate_bullet()` (lines ~34–38)
- [ ] Declare `const MUZZLE_OFFSET_X = 20` and `const MUZZLE_OFFSET_Y = 1` (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Replace inline `Vector2(-20, 1)` and `Vector2(20, 1)` in `_create_muzzle()` with constant-backed expressions (lines ~58–60)

## Refactor _area_checks() — generic_character_behaviour.gd

- [ ] Extract attack-area collision logic into `_process_attack_area()` (file: `scripts/generic_character_behaviour.gd`, lines ~235–249)
- [ ] Extract character-area collision logic into `_process_character_area()` (file: `scripts/generic_character_behaviour.gd`, lines ~251–264)
- [ ] Extract innermost incoming-damage guard into `_apply_incoming_damage(parent)` to reduce nesting to max three levels
- [ ] Replace body of `_area_checks()` with two delegation calls: `_process_attack_area()` and `_process_character_area()`
- [ ] Verify nesting depth of each extracted function does not exceed three levels

## Refactor _handle_timers() — generic_character_behaviour.gd

- [ ] Extract glide timer block into `_tick_glide_timer(delta)` (file: `scripts/generic_character_behaviour.gd`, lines ~127–131)
- [ ] Extract daze timer block into `_tick_daze_timer(delta)` (lines ~133–138)
- [ ] Extract blood/invincibility trigger block into `_tick_blood_timer(delta)` (lines ~140–151)
- [ ] Extract death-state block into `_handle_death_state(delta)` (lines ~153–164)
- [ ] Extract invincibility + flicker timer blocks into `_tick_invincibility_timer(delta)` (lines ~166–198)
- [ ] Extract flicker colour-toggle logic into `_handle_flicker()` to eliminate nested conditionals
- [ ] Replace body of `_handle_timers(delta)` with four delegation calls: `_tick_glide_timer`, `_tick_daze_timer`, `_tick_blood_timer`, `_tick_invincibility_timer`
- [ ] Verify nesting depth of each extracted function does not exceed three levels

## Verification

- [ ] Run all existing GUT tests and confirm zero regressions after the refactor
- [ ] Run `gdlint scripts/generic_character_behaviour.gd scripts/generic_bullet_behaviour.gd` locally and confirm zero violations
- [ ] Run `pre-commit run --all-files` and confirm clean output
