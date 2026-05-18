# CLAUDE.md — agentic-scaffold

Before doing anything else in this repo, Read `AGENTS.md` in full. It is the canonical instruction set for this repo; this file is a thin Claude compatibility wrapper and assumes you have read `AGENTS.md` first.

In Claude Code (CLI), an `@AGENTS.md` directive will expand recursively. In Cowork (desktop), that expansion is not reliable, so the explicit imperative above is required — do not skip it.

## Compatibility notes

- Treat `AGENTS.md` as the source of truth
- Use `.claude-plugin/` as Claude-specific packaging metadata only
- Keep any Claude-only notes thin and local to this wrapper

Release-version source of truth for published Claude plugin builds remains `.claude-plugin/plugin.json`.
