# Decisions — agentic-scaffold

Architectural decisions for this plugin, in lightweight ADR format.

---

## Decision 016: Split session-closeout into a plugin generator and a vendored runner

**Status:** Accepted
**Date:** 2026-08-07

**Context:** Decision 015 made `session-closeout` dual-mode: it both generated a repo's `session-closeout.md` and ran it. That worked for a single operator with the plugin installed, and failed for everyone else. Two problems surfaced in practice.

The first is distribution. `bridging-worlds` has a tracked, mature `ops/workflows/session-closeout.md` and a GitHub remote with collaborators — but no way for any of them to invoke it. The workflow was plugin-independent as designed; the *trigger* was not. A collaborator could read the file and had no `/closeout`.

The second, and the deciding one, is testing drift. With run-mode in the plugin, the operator's every closeout goes through the plugin path. Any repo-local path — the one collaborators would depend on — stays permanently unexercised, so its breakage is invisible until someone else hits it.

The `gm` skill in montymerlinHQ had already solved the shape: a ~30-line repo-agnostic dispatcher that walks up to the nearest `ops/workflows/gm.md` and follows it, vendored and tracked in both HQ and `bridging-worlds`. The pattern was proven in the exact repo that needed it; it simply hadn't been applied to closeout.

**Decision:** Split the concern across two scopes.

- **`agentic-scaffold:session-closeout` becomes setup-only.** It detects the repo's logging surfaces, generates or refreshes the tailored `session-closeout.md`, vendors the runner, and performs staleness checks. Run-mode is removed; its description is narrowed to setup triggers so it no longer competes for "close out" / "wrap up".
- **A thin `closeout` runner skill is vendored into the target repo** — shipped as `skills/session-closeout/references/runner-skill-template.md`, copied verbatim to `.agents/skills/closeout/SKILL.md` (with a `.claude/skills` compatibility symlink where Claude Code needs one). It holds no procedure: nearest-wins walk-up to the workflow, then follow it exactly.

Vendoring targets `.agents/skills/` first, per the canonical-skills-directory convention. Step 5b checks `git check-ignore` on both the runner and the symlink, because vendoring that isn't committed is inert.

**Consequences:**
- Every closeout — the maintainer's and a collaborator's — runs the same code path. Drift between them becomes impossible rather than merely unlikely.
- `/closeout` works from a clone with no plugins installed. The plugin becomes a setup-time dependency, not a runtime one.
- Nearest-wins resolution now matters and is explicit: `/closeout` inside a nested spoke runs the spoke's workflow, falling back to the parent's. Decision 015's flat "check four paths in the target repo" did not handle nesting.
- The plugin's identity gets cleaner. `agentic-scaffold` scaffolds and inspects; *running* a repo's own workflow is a repo concern. This is Principle 7 (rules at the narrowest scope) applied to the plugin's own skills.
- A behavioural contract is removed from a skill, so this is a minor bump: v0.8.0 → v0.9.0. Repos that had a workflow but no runner are handled by a runner-only vendor path — the existing workflow is never regenerated without an explicit ask, since it may be hand-written or hand-edited.
- Codex is unaffected in the invocation sense: it installs skills globally rather than from repo-local directories, so the vendored runner benefits Claude Code and Cowork users, and Codex users continue to reach the workflow by natural language.

**Alternatives Considered:**
- *Keep run-mode in the plugin alongside the vendored runner* — the plugin would still work in repos where nothing was vendored, but it reintroduces the trigger collision and, more seriously, leaves the collaborator path untested. Rejected on the drift argument.
- *Thin the plugin skill down to `gm`'s exact shape (template-copy only)* — `gm`'s scaffold path copies a static template, which is cheap to inline. Closeout's generator detects surfaces and assembles modular blocks; that adaptivity (Decision 015) is the plugin's actual value and would be lost.
- *Vendor nothing; tell collaborators to install the plugin* — pushes a toolchain requirement onto contributors to a knowledge repo, for a workflow that is already fully described by a file in that repo.

<!-- Supersedes the dual-mode half of Decision 015; the generator, adaptivity, and orchestrator properties established there are unchanged. -->
<!-- Applies Decision 014's Principle 7 (rules at the narrowest scope) to the plugin's own skill boundaries. -->

