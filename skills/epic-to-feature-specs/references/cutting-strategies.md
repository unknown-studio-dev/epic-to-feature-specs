# Cutting Strategies

How to decide where the seams in an epic go. Read this whenever you're about to split an epic into feat specs.

> **Cross-reference:** for cutting a feat spec into sub-specs (the optional Step 11 layer), see `sub-spec-cutting.md`. This file covers only the epic → feat spec layer.

## Decision tree

The entry point depends on the user's persona (detected in Step 1 of the workflow):

```
What persona is the user?
│
├── PM / non-technical
│   └── Does the epic involve two or more teams with different ownership?
│       │
│       ├── YES (typical) → Use Dual-Team (Strategy 1)
│       │   Spec X.1 is always the presentation-team spec.
│       │   Other specs split by non-presentation team's internal cohesion.
│       │
│       └── NO (rare for PM persona) → Ask if they want to split by value slice
│           or by layer. Default to Vertical-by-value-slice (Strategy 3).
│
├── Technical lead
│   └── How did they say they want to split? (from Step 2)
│       │
│       ├── By team boundary → Use Dual-Team (Strategy 1)
│       ├── By service/domain → Use Service-Domain (Strategy 5)
│       ├── By layer → Use Horizontal-by-layer (Strategy 2)
│       ├── By value slice → Use Vertical-by-value-slice (Strategy 3)
│       └── Custom → Validate their proposed boundaries are SMART-independent,
│                     then create specs along those boundaries
│
└── Solo developer
    └── What split did they prefer? (from Step 2)
        │
        ├── By value slice (default) → Use Vertical-by-value-slice (Strategy 3)
        ├── By layer → Use Horizontal-by-layer (Strategy 2)
        ├── By feature area → Use Service-Domain (Strategy 5), adapted
        └── Let the skill decide → Evaluate:
            │
            ├── Can the first slice deliver user value? → Vertical-by-value-slice
            ├── Are layers cleanly separable? → Horizontal-by-layer
            └── Is infra a big lift? → Contract-first scaffolding (Strategy 4)
```

## Strategy 1: Dual-Team (most common for PM persona)

**Use when:** Teams are split by team charter — FE-only vs. BE-owning-everything-else is typical; could also be mobile-only vs. backend, designer-engineer vs. everyone, etc.

**Persona fit:** PM / non-technical (default), Technical lead (if they chose team-boundary split).

**Pattern:**
- Spec X.1 — Presentation team's entire surface for this epic. One spec per epic for that team so their reading load is minimized.
- Spec X.2 ... X.5 — Non-presentation team's work, split by internal cohesion.

**How to split X.2+:**
- By **service** (if different backend services are involved, one per spec)
- By **pipeline stage** (if the feature has sequential stages with different concerns — e.g. upload, transcription, structuring)
- By **cross-cutting concern** (e.g. "resilience" as its own spec when retry/backoff/DLQ logic wraps multiple stages)

**Contract requirement:** Spec X.1 depends on a TypeScript contract authored alongside X.2+. The contract is the seam.

**Design integration:** Spec X.1 must include a full UI Design Reference section (see template Section 5) when designs are available. This maps every screen from the design to user stories, lists components used, and maps contract states to design screens. For PM personas, this section is especially important as the bridge between designer intent and developer output.

**Why it works for AI coding:** FE team's agent reads Spec X.1 + contract + design reference, builds against mocks. BE team's agents each read one of X.2+, implement behind the contract. No agent holds the full epic.

**Failure mode to watch:** Spec X.1 gets too big because the epic's FE surface is genuinely large. If X.1 exceeds ~25 pages of spec or ~15 components, consider splitting the *epic* rather than splitting X.1 (your rule is one FE spec per epic — don't break it).

## Strategy 2: Horizontal-by-layer (single team or solo)

**Use when:** One team or solo dev does everything, AND the layers are naturally separable — e.g. a pure data-sync feature where UI, domain logic, and persistence layers can be developed and tested independently.

**Persona fit:** Technical lead (if they chose layer split), Solo developer (if they chose layer split).

**Pattern:**
- Spec X.1 — UI + interaction
- Spec X.2 — Domain logic + state
- Spec X.3 — Persistence + network

**Contract requirement:** Types define inter-layer contracts. Each layer exposes a typed surface; others consume through it. For solo developers who opted out of typed contracts, document the boundaries in markdown instead.

**Design integration:** Spec X.1 (UI layer) carries the design reference. Specs X.2 and X.3 reference Spec X.1's design section to understand what states and data shapes the UI expects.

**Why it works:** Clean boundaries, each layer testable alone. One agent per layer.

**Failure mode:** Each spec alone delivers no user-visible value. The epic can't demo until all 3 land. If the epic has time pressure, prefer Strategy 3.

