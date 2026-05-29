# Tasks: Fix camelCase property references in test_character_behaviour.gd

## Audit

- [ ] Read `scripts/generic_character_behaviour.gd` in full and list all `var` property names
      to confirm canonical snake_case names: `invincible_timer`, `flicker_timer`, `player_sprite`
- [ ] Scan `tests/test_character_behaviour.gd` for every property access and cross-reference
      against the canonical list — confirm exactly 7 mismatched references across lines 60, 61,
      65, 66, 71, 73, 79
- [ ] Verify no other test files under `tests/` reference camelCase variants of these names

## Code Changes — tests/test_character_behaviour.gd

- [ ] Line 57: Update stale inline comment that says `invincibleTimer` to `invincible_timer`
- [ ] Line 58: Update stale inline comment that says `invincibleTimer` to `invincible_timer`
- [ ] Line 60: Replace `_char.invincibleTimer = 0.0` with `_char.invincible_timer = 0.0`
- [ ] Line 61: Replace `_char.flickerTimer = 0.0` with `_char.flicker_timer = 0.0`
- [ ] Line 65: Replace `_char.invincibleTimer` (read in assert) with `_char.invincible_timer`
- [ ] Line 66: Update assertion message string from `invincibleTimer` to `invincible_timer`
- [ ] Line 69: Update stale inline comment that says `playerSprite` to `player_sprite`
- [ ] Line 71: Replace `_char.playerSprite = stub_sprite` with `_char.player_sprite = stub_sprite`
- [ ] Line 73: Replace `_char.invincibleTimer = 3.1` with `_char.invincible_timer = 3.1`
- [ ] Line 74: Replace `_char.flickerTimer = 0.0` with `_char.flicker_timer = 0.0`
- [ ] Line 78: Update assertion message string from `invincibleTimer` to `invincible_timer`
- [ ] Line 79: Replace `_char.invincibleTimer` (read in assert) with `_char.invincible_timer`
- [ ] Line 80: Update assertion message string from `invincibleTimer` to `invincible_timer`

## Verification

- [ ] Run GUT headlessly and confirm `test_invincibility_timer_increments_while_invincible` passes
- [ ] Run GUT headlessly and confirm `test_invincibility_timer_resets_after_duration` passes
- [ ] Confirm all other tests in `test_character_behaviour.gd` still pass (no regressions)
- [ ] Confirm zero orphan-property reads: no camelCase names remain in any file under `tests/`
- [ ] Confirm GUT output shows no unexpected passes caused by orphan-property reads

## Quality Gates

- [ ] Run gdlint on `tests/test_character_behaviour.gd` — zero new warnings
- [ ] No changes outside the `tests/` directory
