# BUG: Fix the game to work with Godot 4

## Overview

The project is in a half-migrated state between Godot 3 and Godot 4. The GDScript files
already use Godot 4 syntax (CharacterBody2D, @export, Callable, instantiate()) but the
inlined GDScript inside World_Scene.tscn and the generic_tween_script.gd still contain
Godot 3 API calls. The result is a game that fails to run: the world scene crashes at
startup due to deprecated Array methods and an incorrect Tween API. Six distinct runtime
errors need to be resolved before the game is functional again.

---

## Issues

### Issue 1 — Array.empty() removed in Godot 4

**File:** `scenes/World_Scene.tscn` (inline GDScript — lines 58, 66, 152, 213)

**Problem:** `Array.empty()` was removed in Godot 4. The correct method is `Array.is_empty()`.
This is called in four places inside the world scene script that manages level transitions,
character connections, and scene resets.

**Fix:**
```gdscript
# Before (Godot 3)
if (!end_door.empty()):
if (!character_node.empty()):
if (!currentLevel.empty()):
if (!levelNode.empty()):

# After (Godot 4)
if (!end_door.is_empty()):
if (!character_node.is_empty()):
if (!currentLevel.is_empty()):
if (!levelNode.is_empty()):
```

---

### Issue 2 — SceneTree.call_deferred("set_current_scene") removed in Godot 4

**File:** `scenes/World_Scene.tscn` (inline GDScript — line 215)

**Problem:** `get_tree().call_deferred("set_current_scene", levelNode)` is a Godot 3
pattern. In Godot 4, `SceneTree.set_current_scene()` no longer exists. The correct
approach to change the active scene is `get_tree().change_scene_to_packed()` or simply
managing scene children directly (the game already does this via root.add_child).
Since levels are already tracked in a group ("level") and managed via add_child/queue_free,
this deferred call is both broken and unnecessary. The setup_level() function should
remove the call entirely and rely solely on the character setup that follows.

**Fix:**
```gdscript
# Before (Godot 3 — line 209-219)
func setup_level():
    print("== setup level ==")
    if (!self.is_queued_for_deletion()):
        var levelNode = get_tree().get_nodes_in_group("level")
        if (!levelNode.empty()):
            levelNode = levelNode.front()
            get_tree().call_deferred("set_current_scene", levelNode)

        # setup character for connected level
        setup_character()

# After (Godot 4)
func setup_level():
    print("== setup level ==")
    if (!self.is_queued_for_deletion()):
        setup_character()
```

---

### Issue 3 — Tween API completely rewritten in Godot 4

**File:** `scripts/generic_tween_script.gd` (lines 17-29, 53-57)

**Problem:** Godot 4 removed the Tween node and the `finished` signal on a
PropertyTweener. In Godot 4, Tween is created with `get_tree().create_tween()` and
returns a Tween object (not a node). Connecting to `tween.finished` is correct, but
`tweenNode` is referenced as if it is a node placed in the scene, which is no longer how
Tweens work. Additionally, `_on_tween_completed(object, key)` receives two arguments in
Godot 3 (object and key) but in Godot 4 the `finished` signal emits no arguments. The
tween property call also returns a PropertyTweener, not the Tween object — so chaining
`set_trans` and `set_ease` must be called on the PropertyTweener, not on the return of
`tween_property`. The entire tween management block needs to be rewritten for Godot 4.

**Fix:**
```gdscript
# Before (Godot 3 — lines 17-29)
func _start_tween_process():
    if (tweenNode and !tweenRunning && canTween):
        tweenRunning = true
        if (!tweenNode.is_connected("finished", Callable(self, "_on_tween_completed"))):
            tweenNode.connect("finished", Callable(self, "_on_tween_completed"))
        var tween = tweenNode.tween_property(self, "position", movementPosition, tweenDuration)
        tween.set_trans(trans_type)
        tween.set_ease(ease_type)

# Before (Godot 3 — lines 53-57)
func _on_tween_completed(object, key):
    _change_x_direction()
    _change_y_direction()
    movementPosition = self.position + Vector2(moveDistanceX * moveDirectionX, moveDistanceY * moveDirectionY)
    tweenRunning = false

# After (Godot 4)
var _active_tween: Tween = null

func _start_tween_process():
    if (!tweenRunning and canTween):
        tweenRunning = true
        _active_tween = get_tree().create_tween()
        _active_tween.tween_property(self, "position", movementPosition, tweenDuration) \
            .set_trans(trans_type) \
            .set_ease(ease_type)
        _active_tween.finished.connect(_on_tween_completed)

# After (Godot 4)
func _on_tween_completed():
    _change_x_direction()
    _change_y_direction()
    movementPosition = self.position + Vector2(moveDistanceX * moveDirectionX, moveDistanceY * moveDirectionY)
    tweenRunning = false
    _active_tween = null
```

