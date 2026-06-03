#!/usr/bin/env bash
# skill-gate: track-read.sh
# PostToolUse hook for Read — logs when critical skill files are read.
# Creates/updates a tracking file so check-gate.sh can enforce read-before-write.
#
# Tier 1 — base files (always required by check-gate.sh):
#   1. SKILL.md (the main skill instructions)
#   2. references/cutting-strategies.md
#   3. references/team-split-patterns.md
#   4. references/smart-checklist.md
#   5. templates/feature-spec.md
#
# Tier 2 — sub-spec files (required by check-gate.sh only when the Write target
#                          looks like a sub-spec — see check-gate.sh for matching):
#   6. references/sub-spec-cutting.md
#   7. references/plan-split-patterns.md
#   8. templates/sub-spec.md
#
# Fail-open: if anything goes wrong (no jq, bad JSON, etc.), exit 0 silently.

set -euo pipefail

# --- Fail-open guard ---
if ! command -v jq &>/dev/null; then
  exit 0
fi

# --- Read stdin ---
INPUT="$(cat)"

SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // empty')"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"

# If we couldn't parse session_id or file_path, nothing to do.
if [[ -z "$SESSION_ID" || -z "$FILE_PATH" ]]; then
  exit 0
fi

# --- Resolve anchors ---
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"

# If CLAUDE_PLUGIN_ROOT is not set, we can't anchor. Fail-open.
if [[ -z "$PLUGIN_ROOT" ]]; then
  exit 0
fi

# Normalize: remove trailing slash from plugin root for consistent matching
PLUGIN_ROOT="${PLUGIN_ROOT%/}"

# The skill files live under this path
SKILL_DIR="${PLUGIN_ROOT}/skills/epic-to-feature-specs"

# --- Check if this Read is relevant to our skill ---
if [[ "$FILE_PATH" != "${SKILL_DIR}"/* ]]; then
  exit 0
fi

# --- Tracking file ---
TRACK_FILE="/tmp/skill-gate-epic-specs-${SESSION_ID}.json"

# Create tracking file with all flags false if it doesn't exist yet.
# This is the "gate activation" moment — reading any skill file turns the gate on.
if [[ ! -f "$TRACK_FILE" ]]; then
  echo '{"skill_md":false,"cutting_strategies":false,"team_split_patterns":false,"smart_checklist":false,"feature_spec_template":false,"sub_spec_cutting":false,"plan_split_patterns":false,"sub_spec_template":false}' > "$TRACK_FILE"
fi

# --- Set flags based on what was read ---

# Tier 1 — base files

# Flag: SKILL.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/SKILL.md" ]]; then
  UPDATED="$(jq '.skill_md = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: cutting-strategies.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/references/cutting-strategies.md" ]]; then
  UPDATED="$(jq '.cutting_strategies = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: team-split-patterns.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/references/team-split-patterns.md" ]]; then
  UPDATED="$(jq '.team_split_patterns = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: smart-checklist.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/references/smart-checklist.md" ]]; then
  UPDATED="$(jq '.smart_checklist = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: feature-spec.md template
if [[ "$FILE_PATH" == "${SKILL_DIR}/templates/feature-spec.md" ]]; then
  UPDATED="$(jq '.feature_spec_template = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Tier 2 — sub-spec files (new in v0.3)

# Flag: sub-spec-cutting.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/references/sub-spec-cutting.md" ]]; then
  UPDATED="$(jq '.sub_spec_cutting = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: plan-split-patterns.md
if [[ "$FILE_PATH" == "${SKILL_DIR}/references/plan-split-patterns.md" ]]; then
  UPDATED="$(jq '.plan_split_patterns = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

# Flag: sub-spec.md template
if [[ "$FILE_PATH" == "${SKILL_DIR}/templates/sub-spec.md" ]]; then
  UPDATED="$(jq '.sub_spec_template = true' "$TRACK_FILE")"
  echo "$UPDATED" > "$TRACK_FILE"
fi

exit 0
