# Proposal: Issue #47 — Find a way to run all tests, lints locally

## Overview

The repository already has three helper scripts (`scripts/verify.sh`, `scripts/run_gut_tests.sh`,
`scripts/download_gut.sh`) that together replicate the full CI pipeline locally, but `README.md`
does not reference them. The existing "Running Tests" section documents only the raw
`godot --headless ...` command and omits `scripts/run_gut_tests.sh` entirely. The fix is to update
the "Running Tests" section to reference `scripts/run_gut_tests.sh`, and to add a new
"Local Verification" section that documents `scripts/verify.sh`, its prerequisites, and the
`SKIP_TESTS=1` override — giving contributors a single, discoverable entry point for local CI
replication.

## Issues

### Issue 1

**File:** `README.md`
**Problem:** The "Running Tests" section (lines 91–111) documents the raw
`godot --headless -s addons/gut/addons/gut/gut_cmdln.gd ...` command but does not mention
`scripts/run_gut_tests.sh`, the canonical wrapper that handles the same invocation and supports
the `GODOT=` env override. This leaves contributors unaware of the convenience script.
**Fix:** Update the "Running Tests" section to reference `scripts/run_gut_tests.sh` as the
preferred way to run tests, retaining the raw command as an explanatory aside. Add a note about
the `GODOT=/path/to/godot` environment variable override.

### Issue 2

**File:** `README.md`
**Problem:** There is no "Local Verification" section documenting `scripts/verify.sh`. Contributors
cannot discover that a single script exists to run gdlint, the absolute-path guard, and the GUT
test suite in sequence — mirroring what CI does on every push/PR.
**Fix:** Add a "Local Verification" section after "Running Tests" that covers:
- Prerequisites: Python 3.x, `pip install gdtoolkit`, Godot 4.x on PATH (or auto-downloaded via
  `scripts/download_gut.sh`)
- How to run `scripts/verify.sh` for a full CI-equivalent check
- The `SKIP_TESTS=1` env override to run lint and path checks only (skipping the Godot test run)
- What each step does (gdlint, absolute-path guard, GUT tests)
