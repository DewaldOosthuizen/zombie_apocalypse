# Proposal: Fix per-frame get_node() lookups and unbounded array growth

## Problem

Two hot-path performance and correctness issues exist in the bullet and character scripts.

---

### Issue 1 — Per-frame get_node() traversal in generic_bullet_behaviour.gd

File: scripts/generic_bullet_behaviour.gd
Lines: 74–81 (_check_collision_objects)

Every physics frame, for every live bullet on screen, get_node() is called twice:

BEFORE (lines 74–81):
    func _check_collision_objects():
        var area = get_node("Area2D").get_overlapping_bodies()   # traverses scene tree
        if (area.size() != 0):
            for body in area:
                if (body.is_in_group("enemy_character")):
                    get_node("CollisionShape2D").disabled = true  # traverses scene tree again
                    body._take_damage(damage + (5 * power))
                    self.queue_free()

get_node() traverses the full scene tree on every invocation. With N bullets each
calling it twice per physics frame the cost is O(2N) tree traversals per frame. This
is measurably worse as bullet count grows.

---

### Issue 2 — Unbounded noValidCollision array growth in generic_bullet_behaviour.gd

File: scripts/generic_bullet_behaviour.gd
Lines: 12, 35–36, 71 (variable declaration, guard check, append)

The noValidCollision array is declared at line 12 and appended to unconditionally in
_remove_if_brick() at line 71. The despawn guard at lines 35–36 reads:

BEFORE (line 12):
    var noValidCollision = []

BEFORE (lines 35–36):
    if (noValidCollision.size() == 2):
        self.queue_free()

BEFORE (line 71):
    noValidCollision.append(true)

Two defects result:

a) If a bullet repeatedly grazes the same non-brick surface (e.g. slides along a wall),
   each physics frame appends a new entry. noValidCollision.size() grows past 2 without
   ever equalling 2 exactly, so the equality guard is bypassed and the bullet never
   despawns — it leaks into the scene indefinitely.

b) Even in the non-leaking case the array allocates heap memory on every append inside
   the physics loop, which is unnecessary given the logic only needs to count hits.

The fix is to replace the array with a plain integer counter and use >= instead of ==
for the guard.

---

### Issue 3 — Per-frame get_node() traversal in generic_character_behaviour.gd

File: scripts/generic_character_behaviour.gd
Lines: 232, 248 (_area_checks)

_area_checks() is called every frame for every character. It calls get_node() twice:

BEFORE (lines 232, 248):
    func _area_checks():
        var objectsInAttackArea = get_node("AttackArea2D").get_overlapping_bodies()
        ...
        var areasInCharacterArea = get_node("CharacterArea2D").get_overlapping_areas()

_setup_collision() at lines 324–331 already caches several child nodes into member
variables but does NOT cache the AttackArea2D and CharacterArea2D nodes themselves —
only their child CollisionShape2D nodes. The parent Area2D references are therefore
re-resolved on every call to _area_checks().

---

## Solution

### generic_bullet_behaviour.gd

1. Declare two cached node references and an integer counter at the top of the script
   (replacing noValidCollision):

AFTER (replace lines 4 and 12):
    var _area2d: Area2D          # cached in _ready()
    var _collision_shape: CollisionShape2D  # cached in _ready()
    var _non_brick_hit_count: int = 0

2. Add a _ready() function (or extend the existing one if present) to cache the nodes:

AFTER (new _ready() function):
    func _ready():
        _area2d = get_node("Area2D")
        _collision_shape = get_node("CollisionShape2D")

3. Update _check_collision_objects() to use the cached references:

AFTER (lines 74–81):
    func _check_collision_objects():
        var area = _area2d.get_overlapping_bodies()
        if (area.size() != 0):
            for body in area:
                if (body.is_in_group("enemy_character")):
                    _collision_shape.disabled = true
                    body._take_damage(damage + (5 * power))
                    self.queue_free()
                    return

4. Update _animate_bullet() despawn guard (line 35–36) to use the counter and >=:

AFTER (lines 34–36):
    if (_non_brick_hit_count >= 2):
        self.queue_free()

5. Update _remove_if_brick() to increment the counter instead of appending (line 71):

AFTER (line 71):
    _non_brick_hit_count += 1

---

### generic_character_behaviour.gd

1. Declare two new cached member variables alongside the existing collision shape
   variables (after line 72):

AFTER (new declarations after line 72):
    var _attack_area: Area2D      # cached in _setup_collision()
    var _character_area: Area2D   # cached in _setup_collision()

2. Extend _setup_collision() (lines 324–331) to cache the parent Area2D nodes:

AFTER (append to _setup_collision(), after line 330):
    _attack_area = get_node("AttackArea2D")
    _character_area = get_node("CharacterArea2D")

3. Update _area_checks() to use the cached references:

AFTER (lines 232, 248):
    func _area_checks():
        var objectsInAttackArea = _attack_area.get_overlapping_bodies()
        ...
        var areasInCharacterArea = _character_area.get_overlapping_areas()

---

## Acceptance Criteria

- All get_node() calls inside _process/_physics_process-driven functions are replaced
  with cached member variables set in _ready() or _setup_collision().
- noValidCollision array is removed and replaced with _non_brick_hit_count: int = 0.
- The despawn guard uses >= 2, not == 2, so bullets cannot skip past the threshold.
- Manual playtesting confirms bullet despawns on: brick hit (power < 1), enemy hit,
  and after 2 distinct or repeated non-brick surface contacts.
- Godot built-in profiler shows reduced per-frame get_node call count with 20+
  simultaneous bullets on screen.
