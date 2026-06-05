#!/usr/bin/env bash
#
# install.sh — pull drmrduck skills into Claude Code.
#
# Usage:
#   install.sh <skill|all> [--here]
#
#   <skill>   Name of a skill folder in this repo (e.g. favicon), or "all".
#   --here    Install into ./.claude/skills (this project only).
#             Default is ~/.claude/skills (every project on this machine).
#
# Works whether run from a clone or piped from curl:
#   curl -fsSL https://raw.githubusercontent.com/drmrduck/skills/main/install.sh | bash -s favicon
#
set -euo pipefail

REPO="drmrduck/skills"
RAW="https://raw.githubusercontent.com/$REPO/main"
TARBALL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"

WHAT="${1:-}"
SCOPE="$HOME/.claude/skills"
[ "${2:-}" = "--here" ] && SCOPE="$PWD/.claude/skills"
[ -z "$WHAT" ] && { echo "usage: install.sh <skill|all> [--here]" >&2; exit 1; }

mkdir -p "$SCOPE"

# Source skills from a local clone if present, else fetch the tarball.
SRC=""
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "$SELF_DIR" ] && [ -f "$SELF_DIR/install.sh" ] && [ -d "$SELF_DIR/favicon" ]; then
  SRC="$SELF_DIR"
else
  TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
  echo "Fetching $REPO ..." >&2
  curl -fsSL "$TARBALL" | tar -xz -C "$TMP"
  SRC="$(find "$TMP" -maxdepth 1 -type d -name 'skills-*' | head -1)"
  [ -n "$SRC" ] || { echo "could not download skills" >&2; exit 1; }
fi

install_one() {
  local name="$1"
  [ -f "$SRC/$name/SKILL.md" ] || { echo "no such skill: $name" >&2; return 1; }
  rm -rf "$SCOPE/$name"
  cp -R "$SRC/$name" "$SCOPE/$name"
  echo "✓ installed '$name' -> $SCOPE/$name" >&2
}

if [ "$WHAT" = "all" ]; then
  for d in "$SRC"/*/; do
    [ -f "${d}SKILL.md" ] && install_one "$(basename "$d")"
  done
else
  install_one "$WHAT"
fi

echo "Done. Restart Claude Code (or run /doctor) to load new skills." >&2
