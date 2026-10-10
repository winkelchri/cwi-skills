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
- **Checkpoint item**: anything only the human can settle — a decision ticket, an escalated ticket, an ambiguous Gate. Record each as an open line under `## Checkpoints` in the Ledger: `- [ ] <id> — <question> — <context path>`, where `<id>` is the ticket number and kind (`05 decision`, `03 NEEDS_CONTEXT`, `03 stuck`) or `Gate`. Items wait for the next [Checkpoint](#checkpoint); only startup items are asked at once, because no work can start without them.
- **Notifications** — `PushNotification`, loaded through ToolSearch if it is deferred — go out for exactly three events: Checkpoint items waiting, run done, run stalled. Nothing else notifies. A notification tool that is missing, or answers that it did not send, changes nothing: carry on.
- **Asking** uses `AskUserQuestion`. If that tool is unavailable (headless runs), the items stay open in the Ledger and the run stops at the Checkpoint. A missing tool is a Checkpoint, never an error.

## Startup

Each check below can refuse the run. A refusal stops before any ticket is claimed, any branch is switched or any agent is dispatched.

1. **Permissions.** The plugin's hook (`hooks/sdd-permission-preflight.sh`) has already checked the session's permission mode before you saw this prompt; it refuses `/sdd` in plan mode, and in Manual or acceptEdits mode without the allowlist documented in [permissions.md](permissions.md). If your context holds a `/sdd permission preflight` note, this session runs on that allowlist: remember its allowed Bash entries for step 6.
2. **Folder.** `<dir>/issues/*.md` exist → ticket mode; read them all. Otherwise `<dir>/map.md` exists → wayfinding mode, which is not built yet: say so and stop. Neither (or no `<dir>` at all) → stop and write nothing, replying:

   > `.scratch/<slug>/` holds neither tickets nor a wayfinding map. Plan the feature first: `/to-spec` then `/to-tickets` for a feature you can describe, or `/wayfinder` to map an effort that is still unclear. Then run `/sdd <slug>` again.

3. **Ledger.** `<dir>/ledger.md` exists → this is a resumed run: reuse its branch, Gate and skills root, and take the Ledger and the tickets' `Status:` lines as they stand. Done tickets are never worked again; open Checkpoint items wait for the next Checkpoint, except an open `Run stalled` item, which this restart answers: tick it. A Ledger left by a run that aborted at startup records no run branch yet; step 8 still applies. Otherwise create it from [the template](#ledger-template).
4. **Skills root.** Record the newest `~/.claude/plugins/cache/*/mattpocock-skills/<version>/skills/` in the Ledger (ADR-0001: user-only upstream skills are read by path from there).
5. **Gate** — the project's typecheck plus full test suite. Look in `CLAUDE.md`, `AGENTS.md`, then manifests (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`). One clear set of commands → use it. Conflicting candidates, or none → ambiguous: ask now with `AskUserQuestion`, one option per candidate (no tool → record the `Gate` item and stop). Record the chosen Gate as a Ruling naming its source, for example: Gate is `npm test` — package.json "test" script, no typecheck configured — cost if wrong: broken work counted as done.
6. **Gate on the allowlist.** Only with a preflight note from step 1: every Gate command must match one of its allowed Bash entries (`Bash(npm test:*)` covers `npm test`). Any missing → stop, name the entries to add to `.claude/settings.local.json`, and point the user to `${CLAUDE_SKILL_DIR}/permissions.md` (give the path, don't read it). The run would otherwise stall on the first Gate run inside an Implementer.
7. **Gate is green.** Run the Gate on the current branch, output saved to `<dir>/runs/gate-start.log`. Red → abort: claim nothing, switch no branch, dispatch nothing. Record under `## Checkpoints` in the Ledger: `- [ ] Gate — red at start (<command>: <failing summary>) — fix it, then run /sdd <slug> again`. On a resumed run whose Gate is now green, tick any such open item (`- [x]`). Reply with the failing command and the decisive lines of its output, and stop. A red Gate at start would make failures from new work indistinguishable from existing ones.
8. **Branch.** Note the current branch. On `main`, `master` or the repo's default branch, switch to `sdd/<slug>` (create it with `git switch -c` if missing) and record that as a Ruling. Record the branch and `git rev-parse HEAD` as the run's base.

## Pick the next ticket

For each ticket read its number `NN` (filename prefix), its `Status:` line, its `Blocked by:` line (ticket numbers; "None" means no blockers) and its `Type:` line if any.

1. **HITL triage.** Every `ready-for-human` ticket without `Type: decision` goes through [HITL triage](#hitl-triage) first, blocked or not.
2. **Offline answers.** A `Type: decision` ticket with an `## Answer` section whose status is not yet `done` was answered outside the run: set its `Status:` to `done (decision)` and tick its Ledger item. That counts as progress.
3. **Workable.** A ticket is workable when its status is `ready-for-agent` (or `claimed` with no Ledger outcome, left over from an interrupted run), every blocker's status starts with `done`, and its Ledger outcome is absent or `reopened`. Take the lowest-numbered workable ticket. Dependencies set the order, never numbering alone. Tickets blocked by an open decision or an escalated ticket stay untouched; everything else keeps running.

A `claimed` ticket whose Ledger outcome is `in review` was interrupted after its build commit passed verification: it comes before any workable ticket. Resume it in the [review and fix loop](#review-and-fix-loop) with `base` from its Ledger row: no `<dir>/runs/NN-review-*.md` yet → step 1 with `R = 0`; otherwise take its newest review `NN-review-R.md` and act on that review's verdict line from step 5. Its Implementer cannot be resumed, so its fix rounds 1–3 go to a fresh Sonnet Implementer.

Nothing workable → [Checkpoint](#checkpoint).

## HITL triage

A HITL ticket should leave the human only the decision. Read it, the spec and the tickets around it, then sort it:

- **No real decision.** Everything it asks is settled by the ticket, spec, ADRs or code; the label is all that makes it HITL. Set its `Status:` to `ready-for-agent` and record a Ruling: `NN reclassified HITL → AFK — <why no decision remains> — <cost if wrong>`.
- **Agent work plus a decision.** Split it:
  - The ticket keeps its number, text and blockers and becomes the agent part. Add a `## Agent part` section: exactly what to build that holds whichever way the decision goes, and the decision it must not make (`Decided in MM`). Set its `Status:` to `ready-for-agent`.
  - Create the decision ticket `<dir>/issues/MM-<name>-decision.md`, with `MM` the next free number and `<name>` the rest of NN's filename (`02-length-cap.md` → `05-length-cap-decision.md`): title `MM — <decision>`, `**Type:** decision`, `**Split from:** NN`, `**Blocked by:** NN`, `**Status:** ready-for-human`, then the question, the options the ticket or spec names, and what each option changes.
  - Every ticket that lists `NN` under `Blocked by:` gets `MM` added there: it needs the decision, not just the agent part.
  - Record a Ruling: `NN split: agent part <scope>; decision moved to MM — <why> — <cost if wrong>`.
- **Decision only.** Nothing an agent can do or verify ahead of the decision. Add `**Type:** decision` and leave it `ready-for-human`. Record a Ruling saying so.

A `Type: decision` ticket whose blockers are all done becomes a Checkpoint item: `- [ ] MM decision — <question> — <ticket path>`.

## Work one ticket

1. **Claim.** Set its `Status:` to `claimed`. Note `base = git rev-parse HEAD`.
2. **Brief.** Write `<dir>/runs/NN-brief.md` with:
   - the ticket path and the spec path (`<dir>/spec.md`; its Testing Decisions name the test seams)
   - the Gate commands
   - the branch, and the commit subject format `<type>: <summary> (ticket NN)`
   - the report path `<dir>/runs/NN-report.md`
   - the paths of any decision tickets among its blockers: their `## Answer` sections are decisions the ticket builds on
   - for a split ticket: build only its `## Agent part`
   - the skills root
   - the safety rules, word for word
3. **Dispatch** one fresh Implementer: Agent tool, `subagent_type: cwi-skills:implementer`, in the foreground, prompt `Brief: <brief path>. Work this ticket.` Keep the agent ID the result gives; fix rounds resume it. Its final line is `STATUS: <status> — <evidence or reason>`. A missing or unreadable status line counts as `BLOCKED`.
4. **Verify** it yourself, whatever the report claims:
   - exactly one new commit: `git rev-list --count <base>..HEAD` is `1`
   - that commit touches nothing under `<dir>`: `git diff --name-only <base> HEAD`
   - the Gate is green when you run it

   | Implementer status | Verification | Ticket `Status:` | Then |
   |---|---|---|---|
   | `DONE`, `DONE_WITH_CONCERNS` | passes | stays `claimed` | Ledger row `in review`, commit range, any concerns. [Review](#review-and-fix-loop). |
   | any | no new commit | back to `ready-for-agent` | Ledger row with the status and reason (verbatim for `BLOCKED` / `NEEDS_CONTEXT`); Checkpoint item `- [ ] NN <status> — <what the human must supply> — <report path>`. Next ticket. |
   | any other status, or a failed check | new commits | back to `ready-for-agent` | Ledger row naming the status or failed check, and the commit range. [Stop as stalled](#stalls): later tickets would build on unverified work. |

5. Tell the user one line: `NN <title>: <ticket status or outcome>`. Unless the table sent you to the review, [count the attempt](#stalls) and pick the next ticket.

## Review and fix loop

Every ticket passes a Ticket review before it counts as done. Diffs, reviews and reports travel as files under `<dir>/runs/`; you pass paths and read only final lines and the sections named below. Your prompts carry paths and the round number only: the reviewer judges, the Implementer checks the findings, and you add no opinion of any finding in either direction.

1. **Package.** Write the review package with a shell redirect, so the diff never enters your context:

   ```sh
   { git log --format='%h %s' <from>..HEAD; echo; git diff --stat <from> HEAD; echo; git diff <from> HEAD; } > <dir>/runs/NN-package-R.md
   ```

   For the first review `<from>` is the ticket's base and `R` is `0`; for round `R`'s re-review `<from>` is the commit before that round.
2. **Review brief.** Write `<dir>/runs/NN-review-brief-R.md` with: the ticket and spec paths, the package path, the newest Implementer report path, the output path `<dir>/runs/NN-review-R.md`, the safety rules word for word, and for `R ≥ 1` the round number and the previous review path.
3. **Dispatch** one fresh Ticket reviewer: Agent tool, `subagent_type: cwi-skills:ticket-reviewer`, in the foreground, prompt `Review brief: <path>.` Its final line is `VERDICT: <PASS | FAIL> — spec <PASS | FAIL>; critical <n>; important <n>; minor <n>`. A missing verdict line counts as `FAIL`.
4. **Defer Minors.** Copy each line of the review file's `## Minor` section, and each `Cannot verify` spec line, into the Ledger's `## Deferred findings` as `- NN — <finding>`. Minor findings never start a fix round.
5. **Verdict `PASS`** → set the ticket's `Status:` to `done (<short sha of HEAD>)` and update its Ledger row: outcome `done`, commit range `<base>..HEAD`, review `PASS after <R> fix rounds`. Tick any open Checkpoint item for this ticket. Next ticket.
6. **Verdict `FAIL`** → run fix round `F = R + 1`:
   - Write `<dir>/runs/NN-fix-brief-F.md`: the original brief path, the paths of this ticket's reviews so far (newest last), the round number `F`, the report path `<dir>/runs/NN-report-F.md`, and the commit subject format `fix: <summary> (ticket NN, review round F)`.
   - Note `<from> = git rev-parse HEAD`.
   - **Rounds 1–3** resume the ticket's Implementer: SendMessage to its agent ID (load the tool through ToolSearch if it is deferred), message `Fix brief: <path>.` If resuming is unavailable, dispatch a fresh Sonnet Implementer with that prompt instead and record a Ruling.
   - **Round 4** dispatches a fresh Implementer on Opus: Agent tool, `subagent_type: cwi-skills:implementer`, `model: opus`, prompt `Fix brief: <path>.` **Round 5** resumes that Opus Implementer the same way (fresh on Opus if resuming is unavailable).
   - Verify: any new commits touch nothing under `<dir>`, and the Gate is green. Then go back to step 1 with `R = F` for the round's re-review. A round that leaves the Gate red, or ends `BLOCKED` / `NEEDS_CONTEXT`, gets no re-review; name its outcome and the Gate log path in the next fix brief.
7. **Round 5 still failing** → the ticket is stuck. Leave its `Status:` at `claimed`, update its Ledger row to outcome `stuck`, the commit range and the newest review path, and add an open item under `## Checkpoints`: `- [ ] NN stuck — after 5 fix rounds, open: <finding ids> — <review path>`. This item waits for the next Checkpoint; it does not stop the run now. Gate green → [count the attempt](#stalls) and carry on with the next ticket; tickets blocked by this one wait. Gate red → [stop as stalled](#stalls): later tickets would build on a red branch.

Tell the user one line per review: `NN review R: <verdict line>`.

## Checkpoint

Reached when nothing is workable. Checkpoints are held back until then, so the human is interrupted as rarely as possible.

1. **Items.** Collect every open (`- [ ]`) item under `## Checkpoints`, adding one for each `Type: decision` ticket whose blockers are all done and which has none yet. None → [Finish](#finish).
2. **Gate.** Run the Gate on the integrated run branch, output to `<dir>/runs/gate-checkpoint-K.log` (`K` counts this run's Checkpoints). Red → present nothing and [stop as stalled](#stalls), naming the log: the human must never test broken code.
3. **Notify** once: `/sdd <slug>: <n> Checkpoint item(s) waiting`.
4. **Ask** with `AskUserQuestion`: one question per item, at most four per call, calls back to back. Each question gives the context the human needs to decide without digging (the ticket or review path, what each option changes) and offers up to three answers plus `Defer`:
   - decision ticket → the options it names
   - `NEEDS_CONTEXT` / `BLOCKED` / `stuck` ticket → `Retry with guidance` (the guidance comes as the free-text answer), `Wontfix`
   - `Gate` → the Gate candidates

   No `AskUserQuestion` → leave every item open and [Finish](#finish) as stopped at a Checkpoint.
5. **Write answers back** to their tickets:
   - decision ticket → append `## Answer` with the answer and `(Checkpoint K)`, set `Status:` to `done (decision)`
   - escalated ticket, retry → append the guidance under `## Comments` as `Checkpoint K: <answer>`, set `Status:` to `ready-for-agent`, Ledger outcome `reopened`
   - escalated ticket, wontfix → `Status: wontfix`, Ledger outcome `wontfix`
   - Gate → record the chosen Gate as a Ruling and in `## Run`

   Then tick the item: `- [x] <item> — answered at Checkpoint K: <answer>`. A deferred item stays open with `(deferred at Checkpoint K)` appended, and its ticket stays as it is.
6. **Carry on.** At least one answer → back to [Pick the next ticket](#pick-the-next-ticket): answers may unblock work, and deferred items keep waiting while everything else runs. Every item deferred → [Finish](#finish) as stopped at a Checkpoint.

## Stalls

A **ticket attempt** is one pass through [Work one ticket](#work-one-ticket), including its review and fix loop. It makes progress when the ticket ends `done`; an answered Checkpoint also counts as progress. Keep a count of consecutive attempts without progress; progress resets it to zero. When it reaches 2, the run has stalled: stop as stalled instead of picking the next ticket. The count starts at zero in every session.

**Stop as stalled**: add `- [ ] Run stalled — <reason> — <ledger rows or log path>` under `## Checkpoints`, notify `/sdd <slug>: run stalled — <reason>`, and [Finish](#finish). Re-running `/sdd <slug>` resumes from the Ledger.

## Finish

Run done (every ticket `done` or `wontfix`, no open items) → notify `/sdd <slug>: run done`. Stopped at a Checkpoint → its notification already went out. Stalled → so did that one.

Final message:

- each ticket's outcome and review verdict, with its commit range for done ones
- how the run ended: done, stopped at a Checkpoint, or stalled
- the tickets left open and why, and every open Checkpoint item, so a later `/sdd <slug>` (or an `## Answer` written into a decision ticket) can pick them up
- the deferred findings from the Ledger
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

| Ticket | Outcome | Commits | Review | Notes |
|---|---|---|---|---|

## Rulings

- <what> — <why> — <cost if wrong>

## Checkpoints

- [ ] <id> — <question> — <context path>

## Deferred findings
```
