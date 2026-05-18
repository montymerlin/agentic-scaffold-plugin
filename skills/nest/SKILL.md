---
name: nest
description: >
  Scaffold folder-level AGENTS.md plus a TEMPLATE.md exemplar inside a subdirectory of an
  already-scaffolded repo. Use when the user asks to "nest agents", "add folder rules",
  "scaffold a subfolder", "add nested instructions", "set up modules folder", "add a
  template for this folder", "add folder-level agents.md", "scaffold folder", "nest in
  this folder", or wants to specialize agent rules for a specific subdirectory.
  Complements `agentic-scaffold:init`, which scaffolds the root layer only.
---

# nest — Folder-level Agentic Scaffold

Scaffold the second and third layers of the three-layer instruction pattern inside a specific subdirectory: folder-level `AGENTS.md` (specialization of root rules) plus `TEMPLATE.md` (the concrete shape files in this folder should imitate). Produces the pair the agent expects: announcement + demonstration. Either alone is weaker than the two together.

**Relation to `agentic-scaffold:init`:** `init` creates the root scaffold. `nest` adds folder-level layers on top of it. Run `init` first if the repo has no root `AGENTS.md`.

> **Design rationale & invariants:** Set `AGENTIC_SCAFFOLD_ROOT="${AGENTIC_SCAFFOLD_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_HOME:-$HOME/.codex}/vendor_imports/repos/agentic-scaffold-plugin}}"`. Read `${AGENTIC_SCAFFOLD_ROOT}/skills/init/references/design-principles.md` (especially Principle 7: *Rules live at the narrowest scope where they apply*) before generating folder-level files, modifying templates, or defending architectural choices. Decision 014 in `DECISIONS.md` authorizes this skill.

## When to use this skill

The right time to nest is when a folder either already contains, or will contain, **a handful of files that share a recognizable shape**. Examples:

- Workshop modules with a common structure (title, prerequisites, walkthrough, exercise, takeaway)
- Research notes that always cite primary sources in a standard section
- Decision records following an ADR format
- API endpoint specs with consistent request/response documentation
- Monorepo packages with package-specific build, test, and lint conventions

