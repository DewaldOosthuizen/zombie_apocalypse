# Spec Approved

Approved at: 2026-06-01T15:04:48.180350+00:00

## Reviewer verdict

The codebase confirms all three bugs. The findings are accurate:

- Line 206: `get_tree().root.add_child(character_node)` fires before line 207: `_connect_to_character_signals(character_node)` — race confirmed.
- Lines 67-70: `character_node` is unconditionally assigned the Array result on line 67 before the empty check — clobber confirmed.
- Ninja scene lines 211-213: stat assignments commented out, serialised `ammo = 10` at line 1096 — fragile ownership confirmed.
- `generic_character_behaviour.gd` line 23 is indeed `@export var ammo = 0` — matches the proposal.

---

APPROVED
Reason: The proposal is technically accurate and complete. All three root causes are verified against the actual source: the signal-connect/add_child order inversion in `setup_character()` (lines 206-207 of World_Scene.tscn) is real and the proposed swap is the correct Godot 4 fix; the `_connect_signals()` unconditional Array assignment (line 67) is real and the local-variable guard is the correct minimal fix; the commented-out stat initialisations in both character scenes and the undocumented @export ownership are real, and offering Option A vs Option B with a required comment in `generic_character_behaviour.gd` line 23 is a well-scoped, non-prescriptive resolution. File paths and line numbers match the codebase exactly, the tasks are independently implementable and tightly scoped to the issue, and no scope creep or risky patterns are introduced.
