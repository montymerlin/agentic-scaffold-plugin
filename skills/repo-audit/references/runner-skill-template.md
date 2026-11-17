---
name: repo-audit
description: Run this repo's audit workflow. Use when the user types /repo-audit or asks to "audit the repo", "check repo health", "run the repo audit", or when a closeout or check-up calls for an audit. Resolves the nearest repo audit workflow (ops/workflows/repo-audit.md) and follows it.
license: MIT. Complete terms in LICENSE.txt
---

# repo-audit — check that the repo still agrees with itself

A portable dispatcher. `/repo-audit` runs the audit for *this* repo: its records,
references, instructions and security. The checks live in the repo's own **audit
workflow**, so the same `/repo-audit` does the right thing in every repo, and works
for collaborators who have no plugins installed.

## What to do

1. **Find the workflow (nearest wins).** From the working directory, walk up to the
   first of `ops/workflows/repo-audit.md`, `.agents/workflows/repo-audit.md`,
   `docs/workflows/repo-audit.md` or `repo-audit.md` at a level's root.
2. **If found:** read it and follow it: its scope rule, its checks, its report and
   its record. It was written for this repo and is the source of truth. Don't add
   checks it doesn't list.
3. **If none exists up the tree:** say so. If the `agentic-scaffold` plugin is
   available, its `repo-audit` skill can audit against its library and set up a
   workflow for this repo. If not, offer a short audit by hand: run the repo's own
   validators, check that the files a session changed still agree with what refers
   to them, and look for secrets in what is tracked.

Keep this skill thin. All repo-specific behaviour belongs in the workflow.
