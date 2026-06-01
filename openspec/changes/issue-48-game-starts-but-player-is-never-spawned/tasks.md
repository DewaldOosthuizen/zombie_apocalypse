# Tasks: Issue #48

## Bug Fix — Signal connection race (setup_character)

- [ ] In `scenes/World_Scene.tscn` `setup_character()`, move the call to
  `_connect_to_character_signals(character_node)` to BEFORE
  `get_tree().root.add_child(character_node)`.
- [ ] Verify that after the swap, running the game and observing the Godot output panel shows
  `== character ready ==` printed exactly once per spawn.

## Bug Fix — _connect_signals() Array clobber

- [ ] In `scenes/World_Scene.tscn` `_connect_signals()`, introduce a local variable `found`
  to hold the result of `get_tree().get_nodes_in_group("main_character")`.
- [ ] Only assign `character_node = found.front()` when `found` is non-empty; never assign
  `character_node` to the raw Array or to an empty Array.
- [ ] Confirm via a print statement (or debugger) that `character_node` retains its Node type
  during frames when no character is in the scene tree.

## Bug Fix / Documentation — Starting stat ownership

- [ ] Decide on Option A (restore explicit `_ready()` assignments) or Option B (document
  @export as source of truth) — record the decision as a comment in the affected files.
- [ ] If Option A: uncomment the stat assignments in `scenes/characters/ninja/Character_Scene.tscn`
  `_ready()` and in `scenes/characters/robot/Character_Scene.tscn` `_ready()`; verify the
  serialised @export values in both .tscn files are consistent with the code.
- [ ] If Option B: add an explanatory comment in each character scene's `_ready()` block and
  at `scripts/generic_character_behaviour.gd` line 23 (`@export var ammo = 0`) explaining
  that starting values are overridden per-character via the Inspector.
- [ ] Ensure `scripts/generic_character_behaviour.gd` line 23 has a comment that communicates
  the ownership model clearly for future character authors.

## Verification — Acceptance criteria

- [ ] Robot, Male Ninja, and Adventure Girl can each be spawned and controlled without errors
  in the Godot output panel.
- [ ] Player switching via Tab works correctly and the HUD updates after each switch.
- [ ] Player respawn via R restores the character at the level start position with correct stats.
- [ ] No "Invalid call" or type-mismatch errors appear in the Godot output panel during a full
  play session (spawn → play → die → respawn).
- [ ] `World_Scene.character_ready()` is confirmed to be called once per spawn (log or breakpoint).
