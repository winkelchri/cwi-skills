# Permissions for an unattended `/sdd` run

`/sdd` runs for a long time without you. Any permission prompt in that time stalls the run until you come back, so `/sdd` refuses to start in a session whose permission mode would prompt.

The check is the plugin hook `hooks/sdd-permission-preflight.sh`. It runs when `/sdd <slug>` is expanded, before the Operator starts, and reads the session's live permission mode:

| Mode | `/sdd` |
|---|---|
| `auto`, `bypassPermissions` | starts: nothing prompts |
| `dontAsk` | starts: nothing prompts, anything not allowed is denied (headless and eval runs use this) |
| Manual (`default`) | starts only with the allowlist below, including `Edit` and `Write` |
| `acceptEdits` | starts only with the allowlist below; edits are already accepted |
| `plan` | refuses: plan mode runs nothing |

With the allowlist, the Operator also checks that every Gate command it detects is on it before it runs anything.

## Preferred: auto mode

Start the session in auto mode, or switch to it with Shift+Tab before running `/sdd`:

```sh
claude --permission-mode auto
```

`bypassPermissions` also never prompts, but it turns off every safety check. Use it only in a sandbox.

## Fallback: the allowlist

For a project you don't run in auto mode, allow what a run needs in the project's `.claude/settings.local.json` (personal, not committed) or `.claude/settings.json` (shared); `~/.claude/settings.json` counts too. Then run `/sdd` in Manual or `acceptEdits` mode.

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Read(~/.claude/plugins/**)",
      "Skill(mattpocock-skills:tdd)",
      "Bash(git status:*)",
      "Bash(git switch:*)",
      "Bash(git rev-parse:*)",
      "Bash(git rev-list:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git show:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(npm test:*)"
    ]
  }
}
```

What each group is for:

- **Edits.** `Edit` and `Write`: the Implementer writes product code and tests, and the Operator writes the State files under `.scratch/<slug>/`.
- **Upstream skills.** `Read(~/.claude/plugins/**)` lets agents read user-only mattpocock-skills by path (ADR-0001). `Skill(...)` lets the Implementer load `tdd` by name.
- **Git.** Inspecting history, switching to the `sdd/<slug>` branch, staging and committing. Nothing that pushes, resets or deletes: those stay prompted, as they should.
- **Wayfinding.** A run on a wayfinding map commits nothing and runs no Gate, but its Scouts research. Add `"Skill(mattpocock-skills:research)"`, plus `"WebFetch"` and `"WebSearch"` when the map's research needs the web.
- **Parallel tickets.** `/sdd <slug> --parallel` also merges worktree branches back and resolves conflicts with an upstream skill. Add `"Bash(git merge:*)"`, `"Bash(git worktree:*)"` and `"Skill(mattpocock-skills:resolving-merge-conflicts)"`. Each worktree is a fresh checkout under `.claude/worktrees/`, without ignored files such as installed dependencies, so use it only where the Gate runs in a fresh checkout.
- **Gate.** Replace `Bash(npm test:*)` with this project's Gate commands, one entry each: for example `Bash(npm run typecheck:*)`, `Bash(cargo test:*)`, `Bash(pytest:*)`, `Bash(make check:*)`. The Implementer may also run single test files while it works, so allow your test runner's direct command too (for example `Bash(node --test:*)`).

Do not add `Bash(git push:*)`, `Bash(git reset:*)` or a blanket `Bash`. Push, PR creation and cleanup are offered to you at the end of a run, never done by it.
