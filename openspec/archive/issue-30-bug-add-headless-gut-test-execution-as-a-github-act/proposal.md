# Proposal: Issue #30 — Headless GUT Test Execution via GitHub Actions

## Overview

The repository already has `.github/workflows/tests.yml` (the GUT Tests workflow), but it installs Godot 4.3-stable while `project.godot` declares `config/features=PackedStringArray("4.6")`. This version mismatch means the workflow runs tests against the wrong engine, risking false passes or cryptic failures. Additionally, the workflow lacks a Godot binary cache (causing a slow cold download on every manual trigger), skips the mandatory asset-import step that must precede test execution, and `README.md` has no CI badge linking to the workflow result. The fix is to update the workflow to use Godot 4.6-stable, add binary caching, add the asset-import step, and add a CI badge to the README.

## Issues

### Issue 1
**File:** `.github/workflows/tests.yml`
**Problem:** The `Install Godot 4` step downloads `Godot_v4.3-stable_linux.x86_64.zip`, but `project.godot` line 1 declares `config/features=PackedStringArray("4.6")`. Running tests with a mismatched engine version can silently hide bugs or produce incorrect results.
**Fix:** Change the download URL and binary name from `4.3-stable` to `4.6-stable` (`Godot_v4.6-stable_linux.x86_64.zip` / `Godot_v4.6-stable_linux.x86_64`) so the workflow engine matches the project configuration.

### Issue 2
**File:** `.github/workflows/tests.yml`
**Problem:** There is no `actions/cache` step for the Godot binary. Every `workflow_dispatch` trigger re-downloads the ~90 MB Godot zip, making manual runs unnecessarily slow and bandwidth-heavy.
**Fix:** Add an `actions/cache@v4` step before the install step, keyed on `godot-4.6-stable` with `path: /usr/local/bin/godot`. Wrap the download+move commands in `if [ ! -f /usr/local/bin/godot ]` so they are skipped on a cache hit.

### Issue 3
**File:** `.github/workflows/tests.yml`
**Problem:** The workflow goes directly from installing Godot to running GUT tests without importing project assets first. Godot 4 requires a headless editor import pass (`godot --headless --editor --quit`) before scripts and scenes can be loaded in `--headless` script mode. Skipping it can cause test failures unrelated to actual code bugs.
**Fix:** Insert a dedicated `Import project assets` step between the install step and the `Run GUT tests headlessly` step:
```yaml
- name: Import project assets
  run: godot --headless --editor --quit || true
```
The `|| true` prevents the step from failing on the expected non-zero exit Godot emits when quitting from `--editor` mode.

### Issue 4
**File:** `README.md`
**Problem:** `README.md` has no CI badge. There is no visible link to the GUT Tests workflow run history, making it hard for contributors to find test status at a glance.
**Fix:** Add a GitHub Actions badge for the `GUT Tests` workflow after the opening description paragraph:
```markdown
[![GUT Tests](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml/badge.svg)](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml)
```