---

## Decision 015: Add session-closeout skill — the end-of-session orchestrator

**Status:** Accepted — amended by Decision 016 (dual-mode split into generator + vendored runner)
**Date:** 2026-05-20

**Context:** The plugin scaffolds a repo's structure (`init`, `nest`) and maintains it (`logchange`, `repo-audit`), but nothing ties those skills together at the moment a work session ends — when unfinished to-dos, unlogged decisions, an un-updated changelog, and an unbuilt commit all need reconciling at once. A per-commit hook reminder (the pattern some repos use) fires at the wrong granularity and can only remind, never act. The need is a coherent, on-demand end-of-session pass.

**Decision:** Add `session-closeout` as the plugin's fifth skill — its capstone. It is **dual-mode**: it *scaffolds* a repo-tailored `session-closeout.md` workflow into the target repo, and *runs* that workflow to close out a session. It is an **orchestrator** — the changelog step delegates to `logchange`, the consistency step to `repo-audit`, and the skill reconciles the remaining logging surfaces itself. It is **highly adaptive**: a detection pass (reusing `init` / `repo-audit` detection) determines which logging surfaces the target repo actually has, and the generated workflow contains only the relevant steps. **Git is a first-class conditional** — an agentically-scaffolded folder need not be a git repo, so the session-delta and commit steps are omitted entirely when git is absent. The skill ships a modular step-block library at `references/closeout-blocks.md` that the generator assembles from, and includes a staleness check that offers to re-scaffold when a repo gains surfaces its existing closeout doesn't cover.

**Consequences:**
- The plugin now covers the full session lifecycle: scaffold (`init` / `nest`) → maintain (`logchange` / `repo-audit`) → close out (`session-closeout`).
- The generated `session-closeout.md` is plugin-independent — it works as a standing workflow file even where the plugin isn't installed, and the user can edit it.
- `session-closeout`'s value scales with how much of the plugin a repo uses, and degrades gracefully (inline reminders) where sibling skills are absent.
- A new skill is a minor version bump: v0.7.0 → v0.8.0.
- The generated workflow can *recommend* a version bump but never performs one — version-bump remains a separate, heavier process, not yet built as its own skill.

**Alternatives Considered:**
- *A per-commit hook reminder* — fires on every commit (wrong granularity), can only print, cannot reconcile or commit. `session-closeout` supersedes this pattern for repos that adopt it.
- *The skill runs the closeout directly, without scaffolding a file* — loses per-repo tailoring persistence, user-editability, and plugin-independence. Scaffolding a tailored artifact matches the plugin's identity.
- *A single fixed closeout template* — fails the adaptivity requirement; a bare non-git folder and a mature multi-skill repo need very different closeouts.

<!-- Sources: runbook/playbook pattern for AI agents (briantakita.me, runplaybooks.ai); Anthropic Agent Skills + agents.md convention landscape. -->
<!-- Builds on Decision 014 (three-layer pattern) and the init/repo-audit detection. -->

---

## Decision 014: Adopt the three-layer instruction pattern as the plugin's core mental model

**Status:** Accepted
**Date:** 2026-05-18

**Context:** Current best practice across agent-coding platforms converges on a three-layer instruction pattern: root rules (project-wide), folder-scoped rules (specialization for "when working in here"), and templates as exemplars (concrete shapes agents copy and imitate rather than reconstruct from rules). Anthropic's Claude Code memory docs document nested `CLAUDE.md` discovery with lazy-loading; OpenAI's Codex AGENTS.md guide documents the same nesting pattern with eager loading from project root down to cwd; the cross-host agents.md spec stewarded by the Linux Foundation's Agentic AI Foundation is used by 60,000+ open-source projects; GitHub's analysis of 2,500 real `AGENTS.md` files found that concrete templates and decision tables drive adherence more than abstract rule lists, summarised as *"language models are pattern-followers more than rule-followers."*

The plugin currently models layer one only. Every scaffold it generates is flat. This was acceptable when the ecosystem was younger, but it now lags the documented best practice from both major hosts and from the open spec. The "Monorepo support" item in the ROADMAP has been blocked at `idea` precisely because the folder-level scaffolding primitive doesn't exist yet.

