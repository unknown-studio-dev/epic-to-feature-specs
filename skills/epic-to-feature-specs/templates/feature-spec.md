# Feature Spec {epic}.{spec-number} — {Team} — {Short Title}

> **Epic:** [link to epic file]
> **Team:** {FE | BE | FE+BE | Service name | Solo | Other}
> **Status:** Draft | Reviewed | Frozen | Implementing | Shipped
> **Owner:** {name}
> **Target:** {date or milestone}
> **Depends on:** Spec X.Y, Spec X.Z (or "none — leaf spec")
> **Unblocks:** Spec X.A (or "none — terminal spec")
> **Design source:** {Figma URL | Pencil doc ID | "none" | "TBD"}

## 1. Context

Two to three sentences linking this spec back to the epic's goal and to the user journey this spec enables. Quote the epic's one-line outcome. This section exists so an AI coding agent understands *why* — without which the code will technically compile but miss the point.

## 2. SMART Outcome

A single paragraph that satisfies SMART independently:

- **Specific:** what exactly will exist when this is done
- **Measurable:** how we know it works — without the sibling specs existing
- **Achievable:** sized for roughly one AI coding session with a bounded task list
- **Relevant:** ties back to the epic's key metric
- **Time-bound:** target completion date or milestone

Example: *"The Inbox surface allows users to select recordings and trigger processing, displaying per-recording status through the full lifecycle (queued → processing → complete/failed), with a reconnect indicator when offline. Success is measured by: (a) all status transitions render in Storybook against a mocked store, (b) offline-queued items visually indicate the deferred state, (c) tapping the Process button calls the mutation exactly once per recording. Target: end of sprint 4."*

## 3. Scope

### In Scope

- Specific deliverables (components, endpoints, types, migrations)
- User-facing behaviour this spec adds
- File paths or modules that will be touched

### Out of Scope (Within This Spec)

- What belongs to sibling specs — be explicit, with pointers
- What belongs to other epics — be explicit
- Gold-plating the AI coding agent might be tempted to add — call it out

## 4. Dependencies

| Type | Item | Notes |
|---|---|---|
| Spec dep | Spec X.Y (contract) | Uses `ProcessingStatus` type from `contracts/processing.ts` |
| Spec dep | Spec X.Z | Consumes the mutation surface from Spec X.Z once shipped |
| External | Epic N | Triggered from the Inbox in Epic 2 |
| Infra | Cloudflare Queues configured | Referenced in Tech Doc section 5.3 |
| Design | Figma page "Inbox" | Screens for this spec's UI |

State **what this spec produces** that other specs will consume — this becomes part of the contract.

## 5. UI Design Reference

> **Include this section for any spec that has user-facing work AND designs were provided.**
> If no designs are available, replace this section with: *"UI design not yet available. Acceptance criteria are based on epic descriptions. Design review required before status moves to Frozen."*

### 5.1 Screen-to-Story Mapping

| Design Screen/Frame | Frame ID | User Story | Notes |
|---|---|---|---|
| {Screen name from design tool} | {frame ID or path} | {Story ID} | {Brief description of what the screen shows} |
| {e.g. "Inbox/Default"} | {e.g. frame-abc123} | {e.g. US-3.1} | {e.g. "Default state with recording list"} |

### 5.2 Component Inventory

List every design system component this spec's screens use. This ensures the FE implementation matches the design.

| Component | Variant/State | Exists in Codebase? | Props from Design | Notes |
|---|---|---|---|---|
| {e.g. RecordingCard} | Default, Selected, Processing | Yes — `src/components/RecordingCard` | title, status, duration, onSelect | {e.g. "Needs new 'processing' variant"} |
| {e.g. StatusBadge} | Queued, Processing, Complete, Failed | No — needs to be built | kind, label | {e.g. "New component"} |

### 5.3 Design Tokens Referenced

Colors, typography, spacing, and other tokens from the design that this spec's UI must use.

