# 04 — Ticket review and fix loop

**What to build:** Every ticket's diff is reviewed before the ticket counts as done. The Operator:

1. Writes the brief and a review package (commits, stat, full diff) to files, so diffs never enter the Operator's context.
2. Dispatches a fresh Ticket reviewer, a plugin agent on Sonnet. The reviewer returns two verdicts: spec compliance (missing / extra / misunderstood / cannot verify from diff) and quality findings graded Critical / Important / Minor. It cites file:line, does not trust the Implementer's report, and does not re-run the full suite.
3. Starts a fix loop when there are Critical or Important findings or a spec failure:
   - Rounds 1–3 resume the same Implementer; rounds 4–5 use a fresh Implementer on Opus.
   - The fixer checks feedback against the code before applying it.
   - Each round ends with a scoped re-review marking every finding ADDRESSED or NOT ADDRESSED.
4. Defers Minor findings to the Ledger.
5. Records a ticket still failing after round 5 as an open Checkpoint item in the Ledger, and continues with the other tickets.

Operator prompts never pre-judge findings.

**Blocked by:** 02

**Status:** done

- [x] Every done ticket has a recorded Ticket review verdict in the Ledger
- [x] Brief, report and review package are passed as files
- [x] Critical/Important findings trigger fix rounds; Minor findings appear as deferred in the Ledger
- [x] Model escalation happens at round 4; the loop never exceeds 5 rounds
- [x] A ticket exhausting its rounds becomes an open Checkpoint item while other tickets continue
- [x] Eval case "fix loop" (a ticket whose spec contains a trap the reviewer should catch) passes

## Comments

- The Ticket reviewer is `agents/ticket-reviewer.md` (Sonnet, `cwi-skills:ticket-reviewer`): spec verdict (Missing / Extra / Misunderstood / Cannot verify), quality findings graded Critical / Important / Minor with `path:line`, re-review marks ADDRESSED / NOT ADDRESSED, final line `VERDICT: ...`. The loop is the "Review and fix loop" section of `skills/sdd/SKILL.md`; the Implementer's "Fix rounds" section makes it check each finding and fix or dispute it.
- A ticket that passes verification gets the Ledger outcome `in review` until its verdict is `PASS`, so an interrupted run resumes at the review. Fix rounds add `fix: ... (ticket NN, review round F)` commits, so a reviewed ticket can own more than one commit; its status names the last one and its Ledger row the range.
- Eval: `evals-e2e/fix-loop/` (needs Bash, like the other e2e cases). Verified with headless runs; details in the spec's "Build notes (ticket 04)".
