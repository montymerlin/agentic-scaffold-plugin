# agentic-scaffold

Scaffold agentic best practices into any project folder. One `/init` command detects your project's stack and state, then generates a coordinated set of documentation and configuration files — each serving a distinct purpose, each informed by established conventions — with smart defaults adapted to what's already there.

The goal is to give every project a solid foundation for AI-assisted development from day one, without front-loading complexity you don't need yet.

## What It Does

Run `/init` in any project folder. The plugin scans for existing files, infers your project details, asks what tools you use, and scaffolds two layers of files:

### Core Files (always generated)

These five files form the backbone of any agentic scaffold. They're generated for every project.

| File | Audience | Purpose |
|------|----------|---------|
| README.md | Humans | Project overview, setup, usage |
| CLAUDE.md | AI agents | Conventions, boundaries, stack-specific instructions |
| DECISIONS.md | Both | Architectural decision records |
| ROADMAP.md | Both | Future directions, inspiration, and idea pipeline |
| CHANGELOG.md | Both | Narrative change history |

### Adaptive Files (generated based on your setup)

These files are offered based on what tools you use and whether you work solo or in a team. During scaffolding, `/init` detects your tooling from existing files or asks you directly.

| File | When generated | Purpose |
|------|---------------|---------|
| .cursorrules | Cursor users | Editor-specific conventions |
| .claude/settings.local.json | Claude Code users | Project configuration |
| CONTRIBUTING.md | Team projects | Collaboration guide |

## The Core Files

### README.md — The human front door

README.md is the human-readable overview of the project. It answers the questions every person landing on the repo will ask: what is this, how do I set it up, how do I use it, and how do I contribute?

This is one of the oldest conventions in software — GitHub's own [documentation guidelines](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes) formalize what open source projects have practiced for decades. The scaffold generates a README with standard sections (project name, description, getting started, usage, contributing, license) because these have proven their worth across millions of repositories.

What makes the scaffold's README distinctive is what it *doesn't* try to do. It doesn't contain agent instructions, convention details, or structural maps — those live in CLAUDE.md. This separation is deliberate. When a single README tries to serve both humans browsing the project and AI agents working in it, neither audience is served well. The human wades through agent-specific jargon; the agent parses human-oriented prose looking for its instructions. Giving each audience its own document means each document can be focused and concise.

### CLAUDE.md — The agent instruction set

CLAUDE.md is the counterpart to README.md — where README serves humans, CLAUDE.md serves AI agents. It's read at the start of every agent session and contains everything an AI needs to work effectively in the repo: project identity, directory structure, naming conventions, commit style, agent boundaries (what to do and what not to do), and stack-specific guidance.

