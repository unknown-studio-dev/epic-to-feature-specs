# Sub-Spec Cutting Strategies

How to decompose a feat spec into 3–5 sub-specs (capped at `.E` per parent feat spec). Read this before drafting any sub-spec.

A sub-spec is the layer between feat spec and hoangsa session. Each sub-spec is one shippable PR, ~5–15 stories, written as a Notion page and pasted into the repo at `<spec_storage>/sub-specs/spec-X.Y.{letter}-<slug>.md`.

> **Cross-reference:** for cutting epics into feat specs, see `cutting-strategies.md`. This file covers only the feat-spec → sub-spec layer.

## The default cutting principle: stub-first

At every layer of decomposition, the dominant pattern is **stub-first**. The first sub-spec ships the structural skeleton — provider chain, root layout, navigation root, base services — with stubs for everything its siblings will fill in. Later sub-specs replace stubs one by one.

Concretely, this means:

1. **The skeleton sub-spec ships stubs.** Provider chain wraps the app, but every provider whose config belongs to a sibling is a pass-through stub (e.g. `<RevenueCatProvider>` that just renders children, until 7.1.D ships its config).
2. **Each consumer sub-spec replaces its predecessor's stubs.** When 7.1.D ships, it deletes the stub provider and replaces it with the configured one. The import site doesn't change.
3. **Out of Scope names the sibling owner of each deferred piece** — by sub-spec ID. *"Real provider implementations — sibling sub-specs own; ship stubs only. Sign-in screens (7.1.B). Settings (7.1.C). Paywall (7.1.D)."*

Why this works: every sub-spec is independently shippable AND independently testable. No sub-spec waits for a sibling. Each PR is mergeable without breaking the build. AI coding agents have a bounded surface area and a clear contract for what to mock.

## Decision tree

```
What does the parent feat spec look like?
│
├── FE feat spec (presentation team owns)
│   └── Apply FE patterns in order:
│       1. Co-shipping coupled foundations (skeleton sub-spec — always first)
│       2. Surface area (one sub-spec per coherent user-facing surface)
│       3. Stub-first dependent (when one surface depends on another's primitive)
│
├── BE feat spec (one or more backend teams)
│   └── Apply BE patterns:
│       1. Service / domain boundary (default — one sub-spec per service or bounded context)
│       2. Endpoint cluster (when a single service has too many endpoints for one sub-spec)
│
└── Small / single-concern feat spec
    └── Fallback — single sub-spec (no decomposition needed)
```

## FE patterns

### FE-1: Co-shipping coupled foundations (always the first FE sub-spec)

**Use when:** Drafting the first sub-spec from any FE feat spec.

**What it bundles:** Pieces that share an integration file (`_layout.tsx`, root provider chain, app bootstrap), or that would crash if shipped alone. Common contents:

- Navigation root + tab bar / drawer
- Provider chain (with stubs for sibling-owned providers)
- Local DB / storage layer (because navigation often gates rendering on it)
- Bootstrap-time encryption / key generation
- Empty route shells for siblings to fill (`<inbox.tsx>`, `<library.tsx>` as placeholders)

**Why bundle them:** They share a single file (`_layout.tsx`) as the integration point. Splitting them would create a navigator that crashes when child screens try to read the DB, or a provider chain that throws before any screen renders.

**Quote from the canonical example (Spec 7.1.A):** *"Groups together two concerns that are technically separate but are tightly coupled at the launch sequence: the navigator + provider chain (which boots first) and the SQLite layer (which boots immediately after, gated by the providers). They share `_layout.tsx` as the integration point so it is cleaner to ship them together than to ship a navigator that crashes when child screens try to read the DB."*

**Sizing target:** ~9 stories, ~150 lines of sub-spec markdown.

### FE-2: Surface area (one sub-spec per coherent user-facing surface)

**Use when:** Drafting sub-specs 2 through N after the skeleton.

**What it bundles:** All FE work for a single coherent user surface — Auth + Onboarding, Settings, Subscription, Paywall, Home, etc. Each surface ships:

