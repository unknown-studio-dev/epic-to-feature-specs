# Install — epic-to-feature-specs for Gemini

This adapter makes the **epic-to-feature-specs** skill usable inside [Gemini CLI](https://github.com/google-gemini/gemini-cli) and Gemini Code Assist. Both tools load `GEMINI.md` from the project root, so the install is just "put two things in your project."

## What gets installed

```
<your project>/
├── GEMINI.md                       ← Gemini auto-loads this on every session
└── .epic-to-feature-specs/
    ├── WORKFLOW.md                 ← full workflow (Gemini reads on trigger)
    ├── references/                 ← decision trees, checklists
    │   ├── cutting-strategies.md
    │   ├── plan-split-patterns.md
    │   ├── smart-checklist.md
    │   ├── sub-spec-cutting.md
    │   └── team-split-patterns.md
    └── templates/                  ← spec + contract templates
        ├── be-handoff-narrative.md
        ├── feature-spec.md
        ├── handoff-contract.ts
        └── sub-spec.md
```

## Install with the script

From the root of the cloned `epic-to-feature-specs` repo:

```bash
./adapters/install.sh gemini /path/to/your/project
```

The script will:

1. Copy `adapters/WORKFLOW.md`, `skills/epic-to-feature-specs/references/`, and `skills/epic-to-feature-specs/templates/` into `<your project>/.epic-to-feature-specs/`.
2. Either create `<your project>/GEMINI.md` (if it doesn't exist) or append the adapter snippet to the existing file with a clear marker block.

Run the script again to update — it's idempotent.

## Install manually

If you'd rather not run the script:

1. **Copy the workflow + references + templates** into your project:
   ```bash
   mkdir -p /path/to/your/project/.epic-to-feature-specs
   cp adapters/WORKFLOW.md \
      /path/to/your/project/.epic-to-feature-specs/
   cp -R skills/epic-to-feature-specs/references \
         skills/epic-to-feature-specs/templates \
         /path/to/your/project/.epic-to-feature-specs/
   ```

2. **Wire up GEMINI.md.** Either copy `adapters/gemini/GEMINI.md` as your project's `GEMINI.md`, or paste its contents into your existing `GEMINI.md` (anywhere — Gemini reads the whole file).

## Verify

Open Gemini CLI in your project and try:

> "I want to break down the epic at `docs/epics/3-processing-pipeline.md` into feature specs."

Gemini should:
1. Read `.epic-to-feature-specs/WORKFLOW.md`.
2. Start by asking which persona you are (PM / tech lead / solo dev).
3. Continue through the workflow steps, asking explicit questions at each branch.

If Gemini skips the persona question or starts drafting specs without asking, the snippet isn't being loaded — check that `GEMINI.md` is at the project root.

## Updating

The workflow and references are versioned in the upstream repo. To pull updates:

```bash
cd /path/to/epic-to-feature-specs
git pull
./adapters/install.sh gemini /path/to/your/project
```

The install script overwrites the files in `.epic-to-feature-specs/` and leaves your edits to `GEMINI.md` outside the marker block alone.

## Differences from the Claude Code plugin

| | Claude Code plugin | Gemini adapter |
|---|---|---|
| Trigger | Auto-detected via skill description matching | Trigger phrases listed in GEMINI.md |
| Structured questions | `AskUserQuestion` tool (multi-choice UI) | Plain-text questions in chat |
| File location | Plugin install dir | Your project's `.epic-to-feature-specs/` |
| Updates | `claude plugin update` | `git pull && install.sh` |

The workflow itself is identical. Same persona detection, same cutting strategies, same SMART validation, same sub-spec layer.

## Notes for Gemini CLI

- **Extensions.** If you've configured Figma, Pencil, or Notion as Gemini CLI extensions (MCP servers in `~/.gemini/settings.json` or equivalent), the workflow will use them. Otherwise it falls back to asking the user for design URLs or screenshots and writing markdown sub-specs only.
- **Nested GEMINI.md.** Gemini CLI loads `GEMINI.md` from the working directory and parents. If you have a parent `GEMINI.md` that contradicts this one, the closer file usually wins — but it's safer to consolidate at the project root.
- **Context window.** Gemini's context is large, but `WORKFLOW.md` is still ~30KB. It's only read when the trigger phrases hit, not on every turn, so it doesn't bloat normal sessions.

## Notes for Gemini Code Assist

Gemini Code Assist reads `GEMINI.md` from the workspace root in supported IDEs. The same install applies — drop `GEMINI.md` and `.epic-to-feature-specs/` at the workspace root and Code Assist will follow the workflow when the trigger phrases hit.

## Troubleshooting

**Gemini doesn't follow the workflow.** Confirm `GEMINI.md` is in the project root and includes the `## Skill: epic-to-feature-specs` section. Gemini reads `GEMINI.md` files from the working directory upward; if you have a parent `GEMINI.md` that contradicts this one, the closer file usually wins.

**`WORKFLOW.md` isn't found at runtime.** Gemini resolves the `./` paths in the GEMINI.md snippet relative to the project root. Confirm `.epic-to-feature-specs/WORKFLOW.md` exists there.

**Figma / Pencil / Notion MCPs aren't being used.** Gemini only uses MCPs you've configured as extensions. The workflow gracefully falls back to "ask the user for the file URL" if no design MCP is connected, and to "markdown-only sub-specs" if no Notion MCP is connected.
