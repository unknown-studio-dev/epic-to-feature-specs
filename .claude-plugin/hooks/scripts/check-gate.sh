#!/usr/bin/env bash
# skill-gate: check-gate.sh
# PreToolUse hook for Write|Edit — blocks if the agent hasn't read critical files.
#
# Two-tier gating (v0.3):
#   Tier 1 (always required): SKILL.md + 3 references + feature-spec template (5 files)
#   Tier 2 (required only when writing/editing a sub-spec):
#          references/sub-spec-cutting.md + references/plan-split-patterns.md + templates/sub-spec.md
#
#   "Write target is a sub-spec" = file_path contains "/sub-specs/" OR filename matches "spec-*.[A-E].*"
#
# Decision matrix:
#   - No tracking file exists                              → approve (fail-open: not a skill session)
#   - Tracking file is malformed                           → approve (fail-open)
#   - All Tier 1 flags true, write target NOT a sub-spec   → approve
#   - All Tier 1 + Tier 2 flags true, target IS a sub-spec → approve
#   - Any required flag false                              → BLOCK (exit 2) with message
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
WRITE_TARGET="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"

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

# --- Detect tier required by this write ---
# A write is a sub-spec write if:
#   - target path contains "/sub-specs/"  (canonical storage location), OR
#   - target filename matches "spec-*.[A-E]-*"  (e.g. spec-7.1.A-...md)
REQUIRES_TIER2="false"
if [[ -n "$WRITE_TARGET" ]]; then
  if [[ "$WRITE_TARGET" == */sub-specs/* ]]; then
    REQUIRES_TIER2="true"
  else
    BASENAME="$(basename "$WRITE_TARGET")"
    if [[ "$BASENAME" =~ ^spec-[0-9]+\.[0-9]+\.[A-E][.-] ]]; then
      REQUIRES_TIER2="true"
    fi
  fi
fi

# --- Parse Tier 1 flags ---
SKILL_MD="$(jq -r '.skill_md // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
CUTTING="$(jq -r '.cutting_strategies // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
TEAM_SPLIT="$(jq -r '.team_split_patterns // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
SMART="$(jq -r '.smart_checklist // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
TEMPLATE="$(jq -r '.feature_spec_template // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }

# --- Parse Tier 2 flags (only checked if REQUIRES_TIER2) ---
SUB_CUT="$(jq -r '.sub_spec_cutting // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
PLAN_SPLIT="$(jq -r '.plan_split_patterns // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }
SUB_TPL="$(jq -r '.sub_spec_template // false' "$TRACK_FILE" 2>/dev/null)" || { exit 0; }

# --- Build the list of missing files ---
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

if [[ "$REQUIRES_TIER2" == "true" ]]; then
  if [[ "$SUB_CUT" != "true" ]]; then
    MISSING="${MISSING}\n  - references/sub-spec-cutting.md (read from: ${SKILL_DIR}/references/sub-spec-cutting.md) [sub-spec write]"
  fi
  if [[ "$PLAN_SPLIT" != "true" ]]; then
    MISSING="${MISSING}\n  - references/plan-split-patterns.md (read from: ${SKILL_DIR}/references/plan-split-patterns.md) [sub-spec write]"
  fi
  if [[ "$SUB_TPL" != "true" ]]; then
    MISSING="${MISSING}\n  - templates/sub-spec.md (read from: ${SKILL_DIR}/templates/sub-spec.md) [sub-spec write]"
  fi
fi

# --- All clear? ---
if [[ -z "$MISSING" ]]; then
  exit 0
fi

# --- Block message ---
if [[ "$REQUIRES_TIER2" == "true" ]]; then
  CONTEXT="Sub-spec write detected (${WRITE_TARGET}). Sub-spec writes require Tier 1 (base) AND Tier 2 (sub-spec) reference files."
else
  CONTEXT="Feat-spec write detected. Tier 1 (base) reference files required."
fi

echo -e "SKILL-GATE BLOCKED: ${CONTEXT}\n\nMissing:${MISSING}\n\nRead the missing files first, then retry your Write/Edit. These files contain critical patterns (persona detection, cutting strategies, SMART validation, design integration, sub-spec cutting, Plan Split rules) that shape every spec you produce." >&2
exit 2
