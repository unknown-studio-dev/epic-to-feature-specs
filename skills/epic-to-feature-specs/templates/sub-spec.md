# Sub-Spec {epic}.{feat-spec}.{letter} — {Short Scope}

> **Parent spec:** `<path to parent feat spec>` §<section list>
> **Contracts:** `<path/to/contract.ts>` (consumed) — or `none consumed directly` for purely structural sub-specs
> **Stories:** <comma-separated story IDs inherited from the parent feat spec, e.g. FND-01, FND-02, FND-03b, FND-10>

> **Status:** Draft | Reviewed | Frozen | Implementing | Shipped
> **Effort:** Low | Medium | High (inherited by Notion property)
> **Priority:** Inherited from epic
> **Tags:** Inherited from parent feat spec team tag

## 1. Context

Two to four sentences linking this sub-spec back to the parent feat spec's scope and to the user journey this sub-spec enables. Quote the cohesion rationale — *why these stories ship together as one PR* (shared layout file, sequential UX flow, shared layer of code, integration-time coupling). The cohesion sentence is what justifies the cut and prevents the AI agent from re-arguing the boundary.

Optional second paragraph: if this sub-spec uses the stub-first pattern, name which stubs from sibling sub-specs it replaces and which stubs of its own siblings will replace later. Example: *"Replaces 7.1.A's `<FirebaseAuthBridge>` stub. Its own `useDeleteAccount` hook is consumed by 7.1.C's Account screen (which ships later)."*

## 2. SMART Outcome

A single paragraph that satisfies SMART independently of sibling sub-specs:

- **Specific:** what exactly will exist when this is done — concrete screens, hooks, services
- **Measurable:** how we know it works — using mocked siblings if needed
- **Achievable:** sized for one shippable PR (~5–15 stories, one cohesive surface)
- **Relevant:** ties back to the parent feat spec's SMART Outcome
- **Time-bound:** target completion date or milestone

Example: *"A first-launch user sees the onboarding pager (`OB1 → OB2 → OB3 → OB3b → OB3c if eligible → OB4`), taps Get Started, lands on Sign Up (frame `2WxUS`), signs up with Apple or Google via Firebase native sheet, grants microphone permission (frame `MZyXC`), and is routed to `(tabs)/home`. A returning user lands on Sign In (`uVMBY`) and goes straight to home. **Success measured by:** Storybook fixtures for every auth/onboarding screen against canned `AuthUser` shapes; interaction tests for the seven flows; Detox happy-path E2E (cold launch → onboarding → sign up → mic permission → home)."*

## 3. Scope

### In Scope

Concrete file list grouped by feature module. Be specific — name files, hooks, services, components. Reference parent feat spec sections to avoid duplicating prose.

Example structure:

**Auth feature module (`src/features/auth/`):**
- `services/AuthService.ts` — `IAuthService` + concrete impl wrapping `@react-native-firebase/auth`. Stub returns canned `AuthUser`.
- `hooks/useAuthSession.ts` — wraps `firebase.auth().onAuthStateChanged`. Exposes `{ status, user }`.
- `components/SignInScreen.tsx` — frame `uVMBY`. Wordmark + value-prop + Apple/Google CTAs.

**Routes (`src/app/`):**
- `sign-in.tsx`, `sign-up.tsx`, `mic-permission.tsx`, `onboarding.tsx`.

### Out of Scope (Within This Sub-Spec)

**Each deferred piece MUST name its sibling sub-spec by ID.** Anonymous deferrals ("owned by another sub-spec") do not satisfy SMART independence — name the sibling.

Example:
- BE endpoints — mocked via fixture (Spec 7.2 owns).
- Account / Storage screens — **7.1.C owns**; this sub-spec ships the `useDeleteAccount` / `useSignOut` hooks they call.
- Settings sub-screens — **7.1.C owns**.
- Paywall — **7.1.D owns**.
- RevenueCat client SDK initialisation — **7.1.D owns**; this sub-spec mocks `Purchases.getOfferings()` for OB3c.
- Custom WebView for OAuth — use Firebase native sheets (Gold-plating warning, parent §3.2).

## 4. Design Reference

> Use this section for any sub-spec with user-facing work. Skip entirely for pure infrastructure or backend sub-specs.