**Decision:** Adopt the three-layer pattern as the plugin's core mental model. This single decision authorizes the following coordinated changes (each can be implemented independently but they share this rationale):

1. **New principle in `references/design-principles.md`** — *"Rules live at the narrowest scope where they apply"* — with the four primary sources cited.
2. **Updated `templates/AGENTS.md.tmpl`** — Design Principles section acknowledges the layered model; footer cites the three-layer pattern.
3. **Updated `skills/init/SKILL.md`** — frames the generated scaffold as the *root* of an optionally layered structure, with the new `nest` skill as the path to deeper layers.
4. **New `nest` skill** at `skills/nest/SKILL.md` — scaffolds folder-level `AGENTS.md` + `TEMPLATE.md` pairs for a specified subdirectory.
5. **New templates**: `templates/folder-AGENTS.md.tmpl` (folder-scoped instructions stub) and `templates/TEMPLATE.md.tmpl` (the exemplar shape).
6. **Extended `repo-audit`** — three new checks: root AGENTS.md length (>200 lines flags bloat), content folders without AGENTS.md (suggestion only), duplication between root and folder AGENTS.md (rule restatement flag).
7. **`.claude/rules/` as a new adaptive scaffolding option** — Claude-Code-specific complement to nested AGENTS.md, generated only when Claude Code is detected and the repo would benefit from path-scoped rules.

**Consequences:**
- The plugin's mental model shifts from "flat scaffold" to "layered scaffold whose root is what we generate by default." Users opt into deeper layers when needed; nothing forced.
- "Monorepo support" (ROADMAP `idea`) becomes tractable. A monorepo is now just a repo with intentional nested AGENTS.md at each workspace, and the `nest` skill is the primitive that composes into monorepo workflows.
- The audit skill begins measuring the *pattern* — root file bloat, duplication across layers, folders that have grown enough to deserve their own rules — rather than only file presence.
- Two non-obvious caveats need to flow into generated documentation: Claude Code lazy-loads nested files (they enter context only when the agent reads a file inside the folder); Codex loads them eagerly from root down to cwd. Both behaviours are documented and valid; users should know which they're working with.
- For rules that must fire regardless of which folder the agent is in, `.claude/rules/*.md` with `paths:` frontmatter is the Claude-specific complement to nested AGENTS.md. The plugin documents both but defaults to the cross-host nested-AGENTS.md mechanism.
- All changes ship together as a single minor version bump (v0.7.0). They're coupled by this decision and consumed together.

**Alternatives Considered:**
- *Keep the scaffold flat* — increasingly inconsistent with what Anthropic, OpenAI, and the agents.md spec all document as best practice. Misses the leverage the new primitives provide; leaves monorepo support blocked indefinitely.
- *Make `.claude/rules/` the primary mechanism instead of nested AGENTS.md* — Claude-specific. Loses cross-host portability. Better as a complement to the nested-AGENTS.md pattern than a replacement for it.
- *Build full monorepo support directly rather than via `nest`* — premature; `nest` is the right primitive to compose monorepo support on top of. Defer the monorepo work to a follow-up release that builds on this one.
- *Scaffold the deeper layers automatically during `/init`* — violates progressive disclosure (Decision 003). Most projects don't need folder-level rules on day one; forcing them in introduces structure users haven't earned the need for. Better to provide `nest` as an opt-in tool users invoke when the project has grown enough to warrant it.

<!-- Sources: code.claude.com/docs/en/memory · developers.openai.com/codex/guides/agents-md · agents.md · github.blog (2,500-repo analysis) -->
<!-- Source-grounded defaults principle: Decision 008 -->

---

## Decision 013: Add repo-audit skill — scaffold health and security audit (2026-04-23)

**Status:** Accepted
**Date:** 2026-04-23

**Context:** The `agentic-scaffold:init` skill creates scaffold files. There was no corresponding skill to *check* those files stay fresh and consistent after a repo evolves — no way to catch a stale CHANGELOG, a version number drift across manifests, or a ROADMAP item marked `decided` without a matching Decision entry. A gap also existed on the security side: no lightweight agent-runnable scan for secrets, overly broad permissions, or supply chain risks.

