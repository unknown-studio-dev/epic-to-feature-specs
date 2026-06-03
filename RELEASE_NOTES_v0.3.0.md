# v0.3.0 — Sub-Spec Layer, Stub-First Cutting, Plan Split for Hoangsa

The missing rung between feat specs and AI coding sessions. v0.3 adds the sub-spec layer so feat specs aren't fed raw to a single AI agent — they get decomposed into shippable-PR-sized units that an AI coding harness like [hoangsa](https://github.com/unknown-studio-dev/hoangsa) can hold in one bounded session.

## The Sub-Spec Layer (New)

A feat spec is a team contract (~20–35 stories, frozen handoff). It's correctly sized for what it is — but it's too big to hand to a single AI agent. Sub-specs sit between feat spec and hoangsa session:

```
Epic
  └─ Feat spec               (team contract — current skill, unchanged)
       └─ Sub-spec           (shippable PR — NEW in v0.3)
            └─ Hoangsa session   (DESIGN-SPEC + TEST-SPEC + plan.json — hoangsa owns)
                 └─ Task         (one fresh Claude context — hoangsa owns)
```

Each sub-spec is one cohesive shippable PR, ~5–15 stories, written as a Notion page and stored in the repo at `<spec_storage>/sub-specs/spec-X.Y.{letter}-<slug>.md`. Sub-specs cap at `.A` through `.E` per parent feat spec; if more are needed, the parent feat spec itself is too big and should be split.

After feat specs are written (Steps 1–9, unchanged), the skill offers Step 10: *"Want me to decompose these into sub-specs?"* Step 11 does the decomposition, with the user confirming boundaries before any file is written.

## Stub-First as Default Cutting Principle (New)

At every layer of decomposition, the dominant pattern is **stub-first**. The first sub-spec from any FE feat spec ships the structural skeleton (navigation root, provider chain, base services) with stubs for everything siblings will fill in. Later sub-specs replace stubs one by one without touching the integration site.

Every sub-spec's Out of Scope section MUST name its sibling sub-specs by ID (`7.1.C`, `7.2`). Anonymous deferrals ("owned by another sub-spec") fail SMART independence and create the coordination ambiguity the sub-spec layer exists to prevent.

This pattern shows up at every layer of the stack — skeleton sub-spec stubs what surface sub-specs fill; Plan-1 (substrate) stubs what Plan-2 (wiring) imports; types in wave-1 stub what wave-2 components consume.

## Plan Split Annotations for Hoangsa (New)

Some sub-specs are large enough that hoangsa's resulting `plan.json` would exceed the ~250k-token AI sweet spot per cook session, causing the "AI-rot" symptom (output quality degrades as context fills). The fix is to pre-split the plan inside the sub-spec itself, so hoangsa receives guidance from the start.

When the skill's internal heuristic flags a likely-oversized plan, it embeds a §7 Plan Split section in the sub-spec body. Hoangsa's `/hoangsa:prepare` honors this annotation.

**Critical design rule:** the skill never emits token numbers in the Plan Split section. The heuristic is internal-only, used only to decide IF a split is recommended. Boundaries are named by REQ + file category. Hoangsa runs `hoangsa-cli budget estimate` and stays the authority on tokens — anchoring it on a crude estimate would be garbage-in.

The §7 section includes a **Coverage check footer** that names the qualifier-overlap convention (`REQ-11 (logic only)` in Plan-1, `REQ-11 (UI)` in Plan-2) so the overlap doesn't read as a coverage gap to a reviewer or AI agent.

Three Plan Split patterns ship with v0.3:
- **FE-Plan (Substrate / Wiring)** — for FE sub-specs with both logic and UI.
- **BE-Plan-1 (Domain core / Transport)** — default for BE sub-specs.
- **BE-Plan-2 (Migration / Application)** — when migrations are nontrivial.

For sub-specs comfortably below the threshold, no Plan Split section is emitted (absence means "plan as one hoangsa session").

