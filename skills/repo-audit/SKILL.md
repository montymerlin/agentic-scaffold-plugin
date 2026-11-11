---
name: repo-audit
description: >
  Audit a repo's scaffold health and security posture. Use when the user asks to
  "audit", "check scaffold", "repo audit", "check repo health", "verify reasoning
  artifacts", "check changelog", "scaffold check", "audit repo", or wants to check
  that a repo's instructions, records, versions and cross-references agree and that
  nothing sensitive is exposed. A session closeout runs it after structural work.
metadata:
  created: "2026-04-23"
  updated: "2026-11-11"
  stage: "budding"
---

# repo-audit

Check that a repo's instructions, records and references agree with each other and with the repo, and that nothing sensitive is exposed. Each check states its objective and what done looks like. Commands, thresholds and pattern lists are dated suggestions: use what fits the repo.

The audit is read-only, apart from the dated record a whole-repo run leaves. It reports and proposes, and changes nothing else until the user says yes.

## Before you start

- **Read the repo's own rules.** Its root instructions, and the contracts they name for the files in scope, decide what good looks like. A convention this skill suggests never overrides one the repo chose on purpose. Where the repo records why something is the way it is, in a decision or a note, don't flag it.
- **Run the repo's own validators** and report what they say: pre-commit hooks, CI, `--check` scripts, a secret scanner. Don't re-check by hand what they already enforce; spend the audit on what they can't judge. If the repo has its own audit skill (often `<namespace>:repo-audit` under `.agents/skills/`), run it and report its findings in their own section.
- **Set the scope.** Run on its own, audit the whole repo: that is where drift no single session sees shows up. Called from a closeout or another workflow, audit only what the session changed and what that could break, and skip any check the caller's own steps already made, such as records, changelog, plans and decisions; say which you skipped. What the call adds is depth: cross-references, the instructions when the session changed them, and security when it touched settings, ignore rules or dependencies.

## Artifact audit

1. **The records exist for what the repo does.** A reader can find what the repo is, how to work in it, what changed (if it ships versions) and why structural choices were made (if it makes them), in whatever form the repo uses. One file per decision, a generated roadmap or no `DECISIONS.md` by design are all fine. Done when each missing record is one this repo needs, not one a template expects.

2. **Versions agree.** In a plugin or package, every manifest and file that names the version gives the same one, and the changelog's newest entry matches. A manifest ahead of the changelog means a missing entry, not a stale number. Done when they agree, or the mismatch is reported with the file that looks right.

3. **The changelog records what shipped.** Judge it against the repo's own changelog rules, not a commit count: a reader-facing changelog that cuts a version only when something ships is current after many commits. Where the repo has no rules, commits since the last entry are a hint, not a finding.

4. **Plans and decisions agree.** Whatever the roadmap or plans mark as decided has a decision record, and no live plan rests on a decision since superseded. Defer to the repo's index checker if it has one.

5. **Cross-references resolve.** Links, paths and names in scope point at something that exists and still says what the reference claims, in the form the repo's linking rules ask for, including anything the calling session wrote just before the audit. Whether a note links everything it should is curation, for the closeout or a gardening pass, not this check.

6. **The root instructions cover what an agent can't infer.** Read them as a new agent would. Done when they say what the repo is, what is safe and what needs asking first, where things go, which conventions differ from the obvious, and how to check work; and when they don't spend space on what the code, the folder names or a nested file already says. Judge the content, never the headings: a section removed on purpose is not a gap.

7. **The instructions fit the runtimes that read them.** If the repo sets its own budget or checks size, defer to it. Otherwise, as of 2026-11: Claude Code's memory docs advise staying under about 200 lines, and Codex reads only the first 32 KiB.

8. **Each rule lives in its narrowest home.** A folder instruction file adds rules that differ from root and bind every edit in that folder, and restates nothing from root; a root rule that binds one folder belongs in that folder. Judge by content, not shared headings. Suggest a new folder file only where such a rule exists, never because a folder has grown.

## Security scan

[`references/security-checklist.md`](references/security-checklist.md) holds pattern lists and a baseline, as suggestions.

9. **No secrets in tracked files or history.** Run the repo's secret scanner over the scope if it has one; otherwise grep the checklist's patterns. Also look for sensitive file types ever committed (`.env`, keys, credentials). Report file and line, never the value. A match in a test fixture or in documentation about secrets is noise: say so once.

10. **Sensitive and generated files are ignored.** Judge `.gitignore` against what this repo produces and holds; the checklist's baseline is a starting list. Done when nothing sensitive or generated sits tracked or unignored.

11. **Agent permissions are no broader than needed.** Read the agent settings (`.claude/settings*.json` and their peers) for wildcard allows and unscoped shell or MCP grants. A broad grant the repo has accepted on record is listed as known, not raised again.

12. **The supply chain is known.** Where the repo has them: dependencies are audited and pinned, package registries are standard or deliberate, and submodules and MCP servers point at hosts the repo expects.

## Report

One punch list per phase, plus one for the repo's own audit skill if it ran: ✅ fine, ⚠️ worth a look, ❌ needs fixing, ℹ️ known or accepted. Lead with what the validators said. Then ask which findings to fix now and which to leave, and apply only the fixes the user approves.

Called from a closeout, the audit writes nothing: the closeout's report covers it. Run across the whole repo, it leaves one short dated record of what it found and what was fixed or left, where the repo keeps dated audits or notes, named so it is easy to find (for example `YYYY-MM-DD_repo-audit.md`). The next run, or a reminder, reads it to see when the last audit was. If the repo has nowhere for it, say so rather than invent a place. Never append to a reader-facing changelog.
