# Changelog — agentic-scaffold-cowork

A narrative record of how this plugin evolves.

---

## 2026-04-08 — v0.1.0: Initial Release

Built the first version of the agentic scaffold plugin after a thorough brainstorming and design process. The plugin provides a single `/init` skill that scaffolds agentic best practices into any project folder.

**What it scaffolds:**
- README.md — human-facing project overview
- CLAUDE.md — agent instruction set with stack-specific conventions and design principles
- CHANGELOG.md — narrative change history
- DECISIONS.md — lightweight architectural decision records
- .cursorrules — Cursor IDE conventions
- .claude/settings.local.json — Claude Code project config
- CONTRIBUTING.md — offered for team projects

**Design philosophy:** The scaffold uses adaptive detection to infer project details from existing files and manifests, minimizing questions. It follows progressive disclosure — starting lean and growing with the project. Every template design choice traces to documented sources (Anthropic CLAUDE.md conventions, HumanLayer best practices, Nygard ADRs, and more). The plugin eats its own cooking — this repo is scaffolded with its own patterns.