**Decision:** Add `agentic-scaffold:repo-audit` as the third skill in this plugin. Two-phase design: Artifact Audit (scaffold freshness and consistency) then Security Scan (secrets, permissions, supply chain). Security patterns live in `references/security-checklist.md` so they can grow independently without modifying the skill logic. Mechanical zero-judgment fixes (version number mismatches, missing standard `.gitignore` entries) are applied silently; everything else surfaces as a punch list with proposed actions.

**Consequences:**
- Plugin now covers the full scaffold lifecycle: init → logchange → repo-audit
- `finishing-a-development-branch` (superpowers) gains a documented optional integration point
- Security checklist is independently expandable as new patterns emerge
- Live threat intelligence (querying OSV/NVD, cross-referencing breach reports) is noted on the ROADMAP as the natural v2 evolution

**Alternatives Considered:**
- Encode the audit inside `finishing-a-development-branch` only — catches it at the right moment but doesn't support on-demand use or cross-repo health checks
- Separate `security-audit` skill — cleaner boundaries but adds a skill slot and splits a natural two-phase workflow that users invoke together

---

## Decision 001: Standalone plugin (not integrated into superpowers-cowork)

**Status:** Accepted
**Date:** 2026-04-08

**Context:** The agentic scaffold concept could live as a skill within the existing superpowers-cowork plugin, as a standalone plugin, or as a CLI tool. Superpowers-cowork focuses on workflow discipline (brainstorming, planning, verification). Scaffolding is a different concern — project initialization and structure.

**Decision:** Build as a standalone Cowork plugin with its own repo and release cycle.

**Consequences:**
- Independent versioning and evolution
- Can be installed without superpowers-cowork
- Smaller, focused scope — easier to maintain and reason about
- Must be packaged and distributed separately

**Alternatives Considered:**
- Skill within superpowers-cowork — conflates workflow discipline with project setup
- CLI tool — loses Cowork integration and plugin distribution model

---

## Decision 002: Smart defaults + edit interaction model

**Status:** Accepted
**Date:** 2026-04-08

**Context:** Three interaction models were considered: (A) wizard with many questions, (B) opinionated with no configuration, (C) smart defaults with ability to edit. The goal is fast scaffolding without sacrificing relevance.

**Decision:** Adaptive detection (infer from environment) combined with confirmation rather than interrogation. Generate files, present for approval, let user edit after creation.

**Consequences:**
- Detection logic must be robust across multiple stacks and project types
- Templates must produce good output even with minimal customization
- User always sees what will be created before anything is written
- Zero questions for mature repos, up to three for blank directories

**Alternatives Considered:**
- Full wizard — too many questions, slow for experienced users
- Zero config — too opinionated, poor fit for diverse project types

---

## Decision 003: Progressive disclosure as architectural principle

**Status:** Accepted
**Date:** 2026-04-08

**Context:** The scaffold could generate many files covering every possible need, or start minimal and grow. Front-loading structure that isn't yet needed creates noise and maintenance burden.

**Decision:** v0.1.0 ships 6 default files + 1 offered (CONTRIBUTING.md for teams). Future versions add specialized layers (monorepo support, API project patterns, knowledge garden scaffolds) as progressive enhancements.

**Consequences:**
- Initial scaffold is lean and fast
- Plugin has clear evolution path through layers
- Users aren't overwhelmed on first use
- More complex project types must wait for future versions

---

## Decision 004: Dual-audience documentation

**Status:** Accepted
**Date:** 2026-04-08

**Context:** Many projects use README.md for everything — human docs and agent instructions in one file. This conflates two audiences with different needs. Humans want overview, setup, and usage. Agents want conventions, boundaries, and structural maps.

**Decision:** Every scaffolded project gets both README.md (human-facing) and CLAUDE.md (agent-facing) as distinct files with distinct purposes.

**Consequences:**
- Slight file count increase, but each file is more focused
- Agents get clear instructions without parsing human-oriented docs
- Humans get clean documentation without agent-specific jargon
- Both files must be maintained, but neither needs to serve two masters

---

## Decision 005: Zero runtime dependencies

**Status:** Accepted
**Date:** 2026-04-08

**Context:** The plugin could use a templating engine (Handlebars, Jinja, etc.) for more powerful interpolation, or keep templates as plain text with simple `{{variable}}` replacement.

