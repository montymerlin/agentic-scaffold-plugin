# Changelog — agentic-scaffold

A narrative record of how this plugin evolves.

---

## 2026-10-26 — v0.9.1: the licence travels with the code

The plugin always declared MIT in its manifest and README, but shipped no licence text, and MIT's one condition is that its notice goes with every copy. The repo now has a `LICENSE` file (Copyright (c) 2026 Monty Bryant).

The vendored `closeout` runner is the part that actually gets copied into other repos, so it now carries the notice too. The runner template gains a `license:` line, and `session-closeout` vendors `references/runner-LICENSE.txt` beside it as `closeout/LICENSE.txt`. The Step 6 staleness check reports a vendored runner that lacks it. Existing vendored runners pick up both through the usual drift offer.

---

## 2026-08-07 — v0.9.0: session-closeout splits into a generator and a vendored runner

`session-closeout` was dual-mode: it generated a repo's `session-closeout.md` and also ran it. That shape only served a single operator with the plugin installed. `bridging-worlds` exposed the gap — a tracked, mature closeout workflow, a GitHub remote with collaborators, and no way for any of them to invoke it. The workflow had always been plugin-independent; the trigger never was.

The deciding argument was subtler than distribution. With run-mode in the plugin, every closeout the maintainer runs goes through the plugin path, so any repo-local path stays permanently unexercised — the collaborator path breaks invisibly. Splitting the concern makes one path the only path.

The skill is now **setup-only**. It detects the repo's logging surfaces, generates or refreshes the tailored workflow, vendors a thin `closeout` runner skill into the repo, and runs staleness checks against both artefacts. It no longer runs closeouts, and its description is narrowed to setup triggers so it stops competing for "close out" / "wrap up".

The runner is new: `skills/session-closeout/references/runner-skill-template.md`, copied verbatim to `.agents/skills/closeout/SKILL.md` in the target repo, with a `.claude/skills` compatibility symlink where Claude Code needs one. It carries no procedure of its own — nearest-wins walk-up to the closest workflow, then follow it exactly. That walk-up is a real gain over the old flat four-path lookup: `/closeout` inside a nested spoke now runs the spoke's workflow and falls back to the parent's. The shape is lifted from the `gm` skill in montymerlinHQ, which had already proven it in the same repos.

Step 5b checks `git check-ignore` on the runner and the symlink before declaring success, since vendoring that isn't committed is inert. A repo that already has a workflow but no runner gets a runner-only vendor — the existing workflow is never regenerated without an explicit ask, because it may be hand-written or hand-edited. See Decision 016.

---

## 2026-07-19 — app-changelogs closeout block

