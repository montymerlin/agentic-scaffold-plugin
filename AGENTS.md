# AGENTS.md — agentic-scaffold

Canonical repo instructions for `agentic-scaffold-plugin`.

## Project Identity

- **Name:** agentic-scaffold
- **Type:** Host-agnostic scaffold and skills repo with Claude plugin packaging compatibility
- **Version:** 0.9.1
- **Stack:** Markdown templates + SKILL.md workflow specifications + lightweight install scripts

## Canonical Structure

```
agentic-scaffold-plugin/
├── .claude-plugin/
│   ├── plugin.json          # Claude plugin packaging metadata
│   └── marketplace.json     # Claude marketplace listing
├── skills/
│   ├── init/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── logchange/
│   │   └── SKILL.md
│   ├── nest/
│   │   └── SKILL.md
│   ├── repo-audit/
│   │   ├── SKILL.md
│   │   └── references/
│   └── session-closeout/       # setup only — generates the workflow, vendors the runner
│       ├── SKILL.md
│       └── references/
│           ├── closeout-blocks.md         # modular blocks the workflow is assembled from
│           ├── runner-skill-template.md   # the thin `closeout` runner vendored into repos
│           └── runner-LICENSE.txt         # its MIT notice, vendored beside it
├── templates/
│   ├── AGENTS.md.tmpl
│   ├── CLAUDE.md.tmpl
│   ├── README.md.tmpl
│   ├── CHANGELOG.md.tmpl
│   ├── DECISIONS.md.tmpl
│   ├── ROADMAP.md.tmpl
│   ├── CONTRIBUTING.md.tmpl
│   ├── cursorrules.tmpl
│   └── claude-settings.json.tmpl
├── scripts/
│   ├── install_codex_skills.sh
│   └── update_codex_skills.sh
├── tests/
│   └── test_install_codex_skills.sh
├── AGENTS.md                # Canonical repo instructions
├── CLAUDE.md                # Claude compatibility wrapper
├── SETUP.md                 # Canonical install + compatibility reference (all hosts)
├── CHANGELOG.md
├── DECISIONS.md
├── ROADMAP.md
├── README.md
├── LICENSE                  # MIT
├── .gitignore
└── .cursorrules             # Cursor-specific behavior config
```

## Packaging for Cowork

Cowork install is via a `.plugin` zip uploaded through Claude Desktop. Two paths:

1. **Use the `cowork-plugin-packager` skill** in the montymerlinHQ workspace — runs validation, packaging, and verification. Produces `agentic-scaffold-<version>.plugin` in `ops/plugins/_dist/`.
2. **Build by hand** — see `SETUP.md` § "Cowork (Claude Desktop App)" for the raw `zip` command and verification steps. Use this when working outside montymerlinHQ.

`SETUP.md` is the single source of truth for install pathways across Cowork, Claude Code CLI, Codex, Cursor/VS Code, and Agent SDK — read it before changing install or packaging behavior.

## Canonical Rules

- `AGENTS.md` is the canonical instruction file for this repo and for scaffolded repos.
- `CLAUDE.md` is a thin compatibility layer that points Claude-family hosts back to `AGENTS.md`.
- `skills/` is the canonical source of shared workflows.
- `.claude-plugin/` is Claude-specific packaging metadata, not the source of truth for the skills themselves.
- Template files define the scaffold output and must stay aligned with the repo’s own conventions.

## Runtime Conventions

- Resolve repo-local references from a portable root variable:
  `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`
- Use that root for `templates/` and `skills/init/references/` lookups instead of assuming Claude-only runtime paths.
- Keep the plugin zero-dependency. Conditional logic belongs in SKILL.md, not in external tooling.

## Documentation Rules

- README.md is human-facing.
- AGENTS.md is the canonical agent-facing document.
- CLAUDE.md exists for compatibility only and should stay short.
- DECISIONS.md logs major structural choices before implementation.
- ROADMAP.md holds future ideas until they become decisions.
- CHANGELOG.md records narrative milestones after significant work.

## Design Principles

1. **Progressive disclosure** — keep root instructions concise and push detail into referenced files.
2. **Dual-audience documentation** — README for humans, AGENTS.md for agents.
3. **Compatibility layers, not duplicate sources** — Claude-facing files should wrap or point to canonical files.
4. **Adaptive generation** — scaffold only what the environment and project actually need.
5. **Convention over configuration** — prefer stable file names and structure across projects.
6. **Eat your own cooking** — the plugin repo should embody the scaffold pattern it generates.

## Boundaries

### Do
- Update templates and skill docs together when conventions change
- Log major structural choices in DECISIONS.md before implementation
- Update CHANGELOG.md after significant releases
- Preserve source-attribution footers in templates

### Don't
- Reintroduce `CLAUDE.md` as the canonical scaffold output
- Hardcode Claude-only runtime paths inside skills
- Add runtime dependencies for templating or installation
- Merge human-facing and agent-facing docs into one file
