# Remove Hardcoded Local Filesystem Paths Leaked in export_presets.cfg

## Overview

`export_presets.cfg` contains two hardcoded absolute export paths that expose the developer's
OS username, home directory layout, and Dropbox account structure to anyone who clones the
repository. The repository is public on GitHub, meaning this is an active personal information
disclosure. Export preset files are intended to capture platform configuration (texture formats,
architecture flags, etc.) — not machine-specific output locations. Both paths must be cleared
and a `.gitignore` rule (in a new `.gitignore` file, which does not yet exist in this repo)
must prevent future contributors from re-committing their own paths. A CI lint step should
additionally reject commits that contain absolute home-directory paths.

Note on credentials: the exposed Dropbox path may reveal folder structure used to access
credentials or sensitive personal files. Reviewing and rotating any credentials stored under
that path is an operational action for Dewald — it is not an implementable code task and is
not assigned as a developer task below.

---

## Issues

### Issue 1 — Hardcoded absolute path in Linux/X11 export preset

**File:** `export_presets.cfg` (line 10)

**Problem:** The `export_path` value encodes the developer's username, home directory, and
Dropbox folder hierarchy. Any visitor to the public repository can read this information
immediately.

```ini
; Before (line 10)
export_path="/home/dewald/Dewald/Dropbox/Work/Personal/Godot/Game Files/Game Executables/retro_mashup/retro_mashup.x86_64"

; After
export_path=""
```

---

### Issue 2 — Hardcoded absolute path in Windows Desktop export preset

**File:** `export_presets.cfg` (line 35)

**Problem:** Same disclosure as Issue 1 — the Windows export path also encodes the developer's
local username and Dropbox path.

```ini
; Before (line 35)
export_path="/home/dewald/Dewald/Dropbox/Work/Personal/Godot/Game Files/Game Executables/retro_mashup/retro_mashup.exe"

; After
export_path=""
```

---

### Issue 3 — No .gitignore exists; export_presets.cfg is fully tracked with no guard

**File:** `.gitignore` (does not yet exist — must be created from scratch)

**Problem:** The repository has no `.gitignore` file. `export_presets.cfg` is tracked by git
with no exclusion rule. Every contributor who opens the project in Godot and exports will
commit their own machine-specific paths if the file remains tracked. The safest long-term
posture is to add `export_presets.cfg` to a new `.gitignore` so that local export
configurations are never committed again.

```gitignore
# After (new file .gitignore)
# Godot export configuration — contains machine-specific output paths.
# Each contributor configures their own export targets locally.
export_presets.cfg
```

If the team ever needs to track non-sensitive preset settings (texture flags, architecture
options) in version control, the `export_path` lines should be stripped via a `.gitattributes`
clean filter instead of tracking the raw file.

---

### Issue 4 — No CI guard against future absolute home-directory paths in tracked files

**File:** `.github/workflows/lint-paths.yml` (does not yet exist — must be created)
**File:** `.pre-commit-config.yaml` (does not yet exist — optional but recommended)

**Problem:** Without an automated check, the same class of leak can recur silently any time
a contributor commits a config file containing `/home/<user>/` or `C:\Users\` patterns.

```yaml
# After: .github/workflows/lint-paths.yml
name: Lint — no absolute home paths

on: [push, pull_request]

jobs:
  check-home-paths:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Reject absolute home-directory paths in tracked files
        run: |
          if git grep -rE '(/home/[^/]+/|C:\\Users\\[^\\]+\\)' -- ':!*.md' ':!openspec/'; then
            echo "ERROR: Absolute home-directory path detected in a tracked file."
            exit 1
          fi
```

```yaml
# After: .pre-commit-config.yaml (optional local guard)
repos:
  - repo: local
    hooks:
      - id: no-home-paths
        name: No absolute home-directory paths
        language: pygrep
        entry: '(/home/[^/]+/|C:\\Users\\[^\\]+\\)'
        exclude: '^(.*\.md|openspec/).*'
```
