# 06 — Prototype tickets

**What to build:** For prototype tickets, an agent builds the prototype with `mattpocock-skills:prototype` on a `prototype/<name>` branch. The resulting Checkpoint item gives the branch, how to run it and the variants to choose between. The developer's choice is written back to the ticket so dependent tickets can proceed.

**Blocked by:** 05

**Status:** done

- [x] Prototype work happens on its own `prototype/<name>` branch and never lands on the feature branch
- [x] The Checkpoint item includes branch, run instructions and variants
- [ ] The chosen variant is recorded on the ticket and unblocks its dependents
- [x] The "mixed" eval case, extended with a prototype ticket, passes

## Comments

- `Type: prototype` tickets skip HITL triage and go to the new "Build a prototype" section of `skills/sdd/SKILL.md`. The Operator switches to `prototype/<name>` (`<name>` from the filename), dispatches the Implementer with a prototype brief (`mattpocock-skills:prototype` instead of `tdd`, no Gate, no Ticket review, commit `prototype: ... (ticket NN)`), verifies the commit sits on the prototype branch and the run branch HEAD is unchanged, and switches back. The ticket gets a `## Prototype` section (branch, run, variants) and goes `ready-for-human`; the Ledger row reads `prototype ready`, and the Checkpoint item carries branch, run instruction and variants. The answer is written back as `## Answer` with `Status: done (prototype)`; dependents' briefs list the prototype ticket and may read the branch with `git show`, never merge it. The safety rules now forbid merging, rebasing or cherry-picking `prototype/*` branches. A resumed run that finds itself on a `prototype/*` branch switches back to the run branch.
- Eval: `evals-e2e/mixed/` extended with prototype ticket 05 and dependent 06 (the split decision ticket is now 07). Verified with direct headless runs, details in the spec's "Build notes (ticket 06)". Run 1 met every grader condition of the case, checked by hand against the files the graders read.
- Unticked: "The chosen variant is recorded on the ticket and unblocks its dependents". The unblocking was exercised: a hand-written `## Answer` was picked up, 05 went to `done (prototype)` and 06 was built on the chosen variant. The Operator writing the answer itself through `AskUserQuestion` was not exercised, because that tool is unavailable headless.
- Untested: the interactive Checkpoint question for a prototype; the failed-check, `BLOCKED` and `NEEDS_CONTEXT` paths of a prototype build; retrying a prototype on an existing branch; resuming a run interrupted on a `prototype/*` branch; a prototype ticket with no named variants.

- implement-loop: closed by commit bca7085 (gate green: validate ok, default eval suite 3/3). Acceptance box "chosen variant recorded and unblocks dependents" left unticked: only the hand-written ## Answer path was exercised, not AskUserQuestion.
