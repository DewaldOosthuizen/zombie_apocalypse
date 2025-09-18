# Zombie Apocalypse - Godot 4 Game Development Instructions

Zombie Apocalypse is a 2D platformer game built with Godot 4. Players can choose between multiple characters (Robot, Male Ninja, Female Ninja) to fight zombies across different levels. The project has been migrated from Godot 3 to Godot 4 with modern GDScript syntax and updated node types.

ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap, Import, and Test the Project:
- Download Godot 4.3 or later:
  - `cd /tmp && wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip`
  - `cd /tmp && unzip -q Godot_v4.3-stable_linux.x86_64.zip`
  - `chmod +x /tmp/Godot_v4.3-stable_linux.x86_64`
- Import project resources:
  - `cd [project-root] && /tmp/Godot_v4.3-stable_linux.x86_64 --headless --import .` -- takes 5 seconds. NEVER CANCEL.
- Test the game runs:
  - `cd [project-root] && /tmp/Godot_v4.3-stable_linux.x86_64 --headless --quit` -- takes 1-2 seconds. NEVER CANCEL.

### Expected Build Behavior:
- NO TRADITIONAL BUILD SYSTEM: This project does not use npm, make, cmake, or traditional build tools
- Godot handles all building and compilation internally
- Resources are imported automatically when opening the project
- Expect Godot 3->4 migration warnings during import and execution (these are NORMAL and do not prevent gameplay)

### Expected Runtime Warnings (NORMAL - DO NOT FIX):
- "Parse Error: Member 'velocity' redefined" - Godot 4 migration issue in CharacterBody2D
- "Parse Error: Could not find base class 'Particles2D'" - Godot 4 renamed to GPUParticles2D/CPUParticles2D
- "Parse Error: Expected statement, found '.' instead" - Scene file parsing issues
- "Tween can't be created directly" - Godot 4 requires create_tween() method
- "Invalid call. Nonexistent function 'empty'" - Array method changes in Godot 4
- "RID leaked" and "ObjectDB instances leaked" - Common in headless mode

## Validation Scenarios

ALWAYS test functionality after making code changes:

### Manual Game Testing:
The game loads to Level 1 automatically with a character that can be controlled using:
- **Movement**: A/D or Arrow Keys (left/right), W/Space/Up Arrow (jump)
- **Combat**: Z (shoot), X (melee attack), Ctrl (slide)
- **Game**: ESC (exit), R (respawn), Tab (switch character)

### Complete End-to-End Test:
1. Import the project: `cd [project-root] && /tmp/Godot_v4.3-stable_linux.x86_64 --headless --import .`
2. Run game test: `cd [project-root] && /tmp/Godot_v4.3-stable_linux.x86_64 --headless --quit`
3. Verify output shows ":: started level 1 ::" which confirms successful level loading
4. For GUI testing, run with: `cd [project-root] && /tmp/Godot_v4.3-stable_linux.x86_64` (requires display)

### Known Limitations:
- The project contains migration issues from Godot 3 to Godot 4 that generate warnings but do not prevent gameplay
- Some scenes may fail to load properly in headless mode but work correctly in GUI mode
- Character and enemy scripts have syntax issues that need updating for full Godot 4 compatibility
- No automated tests exist - validation is done through manual play testing

## Common Tasks

### Repository Structure:
```
├── project.godot               # Main Godot project file
├── scenes/                     # Game scenes (.tscn files)
│   ├── World_Scene.tscn       # Main game scene (entry point)
│   ├── characters/            # Character scenes (Ninja, Robot)
│   ├── enemies/               # Enemy scenes (Zombies, Saws)
│   ├── environment/           # Environmental objects
│   ├── gui/                   # User interface elements
│   └── levels/                # Game levels (Level_1_Scene, Level_2_Scene)
├── scripts/                   # GDScript files (.gd)
│   ├── generic_character_behaviour.gd    # Base character logic
│   ├── generic_bullet_behaviour.gd      # Projectile physics
│   ├── generic_level_script.gd          # Level management
│   └── generic_tween_script.gd          # Animation utilities
├── resources/                 # Game assets
│   ├── characters/            # Character sprites and animations
│   ├── environment/           # Environment art (winter, desert, forest, etc.)
│   ├── hud/                   # UI graphics (health, power bars)
│   └── levels/                # Level tilesets
└── export_presets.cfg         # Export settings for Linux/Windows builds
```

### Key Files to Understand:
- `scenes/World_Scene.tscn` - Main game controller, handles character switching and level management
- `scripts/generic_character_behaviour.gd` - Core character physics, movement, and combat
- `project.godot` - Project configuration including input mappings and window settings
- Main scene launches at `res://scenes/World_Scene.tscn` as configured in project.godot

### Game Features:
- **Multi-character gameplay**: Robot (shooting focus), Male Ninja (gliding ability), Female Ninja
- **Combat system**: Melee attacks, ranged shooting, sliding attacks
- **Level progression**: Currently 2 levels with environmental hazards
- **Environmental interaction**: Destructible blocks, energy stones, health pickups
- **Enemy types**: Zombies with AI behavior, mechanical saws with movement patterns

### Development Workflow:
1. ALWAYS run import command after major changes: `/tmp/Godot_v4.3-stable_linux.x86_64 --headless --import .`
2. Test immediately after script changes: `/tmp/Godot_v4.3-stable_linux.x86_64 --headless --quit`
3. For scene/resource changes, preferably test with GUI: `/tmp/Godot_v4.3-stable_linux.x86_64`
4. Monitor console output for script errors and runtime warnings
5. Remember: Migration warnings are expected and do not indicate broken functionality

### Export and Distribution:
- Configured for Linux (.x86_64) and Windows (.exe) export
- Export presets are pre-configured in `export_presets.cfg`
- Use Godot's export system: Project > Export > Choose platform
- No additional build steps required beyond Godot's export process

## Troubleshooting

### Common Issues:
- **Import takes too long**: Normal for first import, subsequent imports are faster
- **Script errors about 'velocity'**: Expected Godot 4 migration issue, game still functions
- **Missing textures in headless mode**: Use GUI mode for visual validation
- **Tween-related errors**: Expected, use create_tween() in new code instead of Tween nodes

### File Modifications:
- When editing .gd scripts, always test with both import and run commands
- Scene (.tscn) files should be edited in Godot editor when possible
- Resource files (.png, .tres) require import after changes
- Project.godot changes require restart of Godot editor

### Performance Expectations:
- Import: ~5 seconds (with 2000+ resource files)
- Game initialization: ~1-2 seconds in headless mode
- Level loading: Instantaneous for included levels
- Memory usage: Lightweight, suitable for testing in CI environments