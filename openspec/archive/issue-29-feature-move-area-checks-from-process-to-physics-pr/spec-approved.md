# Spec Approved

Approved at: 2026-05-30T20:05:32.128861+00:00

## Reviewer verdict

The source code confirms everything. The proposal is accurate and complete. Here is the verdict:

APPROVED
Reason: The proposal is technically correct and the source code confirms all stated facts. `adventure_girl.gd` has `_process(_delta)` at lines 22-23 calling `_area_checks()`, `_physics_process` at lines 26-28 with `control_character` and `_start_process`, and `set_process(true)` at line 19 in `_ready`. The `_area_checks` implementation in `generic_character_behaviour.gd` at lines 235-264 gates damage on `action2`/`action3` flag state — it carries no render-frame frequency assumption and is safe to call once per physics tick. Removing `_process` entirely and placing `_area_checks()` first in `_physics_process` is the canonical Godot 4 fix: overlap data is fresh after the physics step, damage is applied at most once per tick (eliminating the double-damage risk), and the redundant `set_process(true)` cleanup is correctly scoped to this issue. The tasks are granular and independently implementable with no scope creep.
