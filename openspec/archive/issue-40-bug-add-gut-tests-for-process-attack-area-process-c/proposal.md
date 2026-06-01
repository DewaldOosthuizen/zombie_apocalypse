## Overview
The combat damage dispatch paths in `generic_character_behaviour.gd` — `_process_attack_area()` (line 261), `_process_character_area()` (line 289), and `_apply_incoming_damage()` (line 278) — have zero GUT test coverage. These methods contain multi-branch conditional logic involving group membership checks, action flags, daze/invincibility guards, and the `break_object()` side effect on bricks. A regression in any branch would be silent until manual playtesting. The proposed solution is to extend the existing `tests/test_character_behaviour.gd` suite with at least six new GUT test cases that exercise every significant branch of `_apply_incoming_damage`, and to add a local helper script (`scripts/download_gut.sh`) so an agent or developer can bootstrap the GUT binary without committing it to the repository.

## Issues

### Issue 1
**File:** `tests/test_character_behaviour.gd`
**Problem:** The file covers `_take_damage`, `_shoot_bullet`, and timer mechanics but contains no tests for `_apply_incoming_damage`, `_process_attack_area`, or `_process_character_area`. Incorrect behaviour in these paths — e.g. daze guard being skipped, wrong damage value selected, or invincibility bypassed — produces no test failure.
**Fix:** Add the following test cases using GUT's stub/double pattern or lightweight inner-class fakes:
1. `test_apply_incoming_damage_reduces_health_when_action1_active` — parent.action1 = true, target not dazed; assert health decreases by action1_damage.
2. `test_apply_incoming_damage_blocked_when_target_is_dazed` — dazed = true; assert health unchanged.
3. `test_apply_incoming_damage_blocked_when_parent_health_zero` — parent.health = 0; assert health unchanged.
4. `test_apply_incoming_damage_uses_action2_damage` — parent.action2 = true; assert health decreases by action2_damage.
5. `test_apply_incoming_damage_uses_action3_damage` — parent.action3 = true; assert health decreases by action3_damage.
6. `test_apply_incoming_damage_no_damage_when_attacker_has_zero_health` — attacker health = 0; assert target health unchanged.

Each test constructs minimal stub objects that carry only the properties accessed by the method under test (health, action1/2/3, action1/2/3_damage, dazed, invincible, energy).

### Issue 2
**File:** `scripts/download_gut.sh` (new file)
**Problem:** The acceptance criteria require a script that an agent can execute to download the GUT binary locally so tests can be run outside the Godot editor. No such script exists.
**Fix:** Create `scripts/download_gut.sh`. The script must: detect the OS, download the correct Godot 4 headless binary from the official GitHub release, make it executable, and print the path. It must be idempotent (skip download if binary already present). Add `/usr/local/bin/godot` and any local download target path to `.gitignore`.

### Issue 3
**File:** `.github/workflows/tests.yml`
**Problem:** The workflow currently triggers on every push/PR touching `.gd` or `tests/**` files. The acceptance criteria state that GUT tests must remain manually triggered only, due to run time length.
**Fix:** Remove the `push` and `pull_request` triggers, keeping only `workflow_dispatch`. Add a comment in the workflow file explaining the decision: GUT tests require Godot headless startup (~2–5 min per run) and are therefore gated to manual dispatch only to avoid blocking CI on every commit.
