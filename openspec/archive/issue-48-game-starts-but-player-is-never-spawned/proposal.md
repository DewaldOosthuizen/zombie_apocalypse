# Proposal: Issue #48 — Game starts but player is never spawned

## Overview

The game launches and the first level loads, but the player character is never available in
a playable state. Three bugs in the spawn chain are responsible: (1) `setup_character()` in
`scenes/World_Scene.tscn` calls `add_child` before connecting to the `character_ready` signal,
so the signal fires during `_ready()` before the World_Scene is listening and the spawn callback
is permanently missed; (2) `_connect_signals()` is called every frame from `_process()` and
silently overwrites `character_node` with an empty Array whenever the character is absent from
the scene tree, corrupting the node reference and causing subsequent Node operations to crash or
silently no-op; (3) starting stat initialisations (ammo, health, energy) are commented out in
both character scenes and the ownership of those values via serialised @export Inspector
properties is completely undocumented, making the mechanism fragile and invisible. The fix is:
swap the signal-connect and add_child call order in `setup_character()`, guard `_connect_signals()`
so it never overwrites `character_node` unless a node was actually found, and document (or restore)
the stat initialisation ownership in both the character scenes and the base class.

## Issues

### Issue 1 — Signal connection race in `setup_character()`

**File:** `scenes/World_Scene.tscn`

**Problem:** In `setup_character()` (lines 193–207), `get_tree().root.add_child(character_node)`
is called at line 206 before `_connect_to_character_signals(character_node)` at line 207. In
Godot 4, `add_child` triggers `_ready()` synchronously on the new child. The character's
`_ready()` calls `super._emit_character_ready()` (`generic_character_behaviour.gd` line 446),
which emits the `character_ready` signal. Because `_connect_to_character_signals` has not run
yet, the World_Scene callback `character_ready(character)` (line 163) is never invoked for this
spawn. As a result `character_stats["loaded"]` is never set via that path and saved stats are
never restored after a respawn.

**Fix:** Move the call to `_connect_to_character_signals(character_node)` to before
`get_tree().root.add_child(character_node)` inside `setup_character()`. The corrected order:

Before:
```gdscript
# scenes/World_Scene.tscn  ~line 205
character_node.add_child(camera)
get_tree().root.add_child(character_node)       # triggers _ready() → emits character_ready
_connect_to_character_signals(character_node)   # too late — signal already fired
```

After:
```gdscript
character_node.add_child(camera)
_connect_to_character_signals(character_node)   # connect first
get_tree().root.add_child(character_node)       # now _ready() fires with listener in place
```

### Issue 2 — `_connect_signals()` overwrites `character_node` with an Array every frame

**File:** `scenes/World_Scene.tscn`

**Problem:** `_connect_signals()` (lines 56–70) is called from `_process()` on every frame. It
does `character_node = get_tree().get_nodes_in_group("main_character")` unconditionally. When
the character is absent (during level transition or before first spawn), `get_nodes_in_group`
returns an empty Array and `character_node` is set to that Array. Any subsequent code that
treats `character_node` as a Node — e.g. `character_node.remove_child(camera)` (line 197),
`character_node.position` (line 189) — will either throw a runtime error or silently fail,
leaving the character absent from the scene.

**Fix:** Only reassign `character_node` when `get_nodes_in_group` returns a non-empty result.
Never clobber an existing valid node reference with an Array.

Before:
```gdscript
func _connect_signals():
    # ...
    character_node = get_tree().get_nodes_in_group("main_character")
    if (!character_node.is_empty()):
        character_node = character_node.front()
        _connect_to_character_signals(character_node)
```

After:
```gdscript
func _connect_signals():
    # ...
    var found = get_tree().get_nodes_in_group("main_character")
    if (!found.is_empty()):
        character_node = found.front()
        _connect_to_character_signals(character_node)
    # character_node is NOT touched when the group is empty
```

### Issue 3 — Starting stat initialisations commented out (ninja and robot)

**File:** `scenes/characters/ninja/Character_Scene.tscn`

**Problem:** The `_ready()` GDScript block (sub_resource id=1, lines ~211–213) has the starting
stat assignments commented out:
```gdscript
#   ammo = 10   # starting ammo
#   energy = 0  # starting energy
#   health = 100 # starting health
```
The same pattern exists in `scenes/characters/robot/Character_Scene.tscn`. Both characters
currently rely on serialised `@export` Inspector values in the .tscn files (`ammo = 10` at
line 1096 of the ninja scene) to override the base-class default of `ammo = 0`
(`scripts/generic_character_behaviour.gd` line 23). This mechanism is undocumented and fragile:
duplicating a scene, changing a value in the editor, or adding a new character without knowing
this convention will silently spawn a character with zero ammo and zero energy.

**Fix:** Choose and document one of two approaches (decision left to implementer):
- Option A — Restore explicit assignments in each character's `_ready()` so starting stats are
  owned by code and are self-documenting. Remove or update the serialised @export overrides to
  match.
- Option B — Keep the @export Inspector values as the source of truth but add a clear comment
  in each character scene's `_ready()` and in `scripts/generic_character_behaviour.gd`
  explaining that starting stats are intentionally set via the Inspector (@export) per-character
  and that `ammo = 0` in the base class is only a fallback default.

Regardless of which option is chosen, `scripts/generic_character_behaviour.gd` line 23 must
have a comment that explains the ownership model so future character authors follow the same
pattern.
