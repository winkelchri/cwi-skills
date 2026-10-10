# 03 — Startup refusals

**What to build:** `/sdd` refuses to start in situations where an unattended run would fail or mislead:

- **Permission mode would prompt:** it refuses with guidance pointing to auto mode or the documented allowlist. The plugin documents that allowlist (edits, git, Gate commands) as the fallback for projects not run in auto mode.
- **Gate already red:** it aborts before any work, so failures from new work can't be confused with existing ones.
- **Folder is neither a ticket set nor a wayfinding map:** it stops and names the planning skills to run first.

**Blocked by:** 02

**Status:** done

- [x] A run in a permission mode that would prompt refuses before any dispatch, with actionable guidance
- [x] The allowlist fallback is documented in the plugin
- [x] A red Gate at start aborts with no commits and no ticket status changes
- [x] A folder with neither tickets nor `map.md` produces an error naming `/to-spec`, `/to-tickets` or `/wayfinder`
- [x] Eval case "preflight refusal" passes

## Comments

- Permission check: the plugin hook `hooks/sdd-permission-preflight.sh` (`hooks/hooks.json`, `UserPromptExpansion`, matcher `cwi-skills:sdd`). It is the only place the live permission mode is visible; the model cannot see it. It blocks `/sdd <slug>` before the Operator starts in plan mode, and in Manual or acceptEdits mode unless the allowlist (`Edit`/`Write` for Manual, `Bash(git commit:*)`) is in the project or user settings. `auto`, `bypassPermissions` and `dontAsk` pass (`dontAsk` denies rather than prompts, and eval runs use it). On the allowlist path the hook hands the allowed Bash entries to the Operator, which refuses if a Gate command is not covered.
- Allowlist fallback: `skills/sdd/permissions.md`.
- Red Gate and unplanned folder: new Startup order in `skills/sdd/SKILL.md`. The folder check moved ahead of the Gate (cheapest refusal first); the branch switch moved after the green Gate, so a red Gate leaves the repo untouched.
- Evals: `evals/not-planned` (default suite, passes); `evals-e2e/preflight-refusal` (red Gate, needs Bash, so outside the default suite). Headless evidence in the spec's "Build notes (ticket 03)".
