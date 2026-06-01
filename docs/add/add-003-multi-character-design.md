# ADD-003: Multi-Character World Scene Design

**Status:** Accepted

## Context

The game concept requires the player to be able to switch between multiple playable characters
(Robot, Female Ninja, Male Ninja, Female Ranger, Male Ranger) within a single game session to
stop the zombie apocalypse from spreading. Each character has distinct abilities and playstyles.
A mechanism was needed to:

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

The character roster is defined as an array of dictionaries in World_Scene, each entry specifying
`type`, `gender`, and `scene`. Adding a new character requires only adding an entry to this array
and providing the corresponding scene and script.

## Character Roster (as of ADD-003 v2)

| # | type     | gender | scene                                    |
|---|----------|--------|------------------------------------------|
| 0 | ninja    | female | scenes/characters/ninja/Character_Scene  |
| 1 | ninja    | male   | scenes/characters/ninja/Character_Scene  |
| 2 | robot    | male   | scenes/characters/robot/Character_Scene  |
| 3 | ranger   | female | scenes/characters/ranger/Character_Scene |
| 4 | ranger   | male   | scenes/characters/ranger/Character_Scene |

The Ninja scene serves both genders — the `gender` field drives which SpriteFrames animations
are played at runtime. The Ranger scene follows the same pattern.

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
- Adding a new character requires: a GDScript extending `generic_character_behaviour.gd`,
  a `.tscn` scene with SpriteFrames wired to the correct animation names, and an entry in
  the World_Scene character array.

## Change History

- **v1 (original):** Roster was Robot, Male Ninja, Adventure Girl.
- **v2:** Adventure Girl replaced by Female Ranger and Male Ranger. Scene and script renamed
  from `adventure_girl` to `ranger`. Female Ninja added as a distinct roster entry.
  Male Ranger lacks Melee/Shoot assets and falls back to female animations for those actions.
