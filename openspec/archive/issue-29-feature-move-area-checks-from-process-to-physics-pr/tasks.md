# Tasks: Issue #29

## Code Change

- [ ] In `scripts/adventure_girl.gd`, delete the `_process(_delta)` function override (lines 22–24).
- [ ] In `scripts/adventure_girl.gd`, add `_area_checks()` as the first statement in `_physics_process` (before `control_character(delta)`).
- [ ] In `scripts/adventure_girl.gd` `_ready()`, remove the `set_process(true)` call (line 19) as it no longer serves a purpose once `_process` is removed.

## Verification

- [ ] Run existing GUT tests in `test_adventure_girl.gd` and confirm all pass without modification.
- [ ] Manually playtest: verify melee attacks (action_2) correctly apply damage to enemies in a single hit.
- [ ] Manually playtest: verify slide attacks (action_3) correctly apply damage without double-hit.
- [ ] Profile frame time before and after the change to confirm reduced CPU cost at high frame rates.

## Review

- [ ] Confirm no other script calls `set_process(true)` on `adventure_girl` externally, relying on the now-removed `_process` override.
- [ ] Confirm `generic_character_behaviour.gd` `_area_checks()` implementation (lines 235–264) has no side-effects that assume render-frame call frequency.
