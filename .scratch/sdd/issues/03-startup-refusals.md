# 03 — Startup refusals

**What to build:** `/sdd` refuses to start in situations where an unattended run would fail or mislead:

- **Permission mode would prompt:** it refuses with guidance pointing to auto mode or the documented allowlist. The plugin documents that allowlist (edits, git, Gate commands) as the fallback for projects not run in auto mode.
- **Gate already red:** it aborts before any work, so failures from new work can't be confused with existing ones.
- **Folder is neither a ticket set nor a wayfinding map:** it stops and names the planning skills to run first.

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] A run in a permission mode that would prompt refuses before any dispatch, with actionable guidance
- [ ] The allowlist fallback is documented in the plugin
- [ ] A red Gate at start aborts with no commits and no ticket status changes
- [ ] A folder with neither tickets nor `map.md` produces an error naming `/to-spec`, `/to-tickets` or `/wayfinder`
- [ ] Eval case "preflight refusal" passes
