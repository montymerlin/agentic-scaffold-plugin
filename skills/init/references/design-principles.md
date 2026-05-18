# Design Principles & Invariants — agentic-scaffold

Load this file when generating AGENTS.md, modifying templates, logging decisions, or defending architectural choices. SKILL.md encodes *what* to do; this file encodes *why* and the invariants the skill must preserve.

## 1. AGENTS.md has a ~150-line budget

Generated AGENTS.md files should stay under ~150 lines. Agents lose focus when root instruction files grow long, and every token loaded at session start is a token unavailable for the actual task.

**Source:** HumanLayer's CLAUDE.md best practices (built on Anthropic's Claude Code memory system), reinforced by Anthropic's Agent Skills architecture which uses progressive disclosure (metadata → instructions → nested files) to keep root-level context small.

**How to apply:**
- When interpolating `AGENTS.md.tmpl`, keep `{{directory_structure}}` and `{{stack_conventions}}` concise
- If a generated AGENTS.md would exceed ~150 lines, push detail into referenced files rather than inlining it
- Flag bloat to the user: "Your AGENTS.md is getting long — consider splitting X into a referenced file"

## 2. DECISIONS.md entries are written BEFORE implementation

The discipline that makes ADRs valuable is timing: articulate reasoning while the outcome is still uncertain, not retroactively when rationalization is easy.

**Source:** Michael Nygard's 2011 ADR proposal, extended by Keeling and Runde in IEEE Software.

**How to apply:**
- When the user is about to make an architectural change (tool choice, convention shift, structural refactor), proactively suggest logging a decision first
- The seeded "Decision 001: Adopted agentic scaffold" demonstrates the format — reference it as the pattern
- If the user says "let me just try it and see" for a structural choice, gently push back: "Worth logging the alternatives before you commit, even if you change it later"

## 3. Every template carries a source attribution footer

Each file in `templates/` ends with a comment attributing the design sources that informed it. This is a plugin invariant — preserve it when editing templates.

**How to apply:**
- When modifying a template, keep the existing `<!-- Source: ... -->` footer or extend it
- When adding a new template, include a footer citing the convention(s) it draws from
- If asked "why this structure?", the footer is your first reference

## 4. The ROADMAP → DECISIONS pipeline is an emerging convention we defined

This plugin introduced the pattern that roadmap items don't disappear when resolved — they move to the "Decided" section with a pointer to the DECISIONS.md entry. It is not established convention elsewhere.

**Source:** Decision 006 in this plugin's own DECISIONS.md.

**How to apply:**
- Defend the pattern if users push back ("why not GitHub Issues?"): portability, agent-readability, and an auditable trail from inspiration to decision
- When scaffolding, briefly explain the pipeline so users understand the "Decided" section isn't just an archive
- Parking lot items stay in ROADMAP.md — only evaluated items graduate to DECISIONS.md

## 5. Core vs adaptive split is grounded in progressive disclosure

Core files (README, AGENTS.md, CLAUDE.md wrapper, CHANGELOG, DECISIONS, ROADMAP) are universally valuable. Adaptive files (.cursorrules, .claude/settings.local.json, CONTRIBUTING.md) are tool- or team-specific. Generating adaptive files for users who don't need them violates progressive disclosure — it creates noise and maintenance burden.

**Source:** Decision 007 in this plugin's own DECISIONS.md.

**How to apply:**
- Resist "just in case" adaptive file generation — if tooling isn't detected and the user hasn't stated it, don't generate
- Don't ask about tooling when signals are present (.cursorrules, .claude/ directory)
- If a user asks "should I also add CONTRIBUTING.md?" for a solo project, explain the principle: adaptive files earn their place when the tooling or team context is real

## 6. Source-grounded defaults

Every template choice traces to a documented source — not personal preference. This is what distinguishes this scaffold from an opinionated template pack.

**Key sources to cite when defending choices:**
- README.md structure → GitHub's README guidelines
- Canonical agent-file format → Anthropic's Claude Code memory system + HumanLayer best practices, adapted to AGENTS.md canon
- DECISIONS.md format → Michael Nygard's ADR proposal
- ROADMAP.md parking lot → agile practice (Aha! Roadmaps) + YAGNI (Martin Fowler)
- Narrative CHANGELOG → adapted from keep-a-changelog, shifted to narrative style
- Progressive disclosure → Steve Krug, Nielsen Norman Group, Anthropic Agent Skills
- Three-layer instruction pattern → Anthropic Claude Code memory docs, OpenAI Codex AGENTS.md guide, agents.md cross-host spec, GitHub's 2,500-repo analysis

**How to apply:**
- When a user challenges a default ("why this format?"), cite the source rather than the preference
- When adding new defaults (future versions), require a documented source — no undefended choices

## 7. Rules live at the narrowest scope where they apply

The generated scaffold is the *root layer* of a potentially layered instruction tree. Project-wide rules belong in root `AGENTS.md`. Rules that only apply inside a specific folder belong in that folder's `AGENTS.md`. Concrete shapes that files in a folder should imitate belong in a `TEMPLATE.md` alongside the folder's `AGENTS.md`. This layered model is documented as best practice by both Anthropic (Claude Code memory docs) and OpenAI (Codex AGENTS.md guide), and is honoured by the cross-host agents.md spec used by 60,000+ open-source projects.

The rationale rests on three findings. First, root files load into every session, so every rule placed there competes with every other rule for the agent's attention and consumes tokens — keeping root tight improves adherence to the rules that do live there. Second, GitHub's analysis of 2,500 real `AGENTS.md` files found that *"language models are pattern-followers more than rule-followers"*: a concrete `TEMPLATE.md` an agent can copy and adapt produces more consistent output than a list of stylistic rules in prose. Third, scope-specific rules in a global file create silent conflicts as the project grows — moving them down keeps each scope self-consistent.

**Source:** Anthropic's [Claude Code memory docs](https://code.claude.com/docs/en/memory), OpenAI's [Codex AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md), the [agents.md spec](https://agents.md/) (Linux Foundation / Agentic AI Foundation), and [GitHub's analysis](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/) of 2,500 `AGENTS.md` files. Authorized by Decision 014.

**How to apply:**
- When generating root `AGENTS.md`, keep its conventions project-wide. If a rule references a specific folder or subsystem, that's a signal it belongs in a nested `AGENTS.md` instead. Suggest the `nest` skill.
- When the user adds folder-specific rules to root, gently push back: "This rule only applies to `<folder>/` — consider scaffolding `<folder>/AGENTS.md` so root stays focused."
- When the user describes the shape of files in a folder ("research notes always have these sections"), propose a `TEMPLATE.md` rather than describing the shape in `AGENTS.md`. Templates demonstrate; rules describe; the demonstration is what the agent imitates.
- **Caveat to communicate.** Folder-level `AGENTS.md` is lazy-loaded in Claude Code (enters context only when the agent reads a file inside that folder) and eagerly loaded in OpenAI Codex (from project root down to cwd). When generating folder-level scaffolding, surface this distinction in the file itself so future readers — human or agent — know which timing applies to their host.
- **Complement to know about.** For Claude Code specifically, `.claude/rules/*.md` with `paths:` frontmatter triggers on file pattern rather than directory location. Useful when a rule must fire regardless of cwd. Generate as an adaptive file when Claude Code is detected; document but don't force.
