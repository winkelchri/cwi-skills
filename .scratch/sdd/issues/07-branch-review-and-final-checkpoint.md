# 07 — Branch review and final Checkpoint

**What to build:** Once every ticket is done, the Operator dispatches a Branch review: `mattpocock-skills:code-review` on Opus against the feature branch's base.

- **Findings become tickets.** Each finding is filed as a new ticket that continues the numbering, with `Type: bug` and `Found by: branch review`.
  - Unambiguous findings are filed `ready-for-agent`; judgement calls are filed `ready-for-human`.
  - These tickets go through the normal per-ticket loop, followed by a single re-review.
- **Final Checkpoint.** It shows:
  - a run summary
  - every Ruling
  - the deferred Minor findings, from which the developer picks any to become tickets for one more wave

  Push, PR creation and cleanup of `prototype/*` branches and worktrees are offered as options and never performed automatically.

**Blocked by:** 04, 05

**Status:** ready-for-agent

- [ ] The Branch review runs once all tickets are done, using `code-review` by reference on Opus
- [ ] Findings are filed as bug tickets with correct triage status and `Found by: branch review`
- [ ] Exactly one re-review follows the fix wave
- [ ] The final Checkpoint lists the summary, all Rulings and deferred Minors
- [ ] No push, PR or deletion happens without an explicit choice
- [ ] The "happy path" eval case, extended to assert the Branch review ran, passes
