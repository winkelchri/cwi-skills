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

**Status:** done

- [x] The Branch review runs once all tickets are done, using `code-review` by reference on Opus
- [x] Findings are filed as bug tickets with correct triage status and `Found by: branch review`
- [x] Exactly one re-review follows the fix wave
- [x] The final Checkpoint lists the summary, all Rulings and deferred Minors
- [x] No push, PR or deletion happens without an explicit choice
- [ ] The "happy path" eval case, extended to assert the Branch review ran, passes

## Comments

- Built: `agents/branch-reviewer.md` (Opus), the Branch review, Re-review and Final Checkpoint sections of `skills/sdd/SKILL.md`, a HITL-triage case for judgement bugs, the new `evals-e2e/branch-review` case, and Branch review graders in `evals-e2e/happy-path`. Evidence is in the spec's "Build notes (ticket 07)".
- Happy-path box left unticked: Bash-granting eval cases cannot run on this machine. A headless run of the happy-path fixture met every grader by hand: 3 done tickets, 3 ticket commits in order 02, 03, 01, Gate green, the Branch reviewer dispatched, `code-review` loaded and `branch-review-0.md` written. `evals-e2e/branch-review` was likewise checked only by headless runs, on its older spec.
- Not exercised: picking deferred findings or actions through `AskUserQuestion` at the Final Checkpoint, so push, PR and cleanup were never run; resuming at `filing`; a clean Branch review with zero findings; the "stay `filed` when there are no fix commits" rule added after the last run; the Branch reviewer stall path; a bug ticket built on an answered split decision.

- implement-loop: closed by commit 937d688 (gate green: validate ok, default eval suite 3/3). Note: Final Checkpoint runs push/PR/cleanup when the human picks them via AskUserQuestion; spec said offer without performing. Last-minute "filed" Ledger change not run headless.
