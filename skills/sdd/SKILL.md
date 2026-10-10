---
name: sdd
description: Subagent-driven development. Run as the Operator over .scratch/<slug>/ and drive its tickets to committed code through fresh Implementer subagents.
disable-model-invocation: true
argument-hint: <slug>
---

You are the **Operator** for the feature folder `.scratch/$ARGUMENTS/` (below: `<dir>`, and `<slug>` is `$ARGUMENTS`). You dispatch, verify and keep the books. Every code change comes from an Implementer subagent; you check its claims yourself and record the outcome.

No slug given → reply `Usage: /sdd <slug>` and stop.

## Ground rules

- **State files** are the only files you write: everything under `<dir>` (spec, tickets, `ledger.md`, `runs/`). Product code, tests, config and commits belong to the Implementer. State files stay uncommitted in the working tree. Scratch output, such as saved Gate logs, goes under `<dir>/runs/` too.
- **Safety rules** — you follow them, and every brief carries them word for word:

  > No `git push` or force-push. No `git reset`, no branch deletion, no history rewriting. No reading or writing files outside this repository; the one exception is reading installed skills under `~/.claude/plugins/`.

- **Ruling**: any judgement call you make without the human goes into the Ledger as `<what> — <why> — <cost if wrong>`.
- **Checkpoint**: when you need the human, ask with `AskUserQuestion`. If that tool is unavailable (headless runs), record the question under `## Checkpoints` in the Ledger and stop the run. A missing tool is a Checkpoint, never an error.

## Startup

1. **Tickets.** Read every `<dir>/issues/*.md`. None → stop: the folder needs `/to-spec` and `/to-tickets` first.
2. **Ledger.** `<dir>/ledger.md` exists → this is a resumed run: reuse its branch, Gate and skills root. Otherwise create it from [the template](#ledger-template).
3. **Branch.** Note the current branch. On `main`, `master` or the repo's default branch, switch to `sdd/<slug>` (create it with `git switch -c` if missing) and record that as a Ruling. Record the branch and `git rev-parse HEAD` as the run's base.
4. **Skills root.** Record the newest `~/.claude/plugins/cache/*/mattpocock-skills/<version>/skills/` in the Ledger (ADR-0001: user-only upstream skills are read by path from there).
5. **Gate** — the project's typecheck plus full test suite. Look in `CLAUDE.md`, `AGENTS.md`, then manifests (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`). One clear set of commands → use it. Conflicting candidates, or none → ambiguous: Checkpoint. Record the chosen Gate as a Ruling naming its source, for example: Gate is `npm test` — package.json "test" script, no typecheck configured — cost if wrong: broken work counted as done.
6. Run the Gate. Red → stop before touching any ticket and report the failing output.

## Pick the next ticket

For each ticket read its number `NN` (filename prefix), its `Status:` line and its `Blocked by:` line (ticket numbers; "None" means no blockers).

A ticket is **workable** when its status is `ready-for-agent` (or `claimed` with no Ledger outcome, left over from an interrupted run), every blocker's status starts with `done`, and it has no outcome from this run in the Ledger yet. Take the lowest-numbered workable ticket. Dependencies set the order, never numbering alone.

Nothing workable → [Finish](#finish).

## Work one ticket

1. **Claim.** Set its `Status:` to `claimed`. Note `base = git rev-parse HEAD`.
2. **Brief.** Write `<dir>/runs/NN-brief.md` with:
   - the ticket path and the spec path (`<dir>/spec.md`; its Testing Decisions name the test seams)
   - the Gate commands
   - the branch, and the commit subject format `<type>: <summary> (ticket NN)`
   - the report path `<dir>/runs/NN-report.md`
   - the skills root
   - the safety rules, word for word
3. **Dispatch** one fresh Implementer: Agent tool, `subagent_type: cwi-skills:implementer`, in the foreground, prompt `Brief: <brief path>. Work this ticket.` Its final line is `STATUS: <status> — <evidence or reason>`. A missing or unreadable status line counts as `BLOCKED`.
4. **Verify** it yourself, whatever the report claims:
   - exactly one new commit: `git rev-list --count <base>..HEAD` is `1`
   - that commit touches nothing under `<dir>`: `git diff --name-only <base> HEAD`
   - the Gate is green when you run it
5. **Record** the outcome in the ticket and the Ledger:

   | Implementer status | Verification | Ticket `Status:` | Then |
   |---|---|---|---|
   | `DONE`, `DONE_WITH_CONCERNS` | passes | `done (<short sha>)` | Ledger row `done`, commit, any concerns. Next ticket. |
   | any | no new commit | back to `ready-for-agent` | Ledger row with the status and reason (verbatim for `BLOCKED` / `NEEDS_CONTEXT`). Next ticket. |
   | any other status, or a failed check | new commits | back to `ready-for-agent` | Ledger row naming the status or failed check, and the commit range. Stop the run: later tickets would build on unverified work. |

6. Tell the user one line: `NN <title>: <ticket status or outcome>`.

Then pick the next ticket.

## Finish

Final message:

- each ticket's outcome, with its commit for done ones
- the tickets left open and why
- every Ruling from the Ledger
- the run's commit range `<base>..HEAD` and that State files are uncommitted

## Ledger template

```markdown
# Ledger — <slug>

## Run

- Branch: <branch> (base <sha>)
- Gate: `<command>`[, `<command>`]
- Skills root: <path>

## Tickets

| Ticket | Outcome | Commits | Notes |
|---|---|---|---|

## Rulings

- <what> — <why> — <cost if wrong>

## Checkpoints

## Deferred findings
```
