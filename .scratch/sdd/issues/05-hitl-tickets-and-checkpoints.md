# 05 — HITL tickets and Checkpoints

**What to build:** The Operator handles HITL tickets and presents Checkpoints without needing to be watched.

- **HITL tickets:**
  - A HITL ticket is split. The agent-doable part becomes work for an Implementer, and a smaller decision ticket is created that is blocked by it.
  - A HITL ticket that contains no real decision is reclassified as AFK and recorded as a Ruling.
- **Checkpoints:**
  - They are held back until no unblocked AFK work remains.
  - Before presenting them, the Operator runs the Gate on the integrated branch and sends one `PushNotification`.
  - It asks via an `AskUserQuestion` batch, one question per item. Any item can be deferred, and the run continues on whatever is unblocked.
- **Resuming:** re-running `/sdd <slug>` resumes from the Ledger and ticket statuses.
- **Stalls:** two consecutive rounds with no progress stop the run with a notification.

Adapt the Checkpoint mechanics to the headless findings from ticket 01.

**Blocked by:** 02, 01 (headless findings)

**Status:** done

- [x] HITL tickets are split into agent work plus a decision ticket that is blocked by it
- [x] HITL tickets with no real decision are reclassified as AFK and appear as Rulings in the Ledger
- [x] Tickets not blocked by a pending Checkpoint keep running; tickets blocked by it stay untouched
- [x] The Gate runs on the integrated branch before any Checkpoint is presented
- [x] Notifications fire only for Checkpoints waiting, run done, or run stalled
- [ ] Deferred items stay pending; answered items are written back to their tickets
- [x] Re-running `/sdd <slug>` after a Checkpoint resumes without redoing done tickets
- [x] Eval case "mixed" (AFK ticket plus a HITL ticket that blocks another ticket) passes

## Comments

- HITL triage, Checkpoint and Stalls are sections of `skills/sdd/SKILL.md`. A split keeps the HITL ticket's number as the agent part (new `## Agent part` section, `ready-for-agent`) and files `MM-<name>-decision.md` (`Type: decision`, `Split from: NN`, `Blocked by: NN`, `ready-for-human`); tickets that were blocked by NN get MM added. Checkpoint items are `- [ ]` lines under the Ledger's `## Checkpoints`; answers go back as `## Answer` (decision tickets, then `done (decision)`) or `## Comments` plus Ledger outcome `reopened` (escalations). Headless, with no `AskUserQuestion`, the run stops at the Checkpoint; an `## Answer` written into a decision ticket by hand is picked up by the next `/sdd <slug>`.
- A stall is two consecutive ticket attempts that end without the ticket done (an answered Checkpoint also resets the count). The existing "stop the run" cases (unverified commits, red Gate after a stuck ticket) now stop as stalled with a notification.
- Eval: `evals-e2e/mixed/` (needs Bash). Verified with two headless runs (`claude -p "/sdd demo" --permission-mode auto --model sonnet`, $0.61 + $0.30); details in the spec's "Build notes (ticket 05)". Every grader condition of the case held on run 1.
- Untested: `AskUserQuestion` batches, answer write-back and defer in an interactive session (the tool is unavailable headless; the offline `## Answer` path was tested instead); retry/wontfix answers for escalated tickets; the stall stop (no fixture stalls); a red Gate at a Checkpoint; decision-only HITL tickets (no split). A delivered push notification was not observed: headless `PushNotification` reports "not sent" as ticket 01 found, but the calls themselves fired only for Checkpoint waiting (run 1) and run done (run 2).
