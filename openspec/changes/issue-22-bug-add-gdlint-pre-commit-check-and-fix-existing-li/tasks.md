# Tasks: Add gdlint Pre-Commit Hook and Fix Existing Linting Violations

## Pre-Commit Configuration

- [ ] Add `gdlint` hook to `.pre-commit-config.yaml` under the existing `local` repo entry targeting `\.(gd)$` files (file: `.pre-commit-config.yaml`)
- [ ] Verify `pre-commit run --all-files` passes with zero gdlint violations after all code fixes are applied

## CI Workflow

- [ ] Extend `gdlint` step in `.github/workflows/gdlint.yml` to cover `tests/` directory in addition to `scripts/` (file: `.github/workflows/gdlint.yml`, line 17)

## Named Constants — generic_character_behaviour.gd

- [ ] Add constant `BULLET_OFFSET_X: int = 20` near the top of the constants block (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add constant `BULLET_OFFSET_Y: int = 5` near the top of the constants block (file: `scripts/generic_character_behaviour.gd`)
- [ ] Replace inline `Vector2(-20, 5)` with `Vector2(-BULLET_OFFSET_X, BULLET_OFFSET_Y)` (file: `scripts/generic_character_behaviour.gd`, line 225)
- [ ] Replace inline `Vector2(20, 5)` with `Vector2(BULLET_OFFSET_X, BULLET_OFFSET_Y)` (file: `scripts/generic_character_behaviour.gd`, line 229)
- [ ] Add constant `LOW_HEALTH_THRESHOLD_PERCENT: int = 40` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add constant `HEALTH_SNAP_PRECISION: float = 0.2` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add constant `PERCENT_SCALE: int = 100` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Replace magic values `0.2`, `100`, `40` in health flicker condition with named constants (file: `scripts/generic_character_behaviour.gd`, line 186)

## Named Constants — generic_bullet_behaviour.gd

- [ ] Add constant `BULLET_SCALE_POWER_0: Vector2 = Vector2(0.2, 0.2)` (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Add constant `BULLET_SCALE_POWER_1: Vector2 = Vector2(0.21, 0.22)` (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Add constant `BULLET_SCALE_POWER_2: Vector2 = Vector2(0.22, 0.23)` (file: `scripts/generic_bullet_behaviour.gd`)
- [ ] Replace the three inline `Vector2` scale literals with the new named constants (file: `scripts/generic_bullet_behaviour.gd`, lines 32–38)

## Refactor _area_checks()

- [ ] Add private function `_process_attack_area()` containing the AttackArea2D collision logic extracted from `_area_checks()` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add private function `_process_character_area()` containing the CharacterArea2D collision logic extracted from `_area_checks()` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Rewrite `_area_checks()` body to delegate to `_process_attack_area()` and `_process_character_area()` only (file: `scripts/generic_character_behaviour.gd`)
- [ ] Verify maximum nesting depth of `_process_attack_area()` and `_process_character_area()` is three or fewer levels

## Refactor _handle_timers()

- [ ] Add private function `_tick_glide_timer(delta)` containing glide-timer logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add private function `_tick_daze_timer(delta)` containing daze-timer logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add private function `_tick_blood_timer(delta)` containing blood/invincibility-spawn logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add private function `_tick_death_timer(delta)` containing death-timer and reload logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add private function `_tick_invincibility_timer(delta)` containing flicker/invincibility-timer logic (file: `scripts/generic_character_behaviour.gd`)
- [ ] Rewrite `_handle_timers(delta)` to delegate to the five new timer functions only (file: `scripts/generic_character_behaviour.gd`)
- [ ] Verify maximum nesting depth of `_handle_timers()` and each extracted function is three or fewer levels

## Verification

- [ ] Run `gdlint scripts/ tests/` locally and confirm zero violations
- [ ] Run all GUT tests and confirm they pass without regression
- [ ] Run `pre-commit run --all-files` and confirm zero failures
