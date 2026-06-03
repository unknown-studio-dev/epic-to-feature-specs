<!--
  epic-to-feature-specs — Codex adapter snippet.

  Paste this section into your project's AGENTS.md (or use it as your AGENTS.md
  if you don't have one). Codex CLI / Codex Cloud will load AGENTS.md
  automatically from the project root and parent directories.

  This snippet keeps Codex's context cheap: it tells Codex *when* the workflow
  is relevant and points at the full workflow file. Codex only loads
  WORKFLOW.md when the trigger phrases hit, not on every turn.
-->

## Skill: epic-to-feature-specs

When the user asks any of the following — in English or Vietnamese — load and follow `./.epic-to-feature-specs/WORKFLOW.md` end-to-end before answering:

- "break down this epic", "split epic", "decompose epic"
- "write feature specs", "write sub-specs", "spec out this epic"
- "epic → spec", "epic to stories", "make this epic AI-codeable"
- "FE/BE handoff contract", "team-split implementation plan"
- "chia epic", "viết spec", "tách epic thành spec"

The workflow:

1. Detects the user's persona (PM / tech lead / solo dev) and adapts every downstream question
2. Gathers epic source, team structure, spec/contract storage paths, and tech docs
3. Pulls UI design context from any connected Figma/Pencil tools (or accepts screenshots)
4. Cuts the epic into 3–5 feature specs with typed handoff contracts
5. Validates each spec is SMART-independent (verifiable with siblings mocked)
6. Optionally decomposes each feat spec into 3–5 sub-specs (one shippable PR each), with Plan Split annotations for sub-specs that exceed the ~250k-token AI sweet spot
7. Writes sub-specs into Notion via the Notion MCP if available; otherwise markdown only

### Hard rules

- **Ask explicitly at every step that calls for input.** Wrong assumptions on persona, team split, or storage paths corrupt every spec downstream. The workflow names the questions; do not improvise them.
- **Read all referenced files before drafting.** Before writing any feature spec, read `./.epic-to-feature-specs/templates/feature-spec.md`, `./.epic-to-feature-specs/references/smart-checklist.md`, and `./.epic-to-feature-specs/references/cutting-strategies.md`. Before writing any sub-spec, additionally read `./.epic-to-feature-specs/templates/sub-spec.md`, `./.epic-to-feature-specs/references/sub-spec-cutting.md`, and `./.epic-to-feature-specs/references/plan-split-patterns.md`.
- **Stop at the sub-spec layer.** Do not generate `DESIGN-SPEC.md`, `TEST-SPEC.md`, `plan.json`, or task context packs — those belong to hoangsa's `/hoangsa:menu` and `/hoangsa:prepare` commands.
- **No token numbers in Plan Split sections.** The skill's heuristic is internal; hoangsa is the budget authority.

### Tool guidance

- **Figma / Pencil design tools** — if any are connected as MCP servers, use them to pull component trees, screen flows, and design tokens during Step 2.5. Otherwise ask the user for the file URL or screenshots.
- **Notion MCP** — if connected, fetch the destination database first to discover its property schema, then create one page per sub-spec mapping only properties that exist. If no Notion MCP is connected, write markdown sub-specs only and tell the user to create Notion cards manually.

### Where the workflow lives

- `./.epic-to-feature-specs/WORKFLOW.md` — the canonical workflow (read this when triggered)
- `./.epic-to-feature-specs/references/` — decision trees and validation checklists referenced by the workflow
- `./.epic-to-feature-specs/templates/` — markdown and TypeScript templates the workflow fills in

If `./.epic-to-feature-specs/` doesn't exist in this project, see `adapters/codex/INSTALL.md` in the upstream repo (`unknown-studio-dev/epic-to-feature-specs`) for the one-command install.
