# Install — epic-to-feature-specs for Codex

This adapter makes the **epic-to-feature-specs** skill usable inside [OpenAI Codex CLI](https://github.com/openai/codex) and Codex Cloud. Codex loads `AGENTS.md` from the project root and parent directories, so the install is just "put two things in your project."

## What gets installed

```
<your project>/
├── AGENTS.md                       ← Codex auto-loads this on every session
└── .epic-to-feature-specs/
    ├── WORKFLOW.md                 ← full workflow (Codex reads on trigger)
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
./adapters/install.sh codex /path/to/your/project
```

The script will:

1. Copy `adapters/WORKFLOW.md`, `skills/epic-to-feature-specs/references/`, and `skills/epic-to-feature-specs/templates/` into `<your project>/.epic-to-feature-specs/`.
2. Either create `<your project>/AGENTS.md` (if it doesn't exist) or append the adapter snippet to the existing file with a clear marker block.

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

2. **Wire up AGENTS.md.** Either copy `adapters/codex/AGENTS.md` as your project's `AGENTS.md`, or paste its contents into your existing `AGENTS.md` (anywhere — Codex reads the whole file).

## Verify

Open Codex in your project and try:

> "I want to break down the epic at `docs/epics/3-processing-pipeline.md` into feature specs."

Codex should:
1. Read `.epic-to-feature-specs/WORKFLOW.md`.
2. Start by asking which persona you are (PM / tech lead / solo dev).
3. Continue through the workflow steps, asking explicit questions at each branch.

If Codex skips the persona question or starts drafting specs without asking, the snippet isn't being loaded — check that `AGENTS.md` is at the project root.

## Updating

The workflow and references are versioned in the upstream repo. To pull updates:

```bash
cd /path/to/epic-to-feature-specs
git pull
./adapters/install.sh codex /path/to/your/project
```

The install script overwrites the files in `.epic-to-feature-specs/` and leaves your edits to `AGENTS.md` outside the marker block alone.

## Differences from the Claude Code plugin

| | Claude Code plugin | Codex adapter |
|---|---|---|
| Trigger | Auto-detected via skill description matching | Trigger phrases listed in AGENTS.md |
| Structured questions | `AskUserQuestion` tool (multi-choice UI) | Plain-text questions in chat |
| File location | Plugin install dir | Your project's `.epic-to-feature-specs/` |
| Updates | `claude plugin update` | `git pull && install.sh` |

The workflow itself is identical. Same persona detection, same cutting strategies, same SMART validation, same sub-spec layer.

## Troubleshooting

**Codex doesn't follow the workflow.** Confirm `AGENTS.md` is in the project root (not in a subfolder) and includes the `## Skill: epic-to-feature-specs` section. Codex reads `AGENTS.md` files from the working directory upward; if you have a parent `AGENTS.md` that contradicts this one, the closer file usually wins.

**`WORKFLOW.md` isn't found at runtime.** Codex resolves the `./` paths in the AGENTS.md snippet relative to the project root. Confirm `.epic-to-feature-specs/WORKFLOW.md` exists there.

**Figma / Pencil / Notion MCPs aren't being used.** Codex only uses MCPs you've configured for it. The workflow gracefully falls back to "ask the user for the file URL" if no design MCP is connected, and to "markdown-only sub-specs" if no Notion MCP is connected.