| Token | Value | Source |
|---|---|---|
| {e.g. color/status-processing} | {e.g. #F59E0B} | {e.g. Figma styles / design system variables} |
| {e.g. font/body-medium} | {e.g. Inter 14/20 Medium} | {e.g. Figma typography styles} |

### 5.4 State-to-Screen Mapping

For each state in the handoff contract (or domain logic), map it to the exact design screen/variant that shows that state. This is **critical for FE acceptance criteria** — every state transition the contract defines must have a corresponding visual representation.

| Contract State | Design Screen/Variant | Key Visual Elements |
|---|---|---|
| `idle` | {e.g. "Inbox/Default"} | {e.g. "Recording card with Process button"} |
| `queued` | {e.g. "Inbox/Queued"} | {e.g. "Queued badge, disabled button"} |
| `queued` + `offline: true` | {e.g. "Inbox/Queued-Offline"} | {e.g. "Offline chip: 'Will process when online'"} |
| `inProgress` | {e.g. "Inbox/Processing"} | {e.g. "Spinner, progress bar if determinate"} |
| `complete` | {e.g. "Library/NoteDetail"} | {e.g. "Redirect to completed note"} |
| `failed` + `retriable` | {e.g. "Inbox/Error-Retriable"} | {e.g. "Error message + Retry button"} |
| `failed` + `!retriable` | {e.g. "Inbox/Error-Terminal"} | {e.g. "Error message, no retry, contact support link"} |

### 5.5 Design-Spec Mismatches & Resolutions

> **This section documents any mismatches found between the UI designs and the epic/spec scope.** During spec drafting, the skill actively compares design content against epic stories and spec scope. Any discrepancy is surfaced here with a resolution.

Mismatches fall into these categories:

**Category A: Design has screens/flows not covered by any user story**
The design shows UI that no story in the epic describes. This could be designer foresight, scope creep, or a missing story.

**Category B: User stories have no corresponding design**
A story describes user-facing behaviour but there's no matching screen or state in the design. The story can't be visually verified.

**Category C: Design and story contradict each other**
The design shows one behaviour (e.g. inline editing) but the story describes another (e.g. modal editing). One must be authoritative.

**Category D: Design components don't match existing codebase patterns**
The design uses components or patterns that don't exist in the codebase and aren't in the design system. This implies new component work not accounted for in estimates.

| # | Category | Description | Recommendation | Resolution | Owner |
|---|---|---|---|---|---|
| 1 | {A/B/C/D} | {What the mismatch is — be specific} | {Skill's recommendation — see guidance below} | {Pending / Resolved: {decision}} | {name} |

**How recommendations work:**

For each mismatch, the skill provides a concrete recommendation with reasoning, so the user can make a quick decision:

- **Category A (extra design, no story):** Recommend one of:
  - *"Add a story"* — if the design clearly adds user value and fits this epic's scope
  - *"Defer to a future epic"* — if it's valuable but expands scope beyond this epic
  - *"Confirm with designer it's intentional"* — if it's ambiguous whether the screen is in scope

- **Category B (story, no design):** Recommend one of:
  - *"Request design before Frozen"* — if the story is core to the spec and visual verification matters
  - *"Proceed with text-only acceptance criteria"* — if the story is backend-heavy or the UI is trivial (e.g. a toast notification)
  - *"Split the story"* — if part of the story has designs and part doesn't

- **Category C (contradiction):** Recommend one of:
  - *"Follow the design"* — if the design is more recent and likely reflects the latest thinking
  - *"Follow the story"* — if the story captures a PM decision that the design hasn't caught up to
  - *"Escalate to PM + designer"* — if neither is clearly authoritative

- **Category D (new components):** Recommend one of:
  - *"Add component to the scope and estimate"* — with a rough sizing note
  - *"Use an existing component that's close enough"* — name the substitute
  - *"Flag to the design system team"* — if the component should be part of the system

**All mismatches must be resolved (status: "Resolved: {decision}") before the spec status moves to "Frozen".** Unresolved mismatches block implementation because they create ambiguity for AI coding agents.

## 6. Handoff Contract (if cross-team)

> **Canonical source:** `contracts/{feature-area}.ts` — this is source of truth. The block below is a snapshot for readability; the `.ts` file is what compiles and what AI agents read.

```typescript
// Paste the relevant portion of the TS contract here
// See contracts/{feature-area}.ts for the complete, authoritative version
```

### Mutations (presentation-side calls)
- `mutationName(args): returnType` — one-line description

### Selectors (presentation-side reads)
- `useSelectorName(args): ReturnType` — one-line description

### Events (presentation-side may subscribe)
- `'event.name'` → `{ payload shape }`

### Contract Amendment Policy
Changes to the canonical `.ts` file require a co-reviewed PR with sign-off from each team that consumes the contract. Do not edit the `.ts` file silently mid-implementation. If a change is needed, update this spec in the same PR.

## 7. Decisions Already Made

So AI coding agents don't re-argue settled choices. Each line cites the source.

- **{Decision}** — {source: tech doc §N, ADR-00X, epic decision}
- **{Decision}** — {source}

Example:
- Transcription provider: Workers AI Whisper primary, OpenAI fallback (Tech Doc §3.1)
- State management: Zustand + React Query (Tech Doc §3.1)
- Queue semantics: Cloudflare Queues with DLQ on 3rd retry (Tech Doc §5.3)

If none of the decisions shaping this spec are in the tech doc, record them here as ADR-style statements with a short rationale.

## 8. User Stories & Acceptance Criteria

Preserve story IDs from the epic. Rewrite acceptance criteria to be testable in *this spec's context* (with siblings mocked).

### {ID}: {Story title from epic}

> As a {user}, I want {outcome} so that {value}.

**Acceptance criteria:**
- Given {setup}, when {action}, then {observable result}
- Given {setup}, when {action}, then {observable result}

**Design reference:** {Frame name/ID from Section 5 that shows this story's UI, or "No UI" for backend-only stories}

**Test approach:** {unit | integration | E2E | Storybook | manual QA}

---

### {ID}: {Next story}

...

## 9. Technical Notes

Specific to this spec, not covered by the tech doc. Examples:
- Component structure proposal
- State machine diagram (mermaid)
- Error taxonomy for this spec's scope
- Performance budget (if different from epic-level)

Keep this section lean. If it duplicates the tech doc, cite instead.

## 10. Test Plan

How we verify this spec independently:

1. **Unit / component tests** — what's covered
2. **Integration tests** — what's mocked, what's real
3. **Storybook (FE) / contract tests (BE)** — what scenarios
4. **Visual verification against designs** — if designs were provided, list which screens/states to compare against the implementation. Reference specific frames from Section 5.
5. **Manual verification** — what a reviewer walks through

Explicitly list the **mocks** used to keep this spec independent of siblings. If you can't list them, you haven't sized the mocks correctly.

## 11. Open Questions

Track questions that need resolution before implementation starts. Each should have an owner and a deadline. If the list isn't empty at "Frozen" status, the spec isn't actually frozen.

- [ ] {Question} — owner: {name}, decide by: {date}

**Note:** Unresolved design-spec mismatches from Section 5.5 are automatically open questions. They must be resolved before Frozen.

## 12. Change Log

| Date | Change | Author |
|---|---|---|
| YYYY-MM-DD | Initial draft | {name} |