### 4.1 Frame Map

| Frame ID | Frame Name | Stories | What It Shows |
|---|---|---|---|
| `uVMBY` | 0 - Sign In | FND-06 | Wordmark + Apple/Google CTAs + Sign-up link. |
| `2WxUS` | 0b - Sign Up | FND-05 | Same structure with sign-up copy. |
| `(gap)` | Biometric prompt | FND-07 | OS-native only until designer ships (parent §5.5 row 1). |

Only list frames this sub-spec touches. Inherit design tokens from the parent feat spec — cite the parent §5.3 rather than re-listing.

### 4.2 Component Inventory (when applicable)

List only NEW components this sub-spec builds, or existing components whose variants need extending. Components inherited unchanged from the parent feat spec's inventory don't need re-listing.

### 4.3 Tokens

One-line cite: *"Inherits all tokens from parent feat spec §5.3. Calls out only: `$accent-orange` (CTAs), `$bg-cream`, `$bg-card`."*

## 5. Contracts Consumed

> Sub-specs **consume** contracts; they do not author them. Contracts are authored at the feat-spec layer, frozen there, and this sub-spec just lists what it imports.

From `<path/to/contract.ts>`:
- `AuthUser`, `Email`, `UserId`, `IsoDateTime`, `AuthProvider`
- `GET /v1/me`, `POST /v1/me`, `DELETE /v1/me` HTTP shapes
- `AUTH_HEADER`, `BEARER_PREFIX`
- `AuthErrorCode`, `AuthError`

If this sub-spec consumes no contracts (pure structural / scaffolding work), write: *"No contracts consumed — this sub-spec is structural."*

## 6. Acceptance Criteria

> **REQ-ready format.** Each AC is a single atomic, testable condition. Each AC is tagged with its parent feat-spec story ID. Hoangsa's `/hoangsa:menu` maps each AC 1:1 to a `[REQ-xx]` marker in `DESIGN-SPEC.md`. Do NOT group ACs under story headings — flat numbered list only.

Group by sub-area heading for readability, but keep ACs flat-numbered across the whole sub-spec.

### Auth client

- **AC1 (FND-05/06):** Apple + Google sign-in complete via Firebase native sheets and surface `useAuthSession.status='authenticated'`.
- **AC2 (FND-05):** First sign-in path: `useCurrentUser` receives 404 from `GET /v1/me` → calls `POST /v1/me` → re-fetches → returns `AuthUser`.
- **AC3 (FND-05):** Apple private-relay email stored as-is — no UI to "enter your real email".
- **AC4:** `apiClient` injects `Authorization: Bearer <token>` on every request; 401 triggers one refresh-and-retry; second 401 surfaces `unauthenticated` error.

### Auth screens

- **AC5 (FND-22c):** `useSignOut` clears Firebase session and navigates to `/sign-in`; local SQLite + SecureStore preserved.
- **AC6 (FND-22d):** `useDeleteAccount` runs in order: re-auth → `DELETE /v1/me` → Firebase delete → SQLite wipe → SecureStore wipe → navigate to `/onboarding`. Failure at any step does not proceed.
- **AC7 (FND-05):** `SignUpScreen` renders frame `2WxUS` pixel-for-pixel; tapping Apple/Google triggers the corresponding hook.

### Onboarding

- **AC8 (FND-08):** First launch (no `onboarding_completed` in SecureStore) renders `OnboardingPager` starting at OB1.
- **AC9 (FND-08):** Swipe order: `OB1 → OB2 → OB3 → OB3b → OB3c (if eligible) → OB4`.
- **AC10:** PostHog `onboarding_completed` (or `onboarding_skipped`) fires with screen index.

> Aim for 10–20 ACs per sub-spec. Fewer than 5 = sub-spec is too small (merge with sibling or roll back into parent feat spec). More than 25 = sub-spec is too big (decompose further, but watch the .E ceiling).

## 7. Plan Split (input to /hoangsa:prepare)

> **Include this section only when the skill's internal heuristic clearly flags a Plan Split is needed** (substantial logic + UI surface area, or substantial schema + handlers, etc.). For single-plan sub-specs, omit this section entirely — absence of a Plan Split section means "plan as one hoangsa session."
>
> The skill never emits token numbers here. Hoangsa runs `hoangsa-cli budget estimate` to confirm sizes when `/hoangsa:prepare` runs. This section names the **boundary** (which REQs and files go where), not the **size**.

