# ADD-003: Multi-Character World Scene Design

**Status:** Accepted

## Context

The game concept requires the player to be able to switch between multiple playable characters
(Robot, Male Ninja, Adventure Girl) within a single game session to stop the zombie apocalypse
from spreading. Each character has distinct abilities and playstyles. A mechanism was needed to:

- Instantiate and manage multiple character scenes within the same level.
- Allow runtime switching between active characters (Tab key).
- Keep inactive characters present in the scene (so they can be switched back to).
- Share a common HUD (health bar, power bar) that updates to reflect the current active character.
- Persist character state (health, position) across switches within a session.

## Decision

Introduce `scenes/World_Scene.tscn` as the top-level game controller scene. World_Scene is
responsible for:

1. Loading and holding all character scenes as children.
2. Tracking which character is currently active and routing input to it.
3. Managing level transitions by unloading/loading level sub-scenes.
4. Updating the shared HUD to reflect the active character's stats.
5. Handling game-wide events (respawn via R key, exit via ESC).

Character scenes are instantiated at level start. Only the active character processes input and
physics; inactive characters are paused via `set_physics_process(false)` and `set_process_input(false)`.

## Alternatives Considered

1. **One scene per character with level duplication**: Each character gets its own copy of each
   level scene. Simple but causes massive duplication of level data and makes synchronising
   character states across scenes difficult. Rejected.

2. **Single character selection screen, one active character per run**: Player picks a character
   at the start and cannot switch mid-game. Loses the multi-character gameplay mechanic that is
   central to the game's design. Rejected.

3. **Autoload singleton as game controller**: Using a global script to manage character state.
   Works but breaks Godot's scene tree model and makes character nodes harder to inspect and
   debug in the editor. Rejected.

4. **Character switching via scene reload**: Reload the level scene with a different character
   each time the player switches. Causes visible loading delays and resets level state (enemy
   positions, destroyed blocks). Rejected.

## Consequences

- World_Scene is the authoritative entry point; `project.godot` sets `res://scenes/World_Scene.tscn`
  as the main scene.
- Character switching is seamless with no level reload.
- World_Scene script grows in complexity as the number of characters and levels increases.
- All character scenes must follow the interface expected by World_Scene (health signal,
  `respawn()` method, input action names from the shared input map).
- Adventure Girl is present in the design but her scene is still a work in progress; World_Scene
  must handle partially implemented character scenes gracefully.
