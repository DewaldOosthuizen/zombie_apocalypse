#!/usr/bin/env bash
# download_gut.sh — Idempotent script to download the Godot 4 headless binary
# for running GUT tests locally.  Detects OS/arch, downloads the correct build
# from the official Godot release page, installs it to ./bin/godot (relative to
# the repo root), makes it executable, and prints the absolute path so callers
# can use it directly:
#
#   GODOT=$(bash scripts/download_gut.sh)
#   "$GODOT" --headless -s addons/gut/addons/gut/gut_cmdln.gd ...

set -euo pipefail

GODOT_VERSION="4.6-stable"
INSTALL_DIR="$(cd "$(dirname "$0")/.." && pwd)/bin"
GODOT_BIN="$INSTALL_DIR/godot"

# ------------------------------------------------------------------
# Already installed?
# ------------------------------------------------------------------
if [ -x "$GODOT_BIN" ]; then
    echo "$GODOT_BIN"
    exit 0
fi

mkdir -p "$INSTALL_DIR"

# ------------------------------------------------------------------
# Detect OS / architecture
# ------------------------------------------------------------------
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64)  PLATFORM="linux.x86_64" ;;
            aarch64) PLATFORM="linux.arm64" ;;
            *)
                echo "ERROR: Unsupported Linux architecture: $ARCH" >&2
                exit 1
                ;;
        esac
        ;;
    Darwin)
        # macOS — Godot ships a universal .dmg; we grab the zip variant
        PLATFORM="macos.universal"
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS" >&2
        exit 1
        ;;
esac

ZIP_NAME="Godot_v${GODOT_VERSION}_${PLATFORM}.zip"
DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/${ZIP_NAME}"

TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT

echo "Downloading Godot ${GODOT_VERSION} for ${PLATFORM}..." >&2
curl -fsSL -o "$TMPDIR_WORK/$ZIP_NAME" "$DOWNLOAD_URL"

echo "Extracting..." >&2
unzip -q "$TMPDIR_WORK/$ZIP_NAME" -d "$TMPDIR_WORK"

# The extracted binary name varies slightly by platform
EXTRACTED_BIN="$(find "$TMPDIR_WORK" -maxdepth 2 -type f -name "Godot_v*" | head -1)"

if [ -z "$EXTRACTED_BIN" ]; then
    echo "ERROR: Could not find Godot binary in archive" >&2
    exit 1
fi

cp "$EXTRACTED_BIN" "$GODOT_BIN"
chmod +x "$GODOT_BIN"

echo "Godot installed to: $GODOT_BIN" >&2
echo "$GODOT_BIN"