Recommend two sequential plans so each cook session stays around the ~250k-token sweet spot.

### Plan-1 — {Substrate label — e.g. "Foundation"}

**Scope:** {one-sentence summary, e.g. "types, services, hooks, unit tests. No UI, no route changes."}

**Files (all CREATE):**
- `<path/glob>` (e.g. `src/features/auth/{types.ts, services/*, stores/*, hooks/*}`)
- `<path/glob>` (e.g. `src/features/auth/__tests__/*` — hook tests only)

**REQs:**
- Full: REQ-XX, REQ-XY, …
- Partial: REQ-XX *(logic only — hook + tests; UI prompt in Plan-2)*
- Partial: REQ-XY *(logic only — flag hook; pager rendering in Plan-2)*

**Acceptance:** `<runnable command>` (e.g. `npx tsc --noEmit` + hook tests pass). The new code is unused-but-tested substrate until Plan-2 imports it. **No UI visible — by design.**

### Plan-2 — {Wiring label — e.g. "UI + Routes"}

**Depends on:** Plan-1 merged to working branch.

**Scope:** {one-sentence summary, e.g. "screens + storybook stories + route wiring + component tests + integration scaffold."}

**Files:**
- CREATE: `<paths>` (e.g. component files, story files, route files, test files)
- MODIFY: `<paths>` (e.g. `_layout.tsx`, provider chain wiring, existing route updates)

**REQs:**
- Full: REQ-XX, REQ-XY, …
- Partial (completes Plan-1): REQ-XX *(UI — BiometricUnlockGate screen)*, REQ-XY *(UI realization — OnboardingPager mounting)*

**Acceptance:** `<runnable command>` (e.g. `npx tsc --noEmit` + component/route tests + `yarn build-storybook` succeeds).

### Coverage check

Every REQ in §6 is either:
- **fully in one plan**, OR
- **split across both with an explicit qualifier** — `(logic only)`, `(UI)`, or `(UI realization)` — naming exactly which part each plan ships.

No REQ is dropped between plans. After both plans merge, every REQ in §6 is satisfied end-to-end.

## 8. Dependencies

- **Hard:** Sibling sub-spec(s) this depends on having shipped first (e.g. *"Spec 7.1.A — provider chain, SQLite, `DatabaseService.reset()` called in `useDeleteAccount`"*).
- **Mocked:** External specs whose contracts this consumes via fixture (e.g. *"Spec 7.2 (`/v1/me` endpoints) via fixture in `__fixtures__/auth.ts`"*).
- **External:** npm packages, native SDKs, infra (e.g. *"`@react-native-firebase/auth`, `expo-apple-authentication`, `expo-local-authentication`, `react-native-pager-view`."*).

## 9. Test Plan

How we verify this sub-spec independently (with sibling sub-specs mocked):

- **Storybook:** every screen + every variant; hook state walks.
- **Hook tests:** specific hook behaviour assertions.
- **Interaction (RNTL):** screen-level interaction assertions.
- **Visual regression:** snap each frame from §4.
- **Locale / i18n:** any locale-specific rendering.
- **Detox happy path:** cold-launch through to terminal state of this sub-spec's flow.

Every test must be runnable with sibling sub-specs mocked. If a test requires a sibling to be live, the sub-spec boundary is wrong — re-cut.

## 10. Decisions Already Made

> Cite from parent feat spec, tech doc, or repo memory — do not re-litigate.

- Firebase Auth with Apple + Google providers (Tech Doc §8.2).
- Use Firebase native sheets; do NOT build custom WebView (parent §3.2).
- Re-auth window of 5 minutes for destructive ops (Spec 7.2 §3.6).
- `DeleteConfirmModal` is the single confirm component (`project_instanote_ux_patterns`).
- Onboarding order resolved (parent §5.5 row 5).
- All in-app prices fetched from RevenueCat `localizedPriceString`.

If any decision shaping this sub-spec is NOT in a parent doc, record it here as an ADR-style statement so AI agents can cite it instead of re-arguing.
