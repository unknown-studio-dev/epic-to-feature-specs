# Plan Split Patterns

Some sub-specs are large enough that hoangsa's resulting `plan.json` would exceed the ~250k-token sweet spot per cook session. AI quality degrades past that point — the "AI-rot" symptom. The fix is to pre-split the plan inside the sub-spec itself, so hoangsa receives guidance from the start instead of running into a budget overage at `/hoangsa:prepare` time.

This file documents the patterns the skill uses to decide IF a Plan Split section is needed and WHICH pattern to apply. The exact Plan Split section template lives in `templates/sub-spec.md` §7.

## Why split inside the sub-spec, not split into more sub-specs

Sub-specs are sized for one shippable PR. A typical 7.1.B-shaped sub-spec ships ~9 stories worth of cohesive work as a single Notion task. The work belongs together at the shipping layer — but it may not fit one hoangsa cook session at the AI layer.

The split lives inside the sub-spec because:
- The sub-spec is still one PR, one Notion card, one shipped unit of work.
- Plan-1 and Plan-2 produce ephemeral hoangsa sessions and intermediate code states (Plan-1 ships unused-but-tested substrate; Plan-2 wires it). Neither stands alone as a shippable thing.
- Splitting into two sub-specs would create an awkward Sub-spec 1 ("invisible code") that fails the user-value test.

So: one sub-spec = one PR. Optionally split into Plan-1 + Plan-2 inside.

## When to emit a Plan Split section (the trigger)

The skill runs a crude internal heuristic to decide. **The heuristic is internal-only — never emitted in the output.** Hoangsa runs `hoangsa-cli budget estimate` to confirm sizes when `/hoangsa:prepare` runs.

Internal heuristic — file count × per-type weight (rough proxy):

| File type | Rough token weight |
|---|---|
| UI screen / component (`.tsx`) | ~30k |
| Hook (`.ts`) | ~15k |
| Service / repository (`.ts`) | ~20k |
| Type definition file (`.ts`) | ~8k |
| Test file (`.test.ts(x)`) | ~20k |
| Storybook story (`.stories.tsx`) | ~8k |
| BE endpoint handler | ~25k |
| Migration (`.sql`) | ~10k |
| Route file (`.tsx` under `app/`) | ~12k |
| Config / barrel file | ~5k |

Sum across the sub-spec's In Scope file list. **Trigger threshold:** clearly above 250k. Be conservative — only split when clearly necessary. False positives (split unnecessarily) cost one extra coordination step; false negatives (don't split, plan overshoots) are surfaced by hoangsa during `/hoangsa:prepare` and the user can split there.

## Output discipline

When the trigger fires, emit the Plan Split section from `templates/sub-spec.md` §7. Two rules:

1. **Name the boundary by REQ + file category, not by token count.** No numbers in the output. Hoangsa is the budget authority — it will recalculate.
2. **Include the Coverage check footer.** The qualifier-overlap pattern (`REQ-11 (logic only)` in Plan-1, `REQ-11 (UI)` in Plan-2) reads as a coverage gap if not annotated. The Coverage check footer explicitly names the convention so no AI agent (or human reviewer) mistakes the overlap for a duplication or a drop.

## FE patterns

### FE-Plan — Substrate / Wiring (only FE pattern)

**Use when:** Sub-spec ships both logic (hooks, services, types) AND UI (components, screens, route wiring).

**Plan-1 — Substrate:**
- Types, interfaces, schemas
- Services + stubs (`AuthService`, `IAuthService` interface)
- Hooks (auth, biometric, onboarding)
- Stores (Zustand)
- Unit tests for hooks + services
- Fixtures (`__fixtures__/`)

**Plan-1 acceptance:** `tsc --noEmit` + hook/service tests pass. **No UI visible — by design.** The new code is unused-but-tested substrate until Plan-2 imports it.

**Plan-2 — Wiring:**
- Components + screens (`SignInScreen`, `OnboardingPager`, etc.)
- Storybook stories
- Route files (`sign-in.tsx`, `sign-up.tsx`, `onboarding.tsx`)
- Provider replacements (delete the stub from skeleton sub-spec, plug in real one)
- Modifications to `_layout.tsx` and other already-existing root files
- Feature barrels (`src/features/{auth,onboarding}/index.ts`)
- Component tests (RNTL)
- Route tests
- Detox happy-path scaffold (`describe.skip`)