## Notion Integration (New)

Sub-specs land in Notion via the `notion-create-pages` MCP. The skill discovers the database's property schema dynamically via `notion-fetch` first, then maps only properties that actually exist:

| Default mapping (only if property exists in your database) | Source |
|---|---|
| Task name | "Spec X.Y.{letter} — <short scope>" |
| Description | Sub-spec §1 Context, first sentence |
| Effort level | Heuristic from file count: Low (<5), Medium (5–15), High (>15) |
| Priority | Inherit from epic, or default High |
| Status | Always "Draft" |
| Tags | Inherit from parent feat spec team tag |
| Task type | Default "Feature request" |

Properties absent from your database are silently skipped — the skill adapts to your existing setup rather than imposing a schema.

If the Notion MCP isn't connected (or you prefer another tracker), Notion integration is skipped — the markdown file in the repo is sufficient on its own. Hoangsa can ingest the markdown directly as `EXTERNAL-TASK.md` via the file path.

## Sub-Spec Template (New)

`templates/sub-spec.md` mirrors `templates/feature-spec.md` with three key differences:

1. **Required top-matter:** `Parent spec`, `Contracts`, `Stories` (inherited story IDs).
2. **Flat-numbered REQ-ready ACs** with story tags (`AC1 (FND-05): …`). Hoangsa's `/hoangsa:menu` maps each AC 1:1 to a `[REQ-xx]` marker in `DESIGN-SPEC.md`.
3. **Optional §7 Plan Split section** with the Coverage check footer.

## New Cutting Strategies for Sub-Specs

`references/sub-spec-cutting.md` (new) — decision tree for cutting feat specs into sub-specs.

**FE patterns:**
- FE-1 — Co-shipping coupled foundations (always the first sub-spec; bundles pieces that share `_layout.tsx` or would crash if shipped alone).
- FE-2 — Surface area (one sub-spec per coherent user-facing surface — Auth, Settings, Subscription, etc.).
- FE-3 — Stub-first dependent (discipline within FE-2 sub-specs).

**BE patterns:**
- BE-1 — Service / domain boundary (default).
- BE-2 — Endpoint cluster (when a single service is too large for one sub-spec).

**Fallback:** single sub-spec for small / single-concern feat specs.

## What This Skill Does NOT Do

The skill stops at the sub-spec layer. It does NOT generate `DESIGN-SPEC.md`, `TEST-SPEC.md`, `plan.json`, task context packs, or `PLAN-INDEX.md` — those are hoangsa's outputs. The skill produces the right-shaped input that hoangsa's `/hoangsa:menu` ingests cleanly via `EXTERNAL-TASK.md`.

## Breaking Changes

None. v0.3 is purely additive — v0.2 workflows produce the same output up through Step 9. The new Step 10 prompt is opt-in; users who decline see no change from v0.2. Sub-specs written by hand before v0.3 keep working as-is — no migration needed.

## Files Changed

```
Added:
  skills/epic-to-feature-specs/templates/sub-spec.md
  skills/epic-to-feature-specs/references/sub-spec-cutting.md
  skills/epic-to-feature-specs/references/plan-split-patterns.md

Modified:
  skills/epic-to-feature-specs/SKILL.md         (added Steps 10 + 11, principles 7-8, anti-patterns, references section)
  skills/epic-to-feature-specs/references/cutting-strategies.md  (cross-reference to sub-spec-cutting.md)
  skills/epic-to-feature-specs/references/smart-checklist.md     (sub-spec sibling-naming rule)
  README.md
  .claude-plugin/plugin.json                    (version 0.2.0 → 0.3.0)
```

## What's Next

v0.3 is the missing rung. The next likely improvement is **sync-back** — once sub-specs land in Notion and hoangsa starts implementing, the skill could update sub-spec Status (Draft → In Progress → Merged) via the Notion MCP as hoangsa reports back. But that's v0.4 territory — v0.3 ships the structural change first.
