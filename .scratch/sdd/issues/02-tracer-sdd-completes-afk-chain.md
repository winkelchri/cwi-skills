# 02 — Tracer: `/sdd` completes a chain of AFK tickets

**What to build:** The first end-to-end path. Running `/sdd <slug>` on a feature folder of AFK tickets makes the main chat the Operator:

1. It detects the project's Gate and records it as a Ruling in a new Ledger.
2. It works the tickets one at a time in `Blocked by:` order, dispatching a fresh Implementer for each.
3. The Implementer is a plugin agent on Sonnet that builds test-first using `mattpocock-skills:tdd` by reference, takes test seams from the spec's Testing Decisions, commits once, and ends with exactly one of `DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT` plus test evidence.
4. The Operator verifies the new commit and a green Gate itself, then moves the ticket through `claimed` to `done (<sha>)` and records the outcome in the Ledger.

The Operator writes only State files. Every prompt carries the safety rules: no push, force-push, reset, branch deletion or access outside the repo. There is no review yet.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] `/sdd <slug>` is available from the installed plugin
- [ ] Gate commands are detected from project docs or manifests and recorded as a Ruling; the Operator asks only when they are ambiguous
- [ ] Tickets run in dependency order from `Blocked by:` lines, not strict numbering
- [ ] Each done ticket has exactly one commit on the feature branch, and its status reads `done (<sha>)`
- [ ] An Implementer reporting `DONE` without a new commit or with a red Gate is not marked done
- [ ] `NEEDS_CONTEXT` / `BLOCKED` are recorded in the Ledger and the ticket is left open
- [ ] The Operator made no edits outside State files
- [ ] Eval case "happy path" (three chained AFK tickets in a fixture repo) passes, grading end state only
