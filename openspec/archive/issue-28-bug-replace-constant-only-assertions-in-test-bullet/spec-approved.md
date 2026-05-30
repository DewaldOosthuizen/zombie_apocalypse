# Spec Approved

Approved at: 2026-05-30T19:35:45.495689+00:00

## Reviewer verdict

APPROVED
Reason: The proposal is technically accurate and well-grounded. Source line numbers match exactly — `_set_speed` at lines 49-51, power-branch scale assignments at 33-38, despawn guard at 45-46, and the damage expression at line 90 in `_check_collision_objects`. The `load("res://scripts/generic_bullet_behaviour.gd").new()` headless instantiation is safe because `_ready()` (which calls `get_node("Area2D")` and `get_node("CollisionShape2D")`) is only invoked when the node enters the scene tree — a bare `.new()` skips it, so `_set_speed` and direct property assertions work cleanly. The damage formula tests remain inline arithmetic rather than calling `_check_collision_objects` directly, but that is the correct trade-off since `_check_collision_objects` is scene-dependent (requires `_area2d`); the proposal correctly acknowledges this and defers full integration coverage to the `_get_scale_for_power` extraction task. The despawn threshold tests verify state (the counter value) rather than side-effects (`queue_free`), which is again the correct ceiling for headless testing and a meaningful improvement over the current tautologies. Tasks are granular, scoped to the issue, and follow the existing `test_character_behaviour.gd` pattern. No scope creep, no bad patterns, no security concerns.
