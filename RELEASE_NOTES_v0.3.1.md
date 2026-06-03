# v0.3.1 — Single-Tier Hook Gate

Patch release. Simplifies the read-before-write hook gate that ships with the plugin. No skill-content changes — all v0.3.0 workflow features (sub-spec layer, stub-first cutting, Plan Split annotations) are unchanged.

## What changed

`check-gate.sh` and `track-read.sh` are reverted to a single-tier gate. The hook now requires exactly the five base files before any Write/Edit:

1. `SKILL.md`
2. `references/cutting-strategies.md`
3. `references/team-split-patterns.md`
4. `references/smart-checklist.md`
5. `templates/feature-spec.md`

The v0.3.0 "Tier 2" branch — which conditionally required `references/sub-spec-cutting.md`, `references/plan-split-patterns.md`, and `templates/sub-spec.md` when the write target looked like a sub-spec (path contained `/sub-specs/` or filename matched `spec-X.Y.[A-E]-…`) — has been removed.

## Why

The Tier 2 logic added detection complexity (path + filename matching, two parallel sets of flags) for a marginal correctness gain. In practice the agent reads the sub-spec references via the same SKILL.md guidance that gates Tier 1, so the conditional layer was enforcing a path already taken. Removing it keeps the gate easy to audit and the failure mode obvious.

## Files changed

```
Modified:
  .claude-plugin/hooks/scripts/check-gate.sh    (drop Tier 2 detection + flags)
  .claude-plugin/hooks/scripts/track-read.sh    (drop Tier 2 flag writes)
  .claude-plugin/plugin.json                    (0.3.0 → 0.3.1)
  .claude-plugin/marketplace.json               (0.3.0 → 0.3.1)
  .gitignore                                    (drop *.plugin — the .plugin archive is tracked for Cowork)
  epic-to-feature-specs.plugin                  (rebuilt to match)
```

## Breaking changes

None. Sub-spec files are still shipped and still referenced from the SKILL.md workflow. The only observable difference is that writing to `<spec_storage>/sub-specs/spec-X.Y.{letter}-….md` no longer requires the sub-spec references to have been read in the same session.
