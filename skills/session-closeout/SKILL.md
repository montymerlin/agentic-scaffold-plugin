---
name: session-closeout
description: >
  Scaffold a repo-tailored session-closeout workflow, then run it to close out a work
  session. Use when the user says "close out", "wrap up", "session end", "end of session",
  "prepare commit", "finish up", or "set up session closeout". On first use it generates a
  session-closeout.md workflow fitted to the repo's logging surfaces; on later use it runs
  that workflow — surfacing unfinished to-dos, reconciling the logging surfaces, and
  building the commit if the repo is under git.
---

# session-closeout

The capstone skill of the agentic scaffold. It does two things:

1. **Scaffolds** a repo-tailored `session-closeout.md` workflow into the target repo — a standing, editable, plugin-independent procedure fitted to that repo's actual logging surfaces.
2. **Runs** that workflow to close out a work session — surfacing unfinished to-dos, reconciling whatever logging surfaces the repo has, and (only if the repo is under git) building the commit.

It is an **orchestrator**, not a monolith. It delegates changelog work to `agentic-scaffold:logchange` and deep consistency checks to `agentic-scaffold:repo-audit` rather than re-implementing them. The closeout owns only what nothing else does — surfacing to-dos, the handoff decision, and assembling the session's close.

**Core principle — adaptivity.** No two repos have the same logging surfaces. A bare scaffolded folder may have only `AGENTS.md` and no git; a mature repo has `DECISIONS.md`, `CHANGELOG.md`, `ROADMAP.md`, skills, hooks. The skill detects what the repo actually has and generates a closeout containing only the relevant steps — modular, not mandatory.

> **Design rationale & invariants:** Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. Read `${AGENTIC_SCAFFOLD_ROOT}/skills/init/references/design-principles.md` before generating a workflow — Principle 7 (rules at the narrowest scope) and progressive disclosure govern how the closeout is assembled. The modular step-blocks the generator draws from live in `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-blocks.md`.

## Step 1: Detect mode

Look for an existing session-closeout workflow in the target repo, checking in order: `ops/workflows/session-closeout.md`, `.agents/workflows/session-closeout.md`, `docs/workflows/session-closeout.md`, `session-closeout.md` at root.

- **Not found → Scaffold mode.** Go to Step 2.
- **Found → Run mode.** First run the staleness check (Step 7); then go to Step 6.

## Step 2: Detect the repo's logging surfaces — *scaffold mode*

Scan the target repo. This reuses the detection `agentic-scaffold:init` and `repo-audit` already do — do not reinvent it.

```bash
# git — a first-class conditional; an agentically-scaffolded folder may not be a git repo
git rev-parse --is-inside-work-tree 2>/dev/null && echo "GIT: yes" || echo "GIT: no"

# repo-level logging surfaces
for f in DECISIONS.md ROADMAP.md CHANGELOG.md; do
  [ -f "$f" ] && echo "EXISTS: $f" || echo "MISSING: $f"
done

# skills
{ [ -d ".agents/skills" ] || [ -d ".claude/skills" ]; } && echo "SKILLS: yes" || echo "SKILLS: no"

# nested structure (monorepo / nest skill used / project subfolders)
find . -mindepth 2 -name AGENTS.md -not -path './.git/*' -not -path './node_modules/*' 2>/dev/null | head -1

# generated files + hooks
{ [ -f ".githooks/post-commit" ] || ls .githooks/* 2>/dev/null | grep -q .; } && echo "HOOKS: yes"

# versioning
ls plugin.json .claude-plugin/plugin.json package.json pyproject.toml Cargo.toml 2>/dev/null
git tag -l 2>/dev/null | head -1 | grep -q . && echo "TAGS: yes"
```

Build a surface map:

| Surface | Detected by | The closeout gains |
|---|---|---|
| **git** | `git rev-parse` succeeds | the session-delta + commit block |
| DECISIONS.md | file exists | the decisions-reconcile block |
| ROADMAP.md | file exists | the roadmap-reconcile block |
| CHANGELOG.md | file exists | the changelog block — delegates to `logchange` |
| skills | `.agents/skills/` or `.claude/skills/` | the skill-changelog block |
| nested structure | nested `AGENTS.md` / project subfolders | the per-folder / project-ops block |
| generated files | post-commit hook + generator scripts | the generated-file freshness block |
| `repo-audit` available | the skill is installed | the consistency block delegates to it |
| versioned | a version manifest or git tags | the version-bump-recommendation block |

**No git is a first-class case.** If git is absent, the closeout has no commit step — its terminal action is confirming records are reconciled and, if work is being deferred, writing the handoff file. Never assume the folder is git-tracked.

## Step 3: Assemble the tailored workflow — *scaffold mode*

Read `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-blocks.md`. Assemble `session-closeout.md` from:

- the **header** block — always
- the **to-dos** block — always
- one **reconcile block per detected surface**, ordered: consistency → decisions → roadmap → skill changelogs → project ops → changelog
- the **generated-files** block — if hooks/generators detected
- the **local-indexes** block — if the repo keeps hand-maintained index/registry files (READMEs with inventories, registries, MOCs)
- the **git** block (session delta + commit) — *only if git detected*
- the **version-bump recommendation** block — if versioned
- the **handoff** block — always
- the **footer** block — always

Wire delegations: where `logchange` / `repo-audit` are available, the changelog and consistency blocks delegate to them; where not, they degrade to inline reminders so the generated file still works standalone. Interpolate the repo's name, the detected handoff-file location, and the workflow's own path.

## Step 4: Present & confirm — *scaffold mode*

Show the user: which surfaces were detected, which blocks the workflow will contain, where the file will be written. **GATE: do not write until the user approves.**

## Step 5: Write the workflow + offer to run — *scaffold mode*

Write `session-closeout.md` to the detected location. Default `ops/workflows/` (create it if needed); if the repo already keeps workflow/runbook files elsewhere, use that. Then offer: "Run the closeout now?" — if yes, Step 6.

## Step 6: Run the closeout — *run mode*

Load the repo's `session-closeout.md` and execute its steps for the current session. **The file is the source of truth** — it was tailored to this repo; follow it rather than improvising. Reconcile records first; build the commit (if the repo has git) last.

## Step 7: Staleness / re-scaffold

Before running an existing closeout workflow, compare the repo's current surfaces (Step 2 detection) against the blocks the workflow contains. If the repo has gained a surface the workflow doesn't cover — a `CHANGELOG.md` added, a skills directory created, git initialised — report the gap and offer to re-scaffold (regenerate, preserving any hand-edits the user flags). If nothing has drifted, proceed to run.

## Edge cases

- **Target is not a git repo** — expected and supported. The generated closeout simply omits the git block; its close is the reconciled record plus an optional handoff file.
- **No logging surfaces at all** (bare folder, only `AGENTS.md`) — the closeout is just the to-dos block, the handoff block, and the footer. That is correct and useful; don't pad it.
- **`logchange` / `repo-audit` not installed** — the changelog and consistency blocks degrade to inline reminders. The generated workflow names this so a future reader understands why.
- **An existing closeout workflow with hand-edits** — on re-scaffold, surface the diff and let the user keep their edits; never silently overwrite.
- **User invokes mid-session, not at the end** — fine; the closeout is on-demand. Just run it.
