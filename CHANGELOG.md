# Changelog — agentic-scaffold

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

## 2026-04-08 — Added ROADMAP.md as default scaffolded file

Added ROADMAP.md as the 7th default file in the scaffold. The template uses a four-section format (Near-term, Future explorations, Parking lot, Decided) with lightweight status tracking (`active`, `idea`, `parked`, `decided`). Items flow from ROADMAP.md into DECISIONS.md when evaluated — creating an explicit pipeline from inspiration to architectural decision.

This fills a gap in the original scaffold: a place to capture future directions, inspiration sources, and potential features without overwhelming current work. Informed by GitHub's public roadmap patterns, Mozilla Science roadmapping, agile parking lot conventions, and YAGNI principles. See Decision 006.

## 2026-04-08 — Layered generation and README restructure

Two significant changes in one session. First, split file generation into **core** (5 files, always generated) and **adaptive** (tool-specific and team-specific, generated based on setup). This moves .cursorrules, .claude/settings.local.json, and CONTRIBUTING.md out of the default set — they're now offered based on whether you use Cursor, Claude Code, or work in a team. The /init skill detects tooling from existing files and only asks when it can't determine your setup. See Decision 007.

Second, completely restructured the README to serve as a standalone explainer. Each core file now has a dedicated narrative section that weaves in design sources and rationale — explaining not just what the file is, but why it exists and where the idea came from. The flat "Design Sources & Inspiration" bibliography was replaced by source attribution woven into each file's narrative, with a compact "Further Reading" link section at the bottom.
