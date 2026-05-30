# Tasks: Issue #30

## Workflow — Godot Version Alignment
- [ ] In `.github/workflows/tests.yml`, change the wget URL from `Godot_v4.3-stable_linux.x86_64.zip` to `Godot_v4.6-stable_linux.x86_64.zip`
- [ ] In the same step, update the `sudo mv` source from `Godot_v4.3-stable_linux.x86_64` to `Godot_v4.6-stable_linux.x86_64`

## Workflow — Binary Caching
- [ ] Add an `actions/cache@v4` step before the `Install Godot 4` step with `path: /usr/local/bin/godot` and `key: godot-4.6-stable`
- [ ] Wrap the download, unzip, mv, and chmod commands inside `if [ ! -f /usr/local/bin/godot ]; then ... fi` to skip on cache hit

## Workflow — Asset Import Step
- [ ] Add a new step named `Import project assets` between the install step and `Run GUT tests headlessly`:
  ```yaml
  - name: Import project assets
    run: godot --headless --editor --quit || true
  ```

## README — CI Badge
- [ ] After the opening description paragraph in `README.md` (after the line ending "...from spreading."), add the GUT Tests badge:
  ```markdown
  [![GUT Tests](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml/badge.svg)](https://github.com/DewaldOosthuizen/zombie_apocalypse/actions/workflows/tests.yml)
  ```

## Verification
- [ ] Confirm `project.godot` `config/features` version matches the Godot version in `tests.yml` after the change
- [ ] Trigger the workflow manually via `workflow_dispatch` and verify it completes without import-related errors
- [ ] Confirm the CI badge renders correctly on the GitHub repository README page
