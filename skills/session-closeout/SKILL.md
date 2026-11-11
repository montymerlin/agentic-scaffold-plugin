---
name: session-closeout
description: >
  Set up session closeout in a repo. Generates a repo-tailored session-closeout.md workflow
  fitted to that repo's actual logging surfaces, and vendors the thin `closeout` runner skill
  that invokes it. Use when the user says "set up session closeout", "scaffold a closeout",
  "add closeout to this repo", "my closeout workflow is out of date", or when a repo has a
  closeout workflow but no way to invoke it. This skill does NOT run the closeout — running
  is the vendored `closeout` skill's job (`/closeout`).
metadata:
  created: "2026-05-23"
  updated: "2026-11-11"
  stage: "evergreen"
---

# session-closeout — the closeout *generator*

The capstone skill of the agentic scaffold. It sets up end-of-session closeout in a target repo, producing two artefacts:

1. A repo-tailored **`session-closeout.md` workflow** — a standing, editable, plugin-independent procedure fitted to that repo's actual logging surfaces.
2. A vendored **`closeout` runner skill** — a thin, committed dispatcher that finds the nearest workflow and follows it. It is what gives the repo (and everyone who clones it) `/closeout`.

**This skill does not run closeouts.** Generating and running are split deliberately: running belongs to the vendored skill so that every closeout — yours and a collaborator's — goes through the one code path that ships with the repo. See Decision 016. If the user asks to *run* a closeout, hand off to `/closeout`.

It is an **orchestrator**, not a monolith. Each step of a generated workflow states an objective and what done looks like, and points to the repo's own file for the detail: its decision guide, its release process, its security policy. Deep consistency checks go to `agentic-scaffold:repo-audit` where it is installed.

**Core principle: a menu, not a template.** No two repos have the same logging surfaces. A bare folder may have only `AGENTS.md` and no git; a mature repo has decision logs, changelogs, plans, skills and hooks. The skill draws on a library of steps, takes only those the repo needs, and writes each in the repo's own terms. The result is the repo's own file, maintained by hand from then on.

> **Design rationale & invariants:** Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. Read `${AGENTIC_SCAFFOLD_ROOT}/skills/init/references/design-principles.md` before generating a workflow — Principle 7 (rules at the narrowest scope) and progressive disclosure govern how the closeout is assembled. The library of steps the generator draws from lives in `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-library.md`; the runner skill it vendors lives in `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/runner-skill-template.md`.

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

## Step 2: Find out what the repo keeps

Learn the repo's logging surfaces before choosing steps. Read its root instruction file first: it usually names its decision log, changelog, plans, journal and conventions, and says where things get logged. Then look for what it doesn't mention. Some quick probes, as a starting point:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "GIT: yes" || echo "GIT: no"
ls DECISIONS.md ROADMAP.md CHANGELOG.md MEMORY.md SECURITY.md 2>/dev/null
ls -d .agents/skills .claude/skills ops/decisions ops/specs ops/plans journal 2>/dev/null
find . -mindepth 2 \( -name AGENTS.md -o -name CLAUDE.md \) -not -path './.git/*' -not -path './node_modules/*' 2>/dev/null | head -3
git submodule status 2>/dev/null | head -3
ls .pre-commit-config.yaml .githooks 2>/dev/null
```

**Done when** you can say, for each entry in the library, whether this repo has what its *When a repo wants it* line describes, and which file owns the detail the step would point to.

**No git is a first-class case.** If git is absent, the steps that need it drop out, and the closeout ends with the records reconciled. Never assume the folder is git-tracked.

## Step 3: Draft the workflow

Read `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/closeout-library.md`. Take the frame (header, the rules that apply, output, keeping this file) and each step the repo wants, in the library's order. Then rewrite every step in this repo's terms, following the library's *How to write a step*:

- one or two sentences on what must be true when it is done;
- a pointer to the repo's owner file instead of a copy of its rules;
- the repo's own names, from each entry's *Make it yours*;
- an *Origin* only where it explains a check a reader might otherwise cut, and then in the changelog rather than the step.

Interpolate the repo's name, the workflow's path and the runner's path. A closeout for a bare folder is the to-dos step, *Nothing left open* and the frame; don't pad it.

## Step 4: Present & confirm

Show the user what was found, which steps the workflow will hold and why, and the drafted text itself, with where the workflow will be written and where the runner will be vendored. **GATE: do not write until the user approves the text.**

## Step 5a: Write the workflow

Write `session-closeout.md` to the detected location. Default `ops/workflows/` (create it if needed); if the repo already keeps workflow/runbook files elsewhere, use that.

Start its history beside it in `changelogs/session-closeout.md`: a `v1.0` entry naming the steps chosen and any *Origin* worth keeping. The workflow's frontmatter carries `version:` and `changelog:`. History stays out of the workflow because every closeout loads the workflow and only an editor needs the history. If the repo already keeps workflow histories somewhere else, follow it.

## Step 5b: Vendor the runner skill

Copy `${AGENTIC_SCAFFOLD_ROOT}/skills/session-closeout/references/runner-skill-template.md` **verbatim** to the repo's skills directory as `closeout/SKILL.md`. Only substitute the workflow filename if this repo's workflow is not named `session-closeout.md`. Copy `references/runner-LICENSE.txt` beside it as `closeout/LICENSE.txt`: the runner is MIT-licensed, and its notice travels with every copy.

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

When a workflow already exists, compare what the repo keeps now (Step 2) with the steps the workflow holds. If the repo has gained a surface no step covers, or retired one a step still names, report it and propose the change to that one step, drafted from the library in the workflow's own voice, with a changelog entry. Never offer to regenerate the whole file: it is the repo's own, maintained by hand, and its wording carries lessons the library doesn't know. If nothing has drifted, say so and stop.

Also check the vendored runner against `references/runner-skill-template.md`, and that `closeout/LICENSE.txt` sits beside it. If it has drifted from the current template, or the licence file is missing, report the diff and offer to refresh it — but never overwrite hand-edits without showing them first.

## Edge cases

- **Target is not a git repo:** expected and supported. The steps that need git drop out, and the close is the reconciled record. The runner is still worth vendoring if anyone else works in the folder.
- **No logging surfaces at all** (a bare folder with only `AGENTS.md`): the closeout is the to-dos step, *Nothing left open* and the frame. That is correct and useful; don't pad it.
- **`repo-audit` not installed:** the cross-references step says to check the touched files by hand.
- **An existing workflow:** never overwrite it. Propose step-level changes (Step 6) and show the diff.
- **A repo that can't or won't commit a skills directory** — vendoring is optional. Generate the workflow anyway; without the runner, the workflow is followed by asking for it in natural language rather than via `/closeout`.
- **User asks this skill to run the closeout** — it doesn't. Point them at `/closeout`, and if no runner is vendored yet, offer Step 5b first.
