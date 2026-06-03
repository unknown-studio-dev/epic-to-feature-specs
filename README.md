# Epic to Feature Specs

Break epic documents into 3-5 implementation-ready feature specs with TypeScript handoff contracts, then optionally decompose each into 3-5 sub-specs sized for AI coding harnesses like [hoangsa](https://github.com/unknown-studio-dev/hoangsa). Adapts to your role — whether you're a PM handing off to engineering, a tech lead decomposing your own work, or a solo dev breaking an epic into AI-codeable chunks.

## What it does

Takes an epic doc (a grouped set of user stories with a shared goal) and produces a two-layer decomposition:

### Layer 1 — Feat specs (team contracts)

1. **3 to 5 feature specs** (ceiling of 5, default of 3), one per team-ownership boundary
2. **A typed handoff contract** (`contracts/*.ts`) that is the seam between teams or layers
3. **A narrative companion** (`BE-HANDOFF.md`) for Notion review and onboarding (multi-team setups)
4. **UI design references** — component inventory, screen-to-story mapping, and design-spec mismatch resolution (when Figma/Pencil designs are provided)

### Layer 2 — Sub-specs (shippable-PR units, optional, new in v0.3)

After the feat specs are written, the skill optionally decomposes each into:

5. **3 to 5 sub-specs per feat spec** (cap `.A` through `.E`), each one shippable PR sized for one AI cook session
6. **Notion pages** — sub-specs are written into your Notion task database via the Notion MCP (property schema is discovered per-database, so it adapts to your existing setup)
7. **Plan Split annotations** — when a sub-spec's logical scope would exceed the ~250k-token AI sweet spot, the skill embeds a substrate/wiring or domain/transport split that hoangsa's `/hoangsa:prepare` honors

Each feat spec and sub-spec passes the SMART independence test: specific scope, measurable with siblings mocked, achievable in one session, relevant to the epic goal, time-bound.

## What's new in v0.3

**Sub-spec layer** — the missing rung between feat spec and hoangsa session. Feat specs are now correctly sized as team contracts (30+ stories per spec); sub-specs are sized as shippable PRs (5–15 stories per spec) that an AI coding agent can hold in one bounded session. The skill writes sub-specs into Notion via the Notion MCP, with property schema discovered per-database so it adapts to your existing setup.

**Stub-first as default cutting principle** — the first sub-spec from any FE feat spec ships the structural skeleton (provider chain, navigation root, base services) with stubs for everything siblings will fill in. Each later sub-spec replaces stubs from earlier sub-specs. Out of Scope sections explicitly name sibling sub-specs by ID so the boundaries are unambiguous.

**Plan Split annotations** — when a sub-spec's logical scope would exceed the ~250k-token AI sweet spot (where AI output quality starts to degrade — "AI-rot"), the skill embeds a Plan Split section in the sub-spec body. Hoangsa's `/hoangsa:prepare` uses this annotation to plan two sequential cook sessions instead of one oversized one. The skill names boundaries by REQ + file category; hoangsa runs the actual token math.

**FE / BE split patterns** — sub-spec cutting decisions now ship as a small set of named patterns:
- FE: co-shipping coupled foundations → surface area → stub-first dependent
- BE: service / domain boundary → endpoint cluster
- Fallback: single sub-spec for small / single-concern feat specs

## What's new in v0.2

**Persona-adaptive workflow** — the skill no longer assumes an FE+BE team split. It first asks your role, then tailors everything downstream:

| Persona | Default split | Contract depth | Design integration |
|---|---|---|---|
| PM / non-technical | FE + BE (guided) | Full contracts + prose companion | High — maps designs to specs |
| Technical lead | User-defined (by service, domain, layer, or custom) | Typed interfaces only | Medium — references designs |
| Solo developer | Value slice (ship incrementally) | Optional internal seams | Light — links to designs |

**UI design integration** — auto-detects connected Figma and Pencil MCPs. When designs are available, the skill pulls component trees, design tokens, and screen flows directly into the FE spec. Mismatches between designs and stories are surfaced with concrete recommendations so you can resolve them before implementation starts.

**Read-before-write hooks** — ensures the AI agent reads all 5 critical reference and template files before writing any spec. Adapted from the [dev-blog-writer](https://github.com/unknown-studio-dev/dev-blog-writer) hook pattern. Fail-open design — only activates during skill sessions.

## When to use it

Trigger phrases: "break this epic into feature specs", "decompose epic", "cut epic into AI-codeable chunks", "write feature specs", "split this epic across teams", "make this epic AI-codeable", "spec out this epic".

Vietnamese: "chia epic", "viết spec", "tách epic thành spec".

## How it works

The skill guides you through an 11-step workflow (Steps 10–11 are optional — only run when you want to decompose feat specs further into sub-specs):

1. **Understand the user** — detect persona (PM, tech lead, solo dev) to tailor the entire flow
2. **Gather context** — epic source, team structure (adapted per persona), spec/contract locations, tech docs
3. **Gather UI designs** — auto-detect Figma/Pencil MCPs, pull component trees and design tokens, or accept links/screenshots
4. **Read and analyze the epic** — identify goal, stories, dependencies, and cross-reference against designs
5. **Pick a cutting strategy** — Dual-Team, Horizontal-by-layer, Vertical-by-value-slice, Contract-first scaffolding, or Service-Domain (persona-aware)
6. **Draft the feat specs** — fill each from the template, including UI Design Reference with mismatch resolution
7. **Author handoff contracts** — TypeScript interfaces at team/layer boundaries
8. **Validate independence** — SMART checklist + design coverage verification
9. **Write feat-spec files and present results** — specs, contracts, dependency graph, implementation order
10. **Offer sub-spec decomposition** *(optional)* — ask whether to break feat specs into sub-specs for hoangsa
11. **Decompose into sub-specs** *(optional)* — cut by FE / BE / fallback patterns, write to Notion (if connected) + repo, emit Plan Split sections where warranted

## Team split patterns

The skill supports multiple patterns, chosen based on your persona and team structure:

- **Pattern A: FE + BE** — presentation team gets one spec per epic; BE specs split by service/stage (default for PM persona)
- **Pattern B: FE + BE + Mobile** — three-way split with shared contract
- **Pattern C: Single team** — cuts by layer, value slice, or contract-first scaffolding
- **Pattern D: Multi-service backend** — FE + API + Worker + Data with layered contracts
- **Pattern E: Designer-engineer + Engineers** — component surfaces vs. wiring
- **Pattern F: Solo developer** — value-slice default, optional contracts as AI agent seams
- **Pattern G: Technical lead custom** — split by service, domain, or architectural boundary

## What's inside

```
skills/epic-to-feature-specs/
  SKILL.md                              # Core workflow + principles (11 steps)
  templates/
    feature-spec.md                     # Feat-spec template (includes UI Design Reference section)
    sub-spec.md                         # Sub-spec template (REQ-ready ACs, optional Plan Split)  [v0.3]
    handoff-contract.ts                 # TypeScript contract starter
    be-handoff-narrative.md             # Prose companion for Notion review
  references/
    cutting-strategies.md               # Persona-aware decision tree (epic → feat specs)
    sub-spec-cutting.md                 # FE / BE / fallback patterns (feat spec → sub-specs)  [v0.3]
    plan-split-patterns.md              # When + how to emit a Plan Split section for hoangsa  [v0.3]
    smart-checklist.md                  # SMART independence validation (both layers)
    team-split-patterns.md              # All 7 team split patterns (A-G)

.claude-plugin/
  plugin.json                           # Plugin metadata (v0.3.0)
  marketplace.json                      # Marketplace listing
  hooks/
    hooks.json                          # Hook wiring (PostToolUse + PreToolUse)
    scripts/
      track-read.sh                     # Tracks reads of critical skill files
      check-gate.sh                     # Blocks writes until all files are read
```

## Install

### Cowork (recommended)

Add this repo as a marketplace source in Cowork:

1. Open **Customize** (top-left) → **Plugins** → **Personal** tab
2. Click the **+** button to add a marketplace
3. Enter `unknown-studio-dev/epic-to-feature-specs` and click **Sync**
4. The plugin appears in your Personal plugins — toggle it on

This keeps the plugin in sync with the latest version from the repo.

### Claude Code — via marketplace

```
/plugin marketplace add unknown-studio-dev/epic-to-feature-specs
/plugin install epic-to-feature-specs@epic-to-feature-specs
```

### Claude Code — manual

```
git clone https://github.com/unknown-studio-dev/epic-to-feature-specs.git
cd epic-to-feature-specs
/plugin install ./
```

## Author

Khang Truong — [@keitruong191](https://github.com/keitruong191)

## License

MIT
