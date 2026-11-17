---
name: repo-audit
description: >
  Audit a repo's scaffold health and security posture, or set up the repo's own audit
  workflow. Use when the user asks to "audit", "check scaffold", "repo audit", "check repo
  health", "verify reasoning artifacts", "check changelog", "scaffold check", "audit repo",
  "set up repo audit", or wants to check that a repo's instructions, records, versions and
  cross-references agree and that nothing sensitive is exposed. A session closeout runs it
  after structural work.
metadata:
  created: "2026-04-23"
  updated: "2026-11-17"
  stage: "budding"
---

# repo-audit

Checks that a repo's instructions, records and references agree with each other and with the repo, and that nothing sensitive is exposed. Like `session-closeout`, it works from a **library of checks** that a repo adopts and adapts into **its own audit workflow**, so the audit carries the repo's validators, records and lessons, and runs for collaborators who don't have this plugin.

Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. The library is `${AGENTIC_SCAFFOLD_ROOT}/skills/repo-audit/references/audit-library.md`; the runner this skill vendors is `references/runner-skill-template.md`.

## Run an audit

1. **Find the repo's audit workflow (nearest wins).** Walk up from the working directory to the first of `ops/workflows/repo-audit.md`, `.agents/workflows/repo-audit.md`, `docs/workflows/repo-audit.md` or `repo-audit.md` at a level's root.
2. **If there is one, follow it.** It is the repo's own: its checks, its validators, its record. Don't add checks it doesn't list, except the library's *Check this file first*, which every run makes. If the library holds a check the workflow lacks and the repo plainly wants it, mention it after the report as a suggestion.
3. **If there is none, audit against the library as it stands:** its *Before you start*, *Report* and *Record* sections, and every check whose *When a repo wants it* this repo meets. After the report, offer once to set up the repo's own workflow.

The audit reports and proposes, and changes nothing until the user says yes, apart from its own dated record on a whole-repo run.

## Set up a repo's audit

Use when the user asks to set up, adopt or refresh the audit for a repo, or accepts the offer above. It produces two files: the repo's **audit workflow** and a vendored **`repo-audit` runner skill**.

1. **Find what the repo has.** Read its root instructions, then look for what they don't mention: its validators (pre-commit, CI, `--check` scripts, a secret scanner), its records and their form, where it keeps dated audits or notes, its security policy, its linking rules, agent settings, dependencies and submodules. Done when you can say, for each library entry, whether the repo meets its *When a repo wants it* and which file owns the detail.
2. **Draft the workflow.** Take the library's frame and the checks the repo wants, in the library's order, and write each in the repo's terms, following *How to write a check*. Where a validator already enforces a check, the check becomes "run it and report". Add the repo's own checks where it has lessons the library doesn't know.
3. **Show it and wait.** Show what you found, which checks the workflow holds and why, the drafted text, and where the files will go. **Don't write until the user approves the text.**
4. **Write it.** Put the workflow beside the repo's other workflows, by default `ops/workflows/repo-audit.md`. Start its history in `changelogs/repo-audit.md` beside it, with a `v1.0` entry naming the checks chosen and any origin worth keeping.
5. **Vendor the runner.** Copy `references/runner-skill-template.md` verbatim to the repo's skills directory as `repo-audit/SKILL.md`, with `session-closeout`'s `references/runner-LICENSE.txt` beside it as `LICENSE.txt`. Choose and link the skills directory as `session-closeout`'s SKILL.md Step 5b describes, and tell the user the runner needs committing for collaborators to get it.

**Refreshing an existing workflow:** compare it with the library and the repo as it is now. Propose changes one check at a time, in the workflow's own voice, with a changelog entry. Never regenerate the file: it is the repo's own, and its wording carries lessons the library doesn't know. Check the vendored runner against the template too, and show any diff before refreshing it.

## Edge cases

- **Not a git repo:** the checks that need git drop out; the rest still apply.
- **No validators:** every check is judged by hand, and the report says so.
- **A repo can't commit a skills directory:** skip the runner. The workflow is then followed by asking for it, or through this plugin.
- **An older companion skill** (`<namespace>:repo-audit` under `.agents/skills/`): run it alongside the workflow or the library, and offer to fold its checks into the repo's workflow.
