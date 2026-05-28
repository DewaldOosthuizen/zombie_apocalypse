# Tasks: Remove Hardcoded Local Filesystem Paths Leaked in export_presets.cfg

## Security Fixes — export_presets.cfg

- [ ] Clear the Linux/X11 export path: set `export_path=""` on line 10 of `export_presets.cfg`
- [ ] Clear the Windows Desktop export path: set `export_path=""` on line 35 of `export_presets.cfg`

## Repository Configuration — .gitignore (new file)

- [ ] Create `.gitignore` at the repository root (file does not currently exist)
- [ ] Add an entry for `export_presets.cfg` to the new `.gitignore` with an explanatory comment
- [ ] Verify with `git check-ignore -v export_presets.cfg` that the file is now ignored

## CI — Path Lint Workflow (new file)

- [ ] Create `.github/workflows/lint-paths.yml` that runs on push and pull_request
- [ ] Add a step that uses `git grep -rE` to reject any tracked file containing `/home/<user>/` or `C:\Users\` patterns
- [ ] Exclude Markdown files and the `openspec/` directory from the grep to avoid false positives
- [ ] Confirm the workflow passes on a branch where both `export_path` values are empty

## Local Guard — Pre-Commit Hook (optional)

- [ ] Create `.pre-commit-config.yaml` at the repository root with a `pygrep` hook matching the same home-path pattern
- [ ] Document in `README.md` (or a `CONTRIBUTING.md`) that contributors should run `pre-commit install` after cloning

## Git History Cleanup

- [ ] Open a PR with the above changes for review; confirm old paths are no longer in the default branch HEAD
- [ ] Evaluate whether `git filter-repo --path export_presets.cfg --invert-paths` is needed to expunge the paths from full commit history, given the repository is public
- [ ] After history cleanup (if performed), force-push and notify all existing forks/clones

## Operational Action Item (Dewald — not a code task)

- Review and rotate any credentials or tokens stored under the now-exposed Dropbox path
  `~/Dewald/Dropbox/Work/Personal/Godot/Game Files/Game Executables/retro_mashup/`.
  This is a personal security review, not a developer PR task.
