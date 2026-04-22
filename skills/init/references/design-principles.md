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

**How to apply:**
- When a user challenges a default ("why this format?"), cite the source rather than the preference
- When adding new defaults (future versions), require a documented source — no undefended choices
