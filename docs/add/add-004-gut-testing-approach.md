# ADD-004: GUT Testing Framework Choice

**Status:** Accepted

## Context

As the project grows in complexity — multiple characters, enemies, levels, and generic base
scripts — regression risk increases. Automated testing is needed to catch breakage in game
logic without requiring manual play-through after every change. The testing framework must:

- Work within the Godot engine environment (GDScript, scene tree, nodes).
- Support headless execution for CI (no display required).
- Integrate with GitHub Actions.
- Be maintained and compatible with Godot 4.

Standard software testing frameworks (pytest, Jest, JUnit) cannot test GDScript code because
they run outside the Godot runtime. A Godot-native testing solution is required.

## Decision

Adopt [GUT (Godot Unit Test)](https://github.com/bitwes/Gut) as the project's testing framework.

- Test files live under `tests/` with the `test_` prefix and `.gd` suffix.
- Tests are run headlessly via:
  `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gprefix=test_ -gsuffix=.gd -gexit`
- The GitHub Actions workflow (`.github/workflows/tests.yml`) runs the GUT suite automatically
  on push and pull_request when `.gd` source files or `tests/` are modified.
- The GUT panel in the Godot editor allows running tests interactively during development.

## Alternatives Considered

1. **No automated testing**: Rely entirely on manual play-testing. Acceptable for a solo hobby
   project at v0.1 but becomes unsustainable as the codebase and number of characters grows.
   Does not scale. Rejected as the long-term strategy.

2. **WAT (Godot Testing Framework)**: Another Godot-native testing tool. Less widely adopted
   than GUT, smaller community, fewer examples. GUT has more documentation, a larger user base,
   and an active Godot 4-compatible release. Rejected in favour of GUT.

3. **Custom test runner script**: Write a bespoke test runner in GDScript. Requires maintaining
   test infrastructure in addition to game code. Adds significant overhead. Rejected.

4. **gdUnit4**: A more feature-rich Godot 4 testing framework with IDE integration. A valid
   alternative; heavier setup than GUT. GUT was already familiar to the project maintainer and
   covers the project's needs. Could be reconsidered if GUT becomes unmaintained.

## Consequences

- GUT is a project dependency; the `addons/gut/` directory must be kept in version control.
- All new GDScript logic should be accompanied by GUT test cases under `tests/`.
- The CI badge in README reflects the GUT test run status.
- Headless Godot 4 must be available in the CI environment; the workflow downloads it if absent.
- GUT tests exercise GDScript logic but cannot fully replicate human play-testing for
  visual/physics correctness — both automated and manual testing remain necessary.
