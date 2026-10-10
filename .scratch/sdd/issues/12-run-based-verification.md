# 12 — Verification by running, not reading

**Type:** feature
**Blocked by:** 11

**Status:** ready-for-agent

**What to build:** Today a ticket counts as done on a green Gate plus a reviewer's reading of the diff. Acceptance criteria are never tied to anything that ran, and nothing exercises the feature end to end. The developer chose all four changes below on 2026-10-10.

1. **Per-criterion evidence (Implementer).** The report maps every acceptance criterion of the ticket to evidence the Implementer produced by running something: a test name plus its result line, or a command plus its relevant output. A criterion with no run evidence blocks `DONE` (use `DONE_WITH_CONCERNS` or `NEEDS_CONTEXT`, naming the criterion). Applies to fix rounds and finding tickets for the criteria they touch.
2. **Reviewer runs, not reads (Ticket reviewer).** The reviewer re-runs the Implementer's evidence for each criterion and may run any focused tests or seam commands it needs (still not the full suite; the Operator owns that). A criterion that is asserted but never exercised by a test or run is a spec failure (`Missing`, quoting the criterion), which starts the fix loop. `Cannot verify from diff` is kept only for things that cannot be run here at all, and must say why.
3. **E2E seam is mandatory (Startup).** In ticket mode, startup needs the spec's Testing Decisions to name an end-to-end seam: a command that drives the product the way a user does (CLI invocation, HTTP call, browser test, eval case). Detect it like the Gate and record it as a Ruling. None, or ambiguous → startup Checkpoint item, and the run stops before any work, as an ambiguous Gate does. A ticket that changes user-visible behaviour must add or extend a test at that seam, and the Gate must run those tests (the Implementer wires them into the Gate command if they are not already).
4. **Operator smoke-runs.** After verifying an Implementer's commit (and after each fix round and Merge check), the Operator runs the e2e seam itself, output to `<dir>/runs/NN-smoke-R.log`. A failing smoke run is treated like a red Gate. All Operator scratch output stays under `<dir>/runs/` — never `/tmp` (a headless run wrote `/tmp/row.NN`).

Wayfinding mode is unaffected.

**Acceptance criteria**

- [ ] Implementer reports carry per-criterion run evidence; a criterion without it blocks `DONE`
- [ ] A Ticket review flags an asserted-but-unexercised criterion as a spec failure and the fix loop closes it
- [ ] A spec without an e2e seam stops the run at startup with a Checkpoint item and no commits
- [ ] The Operator's smoke run is logged per ticket, and a failing smoke run stops the ticket like a red Gate
- [ ] Every evals-e2e fixture's spec names an e2e seam, and the full evals-e2e suite passes in headless harness runs (grader output in the ticket's Comments, not hand-checked end state)
