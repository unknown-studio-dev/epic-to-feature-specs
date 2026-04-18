# Feature Spec {epic}.{spec-number} — {Team} — {Short Title}

> **Epic:** [link to epic file]
> **Team:** {FE | BE | FE+BE | Other}
> **Status:** Draft | Reviewed | Frozen | Implementing | Shipped
> **Owner:** {name}
> **Target:** {date or milestone}
> **Depends on:** Spec X.Y, Spec X.Z (or "none — leaf spec")
> **Unblocks:** Spec X.A (or "none — terminal spec")

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

State **what this spec produces** that other specs will consume — this becomes part of the contract.

## 5. Handoff Contract (if cross-team)

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

## 6. Decisions Already Made

So AI coding agents don't re-argue settled choices. Each line cites the source.

- **{Decision}** — {source: tech doc §N, ADR-00X, epic decision}
- **{Decision}** — {source}

Example:
- Transcription provider: Workers AI Whisper primary, OpenAI fallback (Tech Doc §3.1)
- State management: Zustand + React Query (Tech Doc §3.1)
- Queue semantics: Cloudflare Queues with DLQ on 3rd retry (Tech Doc §5.3)

If none of the decisions shaping this spec are in the tech doc, record them here as ADR-style statements with a short rationale.

## 7. User Stories & Acceptance Criteria

Preserve story IDs from the epic. Rewrite acceptance criteria to be testable in *this spec's context* (with siblings mocked).

### {ID}: {Story title from epic}

> As a {user}, I want {outcome} so that {value}.

**Acceptance criteria:**
- Given {setup}, when {action}, then {observable result}
- Given {setup}, when {action}, then {observable result}

**Test approach:** {unit | integration | E2E | Storybook | manual QA}

---

### {ID}: {Next story}

...

## 8. Technical Notes

Specific to this spec, not covered by the tech doc. Examples:
- Component structure proposal
- State machine diagram (mermaid)
- Error taxonomy for this spec's scope
- Performance budget (if different from epic-level)

Keep this section lean. If it duplicates the tech doc, cite instead.

## 9. Test Plan

How we verify this spec independently:

1. **Unit / component tests** — what's covered
2. **Integration tests** — what's mocked, what's real
3. **Storybook (FE) / contract tests (BE)** — what scenarios
4. **Manual verification** — what a reviewer walks through

Explicitly list the **mocks** used to keep this spec independent of siblings. If you can't list them, you haven't sized the mocks correctly.

## 10. Open Questions

Track questions that need resolution before implementation starts. Each should have an owner and a deadline. If the list isn't empty at "Frozen" status, the spec isn't actually frozen.

- [ ] {Question} — owner: {name}, decide by: {date}

## 11. Change Log

| Date | Change | Author |
|---|---|---|
| YYYY-MM-DD | Initial draft | {name} |
