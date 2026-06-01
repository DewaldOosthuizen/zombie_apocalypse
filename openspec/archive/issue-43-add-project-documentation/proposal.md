## Overview

The project currently has no structured location for architectural decision records or design rationale. Key decisions — such as the Godot 3-to-4 migration, the generic behaviour script architecture, the multi-character design, and the GUT testing approach — are either scattered across README.md and CHANGELOG.md or completely undocumented. This change introduces a `docs/add/` directory (Architectural Design Decisions) at the repository root and populates it with ADDs covering all major design choices, while also updating existing documentation files to cross-reference the new docs structure.

## Issues

### Issue 1
**File:** `README.md`
**Problem:** The README contains inline migration notes and a controls reference but lacks any pointer to deeper design documentation or ADDs. There is no `docs/` folder referenced anywhere in the project.
**Fix:** Add a "Documentation" section near the top of README.md that links to `docs/add/` and briefly describes the ADD convention so contributors know where to look for design rationale.

### Issue 2
**File:** `CHANGELOG.md`
**Problem:** The CHANGELOG records what changed but never records why key decisions were made (e.g. why Godot 4 was chosen over staying on Godot 3, why a generic base-script pattern was adopted). Readers cannot trace design intent from this file.
**Fix:** Add a short "Architecture" note under the relevant version entries pointing to the corresponding ADD documents in `docs/add/`.

### Issue 3
**File:** `.github/copilot-instructions.md`
**Problem:** The Copilot instructions document repository structure but make no mention of the `docs/add/` folder or the ADD convention. Future AI agents and contributors will be unaware of where design decisions live.
**Fix:** Add a "Documentation" subsection under "Repository Structure" that describes `docs/add/` and instructs agents to consult ADDs before making architectural changes.

### Issue 4
**File:** `docs/add/add-001-godot4-migration.md` (new file)
**Problem:** The decision to migrate from Godot 3 to Godot 4 is currently only summarised in one line of CHANGELOG.md with no rationale, trade-off analysis, or consequences documented.
**Fix:** Create ADD-001 documenting the context (Godot 3 EOL, modern API needs), the decision (migrate to Godot 4), alternatives considered (stay on Godot 3, rewrite in a different engine), and consequences (migration warnings are expected and listed as normal in copilot-instructions.md).

### Issue 5
**File:** `docs/add/add-002-generic-behaviour-scripts.md` (new file)
**Problem:** The pattern of using shared `generic_*` base scripts (generic_character_behaviour.gd, generic_bullet_behaviour.gd, generic_level_script.gd, generic_tween_script.gd) is a deliberate architectural choice but is completely undocumented. Developers extending the game do not know why this pattern was chosen or how to follow it.
**Fix:** Create ADD-002 documenting the context (multiple characters needing shared physics and combat logic), the decision (extract shared behaviour into generic base scripts extended per character), alternatives considered (duplicating logic per character, using composition nodes), and consequences (new characters must extend the appropriate generic script).

### Issue 6
**File:** `docs/add/add-003-multi-character-design.md` (new file)
**Problem:** The multi-character design (Robot, Male Ninja, Adventure Girl) and the World_Scene acting as the character-switching controller is undocumented. It is unclear why characters share an input map or why the World_Scene owns the switch logic.
**Fix:** Create ADD-003 documenting the context (player variety goal), the decision (single World_Scene controls character switching via Tab key, shared input map across characters), alternatives considered (per-character scenes with no central controller, network multiplayer model), and consequences (Tab switch key is a global constant; all characters must register their scene with World_Scene).

### Issue 7
**File:** `docs/add/add-004-gut-testing-approach.md` (new file)
**Problem:** The choice of GUT (Godot Unit Testing) as the test framework and the CI workflow configuration are not explained anywhere. Developers do not know why GUT was preferred over other testing approaches, or why the CI only triggers on `.gd` file changes.
**Fix:** Create ADD-004 documenting the context (need for headless CI-compatible testing in Godot), the decision (GUT via addons/gut, GitHub Actions workflow triggering on .gd and tests/ changes), alternatives considered (manual-only testing, custom test runner), and consequences (GUT must be kept as a submodule/addon; CI job has a 90-minute timeout as documented in README).

### Issue 8
**File:** `docs/add/README.md` (new file)
**Problem:** No index exists to orient readers entering the `docs/add/` directory for the first time.
**Fix:** Create a README index listing all ADDs with their title, status, and a one-line summary so contributors can scan decisions quickly.
