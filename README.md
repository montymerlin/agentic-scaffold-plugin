# agentic-scaffold-cowork

A Cowork plugin that scaffolds agentic best practices into any project folder. One `/init` command detects your project's stack and state, then generates coordinated documentation and configuration files with smart defaults.

## What It Does

Run `/init` in any project folder. The plugin scans for existing files, infers your stack and project details, and scaffolds:

| File | Audience | Purpose |
|------|----------|---------|
| README.md | Humans | Project overview, setup, usage |
| CLAUDE.md | AI agents | Conventions, boundaries, stack-specific instructions |
| CHANGELOG.md | Both | Narrative change history |
| DECISIONS.md | Both | Lightweight architectural decision records |
| .cursorrules | Cursor IDE | Editor-specific conventions |
| .claude/settings.local.json | Claude Code | Project configuration |
| CONTRIBUTING.md | Humans (teams) | Collaboration guide (offered for team projects) |

## How It Works

1. **Detects** existing files, package manifests, git state, and language markers
2. **Infers** project name, description, stack, and solo/team mode from what it finds
3. **Confirms** inferences with you (or asks questions for blank directories)
4. **Generates** files from templates with your project details interpolated
5. **Presents** what it will create for your approval before writing anything
6. **Writes** only after you approve — never overwrites existing files

For existing projects with some agentic files already present, it performs a gap analysis and only scaffolds what's missing.

## Usage

In Cowork, type `/init` in any project folder. The skill handles the rest adaptively based on what it finds.

**Blank directory:**
> Asks up to 3 questions (project description, stack, solo/team), then scaffolds everything.

**Existing project (e.g., a Python package with pyproject.toml):**
> "I can see this is a Python package called `datapipe` — solo developer, no agentic files yet. Here's what I'd add: [list]. Want me to proceed?"

**Partially scaffolded project:**
> "Found existing CLAUDE.md and README.md. Missing: CHANGELOG.md, DECISIONS.md, .cursorrules, .claude/settings.local.json. Want me to add those?"

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

## Roadmap

Future versions will add progressive layers for specialized project types:

- **Monorepo support** — workspace-aware scaffolding with shared and per-package conventions
- **API project patterns** — OpenAPI spec pointers, endpoint documentation conventions
- **Knowledge garden scaffold** — adapted structure for personal knowledge management
- **`/scaffold-check` skill** — audit an existing scaffold against current best practices and suggest updates
- **Template customization** — user-defined template overrides for organization-specific conventions

## Design Sources & Inspiration

Every design choice in this plugin traces to documented sources. This section credits both the technical references and the conceptual principles that shaped the scaffold.

### Technical Sources

**Anthropic CLAUDE.md Conventions**
Anthropic's documentation on CLAUDE.md structure and purpose — the canonical reference for how agents should receive project instructions. Informed the CLAUDE.md template's section structure and the principle that CLAUDE.md should be agent-facing, not a general-purpose README.
https://docs.anthropic.com/en/docs/claude-code/memory

**HumanLayer CLAUDE.md Best Practices Guide**
Community-driven guide to writing effective CLAUDE.md files. Contributed the "under 150 lines" guideline, the emphasis on agent boundaries (do/don't sections), and the recommendation to separate human and agent documentation.
https://humanlayer.dev/blog/claude-md-best-practices

**Michael Nygard — Architectural Decision Records (2011)**
The original lightweight ADR proposal that established the status/context/decision/consequences format. This format drives our DECISIONS.md template.
https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions

**Keeling & Runde — Sustainable Architectural Decisions (IEEE Software)**
Extended Nygard's ADR format with guidance on when to write decisions, how to maintain them, and organizational adoption patterns. Informed our guidance on decision granularity ("not every choice needs a record").

**keep-a-changelog**
The standard format for changelogs. We adapted its structure to a narrative style — focusing on "why" and "what changed" rather than mechanical per-version lists — based on patterns observed in knowledge garden projects.
https://keepachangelog.com

**awesome-cursorrules**
Community repository of .cursorrules examples across different stacks and project types. Informed the structure of our cursorrules template and stack-specific convention defaults.
https://github.com/PatrickJS/awesome-cursorrules

**GitHub README Guidelines**
GitHub's guidance on writing effective READMEs. Informed the README.md template structure: project name, description, getting started, usage, contributing, license.
https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes

**Letta Context Management**
Letta's approach to persistent context for AI agents — separating core memory, archival memory, and working memory. Influenced the principle of giving agents a clear, structured "starting point" document rather than relying on conversation context.
https://github.com/letta-ai/letta

**Jesse Vincent — Superpowers Framework**
Workflow discipline framework for AI-assisted work. Its emphasis on verification gates, rationalization prevention, and skill composition influenced the scaffold's approach to documenting agent boundaries and design principles.
https://github.com/obra/superpowers

### Conceptual Sources

**Progressive Disclosure** (Krug, *Don't Make Me Think*; Nielsen Norman Group)
The interaction design principle of revealing complexity gradually rather than all at once. Applied here as an architectural principle: the scaffold starts with 6 files, future versions add layers for specialized project types. Also embedded in the CLAUDE.md template as a documented design principle for the scaffolded project itself.

**Convention over Configuration** (Rails / David Heinemeier Hansson)
The principle that sensible defaults reduce decision fatigue. Applied here through stack-specific convention defaults and the "infer first, ask second" approach. A Python project gets pytest/ruff conventions without being asked; a JS project gets ESM/prettier.

**Dual-Audience Documentation**
The principle that different audiences need different documents, even when the subject is the same. Formalized here as the README (humans) / CLAUDE.md (agents) split. Informed by documentation theory and the observed failure mode of "everything in one README" in AI-assisted projects.

**Smart Defaults Pattern**
The UX principle that good defaults let users skip configuration while still allowing customization. Applied here through adaptive detection (infer project details from existing files) and the "present then approve" interaction model.

**Architectural Decision Records as First-Class Artifacts**
The practice of treating design decisions as versioned, searchable documents rather than ephemeral conversation or buried commit messages. Draws from ADR literature and the observed failure mode of "why did we do it this way?" in projects without decision logs.

### Personal Sources

**montymerlinHQ Knowledge Garden**
A three-space knowledge system (self, knowledge, ops) with 9-file DNA architecture. Contributed the principle of cross-referencing between files rather than duplicating content, and the narrative changelog pattern.

**bridging-worlds Project**
A project scaffold using CLAUDE.md, SETUP.md, PLAN.md, DECISIONS.md, CONTRIBUTING.md, CHANGELOG.md, and .claude/skills/. Contributed the DECISIONS.md format, the controlled vocabulary approach, and the practice of scaffolding agent instructions alongside human documentation from project inception.

## License

MIT
