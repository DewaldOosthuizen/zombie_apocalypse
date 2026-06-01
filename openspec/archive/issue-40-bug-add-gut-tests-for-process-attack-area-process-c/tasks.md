# Tasks: Issue #40

## Test Coverage — _apply_incoming_damage
- [ ] Add test: `test_apply_incoming_damage_reduces_health_when_action1_active` — parent.action1 = true, target not dazed; assert health reduced by action1_damage
- [ ] Add test: `test_apply_incoming_damage_blocked_when_target_is_dazed` — dazed = true; assert health unchanged
- [ ] Add test: `test_apply_incoming_damage_blocked_when_parent_health_zero` — parent.health = 0; assert health unchanged
- [ ] Add test: `test_apply_incoming_damage_uses_action2_damage` — parent.action2 = true; assert health reduced by action2_damage
- [ ] Add test: `test_apply_incoming_damage_uses_action3_damage` — parent.action3 = true; assert health reduced by action3_damage
- [ ] Add test: `test_apply_incoming_damage_no_damage_when_attacker_has_zero_health` — attacker (self) health = 0; assert target health unchanged

## Test Infrastructure
- [ ] Create `scripts/download_gut.sh` — idempotent script that downloads the Godot 4 headless binary for local GUT test execution
- [ ] Add Godot binary path(s) to `.gitignore` so the downloaded binary is never committed

## CI Workflow
- [ ] Edit `.github/workflows/tests.yml`: remove `push` and `pull_request` triggers, retain `workflow_dispatch` only
- [ ] Add a comment in `.github/workflows/tests.yml` explaining that GUT tests are manual-only due to Godot headless startup runtime

## Validation
- [ ] Run all existing tests and confirm no regressions
- [ ] Run the 6 new tests and confirm all pass
- [ ] Verify `scripts/download_gut.sh` executes successfully on a clean checkout
