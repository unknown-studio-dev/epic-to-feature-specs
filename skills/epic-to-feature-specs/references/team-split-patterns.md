# Team Split Patterns

How to map team structure to spec ownership. Read this when deciding who reads which spec.

## Pattern A: FE + BE (most common)

**Team charter:**
- **FE:** presentation only — screens, components, navigation, local interaction state (selection, modals, hover), input validation (field-level and form-level rules), error copy, accessibility.
- **BE:** everything else — persisted state (Zustand + SQLite or equivalent), domain logic, network calls, server, auth, tier/entitlement checks, background jobs.

**Gray-area rule:** If a check requires server truth (tier, quota, auth), BE owns it and exposes it through the contract. If it's pure client-side input validity (email format, required fields), FE owns it. Shared error copy stays FE because it's presentation.

**Spec assignment:**
- Spec X.1 → FE (all FE work for the epic, one doc)
- Specs X.2–X.5 → BE (split by service, stage, or cross-cutting concern)

**Contract surface:** view ↔ store. FE calls mutations and reads selectors; BE implements the store, network, and server behind.

**What BE owns that isn't "server":** Zustand store, SQLite queries, network request orchestration, retry logic, offline queuing, anything that isn't a rendered pixel or a user gesture handler.

**Parallel work:** FE builds Spec X.1 against mocked contract from day 1. BE builds X.2+ in parallel. FE "wires up" when BE ships by swapping mocks for real store.

## Pattern B: FE + BE + Mobile

**Team charter:**
- **Web FE:** presentation for web only
- **Mobile:** presentation for iOS + Android (often React Native)
- **BE:** everything else

**Spec assignment:**
- Spec X.1 → Web FE (if web is in scope for this epic)
- Spec X.2 → Mobile (if mobile is in scope)
- Specs X.3–X.5 → BE

**Contract surface:** Same as Pattern A, but the contract is consumed by two presentation teams. This makes contract stability even more critical.

**Special consideration:** If the feature is mobile-only or web-only, one of the presentation specs doesn't exist. That's fine — the 3-to-5 count is a ceiling, not a floor.

## Pattern C: Single team (no split)

**Team charter:** One team owns everything. Cuts are driven by implementation boundaries, not ownership.

**Spec assignment:** Follows the cutting strategies in `cutting-strategies.md`:
- Horizontal-by-layer: UI / domain / data
- Vertical-by-value-slice: v1 happy-path / resilience / polish
- Contract-first: scaffolding / consumer / provider

**Contract surface:** Still valuable as an internal seam even with one team — it lets individual agents implement one layer without holding the others in context.

## Pattern D: Multi-service backend (e.g. FE + API + Worker + Data)

**Team charter:** BE itself is split by service — API service, background worker, data platform, etc.

**Spec assignment:**
- Spec X.1 → FE (or skip if pure-backend epic)
- Spec X.2 → API service
- Spec X.3 → Worker / pipeline
- Spec X.4 → Data / ML

**Contract surface:** Two layers of contracts:
1. FE ↔ BE (as Pattern A)
2. BE ↔ BE (between services — typically message shapes or RPC types)

Both contracts need to be typed and versioned.

## Pattern E: Designer-engineer + Engineers

**Team charter:**
- **Designer-engineer:** HTML/CSS, component library work, design tokens, Storybook, accessibility
- **Engineers:** JavaScript/TypeScript, state, network, backend

**Spec assignment:**
- Spec X.1 → Designer-engineer (component surfaces, tokens, Storybook stories)
- Spec X.2+ → Engineers (wire up components to real state and backends)

**Contract surface:** Component prop types + design tokens. Designer-engineer ships untyped-stateful components with clear props; engineers wire them into real state.

## Choosing a pattern

Ask the user directly rather than guessing. If they describe their team as "FE and BE", confirm whether BE also owns client-side state/SQLite/network (Pattern A) or only the server (closer to Pattern D). The answer changes where Spec X.1's boundary sits.

## When to deviate

The patterns above cover the vast majority of cases, but some epics have features that cross a non-obvious boundary (e.g. a feature that's 99% backend but exposes a tiny FE banner). Two viable responses:

1. **Fold the tiny FE work into Spec X.1 anyway.** Keeps the "one FE spec per epic" rule intact.
2. **Treat it as pure-BE with a small FE PR attached.** The epic has no Spec X.1; the banner is captured as one acceptance criterion on the BE spec and a PR description. Use this only when the FE work is genuinely trivial (< 1 day).

Default to option 1 — preserving the rule reduces FE team's context-switching cost across epics.
