# Adapters — using epic-to-feature-specs outside Claude Code

This folder packages the **epic-to-feature-specs** skill for AI coding agents other than Claude Code. Same workflow, same templates, same SMART validation — just a different entry-point file per agent.

## Supported agents

| Agent | Entry file | Install guide |
|---|---|---|
| **OpenAI Codex** (CLI + Cloud) | `AGENTS.md` | [codex/INSTALL.md](codex/INSTALL.md) |
| **Google Gemini** (CLI + Code Assist) | `GEMINI.md` | [gemini/INSTALL.md](gemini/INSTALL.md) |
| **Claude Code** | (use the plugin) | See [`README.md`](../README.md) at the repo root |

## Folder layout

```
adapters/
├── README.md                 ← this file
├── WORKFLOW.md               ← the canonical agent-agnostic workflow
├── install.sh                ← one-command install for either agent
├── codex/
│   ├── AGENTS.md             ← Codex entry-point snippet (loaded automatically)
│   └── INSTALL.md            ← Codex-specific install + troubleshooting
└── gemini/
    ├── GEMINI.md             ← Gemini entry-point snippet (loaded automatically)
    └── INSTALL.md            ← Gemini-specific install + troubleshooting
```

`WORKFLOW.md` is the same workflow that lives in `skills/epic-to-feature-specs/SKILL.md` — minus the Claude-specific tool calls (`AskUserQuestion`, hardcoded MCP tool names). It points at `references/` and `templates/` from the main skill folder, which the install script copies alongside.

## Why the indirection?

Codex and Gemini have no equivalent of Claude Code's description-based skill triggering. Their convention is "load `AGENTS.md` / `GEMINI.md` from the project root on every session." Pasting a 500-line workflow into every session would be wasteful, so we use a two-layer approach:

1. **Entry file** (`AGENTS.md` / `GEMINI.md`) — small, loaded every session. Lists the trigger phrases and points at the workflow file.
2. **Workflow file** (`.epic-to-feature-specs/WORKFLOW.md`) — full workflow, only read when a trigger phrase hits.

This keeps day-to-day Codex/Gemini sessions cheap and only pays the cost when the user actually wants to break down an epic.

## Install in one command

From the cloned repo:

```bash
./adapters/install.sh codex  /path/to/your/project
# or
./adapters/install.sh gemini /path/to/your/project
```

The script copies the workflow + references + templates into `<your project>/.epic-to-feature-specs/`, then wires up the entry file at the project root with a managed marker block. Idempotent — re-run any time to pick up upstream updates.

For manual install or troubleshooting, see the agent-specific `INSTALL.md`.

## What's the same across agents

- The 11-step workflow, persona detection, cutting strategies
- The reference docs (`references/cutting-strategies.md`, etc.)
- The templates (`templates/feature-spec.md`, `templates/sub-spec.md`, `templates/handoff-contract.ts`, `templates/be-handoff-narrative.md`)
- The SMART independence check
- The sub-spec layer with Plan Split annotations
- Optional Figma / Pencil / Notion MCP integration (when configured for the agent)

## What differs across agents

- **Question style.** Claude Code uses `AskUserQuestion` (structured multi-choice UI). Codex and Gemini ask the same questions in plain chat.
- **Trigger model.** Claude Code matches the skill description automatically. Codex/Gemini trigger via the phrase list in `AGENTS.md` / `GEMINI.md`.
- **Tool names.** The workflow names the *operation* ("fetch the database schema", "create one page per sub-spec") rather than specific tool names, so it works with whatever Figma/Pencil/Notion MCPs you've configured for each agent.

## Updating

Adapter content lives next to the main skill. When the skill bumps a version, re-run the install script in each project that uses the adapter:

```bash
cd /path/to/epic-to-feature-specs && git pull
./adapters/install.sh codex  /path/to/project-a
./adapters/install.sh gemini /path/to/project-b
```

The script overwrites the contents of `.epic-to-feature-specs/` (which is fully managed) and updates the managed block in the entry file in place. Edits outside the managed block are preserved.

## Reporting issues

Adapter-specific problems (install script, entry-file wiring, agent-specific quirks) — open an issue tagged `adapter:codex` or `adapter:gemini`.

Workflow problems (wrong question order, bad cutting strategy, template bug) — open an issue tagged `core` since the workflow is shared across all three integrations.
