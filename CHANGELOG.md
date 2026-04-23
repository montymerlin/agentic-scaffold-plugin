# Changelog — agentic-scaffold

A narrative record of how this plugin evolves.

---

## 2026-04-23 — v0.6.0: repo-audit skill — scaffold health and security audit

Added `repo-audit` as the third skill in this plugin (`agentic-scaffold:repo-audit`). The skill audits a repo's scaffold health and security posture in two phases: Artifact Audit (checks scaffold files are present, version numbers consistent across manifests, CHANGELOG fresh, ROADMAP → DECISIONS integrity intact) followed by a Security Scan (secrets exposure, gitignore completeness, overly broad agent permissions, dependency CVEs, sensitive files in git history, dependency pinning, custom registry overrides, submodule URL drift, MCP server external URLs).

Mechanical zero-judgment fixes — version number mismatches across manifest files, missing standard `.gitignore` entries — are applied silently. Everything else surfaces as a punch list and waits for user confirmation. Security patterns live in `references/security-checklist.md` so they can grow independently. Supply chain live threat intelligence (OSV/NVD queries, breach report cross-referencing) is noted on the ROADMAP as the natural next evolution of the security scan phase. See Decision 013.

## 2026-04-22 — v0.5.0: AGENTS.md canon and cross-host scaffold output

Shifted the plugin and the scaffold it generates to a compatibility-layer model. `AGENTS.md` is now the canonical agent instruction file for both this repo and newly scaffolded repos, while `CLAUDE.md` becomes a thin wrapper for Claude-family hosts. This aligns the scaffold with the same cross-host pattern now used across montymerlinHQ: one source of truth, host-specific aliases only where needed.

The `/init` skill and templates were updated together so the generated output matches the repo's own conventions instead of lagging behind them. Added portable root resolution for internal references, Codex install/update scripts for global skill use, and updated docs and metadata to position the project as host-agnostic with Claude packaging compatibility. See Decision 012.

## 2026-04-21 — v0.4.1: Dual-distribution packaging

Added `marketplace.json` for Claude Code CLI installation via `claude plugins install`. Updated CLAUDE.md to position the plugin as a "Claude Agent SDK plugin" rather than "Cowork plugin (Claude Desktop)". Replaced the Plugin Packaging section with a Distribution section covering both Claude Code CLI and Cowork install paths. Added Installation section to README.md. See Decision 011.

---

## 2026-04-21 — v0.4.0: logchange skill migrated from git-plugin

Added `logchange` as the second skill in this plugin (`agentic-scaffold:logchange`). The skill was previously in `git-plugin` as `git:logchange`, but it maintains CHANGELOG.md — an artifact this plugin creates via `/init`. Moving it here co-locates the full lifecycle: init creates the file, logchange keeps it current. See Decision 010.

The skill works in both git repos (summarises from commit history since the last changelog entry) and non-git folders (asks the user to describe what's changed). A patch commit immediately followed to handle the edge case of a brand-new git repo with zero commits — the git-based workflow now detects this via `git rev-list --count HEAD` and routes to the manual flow rather than running `git log` on an empty history.

---

## 2026-04-21 — v0.3.0: Adaptive versioning conventions

Added versioning best practices as an adaptive feature of the scaffold. The `/init` skill now detects whether a project needs version tracking (by checking for plugin manifests, package.json version fields, git tags, release workflows) and, when it does, injects a `### Versioning` section into the generated CLAUDE.md with four rules: single source of truth, semver, git tags on release, and a pre-commit version check.

This was motivated by real version drift across six plugins — most notably mdpowers, which had plugin.json at v0.3.2, CHANGELOG at v0.4.2, and zero git tags. The conventions codified here are the ones that fixed it. Projects that don't track versions (knowledge gardens, research corpora, docs sites) skip the section entirely, following the existing core-vs-adaptive pattern. See Decision 009.

New reference file: `skills/init/references/versioning-conventions.md` — the pattern and rationale agents use when generating the versioning section, adapted to whatever manifest the project uses.

---

## 2026-04-15 — v0.2.0: Bundled design rationale for skill invariants

Added `skills/init/references/design-principles.md` and a one-line pointer at the top of SKILL.md. The new file bundles the six invariants the `/init` skill is supposed to uphold — the ~150-line CLAUDE.md budget from HumanLayer best practices, the write-before-implement timing discipline for DECISIONS.md, the template source-attribution footer convention, the ROADMAP → DECISIONS pipeline as a pattern we defined, the progressive-disclosure grounding of the core-vs-adaptive split, and the source map for defending generated defaults (Nygard, keep-a-changelog, GitHub README guidelines, Nielsen Norman, YAGNI, Anthropic Agent Skills).

The problem: Cowork loads SKILL.md when the skill is invoked, but doesn't auto-load the plugin's own CLAUDE.md, README.md, or DECISIONS.md. That meant `/init` would execute the workflow correctly but couldn't enforce the CLAUDE.md length budget, preserve template footers during edits, or defend its defaults with source citations when a user pushed back. The new reference file closes that gap without bloating the main skill body — progressive disclosure preserved, rationale reachable on demand. See Decision 008.

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
