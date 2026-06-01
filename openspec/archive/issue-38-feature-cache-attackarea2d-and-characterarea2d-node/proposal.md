# Proposal: Cache AttackArea2D and CharacterArea2D nodes to eliminate per-frame scene-tree traversal

## Overview

`_process_attack_area()` (line 260) and `_process_character_area()` (line 288) in
`scripts/generic_character_behaviour.gd` each call `get_node(...)` on every physics frame to
obtain their respective `Area2D` nodes. Scene-tree lookups via `get_node()` walk the node tree
on each invocation rather than returning a cached reference; this overhead compounds for every
character instance in the scene. The fix is to add two typed instance variables —
`_attack_area_2d` and `_character_area_2d` — and populate them once inside the existing
`_setup_collision()` function (line 368), then replace the per-frame `get_node()` calls with
these cached references. This mirrors the established pattern used in `generic_bullet_behaviour.gd`.

## Issues

### Issue 1

**File:** `scripts/generic_character_behaviour.gd`

**Problem:**
`_process_attack_area()` at line 260 calls `get_node("AttackArea2D")` on every physics frame.
`_process_character_area()` at line 288 calls `get_node("CharacterArea2D")` on every physics frame.
Both are called together from `_area_checks()` (line 297–299), which fires every `_physics_process`
tick for every character node in the scene. There are no cached node variables for these two
`Area2D` children — the six collision-shape variables declared in the `# Collision objects` block
(lines 75–80) do not include the parent `Area2D` nodes themselves, only their child `CollisionShape2D`
nodes.

**Before (line 260):**
```gdscript
func _process_attack_area():
    var objects_in_attack_area = get_node("AttackArea2D").get_overlapping_bodies()
```

**Before (line 288):**
```gdscript
func _process_character_area():
    var areas_in_character_area = get_node("CharacterArea2D").get_overlapping_areas()
```

**Fix:**
1. Declare two typed instance variables in the `# Collision objects` block (after line 80):
```gdscript
var _attack_area_2d: Area2D
var _character_area_2d: Area2D
```

2. Populate them once at the start of `_setup_collision()` (line 368), before the existing
   collision-shape assignments:
```gdscript
func _setup_collision():
    _attack_area_2d    = get_node("AttackArea2D")
    _character_area_2d = get_node("CharacterArea2D")
    area_stand_collision_shape_2d = get_node("CharacterArea2D/StandCollisionShape2D")
    # ... rest unchanged
```

3. Replace `get_node(...)` in the two per-frame methods with the cached variables:
```gdscript
func _process_attack_area():
    var objects_in_attack_area = _attack_area_2d.get_overlapping_bodies()

func _process_character_area():
    var areas_in_character_area = _character_area_2d.get_overlapping_areas()
```
