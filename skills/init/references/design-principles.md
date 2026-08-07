# Design Principles & Invariants — agentic-scaffold

Load this file when generating AGENTS.md, modifying templates, logging decisions, or defending architectural choices. SKILL.md encodes *what* to do; this file encodes *why* and the invariants the skill must preserve.

## Why scaffolding exists

Every principle below serves one end: **consistent, high-quality output from a non-deterministic performer.** LLM agents produce different output — and different *quality* — across runs, sessions, and models. The variability is irreducible: it persists even at temperature 0, arising from sampling and from floating-point and batch-variance effects in the inference stack. An agent also starts each session with no memory of the last, and different models behave differently on the same prompt.

Scaffolding is the response. The canonical files, the layered instructions, templates, skills, and workflow files are all **consistency mechanisms** — written, versioned structure that constrains a capable but inconsistent performer toward repeatable results. Skills, workflows, runbooks, playbooks, and checklists are not five separate inventions; they are one idea in different forms — a capability auto-loaded when relevant, a procedure followed on demand, a gate applied inline. This is the checklist tradition — structure as a defence against variability in expert work — applied to AI agents.

**Sources:** LLM non-determinism — [*Non-Determinism of "Deterministic" LLM Settings*](https://arxiv.org/html/2408.04667v5), [*Numerical Sources of Nondeterminism in LLM Inference*](https://arxiv.org/html/2506.09501v2); agent reliability decomposed into consistency / robustness / predictability / safety — [*Towards a Science of AI Agent Reliability*](https://arxiv.org/abs/2602.16666); the checklist tradition — Atul Gawande, *The Checklist Manifesto* (2009).

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
- Workflow files → the runbook / playbook pattern (operations practice adapted for AI agents) — a validated pattern, not a formal standard

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

## 8. Repeatable procedures belong in the repo as workflow files

Some knowledge is neither a project-wide *rule* (which belongs in `AGENTS.md`) nor an agent *capability* (a skill). It is a **procedure** — a recurring, multi-step task that carries judgement and a quality bar: how to update the changelog, how to close out a session, how to run a release. Captured procedures belong in the repo as **workflow files** — versioned, modular markdown the instruction file points to, loaded only when that procedure runs.

This is the runbook / playbook pattern: long-standing operations practice, recently adapted for AI agents. The reasoning: procedures evolve with the project, so they belong in the repo — not a wiki, not an agent's memory; a procedure pulled out of the root instruction file keeps that file lean (progressive disclosure, Principle 3); and a concrete written procedure is followed more consistently than one reconstructed from memory each time (the pattern-follower finding, Principle 7).

**Workflow files vs. skills** — easy to confuse, genuinely different:

| | Skill | Workflow file |
|---|---|---|
| What it is | An agent capability package (`SKILL.md`) | An explicit written procedure |
| Loaded | Automatically, when the agent judges it relevant | On demand, when someone runs the procedure |
| Followed by | The agent | A human or an agent |
| Lives | `.agents/skills/` (host-discovered) | a `workflows/` folder in the repo (a repo artifact) |

They are complementary and increasingly combined — a skill can scaffold a workflow file, and a skill can run one. This plugin's own closeout is the worked example, and it separates the two: `session-closeout` *generates* the workflow, while a thin `closeout` runner vendored into the repo *follows* it (Decision 016). Splitting them is the general lesson — the generator is a toolchain concern that belongs in a plugin, the runner is a repo concern that should ship with the repo so anyone who clones it can invoke the procedure without installing anything.

**Source:** The runbook / playbook pattern — operations heritage, adapted for AI agents. Validated independently across recent practice (e.g. [agent runbooks as on-demand procedural context](https://briantakita.me/posts/agent-runbooks-on-demand-procedural-context/); the [Playbooks](https://docs.runplaybooks.ai/) tooling). **Not** a formal cross-host standard like `AGENTS.md` or Agent Skills — there is no `workflows` spec. Describe it as a validated *pattern*, never overclaim it as a standard.

**How to apply:**
- When a recurring, multi-step, judgement-bearing procedure surfaces, don't inline it into `AGENTS.md` — suggest a workflow file. Most repos start with none and add them only as real procedures recur (progressive disclosure again — don't pre-scaffold a `workflows/` folder a repo hasn't earned).
- A `workflows/` directory (e.g. `.agents/workflows/` or `ops/workflows/`) is the conventional home; a short README there explaining the pattern is worth it once a repo has two or more.
- The `session-closeout` skill scaffolds one workflow file, and vendors the runner that follows it. Generalising `init` to *offer* a `workflows/` folder is a candidate future step — not a default.
- When you do pair a workflow with a runner skill, keep the runner thin and repo-local: resolve the nearest workflow, follow it exactly, hold no procedure of its own. A fat runner duplicates the workflow and the two drift.
