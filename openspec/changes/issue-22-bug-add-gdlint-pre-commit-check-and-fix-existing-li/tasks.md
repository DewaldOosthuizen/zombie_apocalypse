# Tasks: Add gdlint Pre-commit Check and Fix Existing Linting Violations

## Pre-commit & CI Enforcement

- [ ] Add gdlint hook to `.pre-commit-config.yaml` targeting `*.gd` files (file: `.pre-commit-config.yaml`)
- [ ] Verify `pre-commit run --all-files` passes with zero gdlint violations after all fixes
- [ ] Create or update a CI workflow file to install gdtoolkit and run `gdlint scripts/**/*.gd tests/**/*.gd` (file: `.github/workflows/`)
- [ ] Confirm CI step fails the build when a gdlint violation is introduced (manual verification or test commit)

## Named Constants — generic_bullet_behaviour.gd

- [ ] Add `BULLET_SCALE_POWER_0`, `BULLET_SCALE_POWER_1`, `BULLET_SCALE_POWER_2` constants (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Add `MUZZLE_OFFSET_X` and `MUZZLE_OFFSET_Y` constants (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Replace inline `Vector2(0.2, 0.2)`, `Vector2(0.21, 0.22)`, `Vector2(0.22, 0.23)` in `_animate_bullet()` with constant references (file: `scripts/generic_bullet_behaviour.gd`, lines 34–38)
- [ ] Replace inline `Vector2(-20, 1)` and `Vector2(20, 1)` in `_create_muzzle()` with constant references (file: `scripts/generic_bullet_behaviour.gd`, lines 58–60)

## Named Constants — generic_character_behaviour.gd

- [ ] Add `MOVEMENT_DECELERATION_FACTOR = 2` constant (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add `HEALTH_SNAP_PRECISION = 0.2` constant (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add `LOW_HEALTH_THRESHOLD_PERCENT = 40` constant (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add `BULLET_OFFSET_X = 20` and `BULLET_OFFSET_Y = 5` constants (file: `scripts/generic_character_behaviour.gd`)
- [ ] Replace `* 2` in `_animate_player()` with `MOVEMENT_DECELERATION_FACTOR` (file: `scripts/generic_character_behaviour.gd`, line 99)
- [ ] Replace `snapped(..., 0.2)` and `< 40` in `_handle_timers()` with `HEALTH_SNAP_PRECISION` and `LOW_HEALTH_THRESHOLD_PERCENT` (file: `scripts/generic_character_behaviour.gd`, line 186)
- [ ] Replace `Vector2(-20, 5)` and `Vector2(20, 5)` in `_shoot_bullet()` with `BULLET_OFFSET_X` / `BULLET_OFFSET_Y` constants (file: `scripts/generic_character_behaviour.gd`, lines 225–229)

## Refactor: _area_checks()

- [ ] Extract `_process_attack_area()` private function containing the AttackArea2D body-loop logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Extract `_process_character_area()` private function containing the CharacterArea2D area-loop logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Reduce nesting in `_process_character_area()` using early-return guard clauses (maximum depth: 3) (file: `scripts/generic_character_behaviour.gd`)
- [ ] Update `_area_checks()` to delegate to `_process_attack_area()` and `_process_character_area()` (file: `scripts/generic_character_behaviour.gd`)

## Refactor: _handle_timers()

- [ ] Extract `_tick_glide_timer(delta)` private function (file: `scripts/generic_character_behaviour.gd`)
- [ ] Extract `_tick_daze_timer(delta)` private function (file: `scripts/generic_character_behaviour.gd`)
- [ ] Extract `_tick_blood_timer(delta)` private function containing blood flag, invincibility trigger, and particle spawn (file: `scripts/generic_character_behaviour.gd`)
- [ ] Extract `_tick_invincibility_timer(delta)` private function containing death timer and flicker/invincibility timer logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Extract `_apply_flicker_colour()` helper used by `_tick_invincibility_timer` for the sprite modulate switching (file: `scripts/generic_character_behaviour.gd`)
- [ ] Update `_handle_timers(delta)` to delegate to the four `_tick_*` functions (file: `scripts/generic_character_behaviour.gd`)

## Verification

- [ ] Run all GUT tests and confirm zero regressions after refactoring
- [ ] Confirm `_area_checks()` and `_handle_timers()` each have a maximum nesting depth of three
- [ ] Confirm no magic numbers remain inline in `generic_character_behaviour.gd` or `generic_bullet_behaviour.gd`
