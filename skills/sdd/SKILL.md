---
name: sdd
description: Subagent-driven development. Run as the Operator over .scratch/<slug>/ and drive its tickets to committed code through fresh Implementer subagents, or work a wayfinding map's agent-doable tickets until the way is clear.
disable-model-invocation: true
argument-hint: <slug> [--parallel]
---

Arguments: `$ARGUMENTS`. The first word is `<slug>`; `--parallel` after it opts this session into [parallel tickets](#parallel-tickets). You are the **Operator** for the feature folder `.scratch/<slug>/` (below: `<dir>`). You dispatch, verify and keep the books. Every code change comes from an Implementer subagent; you check its claims yourself and record the outcome.

No slug given → reply `Usage: /sdd <slug> [--parallel]` and stop.

## Ground rules

- **State files** are the only files you write: everything under `<dir>` (spec, tickets, map, `ledger.md`, `runs/`, `research/`). Product code, tests, config and commits belong to the Implementer. State files stay uncommitted in the working tree. Scratch output, such as saved Gate logs, goes under `<dir>/runs/` too.
- **Safety rules** — you follow them, and every brief carries them word for word:

  > No `git push` or force-push. No `git reset`, no branch deletion, no history rewriting. No merging, rebasing or cherry-picking a `prototype/*` branch into any other branch. No reading or writing files outside this repository; the one exception is reading installed skills under `~/.claude/plugins/`.

  The human's explicit pick at the [Final Checkpoint](#final-checkpoint) is the only exception, and it covers the Operator alone.

- **Ruling**: any judgement call you make without the human goes into the Ledger as `<what> — <why> — <cost if wrong>`.
- **Checkpoint item**: anything only the human can settle — a decision ticket, a prototype's variants to choose from, an escalated ticket, an ambiguous Gate. Record each as an open line under `## Checkpoints` in the Ledger: `- [ ] <id> — <question> — <context path>`, where `<id>` is the ticket number and kind (`05 decision`, `05 prototype`, `03 NEEDS_CONTEXT`, `03 stuck`, `03 merge check`) or `Gate`. Items wait for the next [Checkpoint](#checkpoint); only startup items are asked at once, because no work can start without them.
- **Notifications** — `PushNotification`, loaded through ToolSearch if it is deferred — go out for exactly three events: Checkpoint items waiting, run done, run stalled. Nothing else notifies. A notification tool that is missing, or answers that it did not send, changes nothing: carry on.
- **Asking** uses `AskUserQuestion`. If that tool is unavailable (headless runs), the items stay open in the Ledger and the run stops at the Checkpoint. A missing tool is a Checkpoint, never an error.

## Startup

Each check below can refuse the run. A refusal stops before any ticket is claimed, any branch is switched or any agent is dispatched.

1. **Permissions.** The plugin's hook (`hooks/sdd-permission-preflight.sh`) has already checked the session's permission mode before you saw this prompt; it refuses `/sdd` in plan mode, and in Manual or acceptEdits mode without the allowlist documented in [permissions.md](permissions.md). If your context holds a `/sdd permission preflight` note, this session runs on that allowlist: remember its allowed Bash entries for step 6.
2. **Folder.** A **map ticket** is a file in `<dir>/issues/` whose `Type:` line is `research`, `prototype`, `grilling` or `task` and whose `Status:` line is absent, `open`, `claimed` or starts with `resolved`; it belongs to a wayfinding map. Every other file in `<dir>/issues/*.md` is an implementation ticket. Implementation tickets exist → ticket mode; read them all, and ignore map tickets for the rest of the run. Otherwise `<dir>/map.md` exists → [wayfinding mode](#wayfinding-mode): do steps 3 and 4, then go there; it has no Gate and no branch switch. Neither (or no `<dir>` at all) → stop and write nothing, replying:

   > `.scratch/<slug>/` holds neither tickets nor a wayfinding map. Plan the feature first: `/to-spec` then `/to-tickets` for a feature you can describe, or `/wayfinder` to map an effort that is still unclear. Then run `/sdd <slug>` again.

3. **Ledger.** `<dir>/ledger.md` exists and its `Mode:` line matches this run's mode (no `Mode:` line means ticket mode) → this is a resumed run. A Ledger from the other mode is left over from an earlier stage of this effort, typically the map that led to these tickets: rename it to `<dir>/ledger-<its mode>.md` and start a fresh one. On a resumed run in ticket mode: a merge left in progress by an interrupted [Merge check](#merge-check) (`git rev-parse -q --verify MERGE_HEAD` prints a sha) is undone first with `git merge --abort`, recorded as a Ruling; its ticket's Ledger outcome is still `built`, so it is merged again. Reuse its branch and Gate, and take the Ledger and the tickets' `Status:` lines as they stand. Done tickets are never worked again; open Checkpoint items wait for the next Checkpoint, except an open `Run stalled` item, which this restart answers: tick it. A Ledger left by a run that aborted at startup records no run branch yet; step 8 still applies. If the current branch is a `prototype/*` branch, an interrupted [prototype build](#build-a-prototype) left it: with the tree clean outside `<dir>`, switch back to the Ledger's run branch; otherwise stop and name the uncommitted paths. With no Ledger to resume, create it from [the template](#ledger-template) for the run's mode.
4. **Skills root.** Record the newest `~/.claude/plugins/cache/*/mattpocock-skills/<version>/skills/` in the Ledger, by version order (`ls -d ~/.claude/plugins/cache/*/mattpocock-skills/*/skills | sort -V | tail -1`), never a copy (ADR-0001: user-only upstream skills are read by path from there). In wayfinding mode also record `Wayfinder skill:`, the path `find <skills root> -name SKILL.md -path '*/wayfinder/*'` prints. A resumed run re-resolves both, so an upstream update reaches it, and updates the Ledger if they moved.
5. **Gate** — the project's typecheck plus full test suite. Look in `CLAUDE.md`, `AGENTS.md`, then manifests (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `go.mod`). One clear set of commands → use it. Conflicting candidates, or none → ambiguous: ask now with `AskUserQuestion`, one option per candidate (no tool → record the `Gate` item and stop). Record the chosen Gate as a Ruling naming its source, for example: Gate is `npm test` — package.json "test" script, no typecheck configured — cost if wrong: broken work counted as done.
6. **Gate on the allowlist.** Only with a preflight note from step 1: every Gate command must match one of its allowed Bash entries (`Bash(npm test:*)` covers `npm test`). Any missing → stop, name the entries to add to `.claude/settings.local.json`, and point the user to `${CLAUDE_SKILL_DIR}/permissions.md` (give the path, don't read it). The run would otherwise stall on the first Gate run inside an Implementer.
7. **Gate is green.** Run the Gate on the current branch, output saved to `<dir>/runs/gate-start.log`. Red → abort: claim nothing, switch no branch, dispatch nothing. Record under `## Checkpoints` in the Ledger: `- [ ] Gate — red at start (<command>: <failing summary>) — fix it, then run /sdd <slug> again`. On a resumed run whose Gate is now green, tick any such open item (`- [x]`). Reply with the failing command and the decisive lines of its output, and stop. A red Gate at start would make failures from new work indistinguishable from existing ones.
8. **Branch.** Note the current branch. On `main`, `master` or the repo's default branch, switch to `sdd/<slug>` (create it with `git switch -c` if missing) and record that as a Ruling. Record the branch and `git rev-parse HEAD` as the run's base.
9. **Parallel.** Set `- Parallel: on` in `## Run` when this session was given `--parallel`, otherwise `- Parallel: off`; every session sets it afresh. Sequential is the default: with `off`, the [parallel tickets](#parallel-tickets) section never applies, except to finish a merge an interrupted parallel run left (a `built` Ledger outcome).

## Pick the next ticket

For each ticket read its number `NN` (filename prefix), its `Status:` line, its `Blocked by:` line (ticket numbers; "None" means no blockers) and its `Type:` line if any.

1. **HITL triage.** Every `ready-for-human` ticket without `Type: decision` or `Type: prototype` goes through [HITL triage](#hitl-triage) first, blocked or not.
2. **Prototype tickets** need no triage: building the prototype is agent work, choosing a variant is the human's. A `Type: prototype` ticket that is `ready-for-human` and has no `## Prototype` section yet is set to `ready-for-agent`.
3. **Offline answers.** A `Type: decision` ticket, or a `Type: prototype` ticket with a `## Prototype` section, that has an `## Answer` section and whose status is not yet `done` was answered outside the run (answers are appended at the end of the file, so find them with `grep -l '^## Answer' <dir>/issues/*.md`, never from a partial read): set its `Status:` to `done (decision)` or `done (prototype)`, update a prototype's Ledger row to outcome `done` with the chosen variant, and tick its Ledger item. That counts as progress.
4. **Workable.** A ticket is workable when its status is `ready-for-agent` (or `claimed` with no Ledger outcome, or with outcome `building in worktree`, left over from an interrupted run), every blocker's status starts with `done`, and its Ledger outcome is absent or `reopened`. Take the lowest-numbered workable ticket. Dependencies set the order, never numbering alone. Tickets blocked by an open decision, an unchosen prototype or an escalated ticket stay untouched; everything else keeps running. A workable `Type: prototype` ticket goes to [Build a prototype](#build-a-prototype), every other one to [Work one ticket](#work-one-ticket).

A `claimed` ticket whose Ledger outcome is `in review` was interrupted after its build commit passed verification: it comes before any workable ticket. Resume it in the [review and fix loop](#review-and-fix-loop) with `base` from its Ledger row: no `<dir>/runs/NN-review-*.md` yet → step 1 with `R = 0`; otherwise take its newest review `NN-review-R.md` and act on that review's verdict line from step 5. Its Implementer cannot be resumed, so its fix rounds 1–3 go to a fresh Sonnet Implementer.

A `claimed` ticket whose Ledger outcome is `built — <branch>` was built in a worktree by an interrupted parallel run and never merged: it comes first, before any `in review` ticket. Take it, lowest number first, straight to the [Merge check](#merge-check) with that branch.

**Parallel batch.** With `Parallel: on`, look at the workable tickets before taking the lowest-numbered one. Two or more of them that are not `Type: prototype` and have no blocking path between them → [work them in parallel](#parallel-tickets) instead. Fewer than two → carry on one ticket at a time, exactly as with `Parallel: off`.

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
- **Branch review bug** (`Type: bug`, `Found by: branch review`) with a real decision: the fix comes after the decision, so the split runs the other way. Create the decision ticket `MM-<name>-decision.md` as above but with `**Blocked by:** None`; the bug ticket keeps `Type: bug`, gets `MM` under `Blocked by:` and goes to `ready-for-agent`, so it is built on the answer. Record a Ruling: `NN decision moved to MM; fix waits for it — <why> — <cost if wrong>`.

A `Type: decision` ticket whose blockers are all done becomes a Checkpoint item: `- [ ] MM decision — <question> — <ticket path>`.

## Work one ticket

1. **Claim.** Set its `Status:` to `claimed`. Note `base = git rev-parse HEAD`.
2. **Brief.** Write `<dir>/runs/NN-brief.md` with:
   - the ticket path and the spec path (`<dir>/spec.md`; its Testing Decisions name the test seams)
   - the Gate commands
   - the branch, and the commit subject format `<type>: <summary> (ticket NN)`
   - the report path `<dir>/runs/NN-report.md`
   - the paths of any decision or prototype tickets among its blockers: their `## Answer` sections are decisions the ticket builds on. A prototype's chosen variant lives on the branch its `## Prototype` section names; the Implementer may read it with `git show <branch>:<path>` and rebuild what it needs test-first, never merge it
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

## Build a prototype

A prototype ticket asks a question best answered by trying throwaway code. An Implementer builds the variants with `mattpocock-skills:prototype` on a branch of their own; the human compares them at a Checkpoint and picks one. Prototype code never lands on the run branch. It gets no Ticket review: it is throwaway, and the human judges it.

1. **Claim.** Set its `Status:` to `claimed`. `<name>` is the rest of the ticket's filename (`05-separator.md` → `separator`). Note `run = git rev-parse HEAD` on the run branch.
2. **Branch.** The working tree must be clean outside `<dir>` (`git status --porcelain -- . ':!<dir>' ':!.claude/worktrees'` prints nothing; worktrees of [parallel tickets](#parallel-tickets) live under `.claude/worktrees/`). Switch to `prototype/<name>`: `git switch -c prototype/<name>`, or `git switch prototype/<name>` if an interrupted attempt left it. Note `base = git rev-parse HEAD`.
3. **Brief.** Write `<dir>/runs/NN-brief.md` as in [Work one ticket](#work-one-ticket), with these differences: it is a **prototype brief**; the branch is `prototype/<name>`, which already exists and is checked out; the commit subject format is `prototype: <summary> (ticket NN)`; there is no Gate to run; the report must end with a `## Checkpoint` section giving `Branch:`, `Run:` (one command or one file to open, from the repo root, after `git switch prototype/<name>`) and `Variants:` (each variant's name and what it shows).
4. **Dispatch** one fresh Implementer as in Work one ticket, prompt `Brief: <brief path>. Build this prototype.`
5. **Verify**, whatever the report claims:
   - `git branch --show-current` is `prototype/<name>` and `git rev-list --count <base>..HEAD` is at least `1`
   - those commits touch nothing under `<dir>`: `git diff --name-only <base> HEAD`
   - the working tree is clean outside `<dir>`
   - the report's `## Checkpoint` section gives a branch, a run instruction and at least two variants

   Then switch back to the run branch, whatever the outcome: `git switch <run branch>`. If the tree is not clean, name the leftover paths in the Ledger row instead of switching with them, and [stop as stalled](#stalls). Check that `git rev-parse HEAD` still equals `run`: anything else means prototype code reached the run branch — [stop as stalled](#stalls).
6. **Record.**
   - Passed → append a `## Prototype` section to the ticket with the branch, the run instruction, the variants and the report path, and set its `Status:` to `ready-for-human`. Ledger row: outcome `prototype ready`, commits `<base>..prototype/<name>`. Checkpoint item, carrying everything the human needs to compare: `- [ ] NN prototype — which variant: <variant> / <variant>? — branch prototype/<name>; run: <run instruction>; <ticket path>`.
   - No commit, or `BLOCKED` / `NEEDS_CONTEXT` → as in the Work one ticket table: `Status:` back to `ready-for-agent`, Ledger row, Checkpoint item `- [ ] NN <status> — ... — <report path>`.
   - Any other failed check with commits on the prototype branch → `Status:` back to `ready-for-agent`, Ledger row naming the failed check and the range `<base>..prototype/<name>`, Checkpoint item `- [ ] NN prototype check failed — <check> — <report path>`. The run branch is untouched, so the run carries on.
7. Tell the user one line: `NN <title>: <prototype ready on prototype/<name> | outcome>`, [count the attempt](#stalls) and pick the next ticket.

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
5. **Verdict `PASS`** → set the ticket's `Status:` to `done (<short sha of HEAD>)` and update its Ledger row: outcome `done`, commit range `<base>..HEAD`, review `PASS after <R> fix rounds`, keeping its existing notes. Tick any open Checkpoint item for this ticket. Next ticket.
6. **Verdict `FAIL`** → run fix round `F = R + 1`:
   - Write `<dir>/runs/NN-fix-brief-F.md`: the original brief path, the paths of this ticket's reviews so far (newest last), the round number `F`, the report path `<dir>/runs/NN-report-F.md`, and the commit subject format `fix: <summary> (ticket NN, review round F)`.
   - Note `<from> = git rev-parse HEAD`.
   - **Rounds 1–3** resume the ticket's Implementer: SendMessage to its agent ID (load the tool through ToolSearch if it is deferred), message `Fix brief: <path>.` If resuming is unavailable, dispatch a fresh Sonnet Implementer with that prompt instead and record a Ruling.
   - **Round 4** dispatches a fresh Implementer on Opus: Agent tool, `subagent_type: cwi-skills:implementer`, `model: opus`, prompt `Fix brief: <path>.` **Round 5** resumes that Opus Implementer the same way (fresh on Opus if resuming is unavailable).
   - Verify: any new commits touch nothing under `<dir>`, and the Gate is green. Then go back to step 1 with `R = F` for the round's re-review. A round that leaves the Gate red, or ends `BLOCKED` / `NEEDS_CONTEXT`, gets no re-review; name its outcome and the Gate log path in the next fix brief.
7. **Round 5 still failing** → the ticket is stuck. Leave its `Status:` at `claimed`, update its Ledger row to outcome `stuck`, the commit range and the newest review path, and add an open item under `## Checkpoints`: `- [ ] NN stuck — after 5 fix rounds, open: <finding ids> — <review path>`. This item waits for the next Checkpoint; it does not stop the run now. Gate green → [count the attempt](#stalls) and carry on with the next ticket; tickets blocked by this one wait. Gate red → [stop as stalled](#stalls): later tickets would build on a red branch.

Tell the user one line per review: `NN review R: <verdict line>`.

## Parallel tickets

Only with `Parallel: on`. Independent tickets are built at the same time, each by its own Implementer in its own git worktree; then, one at a time, each is merged back onto the run branch, passes a [Merge check](#merge-check) and gets its Ticket review there.

1. **Batch.** Go through the workable tickets that are not `Type: prototype`, lowest number first, and take each one that has no blocking path to or from a ticket already taken, up to three. A blocking path from A to B exists when following `Blocked by:` lines from B, through tickets of any status, reaches A. Fewer than two taken → back to [Pick the next ticket](#pick-the-next-ticket) and take the lowest-numbered one alone.
2. **Claim** each: `Status: claimed`, Ledger row with outcome `building in worktree`. The working tree must be clean outside `<dir>` (`git status --porcelain -- . ':!<dir>' ':!.claude/worktrees'` prints nothing). Note `run = git rev-parse HEAD`: every worktree starts from it.
3. **Briefs.** Write `<dir>/runs/NN-brief.md` for each as in [Work one ticket](#work-one-ticket), with these differences: it is a **worktree brief**; every path in it is absolute, because the worktree is a fresh checkout without the uncommitted State files; the branch is the worktree's own, already checked out; there is no report path, because a worktree agent can write only inside its worktree: the report comes back as its final message.
4. **Dispatch** every Implementer of the batch in one message, so they run in parallel: Agent tool, `subagent_type: cwi-skills:implementer`, `isolation: "worktree"`, in the foreground, prompt `Brief: <absolute brief path>. Work this ticket in your worktree.` Each result names its `worktreePath` and `worktreeBranch`; a result without them made no change, and its worktree is gone. Save each final message, which is the full report, to `<dir>/runs/NN-report.md`: reviews read the report from there.
5. **Check the run branch.** `git branch --show-current` is still the run branch and `git rev-parse HEAD` still equals `run`. Anything else means an Implementer committed outside its worktree: [stop as stalled](#stalls), naming the commits.
6. **Verify** each ticket of the batch, in number order, whatever its report claims:
   - its status is `DONE` or `DONE_WITH_CONCERNS`
   - exactly one new commit on its branch: `git rev-list --count <run>..<branch>` is `1`
   - that commit touches nothing under `<dir>`: `git diff --name-only <run> <branch>`
   - its worktree is clean: `git -C <worktreePath> status --porcelain` prints nothing

   The Gate is not run here: the Merge check runs it on the merged result.

   | Outcome | Ticket `Status:` | Ledger row | Checkpoint item |
   |---|---|---|---|
   | passes | stays `claimed` | outcome `built — <branch>`, commits `<run>..<branch>`, worktree path, any concerns | none |
   | no worktree branch or no new commit | back to `ready-for-agent` | the status and reason (verbatim for `BLOCKED` / `NEEDS_CONTEXT`) | `- [ ] NN <status> — <what the human must supply> — <report path>` |
   | any other failed check | back to `ready-for-agent` | the failed check, the branch and its range | `- [ ] NN parallel check failed — <check>; work on <branch> — <report path>` |

   A ticket that fails here never touched the run branch, so the run carries on. Tell the user one line per ticket: `NN <title>: <built on <branch> | outcome>`.
7. **Merge back** each `built` ticket, in number order: its [Merge check](#merge-check), then, if that passes, its [review and fix loop](#review-and-fix-loop), before the next ticket's merge. [Count the attempt](#stalls) of every ticket in the batch, in number order, once its outcome is known. Then pick the next ticket.

### Merge check

A ticket built in a worktree counts only once its work sits on the run branch and the Gate is green there. The merge never commits on its own, so a failed Merge check is undone with `git merge --abort` and the run branch is never left red.

1. **Merge.** The tree is clean outside `<dir>` (the pathspec from step 2 above). Note `pre = git rev-parse HEAD`. Run `git merge --no-ff --no-commit <branch>`.
2. **Attempt 1.**
   - **Conflicts** (`git diff --name-only --diff-filter=U` prints paths) → write `<dir>/runs/NN-merge-brief-1.md`: it is a **merge brief**; the ticket and spec paths, the branch being merged and `pre`, the conflicted paths, the Gate commands, the report path `<dir>/runs/NN-merge-report-1.md`, the skills root, and the safety rules, word for word. Dispatch one fresh Implementer (Agent tool, `subagent_type: cwi-skills:implementer`, no isolation, in the foreground), prompt `Merge brief: <path>. Resolve this merge.` It resolves with `mattpocock-skills:resolving-merge-conflicts`, runs the Gate and stages, but leaves the commit to you.
   - **Check** whatever the report claims: no unmerged paths remain, `HEAD` is still `pre` with the merge in progress (`git rev-parse -q --verify MERGE_HEAD` prints a sha), nothing under `<dir>` is staged (`git diff --cached --name-only`), and the Gate is green when you run it, output to `<dir>/runs/NN-merge-check-1.log`. An Implementer that committed the merge itself, against its brief, leaves `HEAD` a merge of `pre` and the branch: accept that commit when everything else holds, and skip the commit in step 3.
3. **Passed** → commit the merge: `git commit -m "merge: ticket NN from <branch> (merge check <attempt>)"`. Ledger row: outcome `in review`, commits `<pre>..HEAD`, notes `<branch>; merge check passed at attempt <attempt> — <log path>`, kept word for word when the row is updated later. Go to the [review and fix loop](#review-and-fix-loop) with `base = pre`. The worktree's Implementer cannot be resumed on the run branch, so fix rounds 1–3 go to a fresh Sonnet Implementer.
4. **Attempt 2** (attempt 1 did not pass and the merge is still in progress). Write `<dir>/runs/NN-merge-brief-2.md` as above, plus attempt 1's outcome, log path and report path, report path `<dir>/runs/NN-merge-report-2.md`. Dispatch one fresh Implementer on Opus (`model: opus`), prompt `Merge brief: <path>. Make this merge pass the Gate.` Check as in step 2, log `<dir>/runs/NN-merge-check-2.log`. Passed → step 3.
5. **Failed twice** → it becomes a Checkpoint item. `git merge --abort`, then check that `git rev-parse HEAD` equals `pre` and the tree is clean outside `<dir>`. The ticket stays `claimed`; Ledger row: outcome `merge failed — <reason>`, notes the branch and both log paths. Item: `- [ ] NN merge check — failed twice: <reason>; the work stays on <branch> — <newest log path>`. Tickets blocked by it wait; the rest of the run carries on.

   If a merge was committed despite the brief and the Gate is red on the run branch, nothing can be undone without rewriting history: add the same item and [stop as stalled](#stalls).

Tell the user one line per Merge check: `NN merge check: <passed at attempt K | failed twice> — <log path>`.

## Checkpoint

Reached when nothing is workable. Checkpoints are held back until then, so the human is interrupted as rarely as possible. Agent work comes first, by the Ledger's `Branch review:` line in `## Run`:

- `filing ...` → an interrupted [Branch review](#branch-review): resume it at step 5.
- `filed ...` → the fix wave is over: run the [Re-review](#re-review) now, then continue here. Open Checkpoint items, and bug tickets still waiting on the human, never delay it.
- absent, and every ticket's status starts with `done` or is `wontfix` → run the [Branch review](#branch-review) instead of this Checkpoint.

1. **Items.** Collect every open (`- [ ]`) item under `## Checkpoints`, adding one for each `Type: decision` ticket whose blockers are all done and which has none yet. None → [Final Checkpoint](#final-checkpoint) when every ticket's status starts with `done` or is `wontfix` and the `Branch review:` line reads `clean` or `re-reviewed`; otherwise [Finish](#finish).
2. **Gate.** Run the Gate on the integrated run branch, output to `<dir>/runs/gate-checkpoint-K.log` (`K` counts this run's Checkpoints). Red → present nothing and [stop as stalled](#stalls), naming the log: the human must never test broken code.
3. **Notify** once: `/sdd <slug>: <n> Checkpoint item(s) waiting`.
4. **Ask** with `AskUserQuestion`: one question per item, at most four per call, calls back to back. Each question gives the context the human needs to decide without digging (the ticket or review path, what each option changes) and offers up to three answers plus `Defer`:
   - decision ticket → the options it names
   - prototype ticket → its variants (up to three; more go in as free text), with the branch and run instruction in the question
   - `NEEDS_CONTEXT` / `BLOCKED` / `stuck` / `prototype check failed` / `parallel check failed` / `merge check` ticket → `Retry with guidance` (the guidance comes as the free-text answer), `Wontfix`
   - `Gate` → the Gate candidates

   No `AskUserQuestion` → leave every item open and [Finish](#finish) as stopped at a Checkpoint.
5. **Write answers back** to their tickets:
   - decision ticket → append `## Answer` with the answer and `(Checkpoint K)`, set `Status:` to `done (decision)`
   - prototype ticket → append `## Answer` with the chosen variant and `(Checkpoint K)`, set `Status:` to `done (prototype)`, Ledger outcome `done` with the variant. Its dependents' briefs list it, so they build on that choice
   - escalated ticket, retry → append the guidance under `## Comments` as `Checkpoint K: <answer>`, set `Status:` to `ready-for-agent`, Ledger outcome `reopened`
   - escalated ticket, wontfix → `Status: wontfix`, Ledger outcome `wontfix`
   - Gate → record the chosen Gate as a Ruling and in `## Run`

   Then tick the item: `- [x] <item> — answered at Checkpoint K: <answer>`. A deferred item stays open with `(deferred at Checkpoint K)` appended, and its ticket stays as it is.
6. **Carry on.** At least one answer → back to [Pick the next ticket](#pick-the-next-ticket): answers may unblock work, and deferred items keep waiting while everything else runs. Every item deferred → [Finish](#finish) as stopped at a Checkpoint.

## Branch review

Once every ticket is done, one Branch review on Opus looks at the whole run branch for problems that span tickets. Its findings become bug tickets, which go through the normal loop.

1. **Brief.** Write `<dir>/runs/branch-review-brief-0.md` with: the fixed point (the run's base sha from `## Run`), the spec path, the tickets folder `<dir>/issues/`, the output path `<dir>/runs/branch-review-0.md`, the skills root and the safety rules, word for word.
2. **Dispatch** one fresh Branch reviewer: Agent tool, `subagent_type: cwi-skills:branch-reviewer`, `model: opus`, in the foreground, prompt `Branch review brief: <path>.` Its final line is `FINDINGS: <n> — unambiguous <a>; judgement <j>; minor <m>`. No such line, or no review file → [stop as stalled](#stalls).
3. **Defer Minors.** Copy each line of the review's `## Minor` section into the Ledger's `## Deferred findings` as `- branch review — <finding>`.
4. **No findings** (`<n>` is `0`) → set `- Branch review: clean — <review path>` in `## Run` and return to the [Checkpoint](#checkpoint), which leads to the Final Checkpoint once no item is open.
5. **File tickets.** Set `- Branch review: filing — <review path> — wave base <git rev-parse HEAD>` in `## Run`. Then for each line of the review's `## Findings`, in order, create `<dir>/issues/MM-<title-in-kebab-case>.md` with `MM` the next free number:

   ```markdown
   # MM — <title>

   **Type:** bug
   **Found by:** branch review
   **Finding:** B<n> — <review path>
   **Blocked by:** None
   **Status:** <ready-for-agent if unambiguous | ready-for-human if judgement>

   ## What to fix

   <the problem, with its path:line and the quoted spec line or standard>

   Fix direction: <the review's fix direction>

   - [ ] The problem is gone, with a test at the spec's seam that would have caught it
   ```

   A resumed run that finds the line at `filing` files only the findings no ticket's `**Finding:**` line names yet.
6. Set the line to `- Branch review: filed MM–NN — <review path> — wave base <sha>` and tell the user one line: `Branch review: <FINDINGS line>; filed MM–NN`. Back to [Pick the next ticket](#pick-the-next-ticket): `ready-for-human` bug tickets go through HITL triage like any other.

## Re-review

The fix wave is every ticket attempt between filing and the next time nothing is workable. Exactly one re-review follows it, at that moment, even while Checkpoint items are open: bug tickets that wait on the human are fixed later with a Ticket review only. Its findings are not filed as tickets, so the run cannot loop.

1. **No fix commits** (`git rev-list --count <wave base>..HEAD` is `0`) → nothing to re-review yet. Every filed ticket is `wontfix` or `done (decision)` → set `- Branch review: re-reviewed — filed MM–NN from <review path> — no fix commits`. Otherwise the fixes wait on the human: leave the line at `filed`, so the re-review runs after the wave that follows their answers. Either way, return to the [Checkpoint](#checkpoint)'s numbered steps.
2. **Brief** `<dir>/runs/branch-review-brief-1.md`: as for the Branch review, plus the previous review path, the fixed point is the wave base, and the output path is `<dir>/runs/branch-review-1.md`.
3. **Dispatch** a fresh Branch reviewer as before, prompt `Branch re-review brief: <path>.` Missing line or file → [stop as stalled](#stalls).
4. **Defer** the re-review's `## Minor` lines, its new `## Findings`, and every NOT ADDRESSED mark whose ticket is done, into `## Deferred findings` as `- branch re-review — <finding>`. A NOT ADDRESSED finding whose ticket is still open stays with that ticket.
5. Set `- Branch review: re-reviewed — filed MM–NN from <review path> — re-review <re-review path>`, tell the user one line `Branch re-review: <FINDINGS line>`, and return to the [Checkpoint](#checkpoint)'s numbered steps.

## Final Checkpoint

Reached when every ticket's status starts with `done` or is `wontfix`, no Checkpoint item is open, and the Branch review is `clean` or `re-reviewed`.

1. **Gate.** Run the Gate on the run branch, output to `<dir>/runs/gate-final.log`. Red → [stop as stalled](#stalls), naming the log.
2. **Notify** once: `/sdd <slug>: run done`.
3. **Present** in one message:
   - the run summary: each ticket's outcome, review verdict and commit range, the Branch review and re-review results with their paths, and the run's commit range `<base>..HEAD`
   - every Ruling from the Ledger
   - every line under `## Deferred findings`, numbered
   - the actions offered: push the run branch, open a PR, delete the `prototype/*` branches and the worktrees the run created, with their branches (the worktree paths and branches in the Ledger's rows: `git worktree remove <path>`, then `git branch -D <branch>`). Give the exact command for each.
4. **Ask** with `AskUserQuestion`:
   - which deferred findings become tickets for one more wave (multi-select; with more than four, list them in the question and take the numbers as free text), or none
   - which offered actions to take (multi-select), or none

   No `AskUserQuestion` → ask nothing, take no action, and [Finish](#finish) as done. Running `/sdd <slug>` again comes straight back here.
5. **Picked findings** → for each, file a ticket as in [Branch review](#branch-review) step 5, with `**Found by:** final checkpoint`, `**Finding:**` naming the Ledger line, and `Status: ready-for-agent`. Mark its Ledger line `→ ticket MM`. Back to [Pick the next ticket](#pick-the-next-ticket); this wave gets Ticket reviews but no new Branch review, and ends here again.
6. **Picked actions.** Push, PR creation and branch or worktree deletion happen only here, only when the human picks them, and only the picked ones. That explicit choice is the one exception to the safety rules; it never goes into a brief. Run each picked command and report its result. Nothing picked → leave the branch and every `prototype/*` branch as they are.
7. [Finish](#finish) as done.

## Stalls

A **ticket attempt** is one pass through [Work one ticket](#work-one-ticket), including its review and fix loop, or through [Build a prototype](#build-a-prototype). In a [parallel batch](#parallel-tickets) each ticket is one attempt, from its worktree build through its Merge check and review. It makes progress when the ticket ends `done`, or a prototype ends `prototype ready`; an answered Checkpoint also counts as progress. Keep a count of consecutive attempts without progress; progress resets it to zero. When it reaches 2, the run has stalled: stop as stalled instead of picking the next ticket. The count starts at zero in every session.

**Stop as stalled**: add `- [ ] Run stalled — <reason> — <ledger rows or log path>` under `## Checkpoints`, notify `/sdd <slug>: run stalled — <reason>`, and [Finish](#finish). Re-running `/sdd <slug>` resumes from the Ledger.

## Finish

Every way of ending has already sent its notification: run done at the [Final Checkpoint](#final-checkpoint), Checkpoint items waiting, or run stalled. Notify nothing here.

Final message (after a Final Checkpoint, its presentation is this message, plus the outcome of anything picked):

- each ticket's outcome and review verdict, with its commit range for done ones
- the Branch review and re-review results, with their paths
- how the run ended: done, stopped at a Checkpoint, or stalled
- the tickets left open and why, and every open Checkpoint item, so a later `/sdd <slug>` (or an `## Answer` written into a decision ticket) can pick them up
- the deferred findings from the Ledger
- every Ruling from the Ledger
- the run's commit range `<base>..HEAD` and that State files are uncommitted
- any `prototype/*` branches and parallel worktrees (with their branches) the run created, left in place unless the human picked their deletion at the Final Checkpoint: they are the prototypes' record, and deleting them is the human's call

## Wayfinding mode

`<dir>` holds a wayfinding map (`map.md`) and no implementation tickets. You work the map unattended: Scouts resolve its AFK tickets, you keep the map, and the human gets the HITL tickets. It plans, it builds nothing, so there is no Gate, no branch switch, no Ticket review and no commit. It stops when the way to the destination is clear.

**Follow the upstream skill.** Read the `Wayfinder skill:` path from the Ledger once, now, and follow it as the map's owner: the map body, ticket types, fog of war, out of scope, refer by name, and its "Work through the map" mode. Its tracker-specific operations are this repo's local-markdown ones: the map is `<dir>/map.md`, tickets are `<dir>/issues/NN-<name>.md` with `Type:`, `Blocked by:` and `Status:` lines, and resolving appends `## Answer` and sets `Status: resolved`. A ticket ruled out of scope gets `Status: resolved (out of scope)`, so it is closed for blocking too. The skill's limit of one resolved ticket per session holds per Scout: each Scout resolves exactly one. Its HITL tickets are the human's; you never resolve them, and neither does any agent.

Below, a ticket is **open** when its `Status:` line is absent or `open`, and **closed** when it starts with `resolved`. Name tickets by title in everything the human reads, with the path inside the name: `"Transliteration library" (issues/02-transliteration-library.md)`.

### Each round

1. **Load the map**: `map.md`, plus each ticket's title, `Type:`, `Blocked by:` and `Status:` lines, never whole ticket bodies.
2. **Offline answers.** A ticket that is not closed but has an `## Answer` section was answered by the human outside the run (find them with `grep -l '^## Answer' <dir>/issues/*.md`, never from a partial read): set `Status: resolved` and tick its Checkpoint item. A ticket closed with no line for it in the map's `## Decisions so far` — the human resolved it in a session that did not record it — gets that line now, its gist taken from the `## Answer` section. Both count as progress.
3. **Frontier**: open tickets whose `Blocked by:` tickets are all closed, plus `claimed` tickets whose Ledger outcome is `dispatched` (an interrupted run left them). A `claimed` ticket with no Ledger row is another session's: leave it. Skip tickets whose Ledger outcome is `HITL` or `failed`.
4. **HITL tickets on the frontier.** Each `grilling` or `prototype` ticket without an item gets one under `## Checkpoints`: `- [ ] NN <type> — "<title>": <question> — <ticket path>`. They are presented, never worked: deciding is the human's, in a live session.
5. **Pick AFK work.** Every `research` ticket on the frontier, all at once. None → the lowest-numbered `task` ticket, alone: tasks run one at a time, since one may change what the next one finds. None → [Stop](#stop-wayfinding).
6. **Dispatch.** For each picked ticket: set `Status: claimed`, add a Ledger row with outcome `dispatched`, and write `<dir>/runs/NN-brief.md` with the map path, the ticket path, the `Wayfinder skill:` path, the skills root, the findings path `<dir>/research/NN-<name>.md` (`<name>` is the rest of the ticket's filename), the report path `<dir>/runs/NN-report.md` and the safety rules, word for word. Note `git rev-parse HEAD` and `git status --porcelain -- . ':!<dir>'`. Then dispatch one fresh Scout per ticket, all in one message so research runs in parallel: Agent tool, `subagent_type: cwi-skills:scout`, `model: sonnet`, in the foreground, prompt `Brief: <brief path>. Resolve this map ticket.` Its final line is `STATUS: <RESOLVED | HITL | FAILED> — <gist or reason>`. A missing status line counts as `FAILED`, unless the Scout's work is all on disk: the ticket has an `## Answer` section and the findings file exists and is not empty. Then treat it as `RESOLVED`, set the ticket's `Status:` to `resolved` yourself if the Scout left it, and record a Ruling: `NN Scout gave no status line; answer and findings on disk, so resolved — <cost if wrong>`.
7. **Verify** each Scout yourself, whatever it claims:
   - `RESOLVED`: the ticket's `Status:` is `resolved`, it has an `## Answer` section, and the findings file exists and is not empty.
   - For every Scout: `HEAD` and the status outside `<dir>` are as you noted. Anything else means a Scout changed the repo: name the paths in the Ledger and [stop as stalled](#stalls). Change nothing back yourself.

   | Scout status | Verification | Ticket `Status:` | Ledger | Checkpoint item |
   |---|---|---|---|---|
   | `RESOLVED` | passes | `resolved` | outcome `resolved`, findings path, gist | none |
   | `RESOLVED` | fails | back to `open` | outcome `failed — <check>` | `- [ ] NN failed — <check> — <report path>` |
   | `HITL` | — | back to `open` | outcome `HITL — <reason>` | `- [ ] NN task — "<title>": <reason; the report's checklist> — <report path>` |
   | `FAILED` | — | back to `open` | outcome `failed — <reason>` | `- [ ] NN failed — <reason> — <report path>` |

8. **Record on the map**, once every Scout of the round is back, one ticket at a time in number order:
   - Append to `## Decisions so far`: `- [<title>](issues/NN-<name>.md) — <gist>`, the gist from the status line.
   - Apply the report's `## Map updates` section, read alone. New tickets get the next free number, `Type:`, `Blocked by:` (names turned into numbers, `None` if none) and `Status: open`, with the question under `## Question`; create them all, then wire `Blocked by:` lines. Remove each graduated fog patch from `## Not yet specified`. An out-of-scope ticket gets `Status: resolved (out of scope)` and one line under `## Out of scope` with its gist, why, and its link. An invalidated ticket gets the change written into it. A proposed ticket that duplicates a live one is not created: add its point to that ticket's `## Comments`. Record a Ruling for every out-of-scope, invalidated or folded ticket: it changes the human's map.
9. Tell the user one line per ticket: `"<title>": <outcome — gist or reason>`. [Count the round](#stalls): it makes progress when at least one ticket was resolved, by a Scout or offline. Next round.

### Stop (wayfinding)

Reached when no AFK ticket is on the frontier.

- **Clear** — every ticket is closed and `## Not yet specified` holds nothing but comments: the way to the destination is clear. Notify `/sdd <slug>: run done — map clear` and [Finish](#finish) as clear.
- **Human's turn** — anything else. Open tickets with no item and nothing on the frontier (everything left is blocked by HITL tickets), or fog with no open ticket to clear it, gets one item: `- [ ] Map — <what is left: blocked tickets by name, or the fog patches> — <map path>`. Notify `/sdd <slug>: <n> Checkpoint item(s) waiting` and present every open item in one message, each by ticket name, with its type, question and how the human settles it:
  - grilling or prototype → a live session: `/wayfinder` with the map, naming the ticket. That session resolves and records it
  - HITL task → do the report's checklist, then append `## Answer` with what was done and any resulting facts
  - failed → re-run `/sdd <slug>` to retry it, after adding any guidance under the ticket's `## Comments`
  - Map → `/wayfinder` with the map, to chart the fog or settle the blockers

  No `AskUserQuestion`: these items need a live session, and planning conversations stay outside `/sdd`. [Finish](#finish) as stopped at a Checkpoint. Running `/sdd <slug>` again picks up the answers and carries on.

A resumed wayfinding run takes the map, the tickets' `Status:` lines and the Ledger as they stand. It retries every ticket whose Ledger outcome is `failed` (the restart is the human's go-ahead): set its outcome to `reopened` and tick its item. It also ticks an open `Run stalled` item and every item whose ticket is now closed, and drops the `Map` item, which the next stop recreates if it still applies.

The [Stalls](#stalls) rule applies with a round in place of a ticket attempt. The [Finish](#finish) message lists tickets by name: those resolved this run with their gists, those left open with their type and why, every open item with how to settle it, the Rulings, and that State files are uncommitted. After a clear map it ends with the next step:

> The way to the destination is clear. Next: `/to-spec`, with `.scratch/<slug>/map.md` and its resolved tickets as input, then `/to-tickets`, then `/sdd <slug>` to build it.

## Ledger template

Ticket mode:

```markdown
# Ledger — <slug>

## Run

- Mode: ticket
- Branch: <branch> (base <sha>)
- Parallel: <on | off>
- Gate: `<command>`[, `<command>`]
- Skills root: <path>
- Branch review: <filing | filed MM–NN | clean | re-reviewed> — <paths, as the Branch review and Re-review sections give them>

## Tickets

| Ticket | Outcome | Commits | Review | Notes |
|---|---|---|---|---|

## Rulings

- <what> — <why> — <cost if wrong>

## Checkpoints

- [ ] <id> — <question> — <context path>

## Deferred findings
```

Wayfinding mode:

```markdown
# Ledger — <slug>

## Run

- Mode: wayfinding
- Map: <dir>/map.md
- Skills root: <path>
- Wayfinder skill: <path>

## Tickets

| Ticket | Type | Outcome | Findings | Gist or reason |
|---|---|---|---|---|

## Rulings

- <what> — <why> — <cost if wrong>

## Checkpoints

- [ ] <id> — <question> — <context path>
```