---

### Issue 4 — project.godot uses Godot 3 InputEvent serialisation format

**File:** `project.godot` (lines 31-74)

**Problem:** All input action entries use the Godot 3 `Object(InputEventKey, ...)` string
serialisation format. Godot 4 uses a different resource format with `uid` and `keycode`
renamed to `physical_keycode` in some contexts. Godot 4's project converter will reject or
silently break these entries. The input map must be re-saved through the Godot 4 editor to
produce valid Godot 4 InputEvent resource syntax.

**Fix:**
Open the project in Godot 4, navigate to Project > Project Settings > Input Map, verify
all six actions (move_left, move_right, move_jump, tab, action_1, action_2, action_3,
respawn) are present and correctly bound, then save. Godot 4 will rewrite the input
section to its native format. No manual text edit is required or safe here.

---

### Issue 5 — project.godot rendering keys removed in Godot 4

**File:** `project.godot` (lines 80-87)

**Problem:** Several rendering keys in project.godot are Godot 3-only:
- `quality/intended_usage/framebuffer_allocation` and its `.mobile` variant were removed.
- `threads/thread_model` was replaced by a different threading model in Godot 4.
- `quality/subsurface_scattering/quality` moved to a different path.
- `environment/default_clear_color` syntax changed.

These stale keys do not cause a crash but generate editor warnings on every open and may
conflict with future Godot 4 rendering settings.

**Fix:**
```ini
# Before (Godot 3)
[rendering]
quality/intended_usage/framebuffer_allocation=0
quality/intended_usage/framebuffer_allocation.mobile=0
threads/thread_model=2
quality/subsurface_scattering/quality=2
environment/default_clear_color=Color( 0.284546, 0.286839, 0.289063, 1 )
quality/filters/msaa=4

# After (Godot 4 — keep only valid keys, let editor manage the rest)
[rendering]
anti_aliasing/quality/msaa_2d=2
```

---

### Issue 6 — test_tween_script.gd tests are invalidated by the Tween API rewrite

**File:** `tests/test_tween_script.gd`

**Problem:** The existing tween tests only cover direction-toggle and position-calculation
helpers, which survive the rewrite. However they do not cover `_on_tween_completed`, which
now has a changed signature (no arguments), and there is no coverage for the new
`_active_tween` lifecycle or the guard against double-starting a tween. After the fix the
test suite has a gap.

**Fix:**
Add three new test cases to `tests/test_tween_script.gd`:

```gdscript
func test_on_tween_completed_resets_running_flag():
    _tween.tweenRunning = true
    _tween._on_tween_completed()
    assert_false(_tween.tweenRunning,
        "tweenRunning must be cleared after tween completes")

func test_on_tween_completed_clears_active_tween():
    _tween._active_tween = null  # no real Tween needed for this check
    _tween.tweenRunning = true
    _tween._on_tween_completed()
    assert_null(_tween._active_tween,
        "_active_tween must be null after completion")

func test_on_tween_completed_updates_movement_position():
    _tween.moveDirectionX = 1
    _tween.moveDirectionY = 0
    _tween.moveDistanceX = 50
    _tween.moveDistanceY = 0
    _tween.position = Vector2(100, 100)
    _tween.tweenRunning = true
    _tween._on_tween_completed()
    assert_eq(_tween.movementPosition, Vector2(150, 100),
        "movement position must update after tween completes")
```
