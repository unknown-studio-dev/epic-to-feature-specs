# Epic to Feature Specs

Break epic documents into 3-5 implementation-ready feature specs with TypeScript handoff contracts. Solves the granularity gap where user stories are too small for AI coding agents (missing context) and epics are too big (scope creep, drift).

## What it does

Takes an epic doc (a grouped set of user stories with a shared goal) and produces:

1. **3 to 5 feature specs** (ceiling of 5, default of 3), each sized for one AI coding session
2. **A typed handoff contract** (`contracts/*.ts`) that is the seam between FE and BE teams
3. **A narrative companion** (`BE-HANDOFF.md`) for Notion review and onboarding

Each feature spec passes the SMART independence test: specific scope, measurable with sibling specs mocked, achievable in one session, relevant to the epic goal, time-bound.

## When to use it

Trigger phrases:

- "Break this epic into feature specs"
- "Decompose epic-XX into implementation-ready specs"
- "Cut epic into AI-codeable chunks"
- "Write feature specs for epic XX"
- "Split this epic across FE and BE teams"

Vietnamese: "chia epic", "viết spec", "tách epic thành spec".

## How it works

The skill guides you through an 8-step workflow:

1. Read the epic + any referenced technical documents
2. Clarify team structure, spec location, contract location
3. Choose a cutting strategy (Dual-Team, Horizontal-by-layer, Vertical-by-value-slice, or Contract-first scaffolding)
4. Draft the handoff contract in TypeScript
5. Split stories across specs — presentation team always gets one spec (Spec X.1)
6. Fill each spec against the template
7. Run the SMART independence checklist
8. Write the BE handoff narrative

## Team split assumptions

Defaults to the "FE + BE" pattern where:

- **FE** owns presentation, navigation, local interaction state, and input validation
- **BE** owns all client-side logic (state management, persistence, network, retry) plus the server

The contract surface is view ↔ store (not client ↔ server). This split is parameterized — the skill asks at runtime and supports single-team, FE+BE+Mobile, multi-service backend, and designer-engineer patterns.

## What's inside

- `skills/epic-to-feature-specs/SKILL.md` — core workflow and principles
- `skills/epic-to-feature-specs/templates/` — feature spec, TypeScript handoff contract, BE-handoff narrative
- `skills/epic-to-feature-specs/references/` — cutting strategies, SMART checklist, team split patterns

## Install

### Cowork (recommended)

Add this repo as a marketplace source in Cowork:

1. Open **Customize** (top-left) → **Plugins** → **Personal** tab
2. Click the **+** button to add a marketplace
3. Enter `studium-ignotum/epic-to-feature-specs` and click **Sync**
4. The plugin appears in your Personal plugins — toggle it on

This keeps the plugin in sync with the latest version from the repo.

### Claude Code — via marketplace

```
/plugin marketplace add studium-ignotum/epic-to-feature-specs
/plugin install epic-to-feature-specs@epic-to-feature-specs
```

### Claude Code — manual

```
git clone https://github.com/studium-ignotum/epic-to-feature-specs.git
cd epic-to-feature-specs
/plugin install ./
```

## Author

Khang Truong — built for the InstaNote project, generalized for any multi-team codebase.

## License

MIT
