---
name: session-closeout
description: >
  Set up session closeout in a repo. Generates a repo-tailored session-closeout.md workflow
  fitted to that repo's actual logging surfaces, and vendors the thin `closeout` runner skill
  that invokes it. Use when the user says "set up session closeout", "scaffold a closeout",
  "add closeout to this repo", "my closeout workflow is out of date", or when a repo has a
  closeout workflow but no way to invoke it. This skill does NOT run the closeout — running
  is the vendored `closeout` skill's job (`/closeout`).
---

# session-closeout — the closeout *generator*

The capstone skill of the agentic scaffold. It sets up end-of-session closeout in a target repo, producing two artefacts:

1. A repo-tailored **`session-closeout.md` workflow** — a standing, editable, plugin-independent procedure fitted to that repo's actual logging surfaces.
2. A vendored **`closeout` runner skill** — a thin, committed dispatcher that finds the nearest workflow and follows it. It is what gives the repo (and everyone who clones it) `/closeout`.

**This skill does not run closeouts.** Generating and running are split deliberately: running belongs to the vendored skill so that every closeout — yours and a collaborator's — goes through the one code path that ships with the repo. See Decision 016. If the user asks to *run* a closeout, hand off to `/closeout`.

It is an **orchestrator**, not a monolith. The workflows it generates delegate changelog work to `agentic-scaffold:logchange` and deep consistency checks to `agentic-scaffold:repo-audit` rather than re-implementing them. The closeout owns only what nothing else does — surfacing to-dos, the handoff decision, and assembling the session's close.

**Core principle — adaptivity.** No two repos have the same logging surfaces. A bare scaffolded folder may have only `AGENTS.md` and no git; a mature repo has `DECISIONS.md`, `CHANGELOG.md`, `ROADMAP.md`, skills, hooks. The skill detects what the repo actually has and generates a closeout containing only the relevant steps — modular, not mandatory.

> **Design rationale & invariants:** Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. Read `${AGENTIC_SCAFFOLD_ROOT}/skills/init/references/design-principles.md` before generating a workflow — Principle 7 (rules at the narrowest scope) and progressive disclosure govern how the closeout is assembled. The modular step-blocks the generator draws from live in `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-blocks.md`; the runner skill it vendors lives in `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/runner-skill-template.md`.

## Step 1: Detect what the repo already has

Check for both artefacts independently — they can exist apart, and which are missing decides the work.

```bash
# the workflow — first hit wins
for p in ops/workflows/session-closeout.md .agents/workflows/session-closeout.md \
         docs/workflows/session-closeout.md session-closeout.md; do
  [ -f "$p" ] && echo "WORKFLOW: $p" && break
done

# the vendored runner
for p in .agents/skills/closeout/SKILL.md .claude/skills/closeout/SKILL.md; do
  [ -f "$p" ] && echo "RUNNER: $p" && break
done
```

| Found | Do this |
|---|---|
| Neither | **Full scaffold.** Steps 2 → 5. |
| Workflow only | **Runner-only vendor.** Skip generation entirely — the workflow exists and may be hand-written or hand-edited. Go straight to Step 5b, then run the Step 6 staleness check and report. |
| Runner only | Unusual (runner vendored, workflow deleted). Full scaffold, Steps 2 → 5, but don't re-vendor the runner if it's current. |
| Both | **Nothing to build.** Run the Step 6 staleness check and report. Tell the user `/closeout` is how they run it. |

The *workflow only* case is the common one for a repo that adopted closeout before this split, or wrote its workflow by hand. Never regenerate over an existing workflow without an explicit ask — vendor the runner and leave the workflow alone.

## Step 2: Detect the repo's logging surfaces

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

# app layer — per-app CHANGELOG/ROADMAP inside an apps/ or app/ directory
find apps app -maxdepth 2 \( -name CHANGELOG.md -o -name ROADMAP.md \) 2>/dev/null | head -1

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
| app layer | per-app `CHANGELOG.md`/`ROADMAP.md` under `apps/` or `app/`, plus a registry carrying `version` fields | the app-changelogs block |
| nested structure | nested `AGENTS.md` / project subfolders | the per-folder / project-ops block |
| generated files | post-commit hook + generator scripts | the generated-file freshness block |
| `repo-audit` available | the skill is installed | the consistency block delegates to it |
| versioned | a version manifest or git tags | the version-bump-recommendation block |

**No git is a first-class case.** If git is absent, the closeout has no commit step — its terminal action is confirming records are reconciled and, if work is being deferred, writing the handoff file. Never assume the folder is git-tracked.

