---
name: epic-to-feature-specs
description: Break a large epic doc into implementation-ready feature specs that sit between epic-level goals and story-level detail. Use whenever the user says "break down epic", "split epic", "decompose epic", "write feature specs", "epic → spec", "epic to stories", "make this epic AI-codeable", "spec out this epic", Vietnamese equivalents ("chia epic", "viết spec", "tách epic thành spec"), or complains that stories are too small and epics are too big for AI coding agents. Also trigger when the user uploads an epic doc and asks how to hand it to engineering, or when discussing FE/BE handoff contracts, team-split implementation planning, or SMART decomposition. Produce a small number (default 3, up to 5) of feature specs per epic, each with a TypeScript handoff contract and acceptance criteria — the output is designed to be fed directly to AI coding agents so teams can ship in parallel.
---

# Epic → Feature Specs

## What this skill does

Transforms an epic document (a phase-sized goal with many user stories) into **3–5 feature specs** — an intermediate layer between epic and story that is sized for AI coding agents and team-parallel implementation.

The core problem this solves: epics are too big (agent loses the thread, scope creeps, technical decisions drift) and stories are too small (agent implements in isolation, misses shared code paths, re-litigates decisions). A feature spec bundles stories that share an implementation boundary, freezes the technical contracts, and preserves just enough context for a bounded agent session.

## Core principles

**1. Each spec must be SMART-independent.** Specific, Measurable, Achievable, Relevant, Time-bound — and crucially, **measurable without its siblings existing**. If Spec B needs Spec A done before B can be tested, the cut is wrong. Use mocked contracts so every spec is independently verifiable.

**2. The handoff contract is load-bearing.** When teams are split (e.g. FE/BE), the contract is what lets them work in parallel. It must be typed (TypeScript or equivalent), frozen before either side codes, and canonical in one place that AI agents can read.

**3. Decisions already made stay made.** Feature specs carry a "Decisions Already Made" section so agents don't re-argue provider choices, state libraries, or data layer picks. This is the single biggest reason agents drift mid-implementation.

**4. Max 5 specs per epic.** 3 is default. 5 is the ceiling. More fragmentation than 5 is a signal the epic itself should be split.

**5. FE (or any presentation-only team) gets exactly one spec per epic.** When teams are split so that one owns presentation-only concerns, all of that team's work rolls up into Spec X.1. One doc per epic for that team. This simplifies their reading and keeps the cognitive load low.

## Workflow

Follow these steps in order. Use the AskUserQuestion tool to gather inputs — do not assume.

### Step 1: Gather context

Before drafting anything, ask the user these questions (use AskUserQuestion with 2–4 questions per turn, combine where natural):

1. **Epic source** — path to the epic file, or Notion URL. Read it in full before proceeding.
2. **Team structure** — present options:
   - Single team (no split)
   - FE + BE (presentation vs. everything-else, FE may also own input validation)
   - FE + BE + Mobile (three-way)
   - Other (free text)
3. **Max spec count** — 3 (default, tightest) / 4 / 5 (ceiling).
4. **Spec storage location** — where to write the `.md` files (e.g. `product_docs/specs/{epic}/`, `.hoangsa/sessions/{branch}/`, `docs/specs/`).
5. **Contract storage location** — where TypeScript contract files live (e.g. `contracts/` at repo root). If the project uses multiple repos, ask which one is canonical.
6. **Language for the contract** — default TypeScript. Offer alternatives (Go types, Python protocol classes, JSON Schema) only if the user's stack clearly isn't TS.
7. **Existing tech doc** — ask if there's an architecture/technical document the specs should cite rather than duplicate. Read it if provided.

Do not improvise these inputs. A wrong assumption here corrupts every spec downstream.

### Step 2: Read and analyze the epic

Read the epic file. Identify:

- The **goal** (the one-sentence outcome)
- The **user stories** (enumerate them with their IDs)
- **Dependencies** on other epics or external systems
- **Technical notes** (stack decisions, architectural constraints)
- **Out-of-scope** items (these must NOT bleed into any spec)

Then mentally group the stories by **implementation cohesion** — which stories touch the same files, the same service, the same state machine? Groupings become candidate specs.

### Step 3: Pick a cutting strategy

See `references/cutting-strategies.md` for the full decision tree. Quick version:

- **Dual-team (e.g. FE + BE)** → Spec X.1 is always the FE spec (all presentation work for the epic). BE specs split by service or by stage. This is the most common case.
- **Single team** → Cut horizontally by layer (UI / domain / data) when layers are genuinely separable, OR vertically by user-value slice when horizontal cuts would ship no value until all are done.
- **Contract-first (when infra is a big lift)** → Spec X.1 is scaffolding (types, routes, migrations), Specs X.2+ are implementations against the scaffolding.

If uncertain, prefer the dual-team pattern — it's the most AI-codeable because boundaries are enforced by the contract rather than by convention.

### Step 4: Draft the specs

Use `templates/feature-spec.md` as the starting structure. Fill each spec with:

