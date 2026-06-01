# Zombie Apocalypse
Zombie Apocalypse is created with Godot 4. A 2D game where the player can play with multiple characters to try and stop a zombie apocalypse 
from spreading.

[![GUT Tests](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml/badge.svg)](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml)

## Requirements
- Godot 4.x or later

## Migration to Godot 4
This project has been updated from Godot 3 to Godot 4, including:
- Updated node types (CharacterBody2D, AnimatedSprite2D, Sprite2D)
- Modernized GDScript syntax (@export, @onready, Callable)
- Updated signal connections and scene instantiation
- DisplayServer API for fullscreen handling
- Updated Tween API

## CONTROLS
  * ESC: Exit fullscreen, if not in full screen then exit game
  * R: Respawn character at level starting position


### ROBOT CONTROLS
* MOVEMENTS
  * A, LEFT ARROW        - move left
  * D, RIGHT ARROW:      - move right
  * W, SPACE, UP ARROW:  - jump 
* ATTACKS
  * CTRL:    - slide
  * Z:       - shoot
  * X:       - melee

### MALE NINJA CONTROLS
* MOVEMENTS
  * A, LEFT ARROW                                 - move left
  * D, RIGHT ARROW:                               - move right
  * W, SPACE, UP ARROW:                           - jump 
  * (W, SPACE, UP ARROW) + (W, SPACE, UP ARROW):  - GLIDE 
* ATTACKS
  * CTRL:    - slide
  * Z:       - shoot
  * X:       - melee

### ADVENTURE GIRL CONTROLS

> **Note:** Adventure Girl is launchable but incomplete. She currently borrows
> the Ninja bullet scene and is missing a dedicated bullet scene, a jump-shoot
> animation variant, and a jump-melee animation variant.

* MOVEMENTS
  * A, LEFT ARROW        - move left
  * D, RIGHT ARROW       - move right
  * W, SPACE, UP ARROW   - jump
* ATTACKS
  * CTRL   - slide
  * Z      - shoot
  * X      - melee

## Characters

| Character      | Scene file present | Animations available                          | Status           |
|----------------|--------------------|-----------------------------------------------|------------------|
| Robot          | Yes                | Full set                                      | Playable         |
| Male Ninja     | Yes                | Full set                                      | Playable         |
| Adventure Girl | Yes                | Idle, Dead, Jump, Melee, Run, Shoot, Slide    | Playable (partial) |

![image](https://github.com/user-attachments/assets/d4f90d48-03f8-4e04-872e-633b077a57d1)

## Known Gaps / Roadmap

The following items are outstanding for Adventure Girl and are tracked as open GitHub Issues:

- **Dedicated bullet scene** — Adventure Girl currently borrows the Ninja bullet scene.
  A dedicated projectile scene and asset are needed. (Issue #41)
- **Jump-shoot animation variant** — No jump-shoot animation exists yet; the character
  falls back to the ground-shoot animation in mid-air. (Issue #42)
- **Jump-melee animation variant** — No jump-melee animation exists yet; the character
  falls back to the ground-melee animation in mid-air. (Issue #42)

## Running Tests

This project uses [GUT](https://github.com/bitwes/Gut) for unit testing.

Prerequisites: Godot 4.x installed and on your PATH.

Run all tests headlessly:

    godot --headless -s addons/gut/addons/gut/gut_cmdln.gd \
      -gdir=res://tests \
      -gprefix=test_ \
      -gsuffix=.gd \
      -gexit

Tests can also be run from inside the Godot editor via the GUT panel
(Scene > GUT > Run All).

The `.github/workflows/tests.yml` CI workflow runs automatically on push and
pull_request when any `.gd` source file or file under `tests/` is modified.
It can also be triggered manually from the GitHub Actions UI via
`workflow_dispatch`. A 90-minute job timeout bounds worst-case CI time.
