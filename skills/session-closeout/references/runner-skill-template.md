---
name: closeout
description: Run this repo's session-closeout workflow. Use when the user types /closeout or says "close out", "wrap up", "session end", "end of session", "prepare commit", or "finish up". Resolves the nearest repo closeout workflow (ops/workflows/session-closeout.md) and follows it exactly.
---

# closeout — end-of-session reconcile + commit

A portable dispatcher. `/closeout` runs the end-of-session pass for *this* repo:
surface what the session left unfinished, reconcile the repo's logging surfaces,
and build the commit. The skill is repo-agnostic and voice-neutral — the actual
steps live in the repo's own **closeout workflow**, so the same `/closeout` does
the right thing in every repo, and works for collaborators who have no plugins
installed.

## What to do

1. **Find the workflow (nearest-wins).** From the current working directory, walk
   up parent directories to the first closeout workflow you find, checking these
   paths at each level in order: `ops/workflows/session-closeout.md`,
   `.agents/workflows/session-closeout.md`, `docs/workflows/session-closeout.md`,
   `session-closeout.md` at the level's root. The first hit is the closeout
   workflow for the active repo/spoke — so `/closeout` inside a nested spoke runs
   that spoke's own workflow when it has one, and the parent repo's when it
   doesn't.
2. **If found:** read it and **follow it exactly** — its steps, their order, and
   its gates. The file was tailored to this repo; it is the source of truth.
   Do not add steps it doesn't list and do not improvise a closeout of your own.
   Honour its ordering rule: reconcile the records first, commit last, so the
   commit captures the updates the closeout itself produced.
3. **If none exists up the tree:** don't error. Tell the user this repo has no
   closeout workflow yet, and offer to set one up. If the `agentic-scaffold`
   plugin is available, that means invoking `agentic-scaffold:session-closeout`,
   which detects this repo's logging surfaces and generates a workflow fitted to
   them. If it isn't available, offer to write a minimal one at
   `ops/workflows/session-closeout.md`: surface unfinished to-dos → reconcile
   whatever logging surfaces the repo has → build the commit.

Keep this skill thin. All repo-specific behaviour belongs in the workflow.