- Linkage back to the epic (cite goal and story IDs from the original)
- Scope in/out (explicit; no overlap with sibling specs)
- SMART outcome (see `references/smart-checklist.md`)
- Dependencies (on sibling specs and external epics)
- **Handoff Contract** (most important section — see below)
- Grouped user stories with acceptance criteria
- Decisions Already Made (cite the tech doc; don't re-argue)
- Test plan (how we verify independently)
- Out of Scope Within This Spec (prevents gold-plating)

### Step 5: Author the handoff contract

For each spec that crosses a team boundary, produce a TypeScript contract file using `templates/handoff-contract.ts`. The contract defines:

- Mutations (actions the presentation layer calls)
- Selectors / hooks (state the presentation layer reads)
- Types (discriminated unions for state machines — always prefer these over loose `status: string` fields; they force exhaustive rendering)
- Events (optional subscriptions)

**Critical rule:** the contract is coarser than the internal state it represents. If BE has internal stages (e.g. `whisper-running`, `structuring`, `dlq-retry`), those should collapse to a single `processing` state at the contract boundary. The contract is a *seam*, not a mirror.

Also produce a prose `BE-HANDOFF.md` (see `templates/be-handoff-narrative.md`) that documents the contract in human-readable form for Notion review. The `.ts` file is canonical; the `.md` is explanation.

### Step 6: Validate independence (SMART check)

For each spec, run through `references/smart-checklist.md`. The most important test:

> *"Can this spec's acceptance criteria be verified with sibling specs mocked out?"*

If no, cut differently. Typical fixes:
- Merge two specs that have circular dependencies
- Extract the shared dependency into a new spec that both depend on (counts toward the 5-spec ceiling)
- Move scope out (it belongs to another epic)

### Step 7: Write files and produce a dependency graph

Write each spec to the agreed storage path using the naming convention:

```
spec-{epic-number}.{spec-number}-{team}-{short-title}.md
```

Examples:
- `spec-3.1-fe-processing-surface.md`
- `spec-3.2-be-upload-transcription.md`
- `spec-3.3-be-structuring-note-creation.md`

Write contract files to the agreed contracts path:

```
contracts/{feature-area}.ts
```

Example: `contracts/processing.ts`

Also produce a short mermaid diagram showing spec → spec dependencies, so the team can see the ordering at a glance. Include it in the epic's existing `.md` file as an appendix or in a new `SPECS-OVERVIEW.md` in the spec folder.

### Step 8: Present results

Output to the user:
- List of files written (with paths)
- The dependency graph (mermaid block)
- A **"What each team reads first"** summary — e.g. "FE team starts with Spec 3.1. BE team starts with Spec 3.2 and 3.3 in parallel."
- Any open questions or places where the user should review before finalizing

## Handoff contract: the discipline

When a spec crosses a team boundary, follow these rules to prevent drift (the #1 failure mode of parallel teams):

1. **Freeze before coding.** The contract must be agreed by both team leads before either side writes production code. AI agents can work against mocks only if the mock shape is trustworthy.
2. **One source of truth.** The `.ts` contract file lives in one repo (the BE-owning repo is a good default). Other repos either import it as a package, sync via a small script, or copy-paste with a CI diff check. Do not rely on memory or Notion alone — AI agents need a file they can read.
3. **Amendments require co-review.** If a contract needs to change mid-implementation, both team leads sign off in the same PR. Amending quietly in one repo is the failure mode.
4. **Contract is coarser than internals.** FE sees `processing`, BE knows whether it's in Whisper-stage or DLQ-retry. Leaking internal states into the contract couples the teams and defeats the purpose.

See `references/team-split-patterns.md` for variants: FE/BE, FE/BE/Mobile, single team with service boundaries, etc.

## Anti-patterns to watch for

- **Spec 3.1 referenced in Spec 3.2's acceptance criteria** — that's a dependency cycle. Cut differently.
- **A spec with no handoff contract** — only OK for a spec that lives entirely within one team's ownership (e.g. a pure-backend worker). If two teams touch it, contract is mandatory.
- **Stories copy-pasted verbatim from the epic** — preserve IDs, but rewrite acceptance criteria in the spec's voice with concrete, testable conditions.
- **Duplicating tech-doc decisions in every spec** — cite, don't re-state. The tech doc is authoritative.
- **More than 5 specs per epic** — the epic itself is probably too big. Escalate to the user: "Do we want to split the epic first?"
- **FE spec that also contains BE behaviour** — FE spec is presentation + input validation only. Domain logic goes to BE specs.

## When to stop

You're done when:
- Each spec is independently testable (SMART-independent)
- Each cross-team boundary has a TypeScript contract
- The user has reviewed the dependency graph and said "yes this ships in this order"
- Files are written to the agreed paths

If the user wants a worked example or a single spec drafted in full detail, offer to draft Spec X.1 end-to-end (the FE-heavy one when teams are split — it's the hardest to get right, so stress-test it first).

## References

- `templates/feature-spec.md` — the full spec template
- `templates/handoff-contract.ts` — TypeScript contract starter
- `templates/be-handoff-narrative.md` — prose companion for Notion review
- `references/cutting-strategies.md` — decision tree for how to split an epic
- `references/smart-checklist.md` — the SMART-independence validation
- `references/team-split-patterns.md` — FE/BE, FE/BE/Mobile, single-team variants
