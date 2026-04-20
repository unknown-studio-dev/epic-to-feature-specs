#!/usr/bin/env bash
# Run this script from the repo root to create the branch, commit, push, and open a PR.
# Usage: bash push-v0.2.sh

set -euo pipefail

echo "=== Creating branch ==="
git checkout -b feat/v0.2-persona-design-hooks

echo "=== Staging changes ==="
git add \
  skills/epic-to-feature-specs/SKILL.md \
  skills/epic-to-feature-specs/references/cutting-strategies.md \
  skills/epic-to-feature-specs/references/team-split-patterns.md \
  skills/epic-to-feature-specs/templates/feature-spec.md \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  .claude-plugin/hooks/hooks.json \
  .claude-plugin/hooks/scripts/check-gate.sh \
  .claude-plugin/hooks/scripts/track-read.sh \
  epic-to-feature-specs.plugin

echo "=== Committing ==="
git commit -m "$(cat <<'EOF'
feat: v0.2 — persona-adaptive flow, UI design integration, read-before-write hooks

Three major improvements:

1. Persona detection (Step 1): asks users if they're a PM/non-tech,
   technical lead, or solo developer. Each persona gets tailored
   questions, cutting strategies, contract depth, and output format.
   Replaces the previous hardcoded FE+BE team assumption.

2. UI design integration (Step 2.5): auto-detects Figma and Pencil
   MCPs. Pulls component trees, design tokens, and screen flows
   into FE specs. Adds Section 5 (UI Design Reference) to the
   feature-spec template with screen-to-story mapping, component
   inventory, state-to-screen mapping, and design-spec mismatch
   resolution with concrete recommendations.

3. Read-before-write hooks: adapted from dev-blog-writer pattern.
   track-read.sh (PostToolUse) records which reference/template
   files the agent has read. check-gate.sh (PreToolUse) blocks
   Write/Edit if any of the 5 critical files haven't been read.
   Fail-open design — only activates when a skill file is read.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"

echo "=== Pushing ==="
git push -u origin feat/v0.2-persona-design-hooks

echo "=== Creating PR ==="
gh pr create --title "feat: v0.2 — persona-adaptive flow, design integration, hooks" --body "$(cat <<'EOF'
## Summary

- **Persona detection**: New Step 1 asks users their role (PM, tech lead, solo dev) before anything else. Tailors team split options, contract depth, and output format per persona. Non-tech PMs get guided FE/BE splits; technical users get flexible options (by service, domain, layer, custom).
- **UI design integration**: New Step 2.5 auto-detects Figma/Pencil MCPs and offers to pull component trees, design tokens, and screen flows. Adds Section 5 (UI Design Reference) to feature-spec template with screen-to-story mapping, component inventory, state-to-screen mapping, and **design-spec mismatch resolution** with concrete recommendations and alternatives.
- **Read-before-write hooks**: Adapted from dev-blog-writer. Blocks the agent from writing specs until it has read all 5 critical files (SKILL.md, cutting-strategies.md, team-split-patterns.md, smart-checklist.md, feature-spec.md). Fail-open — only activates during skill sessions.

## Files changed

- `skills/epic-to-feature-specs/SKILL.md` — Rewritten workflow (Steps 1, 2, 2.5 new; all other steps updated)
- `skills/epic-to-feature-specs/references/cutting-strategies.md` — Persona-aware decision tree + Strategy 5 (Service-Domain)
- `skills/epic-to-feature-specs/references/team-split-patterns.md` — Pattern F (Solo dev) + Pattern G (Tech lead custom)
- `skills/epic-to-feature-specs/templates/feature-spec.md` — New Section 5 (UI Design Reference with mismatch handling)
- `.claude-plugin/hooks/` — New hook scripts (track-read.sh, check-gate.sh, hooks.json)
- `.claude-plugin/plugin.json` + `marketplace.json` — Version bump to 0.2.0
- `epic-to-feature-specs.plugin` — Rebuilt with all changes + hooks

## Test plan

- [ ] Install plugin from `.plugin` file and verify skill triggers correctly
- [ ] Run skill and confirm persona detection question appears first
- [ ] Verify hook blocks Write before all 5 files are Read
- [ ] Verify hook passes after all 5 files are Read
- [ ] Test with Figma MCP connected — confirm design auto-detection prompt
- [ ] Test without any design MCP — confirm graceful fallback to link/screenshot

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"

echo "=== Done! ==="
