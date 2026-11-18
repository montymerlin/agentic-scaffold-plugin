# Audit library

The checks `repo-audit` draws on. It is good practice, not fixed text. A repo with its own audit workflow took the checks that fit and wrote each in its own terms (SKILL.md, *Set up*). A repo without one is audited against this file as it stands.

Each check states an **objective and what done looks like**. Commands, thresholds and pattern lists are dated suggestions. Each entry also says **when a repo wants it**, what to change to **make it yours**, and sometimes its **origin**: the miss that taught it, worth keeping when the check is rewritten.

## How to write a check

- One or two sentences: what must be true when the check passes. Leave the how to the agent and to the file that owns it.
- Where the repo has a validator that enforces it, the check is "run it and report"; don't restate the rule.
- Use the repo's own names for its files, records and validators.
- Keep each check's history out of the workflow. It goes in the workflow's changelog.

Placeholders: `{{repo_name}}`, `{{workflow_path}}`, `{{record_path}}`.

---

## Frame

### Header: always

Frontmatter: `title`, `type: workflow`, `version: "1.0"`, `changelog: "changelogs/repo-audit.md"`, `date`, `status: active`, `scope`. Then a short opening:

> # Workflow: Repo audit
>
> The audit checks that {{repo_name}}'s instructions, records and references agree with each other and with the repo, and that nothing sensitive is exposed. `/repo-audit` follows this file. Each check says what must be true; the file it names owns the how. The audit reports and proposes, and changes nothing until the user says yes, apart from its own dated record.

### Before you start: always

- **Check this file first.** Every file, script, section and command it names still exists, and the repo has no validator, record or security surface it doesn't cover. Report drift as ⚠️, with a proposed change to the one check it affects.
- **Read the repo's rules.** Its root instructions, and the contracts they name for the files in scope, decide what good looks like. A convention a check suggests never overrides one the repo chose on purpose. Where the repo records why something is the way it is, don't flag it.
- **Run the repo's validators** and report what they say. Don't re-check by hand what they enforce; spend the audit on what they can't judge.
- **Set the scope.** Run on its own, audit the whole repo: that is where drift no single session sees shows up. Called from a closeout or another workflow, audit only what the session changed and what that could break, and skip any check the caller's own steps already made, such as records, changelog, plans and decisions; say which you skipped. What the call adds is depth: cross-references, the instructions when the session changed them, and security when it touched settings, ignore rules or dependencies.

**Make it yours:** name the validators (a pre-commit config, CI, `--check` scripts, a secret scanner) and how to run them across the whole repo.

### Then look beyond this file: always

> After the checks, spend a bounded pass auditing {{repo_name}} as you would without this file: anything sensitive, heavy, stale or broken that no check asked about. Report it in its own section, and propose a check for anything worth catching every time.

**Origin:** in its author's garden, a bare audit run beside the garden's workflow found the most severe issue, a secret pushed to a public repo the garden held as a clone, because nothing confined it to the checks (2026-11-17).

### Report: always

> One punch list per phase: ✅ fine, ⚠️ worth a look, ❌ needs fixing, ℹ️ known or accepted. Lead with what the validators said. Then ask which findings to fix now and which to leave, and apply only the fixes the user approves.

### Record: always

> Called from a closeout, the audit writes nothing: the closeout's report covers it. Run across the whole repo, it leaves one short dated record at `{{record_path}}`: what it found, which checks found something, and what was fixed or left. The next run, or a reminder, reads it to see when the last audit was. Never append to a reader-facing changelog.

**Make it yours:** where the repo keeps dated audits or notes, named so it is easy to find (for example `YYYY-MM-DD_repo-audit.md`), and what reminds someone to run it (a morning check-up, a calendar, a CI schedule). If the repo has nowhere for it, say so rather than invent a place.

### Keeping this file: always

> This file is maintained by hand. When {{repo_name}} gains a validator, change the check it now enforces to "run it". When an audit misses something real, add the check, with the miss, in `changelogs/repo-audit.md`. Read that history before cutting a check, and read the last few records: a check that only ever produces noise is a candidate to cut, and one that keeps catching the same problem is a candidate for a validator. `agentic-scaffold:repo-audit` can spot a check the library has that this file lacks.

---

## Artifact checks

### The records exist for what the repo does

**Check.** A reader can find what the repo is, how to work in it, what changed (if it ships versions) and why structural choices were made (if it makes them), in whatever form the repo uses. Done when each missing record is one this repo needs, not one a template expects.

**When a repo wants it:** always.

**Make it yours:** name the records the repo keeps and their form: one file per decision, a generated roadmap, no `DECISIONS.md` by design.

**Origin:** an audit flagged a garden at every run for a `DECISIONS.md` it had replaced, on purpose, with one file per decision.

### Versions agree

**Check.** Every manifest and file that names a version gives the same one, and the changelog's newest entry matches. A manifest ahead of the changelog means a missing entry, not a stale number. Done when they agree, or the mismatch is reported with the file that looks right.

**When a repo wants it:** it ships versions: a plugin, a package, apps with their own versions, workflows that carry one.

**Make it yours:** list where versions live, for example a manifest, an app registry, a workflow's frontmatter and its changelog.

**Origin:** caught an instruction file naming 0.5.0 while the manifest said 0.6.0 (agentic-scaffold, 2026-04-27).

