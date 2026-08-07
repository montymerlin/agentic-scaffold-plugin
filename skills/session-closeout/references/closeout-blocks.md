# Closeout step-blocks

The modular library the `session-closeout` skill assembles a repo-tailored `session-closeout.md` from (SKILL.md Step 3). Each block below carries an **Include** condition. The skill emits the header and footer always, the to-dos and handoff blocks always, and one reconcile block per detected surface — then numbers the steps at assembly time, since which blocks appear varies by repo.

Interpolation placeholders: `{{repo_name}}`, `{{workflow_path}}` (where the file lands), `{{handoff_dir}}` (detected handoff location), `{{runner_path}}` (where the `closeout` runner skill was vendored — see SKILL.md Step 5b).

Keep the generated file at orchestrator altitude: each step is a short prompt that routes to a deeper tool or surface, not a re-implementation of it. Reconcile records first; build the commit (if any) last.

---

## Block: header — *always*

Frontmatter: `title`, `type: workflow`, `date`, `status: active`, `scope` (one line). Then:

> # Workflow — Session Closeout
>
> A short orientation pass at the end of a work session on {{repo_name}}: catch anything the session changed that hasn't been recorded, then close the session out. An **orchestrator** — it routes to deeper tools rather than re-implementing them. Reconcile the records first; build the commit (if any) last.
>
> **This file is the source of truth for the closeout.** `/closeout` — the thin runner vendored at `{{runner_path}}` — resolves this file and follows it; don't improvise a closeout from generic steps. The `agentic-scaffold:session-closeout` skill *generated* this file and vendored that runner; it does not run closeouts. If {{repo_name}} later gains or retires a logging surface, re-run that skill: its staleness check compares this file against the repo's current surfaces and offers to regenerate, preserving hand-edits you flag.
>
> ## When to use
> Ending a substantial work session; preparing a commit; finishing a structural change; or when the user says "close out", "wrap up", "prepare commit", "session end". Not after every micro-task.
>
> ## Non-goals
> Does not re-run deep audits by hand, bump the version automatically, run on every commit, or run test/build suites.

## Block: to-dos — *always*

> **Surface outstanding to-dos.** Review the session for unfinished or unaddressed items. For each, the user chooses: address it now, drop it, or defer it to a handoff file (see *Handoff file* below).

## Block: consistency — *include when the repo has 2+ logging surfaces*

> **Cross-file consistency.** Did the session's changes require updates elsewhere — cross-links, references, anchors, files that name what changed?

If `repo-audit` is available, append: *For a structural session, run `/repo-audit` for the deep check rather than eyeballing it.* If not, append: *Eyeball the files the session touched for stale references — there is no audit skill installed to do this automatically.*

## Block: decisions — *include if DECISIONS.md exists*

> **Reconcile decisions.** Any judgement made this session significant enough to log, and not yet logged? Any existing entry needing a status or superseded-by update? Log or update it now, against the repo's own "when to log a decision" gate.

## Block: roadmap — *include if ROADMAP.md exists*

> **Reconcile the roadmap.** Did the session progress, complete, or reject any roadmap item? Move it to the right section and update its status.

## Block: skill-changelogs — *include if a skills directory exists*

> **Reconcile skill changelogs.** Any skill-internal version bump or convention change this session? Update that skill's `SKILL.md` changelog or `references/changelog.md`.

## Block: app-changelogs — *include when the repo keeps per-app CHANGELOG/ROADMAP files (an app layer)*

> **App changelogs & roadmaps.** Did the session touch any app in the repo's app layer? If yes, ask **"is this a seam?"** — the end of a working session on an app usually is. If so: cut a versioned entry in that app's `CHANGELOG.md` (newest-first, what shipped and what taught it), mirror the version wherever the repo's app registry advertises it, and retire shipped items from that app's `ROADMAP.md`. App-internal work logs only at the app layer — the repo root keeps a capability-level pointer at most.

