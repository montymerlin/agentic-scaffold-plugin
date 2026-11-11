# Closeout library

The menu of steps the `session-closeout` skill draws on when it drafts a repo's `session-closeout.md` (SKILL.md Step 3). It is good practice, not fixed text. A repo takes the steps that fit and rewrites each in its own terms.

Each step states an **objective and what done looks like**. Each entry also says **when a repo wants it**, what to change to **make it yours**, and sometimes its **origin**: the miss that taught it, worth keeping when the step is rewritten.

## How to write a step

- One or two sentences: what must be true when the step is done. Leave the how to the agent and to the file that owns it.
- Point to the repo's owner file (its decision guide, release process, security policy) instead of restating it. A copy drifts from its source, and every closeout pays to read it.
- Use the repo's own names for its files and layers.
- A command belongs in a step only when it is the step: a generator to run, a script that sweeps.
- Keep the step's history out of the workflow. It goes in the workflow's changelog (Step 5a of SKILL.md).

Placeholders: `{{repo_name}}`, `{{workflow_path}}`, `{{runner_path}}`.

---

## Frame

### Header: always

Frontmatter: `title`, `type: workflow`, `version: "1.0"`, `changelog: "changelogs/session-closeout.md"`, `date`, `status: active`, `scope`. Then a short opening:

> # Workflow: Session closeout
>
> The closeout catches what a session on {{repo_name}} changed but hasn't recorded, then closes the session cleanly. `/closeout`, the runner at `{{runner_path}}`, follows this file. Each step says what must be true when it is done; the file it names owns the how.
>
> ## When to run it
>
> Once, at the end of a substantial session, however many commits it made. Skip it for a trivial one, and never run it per commit.

### Rules that hold throughout: always, pick the ones that apply

- **Records first, commits last,** so the final commits carry the closeout's own updates. *(Always, when the repo uses git.)*
- **This session's work only.** Reconcile and commit what this session changed, and leave other people's and other sessions' work alone. If this session changed something another live session relies on, say so. *(When several people or agent sessions share a working tree.)*
- **Work keeps its own date.** A session can span days. Dated files keep the day they were written, and the closeout credits work to the day it happened; if the split isn't known, say so. *(When the repo dates its files or keeps a journal. Origin: a closeout dated several days of work to its own day.)*
- **Name who ran it,** the person and the AI runtime, in the closeout's first line. *(When more than one person or runtime works in the repo.)*

### Output: always

> The closeout's report says what each step checked and changed, names any version cut, and lists the commits made.

### Keeping this file: always

> This file is maintained by hand. When {{repo_name}} gains or retires a logging surface, change the step that covers it. `agentic-scaffold:session-closeout` can spot the gap and suggest a step. Its history is in `changelogs/session-closeout.md`; read it before cutting a check.

---

## Steps

Ordered as a generated workflow would run them. Number them when assembling.

### To-dos settled: always

**Step.** Outline what is unfinished or deferred, with the next step for each, and settle each with the person: do it now, drop it or defer it. Deferred work goes where the repo already keeps it.

**When a repo wants it:** always.

**Make it yours:** name where deferred work goes: a journal, a plan or spec, an issue tracker. Write a handoff file only if the repo has nowhere else for it, and say where it lives.

**Origin:** handoff files went stale wherever a plan or journal could hold the same thing.

### Contracts held, calls rechecked

**Step.** For each file the session changed, re-read the instructions that govern it: the nearest folder or subproject `AGENTS.md` (or `CLAUDE.md`), or the README or skill that serves as its contract. A session can skip these or lose them to compaction. Check the changes still follow them, and revisit the judgement calls made under them, such as how something was classified or where it was filed, with what the session now knows. Fix what is clearly wrong, and say in the closeout output what was checked and what changed, including any contract the session wrote under without reading first.

**When a repo wants it:** it has instruction files below the root, or READMEs and skills that act as a folder's rules.

**Make it yours:** usually nothing. This step is written generally on purpose.

**Origin:** a personal garden, 2026-11-10. Nested contracts are found by search, not loaded, so nothing else checked they were read. Its first run caught a note that broke its folder's rule.

### Freshness fields honest

**Step.** Every file the session meaningfully changed that carries a freshness field (`updated`, `last_edited`, `version_date`, a status, a review date) shows the change, and any field left alone was left alone on purpose.

**When a repo wants it:** its files carry hand-kept dates, statuses or review fields.

**Make it yours:** name the fields and which kinds of file carry them, and point to the contract that defines "meaningful".

**Origin:** an organisational garden, where hand-kept dates drifted until a closeout step guarded them.

### Decisions logged

**Step.** Every judgement the session made that passes the repo's bar for a decision has an entry, and any entry the session overturned is amended or superseded.

**When a repo wants it:** it keeps a decision log, as one `DECISIONS.md` or a folder of one file per decision.

**Make it yours:** point to the repo's own guide for when to log a decision, and to its helper or template for writing one.

### Plans current

**Step.** Each plan, spec or roadmap item the session moved shows where it stands now, and any generated view of them has been regenerated.

**When a repo wants it:** it has a `ROADMAP.md`, a specs or plans folder, or an issue tracker it keeps in step.

**Make it yours:** name the plan surface and its rules, and the command that regenerates any view.

### Every repo the session touched is closed out

