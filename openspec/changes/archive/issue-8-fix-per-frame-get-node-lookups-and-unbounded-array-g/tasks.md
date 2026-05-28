# Tasks: Fix per-frame get_node() lookups and unbounded array growth

## A. generic_bullet_behaviour.gd — Node Caching

- [ ] A1. Remove the existing `var noValidCollision = []` declaration at line 12.
- [ ] A2. Add typed cached node declarations at the top of the script (after existing var block):
        var _area2d: Area2D
        var _collision_shape: CollisionShape2D
- [ ] A3. Add integer hit counter declaration replacing the array:
        var _non_brick_hit_count: int = 0
- [ ] A4. Add a `_ready()` function that caches both nodes:
        func _ready():
            _area2d = get_node("Area2D")
            _collision_shape = get_node("CollisionShape2D")
        Confirm the bullet scene has no existing _ready() that would conflict — if it does,
        append the two assignments into the existing body.
- [ ] A5. Update `_check_collision_objects()` (lines 74–81):
        Replace `get_node("Area2D")` with `_area2d`.
        Replace `get_node("CollisionShape2D")` with `_collision_shape`.
        Add an early `return` after `self.queue_free()` to avoid processing remaining bodies.

## B. generic_bullet_behaviour.gd — Unbounded Array Fix

- [ ] B1. Update `_remove_if_brick()` at line 71:
        Replace `noValidCollision.append(true)` with `_non_brick_hit_count += 1`.
- [ ] B2. Update despawn guard in `_animate_bullet()` at lines 35–36:
        Replace `if (noValidCollision.size() == 2):` with `if (_non_brick_hit_count >= 2):`.
        The >= operator ensures the guard fires even if a frame increments past 2 without
        stopping exactly on it.
- [ ] B3. Verify no other references to `noValidCollision` exist anywhere in the script
        (search for the identifier) — remove any found.

## C. generic_character_behaviour.gd — Node Caching

- [ ] C1. Add two typed cached node declarations in the Collision objects block
        (after line 72, alongside existing AreaStandCollisionShape2D etc.):
        var _attack_area: Area2D
        var _character_area: Area2D
- [ ] C2. Extend `_setup_collision()` (lines 324–331) to cache the parent Area2D nodes.
        Append after the existing get_node assignments (after line 330, before `_default_collision()`):
        _attack_area = get_node("AttackArea2D")
        _character_area = get_node("CharacterArea2D")
- [ ] C3. Update `_area_checks()` at line 232:
        Replace `get_node("AttackArea2D")` with `_attack_area`.
- [ ] C4. Update `_area_checks()` at line 248:
        Replace `get_node("CharacterArea2D")` with `_character_area`.
- [ ] C5. Confirm `_setup_collision()` is called before `_area_checks()` in every code path
        that exercises area checks (trace from _ready() or the equivalent entry point in
        subclasses that extend generic_character_behaviour).

## D. Verification

- [ ] D1. Open the project in Godot and run the scene — no script errors on startup.
- [ ] D2. Manual playtest: fire bullets at brick objects — bullets despawn on brick contact
        when power < 1; bullets break brick and continue when power >= 1.
- [ ] D3. Manual playtest: fire bullets at an enemy character — bullet despawns, enemy takes
        correct damage (damage + 5 * power).
- [ ] D4. Manual playtest: fire bullets along a wall surface so they repeatedly graze
        non-brick geometry — bullet despawns after exactly 2 non-brick contacts and does
        not leak (confirm in Godot Remote scene tree that no orphan bullet nodes remain).
- [ ] D5. Manual playtest: melee attack on enemy and brick — area checks still trigger
        correct damage and brick break behaviour, no null reference errors.
- [ ] D6. Open Godot built-in profiler. Spawn 20+ simultaneous bullets. Confirm the
        per-frame count of `get_node` calls is lower than before the change.
- [ ] D7. Confirm _non_brick_hit_count is not shared across bullet instances (each bullet
        is a separate scene instance, so the member variable is per-instance by default —
        verify no static keyword was accidentally introduced).

## E. Code Quality

- [ ] E1. Ensure all new variable names follow the existing naming conventions of the file
        (snake_case, leading underscore for private cached refs as introduced here).
- [ ] E2. Add a brief inline comment on each cached variable declaration explaining why it
        is cached (e.g. "# cached in _ready() to avoid per-frame scene tree traversal").
- [ ] E3. Run `godot --check-only` or equivalent static analysis if available in the project
        CI to confirm no GDScript parse errors are introduced.
