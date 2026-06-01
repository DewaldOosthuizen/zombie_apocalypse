# Tasks: Issue #47

## Documentation — README.md

- [ ] Update the "Running Tests" section (around line 97) to reference `scripts/run_gut_tests.sh`
      as the preferred command for running GUT tests locally, retaining the raw `godot --headless`
      command as an explanatory example.
- [ ] Add a note in "Running Tests" about the `GODOT=/path/to/godot` environment variable override
      supported by `scripts/run_gut_tests.sh`.
- [ ] Add a "Local Verification" section to `README.md` after "Running Tests" with the following
      subsections:
      - Prerequisites: Python 3.x, `pip install gdtoolkit`, Godot 4.x on PATH or via
        `scripts/download_gut.sh`
      - Usage: `bash scripts/verify.sh` to run the full CI-equivalent pipeline
      - The `SKIP_TESTS=1` override: `SKIP_TESTS=1 bash scripts/verify.sh` to run lint and
        path checks only
      - A brief description of what each pipeline step does (gdlint, absolute-path guard,
        GUT tests via `scripts/run_gut_tests.sh`)
- [ ] Verify that no absolute home-directory paths are introduced by the README edits (to pass
      the `lint-paths.yml` CI workflow guard).