- Its feature module (`src/features/<area>/{components, hooks, services, stores, types}`)
- Its routes
- Its tests + Storybook stories
- The piece that replaces a stub from the skeleton sub-spec (e.g. `<FirebaseAuthBridge>` replaces 7.1.A's stub)

**How to know it's coherent:**
- The user can complete a single end-to-end task within this surface (sign in, change a setting, upgrade their plan).
- The screens are tightly sequenced (`onboarding → sign-up → mic-permission → home`).
- The data layer they read/write is mostly their own; cross-surface reads happen through hooks owned by another sub-spec.

**Quote from the canonical example (Spec 7.1.B):** *"Groups auth and onboarding together because the screens are tightly sequenced (`onboarding → sign-up → mic-permission → home`) and the navigation logic between them is shared. Splitting them would create artificial seams where one sub-spec needs to mock another's navigation."*

**Sizing target:** ~9 stories per surface, ~150–250 lines of sub-spec markdown.

### FE-3: Stub-first dependent

**Use when:** A surface (FE-2) consumes a primitive owned by another surface — e.g. Settings reads `useFeatureGate` from Subscription; Paywall consumes `usePurchase` from Subscription.

**How to handle:** The consuming sub-spec ships the consumer as if the producer's stub is real. The producer sub-spec ships the real impl that replaces the stub.

**In the consuming sub-spec's Out of Scope:** *"Real `useFeatureGate` implementation — 7.1.D owns. We import the typed hook and mock its return values for testing."*

**In the producing sub-spec's Out of Scope:** *"Settings sub-screen content — 7.1.C owns. We expose `useFeatureGate` as a typed hook with full impl; 7.1.C consumes it via import."*

This pattern doesn't need its own sub-spec — it's a discipline applied within FE-2 sub-specs.

## BE patterns

### BE-1: Service / domain boundary (default)

**Use when:** Drafting sub-specs from a BE feat spec.

**What it bundles:** All work for one service, one worker, or one bounded context. Each sub-spec ships:

- Type definitions / schemas for this service
- Migrations (if the service owns its own data store)
- Data-access layer (repositories, ORM models)
- Business logic / services / use cases
- HTTP handlers + route registration
- Tests at all levels

**Why service-boundary first:** Most BE feat specs already split at the service level (e.g. Auth service vs. Subscription Sync worker). One sub-spec per service is the cleanest mapping. Cross-service contracts are already frozen at the feat-spec layer.

**When to escalate beyond one sub-spec per service:** When a single service has so many endpoints or domain concerns that it exceeds the ~15-story sub-spec ceiling. Then apply BE-2.

### BE-2: Endpoint cluster

**Use when:** A single service is too large for one sub-spec.

**What it bundles:** Group endpoints by user-facing capability — Auth endpoints, User-management endpoints, Subscription endpoints, Webhook handlers. Each cluster gets its own sub-spec.

**Cohesion test:** Endpoints in the same cluster typically share repositories, validators, and middleware. Endpoints in different clusters usually don't.

**Example:** A single Cloudflare Worker that handles auth + user CRUD + subscription sync might decompose into:
- BE Sub-spec 1 — Bootstrap + JWT verification + auth endpoints
- BE Sub-spec 2 — User CRUD + delete cascade
- BE Sub-spec 3 — Subscription sync + webhook handlers

## Fallback: single sub-spec (no decomposition)

**Use when:** The parent feat spec is already small. Decomposing into multiple sub-specs would add coordination overhead without reducing AI context size.

**Signals:**
- The feat spec is < ~10 user stories total.
- The feat spec touches one feature module / one service / one screen with its API.
- The feat spec is a "wire up X" or "add field Y" change.

**What to do:** Output a single sub-spec (e.g. `Spec 4.1.A — <scope>`) covering the entire feat spec. Mark it `.A` and note in §3 *"No siblings — this feat spec ships as one sub-spec."*

## Anti-patterns

- **Cutting by layer within a single user-facing surface.** Don't make Sub-spec X.Y.A "types and hooks" and Sub-spec X.Y.B "components" as separate sub-specs. That belongs in **Plan Split** within a single sub-spec — see `plan-split-patterns.md`. Sub-specs are shippable PRs; layer splits don't ship independently.
- **Cutting by time** ("this week's work" vs. "next week's"). Cuts must follow integration boundaries, not calendar boundaries.
- **Cutting by person** ("Alice's sub-spec" vs. "Bob's"). Same reason — fails SMART-independence.
- **More than 5 sub-specs per feat spec.** Hard ceiling at `.E`. If you need 6+, the parent feat spec itself should be split — escalate to the user before overflowing.
- **Anonymous deferrals in Out of Scope.** *"Owned by another sub-spec"* fails SMART-independence. Always name the sibling sub-spec by ID.
- **Skeleton sub-spec that doesn't ship stubs for siblings.** If 7.1.A omits provider stubs, then 7.1.B, .C, .D, .E each have to add the provider chain back to `_layout.tsx`, creating merge conflicts. Skeleton sub-spec MUST ship stubs.

## Examples

| Feat spec shape | Sub-specs produced |
|---|---|
| FE — App Foundation (35 stories, all FE for one epic) | 7.1.A skeleton (nav + SQLite + audio enc), 7.1.B Auth + Onboarding, 7.1.C Settings, 7.1.D Subscription + Paywall, 7.1.E Monitoring + Home |
| BE — Cloudflare Auth Worker (20 stories, one service) | 7.2.A Bootstrap + JWT verification + auth endpoints, 7.2.B User CRUD + delete cascade |
| BE — Single migration + new field on one endpoint (3 stories) | 4.2.A only (single sub-spec, no decomposition) |
| FE — Settings v2 (12 stories, one surface) | 8.1.A only (single sub-spec, no decomposition) |