### The changelog records what shipped

**Check.** Judge the changelog against the repo's own changelog rules, not a commit count: a reader-facing changelog that cuts a version only when something ships is current after many commits. Where the repo has no rules, commits since the last entry are a hint, not a finding.

**When a repo wants it:** it keeps a changelog.

**Make it yours:** point to the repo's release or changelog process.

### Plans and decisions agree

**Check.** Whatever the roadmap or plans mark as decided has a decision record, and no live plan rests on a decision since superseded.

**When a repo wants it:** it keeps both plans and decisions.

**Make it yours:** name the index checker, if one enforces this, and make the check "run it".

### Cross-references resolve

**Check.** Links, paths and names in scope point at something that exists and still says what the reference claims, in the form the repo's linking rules ask for. Whether a note links everything it should is curation, for the closeout or a gardening pass, not this check.

**When a repo wants it:** it has two or more files that refer to each other.

**Make it yours:** point to the linking rules and any link checker.

### The root instructions cover what an agent can't infer

**Check.** Read them as a new agent would. Done when they say what the repo is, what is safe and what needs asking first, where things go, which conventions differ from the obvious, and how to check work; and when they don't spend space on what the code, the folder names or a nested file already says. Judge the content, never the headings: a section removed on purpose is not a gap.

**When a repo wants it:** always.

**Origin:** a fixed-heading test flagged a garden for lacking a *Key Conventions* section it had removed on purpose as duplication (2026-11-10).

### The instructions fit the runtimes that read them

**Check.** Root instructions stay within what each runtime reads reliably. As of 2026-11, Claude Code's memory docs advise under about 200 lines, and Codex reads only the first 32 KiB.

**When a repo wants it:** always.

**Make it yours:** if the repo sets its own budget or a check enforces it, the check is "run it".

**Origin:** a garden's root file grew past what Codex reads, which led it to a byte budget enforced at commit (2026-11-10).

### Each rule lives in its narrowest home

**Check.** A folder instruction file adds rules that differ from root and bind every edit in that folder, and restates nothing from root; a root rule that binds one folder belongs in that folder. Judge by content, not shared headings. Suggest a new folder file only where such a rule exists, never because a folder has grown.

**When a repo wants it:** it has, or might need, nested instruction files.

**Make it yours:** point to the repo's rule for when a folder earns its own instructions.

---

## Security checks

[`security-checklist.md`](security-checklist.md) holds pattern lists and a baseline, as suggestions.

### No secrets in tracked files or history

**Check.** Run the repo's secret scanner over the scope if it has one, across history, not just staged files; otherwise grep the checklist's patterns. Cover every repository the repo holds too: submodules and nested clones it ignores. Check whether each one's remote is public; a secret there is ❌, rotated before it is scrubbed. Also look for sensitive file types ever committed (`.env`, keys, credentials). Report file and line, never the value. A match in a test fixture or in documentation about secrets is noise: say so once.

**When a repo wants it:** always, when it is under git.

**Make it yours:** name the scanner and how to run it over history; a pre-commit hook usually scans staged files only.

**Origin:** a pre-commit secret hook scanned nothing under `--all-files`, and a secret sat in a public clone the audit never looked at (2026-11-17).

### Sensitive and generated files are ignored

**Check.** Judge `.gitignore` against what this repo produces and holds; the checklist's baseline is a starting list. Done when nothing sensitive or generated sits tracked or unignored.

**When a repo wants it:** always, when it is under git.

### Agent permissions are no broader than needed

**Check.** Read the agent settings (`.claude/settings*.json` and their peers) for wildcard allows and unscoped shell or MCP grants. A broad grant the repo has accepted on record is listed as known, not raised again.

**When a repo wants it:** it has agent settings files.

**Make it yours:** say where an accepted grant is recorded.

### The supply chain is known

**Check.** Dependencies are audited and pinned, package registries are standard or deliberate, and submodules and MCP servers point at hosts the repo expects.

**When a repo wants it:** it has dependencies, submodules or MCP configs.

**Make it yours:** name the expected hosts.

---

## Garden checks

For knowledge gardens and other repos whose content is tended over time. Whole-repo runs only: a closeout covers the same ground for one session's files.

### Sensitive material stays in its tier

**Check.** Across the whole repo, nothing the repo's security policy keeps out of tracked files is tracked, and logs, decisions and commit messages name sensitive files without quoting them.

**When a repo wants it:** it has a security policy with sensitivity tiers.

**Make it yours:** point to the policy.

**Origin:** a garden's plan quoted the figures its own constraint existed to keep out of logs, found at audit (2026-08-13).

### Work records show where things stand

**Check.** The repo's work views (dashboard, roadmap, project index) carry no stale signal nobody has looked at: a spec marked active with no movement, a plan whose checkboxes stopped, a project untouched past its threshold. Report each with what would settle it; don't settle it.

**When a repo wants it:** it keeps specs, plans or a project index with staleness signals.

**Make it yours:** name the views and the thresholds the repo already uses.

### Knowledge is reviewed on its cadence

**Check.** Notes, topics or sources that carry a review date or cadence are within it, or reported with how far past.

**When a repo wants it:** it records review dates on knowledge, for example research topics or living notes.

**Make it yours:** name the field and the tool that reports it, if any.
