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

**Status:** ready-for-agent

- [ ] HITL tickets are split into agent work plus a decision ticket that is blocked by it
- [ ] HITL tickets with no real decision are reclassified as AFK and appear as Rulings in the Ledger
- [ ] Tickets not blocked by a pending Checkpoint keep running; tickets blocked by it stay untouched
- [ ] The Gate runs on the integrated branch before any Checkpoint is presented
- [ ] Notifications fire only for Checkpoints waiting, run done, or run stalled
- [ ] Deferred items stay pending; answered items are written back to their tickets
- [ ] Re-running `/sdd <slug>` after a Checkpoint resumes without redoing done tickets
- [ ] Eval case "mixed" (AFK ticket plus a HITL ticket that blocks another ticket) passes
