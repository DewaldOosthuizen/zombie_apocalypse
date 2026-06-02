# Zombie Apocalypse
Zombie Apocalypse is created with Godot 4. A 2D game where the player can play with multiple characters to try and stop a zombie apocalypse 
from spreading.

[![GUT Tests](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml/badge.svg)](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml)

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RVJC5VUM5ZEW8&source=url)

## Requirements
- Godot 4.x or later

## Documentation

Architecture Decision Documents (ADDs) capture significant design and technical decisions:

- [docs/add/README.md](docs/add/README.md) — ADD index
- [CHANGELOG.md](CHANGELOG.md) — release history and unreleased changes
- [ADD-001: Godot 4 Migration](docs/add/add-001-godot4-migration.md)
- [ADD-002: Generic Behaviour Scripts](docs/add/add-002-generic-behaviour-scripts.md)
- [ADD-003: Multi-Character World Scene Design](docs/add/add-003-multi-character-design.md)
- [ADD-004: GUT Testing Approach](docs/add/add-004-gut-testing-approach.md)

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

### RANGER CONTROLS

* MOVEMENTS
  * A, LEFT ARROW        - move left
  * D, RIGHT ARROW       - move right
  * W, SPACE, UP ARROW   - jump
* ATTACKS
  * CTRL   - slide
  * Z      - shoot (female only; male falls back to female animation)
  * X      - melee (female only; male falls back to female animation)

## Characters

| Character      | Scene file present | Animations available                          | Status     |
|----------------|--------------------|-----------------------------------------------|------------|
| Robot          | Yes                | Full set                                      | Playable   |
| Female Ninja   | Yes                | Full set                                      | Playable   |
| Male Ninja     | Yes                | Full set                                      | Playable   |
| Female Ranger  | Yes                | Dead, Idle, Jump, Melee, Run, Shoot, Slide    | Playable   |
| Male Ranger    | Yes                | Dead, Idle, Jump, Run, Slide                  | Playable (Melee/Shoot fall back to female animations) |

![image](https://github.com/user-attachments/assets/d4f90d48-03f8-4e04-872e-633b077a57d1)


## Known Gaps / Roadmap

The following items are outstanding for the Ranger character and are tracked as open GitHub Issues:

- **Dedicated bullet scene** — Ranger currently borrows the Ninja bullet scene.
  A dedicated projectile scene and asset are needed.
- **Male Ranger Melee/Shoot animations** — No male-specific Melee or Shoot animation assets
  exist; the male ranger falls back to female animations for those actions.
- **Jump-shoot animation variant** — No jump-shoot animation exists yet; the character
  falls back to the ground-shoot animation in mid-air.
- **Jump-melee animation variant** — No jump-melee animation exists yet; the character
  falls back to the ground-melee animation in mid-air.

## Running Tests

This project uses [GUT](https://github.com/bitwes/Gut) for unit testing.

Prerequisites: Godot 4.x installed and on your PATH.

The preferred way to run GUT tests locally is via the convenience wrapper:

	bash scripts/run_gut_tests.sh

To use a specific Godot binary, set the `GODOT` environment variable:

	GODOT=/path/to/godot bash scripts/run_gut_tests.sh

Under the hood the script calls:

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

## Local Verification

`scripts/verify.sh` is the single entry point for replicating the full CI
pipeline locally. It runs gdlint, the absolute-path guard, and the GUT test
suite in sequence — exactly what CI does on every push and pull request.

### Prerequisites

- Python 3.x with gdtoolkit: `pip install gdtoolkit`
- Godot 4.x on your PATH, **or** let `scripts/download_gut.sh` auto-download
  it (the script places the binary at `./bin/godot`).

### Usage

Run the full CI-equivalent pipeline:

	bash scripts/verify.sh

To run only the lint and path checks (skip the Godot test run):

	SKIP_TESTS=1 bash scripts/verify.sh

### What each step does

1. **gdlint** (`scripts/` and `tests/`) — checks GDScript style and syntax,
   mirroring `.github/workflows/ci.yml`.
2. **Absolute-path guard** — scans source files for hard-coded home-directory
   paths, mirroring `.github/workflows/lint-paths.yml`.
3. **GUT headless tests** (via `scripts/run_gut_tests.sh`) — runs the full
   unit-test suite headlessly, mirroring `.github/workflows/tests.yml`.
