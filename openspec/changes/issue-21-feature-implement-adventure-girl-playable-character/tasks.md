# Tasks: FEATURE — Implement Adventure Girl Playable Character Scene

## Scene File

- [ ] Create directory `scenes/characters/adventure_girl/`
- [ ] Copy `scenes/characters/ninja/Character_Scene.tscn` as the starting template into `scenes/characters/adventure_girl/Character_Scene.tscn`
- [ ] Remove SpriteFrames entry `female_ninja_jump_glide` (no Adventure Girl asset)
- [ ] Remove SpriteFrames entry `male_ninja_jump_glide` (no Adventure Girl asset)
- [ ] Remove SpriteFrames entry `female_ninja_walk` (Adventure Girl uses run, not walk)
- [ ] Remove SpriteFrames entry `male_ninja_walk` (Adventure Girl uses run, not walk)
- [ ] Rename all remaining `female_ninja_` SpriteFrames entries to `female_adventure_girl_`
- [ ] Rename all remaining `male_ninja_` SpriteFrames entries to `male_adventure_girl_`
- [ ] Add SpriteFrames entry `female_adventure_girl_run` backed by `res://resources/characters/adventure_girl/png/Run (N).png` (frames 1–8)
- [ ] Add SpriteFrames entry `male_adventure_girl_run` backed by `res://resources/characters/adventure_girl/png/Run (N).png` (frames 1–8)
- [ ] Update all `female_adventure_girl_dead` frame textures to point to `res://resources/characters/adventure_girl/png/Dead (N).png` (frames 1–10)
- [ ] Update all `female_adventure_girl_idle` frame textures to point to `res://resources/characters/adventure_girl/png/Idle (N).png` (frames 1–10)
- [ ] Update all `female_adventure_girl_jump` frame textures to point to `res://resources/characters/adventure_girl/png/Jump (N).png` (frames 1–10)
- [ ] Update all `female_adventure_girl_melee` frame textures to point to `res://resources/characters/adventure_girl/png/Melee (N).png` (frames 1–7)
- [ ] Update all `female_adventure_girl_shoot` frame textures to point to `res://resources/characters/adventure_girl/png/Shoot (N).png` (frames 1–3)
- [ ] Update all `female_adventure_girl_slide` frame textures to point to `res://resources/characters/adventure_girl/png/Slide (N).png` (frames 1–5)
- [ ] Apply the same texture updates for all `male_adventure_girl_*` entries (same asset files — sprite sheet is gender-neutral)
- [ ] Verify the final SpriteFrames block contains exactly 14 named entries (7 states × 2 gender prefixes) and none of: jump_melee, jump_shoot, run_shoot, walk, jump_glide
- [ ] Update the AnimatedSprite script reference in the scene from the ninja inline script to `res://scripts/adventure_girl.gd`

## Character Script

- [ ] Create `scripts/adventure_girl.gd` extending `res://scripts/generic_character_behaviour.gd`
- [ ] In `_ready()` set `type = "adventure_girl"` and `gender = "female"`, then call `._ready()`
- [ ] Override `control_character(delta)` to handle: shoot (action_1), melee (action_2), slide (action_3), jump, move_left, move_right, respawn, idle, dead
- [ ] In the shoot branch: use `jump` animation (not `jump_shoot`) when `currentJumpCount > 0` — Adventure Girl has no jump_shoot asset
- [ ] In the melee branch: use `jump` animation (not `jump_melee`) when `currentJumpCount > 0` — Adventure Girl has no jump_melee asset
- [ ] In the movement branches: call `_change_sprite_animation("run")` where the ninja/robot use `"walk"` — Adventure Girl has no walk asset
- [ ] Confirm no call to `_change_sprite_animation` emits a state name not present in the 14-entry SpriteFrames block

## Level Integration

- [ ] Inspect `scenes/World_Scene.tscn` and `scripts/generic_level_script.gd` to identify how Robot and Ninja are registered in the character-selection mechanism
- [ ] Add `scenes/characters/adventure_girl/Character_Scene.tscn` to the same character roster using the established registration pattern
- [ ] Verify Adventure Girl appears in the in-game character selection UI

## Documentation

- [ ] Update `README.md` characters table: change Adventure Girl status from `Work in progress` to `Playable`
- [ ] Fill in the Adventure Girl controls block in README.md if it contains placeholder text

## Tests

- [ ] Create `tests/test_adventure_girl.gd` as a GUT test scene
- [ ] Add test: `_ready()` sets `type` to `"adventure_girl"`
- [ ] Add test: `_ready()` sets `gender` to `"female"`
- [ ] Add test: shooting while jumping calls `_change_sprite_animation("jump")` not `"jump_shoot"`
- [ ] Add test: melee while jumping calls `_change_sprite_animation("jump")` not `"jump_melee"`
- [ ] Add test: horizontal movement calls `_change_sprite_animation("run")` not `"walk"`

## Verification

- [ ] Open `scenes/characters/adventure_girl/Character_Scene.tscn` in Godot 4 — confirm no errors on load
- [ ] Play all seven animation states in the AnimatedSprite preview — confirm each resolves without "Animation not found" warnings
- [ ] Confirm none of the following animation names appear in the scene file: `jump_melee`, `jump_shoot`, `run_shoot`, `walk`, `jump_glide`
- [ ] Run GUT test suite — all tests green
