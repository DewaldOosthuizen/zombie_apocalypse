# Proposal: Fix camelCase property references in test_character_behaviour.gd

## Problem

`tests/test_character_behaviour.gd` assigns and reads three properties using camelCase names:

- `invincibleTimer`
- `flickerTimer`
- `playerSprite`

None of these names exist in `scripts/generic_character_behaviour.gd`. The canonical snake_case
names defined there are:

- `invincible_timer` (line 50)
- `flicker_timer` (line 48)
- `player_sprite` (line 29)

GDScript dynamic typing silently creates orphan properties on the object when you assign to an
undefined name. This means every assertion in the two affected tests reads back the orphan value,
never the real game state. The tests pass but prove nothing. This is a silent correctness defect
that produces false confidence in coverage.

## Affected Lines

File: tests/test_character_behaviour.gd

| Line | Wrong name          | Correct name        |
|------|---------------------|---------------------|
|  60  | `invincibleTimer`   | `invincible_timer`  |
|  61  | `flickerTimer`      | `flicker_timer`     |
|  65  | `invincibleTimer`   | `invincible_timer`  |
|  66  | `invincibleTimer`   | `invincible_timer`  |
|  71  | `playerSprite`      | `player_sprite`     |
|  73  | `invincibleTimer`   | `invincible_timer`  |
|  79  | `invincibleTimer`   | `invincible_timer`  |

## Solution

Replace every camelCase reference in the test file with its canonical snake_case counterpart.
No changes to any source script are required.

### test_invincibility_timer_increments_while_invincible (lines 56-66)

Before:
```gdscript
_char.invincible = true
_char.invincibleTimer = 0.0
_char.flickerTimer = 0.0
_char.blood = false
_char._handle_timers(0.1)
assert_almost_eq(_char.invincibleTimer, 0.1, 0.001,
    "invincibleTimer should increment by delta each frame")
```

After:
```gdscript
_char.invincible = true
_char.invincible_timer = 0.0
_char.flicker_timer = 0.0
_char.blood = false
_char._handle_timers(0.1)
assert_almost_eq(_char.invincible_timer, 0.1, 0.001,
    "invincible_timer should increment by delta each frame")
```

### test_invincibility_timer_resets_after_duration (lines 68-81)

Before:
```gdscript
var stub_sprite = AnimatedSprite2D.new()
_char.playerSprite = stub_sprite
_char.invincible = true
_char.invincibleTimer = 3.1
_char.flickerTimer = 0.0
_char.blood = false
_char._handle_timers(0.0)
assert_false(_char.invincible,
    "invincible must be cleared once invincibleTimer exceeds invincibleTime")
assert_eq(_char.invincibleTimer, 0,
    "invincibleTimer must reset to 0 after expiry")
stub_sprite.free()
```

After:
```gdscript
var stub_sprite = AnimatedSprite2D.new()
_char.player_sprite = stub_sprite
_char.invincible = true
_char.invincible_timer = 3.1
_char.flicker_timer = 0.0
_char.blood = false
_char._handle_timers(0.0)
assert_false(_char.invincible,
    "invincible must be cleared once invincible_timer exceeds invincible_time")
assert_eq(_char.invincible_timer, 0,
    "invincible_timer must reset to 0 after expiry")
stub_sprite.free()
```

## Audit Note

A full audit of `tests/test_character_behaviour.gd` found no other camelCase property
mismatches beyond the seven occurrences listed above. All other property accesses
(`health`, `energy`, `invincible`, `blood`) match the canonical names in the source.

## Out of Scope

- No changes to `scripts/generic_character_behaviour.gd` or any other source file.
- No new tests are required; fixing the names makes the existing tests meaningful.
