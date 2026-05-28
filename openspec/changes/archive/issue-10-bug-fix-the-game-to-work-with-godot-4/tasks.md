# Tasks: BUG — Fix the game to work with Godot 4

## Project Setup

- [ ] Open the project in Godot 4.x editor to confirm which errors are reported in the
      Output panel at startup (file: `project.godot`)
- [ ] Note the Godot 4 version being used and record it in a comment at the top of
      `project.godot` for future reference

## Input Map Migration

- [ ] Open Project > Project Settings > Input Map in the Godot 4 editor
- [ ] Verify all eight actions are present: move_left, move_right, move_jump, tab,
      action_1, action_2, action_3, respawn (file: `project.godot`)
- [ ] Re-bind any action whose key is missing or incorrectly parsed from the Godot 3 format
- [ ] Save the project so Godot 4 rewrites input entries in its own serialisation format
      (file: `project.godot`, lines 31-74)

## Rendering Settings Cleanup

- [ ] Remove the following stale Godot 3 rendering keys from project.godot (lines 80-87):
      quality/intended_usage/framebuffer_allocation,
      quality/intended_usage/framebuffer_allocation.mobile,
      threads/thread_model,
      quality/subsurface_scattering/quality,
      environment/default_clear_color (file: `project.godot`)
- [ ] Replace with Godot 4 equivalent: set MSAA via
      `anti_aliasing/quality/msaa_2d=2` (file: `project.godot`)
- [ ] Confirm no rendering warnings appear in the Godot 4 editor after the change

## World Scene Script Fixes (Array API)

- [ ] Replace `end_door.empty()` with `end_door.is_empty()` in _connect_signals()
      (file: `scenes/World_Scene.tscn`, inline GDScript line 58)
- [ ] Replace `character_node.empty()` with `character_node.is_empty()` in
      _connect_signals() (file: `scenes/World_Scene.tscn`, inline GDScript line 66)
- [ ] Replace `currentLevel.empty()` with `currentLevel.is_empty()` in
      reset_current_scene() (file: `scenes/World_Scene.tscn`, inline GDScript line 152)
- [ ] Replace `levelNode.empty()` with `levelNode.is_empty()` in setup_level()
      (file: `scenes/World_Scene.tscn`, inline GDScript line 213)

## World Scene Script Fixes (Removed SceneTree API)

- [ ] Remove the `get_tree().call_deferred("set_current_scene", levelNode)` call and
      its surrounding levelNode variable block from setup_level()
      (file: `scenes/World_Scene.tscn`, inline GDScript lines 209-219)
- [ ] Confirm setup_level() still calls setup_character() after the removal
- [ ] Verify level transitions work end-to-end in the editor (play scene, reach end door)

## Tween Script Rewrite

- [ ] Add `var _active_tween: Tween = null` as a class-level variable
      (file: `scripts/generic_tween_script.gd`)
- [ ] Remove the `tweenNode` variable and all references to it
      (file: `scripts/generic_tween_script.gd`, line 3)
- [ ] Rewrite `_start_tween_process()` to use `get_tree().create_tween()` instead of
      a Tween node, chaining `.set_trans()` and `.set_ease()` on the PropertyTweener
      (file: `scripts/generic_tween_script.gd`, lines 17-29)
- [ ] Connect `_active_tween.finished` to `_on_tween_completed` with zero-argument
      Callable (file: `scripts/generic_tween_script.gd`)
- [ ] Update `_on_tween_completed` signature from `(object, key)` to `()` and set
      `_active_tween = null` at the end (file: `scripts/generic_tween_script.gd`,
      lines 53-57)
- [ ] Remove the guard `tweenNode and` from the `_start_tween_process` condition since
      `tweenNode` no longer exists (file: `scripts/generic_tween_script.gd`, line 18)
- [ ] Run `gdscript --check scripts/generic_tween_script.gd` or use the Godot 4 editor's
      script parser to verify no syntax errors remain

## Test Updates

- [ ] Update the `test_tween_script.gd` test for `_on_tween_completed` to call it with
      no arguments (file: `tests/test_tween_script.gd`)
- [ ] Add test `test_on_tween_completed_resets_running_flag` verifying tweenRunning is
      false after completion (file: `tests/test_tween_script.gd`)
- [ ] Add test `test_on_tween_completed_clears_active_tween` verifying _active_tween is
      null after completion (file: `tests/test_tween_script.gd`)
- [ ] Add test `test_on_tween_completed_updates_movement_position` verifying position
      target recalculates correctly after completion (file: `tests/test_tween_script.gd`)
- [ ] Run the full GUT test suite via the editor or CLI and confirm all tests pass

## Final Verification

- [ ] Launch the game from the editor (F5) with no errors in the Output panel
- [ ] Walk character to end door in Level 1 — confirm Level 2 loads without crash
- [ ] Switch character with Tab key — confirm character swap works without crash
- [ ] Die and wait for reload — confirm respawn works without crash
- [ ] Confirm floating platforms (tween objects) animate correctly in both levels
