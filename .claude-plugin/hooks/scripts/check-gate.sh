#!/usr/bin/env bash
# skill-gate: check-gate.sh
# PreToolUse hook for Write|Edit — blocks if the agent hasn't read critical files.
#
# Decision matrix:
#   - No tracking file exists     → approve (fail-open: not a skill session)
#   - Tracking file is malformed  → approve (fail-open)
#   - All five flags true         → approve
#   - Any flag false              → BLOCK (exit 2) with message listing what's missing
#
# Fail-open: if anything goes wrong, exit 0 silently.

set -euo pipefail

# --- Fail-open guard ---
if ! command -v jq &>/dev/null; then
  exit 0
fi

# --- Read stdin ---
INPUT="$(cat)"

SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // empty')"

if [[ -z "$SESSION_ID" ]]; then
  exit 0
fi

# --- Check tracking file ---
TRACK_FILE="/tmp/skill-gate-epic-specs-${SESSION_ID}.json"

# No tracking file = the agent hasn't read any skill file this session.
# This means it's either not a skill session, or the skill hasn't been invoked yet.
# Fail-open: approve.
if [[ ! -f "$TRACK_FILE" ]]; then
  exit 0
fi

# --- Resolve anchors ---
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
if [[ -z "$PLUGIN_ROOT" ]]; then
  exit 0
fi
PLUGIN_ROOT="${PLUGIN_ROOT%/}"
SKILL_DIR="${PLUGIN_ROOT}/skills/epic-to-feature-specs"

# --- Parse flags ---
SKILL_MD="$(jq -r '.skill_md // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
CUTTING="$(jq -r '.cutting_strategies // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
TEAM_SPLIT="$(jq -r '.team_split_patterns // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
SMART="$(jq -r '.smart_checklist // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
TEMPLATE="$(jq -r '.feature_spec_template // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }

# --- All clear? ---
if [[ "$SKILL_MD" == "true" && "$CUTTING" == "true" && "$TEAM_SPLIT" == "true" && "$SMART" == "true" && "$TEMPLATE" == "true" ]]; then
  exit 0
fi

# --- Build block message ---
MISSING=""

if [[ "$SKILL_MD" != "true" ]]; then
  MISSING="${MISSING}\n  - SKILL.md (read from: ${SKILL_DIR}/SKILL.md)"
fi

if [[ "$CUTTING" != "true" ]]; then
  MISSING="${MISSING}\n  - references/cutting-strategies.md (read from: ${SKILL_DIR}/references/cutting-strategies.md)"
fi

if [[ "$TEAM_SPLIT" != "true" ]]; then
  MISSING="${MISSING}\n  - references/team-split-patterns.md (read from: ${SKILL_DIR}/references/team-split-patterns.md)"
fi

if [[ "$SMART" != "true" ]]; then
  MISSING="${MISSING}\n  - references/smart-checklist.md (read from: ${SKILL_DIR}/references/smart-checklist.md)"
fi

if [[ "$TEMPLATE" != "true" ]]; then
  MISSING="${MISSING}\n  - templates/feature-spec.md (read from: ${SKILL_DIR}/templates/feature-spec.md)"
fi

echo -e "SKILL-GATE BLOCKED: You must read ALL reference and template files before writing any spec.\n\nMissing:${MISSING}\n\nRead the missing files first, then retry your Write/Edit. These files contain critical patterns (persona detection, cutting strategies, SMART validation, design integration) that shape every spec you produce." >&2
exit 2