**Decision:** No runtime dependencies. Templates use simple `{{variable}}` string replacement, handled by the agent executing the SKILL.md instructions.

**Consequences:**
- Instant setup — no install step, no lazy dependency loading
- Templates are readable as-is (no special syntax beyond `{{variables}}`)
- Limited to string interpolation (no conditionals, loops in templates)
- Conditional logic (e.g., solo vs team) lives in SKILL.md, not in templates

---

## Decision 006: ROADMAP.md as default scaffolded file

**Status:** Accepted
**Date:** 2026-04-08

**Context:** The original scaffold (6 default files) had no place to capture future directions, inspiration, or ideas that aren't ready for implementation. These ideas were either lost (forgotten between sessions), buried in conversation history, or awkwardly shoehorned into DECISIONS.md (which is for evaluated choices, not unevaluated possibilities). The principle of "implement what's needed now, document what might be needed later" needed a home.

**Decision:** Added ROADMAP.md as a 7th default scaffolded file. Four sections (Near-term, Future explorations, Parking lot, Decided) with four statuses (active, idea, parked, decided). The "Decided" section creates an explicit pipeline to DECISIONS.md — items don't disappear, they get a pointer to where the reasoning lives.

**Consequences:**
- Every scaffolded project now has a place for future thinking from day one
- The ROADMAP → DECISIONS pipeline is a novel pattern (not yet established as convention elsewhere) — we're defining it
- 7 default files instead of 6, but ROADMAP.md is lightweight and doesn't add cognitive overhead
- Parking lot section prevents good ideas from being lost without creating pressure to act on them

**Alternatives Considered:**
- PLAN.md — implies current execution, not future aspirations
- TODO.md — too granular, too tactical
- Keep it in README.md — conflates project documentation with aspirational planning
- No file (use GitHub Issues instead) — loses portability and agent-readability

---

## Decision 007: Layered file generation (core vs adaptive)

**Status:** Accepted
**Date:** 2026-04-08

**Context:** The scaffold originally generated all files as defaults — including .cursorrules and .claude/settings.local.json. But these are tool-specific: a user who doesn't use Cursor gets a .cursorrules file they don't need, and a user who doesn't use Claude Code gets a .claude/settings.local.json that serves no purpose. Similarly, CONTRIBUTING.md is team-specific and adds noise for solo projects. Generating unnecessary files contradicts the progressive disclosure principle.

**Decision:** Split file generation into two layers. **Core files** (README.md, CLAUDE.md, CHANGELOG.md, DECISIONS.md, ROADMAP.md) are always generated — these are universally valuable regardless of tooling. **Adaptive files** (.cursorrules, .claude/settings.local.json, CONTRIBUTING.md) are generated based on detected or stated tooling and team setup. The /init skill detects existing tool configurations and only asks about tooling when detection is inconclusive.

**Consequences:**
- Cleaner scaffold for users who don't use Cursor or Claude Code
- 5 core files + 0-3 adaptive files instead of a flat 7
- Requires tooling detection logic and an additional question in the /init flow
- Better alignment with progressive disclosure — don't generate what isn't needed
- README restructured to explain the distinction between core and adaptive files

**Alternatives Considered:**
- Keep all files as defaults — contradicts progressive disclosure for tool-specific files
- Make everything optional — too many questions, undermines smart defaults for core files
- Detect only, never ask — misses cases where user plans to adopt a tool but hasn't configured it yet

---

## Decision 008: Bundle design rationale as an on-demand reference

**Status:** Accepted
**Date:** 2026-04-15

**Context:** The `/init` skill executes a workflow (what to do) but the rationale for its invariants — the ~150-line CLAUDE.md budget from HumanLayer best practices, the write-before-implement timing for DECISIONS.md, the template source-attribution footer convention, the ROADMAP → DECISIONS pipeline as an emerging pattern we defined, and the grounding of core vs adaptive split in progressive disclosure — lived only in CLAUDE.md, README.md, and DECISIONS.md. Cowork doesn't auto-load those files when a user invokes the skill, so the skill would execute correctly but couldn't defend its own choices, enforce the CLAUDE.md length budget, preserve template footers during edits, or communicate timing discipline to users.

