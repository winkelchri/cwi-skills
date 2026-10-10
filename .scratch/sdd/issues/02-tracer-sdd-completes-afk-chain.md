# 02 — Tracer: `/sdd` completes a chain of AFK tickets

**What to build:** The first end-to-end path. Running `/sdd <slug>` on a feature folder of AFK tickets makes the main chat the Operator:

1. It detects the project's Gate and records it as a Ruling in a new Ledger.
2. It works the tickets one at a time in `Blocked by:` order, dispatching a fresh Implementer for each.
3. The Implementer is a plugin agent on Sonnet that builds test-first using `mattpocock-skills:tdd` by reference, takes test seams from the spec's Testing Decisions, commits once, and ends with exactly one of `DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT` plus test evidence.
4. The Operator verifies the new commit and a green Gate itself, then moves the ticket through `claimed` to `done (<sha>)` and records the outcome in the Ledger.

The Operator writes only State files. Every prompt carries the safety rules: no push, force-push, reset, branch deletion or access outside the repo. There is no review yet.

**Blocked by:** 01

**Status:** done

- [x] `/sdd <slug>` is available from the installed plugin
- [x] Gate commands are detected from project docs or manifests and recorded as a Ruling; the Operator asks only when they are ambiguous
- [x] Tickets run in dependency order from `Blocked by:` lines, not strict numbering
- [x] Each done ticket has exactly one commit on the feature branch, and its status reads `done (<sha>)`
- [x] An Implementer reporting `DONE` without a new commit or with a red Gate is not marked done
- [x] `NEEDS_CONTEXT` / `BLOCKED` are recorded in the Ledger and the ticket is left open
- [x] The Operator made no edits outside State files
- [x] Eval case "happy path" (three chained AFK tickets in a fixture repo) passes, grading end state only

## Comments

- `/sdd` is `skills/sdd/SKILL.md`; the Implementer is `agents/implementer.md` (Sonnet, loads `mattpocock-skills:tdd` by name).
- Eval: the "happy path" case is `evals-e2e/happy-path/` (fixture repo, end-state graders). It needs Bash, and `claude plugin eval` refuses Bash-granting cases on this machine (`~/.docker/contexts` is a symlink its sandbox cannot exclude), so it sits outside the default `evals/` suite. Run it with `claude plugin eval . --trust-plugin --eval-dir evals-e2e --scaffold --allow-tools Bash Write Edit --ablation none` on a machine without that symlink. The default suite gained `evals/sdd-available` (cheap: `/sdd` with no slug answers with its usage line).
- Verified with headless `claude -p "/sdd demo"` runs on the same fixture: all three tickets `done (<sha>)` in order 02, 03, 01, one commit each, Gate green, Gate Ruling in the Ledger, Operator writes only under `.scratch/demo/`, `tdd` loaded by each Implementer (~$0.65 a run). A variant with a missing decision in ticket 02 ended with `NEEDS_CONTEXT` in the Ledger, every ticket left open and no commits. Details in the spec's "Build notes (ticket 02)".
