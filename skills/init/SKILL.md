---
name: init
description: >
  Scaffold agentic best practices into a repo or project folder. Use when the
  user asks to "init", "scaffold", "set up repo", "agentic setup", "bootstrap",
  "initialize", "set up CLAUDE.md", "add agentic files", "scaffold repo",
  "repo init", "set up best practices", "add decisions file", "create project
  structure", or wants to add CLAUDE.md, DECISIONS.md, CHANGELOG.md, or editor
  configs to a new or existing project. Also trigger when the user opens a fresh
  repo and asks "what should I set up?" or "how should I organize this?"
---

# Init — Agentic Scaffold

Scaffold agentic best practices into any project folder. Generates coordinated files — README.md, CLAUDE.md, CHANGELOG.md, DECISIONS.md, editor configs — with smart defaults adapted to what's already in the folder.

**Core principles:**
- Progressive disclosure — start with what's needed, add complexity when earned
- Dual-audience documentation — README for humans, CLAUDE.md for agents
- Adaptive detection — infer what you can, ask only what you must
- Source-grounded defaults — every template choice traces to documented sources

## Step 1: Detect & Infer

Scan the target directory to understand what exists. Run these checks:

### Existing agentic files
```bash
# Check for each file (in the target directory)
for f in CLAUDE.md README.md CHANGELOG.md DECISIONS.md CONTRIBUTING.md .cursorrules; do
  [ -f "$f" ] && echo "EXISTS: $f" || echo "MISSING: $f"
done
[ -d ".claude" ] && echo "EXISTS: .claude/" || echo "MISSING: .claude/"
```

### Project signals
```bash
# Package manifests (detect stack)
ls package.json pyproject.toml Cargo.toml go.mod Gemfile build.gradle pom.xml 2>/dev/null

# Git state
git rev-parse --is-inside-work-tree 2>/dev/null && echo "GIT: yes" || echo "GIT: no"
git log --oneline -5 2>/dev/null  # Recent history if exists

# File extension census (detect primary language)
find . -maxdepth 3 -type f -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" -o -name "*.rb" -o -name "*.java" 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5

# Directory structure (for CLAUDE.md)
ls -la
```

### Build the inference map

From the scan results, infer:

| Field | How to infer | Fallback |
|-------|-------------|----------|
| **project_name** | Directory name, or `name` field from package.json / pyproject.toml | Ask user |
| **description** | `description` from manifest, or first line of existing README | Ask user |
| **stack** | Manifest type + file extension census (see stack table below) | Ask user |
| **solo_or_team** | Presence of CONTRIBUTING.md, .github/ directory, multiple git authors | Default to solo |
| **directory_structure** | Output of `ls` / `tree -L 2` if available | Generate after file creation |
| **license** | LICENSE file content, or `license` field from manifest | "MIT" default |

### Stack detection table

| Signal | Stack | Default conventions |
|--------|-------|-------------------|
| package.json | JavaScript/TypeScript | ESM imports, named exports, prettier/eslint, jest/vitest |
| pyproject.toml or setup.py | Python | Type hints, pytest, ruff or black, docstrings |
| Cargo.toml | Rust | clippy, cargo test, cargo fmt, documentation comments |
| go.mod | Go | go vet, go test, gofmt, short variable names |
| Gemfile | Ruby | RSpec, rubocop, YARD docs |
| build.gradle or pom.xml | Java/Kotlin | JUnit, checkstyle, Javadoc |
| No manifest | Generic | Descriptive naming, consistent formatting, tests encouraged |

## Step 2: Classify

Based on the scan, classify the target as one of:

| Classification | Criteria | Behavior |
|---------------|----------|----------|
| **Blank directory** | No files, no git | Scaffold everything, ask all unanswerable questions |
| **Fresh git repo** | Git init'd, few/no files | Scaffold everything, infer from git config |
| **Existing project** | Has code, no agentic files | Gap analysis — scaffold only missing agentic files |
| **Partially scaffolded** | Some agentic files present | Gap analysis — scaffold only what's missing, respect what exists |

## Step 3: Confirm or Ask

**Adaptive questioning:** Present inferences for confirmation. Only ask what the environment can't answer.

For a **mature existing project**, this might be zero questions:
> "I can see this is a Python CLI tool called `datapipe` — solo developer, no agentic files yet. Here's what I'd add: [list]. Want me to proceed?"

For a **blank directory**, ask up to three questions using the AskUserQuestion tool:

1. **What is this project?** (One-line description — feeds into CLAUDE.md header and README)
2. **What's the primary stack/domain?** (e.g., "Python CLI tool", "React app", "research project")
3. **Solo or team?** (Determines whether CONTRIBUTING.md is included)

