# Decisions — agentic-scaffold-cowork

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
