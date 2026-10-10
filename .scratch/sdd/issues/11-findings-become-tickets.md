# 11 — Every review finding becomes a scheduled ticket

**Type:** feature
**Blocked by:** 04, 07

**Status:** ready-for-agent

**What to build:** Review findings no longer wait in `## Deferred findings` for the human. Every finding becomes a ticket that the Operator schedules like any other. The developer chose this on 2026-10-10, superseding spec stories 18, 39 and 45 where they conflict.

- **Ticket review.** Critical, Important and spec failures still go to the fix loop on the same ticket. Minor findings and `Cannot verify` lines each become a new ticket (`Type: bug`, `Found by: ticket review NN`, `Finding:` naming the review file and line, `Blocked by: NN`, `ready-for-agent`). Exception, to bound the loop: a ticket that was itself filed from a review (it has a `Found by:` line) files no tickets for its own Minor / `Cannot verify` findings. They go into `## Deferred findings` and the next Branch re-review covers them.
- **Branch review.** Minor findings become tickets too (`ready-for-agent`), next to the unambiguous and judgement ones that already do.
- **Re-review until clean, max 3.** After each fix wave the Branch reviewer runs again over the whole branch. Its new findings, its Minors, and every NOT ADDRESSED mark whose ticket is done become the next wave's tickets (`Found by: branch re-review K`). It stops when a re-review returns no findings at all, or after the 3rd re-review. Findings left after the 3rd go to `## Deferred findings`, and only those are offered at the Final Checkpoint.
- **Ledger.** The `Branch review:` line records the round (`filed MM–NN, round K`, `clean after K re-reviews`, `capped after 3 re-reviews`), so a resumed run continues the right round.
- **No separate plan file.** Tickets' `Status:` lines plus the Ledger remain the worklog.

**Acceptance criteria**

- [ ] A ticket review's Minor finding produces a new `ready-for-agent` ticket blocked by the reviewed ticket, and the run builds it
- [ ] A finding ticket's own Minors are deferred, not filed
- [ ] Branch review Minors become tickets
- [ ] The Branch reviewer re-runs after each wave until a review is clean, at most 3 re-reviews; leftovers reach the Final Checkpoint
- [ ] `evals-e2e/branch-review` and `evals-e2e/fix-loop` updated to the new behaviour and passing in a headless run