If a folder contains miscellaneous files with no shared shape, folder-level rules can still help (naming, what belongs, what doesn't), but `TEMPLATE.md` may not — the skill can scaffold `AGENTS.md` only in that case.

## Step 1: Detect & Orient

Verify the prerequisites and gather context about the target folder.

```bash
# Confirm root scaffold exists — nest assumes a root AGENTS.md
[ -f "AGENTS.md" ] && echo "ROOT_AGENTS: present" || echo "ROOT_AGENTS: missing"

# Inspect the target folder
TARGET="${TARGET:-}"  # set by user input or by skill from prompt
[ -d "$TARGET" ] && echo "TARGET_DIR: $TARGET exists" || echo "TARGET_DIR: $TARGET — will create"

# Check for existing folder-level scaffold
[ -f "$TARGET/AGENTS.md" ] && echo "FOLDER_AGENTS: present" || echo "FOLDER_AGENTS: missing"
[ -f "$TARGET/TEMPLATE.md" ] && echo "FOLDER_TEMPLATE: present" || echo "FOLDER_TEMPLATE: missing"

# Sample existing files in the target folder for inference
[ -d "$TARGET" ] && ls -la "$TARGET" | head -20
[ -d "$TARGET" ] && find "$TARGET" -maxdepth 1 -type f -name "*.md" | head -5
```

If `ROOT_AGENTS` is missing, halt and suggest `agentic-scaffold:init` first. The folder layer assumes a root layer.

If `FOLDER_AGENTS` is already present, switch to gap-analysis mode (Step 4) — don't overwrite.

## Step 2: Ask the right questions

Use the AskUserQuestion tool. Keep it tight — three questions maximum, fewer if the environment answers them.

1. **Which folder?** (Required if not already specified in the user's prompt. Default suggestion: any existing subdirectory that looks like a content folder — multiple `.md` files of similar shape, or named like `modules/`, `sessions/`, `notes/`, `packages/<name>/`, etc.)

2. **What kind of files live here?** (One short phrase. "Workshop modules", "research notes", "API endpoint specs", "session writeups", "ADR-style decisions". This phrase seeds both the folder-level `AGENTS.md` description and the `TEMPLATE.md` header.)

3. **What sections should every file in this folder have?** (List the standard sections — e.g., "title, why it matters, prerequisites, walkthrough, exercise, takeaway, further reading". The skill uses this to generate `TEMPLATE.md`. If the user says "I don't know yet" or the folder mixes types, skip generating `TEMPLATE.md` and proceed with `AGENTS.md` only.)

If the user has already given enough information in the initial prompt, present inferences for confirmation rather than re-asking. Match the inference style of `agentic-scaffold:init`.

## Step 3: Read root AGENTS.md before generating

This is critical. The folder-level `AGENTS.md` must *specialize*, not duplicate, the root rules. Read the existing root `AGENTS.md` and identify rules that are already covered there. The generated folder file should not restate them.

```bash
# Pull the section headings from root for cross-checking
grep -nE "^#{1,3} " AGENTS.md
```

Note specifically which of these the root already covers, so the folder file can omit them:
- Naming conventions (if root has general conventions, folder only adds folder-specific naming)
- Documentation rules (if root covers README/AGENTS/CLAUDE/CHANGELOG, folder doesn't repeat)
- Agent boundaries (root's Do/Don't usually applies; folder adds folder-specific additions only)

If the folder genuinely needs to override a root rule rather than just add to it, surface that explicitly in the generated file (e.g., "Overrides root convention X because Y") and suggest logging a decision in `DECISIONS.md`.

## Step 4: Generate

Load templates and interpolate.

| Template | Becomes | When |
|----------|---------|------|
| `templates/folder-AGENTS.md.tmpl` | `<TARGET>/AGENTS.md` | Always (unless folder already has one) |
| `templates/TEMPLATE.md.tmpl` | `<TARGET>/TEMPLATE.md` | When user provided file shape in Step 2 question 3 |

### Variables to interpolate

| Variable | Source |
|----------|--------|
| `{{folder_path}}` | User's answer to question 1 (e.g., `modules`) |
| `{{folder_purpose}}` | User's answer to question 2 (e.g., "Workshop modules") |
| `{{file_kind}}` | Singular of `{{folder_purpose}}` (e.g., "module") |
| `{{file_sections}}` | User's answer to question 3, structured as a list |
| `{{naming_convention}}` | Inferred from existing files or asked (default: `NNN-topic.md` for content folders, no convention enforced for mixed) |
| `{{root_path}}` | Relative path from folder back to root (typically `..`) |
| `{{date}}` | Today's date in YYYY-MM-DD format |

### For gap-analysis mode (folder AGENTS.md already exists)

- Never overwrite
- If only `AGENTS.md` exists and the user wants a `TEMPLATE.md`, generate just the template
- If both exist, run a brief audit instead: are the files consistent with each other? Does the folder AGENTS.md duplicate root rules? Surface findings to the user but do not write changes.

## Step 5: Present & Approve

Before writing, show the user what will be generated:

```
Here's what I'll scaffold for `{{folder_path}}/`:

- {{folder_path}}/AGENTS.md — folder-scoped rules: naming, scope, what belongs/doesn't,
  pointer to TEMPLATE.md. ~40 lines.
- {{folder_path}}/TEMPLATE.md — exemplar shape for {{file_kind}} files, with the
  sections you described. Includes "delete these notes when copying" comments.

Notes:
- The folder AGENTS.md will NOT restate rules already in root AGENTS.md (Naming, Documentation, Agent Boundaries — root covers these).
- Folder-level AGENTS.md is lazy-loaded in Claude Code (enters context when the agent
  reads a file inside this folder) and eagerly loaded in Codex. The generated file
  surfaces this distinction so future readers know which timing applies.

Create these files?
```

**GATE: Do not write any files until the user approves.**

## Step 6: Write

After approval:

1. Create the target folder if it doesn't exist
2. Write `<TARGET>/AGENTS.md` from `folder-AGENTS.md.tmpl`
3. Write `<TARGET>/TEMPLATE.md` from `TEMPLATE.md.tmpl` (if applicable)
4. Do NOT run `git add` or `git commit` — let the user decide when to commit

After writing, confirm and suggest next steps:

```
Scaffold complete for `{{folder_path}}/`:
- {{folder_path}}/AGENTS.md
- {{folder_path}}/TEMPLATE.md

Next steps:
- Open TEMPLATE.md and refine the section descriptions to match what you actually want
- If a real example file already exists in this folder, the template will work better
  paired with that file — agents imitate concrete artifacts more reliably than stubs
- When adding new files to this folder, prompt with "copy TEMPLATE.md and adapt"
  rather than describing the shape from memory
- Consider running /repo-audit to check the new layered structure for consistency
```

## Step 7: Offer Extras

After the folder scaffold lands, suggest:

- **Log a decision.** "This is a structural change worth recording — want me to add a decision entry to DECISIONS.md noting that `<folder>/` now has its own scaffold and why?"
- **`.claude/rules/` complement.** If Claude Code is detected (`.claude/` directory present) and the folder has a strong path pattern, mention: "You can also pin a path-scoped rule under `.claude/rules/` so the file shape is enforced regardless of cwd. Useful when the agent often works from project root."

## Edge Cases

### Folder doesn't exist yet
Create it. Empty folder + new `AGENTS.md` + `TEMPLATE.md` is a valid starting state.

### Folder has files but no shared shape
Generate `AGENTS.md` only. Skip `TEMPLATE.md`. Note in `AGENTS.md` that files in this folder are heterogeneous — folder rules cover scope and naming, not shape.

### Root AGENTS.md missing
Halt. Suggest running `agentic-scaffold:init` first to lay the root layer.

### User wants to nest at root level (`./`)
Reject politely. Root is `init`'s job. The nest skill specifically scaffolds *below* root.

### Folder is itself a git submodule
Warn the user — instruction files inside a submodule live in a separate repo and may not be picked up by the parent. Suggest scaffolding in the submodule repo directly.

### Multi-level nesting (e.g., `packages/frontend/components/`)
Supported. The skill walks the path and asks whether intermediate folders also need their own `AGENTS.md`. Default: skip intermediates unless they have their own shared shape.

<!-- Authorized by Decision 014. See DECISIONS.md and skills/init/references/design-principles.md Principle 7. -->
<!-- Sources: Anthropic Claude Code memory docs, OpenAI Codex AGENTS.md guide, agents.md cross-host spec, GitHub 2,500-repo analysis -->
