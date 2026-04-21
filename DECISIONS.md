# Decisions — agentic-scaffold

Architectural decisions for this plugin, in lightweight ADR format.

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

**Alternatives Considered:**
- *Keep in git-plugin* — simpler in the short term, but splits the artifact lifecycle and muddies git-plugin's focus
- *Standalone logchange plugin* — overkill for one skill with a clear home already
