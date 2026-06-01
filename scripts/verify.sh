#!/usr/bin/env bash
# verify.sh — run all local checks that mirror the CI workflows exactly.
#
# Checks performed (in order):
#   1. gdlint scripts/ tests/          (mirrors .github/workflows/ci.yml)
#   2. Absolute home-path guard        (mirrors .github/workflows/lint-paths.yml)
#   3. GUT headless tests              (mirrors .github/workflows/tests.yml)
#
# Usage:
#   bash scripts/verify.sh
#
# Prerequisites:
#   - Python 3.x with gdtoolkit: pip install gdtoolkit
#   - Godot 4.x on PATH, OR let this script auto-download it via
#     scripts/download_gut.sh (places the binary at ./bin/godot).
#
# To skip the GUT tests (lint + path check only):
#   SKIP_TESTS=1 bash scripts/verify.sh

set -euo pipefail

# Resolve repo root (script lives in scripts/)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SKIP_TESTS="${SKIP_TESTS:-0}"
PASS=0
FAIL=0

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

step_header() {
    echo ""
    echo "══════════════════════════════════════════════════════════"
    echo "  $1"
    echo "══════════════════════════════════════════════════════════"
}

step_pass() {
    echo "  ✓ $1"
    PASS=$((PASS + 1))
}

step_fail() {
    echo "  ✗ $1"
    FAIL=$((FAIL + 1))
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 1 — GDScript lint (ci.yml authoritative scope: scripts/ tests/)
# ─────────────────────────────────────────────────────────────────────────────
step_header "Step 1/3 — GDScript lint (gdlint scripts/ tests/)"

if ! command -v gdlint &>/dev/null; then
    echo "  ERROR: gdlint not found."
    echo "  Install with: pip install gdtoolkit"
    step_fail "gdlint: not installed"
else
    if gdlint scripts/ tests/; then
        step_pass "gdlint scripts/ tests/"
    else
        step_fail "gdlint scripts/ tests/"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 2 — Absolute home-path guard (lint-paths.yml)
# ─────────────────────────────────────────────────────────────────────────────
step_header "Step 2/3 — Absolute home-path check"

# Exact pattern from lint-paths.yml (one backslash removed per Bash layer)
PATH_PATTERN='(/home/[^/]+/|C:\\Users\\[^\\]+\\)'

if git grep -rE "$PATH_PATTERN" -- ':!*.md' ':!openspec/' 2>/dev/null; then
    echo "  ERROR: Absolute home-directory path detected in a tracked file."
    step_fail "Absolute path guard"
else
    step_pass "No absolute home-directory paths found"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Step 3 — GUT headless tests (tests.yml)
# ─────────────────────────────────────────────────────────────────────────────
step_header "Step 3/3 — GUT headless tests"

if [ "$SKIP_TESTS" = "1" ]; then
    echo "  Skipping GUT tests (SKIP_TESTS=1)."
    step_pass "GUT tests skipped by request"
else
    # Resolve godot binary: PATH first, then ./bin/godot, then auto-download.
    GODOT_BIN=""
    if command -v godot &>/dev/null; then
        GODOT_BIN="godot"
    elif [ -x "$REPO_ROOT/bin/godot" ]; then
        GODOT_BIN="$REPO_ROOT/bin/godot"
    else
        echo "  Godot not found on PATH or at ./bin/godot — running download_gut.sh ..."
        GODOT_BIN="$(bash "$REPO_ROOT/scripts/download_gut.sh")"
    fi

    echo "  Using Godot: $("$GODOT_BIN" --version 2>&1 | head -1)"

    # Import project assets (non-fatal; Godot 4 headless --editor --quit may
    # return non-zero even on success — same workaround as tests.yml)
    echo "  Importing project assets (godot --headless --editor --quit) ..."
    "$GODOT_BIN" --headless --editor --quit 2>/dev/null || true

    echo "  Running GUT tests ..."
    if GODOT="$GODOT_BIN" bash "$REPO_ROOT/scripts/run_gut_tests.sh"; then
        step_pass "GUT tests"
    else
        step_fail "GUT tests"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════════"
TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
    echo "  All $TOTAL checks passed. ✓"
    echo "══════════════════════════════════════════════════════════"
    exit 0
else
    echo "  $FAIL/$TOTAL check(s) FAILED. ✗"
    echo "══════════════════════════════════════════════════════════"
    exit 1
fi
