# CLAUDE.md — agentic-scaffold

A Cowork plugin that scaffolds agentic best practices into any repo. One `/init` command generates 5 core files (README.md, CLAUDE.md, CHANGELOG.md, DECISIONS.md, ROADMAP.md) plus adaptive files based on your tooling and team setup.

## Project Identity

- **Name:** agentic-scaffold
- **Type:** Cowork plugin (Claude Desktop)
- **Version:** 0.1.0
- **Stack:** Markdown templates + SKILL.md workflow specification (no runtime dependencies)

## Directory Structure

```
agentic-scaffold-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/
│   ├── init/
│   │   └── SKILL.md         # The /init skill — full workflow spec
│   └── logchange/
│       └── SKILL.md         # The /logchange skill — maintains CHANGELOG.md
├── templates/               # Template files for scaffolded output
│   ├── README.md.tmpl
│   ├── CLAUDE.md.tmpl
│   ├── CHANGELOG.md.tmpl
│   ├── DECISIONS.md.tmpl
│   ├── ROADMAP.md.tmpl
│   ├── CONTRIBUTING.md.tmpl
│   ├── cursorrules.tmpl
│   └── claude-settings.json.tmpl
├── CLAUDE.md                # This file — agent instructions
├── CHANGELOG.md             # Narrative change history
├── DECISIONS.md             # Architectural decision log
├── ROADMAP.md               # Future directions and inspiration
├── .cursorrules             # Cursor IDE conventions
└── README.md                # Human-facing documentation
```

## Key Conventions

### Templates
- Template files use `{{variable}}` interpolation (simple string replacement, no engine)
- All templates live in `templates/` and are referenced via `${CLAUDE_PLUGIN_ROOT}/templates/`
- Every template includes a source attribution footer comment
- Template variables: `{{project_name}}`, `{{description}}`, `{{stack}}`, `{{directory_structure}}`, `{{stack_conventions}}`, `{{date}}`, `{{year}}`, `{{license}}`

### Skills

This plugin provides two skills:

- **init** — scaffolds the five core agentic files (including CHANGELOG.md) into a new repo
- **logchange** — maintains CHANGELOG.md over the project's lifetime

logchange lives here because it maintains CHANGELOG.md, which agentic-scaffold generates — same artifact lifecycle. scaffold creates the file, logchange keeps it current.

### SKILL.md
- Follows CSO (Claude Search Optimization) pattern: description triggers on conditions, doesn't summarize workflow
- YAML frontmatter with `name` and `description` fields
- Workflow is fully self-contained — an agent should be able to execute it with no external context

### Plugin packaging
- Package with `zip -r agentic-scaffold.plugin .` from the plugin root directory
- Exclude .git/, .DS_Store, and other non-essential files
- plugin.json version must match CHANGELOG.md latest entry

### Documentation
- README.md is human-facing — explains what the plugin does, how to use it, design sources
- CLAUDE.md (this file) is agent-facing — conventions, structure, boundaries
- DECISIONS.md logs architectural choices — add entries before implementing changes
- ROADMAP.md captures future directions — items flow to DECISIONS.md when evaluated
- CHANGELOG.md tracks evolution narratively — update after significant work

## Agent Boundaries

### Do
- Read this file at session start
- Follow template variable conventions exactly
- Log decisions in DECISIONS.md before implementing significant changes
- Update CHANGELOG.md after making changes
- Test templates by mentally interpolating variables to check output quality
- Keep SKILL.md self-contained and executable

### Don't
- Add runtime dependencies — this plugin has zero deps by design
- Change template variable names without updating SKILL.md's interpolation table
- Overwrite user files — the /init skill must always present and get approval first
- Merge human-facing and agent-facing documentation

## Design Principles

1. **Progressive disclosure** — The scaffold starts simple (5 core files + adaptive extras). Future versions add layers for specialized project types. Don't front-load complexity.


2. **Dual-audience documentation** — README for humans, CLAUDE.md for agents. This principle applies both to the plugin itself and to what it generates.

3. **Adaptive detection** — Infer from environment first, ask only what can't be determined. Smart defaults beat questionnaires.

4. **Source-grounded defaults** — Every template design choice traces to a documented source. See README.md Design Sources section.

5. **Convention over configuration** — Prefer consistent patterns. When adding a new template or modifying an existing one, follow established patterns.

6. **Layered generation** — Core files are always generated. Tool-specific and team-specific files adapt to the user's setup.

7. **Eat your own cooking** — This plugin repo uses its own scaffold pattern. Changes to templates should be reflected here, and vice versa.

## References

- [DECISIONS.md](DECISIONS.md) — Architectural decision log
- [ROADMAP.md](ROADMAP.md) — Future directions and inspiration
- [CHANGELOG.md](CHANGELOG.md) — Narrative change history
- [README.md](README.md) — Human-facing documentation with Design Sources
