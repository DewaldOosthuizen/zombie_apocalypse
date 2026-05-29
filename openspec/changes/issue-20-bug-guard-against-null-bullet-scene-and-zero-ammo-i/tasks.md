# Tasks: Guard Against Null bullet_scene and Zero Ammo in _shoot_bullet

## Error Handling — _shoot_bullet guards

- [ ] Add `if bullet_scene == null:` guard at the top of `_shoot_bullet()` (file: `scripts/generic_character_behaviour.gd`, line 209)
- [ ] Inside the null guard call `push_error("_shoot_bullet called but bullet_scene is not assigned on " + name)` then `return` (file: `scripts/generic_character_behaviour.gd`)
- [ ] Add `if ammo <= 0: return` guard immediately after the null check, before any mutation (file: `scripts/generic_character_behaviour.gd`, line ~213)
- [ ] Verify `action1 = true` and `ammo -= 1` remain after both guards so they are only reached on a valid shoot (file: `scripts/generic_character_behaviour.gd`)

## Subclass Resilience — _ready() assertions

- [ ] Identify every character GDScript that extends `generic_character_behaviour.gd` and calls `_shoot_bullet` (Robot, Male Ninja, and any future shooters)
- [ ] Add `assert(bullet_scene != null, name + ": bullet_scene must be assigned before entering the scene tree")` in each such subclass `_ready()` function

## Testing — GUT test coverage

- [ ] Add test `test_shoot_bullet_with_null_bullet_scene_pushes_error_and_returns()` in `tests/test_character_behaviour.gd`
  - Set `_char.bullet_scene = null`
  - Call `_char._shoot_bullet(10)`
  - Assert `action1` remains false (method returned early)
  - Assert ammo was not decremented
- [ ] Add test `test_shoot_bullet_with_zero_ammo_is_noop()` in `tests/test_character_behaviour.gd`
  - Assign a valid (mocked/stubbed) `bullet_scene` to `_char`
  - Set `_char.ammo = 0`
  - Call `_char._shoot_bullet(10)`
  - Assert `action1` remains false
  - Assert `_char.ammo == 0` (not negative)
- [ ] Verify existing shoot tests still pass (no regression for normal shooting behaviour with valid `bullet_scene` and `ammo > 0`)

## Regression Check

- [ ] Manually verify Robot character shoots correctly after the guards are in place
- [ ] Manually verify Male Ninja character shoots correctly after the guards are in place
- [ ] Run full GUT test suite and confirm no new failures
