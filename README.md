# Zombie Apocalypse
Zombie Apocalypse is created with Godot 4. A 2D game where the player can play with multiple characters to try and stop a zombie apocalypse 
from spreading.

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

> **Status:** Work in progress — sprite assets are present
> (Idle, Dead, Jump, Melee, Run, Shoot, Slide) but no playable scene exists yet.
> Controls below reflect the shared input map and will be confirmed once the
> character scene is implemented.

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
| Adventure Girl | Yes                | Idle, Dead, Jump, Melee, Run, Shoot, Slide    | Playable         |

![image](https://github.com/user-attachments/assets/d4f90d48-03f8-4e04-872e-633b077a57d1)

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
