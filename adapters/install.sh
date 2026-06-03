#!/usr/bin/env bash
#
# epic-to-feature-specs — multi-agent install script
#
# Usage:
#   ./adapters/install.sh <agent> <target-project-dir>
#
# <agent>   = codex | gemini
# <target>  = absolute or relative path to the project that should get the skill
#
# What it does:
#   1. Creates <target>/.epic-to-feature-specs/ and copies WORKFLOW.md,
#      references/, and templates/ into it.
#   2. Wires up the agent's entry-point file:
#        codex  → <target>/AGENTS.md
#        gemini → <target>/GEMINI.md
#      If the file doesn't exist, copies the adapter snippet verbatim.
#      If it exists, appends the snippet between idempotent marker comments
#      (or updates the block in place if the markers are already there).

set -euo pipefail

# ---------- argument parsing ----------

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <codex|gemini> <target-project-dir>" >&2
  exit 64
fi

AGENT="$1"
TARGET="$2"

case "$AGENT" in
  codex)
    ENTRY_FILE_NAME="AGENTS.md"
    ;;
  gemini)
    ENTRY_FILE_NAME="GEMINI.md"
    ;;
  *)
    echo "error: unknown agent '$AGENT'. Expected 'codex' or 'gemini'." >&2
    exit 64
    ;;
esac

# ---------- resolve repo paths ----------

# This script lives at <repo>/adapters/install.sh. Resolve <repo> relative to
# the script's own location so it works no matter where the user runs it from.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

WORKFLOW_SRC="$SCRIPT_DIR/WORKFLOW.md"
REFERENCES_SRC="$REPO_ROOT/skills/epic-to-feature-specs/references"
TEMPLATES_SRC="$REPO_ROOT/skills/epic-to-feature-specs/templates"
ENTRY_SNIPPET_SRC="$SCRIPT_DIR/$AGENT/$ENTRY_FILE_NAME"

for path in "$WORKFLOW_SRC" "$REFERENCES_SRC" "$TEMPLATES_SRC" "$ENTRY_SNIPPET_SRC"; do
  if [[ ! -e "$path" ]]; then
    echo "error: expected source file/dir not found: $path" >&2
    echo "       (are you running this from a clean clone of the repo?)" >&2
    exit 1
  fi
done

# ---------- prepare target ----------

if [[ ! -d "$TARGET" ]]; then
  echo "error: target directory not found: $TARGET" >&2
  echo "       create it first, or pass an existing project path." >&2
  exit 1
fi

TARGET_ABS="$(cd -- "$TARGET" && pwd)"
SKILL_DIR="$TARGET_ABS/.epic-to-feature-specs"

echo "Installing epic-to-feature-specs ($AGENT adapter) → $TARGET_ABS"

mkdir -p "$SKILL_DIR"

# ---------- copy workflow + refs + templates ----------

# Overwrite to pick up upstream updates. References and templates are the
# source of truth; user edits in .epic-to-feature-specs/ will be clobbered.
cp -f "$WORKFLOW_SRC" "$SKILL_DIR/WORKFLOW.md"
echo "  wrote $SKILL_DIR/WORKFLOW.md"

rm -rf "$SKILL_DIR/references" "$SKILL_DIR/templates"
cp -R "$REFERENCES_SRC" "$SKILL_DIR/references"
cp -R "$TEMPLATES_SRC" "$SKILL_DIR/templates"
echo "  wrote $SKILL_DIR/references/ ($(ls "$SKILL_DIR/references" | wc -l | tr -d ' ') files)"
echo "  wrote $SKILL_DIR/templates/  ($(ls "$SKILL_DIR/templates"  | wc -l | tr -d ' ') files)"

# ---------- wire up the entry file ----------

ENTRY_FILE="$TARGET_ABS/$ENTRY_FILE_NAME"
BEGIN_MARKER="<!-- BEGIN: epic-to-feature-specs adapter — managed by install.sh, do not edit between markers -->"
END_MARKER="<!-- END: epic-to-feature-specs adapter -->"

# Strip the leading HTML comment from the adapter snippet (it's developer-facing
# instructions for the source file; once installed we don't need it).
SNIPPET_BODY="$(awk '
  BEGIN { in_comment = 0; printed_anything = 0 }
  /^<!--/  { in_comment = 1; next }
  in_comment && /-->/ { in_comment = 0; next }
  in_comment { next }
  { print; printed_anything = 1 }
' "$ENTRY_SNIPPET_SRC")"

MANAGED_BLOCK="$BEGIN_MARKER
$SNIPPET_BODY
$END_MARKER"

if [[ ! -f "$ENTRY_FILE" ]]; then
  # Brand-new entry file. Write the snippet body verbatim wrapped in markers.
  printf '%s\n' "$MANAGED_BLOCK" > "$ENTRY_FILE"
  echo "  created $ENTRY_FILE"
elif grep -qF "$BEGIN_MARKER" "$ENTRY_FILE"; then
  # Existing managed block — replace it in place.
  TMP_FILE="$(mktemp)"
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" -v block="$MANAGED_BLOCK" '
    BEGIN { in_block = 0; replaced = 0 }
    {
      if (in_block) {
        if (index($0, end)) { in_block = 0 }
        next
      }
      if (index($0, begin)) {
        print block
        in_block = 1
        replaced = 1
        next
      }
      print
    }
  ' "$ENTRY_FILE" > "$TMP_FILE"
  mv "$TMP_FILE" "$ENTRY_FILE"
  echo "  updated managed block in $ENTRY_FILE"
else
  # Existing entry file, no managed block yet — append.
  {
    printf '\n'
    printf '%s\n' "$MANAGED_BLOCK"
  } >> "$ENTRY_FILE"
  echo "  appended managed block to $ENTRY_FILE"
fi

# ---------- done ----------

cat <<EOF

Done. Open your project in $AGENT and try a phrase like:

  "Break down the epic at docs/epics/<your-epic>.md into feature specs."

The agent should read .epic-to-feature-specs/WORKFLOW.md and start by asking
which persona you are (PM / tech lead / solo dev).

If anything goes wrong, see adapters/$AGENT/INSTALL.md.
EOF
