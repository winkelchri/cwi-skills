# cwi-skills

Personal Claude Code plugin. Its centrepiece is `/sdd` (subagent-driven development): a main chat that drives a feature from tickets to reviewed code by delegating work to fresh subagents, pausing for the human where judgement is needed.

## Language

### Roles

**Operator**:
The main chat running `/sdd`. Dispatches subagents, verifies their claims and keeps the State files consistent; never edits product code.
_Avoid_: Orchestrator, controller, main agent

**Implementer**:
A fresh subagent that works one Ticket to a commit and reports a status back to the Operator.
_Avoid_: Worker, coder, child agent

**Ticket reviewer**:
A fresh subagent that performs a Ticket review and returns spec and quality verdicts with severities.
_Avoid_: Code reviewer, checker

**Branch reviewer**:
A fresh Opus subagent that performs the Branch review, or one of its re-reviews, and sorts each finding as unambiguous, a judgement call or Minor.
_Avoid_: Final reviewer

**Scout**:
A fresh Sonnet subagent that resolves one AFK Map ticket (research or task) in wayfinding mode, writes the answer into the ticket, and proposes map updates for the Operator to apply. It changes no code and commits nothing.
_Avoid_: Researcher, wayfinder child

### Tickets

**Ticket**:
One unit of work in `.scratch/<feature-slug>/issues/`, with a lifecycle of ready, claimed, then done or wontfix. Review findings become Tickets of type bug.
_Avoid_: Issue, task, story

**Finding ticket**:
A Ticket of type bug filed from a review finding, marked by its `Found by:` line: a Ticket review's Minor or `Cannot verify` line, or any Branch review finding. A Finding ticket's own Minor findings are deferred to the Ledger, not filed, so the loop ends.
_Avoid_: Follow-up ticket, review ticket

**AFK ticket**:
A Ticket an Implementer can finish and verify without the human.
_Avoid_: Autonomous ticket, agent ticket

**HITL ticket**:
A Ticket containing a decision only the human can make. The Operator splits off any agent-verifiable work so the human is left with only the decision; a HITL ticket with no real decision in it is reclassified as AFK.
_Avoid_: Manual ticket, human ticket

**Prototype ticket**:
A Ticket (`Type: prototype`) whose decision is best made by trying throwaway code. An Implementer builds its variants on a `prototype/<name>` branch, which never lands on the feature branch; the human picks a variant at a Checkpoint, and the choice is written back to the Ticket.
_Avoid_: Spike ticket, experiment

**Map ticket**:
A child ticket of a wayfinding map (`Type:` research, prototype, grilling or task) whose resolution is a decision or a fact, not code. It goes from open to claimed to resolved; research and agent-doable tasks go to Scouts, grilling and prototype tickets to the human at a Checkpoint.
_Avoid_: Wayfinder ticket, decision ticket (a decision ticket is the human part of a split HITL ticket)

**Checkpoint**:
A pause where the Operator presents the human with a batch of pending HITL decisions, prototype selections or escalations, after the integrated branch has passed the Gate. The run continues on every Ticket not blocked by a pending Checkpoint. The **Final Checkpoint** ends the run: a summary, every Ruling and the deferred findings, with push, PR and cleanup offered but never performed unasked.
_Avoid_: Stopgap, check-in, approval gate

### Artifacts

**State files**:
The files under `.scratch/<feature-slug>/` (spec, tickets, map, ledger) plus the domain docs. The only files the Operator may write.
_Avoid_: Tracker files, metadata

**Ledger**:
The running record of a `/sdd` run: ticket outcomes with their commits, deferred findings and Rulings. The source of truth when a run is resumed.
_Avoid_: Progress log, journal

**Ruling**:
A judgement call the Operator made without the human, recorded in the Ledger as what, why and cost if wrong, and listed back to the human at the end.
_Avoid_: Assumption, decision log entry

### Checks

**Gate**:
The project's typecheck and test suite. Work counts as done only once the Gate is green.
_Avoid_: CI, checks, verification

**Ticket review**:
Review of one Implementer's diff against its Ticket, judging spec compliance and code quality.
_Avoid_: Task review, per-commit review

**Branch review**:
Review of the whole feature branch once every Ticket is done, to catch problems that span Tickets. Its findings, Minors included, are filed as new Tickets; after each fix wave the whole branch is re-reviewed, until a re-review is clean or after the third.
_Avoid_: Final review, big-picture review

**Merge check**:
Verification that work done in parallel on separate branches combines cleanly onto the feature branch and still passes the Gate.
_Avoid_: Integration check
