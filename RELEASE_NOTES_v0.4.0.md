# v0.4.0 — Multi-Agent Support (Codex + Gemini)

The skill is no longer Claude Code only. v0.4 ships native adapters for [OpenAI Codex](https://github.com/openai/codex) (CLI + Cloud) and [Google Gemini](https://github.com/google-gemini/gemini-cli) (CLI + Code Assist) alongside the existing Claude Code plugin. Same 11-step workflow, same templates, same SMART validation — just a native entry-point per agent so the same epic decomposition discipline travels with the team across whichever AI coding tool they use.

## Why

Teams rarely standardize on one AI coding agent across an org. Engineering uses Claude Code, product uses Codex, design uses Gemini Code Assist — and the gap between "we have a great way to break down epics in Claude" and "everyone on the team uses it" was big enough that the skill stopped at one provider's surface. v0.4 closes that gap.

The constraint shaping the design: Codex and Gemini have no equivalent of Claude Code's description-based skill triggering. Their convention is "load `AGENTS.md` / `GEMINI.md` from the project root on every session." Pasting a 500-line workflow into every session would be wasteful, so v0.4 uses a two-layer approach.

## Agent-Agnostic Workflow (New)

`adapters/WORKFLOW.md` is the canonical workflow, written so any AI coding agent that reads context files from the working directory can execute it. It's the de-Claude'd version of `SKILL.md`:

- `AskUserQuestion` calls → plain explicit instructions ("ask the user the following questions…")
- Hardcoded MCP tool names (`mcp__figma__*`, `notion-create-pages`, etc.) → operation descriptions ("fetch the database schema first, then create one page per sub-spec") so it works with whatever MCPs each agent has configured
- Path references → `./references/` and `./templates/` siblings, materialized at install time

The workflow itself is identical to `skills/epic-to-feature-specs/SKILL.md` — same persona detection, same cutting strategies, same sub-spec layer, same Plan Split rules. The Claude Code plugin remains the structured-question version (`AskUserQuestion` multi-choice UI) for Claude users; the adapters use plain-text questions.

## Entry-Point Snippets (New)

Each adapter ships a small entry-point file that the agent auto-loads:

- **`adapters/codex/AGENTS.md`** — loaded by Codex CLI and Codex Cloud from the project root and parent dirs.
- **`adapters/gemini/GEMINI.md`** — loaded by Gemini CLI and Gemini Code Assist from the workspace root.

Both snippets list the trigger phrases (English + Vietnamese) and point at `./.epic-to-feature-specs/WORKFLOW.md` for the full workflow. The full workflow is only read when a trigger phrase hits, not on every turn, so day-to-day sessions stay cheap.

The snippets also encode the four hard rules: ask explicitly at every input step; read referenced files before drafting; stop at the sub-spec layer; no token numbers in Plan Split sections.

## One-Command Install (New)

`adapters/install.sh` ships a single script that installs either adapter into any project:

```bash
./adapters/install.sh codex  /path/to/your/project
./adapters/install.sh gemini /path/to/your/project
```

The script:

1. Creates `<target>/.epic-to-feature-specs/` and copies `WORKFLOW.md`, `references/`, and `templates/` into it.
2. Either creates the entry file (`AGENTS.md` for Codex, `GEMINI.md` for Gemini) or appends the adapter snippet to an existing file between idempotent marker comments.

Re-running picks up upstream updates: `.epic-to-feature-specs/` is fully managed and overwritten; the managed block in the entry file is updated in place; everything outside that block is preserved.

## What Each Agent Gets

| | Claude Code plugin | Codex adapter | Gemini adapter |
|---|---|---|---|
| Trigger | Auto via skill description matching | Trigger phrases in `AGENTS.md` | Trigger phrases in `GEMINI.md` |
| Structured questions | `AskUserQuestion` (multi-choice UI) | Plain-text questions in chat | Plain-text questions in chat |
| File location | Plugin install dir | `<project>/.epic-to-feature-specs/` | `<project>/.epic-to-feature-specs/` |
| Updates | `claude plugin update` | `git pull && install.sh` | `git pull && install.sh` |
| Figma / Pencil / Notion MCPs | Used if connected | Used if connected | Used if connected |

The skill content — persona detection, cutting strategies, SMART validation, sub-spec layer, Plan Split heuristic, the templates themselves — is bit-for-bit identical across all three.

## Tool Names Are Now Generic

The workflow used to name specific MCP tools (`notion-fetch`, `notion-create-pages`, `get_file_components`, etc.) that only existed in Claude Code's Notion and Figma integrations. v0.4 names the *operation* instead:

- "fetch the database schema first, then create one page per sub-spec mapping only properties that exist"
- "retrieve the page/frame structure, list reusable components, extract design tokens, capture screenshots"

This means the workflow runs against whichever Figma/Pencil/Notion MCPs each agent has configured, without hardcoding tool names. The Claude Code SKILL.md retains specific tool names (since Claude users only have one Notion MCP available), but the agent-agnostic `WORKFLOW.md` is portable.

## What This Release Does NOT Do

- **No Cursor / Aider / Continue / other adapters yet.** v0.4 ships only the Codex and Gemini adapters. The pattern (small entry-point file + shared WORKFLOW.md + install script) is straightforward to extend later — but adding more provider surfaces in one release would dilute review and testing.
- **No MCP server.** A future version may wrap the skill as an MCP server (`break_down_epic` tool), which would give all three agents description-based triggering rather than phrase-matching. v0.4 stays with file-based context loading because it's simpler and matches each agent's native convention.
- **No content changes to the Claude Code plugin.** `skills/epic-to-feature-specs/SKILL.md`, `references/`, and `templates/` are unchanged from v0.3.1. Claude users see no behavior difference.

## Breaking Changes

None. v0.4 is purely additive:

- Existing Claude Code installations keep working unchanged — `SKILL.md` and the read-before-write hooks are untouched.
- The Notion MCP integration in `SKILL.md` still names `notion-fetch` and `notion-create-pages` (the Cowork Notion MCP's tool names) because that's what Claude users have. Only the agent-agnostic `WORKFLOW.md` uses generic operation descriptions.
- No file moves. The Claude plugin layout is unchanged; adapters live in a new sibling `adapters/` folder.

## Files Changed

```
Added:
  adapters/README.md                       (adapter overview + layout)
  adapters/WORKFLOW.md                     (agent-agnostic workflow — 532 lines)
  adapters/install.sh                      (one-command install for either agent)
  adapters/codex/AGENTS.md                 (Codex entry-point snippet)
  adapters/codex/INSTALL.md                (Codex install + troubleshooting)
  adapters/gemini/GEMINI.md                (Gemini entry-point snippet)
  adapters/gemini/INSTALL.md               (Gemini install + troubleshooting)
  RELEASE_NOTES_v0.4.0.md

Modified:
  README.md                                (added v0.4 section, Codex + Gemini install paths, updated "What's inside" tree)
  .claude-plugin/plugin.json               (version 0.3.1 → 0.4.0, expanded description, new keywords: codex, gemini, multi-agent)
  .claude-plugin/marketplace.json          (version 0.3.1 → 0.4.0, expanded description, new keywords)
```

## Verifying the Install

After running `./adapters/install.sh codex /path/to/project`, the target should look like:

```
<project>/
├── AGENTS.md                       ← contains managed marker block with the skill snippet
└── .epic-to-feature-specs/
    ├── WORKFLOW.md
    ├── references/                 (5 files)
    └── templates/                  (4 files)
```

Then in Codex, ask "Break down the epic at `docs/epics/<your-epic>.md` into feature specs." The agent should read `.epic-to-feature-specs/WORKFLOW.md` and start by asking which persona you are (PM / tech lead / solo dev). If it skips the persona question, the snippet isn't being loaded — see `adapters/codex/INSTALL.md` troubleshooting.

Same flow for Gemini, but install with `gemini` instead of `codex` and look for `GEMINI.md`.

## What's Next

The natural follow-up is **more adapters** — Cursor (`.cursorrules`), Aider (`CONVENTIONS.md`), Continue (`.continue/config.json`) — each one a small entry-point snippet pointing at the same `WORKFLOW.md`. The install script can stay as-is; only the per-agent folders need to be added.

Beyond that, the v0.3.0 "sync-back" idea (auto-updating Notion task Status as hoangsa reports progress) is still on the table and now applies across all three agents.
