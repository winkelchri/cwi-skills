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

### Tickets

**Ticket**:
One unit of work in `.scratch/<feature-slug>/issues/`, with a lifecycle of ready, claimed, then done or wontfix. Findings from the Branch review become Tickets of type bug.
_Avoid_: Issue, task, story

**AFK ticket**:
A Ticket an Implementer can finish and verify without the human.
_Avoid_: Autonomous ticket, agent ticket

**HITL ticket**:
A Ticket containing a decision only the human can make. The Operator splits off any agent-verifiable work so the human is left with only the decision; a HITL ticket with no real decision in it is reclassified as AFK.
_Avoid_: Manual ticket, human ticket

**Checkpoint**:
A pause where the Operator presents the human with a batch of pending HITL decisions, prototype selections or escalations, after the integrated branch has passed the Gate. The run continues on every Ticket not blocked by a pending Checkpoint.
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
Review of the whole feature branch once every Ticket is done, to catch problems that span Tickets. Its findings are filed as new Tickets.
_Avoid_: Final review, big-picture review

**Merge check**:
Verification that work done in parallel on separate branches combines cleanly onto the feature branch and still passes the Gate.
_Avoid_: Integration check
