# Tasks: Issue #38

## Variable Declarations

- [ ] In `scripts/generic_character_behaviour.gd`, add `var _attack_area_2d: Area2D` to the `# Collision objects` block (after line 80)
- [ ] In `scripts/generic_character_behaviour.gd`, add `var _character_area_2d: Area2D` to the `# Collision objects` block (after the `_attack_area_2d` declaration)

## Node Caching in Setup

- [ ] In `_setup_collision()` (line 368), assign `_attack_area_2d = get_node("AttackArea2D")` as the first statement, before existing collision-shape assignments
- [ ] In `_setup_collision()` (line 368), assign `_character_area_2d = get_node("CharacterArea2D")` as the second statement, before existing collision-shape assignments

## Per-Frame Call Sites

- [ ] In `_process_attack_area()` (line 260), replace `get_node("AttackArea2D")` with `_attack_area_2d`
- [ ] In `_process_character_area()` (line 288), replace `get_node("CharacterArea2D")` with `_character_area_2d`

## Verification

- [ ] Run the full GUT test suite and confirm all existing tests pass with no regressions
- [ ] Manually verify Robot, Ninja, and Adventure Girl scenes load and area detection behaves correctly at runtime
