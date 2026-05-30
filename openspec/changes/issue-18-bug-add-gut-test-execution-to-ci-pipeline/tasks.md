# Tasks: Issue #18

## Workflow Trigger Hardening

- [ ] Read lines 3-6 of `.github/workflows/tests.yml` and confirm the documented
  performance constraint (60+ min runtime) is understood before making any changes.
- [ ] Replace the `workflow_dispatch`-only `on:` block with a path-scoped trigger block
  that includes `workflow_dispatch`, `push: paths: ['**.gd', 'tests/**']`, and
  `pull_request: paths: ['**.gd', 'tests/**']`.
- [ ] Update the comment on lines 3-6 to reflect the chosen mitigation (path-scoped
  triggers + timeout) instead of describing the workflow as disabled.
- [ ] Add `timeout-minutes: 90` to the `test` job to bound worst-case CI time.

## Import Step Robustness

- [ ] Replace `godot --headless --editor --quit || true` with
  `godot --headless --editor --quit; true` and add an inline comment explaining that
  Godot 4 headless editor mode does not guarantee exit 0 on success, so the step is
  intentionally allowed to proceed past a non-zero exit.

## Verification

- [ ] Confirm the workflow file still correctly discovers all three test files by
  verifying the GUT command arguments:
  `-gdir=res://tests -gprefix=test_ -gsuffix=.gd -gexit` (already present on lines 38-42).
- [ ] Confirm Godot is pinned to `4.6-stable` in both the cache key (line 22) and the
  download URL (line 27) — both are already correct; document that any future version
  bump must update both locations atomically.
- [ ] Trigger the workflow manually via `workflow_dispatch` after the changes land to
  confirm the job completes within the 90-minute timeout and exits non-zero on a
  deliberately broken test (smoke test the `-gexit` flag).

## Documentation

- [ ] Update `README.md` if the `Running Tests` section implies the workflow only
  supports manual dispatch — revise to mention that the workflow also runs automatically
  on push/pull_request when GDScript or test files are modified.