**Plan-2 acceptance:** `tsc --noEmit` + component/route tests pass + `yarn build-storybook` succeeds.

**Why it works:** Plan-1 builds the testable mockable substrate; Plan-2 imports it and wires it into the app. Each plan is a single cook session in hoangsa, around 200–250k tokens. The two-plan sequence matches the natural review cadence — Plan-1 review focuses on shapes and contracts; Plan-2 review focuses on screens and pixel-fidelity.

## BE patterns

### BE-Plan-1 — Domain core / Transport (default for BE)

**Use when:** Sub-spec touches both data/business logic AND request handlers (the common case for a new endpoint, a new worker feature, or a new bounded context).

**Plan-1 — Domain core:**
- Types, zod schemas, DTOs
- DB migrations (if any)
- Repositories / data-access layer
- Services / domain logic / validators
- Unit tests for repositories + services

**Plan-1 acceptance:** `tsc --noEmit` (or language equivalent) + unit tests pass. **No HTTP exposed — by design.** Pure functions and pure data access; mockable and testable without the server running.

**Plan-2 — Transport:**
- HTTP handlers (controllers, route handlers)
- Route registration
- Middleware wiring (auth, validation, error handling)
- Dependency injection / app bootstrap modifications
- Integration tests (request-level)
- e2e tests (if applicable)

**Plan-2 acceptance:** `tsc --noEmit` + integration tests pass.

**Why it works:** Plan-1 ships a pure, testable domain layer that can be exercised without HTTP. Plan-2 exposes it over the network. Same stub-first energy as the FE pattern.

### BE-Plan-2 — Migration / Application (rare)

**Use when:** Sub-spec includes nontrivial migrations (>1 table change, data backfills, indexes) AND application logic on top. The split exists because migrations want a slower, more careful review cycle that's different from feature code.

**Plan-1 — Migration:**
- All `.sql` migration files
- Data backfill scripts
- Repository unit tests against the new schema
- Migration tests (forward + rollback if applicable)

**Plan-1 acceptance:** Migrations apply cleanly on a fresh DB; rollback works; repository tests pass against the new shape.

**Plan-2 — Application:**
- Services that depend on the new schema
- HTTP handlers
- Route registration
- Integration tests
- Any consumer code in other parts of the app

**Plan-2 acceptance:** `tsc --noEmit` + integration tests pass against the migrated schema.

**Why it works:** Migrations carry more deployment risk than code. Splitting them off lets ops review Plan-1 carefully (schema review, lock analysis, backfill safety) without blocking on application-layer details.

## Fallback — no split

Most sub-specs don't need a Plan Split. Skip the section entirely when:

- The sub-spec is single-concern: "add a field to an endpoint", "wire up Sentry", "fix one bug".
- The sub-spec is pure UI on existing hooks (no new substrate to build).
- The sub-spec is pure infrastructure (migrations only, config only).
- The heuristic sum is comfortably below the trigger threshold.

When skipping, omit the §7 Plan Split section entirely from the sub-spec. Absence of the section means "plan as one hoangsa session." Hoangsa's `/hoangsa:prepare` will design a single `plan.json` and `/hoangsa:cook` runs it.

## Output is advisory, not load-bearing

If the skill's heuristic gets it wrong:

- **False positive** (we suggested a split, hoangsa would've been fine): one extra coordination step, user can collapse Plan-1 and Plan-2 manually. Cheap mistake.
- **False negative** (we didn't suggest a split, plan ends up >300k after hoangsa's real budget estimate): hoangsa surfaces the overage during `/hoangsa:prepare` and the user does the split there manually. Same workflow they had before this skill existed.

The Plan Split section is the skill's recommendation. Hoangsa is the source of truth on tokens. This split of responsibility is intentional — the skill owns the **logical** decomposition (which REQs belong together); hoangsa owns the **physical** decomposition (which tasks fit in one cook session).
