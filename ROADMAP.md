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
- **`/scaffold-check` audit skill** — Review an existing scaffold against current best practices and suggest updates. Could re-run /init in "audit mode." `status: idea`
- **Template customization** — User-defined template overrides for organization-specific conventions. Load from a `.agentic-scaffold/` config directory. `status: idea`

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