## Step 3: Assemble the tailored workflow

Read `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-blocks.md`. Assemble `session-closeout.md` from:

- the **header** block — always
- the **to-dos** block — always
- one **reconcile block per detected surface**, ordered: consistency → decisions → roadmap → skill changelogs → app changelogs → project ops → changelog
- the **generated-files** block — if hooks/generators detected
- the **local-indexes** block — if the repo keeps hand-maintained index/registry files (READMEs with inventories, registries, MOCs)
- the **git** block (session delta + commit) — *only if git detected*
- the **version-bump recommendation** block — if versioned
- the **handoff** block — always
- the **footer** block — always

Wire delegations: where `logchange` / `repo-audit` are available, the changelog and consistency blocks delegate to them; where not, they degrade to inline reminders so the generated file still works standalone. Interpolate the repo's name, the detected handoff-file location, and the workflow's own path.

## Step 4: Present & confirm

Show the user: which surfaces were detected, which blocks the workflow will contain, where the workflow file will be written, and where the runner skill will be vendored. **GATE: do not write until the user approves.**

## Step 5a: Write the workflow

Write `session-closeout.md` to the detected location. Default `ops/workflows/` (create it if needed); if the repo already keeps workflow/runbook files elsewhere, use that.

## Step 5b: Vendor the runner skill

Copy `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/runner-skill-template.md` **verbatim** to the repo's skills directory as `closeout/SKILL.md`. Only substitute the workflow filename if this repo's workflow is not named `session-closeout.md`.

Choose the destination in this order:

1. `.agents/skills/closeout/SKILL.md` — if `.agents/skills/` exists. This is the canonical location in this ecosystem.
2. `.claude/skills/closeout/SKILL.md` — if `.claude/skills/` exists as a real directory and `.agents/skills/` does not.
3. Otherwise create `.agents/skills/` and use it.

**Claude Code discovery.** Claude Code reads `.claude/skills/`. If the runner landed in `.agents/skills/` and `.claude/skills` does not already exist, create the compatibility symlink:

```bash
mkdir -p .claude && ln -s ../.agents/skills .claude/skills
```

If `.claude/skills` already exists as a real directory (not a symlink), leave it alone and vendor there instead — never clobber it.

**Then make it shareable.** The whole point of vendoring is that collaborators get `/closeout` from the clone. If the repo is under git, tell the user the runner and the symlink need committing, and check nothing excludes them:

```bash
git check-ignore -v .agents/skills/closeout/SKILL.md .claude/skills 2>/dev/null
```

If either is ignored, say so plainly — the vendoring is inert until that's fixed.

**Codex note.** Codex installs skills globally via `scripts/install_codex_skills.sh`, not from repo-local directories. The vendored runner gives Claude Code and Cowork users `/closeout`; Codex users invoke the workflow by asking for it in natural language, or install the runner globally themselves.

Finish by telling the user: closeout is set up, and `/closeout` runs it. Do not offer to run it here.

## Step 6: Staleness check

When a workflow already exists, compare the repo's current surfaces (Step 2 detection) against the blocks that workflow contains. If the repo has gained a surface the workflow doesn't cover — a `CHANGELOG.md` added, a skills directory created, git initialised — report the gap and offer to regenerate, preserving any hand-edits the user flags. If nothing has drifted, say so and stop.

Also check the vendored runner against `references/runner-skill-template.md`. If it has drifted from the current template, report the diff and offer to refresh it — but never overwrite hand-edits without showing them first.

## Edge cases

- **Target is not a git repo** — expected and supported. The generated closeout simply omits the git block; its close is the reconciled record plus an optional handoff file. The runner is still worth vendoring if anyone else works in the folder.
- **No logging surfaces at all** (bare folder, only `AGENTS.md`) — the closeout is just the to-dos block, the handoff block, and the footer. That is correct and useful; don't pad it.
- **`logchange` / `repo-audit` not installed** — the changelog and consistency blocks degrade to inline reminders. The generated workflow names this so a future reader understands why.
- **An existing workflow with hand-edits** — on regenerate, surface the diff and let the user keep their edits; never silently overwrite.
- **A repo that can't or won't commit a skills directory** — vendoring is optional. Generate the workflow anyway; without the runner, the workflow is followed by asking for it in natural language rather than via `/closeout`.
- **User asks this skill to run the closeout** — it doesn't. Point them at `/closeout`, and if no runner is vendored yet, offer Step 5b first.
