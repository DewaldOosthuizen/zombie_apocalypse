# Tasks: Add GUT Automated Test Suite (Issue #6)

## Framework Installation

- [ ] Add GUT as a git submodule: `git submodule add https://github.com/bitwes/Gut.git addons/gut`
- [ ] Run `git submodule update --init --recursive` and commit `.gitmodules` and `addons/gut`
- [ ] Verify `addons/gut/gut_cmdln.gd` is present after submodule initialisation
- [ ] Enable the GUT plugin in `project.godot` (Plugins tab or direct edit)

## Test File: tests/test_character_behaviour.gd

- [ ] Create `tests/` directory at project root
- [ ] Create `tests/test_character_behaviour.gd` extending `GutTest`
- [ ] Implement `before_each` — instantiate bare `generic_character_behaviour.gd` via `load().new()`
- [ ] Implement `after_each` — call `_char.free()`
- [ ] Write `test_take_damage_reduces_health_when_no_energy` (energy=0, damage=30 → health 70)
- [ ] Write `test_take_damage_drains_energy_before_health` (energy=50, damage=30 → energy 20, health 100)
- [ ] Write `test_take_damage_spills_over_from_energy_to_health` (energy=10, damage=30 → energy 0, health 80)
- [ ] Write `test_take_damage_blocked_when_invincible` (invincible=true → health unchanged)
- [ ] Write `test_take_damage_sets_blood_flag` (blood flag set true after damage)
- [ ] Write `test_take_damage_does_not_set_blood_when_invincible` (blood remains false)
- [ ] Write `test_invincibility_timer_increments_while_invincible`
      — set `invincibleTimer=0`, `blood=false`, call `_handle_timers(0.1)`, assert timer ~0.1
      — NOTE: delta must keep `invincibleTimer < invincibleTime (3)` to avoid playerSprite access
- [ ] Write `test_invincibility_timer_resets_after_duration`
      — assign `stub_sprite = AnimatedSprite2D.new()` to `_char.playerSprite` BEFORE calling `_handle_timers`
      — set `invincibleTimer=3.1`, `blood=false`, call `_handle_timers(0.0)`
      — assert `invincible == false` and `invincibleTimer == 0`
      — call `stub_sprite.free()` in cleanup

## Test File: tests/test_tween_script.gd

- [ ] Create `tests/test_tween_script.gd` extending `GutTest`
- [ ] Implement `before_each` — instantiate `generic_tween_script.gd` via `load().new()`
- [ ] Implement `after_each` — call `_tween.free()`
- [ ] Write `test_change_x_direction_toggles_positive_to_negative` (1 → -1)
- [ ] Write `test_change_x_direction_toggles_negative_to_positive` (-1 → 1)
- [ ] Write `test_change_x_direction_noop_when_zero` (0 → 0)
- [ ] Write `test_change_y_direction_toggles_positive_to_negative` (1 → -1)
- [ ] Write `test_change_y_direction_toggles_negative_to_positive` (-1 → 1)
- [ ] Write `test_change_y_direction_noop_when_zero` (0 → 0)
- [ ] Write `test_set_initial_movement_computes_correct_target_x`
      (origin Vector2(50,50), distanceX=100, directionX=1 → movementPosition.x == 150)

## Test File: tests/test_bullet_behaviour.gd

- [ ] Create `tests/test_bullet_behaviour.gd` extending `GutTest`
- [ ] Write `test_power_zero_scale_constant` — assert expected Vector2(0.2, 0.2) matches L24 values
- [ ] Write `test_power_one_scale_constant` — assert expected Vector2(0.21, 0.22) matches L26 values
- [ ] Write `test_damage_with_power_bonus_calculation`
      — verify `damage + (5 * power)` for power 0, 1, 2 gives 30, 35, 40 (mirrors L80 formula)

## CI Workflow

- [ ] Create `.github/workflows/` directory
- [ ] Create `.github/workflows/tests.yml` with trigger on `push` to `main` and `pull_request`
- [ ] Workflow step: `actions/checkout@v4` with `submodules: recursive`
- [ ] Workflow step: download and install Godot 4.3-stable Linux headless binary
- [ ] Workflow step: run `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gprefix=test_ -gsuffix=.gd -gexit`
- [ ] Verify workflow exits non-zero on test failure (GUT's `-gexit` flag)

## Documentation

- [ ] Add "Running Tests" section to `README.md` with the `godot --headless` command
- [ ] Document the prerequisite (Godot 4.x on PATH)
- [ ] Mention that tests can also be run from inside the Godot editor via the GUT panel

## Acceptance Verification

- [ ] At least 15 unit tests total across all test files
- [ ] All tests pass headlessly: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gprefix=test_ -gsuffix=.gd -gexit`
- [ ] GitHub Actions workflow runs green on a push to `main`
- [ ] No test calls `_handle_timers` with `invincibleTimer > invincibleTime` unless `playerSprite` is assigned
- [ ] No test calls any method that accesses `get_tree()` or `bloodParticle_scene` without scene-tree setup
