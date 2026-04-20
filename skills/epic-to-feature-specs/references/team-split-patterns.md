# Team Split Patterns

How to map team structure to spec ownership. Read this when deciding who reads which spec.

The right pattern depends on two things: (1) the user's persona (detected in Step 1 of the workflow), and (2) their actual team structure. Patterns A-E are for multi-team setups (common with PM and technical lead personas). Patterns F-G are for solo and single-team setups.

## Pattern A: FE + BE (most common for PM persona)

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

**Design integration:** FE Spec X.1 should include a full UI Design Reference section mapping every screen from the design to user stories and acceptance criteria. This is where design-to-spec alignment is enforced.

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

**Design integration:** Web FE and Mobile may reference different design files (web mockups vs. mobile mockups). Each presentation spec gets its own UI Design Reference section pointing to the platform-specific designs.

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

**Design integration:** This pattern benefits most from design tool integration — the designer-engineer's spec should directly reference Figma/Pencil components and export design tokens as part of the deliverable.

## Pattern F: Solo developer (full-stack)

**Persona:** Technical user implementing everything themselves. They want specs to break work into manageable AI-codeable chunks, not to coordinate across teams.

**Team charter:** One person owns everything. No handoff needed — the "contract" is for AI agent boundaries, not team coordination.

**Spec assignment:** Typically follows vertical-by-value-slice:
- Spec X.1 → Happy-path end-to-end (thin slice, demoable)
- Spec X.2 → Error handling + resilience
- Spec X.3 → Polish, edge cases, performance

Alternative: by feature area if the epic has naturally isolated subfeatures.

**Contract surface:** Optional but recommended. Typed interfaces between specs help AI agents stay bounded. The "freeze before coding" discipline doesn't apply — the solo dev can amend freely. But "coarser than internals" still helps: define the interface between layers so each spec's agent doesn't need full context.

**Design integration:** Lightweight — link to designs and list key components. The solo dev extracts implementation details themselves. Include state-to-screen mapping if the designs cover multiple states.

**What's different from Pattern C:** Pattern C assumes a team that still needs coordination (standups, PRs, shared ownership). Pattern F assumes one person who wants AI agents to do bounded work. The specs are less formal, contracts are optional, and the prose companion is skipped.

## Pattern G: Technical lead with custom boundaries

**Persona:** A technical lead who understands the codebase and wants to split by service, domain, or architectural boundary rather than by team role.

**Team charter:** Varies — could be one team or multiple, but the split is driven by the codebase architecture, not team roles.

**Spec assignment:** User-defined. Common patterns:
- By service: Spec X.1 → Auth service, X.2 → Payment service, X.3 → Notification service
- By domain: Spec X.1 → User management, X.2 → Billing, X.3 → Reporting
- By layer with custom boundaries: Spec X.1 → API layer, X.2 → Business logic, X.3 → Data access

**Contract surface:** Typed interfaces between the boundaries the user defines. These may be REST API contracts, message queue schemas, or internal module interfaces — not necessarily the FE ↔ BE pattern.

**Design integration:** Medium depth — reference designs and map screens to specs, but the technical lead handles the implementation details. Focus the design section on which spec owns which screens and components, so there's no ambiguity about where UI work lives.

**What's different from other patterns:** The skill doesn't prescribe the split — it follows the user's architectural judgment. The skill's job is to validate SMART-independence and produce clean contracts at the boundaries the user defines, not to argue for a different structure.

## Choosing a pattern

**Step 1: Check the persona** (from the workflow's Step 1):
- PM / non-technical → Default to Pattern A (FE + BE). Confirm with follow-up questions.
- Technical lead → Ask how they want to split. Map to Pattern A-E or G.
- Solo developer → Pattern F.

**Step 2: Confirm the details.** If the user describes their team as "FE and BE", confirm whether BE also owns client-side state/SQLite/network (Pattern A) or only the server (closer to Pattern D). The answer changes where Spec X.1's boundary sits.

**Step 3: Don't force a pattern.** If the user describes something that doesn't fit any pattern above, that's fine — create specs along the boundaries they describe and validate SMART-independence. The patterns are guidance, not constraints.

## When to deviate

The patterns above cover the vast majority of cases, but some epics have features that cross a non-obvious boundary (e.g. a feature that's 99% backend but exposes a tiny FE banner). Two viable responses:

1. **Fold the tiny FE work into Spec X.1 anyway.** Keeps the "one FE spec per epic" rule intact.
2. **Treat it as pure-BE with a small FE PR attached.** The epic has no Spec X.1; the banner is captured as one acceptance criterion on the BE spec and a PR description. Use this only when the FE work is genuinely trivial (< 1 day).

Default to option 1 for PM personas — preserving the rule reduces FE team's context-switching cost across epics. For technical leads and solo devs, use their judgment.
