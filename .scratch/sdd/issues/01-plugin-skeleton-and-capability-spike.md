# 01 — Plugin skeleton and capability spike

**What to build:** This repo installs as a local Claude Code plugin through its own local marketplace, so later tickets have somewhere to put the `/sdd` skill and its agents. The ticket also answers the open questions the design depends on:

- whether a plugin agent can invoke a mattpocock-skills skill by name through the Skill tool
- whether `AskUserQuestion` and `PushNotification` work inside a headless `claude plugin eval` run

Record the answers in the spec's Further Notes. If calling by name fails, extend ADR-0001 so that model-invocable upstream skills are also read by path.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] The plugin manifest and local marketplace manifest validate with `claude plugin validate`
- [ ] The plugin installs from this repo via the local marketplace and shows up as installed
- [ ] A throwaway plugin agent was dispatched and the result of its attempt to invoke `mattpocock-skills:tdd` by name is recorded (works / fails, with exact error)
- [ ] A minimal `claude plugin eval` case runs, and the behaviour of `AskUserQuestion` and `PushNotification` in headless runs is recorded
- [ ] The spec's Further Notes (and ADR-0001 if needed) reflect the findings
- [ ] Throwaway spike artifacts are removed or clearly marked as fixtures
