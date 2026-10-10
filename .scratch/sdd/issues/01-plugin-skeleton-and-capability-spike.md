# 01 — Plugin skeleton and capability spike

**What to build:** This repo installs as a local Claude Code plugin through its own local marketplace, so later tickets have somewhere to put the `/sdd` skill and its agents. The ticket also answers the open questions the design depends on:

- whether a plugin agent can invoke a mattpocock-skills skill by name through the Skill tool
- whether `AskUserQuestion` and `PushNotification` work inside a headless `claude plugin eval` run

Record the answers in the spec's Further Notes. If calling by name fails, extend ADR-0001 so that model-invocable upstream skills are also read by path.

**Blocked by:** None — can start immediately.

**Status:** done

- [x] The plugin manifest and local marketplace manifest validate with `claude plugin validate`
- [x] The plugin installs from this repo via the local marketplace and shows up as installed
- [x] A throwaway plugin agent was dispatched and the result of its attempt to invoke `mattpocock-skills:tdd` by name is recorded (works / fails, with exact error)
- [x] A minimal `claude plugin eval` case runs, and the behaviour of `AskUserQuestion` and `PushNotification` in headless runs is recorded
- [x] The spec's Further Notes (and ADR-0001 if needed) reflect the findings
- [x] Throwaway spike artifacts are removed or clearly marked as fixtures

## Comments

Spike answers (Claude Code 2.1.296; full notes in the spec's Further Notes, "Spike findings"):

- **Plugin agent invoking `mattpocock-skills:tdd` by name: works.** A throwaway plugin agent dispatched as `cwi-skills:spike-skill-caller` called the Skill tool with `mattpocock-skills:tdd` and got the skill text back (`# Test-Driven Development`). User-only skills (`implement`, `wayfinder`, `to-spec`, `to-tickets`, `triage`) do not appear in its skill listing. ADR-0001 is unchanged.
- **`AskUserQuestion` headless: unavailable** in `claude plugin eval`, even when listed in `allowed_tools`; `ToolSearch` finds nothing. Same in `claude -p`.
- **`PushNotification` headless: unavailable** in `claude plugin eval`, even with `--allow-tools PushNotification` (without it the run reports `not granted`). In `claude -p` it can be called but returns `Not sent — this terminal is active, ...`.
- **Result:** Checkpoint eval cases grade "stopped at a Checkpoint and recorded it in the Ledger" (the spec's headless caveat).
- **Install:** `claude plugin marketplace add /home/chris/devel/cwi-skills` then `claude plugin install cwi-skills@cwi-skills`. `claude plugin list` shows `cwi-skills@cwi-skills`, version 0.1.0, user scope, enabled, read from the repo.
- **Spike artifacts:** the spike agent was deleted. `evals/spike-headless-tools/` stays as a marked probe fixture (1 run, ~$0.05).