**Decision:** Add `skills/init/references/design-principles.md` containing the skill's invariants and their sources. Add one pointer line to the top of SKILL.md instructing the agent to load it when generating CLAUDE.md, modifying templates, logging decisions, or defending architectural choices. Content stays out of SKILL.md's main body to preserve progressive disclosure.

**Consequences:**
- Skill can now enforce the 150-line CLAUDE.md budget and flag bloat to users
- Skill can defend defaults with source citations rather than treating them as preferences
- Template source-attribution footer becomes a preserved invariant across edits
- SKILL.md grows by one line; rationale file is ~80 lines loaded on-demand only
- Establishes a pattern for future skills in this plugin (references for *why*, SKILL.md for *what*)
- Creates a minor maintenance burden: if a decision changes (e.g., new DECISIONS.md entry supersedes old guidance), the reference file must be updated too

**Alternatives Considered:**
- Inline the rationale in SKILL.md — violates progressive disclosure; bloats every skill invocation with context that's only relevant in specific sub-tasks
- Rely on CLAUDE.md — Cowork doesn't auto-load plugin-internal CLAUDE.md files at skill-invocation time
- Leave rationale in README.md only — README is human-facing and not addressable from the skill via `${CLAUDE_PLUGIN_ROOT}`

---

## Decision 009: Adaptive versioning conventions in scaffolded projects

**Status:** Accepted
**Date:** 2026-04-21

**Context:** Managing six plugins (mdpowers, agentic-scaffold, superpowers-cowork, git-cowork, regen-network, notion-sync) revealed a consistent pattern: projects that track versions need explicit conventions to prevent drift between their version source (plugin.json, package.json, etc.), CHANGELOG headings, commit messages, and git tags. mdpowers drifted to four conflicting version sources before the problem was caught. Meanwhile, knowledge gardens and documentation projects don't need versioning at all — adding it would be noise.

The scaffold already has adaptive file generation (core vs adaptive, per Decision 007). Versioning conventions fit the same pattern: detect whether the project needs version tracking, and only include the conventions when they're warranted.

**Decision:** Add versioning as an adaptive section in the scaffold:

1. **Detection** — new "Versioning signals" step in the init scan checks for `.claude-plugin/plugin.json`, manifest `version` fields, git tags, release workflows, and existing changelogs
2. **Inference** — `needs_versioning` field in the inference map, defaulting to yes for software/plugins and no for knowledge/docs projects
3. **Adaptive question** — only ask when detection is inconclusive (follows existing "never ask what you can infer" rule)
4. **Reference file** — `skills/init/references/versioning-conventions.md` with the four rules (single source of truth, semver, git tags on release, pre-commit version check) and their rationale
5. **Injection** — when `needs_versioning` is true, a `### Versioning` subsection is added to the generated CLAUDE.md, adapted to the project's specific version source

For partially-scaffolded repos that already have a CLAUDE.md but lack versioning conventions, the skill suggests adding them rather than silently skipping.

**Consequences:**
- Software projects and plugins get versioning conventions from day one, preventing the drift pattern seen in mdpowers
- Knowledge gardens and docs projects don't get unnecessary versioning noise
- The reference file documents the "why" (mdpowers incident, real-world experience) so future agents can defend the conventions
- Adds one detection step, one inference field, one potential question, one reference file, and one adaptive section — modest complexity increase, proportional to the value
- The versioning section contributes ~8 lines to generated CLAUDE.md files, well within the 150-line budget

**Alternatives Considered:**
- *Always include versioning* — contradicts progressive disclosure; knowledge gardens don't need it
- *Never include versioning (leave to the user)* — the mdpowers drift shows this doesn't work in practice; conventions need to be established at scaffold time
- *Separate versioning skill* — overkill for what's essentially a documentation convention; the scaffold is the right time to establish it

---

## Decision 010: Add logchange skill (migrated from git-plugin) (2026-04-21)

**Status:** Accepted
**Date:** 2026-04-21

**Context:** The `logchange` skill maintains CHANGELOG.md — updating it with a narrative summary of recent work after a session. It was originally shipped in `git-plugin` because it's invoked alongside git workflows. However, CHANGELOG.md is created by this plugin's `/init` skill. The artifact has two phases: creation (init) and ongoing maintenance (logchange). Having them in separate plugins splits an artifact lifecycle across unrelated packages.

