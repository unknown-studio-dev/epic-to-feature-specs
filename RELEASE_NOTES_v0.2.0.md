# v0.2.0 — Persona-Adaptive Flow, UI Design Integration, Read-Before-Write Hooks

Three major improvements that make the skill work for any user — not just FE/BE teams managed by a PM.

## Persona Detection (New)

The skill no longer assumes an FE+BE team split. It now asks your role first and tailors everything downstream:

- **PM / non-technical** — guided FE+BE split with full handoff contracts and prose companion. Design references are high-detail to bridge designer intent and developer output.
- **Technical lead** — flexible splitting by service, domain, layer, or custom boundaries. Typed interfaces only (no prose companion unless requested).
- **Solo developer** — value-slice default (ship incrementally). Contracts are optional internal seams for AI agents.

Questions, cutting strategies, contract depth, and output format all adapt per persona.

## UI Design Integration (New)

The skill now connects to your design tools to ensure FE specs match the intended UI:

- **Auto-detects** connected Figma and Pencil MCPs — offers to pull design context directly
- **Falls back gracefully** to links, screenshots, or "no designs yet" when no MCP is available
- **Extracts** component trees, design tokens, screen flows, and state variants from design files
- **Adds Section 5 (UI Design Reference)** to every spec with user-facing work, containing:
  - Screen-to-story mapping
  - Component inventory (with "exists in codebase?" status)
  - Design tokens referenced
  - State-to-screen mapping (contract states → design frames)
  - **Design-spec mismatch resolution** — surfaces contradictions between designs and stories with concrete recommendations and alternatives, so decisions are made before implementation starts

## Read-Before-Write Hooks (New)

Adapted from [dev-blog-writer](https://github.com/unknown-studio-dev/dev-blog-writer). Ensures the AI agent reads all critical reference and template files before writing any spec:

- `track-read.sh` (PostToolUse on Read) — records which of the 5 critical files have been read
- `check-gate.sh` (PreToolUse on Write/Edit) — blocks writes with a descriptive error listing missing files
- **Fail-open** — only activates when a skill file is read; non-skill work is never blocked

Gated files: `SKILL.md`, `cutting-strategies.md`, `team-split-patterns.md`, `smart-checklist.md`, `feature-spec.md`.

## Updated References

- **cutting-strategies.md** — decision tree now starts from persona. Added Strategy 5 (Service-Domain) for tech leads splitting by architecture.
- **team-split-patterns.md** — added Pattern F (Solo developer) and Pattern G (Technical lead with custom boundaries). Choosing guide updated for all 3 personas.
- **feature-spec.md template** — new Section 5 (UI Design Reference) with 5 subsections. User stories now include a "Design reference" field. Test plan includes visual verification against designs.

## Breaking Changes

None. The skill is fully backward-compatible — PM persona with FE+BE split produces the same output as v0.1. The new personas and design integration are additive.

## Files Changed

```
Modified:
  skills/epic-to-feature-specs/SKILL.md
  skills/epic-to-feature-specs/references/cutting-strategies.md
  skills/epic-to-feature-specs/references/team-split-patterns.md
  skills/epic-to-feature-specs/templates/feature-spec.md
  .claude-plugin/plugin.json
  .claude-plugin/marketplace.json
  README.md

Added:
  .claude-plugin/hooks/hooks.json
  .claude-plugin/hooks/scripts/track-read.sh
  .claude-plugin/hooks/scripts/check-gate.sh
```
