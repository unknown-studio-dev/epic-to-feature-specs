# Cutting Strategies

How to decide where the seams in an epic go. Read this whenever you're about to split an epic.

## Decision tree

```
Does the epic involve two or more teams with different ownership?
│
├── YES → Use Dual-Team (horizontal-by-boundary)
│         Spec X.1 is always the presentation-team spec (captures ALL
│         of that team's work for the epic). Other specs split by the
│         non-presentation team's internal cohesion (service, stage,
│         or cross-cutting concern).
│
└── NO → Single team. Ask:
         │
         ├── Are the layers (UI / domain / data) genuinely separable,
         │   with contracts between them already enforced by types?
         │   │
         │   ├── YES → Horizontal-by-layer
         │   │
         │   └── NO → Would the first implementation slice deliver
         │           any user-visible value on its own?
         │           │
         │           ├── YES → Vertical-by-value-slice
         │           │
         │           └── NO → Contract-first scaffolding
```

## Strategy 1: Dual-Team (most common)

**Use when:** Teams are split by team charter — FE-only vs. BE-owning-everything-else is typical; could also be mobile-only vs. backend, designer-engineer vs. everyone, etc.

**Pattern:**
- Spec X.1 — Presentation team's entire surface for this epic. One spec per epic for that team so their reading load is minimized.
- Spec X.2 ... X.5 — Non-presentation team's work, split by internal cohesion.

**How to split X.2+:**
- By **service** (if different backend services are involved, one per spec)
- By **pipeline stage** (if the feature has sequential stages with different concerns — e.g. upload, transcription, structuring)
- By **cross-cutting concern** (e.g. "resilience" as its own spec when retry/backoff/DLQ logic wraps multiple stages)

**Contract requirement:** Spec X.1 depends on a TypeScript contract authored alongside X.2+. The contract is the seam.

**Why it works for AI coding:** FE team's agent reads Spec X.1 + contract, builds against mocks. BE team's agents each read one of X.2+, implement behind the contract. No agent holds the full epic.

**Failure mode to watch:** Spec X.1 gets too big because the epic's FE surface is genuinely large. If X.1 exceeds ~25 pages of spec or ~15 components, consider splitting the *epic* rather than splitting X.1 (your rule is one FE spec per epic — don't break it).

## Strategy 2: Horizontal-by-layer (single team)

**Use when:** One team does everything, AND the layers are naturally separable — e.g. a pure data-sync feature where UI, domain logic, and persistence layers can be developed and tested independently.

**Pattern:**
- Spec X.1 — UI + interaction
- Spec X.2 — Domain logic + state
- Spec X.3 — Persistence + network

**Contract requirement:** Types define inter-layer contracts. Each layer exposes a typed surface; others consume through it.

**Why it works:** Clean boundaries, each layer testable alone. One agent per layer.

**Failure mode:** Each spec alone delivers no user-visible value. The epic can't demo until all 3 land. If the epic has time pressure, prefer Strategy 3.

## Strategy 3: Vertical-by-value-slice (single team)

**Use when:** One team, AND you need incremental value delivery, OR the layers are too coupled to separate cleanly.

**Pattern:**
- Spec X.1 — Happy-path v1 (single thin slice, end-to-end)
- Spec X.2 — Error / edge cases (resilience)
- Spec X.3 — Scale / polish (rate limits, tier differentiation, performance)

**Contract requirement:** Spec X.1 defines the API/data shapes that X.2 and X.3 extend. Shapes must be forward-compatible to avoid rework.

**Why it works:** Each spec ships user value. X.1 can demo at the "Aha!" moment.

**Failure mode:** Forward-compatibility discipline is hard. If X.1's shapes turn out to need breaking changes in X.2, you've lost the benefit. Mitigation: over-design X.1's types slightly to absorb foreseeable X.2 cases.

## Strategy 4: Contract-first scaffolding

**Use when:** The feature has significant infrastructure (new services, new data stores, new type system extensions) that will be consumed by multiple implementations. Also: when AI coding agents need maximum enforced boundaries.

**Pattern:**
- Spec X.1 — Scaffolding: types, API route signatures (no impl), database migrations, queue definitions, TypeScript interfaces
- Spec X.2 — Consumer A implementation
- Spec X.3 — Consumer B implementation (or provider if X.2 is a consumer)

**Why it works:** The hardest decisions (shapes, boundaries) are made up front. X.2 and X.3 are "fill in the impl" — almost mechanical, highly AI-friendly.

**Failure mode:** Over-engineering. This pattern is often overkill for features where the contract is obvious. Reserve for cases where the infra itself is non-trivial.

## Choosing the right strategy — examples

| Epic shape | Strategy |
|---|---|
| App has FE + BE teams; epic has user-facing feature with backend pipeline | Dual-Team |
| Small team builds offline sync feature with independent UI/domain/data layers | Horizontal-by-layer |
| Small team has 3 weeks to ship something the founder can demo | Vertical-by-value-slice (ship X.1 first) |
| New microservice with typed API consumed by 2 clients | Contract-first scaffolding |

## Anti-pattern: arbitrary splits

Do not cut by *time* ("week 1 work" vs. "week 2 work") or by *person* ("Alice's stuff" vs. "Bob's stuff"). Cuts must follow implementation boundaries — files touched, services called, contracts exposed. Time-based or person-based cuts create specs with arbitrary scope that fail the SMART-independence check.