`git-plugin` is focused on git operations: staging, committing, PR creation, repo orientation. Maintaining a human-readable changelog is documentation work, not a git operation. The conceptual fit is much stronger here.

**Decision:** Migrate `logchange` from `git-plugin` to `agentic-scaffold-plugin`. Namespace it as `agentic-scaffold:logchange`. Remove it from `git-plugin` in that repo's v0.3.0 release.

**Consequences:**
- The full CHANGELOG.md lifecycle (create → maintain) is co-located in one plugin
- `git-plugin` is more focused: commit, PR, status, and nothing else
- Users with `logchange` symlinked to `git-plugin` must update their symlinks — in montymerlinHQ, `.claude/skills/logchange` was rewired in the same session
- Skill is now namespaced `agentic-scaffold:logchange` rather than `git:logchange` — any documentation or habit referencing `git:logchange` is stale
- Establishes a cleaner principle: skills in this plugin maintain artifacts that this plugin creates

---

## Decision 012: Canonicalize scaffold instructions around AGENTS.md

**Status:** Accepted
**Date:** 2026-04-22

**Context:** The plugin had become Claude-first in two layers at once: the repo itself used `CLAUDE.md` as its own source of truth, and the `/init` skill generated `CLAUDE.md` as the canonical instruction file for every scaffolded repo. That now conflicts with the convention adopted across montymerlinHQ: `AGENTS.md` should be canonical, while Claude-facing files exist as compatibility layers. Leaving agentic-scaffold on the old pattern would keep reintroducing drift into every newly scaffolded project.

**Decision:** Make `AGENTS.md` canonical in both the plugin repo and scaffolded output. Keep `CLAUDE.md` as a thin compatibility wrapper that points to `AGENTS.md`. Update templates, skill instructions, references, installation docs, and packaging metadata together so the repo and generated output follow the same cross-host convention.

**Consequences:**
- Newly scaffolded repos get a future-friendly canonical instruction file from day one
- Claude-family tools still work cleanly through a wrapper rather than a second source of truth
- The plugin is repositioned as host-agnostic, with `.claude-plugin/` serving packaging compatibility rather than defining the repo
- The migration touches both the plugin repo and the generator logic, but avoids the worse outcome of a half-migrated scaffold
- Codex can consume the same skills directly via global install scripts or workspace symlinks

**Alternatives Considered:**
- Keep `CLAUDE.md` canonical and document AGENTS as optional — perpetuates drift and conflicts with the newer workspace convention
- Migrate only the repo, not the generated output — leaves the product behavior stale
- Generate AGENTS only for non-Claude users — reintroduces branching logic where a single canonical file is simpler

**Alternatives Considered:**
- *Keep in git-plugin* — simpler in the short term, but splits the artifact lifecycle and muddies git-plugin's focus
- *Standalone logchange plugin* — overkill for one skill with a clear home already

---

## Decision 011: Dual-distribution packaging with marketplace.json (2026-04-21)

**Status:** Accepted
**Date:** 2026-04-21

**Context:** The plugin was described as "Cowork plugin (Claude Desktop)" in CLAUDE.md, with no marketplace.json for Claude Code CLI installation. The plugin has zero runtime dependencies — it's pure markdown templates and workflow specs — so there's no technical reason to limit it to one host. As the plugin portfolio standardised on dual-distribution, this plugin needed the same treatment.

**Decision:** Add `.claude-plugin/marketplace.json`, update CLAUDE.md Project Identity to say "Claude Agent SDK plugin" rather than "Cowork plugin", replace the Plugin Packaging section with a Distribution section covering both install paths, and add Installation instructions to README.md.

**Consequences:**
- Users can install via `claude plugins install github.com/montymerlin/agentic-scaffold-plugin`
- Cowork users can install via `.plugin` zip or marketplace
- CLAUDE.md no longer positions the plugin as single-host
- marketplace.json version must stay in sync with plugin.json on each release

**Alternatives Considered:**
- *Cowork only* — rejected. `/init` is equally useful in Claude Code CLI where users scaffold new repos
- *Add COMPATIBILITY.md* — deferred. The plugin has no environment-specific behaviour to document; the Distribution section in CLAUDE.md is sufficient
