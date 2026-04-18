# SMART Independence Checklist

Run through this for each spec before calling it done. The most important test is **Measurable-independently** — specs that fail this are the root cause of stuck parallel-team projects.

## The five checks

### Specific

- [ ] Can you state the outcome in one sentence without using "and"?
- [ ] Are files, endpoints, or components named explicitly in scope?
- [ ] Is "in scope" and "out of scope" written out, not implied?
- [ ] Would two engineers reading this independently agree on what "done" looks like?

**If no:** the spec is probably trying to cover multiple concerns. Split, or write the scope section more tightly.

### Measurable — independently

This is the spec-maker's most important test.

- [ ] Can the acceptance criteria be verified with sibling specs mocked out?
- [ ] Are the mocks listed explicitly? If so, are they shape-complete?
- [ ] Is there at least one test (unit, integration, Storybook story, manual flow) named for each acceptance criterion?
- [ ] If a sibling spec's behaviour changes post-contract, does this spec still pass its own acceptance criteria?

**If no:** the cut is wrong. Fixes:
1. **Merge** — if two specs have mutual acceptance criteria, they're one spec
2. **Extract shared dep** — if both specs need the same thing, that thing becomes its own spec they both depend on
3. **Move scope** — if a criterion can only be verified with the real sibling, it belongs to the sibling

### Achievable

- [ ] Is the spec sized for roughly one AI coding session with a bounded task list?
  - Rough heuristic: < 15 new/modified files, < 1500 lines of new code, < 10 user stories grouped in
- [ ] Are all external dependencies (APIs, libraries, infra) confirmed available?
- [ ] Does the "Decisions Already Made" section cover the stack choices that would otherwise eat time?

**If no:** probably needs to be split. But watch the 5-spec ceiling — if splitting would break it, consider splitting the *epic* instead.

### Relevant

- [ ] Does every story in this spec roll up to the epic's goal?
- [ ] Is there at least one metric this spec moves toward the epic's key metrics?
- [ ] Are you confident a PM reading only this spec would say "yes, this advances the epic"?

**If no:** the scope has drifted. Either re-anchor to the epic or move the off-target work to a different epic entirely.

### Time-bound

- [ ] Is there a target date or milestone in the spec frontmatter?
- [ ] Does the target account for the spec's dependencies landing first?
- [ ] If dependencies slip, is the ripple effect on this spec obvious from the dependency graph?

**If no:** add it. Unbounded specs don't ship.

## Common failure modes and fixes

### "My Spec 3.2's acceptance criteria say 'the FE displays correctly'"

That's a dependency on Spec 3.1. The acceptance criterion should instead read: *"Given a call to `triggerProcessing(ids)`, a queue row appears in SQLite with status 'queued'."* — verifiable without any FE.

### "The test plan says 'E2E test against the real server'"

E2E tests belong at the epic or product level, not the spec level. Spec-level tests run with mocks so each spec is independent.

### "Spec 3.3 needs the output of Spec 3.2 to test"

That's OK — but the output shape must be defined in the contract and mockable. The test plan for Spec 3.3 should read: *"Given a fixture matching the Spec 3.2 output shape, ..."* — no need for Spec 3.2 to be actually running.

### "I can't figure out what to mock in Spec 3.1"

That's a signal the contract isn't well-defined. Write the contract first (as types), then the mock is just a typed fixture.

## Sanity check: the mock audit

For each spec, list every mock the test plan assumes. If any entry in that list reads like "the other spec's real implementation", you haven't finished the contract. Contracts must be complete enough that the mocks are trivially constructable from the types.

## Final gate

A spec passes if, hand on heart:

> "If every other spec in this epic disappeared tomorrow, and I had the contract file, I could still implement and verify this spec."

If you can't say yes to that, keep cutting.