The CLAUDE.md convention was established by [Anthropic](https://docs.anthropic.com/en/docs/claude-code/memory) as part of Claude Code's memory system — a project-level instruction file that persists across sessions. The [HumanLayer community](https://humanlayer.dev/blog/claude-md-best-practices) built on this with a best practices guide that contributed several key insights: keep it under 150 lines (agents lose focus in long documents), include explicit do/don't boundaries (agents need guardrails, not just guidelines), and never duplicate what's in the README (reference it instead).

The scaffold's CLAUDE.md template goes further by embedding a Design Principles section into every generated file. This means the project's own evolution principles — progressive disclosure, dual-audience documentation, decisions as first-class artifacts — are documented from day one, not added retroactively. The concept of progressive disclosure comes from [Steve Krug's *Don't Make Me Think*](https://sensible.com/dont-make-me-think/) and [Nielsen Norman Group's interaction design research](https://www.nngroup.com/articles/progressive-disclosure/): reveal complexity gradually, don't front-load structure you haven't earned yet. For agentic projects the stakes are sharper — every token loaded at session start is a token unavailable for the actual task. [Anthropic's Agent Skills architecture](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) formalizes the same idea for AI contexts via a three-level model (metadata → instructions → nested files), where bundled content has no context cost until accessed. The scaffold's CLAUDE.md therefore stays small at the root and points to deeper files (DECISIONS.md, ROADMAP.md, sub-directory docs) that are discovered only when the task requires them.

### DECISIONS.md — The architectural decision record

DECISIONS.md is a lightweight log of architectural choices — the decisions that shape how a project is built, not just what it contains. Each entry follows a structured format: a sequential number, a status, and four sections — Context (why this decision was needed), Decision (what was chosen), Consequences (what follows from the choice), and Alternatives Considered (what else was evaluated).

This format traces directly to [Michael Nygard's 2011 proposal](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) for Architectural Decision Records (ADRs). Nygard observed that teams repeatedly ask "why did we do it this way?" and the answer is usually buried in a Slack thread, a meeting that nobody documented, or the memory of someone who has since left the project. His solution was deliberately minimal: a short, structured document per decision, stored alongside the code. Keeling and Runde later extended the practice in IEEE Software with guidance on organizational adoption — notably, that not every choice needs a record. The scaffold follows this guidance: log decisions that affect project structure, tool choices, convention changes, or trade-offs that future contributors (including your future self) would benefit from understanding.

The key discipline the scaffold enforces is *timing*: entries are written before implementation, not after. This forces the thinking to happen up front. It's easy to rationalize a decision in retrospect; it's harder to articulate your reasoning when the outcome is still uncertain. The scaffold seeds DECISIONS.md with a first entry — "Decision 001: Adopted agentic scaffold" — which demonstrates the format and documents the choice to use this structure in the first place.

DECISIONS.md has a direct relationship with ROADMAP.md. Ideas captured in the roadmap eventually get evaluated, and the outcome — adopted, deferred, or declined — gets logged as a decision. This creates a traceable pipeline from initial inspiration to architectural choice.

### ROADMAP.md — The inspiration pipeline

ROADMAP.md is a place to capture future directions, inspiration, and possibilities without the pressure of a commitment or deadline. It solves a specific problem: good ideas get lost if there's nowhere low-friction to capture them, but tracking every idea as a task creates overwhelming noise.

The template uses four sections, each representing a different level of commitment. **Near-term** holds items actively being worked on. **Future explorations** captures ideas worth evaluating when the time is right. **Parking lot** is the loosest category — inspiration, references, repos you've seen, half-formed thoughts, things you might want to explore someday. **Decided** tracks items that have been evaluated, with pointers to their corresponding entries in DECISIONS.md. Each item carries a lightweight status tag: `active`, `idea`, `parked`, or `decided`.

This structure draws from several established patterns. [GitHub's public roadmap](https://github.com/github/roadmap) pioneered phase-based tracking for open projects, demonstrating that roadmaps don't need to be Gantt charts. [Mozilla Science's roadmapping guide](https://mozillascience.github.io/working-open-workshop/roadmapping/) emphasized the balance between strategic direction and practical next steps. The "parking lot" concept comes from agile practice (formalized in tools like [Aha! Roadmaps](https://www.aha.io/roadmaps/guide/product-roadmap)) — a staging area for ideas that aren't ready for prioritization but shouldn't be forgotten. And the [YAGNI principle](https://martinfowler.com/bliki/Yagni.html) from extreme programming ("You Ain't Gonna Need It") provides the philosophical foundation: don't build what you don't need yet, but don't lose track of what you might need later.

The pipeline from ROADMAP.md to DECISIONS.md is a pattern this scaffold introduces. Rather than items simply disappearing from the roadmap when they're resolved, they move to the Decided section with a pointer to the decision record. This creates an auditable trail: you can trace any architectural choice back to when it was first conceived as a roadmap idea, through its evaluation, to its final disposition.

### CHANGELOG.md — The narrative history

CHANGELOG.md is a record of how the project evolves over time, written in narrative prose rather than mechanical version lists. It's updated after significant work sessions, not per-commit — capturing the story of *why* changes happened, not just *what* changed.

The format is adapted from the [keep-a-changelog](https://keepachangelog.com) standard, which established the principle that changelogs should be human-readable and maintained deliberately. The scaffold shifts from keep-a-changelog's version-centric format to a narrative style, informed by patterns observed in knowledge garden projects: narrative changelogs are more useful than lists because they capture context that commit messages and diffs don't. An entry like "Refactored the auth middleware to meet new compliance requirements — see Decision 004" tells a future reader far more than "v2.1.0: Updated auth module." Agents are instructed (via CLAUDE.md) to update the changelog after significant work sessions, making it a natural part of the development rhythm.

## Adaptive Files

These files are generated based on your tooling and team setup. During scaffolding, `/init` detects existing tool configurations or asks what tools you use to work on the project.

### .cursorrules (for Cursor users)

Mirrors key CLAUDE.md conventions in the format Cursor expects. Includes project identity, code style conventions, file organization rules, and commit message standards. Generated when Cursor is detected (existing .cursorrules or .cursor/ directory) or when you indicate you use Cursor. Informed by the [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) community ecosystem, which collects patterns across hundreds of projects and stacks.

### .claude/settings.local.json (for Claude Code users)

Claude Code project configuration. Points the agent to CLAUDE.md and sets up key instructions (read CLAUDE.md at session start, log decisions, update changelog). Generated when Claude Code is detected (existing .claude/ directory) or when you indicate you use Claude Code. Based on [Anthropic's Claude Code configuration documentation](https://docs.anthropic.com/en/docs/claude-code/memory).

### CONTRIBUTING.md (for team projects)

How to work with the agentic setup as a team. Covers the file inventory, how to make changes (read CLAUDE.md first, check DECISIONS.md for prior choices, log new decisions before implementing), how to update CLAUDE.md, and the decision logging format. Generated when team mode is detected (existing CONTRIBUTING.md, .github/ directory, multiple git authors) or confirmed by you. Informed by [GitHub's contribution guideline conventions](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors) and open source practices.

## How It Works

1. **Detects** existing files, package manifests, git state, language markers, and tool configurations
2. **Infers** project name, description, stack, solo/team mode, and tooling from what it finds
3. **Confirms** inferences with you — including what tools you use (Cursor, Claude Code, both, neither) — only asking what can't be determined from the environment
4. **Generates** files from templates with your project details interpolated
5. **Presents** what it will create for your approval before writing anything
6. **Writes** only after you approve — never overwrites existing files

**Blank directory:** Asks up to 4 questions (project description, stack, solo/team, tooling), then scaffolds everything.

**Existing project (e.g., a Python package with pyproject.toml and .cursor/ directory):**
> "I can see this is a Python package called `datapipe` — solo developer, using Cursor. No agentic files yet. Here's what I'd add: [5 core files + .cursorrules]. Want me to proceed?"

**Partially scaffolded project:**
> "Found existing CLAUDE.md and README.md. Missing: CHANGELOG.md, DECISIONS.md, ROADMAP.md. Want me to add those?"

## Supported Stacks

The scaffold adapts its conventions to your detected stack:

| Stack | Detection Signal | Convention Defaults |
|-------|-----------------|-------------------|
| JavaScript/TypeScript | package.json | ESM, named exports, prettier/eslint, jest/vitest |
| Python | pyproject.toml, setup.py | Type hints, pytest, ruff/black, docstrings |
| Rust | Cargo.toml | clippy, cargo test, cargo fmt |
| Go | go.mod | go vet, go test, gofmt |
| Ruby | Gemfile | RSpec, rubocop, YARD |
| Java/Kotlin | build.gradle, pom.xml | JUnit, checkstyle, Javadoc |
| Generic | No manifest | Descriptive naming, consistent formatting |

## Design Principles

These principles guide both the scaffold itself and the projects it generates. Each is grounded in an established source so the reasoning is inspectable rather than taste-based.

1. **Progressive disclosure** — Start simple, and keep root and initialization files deliberately small. Every token an agent loads at session start is a token unavailable for the actual task — and frontier models only reliably follow a bounded number of instructions before focus degrades. Deeper context should live nested further down in the file structure, referenced by name and loaded only when specifically needed. The scaffold generates minimal core files at the root; detailed guidance lives in sub-documents discovered on demand; adaptive files are added only when the environment warrants them. The pattern traces to [Nielsen Norman Group's progressive disclosure research](https://www.nngroup.com/articles/progressive-disclosure/) in interaction design, and has been formalized for agents in [Anthropic's Agent Skills architecture](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) (metadata → instructions → nested files, where bundled content has no context cost until accessed) and the [HumanLayer community's CLAUDE.md best practices](https://humanlayer.dev/blog/claude-md-best-practices) (keep the root file small; push detail into linked files).

2. **Dual-audience documentation** — README.md serves humans. CLAUDE.md serves agents. Keep them distinct. Don't collapse one audience's needs into the other's document. Grounded in [Anthropic's CLAUDE.md memory convention](https://docs.anthropic.com/en/docs/claude-code/memory), which establishes CLAUDE.md as a dedicated agent-facing file separate from project README, and reinforced by [HumanLayer's guidance](https://humanlayer.dev/blog/claude-md-best-practices) to never duplicate README content — reference it instead.

3. **Adaptive detection** — Infer from the environment first, ask only what can't be determined. Smart defaults beat questionnaires. This is an application of sensible-defaults thinking from [*The Ruby on Rails Doctrine*](https://rubyonrails.org/doctrine) ("The menu is omakase") and aligns with the principle of least astonishment: the scaffold should behave the way an experienced practitioner would expect without needing to be told.

4. **Source-grounded defaults** — Every template design choice traces to a documented source. No convention exists "because it seemed right." This discipline is adapted from the [ADR practice itself](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions): if you can't articulate *why* a default exists, it probably shouldn't be a default. Applied to the scaffold, it means this README's Design Sources sections aren't decorative — they are the evidence trail for every decision baked into the templates.

5. **Convention over configuration** — Prefer consistent patterns over per-case customization. When a pattern is established, follow it. The phrase was coined by David Heinemeier Hansson as a core tenet of [*The Ruby on Rails Doctrine*](https://rubyonrails.org/doctrine) and has since become one of the most influential ideas in modern framework design. The scaffold inherits the philosophy: a new contributor (human or agent) can drop into any scaffolded project and find the same file names, the same sections, and the same decision format.

6. **Layered generation** — Core files are always generated. Tool-specific and team-specific files adapt to your setup. Don't generate files you don't need. This is an application of the [YAGNI principle](https://martinfowler.com/bliki/Yagni.html) ("You Ain't Gonna Need It") from extreme programming, codified by Martin Fowler: the cost of speculative features is paid immediately while the value is uncertain. Layered generation also echoes the metadata/instructions/nested-files progression of [Anthropic's Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) at the repo-scaffold scale — load what's needed now, leave the rest to be added when the project earns it.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for future directions, ideas, and inspiration — including monorepo support, API project patterns, knowledge garden scaffolds, a `/scaffold-check` audit skill, and more.

## Further Reading

Sources referenced throughout this document, for those who want to dig deeper:

- [Anthropic CLAUDE.md conventions](https://docs.anthropic.com/en/docs/claude-code/memory) — the canonical reference for agent instruction files
- [Anthropic — Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — the three-level progressive disclosure model for agent context
- [HumanLayer CLAUDE.md best practices](https://humanlayer.dev/blog/claude-md-best-practices) — community guide to effective CLAUDE.md files
- [Nielsen Norman Group — Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/) — the foundational UX principle
- [The Ruby on Rails Doctrine](https://rubyonrails.org/doctrine) — convention over configuration, sensible defaults, "the menu is omakase"
- [Martin Fowler — YAGNI](https://martinfowler.com/bliki/Yagni.html) — "You Ain't Gonna Need It" from extreme programming
- [Michael Nygard — Architectural Decision Records](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) — the original ADR proposal (2011)
- [keep-a-changelog](https://keepachangelog.com) — the standard for changelog formatting
- [GitHub public roadmap](https://github.com/github/roadmap) — phase-based roadmap patterns at scale
- [Mozilla Science roadmapping guide](https://mozillascience.github.io/working-open-workshop/roadmapping/) — open source roadmapping methodology
- [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) — community .cursorrules patterns
- [GitHub README guidelines](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes) — effective README structure
- [Jesse Vincent — Superpowers framework](https://github.com/obra/superpowers) — workflow discipline for AI-assisted work
- [Letta context management](https://github.com/letta-ai/letta) — persistent context patterns for AI agents
- [*Don't Make Me Think* (Steve Krug)](https://sensible.com/dont-make-me-think/) — progressive disclosure and interaction design
- Keeling & Runde, IEEE Software — sustainable architectural decisions
- montymerlinHQ — three-space knowledge garden architecture, narrative changelog pattern
- bridging-worlds — project scaffold patterns, DECISIONS.md format, controlled vocabulary

## License

MIT