Added an `app-changelogs` block to the session-closeout block library, contributed from montymerlinHQ the same day its App logging layer landed (per-app `CHANGELOG.md`/`ROADMAP.md` under `apps/`, versions mirrored in a registry and rendered in the repo's own UI). Without it, a closeout in a repo with an app layer checks every root surface, finds app-internal work correctly absent from all of them, and closes clean while the app's changelog silently drifts. The block asks the seam question — "did the session touch an app, and is this a seam?" — then prompts the version cut, the registry mirror, and the roadmap retirement. Detection: per-app CHANGELOG/ROADMAP files inside an `apps/`-style directory plus a registry carrying version fields; bridging-worlds' `app/` layer matches the same shape.

---

## 2026-07-19 — local-indexes closeout block

Added a `local-indexes` block to the session-closeout skill's block library, prompted by a real miss-class in montymerlinHQ: a session that builds something new under a directory whose README enumerates its contents (a registry table, an MOC, an inventory) had no closeout step nudging that index back into sync — hand-maintained indexes fell between the consistency step (cross-references) and the generated-files step (auto-generated only). The block derives the session's touched directories from the git delta, checks each (and its parent) for files that *claim to list things the session changed*, and adds a one-line glance at memory-index and daily-log surfaces where the repo keeps them. Wired into the scaffold assembly order between generated-files and git; omitted when a repo has no such files.

---

## 2026-07-17 — Codex installer discovery and repair

Repaired the Codex installer after the plugin's skill inventory outgrew its original two-entry link list. The installer now discovers every immediate `skills/<name>/` directory containing `SKILL.md`, installs the resulting namespaced links in stable order, rejects empty or invalid source roots, and continues to replace valid or broken targets only when `--force` is supplied.

Added a zero-dependency Bash integration test covering clean five-skill installation, overwrite refusal, broken-link repair, and invalid-source failure. Host documentation now carries the full five-skill inventory and distinguishes Claude/Cowork slash commands such as `/session-closeout` from Codex's `$session-closeout` skill mention. This is a maintenance repair on top of v0.8.0; native `.codex-plugin/` packaging and global skill-root migration remain separate work, now captured in the ROADMAP rather than left implicit.

---

## 2026-05-20 — v0.8.0: session-closeout skill — the end-of-session orchestrator

Added `session-closeout` as the plugin's fifth skill and capstone. Where `init` and `nest` scaffold a repo's structure and `logchange` and `repo-audit` maintain it, `session-closeout` ties them together at the moment a work session ends.

The skill is dual-mode. On first use it **scaffolds** a `session-closeout.md` workflow into the target repo — a standing, editable, plugin-independent procedure. On later use it **runs** that workflow: surface unfinished to-dos (address / drop / defer to a handoff file), reconcile whatever logging surfaces the repo has, and — only if the repo is under git — inspect the session delta and build the commit.

It is adaptive and an orchestrator. A detection pass (reusing `init` / `repo-audit` detection) determines which logging surfaces the repo actually has; the generated workflow contains only the relevant steps — a bare non-git folder gets a three-step closeout, a mature multi-skill repo gets the full pass. The changelog step delegates to `logchange`, the consistency step to `repo-audit`; both degrade to inline reminders where the sibling skill is absent. Git is a first-class conditional — the commit step is omitted entirely when the folder isn't a git repo. The modular step-block library lives in `references/closeout-blocks.md`. See Decision 015.

---

## 2026-05-18 — v0.7.0: Three-layer instruction pattern as the core mental model

Adopted the three-layer instruction pattern (root rules → folder-level `AGENTS.md` → templates as exemplars) as the plugin's core mental model. The plugin previously modelled only the root layer; every scaffold it generated was flat. This release brings the plugin into alignment with what Anthropic's Claude Code memory docs, OpenAI's Codex AGENTS.md guide, and the cross-host [agents.md spec](https://agents.md/) (used by 60,000+ open-source projects) all document as best practice. GitHub's analysis of 2,500 real `AGENTS.md` files informed the templates-as-exemplars piece — *"language models are pattern-followers more than rule-followers"* is the clearest articulation of why concrete templates beat abstract rule lists.

Decision 014 authorizes the full coordinated change. Seven concrete pieces shipped together:

- **New principle in `design-principles.md`** — *"Rules live at the narrowest scope where they apply"* — Principle 7, sourced from the four primary references above.
- **`templates/AGENTS.md.tmpl` updated** — Design Principles section now teaches the layered model; footer cites the three-layer pattern. Fixed stale `v0.5.0` version reference (caught by Decision 013's audit logic).
- **`skills/init/SKILL.md` updated** — Frames the generated scaffold as the *root* of an optionally layered structure. Step 7 now suggests `nest` when content folders are detected.
- **New `nest` skill** (`skills/nest/SKILL.md`) — Scaffolds folder-level `AGENTS.md` plus a `TEMPLATE.md` exemplar inside a specified subdirectory. Reads root `AGENTS.md` before generating so the folder file specializes rather than duplicates. Surfaces the Claude Code lazy-load vs Codex eager-load distinction in every file it produces.
- **Two new templates** — `templates/folder-AGENTS.md.tmpl` (folder-scoped instructions) and `templates/TEMPLATE.md.tmpl` (the exemplar shape, generic enough to flex across folder kinds).
- **`repo-audit` extended** with three new Artifact Audit checks: 2f (root AGENTS.md length — flag >200 lines, info >150), 2g (nested instruction-file discovery), 2h (root↔folder duplication detection by shared heading), 2i (content folders without AGENTS.md — soft suggestion). The audit now measures the layered pattern, not just root-file presence.
- **`.claude/rules/example.md` as a new adaptive scaffolding option** — Claude-Code-specific complement to nested `AGENTS.md`, generated when Claude Code is detected and the repo would benefit from path-scoped rules. New template at `templates/claude-rules-example.md.tmpl`.

Knock-on consequences logged in ROADMAP: **Monorepo support** moved from `idea` to `active` — the blocker was the missing folder-level scaffolding primitive, which `nest` now provides. A monorepo is now just a repo with intentional nested `AGENTS.md` at each workspace, and `nest` composes into that workflow.

README's "The Layered Pattern" section and SETUP's opening line teach the new model to users. The plugin now does what it teaches.

---

## 2026-04-27 — Plugin audit pass + skill name fix + version drift

Audited the plugin against `/create-cowork-plugin` standards. Fixed the namespaced skill `name:` frontmatter bug — all 3 SKILL.md files had `name: agentic-scaffold:<skill>` which caused doubled runtime IDs at install time. Fixed to bare dir names: `init`, `logchange`, `repo-audit`.

Also fixed AGENTS.md version drift (said 0.5.0, plugin.json was already at 0.6.0); updated the Canonical Structure tree to include `repo-audit/` skill (added in v0.6.0), `SETUP.md`, and `.gitignore`. Added `.gitignore`. Added `SETUP.md` § "Quick Install (for AI agents)" decision tree and a 3-option Cowork packaging pattern. Restructured the Claude Code CLI section as global-vs-local with explicit user question. Flagged: `.claude/settings.local.json` line 6 still says "Read CLAUDE.md" but AGENTS.md is canonical — needs manual update (path-protected from session).

## 2026-04-27 — Cowork packaging: SETUP.md as setup canon

Added `SETUP.md` as the single source of truth for install pathways and host compatibility. `README.md`'s installation section was trimmed to a brief pointer at SETUP.md. The plugin is now packaged as `agentic-scaffold-0.6.0.plugin` in the workspace's `ops/plugins/_dist/` directory using the new `cowork-plugin-packager` skill at `.agents/skills/cowork-plugin-packager/`. No skill or behavior changes — packaging-and-docs only.

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
