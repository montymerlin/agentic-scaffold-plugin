# Roadmap — agentic-scaffold

Where this plugin could go. Items here are aspirations, not commitments. When an item gets evaluated, the outcome is logged in [DECISIONS.md](DECISIONS.md).

**Statuses:** `active` (in progress) · `idea` (worth evaluating) · `parked` (inspiration, no timeline) · `decided` (evaluated — see DECISIONS.md)

---

## Near-term

No active near-term items. See Future explorations for what's next.

## Future explorations

- **Monorepo support** — Workspace-aware scaffolding with shared and per-package conventions. Would need detection of workspaces (npm, pnpm, Cargo, Go modules). `status: idea`
- **API project patterns** — OpenAPI spec pointers, endpoint documentation conventions, request/response examples structure. `status: idea`
- **Knowledge garden scaffold** — Adapted structure for personal knowledge management systems (journal, readings, wisdom directories). Different from code repo patterns. `status: idea`
- **Live dependency threat intelligence** — Scheduled agent queries OSV/NVD for installed package CVEs and cross-references configured tools/services against recent breach reports. Surfaces "you're using X and X was compromised last week." Requires network access and periodic re-running — natural v2 evolution of the `repo-audit` security scan phase. `status: idea`
- **Wire `repo-audit` into `finishing-a-development-branch`** — Add `repo-audit` as an optional pre-step in the superpowers finishing skill so the audit runs automatically before every merge. Requires a documented integration point between the two plugins. `status: idea`
- **Template customization** — User-defined template overrides for organization-specific conventions. Load from a `.agentic-scaffold/` config directory. `status: idea`
- **Thin compatibility wrappers for more hosts** — Extend the `AGENTS.md` canonical pattern beyond Claude and Codex if other host-specific wrapper files emerge. `status: idea`

## Parking lot

- **CLI distribution** — Wrap detection and templating in a standalone script (Python or Node) that runs outside Cowork. No agent required. `status: parked`
- **Cursor-native distribution** — Package as a Cursor extension or .cursor/rules skill for non-Cowork users. `status: parked`
- **GitHub template repo format** — Publish a template repository people can clone directly, as an alternative to dynamic generation. Simpler but less adaptive. `status: parked`
- **Organization presets** — Pre-configured template sets for specific org conventions (e.g., "startup," "research lab," "open source project"). `status: parked`
- **Letta-style context layers** — Separate core memory, archival memory, and working memory as distinct scaffolded concerns. Inspired by Letta's context management. `status: parked`
- **ADR tooling integration** — Interop with existing ADR tools (adr-tools, log4brains) for teams that already have ADR workflows. `status: parked`

## Decided

- **Standalone plugin** — → Decision 001. `status: decided`
- **Smart defaults + edit interaction** — → Decision 002. `status: decided`
- **Progressive disclosure** — → Decision 003. `status: decided`
- **Dual-audience documentation** — → Decision 004. `status: decided`
- **Zero runtime dependencies** — → Decision 005. `status: decided`
- **ROADMAP.md as default scaffolded file** — → Decision 006. `status: decided`
- **Layered file generation (core vs adaptive)** — → Decision 007. `status: decided`
- **Bundle design rationale as on-demand reference** — → Decision 008. `status: decided`
- **Adaptive versioning conventions** — → Decision 009. `status: decided`
- **Add logchange skill (migrated from git-plugin)** — → Decision 010. `status: decided`
- **Dual-distribution packaging with marketplace.json** — → Decision 011. `status: decided`
- **Canonicalize scaffold instructions around AGENTS.md** — → Decision 012. `status: decided`
- **`/scaffold-check` audit skill** — → Decision 013. `status: decided`
