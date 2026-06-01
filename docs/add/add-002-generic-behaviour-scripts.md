# ADD-002: Generic Behaviour Scripts Architecture

**Status:** Accepted

## Context

The game features multiple playable characters (Robot, Male Ninja, Adventure Girl) and multiple
enemy types (Zombies, mechanical Saws). Each character and enemy shares a significant amount of
behaviour: movement physics, animation state machines, collision handling, health management,
and combat logic. Without a shared base, each character script would duplicate this logic,
making maintenance error-prone and inconsistent across characters.

A design pattern was needed to centralise shared logic while allowing individual characters to
override or extend behaviour with their unique abilities (e.g. the Male Ninja's glide, the
Robot's shooting focus).

## Decision

Implement a set of `generic_*` base scripts that encapsulate shared behaviour:

- `scripts/generic_character_behaviour.gd` — Core character physics, movement, animation states,
  health, and combat logic. All playable character scripts extend this.
- `scripts/generic_bullet_behaviour.gd` — Projectile physics and lifetime management shared by
  all ranged attack implementations.
- `scripts/generic_level_script.gd` — Level setup, spawn management, and level-completion logic
  shared across Level_1 and Level_2 scenes.
- `scripts/generic_tween_script.gd` — Reusable animation utilities using Godot 4's `create_tween()`
  pattern, shared across scenes that need animated transitions.

Character-specific scripts `extend` the relevant generic base and override only what differs.

## Alternatives Considered

1. **Copy-paste per character**: Simple initially but leads to divergence and bugs as shared
   logic must be updated in multiple places. Rejected.

2. **Composition via autoload singletons**: Could work for some shared state but does not fit
   Godot's node-based inheritance model well for per-instance character behaviour. Rejected.

3. **Single monolithic character script with flags**: A single script with if-statements per
   character type. Makes the script unwieldy and harder to extend with new characters. Rejected.

4. **Godot 4 native class system with `class_name`**: Complementary to the chosen approach.
   `class_name` declarations are used where appropriate so Godot's type system can reference
   base classes explicitly.

## Consequences

- Adding a new character requires creating a script that `extends generic_character_behaviour`
  and overriding only the character-specific methods.
- Bugs in shared logic need only be fixed once in the generic script.
- The generic scripts are tightly coupled to Godot 4 APIs; they cannot be back-ported to Godot 3.
- New contributors need to understand the inheritance chain before modifying character behaviour.
- Some Godot 4 migration warnings (e.g. `velocity` redefinition) surface in the generic base
  script and affect all characters that extend it.
