# ADD-001: Godot 3 to Godot 4 Migration

**Status:** Accepted

## Context

The Zombie Apocalypse project was originally developed using Godot 3. Godot 4 was released with
significant improvements including a rewritten rendering engine (Vulkan/OpenGL), a revamped
physics system, an updated GDScript 2.0 syntax, and long-term support commitments from the
Godot Foundation. The existing Godot 3 codebase used deprecated node types, legacy GDScript
syntax, and older API patterns that would become increasingly unsupported over time.

Key differences requiring migration work:
- `KinematicBody2D` replaced by `CharacterBody2D`
- `AnimatedSprite` replaced by `AnimatedSprite2D`
- `Sprite` replaced by `Sprite2D`
- GDScript now uses `@export`, `@onready` annotations
- Signal connections changed from `connect("signal", self, "method")` to `connect("signal", Callable(self, "method"))`
- `OS.set_window_fullscreen()` replaced by `DisplayServer` API
- `Tween` node replaced by `create_tween()` method pattern

## Decision

Migrate the entire project from Godot 3 to Godot 4, updating all node types, GDScript syntax,
signal connections, and API calls to match Godot 4 conventions. Accept that some migration
warnings will persist during the transition period as technical debt.

## Alternatives Considered

1. **Stay on Godot 3**: Would avoid migration effort but leaves the project on an unsupported
   engine version with no future improvements. Community and plugin support for Godot 3 is
   declining. Rejected.

2. **Partial migration (hybrid approach)**: Not feasible — Godot 4 is not backward compatible
   with Godot 3 scene and script formats. A full migration is required to run on Godot 4. Rejected.

3. **Full migration with zero warnings**: Ideal but impractical as a first step. Several Godot 3
   patterns produce migration warnings in Godot 4 that require deeper refactoring. Deferred to
   future cleanup work.

## Consequences

- The project runs on Godot 4.x and benefits from its improved renderer, physics, and tooling.
- Several expected runtime warnings remain (velocity redefinition, Particles2D rename, etc.)
  as documented in `.github/copilot-instructions.md`. These do not break gameplay.
- All new development must target Godot 4 APIs and GDScript 2.0 syntax.
- CI pipeline uses Godot 4 headless mode for automated testing.
- Future contributors must have Godot 4.x installed.