## Strategy 3: Vertical-by-value-slice (single team or solo)

**Use when:** One team or solo dev, AND you need incremental value delivery, OR the layers are too coupled to separate cleanly.

**Persona fit:** Solo developer (default), Technical lead (if they chose value-slice split), PM with a single team.

**Pattern:**
- Spec X.1 — Happy-path v1 (single thin slice, end-to-end)
- Spec X.2 — Error / edge cases (resilience)
- Spec X.3 — Scale / polish (rate limits, tier differentiation, performance)

**Contract requirement:** Spec X.1 defines the API/data shapes that X.2 and X.3 extend. Shapes must be forward-compatible to avoid rework.

**Design integration:** Spec X.1 references the "happy path" design screens. Spec X.2 references error/empty/loading state designs. Spec X.3 references any edge-case or performance-related design variants (e.g. skeleton loaders, pagination). If designs only cover the happy path, note the gaps in Spec X.2 and X.3.

**Why it works:** Each spec ships user value. X.1 can demo at the "Aha!" moment. Best for solo developers who want to ship incrementally.

**Failure mode:** Forward-compatibility discipline is hard. If X.1's shapes turn out to need breaking changes in X.2, you've lost the benefit. Mitigation: over-design X.1's types slightly to absorb foreseeable X.2 cases.

## Strategy 4: Contract-first scaffolding

**Use when:** The feature has significant infrastructure (new services, new data stores, new type system extensions) that will be consumed by multiple implementations. Also: when AI coding agents need maximum enforced boundaries.

**Persona fit:** Technical lead (complex infra), Solo developer (new service/system setup).

**Pattern:**
- Spec X.1 — Scaffolding: types, API route signatures (no impl), database migrations, queue definitions, TypeScript interfaces
- Spec X.2 — Consumer A implementation
- Spec X.3 — Consumer B implementation (or provider if X.2 is a consumer)

**Why it works:** The hardest decisions (shapes, boundaries) are made up front. X.2 and X.3 are "fill in the impl" — almost mechanical, highly AI-friendly.

**Failure mode:** Over-engineering. This pattern is often overkill for features where the contract is obvious. Reserve for cases where the infra itself is non-trivial.

## Strategy 5: Service-Domain (technical lead)

**Use when:** A technical lead wants to split by service, domain, or architectural boundary rather than by team role or layer.

**Persona fit:** Technical lead (primary), rarely used by other personas.

**Pattern:**
- Spec X.1 — Service/domain A (e.g. Auth service, User management)
- Spec X.2 — Service/domain B (e.g. Payment pipeline, Billing)
- Spec X.3 — Service/domain C (e.g. Notification system, Reporting)

**Contract requirement:** Typed interfaces at service/domain boundaries. These might be REST API contracts, message queue schemas, gRPC definitions, or internal module interfaces — not necessarily the FE ↔ BE pattern from Strategy 1.

**Design integration:** Assign UI screens to the service/domain that owns the data behind them. If one screen pulls data from multiple services, the spec that owns the primary data source owns the screen; other specs expose the data through contracts.

**How to identify boundaries:** Ask the technical lead. If they can't articulate boundaries, help them by looking at:
- Which services/repos will be modified
- Where data flows cross a network or process boundary
- Where different teams or on-call rotations own different parts

**Why it works:** Respects the codebase architecture. Each spec maps to a natural deployment or ownership boundary. AI agents work within one service at a time.

**Failure mode:** Services that are too tightly coupled for independent specs. If service A can't be tested without service B running, the boundary isn't clean enough — consider merging or using contract-first scaffolding first.

## Choosing the right strategy — examples

| Epic shape | Persona | Strategy |
|---|---|---|
| App has FE + BE teams; epic has user-facing feature with backend pipeline | PM | Dual-Team |
| Same epic, but user is the tech lead who manages both teams | Tech lead | Dual-Team or Service-Domain (user's choice) |
| Solo dev builds offline sync feature with independent UI/domain/data layers | Solo | Horizontal-by-layer |
| Solo dev has 3 weeks to ship something demoable | Solo | Vertical-by-value-slice (ship X.1 first) |
| Tech lead splitting work across auth, payment, and notification services | Tech lead | Service-Domain |
| New microservice with typed API consumed by 2 clients | Tech lead | Contract-first scaffolding |
| PM with a single team, no FE/BE split | PM | Vertical-by-value-slice (default for single team) |

## Anti-pattern: arbitrary splits

Do not cut by *time* ("week 1 work" vs. "week 2 work") or by *person* ("Alice's stuff" vs. "Bob's stuff"). Cuts must follow implementation boundaries — files touched, services called, contracts exposed. Time-based or person-based cuts create specs with arbitrary scope that fail the SMART-independence check.

This applies to all personas. Even a solo developer shouldn't split by "what I'll do this week" — split by what can be independently verified.