*(Detection hint for the generator: look for `CHANGELOG.md`/`ROADMAP.md` files inside an apps/ or app/ directory, and a registry file — e.g. `hubs.json` — carrying `version` fields. Contributed from montymerlinHQ 2026-07-19, where the app layer is governed by its DEC-0049; bridging-worlds' `app/` layer matches the same shape.)*

## Block: project-ops — *include if the repo has nested AGENTS.md / project subfolders*

> **Reconcile project ops.** Any project-specific operational work (a migration, a wave, a brief, a review)? Log it to that project's ops location.

## Block: changelog — *include if CHANGELOG.md exists; delegates to logchange*

> **Reconcile the changelog.** Do qualifying changes deserve a changelog entry?

If `logchange` is available, append: *Run `/logchange` — it distils the session's meaningful changes into the changelog.* If not, append: *Add a short entry by hand, summarising the session's meaningful changes — not a commit dump.*

## Block: generated-files — *include if hooks/generators detected*

> **Generated files.** Confirm any auto-generated files (indexes, maps) reflect the current state — a verification, not a regeneration; the post-commit hook still runs and is idempotent.

## Block: local-indexes — *include when the repo keeps hand-maintained index/registry files*

> **Local indexes & READMEs.** Derive the directories the session touched (`git log <session-range> --name-only | xargs -n1 dirname | sort -u`, or the session's file list where git is absent). For each touched directory and its parent, check whether a README / index / registry file **enumerates** what changed — a registry table, an MOC, an inventory list, an architecture map. The test: *does this file claim to list things, and did the session change the list?* Update any that drifted. This covers hand-maintained indexes only — auto-generated ones belong to the generated-files step.
>
> Where the repo keeps session-context surfaces (a memory index, a daily journal/log), add one glance each: did the session produce durable context the memory surface should hold, and does today's log entry capture the session?

*(Detection hint for the generator: look for README.md files containing tables or lists that enumerate sibling files/folders, registry files named in the repo's instruction file, and MOC/landscape/index conventions. If none exist, omit the block.)*

## Block: git — *include ONLY if the repo is under git*

> **Inspect the session delta.** Run `git status`, `git diff --stat`, `git diff --name-only`, `git log --oneline -n 10`. Confirm the delta matches what the reconcile steps above produced — nothing unexpected, nothing missing.
>
> **Build the commit.** Draft a commit message in the repo's conventional style, referencing the logging surfaces touched. Present it for confirmation; the user executes it or hands it to a commit tool.

*(Omit this block entirely for a non-git folder. The closeout's terminal action is then the reconciled record plus, if deferring, the handoff file.)*

## Block: version-bump recommendation — *include if the repo is versioned*

> **Version bump?** The closeout never bumps the version. But if the session's work looks like it crosses the repo's bump bar, say so and ask the user whether to run the version-bump process. Flag and ask; never act.

## Block: handoff — *always*

> ## Handoff file
> When outstanding to-dos are deferred rather than addressed, capture them so the next session picks up cleanly.
>
> - **Path:** `{{handoff_dir}}` (date-stamped if the repo dates its operational files)
> - **Contents:** what changed this session · what remains unfinished · unresolved decisions · the recommended next task · files to inspect first

## Block: footer — *always*

> ## Expected output
> A reconciled record (whichever logging surfaces the repo has, current with the session); a drafted commit message if the repo uses git; optionally a handoff file; optionally a flagged version-bump recommendation.
>
> ## Common failure modes
> Building the commit before the records are reconciled · re-running deep checks by hand instead of delegating · bumping the version inside the closeout · running the full closeout after a micro-task.
>
> ## Related
> `{{runner_path}}` — `/closeout`, the runner that follows this workflow · the repo's instruction file (`AGENTS.md`), its decision log and changelog where present · `agentic-scaffold` skills `logchange` and `repo-audit` where installed, and `session-closeout` to regenerate this file when the repo's surfaces change.
