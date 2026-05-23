# Closeout step-blocks

The modular library the `session-closeout` skill assembles a repo-tailored `session-closeout.md` from (SKILL.md Step 3). Each block below carries an **Include** condition. The skill emits the header and footer always, the to-dos and handoff blocks always, and one reconcile block per detected surface — then numbers the steps at assembly time, since which blocks appear varies by repo.

Interpolation placeholders: `{{repo_name}}`, `{{workflow_path}}` (where the file lands), `{{handoff_dir}}` (detected handoff location).

Keep the generated file at orchestrator altitude: each step is a short prompt that routes to a deeper tool or surface, not a re-implementation of it. Reconcile records first; build the commit (if any) last.

---

## Block: header — *always*

Frontmatter: `title`, `type: workflow`, `date`, `status: active`, `scope` (one line). Then:

> # Workflow — Session Closeout
>
> A short orientation pass at the end of a work session on {{repo_name}}: catch anything the session changed that hasn't been recorded, then close the session out. An **orchestrator** — it routes to deeper tools rather than re-implementing them. Reconcile the records first; build the commit (if any) last.
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

## Block: project-ops — *include if the repo has nested AGENTS.md / project subfolders*

> **Reconcile project ops.** Any project-specific operational work (a migration, a wave, a brief, a review)? Log it to that project's ops location.

## Block: changelog — *include if CHANGELOG.md exists; delegates to logchange*

> **Reconcile the changelog.** Do qualifying changes deserve a changelog entry?

If `logchange` is available, append: *Run `/logchange` — it distils the session's meaningful changes into the changelog.* If not, append: *Add a short entry by hand, summarising the session's meaningful changes — not a commit dump.*

## Block: generated-files — *include if hooks/generators detected*

> **Generated files.** Confirm any auto-generated files (indexes, maps) reflect the current state — a verification, not a regeneration; the post-commit hook still runs and is idempotent.

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
> The repo's instruction file (`AGENTS.md`), its decision log and changelog where present, and `agentic-scaffold` skills `logchange` and `repo-audit` where installed.