**Rules:**
- Never ask a question you can answer from the scan
- Present inferences confidently ("I can see this is...") with an option to correct
- If only one field is ambiguous, ask only that one question
- Default solo unless team signals are present

## Step 4: Generate Files

Load templates from `${CLAUDE_PLUGIN_ROOT}/templates/` and interpolate variables.

### Template interpolation

For each template file, read its contents and replace all `{{variable}}` placeholders with the inferred or confirmed values:

| Variable | Source |
|----------|--------|
| `{{project_name}}` | Inferred from directory/manifest or user answer |
| `{{description}}` | Inferred from manifest/README or user answer |
| `{{stack}}` | Detected from manifest/files or user answer |
| `{{directory_structure}}` | Generated from `ls` / `tree -L 2` output |
| `{{stack_conventions}}` | Looked up from stack detection table above |
| `{{date}}` | Today's date in YYYY-MM-DD format |
| `{{year}}` | Current year |
| `{{license}}` | Detected or default "MIT" |

### Files to generate

**Always generate (if missing):**

| File | Template | Purpose |
|------|----------|---------|
| README.md | README.md.tmpl | Human-facing project overview |
| CLAUDE.md | CLAUDE.md.tmpl | Agent instruction set |
| CHANGELOG.md | CHANGELOG.md.tmpl | Narrative change history |
| DECISIONS.md | DECISIONS.md.tmpl | Architectural decision log |
| .cursorrules | cursorrules.tmpl | Cursor IDE conventions |
| .claude/settings.local.json | claude-settings.json.tmpl | Claude Code config |

**Generate only for team projects:**

| File | Template | Purpose |
|------|----------|---------|
| CONTRIBUTING.md | CONTRIBUTING.md.tmpl | Collaboration guide |

### For partially scaffolded repos

If some agentic files already exist:
- **Never overwrite** existing files
- Only generate files that are MISSING
- After generation, note which existing files might benefit from updates (e.g., "Your existing CLAUDE.md doesn't have a Design Principles section — consider adding one")

## Step 5: Present & Approve

Before writing any files, show the user exactly what will be created:

```
Here's what I'll scaffold for {{project_name}}:

**New files:**
- README.md — Human-facing overview ({{description}})
- CLAUDE.md — Agent instructions with {{stack}} conventions
- CHANGELOG.md — Narrative change history, seeded with today's entry
- DECISIONS.md — Decision log with "adopted scaffold" as Decision 001
- .cursorrules — Cursor IDE conventions for {{stack}}
- .claude/settings.local.json — Claude Code project config

**Already present (won't touch):**
- [list any existing files detected in Step 1]

Create these files?
```

**GATE: Do not write any files until the user approves.**

## Step 6: Write

After approval:

1. Create `.claude/` directory if it doesn't exist
2. Write each file from the interpolated templates
3. Do NOT run `git add` or `git commit` — let the user decide when to commit

After writing, confirm:

```
Scaffold complete. 6 files created:
- README.md, CLAUDE.md, CHANGELOG.md, DECISIONS.md, .cursorrules, .claude/settings.local.json

Next steps:
- Review and customize CLAUDE.md for your specific conventions
- Add your first real decision to DECISIONS.md when you make an architectural choice
- Commit when you're happy with the scaffold
```

## Step 7: Offer Extras (if applicable)

After the core scaffold is written:

- **If solo mode:** "CONTRIBUTING.md is available if you later add collaborators — just run /init again."
- **If no git:** "Consider initializing git (`git init`) to get the most from your decision and changelog history."
- **For any project:** "This scaffold follows progressive disclosure — start with these files and add more structure as your project grows. You can re-run /init anytime to fill gaps."

## Edge Cases

### User runs /init in a fully scaffolded repo
Report: "This project already has all agentic scaffold files. Nothing to add." Then offer to audit existing files against current best practices.

### User runs /init in montymerlinHQ or another knowledge garden
Detect the presence of SOUL.md, STYLE.md, or journal/ directories. Report: "This looks like a knowledge garden with its own established structure. The agentic scaffold is designed for code repos and projects — it might conflict with your existing setup. Want to proceed anyway, or would you like to scaffold a specific sub-project instead?"

### User runs /init inside a Cowork plugin directory
Detect .claude-plugin/ directory. Adapt: plugin repos have different conventions. Adjust CLAUDE.md template to reference plugin.json, SKILL.md patterns, and packaging conventions.

### Target directory has no write access
Report the error clearly and suggest an alternative location.