**Step.** Each other repo the session changed (a submodule, a nested repo, a sibling checkout) holds its own record under its own instructions. If it has its own closeout workflow, run it for that repo's changes. Commit the inner repo first, then record the new pointer in the outer one. Pushing waits for the person's yes, but say when work only takes effect once pushed.

**When a repo wants it:** it has submodules or nested repos, or its sessions often work across several repos.

**Make it yours:** name the repos that have their own closeouts, and anything that only takes effect once pushed.

**Origin:** a personal garden, 2026-11-11, after a config commit sat unpushed for a week and a server kept acting on the old one.

### The narrowest owner holds the record

**Step.** Work owned by a narrower layer (an app, a skill, a package, a project folder) is logged in that layer's own files, and the root records only what no narrower layer owns. The same goes for instructions: anything added to a root instruction file sits in the narrowest file that governs it.

**When a repo wants it:** it has layers with their own changelogs, roadmaps or logs: skills with inline changelogs, apps with their own `CHANGELOG.md`, project folders with ops logs.

**Make it yours:** list the repo's layers and what each records, or point to where the repo already lists them. Name any registry that mirrors a layer's version.

**Origin:** a personal garden, where a new app layer had no closeout step until one was added.

### A version when one shipped

**Step.** If the session shipped something that clears the repo's bar for a release, the version is cut and tagged, or proposed, as the repo prefers. Most sessions cut nothing, which is correct.

**When a repo wants it:** it keeps a `CHANGELOG.md` or a version manifest.

**Make it yours:** point to the repo's release process and its bar for a version, and say whether the closeout cuts the version itself or asks first. Use `agentic-scaffold:logchange` only if the changelog follows its date-narrative format.

### Indexes and memory current

**Step.** Generated indexes match the content, and any hand-kept file that lists what the session changed has been updated. The test is whether the file claims to list things and the session changed the list. The repo's memory surface holds any durable context the session created, and any local search index is fresh.

**When a repo wants it:** it keeps generated indexes, hand-kept registries, maps or inventories, a memory file the agent reads each session, or a local search index.

**Make it yours:** name the generators and when each needs running, the hand-kept lists most likely to drift, the memory file, and the search index's refresh command.

**Origin:** a personal garden, 2026-07-19, where a registry row was updated by luck rather than by process.

### The session recorded

**Step.** The repo's session record (a daily journal, a session log) captures what happened and why, linking decisions and plans rather than repeating them.

**When a repo wants it:** it keeps a journal or session log.

**Make it yours:** say where entries go, one per day or one per session, the frontmatter they need, and anything that must never go in them.

### Cross-references agree

**Step.** Every link, reference and file that names what the session changed still matches it, including what the closeout itself just wrote. For structural work, run `/repo-audit` rather than checking by hand.

**When a repo wants it:** it has two or more files that refer to each other. If `repo-audit` isn't installed, check the files the session touched by hand and say so.

**Make it yours:** say which kinds of work count as structural here.

### Private material kept out of logs

**Step.** Nothing sensitive was copied into a file or message with wider reach than its source: logs, changelogs, memory, journals or commit messages.

**When a repo wants it:** it holds personal, client or otherwise restricted material, or has a security policy with sensitivity tiers.

**Make it yours:** point to the policy, and name what counts as sensitive here and which files have wider reach.

**Origin:** a personal garden, where a filter on file paths would miss a figure quoted out of its source.

### Nothing left open

**Step.** Anything the session started that shouldn't outlive it is stopped or removed: a dev server, a test container, a background job, a mounted volume, temp files outside the scratch area. Long-running services the repo relies on stay up, but one whose code changed is restarted so it runs the new code.

**When a repo wants it:** always. Add specifics when the repo has them.

**Make it yours:** name anything that must never be left open, such as an encrypted volume, and the services that stay up.

**Origin:** a personal garden, where an encrypted vault stayed mounted for 30 hours across two sessions and a full closeout.

### Branches and worktrees resolved

**Step.** The session's branch or worktree has an outcome (merged, kept with a reason, or handed to a pull request), and nothing it created is left without one. Other branches and worktrees are listed, not touched, unless the person says so.

**When a repo wants it:** it uses git branches or worktrees for sessions, especially with collaborators and a remote.

**Make it yours:** name the integration branch, the cleanup order, and which deletions need confirmation.

**Origin:** an organisational garden, where worktrees and branches piled up across sessions.

### The delta matches

**Step.** The working-tree status, the diff and the recent log show what the closeout reconciled: nothing unexpected, nothing missing.

**When a repo wants it:** it uses git.

**Make it yours:** add any backup or snapshot worth refreshing after major work, and whether to ask first.

### Commits made

**Step.** The session's remaining work and the closeout's own updates are committed under the repo's commit conventions, each message pointing to the decision, plan and session record it relates to.

**When a repo wants it:** it uses git.

**Make it yours:** point to the commit conventions, and say whether the closeout commits itself or presents the messages for approval.

### Housekeeping swept, last

**Step.** Routine edits that tools leave behind are committed by the repo's sweep, after the session's own commits, so a deliberate edit can't be swept as routine.

**When a repo wants it:** it has a script that commits routine edits, such as UI state or favourites.

**Make it yours:** name the script, and say who owns what counts as routine.
