# Spec: `/sdd` — subagent-driven development for Claude Code

Status: ready-for-agent

## Problem Statement

I have mattpocock-skills for planning (grilling, spec, tickets, wayfinding) and building (`tdd`, `code-review`, `diagnosing-bugs`, `prototype`). Turning a ticket set into reviewed, committed code still means sitting in one long chat: running `/implement` ticket by ticket, clearing context between tickets, re-checking that the gate is green, and reviewing diffs myself. My two home-grown helpers, `implement-loop` and `wayfinder-loop`, each automate part of this, but they are separate, don't review per ticket, don't handle HITL tickets beyond stopping, and don't do a branch-wide review.

On opencode I had an `/sdd` skill that did this with an operator chat dispatching subagents, leaning on the superpowers skills because they helped weaker local models. On Claude Code I want the equivalent built for Anthropic models. It should reuse installed plugin skills by reference so upstream updates flow through, and it should run unattended until it actually needs me.

## Solution

A personal Claude Code plugin in this repo, installed locally, providing `/sdd`. Running `/sdd <slug>` turns the main chat into the **Operator** for `.scratch/<slug>/`:

- If tickets exist, the Operator works them in dependency order. For each one, a fresh **Implementer** subagent builds it test-first and commits it. A fresh **Ticket reviewer** then judges the diff on spec and quality, and a capped fix loop resolves Critical and Important findings.
- **HITL tickets** are split, so agents do everything verifiable and I'm left with only the decision. A HITL ticket with no real decision in it is reclassified as AFK and recorded as a **Ruling**.
- When nothing unblocked remains, the Operator runs the **Gate** on the integrated branch, notifies me, and presents a **Checkpoint**: a batch of decisions I can answer or defer. It then carries on.
- When every ticket is done, a **Branch review** on Opus files its findings as new bug tickets, which go through the same loop.
- A final Checkpoint shows a summary, every Ruling and the deferred Minor findings. It offers push, PR and cleanup without performing them.
- If the folder holds a wayfinding `map.md` and no tickets, the Operator works through the map's agent-doable tickets instead. It stops when the map is clear and suggests `/to-spec`.

Superpowers is not installed. Its useful ideas are built into `/sdd`'s own prompts.

## User Stories

1. As a developer, I want to run `/sdd <slug>` on a folder that already has tickets, so that implementation starts without re-explaining the feature.
2. As a developer, I want `/sdd` to refuse to start when the session's permission mode would prompt on edits or commands, so that I don't come back to a run stalled on a permission dialog.
3. As a developer, I want the refusal message to point me at auto mode or the documented allowlist, so that I can fix the setup quickly.
4. As a developer, I want the Operator to find the Gate commands itself from `CLAUDE.md`, `AGENTS.md` or project manifests, so that I don't have to configure each project.
5. As a developer, I want the Operator to ask me about the Gate only when it is ambiguous, so that unambiguous projects start without my input.
6. As a developer, I want the chosen Gate recorded as a Ruling in the Ledger, so that I can see and correct it afterwards.
7. As a developer, I want the run to abort before any work if the Gate is already red, so that failures from new work aren't confused with existing ones.
8. As a developer, I want tickets worked in dependency order based on their `Blocked by:` lines rather than strict numbering, so that a waiting HITL ticket doesn't hold up independent work.
9. As a developer, I want each ticket implemented by a fresh subagent, so that context from earlier tickets doesn't pollute later ones.
10. As a developer, I want the Implementer to use `mattpocock-skills:tdd` by reference, so that improvements to that skill reach my runs automatically.
11. As a developer, I want the Implementer to take test seams from the spec's Testing Decisions, so that TDD works without asking me to confirm seams mid-run.
12. As a developer, I want an Implementer that lacks seams or context to report `NEEDS_CONTEXT` rather than guess, so that the Operator can fill the gap or escalate it.
13. As a developer, I want each Implementer to end with exactly one status (`DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT`) and the evidence behind it, so that the Operator can act on it mechanically.
14. As a developer, I want each completed ticket to produce one commit on the feature branch, so that every ticket is a clean rollback point.
15. As a developer, I want the Operator to check an Implementer's claims itself (new commit present, Gate green) rather than trust the report, so that false "done" claims are caught.
16. As a developer, I want each ticket's diff reviewed by a fresh Ticket reviewer on two axes, spec compliance and code quality, so that defects are caught before later tickets build on them.
17. As a developer, I want review findings graded Critical, Important or Minor, so that only material problems trigger fixes.
18. As a developer, I want Minor findings deferred to the Ledger rather than fixed straight away, so that the run doesn't churn on nits.
19. As a developer, I want fixes for one ticket capped at five rounds, the first three resuming the same Implementer and the last two using a fresh Opus Implementer, so that hard fixes escalate instead of looping forever.
20. As a developer, I want every fix round to end with a scoped re-review that marks each finding ADDRESSED or NOT ADDRESSED, so that progress is measurable.
21. As a developer, I want the fixer to check review feedback against the code before acting on it, so that wrong review comments don't introduce regressions.
22. As a developer, I want a ticket that exhausts its fix rounds turned into a Checkpoint while other tickets continue, so that one stuck ticket doesn't halt the run.
23. As a developer, I want the brief, report and diff passed between agents as files, so that the Operator's context stays small during long runs.
24. As a developer, I want the Operator to edit only State files and never product code, so that every code change goes through an Implementer and a review.
25. As a developer, I want ticket statuses to move from `ready-for-agent`/`ready-for-human` to `claimed` to `done (<sha>)` or `wontfix`, so that the tracker always reflects reality.
26. As a developer, I want a run I interrupt or that ends at a Checkpoint to resume from the Ledger and ticket statuses, so that re-running `/sdd <slug>` continues where it left off.
27. As a developer, I want each HITL ticket split into an agent-doable part and a smaller decision ticket, so that I only make the decision and do no legwork.
28. As a developer, I want HITL tickets that contain no real decision reclassified as AFK and recorded as Rulings, so that mislabelled tickets don't wait for me.
29. As a developer, I want prototype tickets built by an agent with `mattpocock-skills:prototype` on a `prototype/<name>` branch, so that at the Checkpoint I only compare and choose.
30. As a developer, I want Checkpoints held back until no unblocked AFK work remains, so that I'm interrupted as rarely as possible.
31. As a developer, I want the Gate run on the integrated branch before any Checkpoint, so that I never test broken code.
32. As a developer, I want a push notification when Checkpoints are waiting, the run is done, or the run has stalled, and no notifications otherwise, so that I can walk away.
33. As a developer, I want Checkpoints presented as one batch of questions, each with the context I need (for prototypes: branch, how to run, variants), so that I can decide quickly.
34. As a developer, I want to be able to defer any Checkpoint item, so that the run continues on everything not blocked by it.
35. As a developer, I want every judgement call the Operator made without me recorded as a Ruling (what, why, cost if wrong), so that I can audit autonomy afterwards.
36. As a developer, I want a Branch review with `mattpocock-skills:code-review` on Opus once every ticket is done, so that problems spanning tickets are caught.
37. As a developer, I want Branch review findings filed as new tickets with `Type: bug` and `Found by: branch review`, continuing the numbering, so that fixes go through the same loop and leave a trail.
38. As a developer, I want unambiguous findings filed `ready-for-agent` and judgement calls filed `ready-for-human`, so that only real decisions reach me.
39. As a developer, I want one re-review after the Branch review's fix wave, so that the fixes are checked without an endless loop.
40. As a developer, I want the run to stop and notify me after two consecutive rounds with no progress, so that a stuck run doesn't burn tokens.
41. As a developer, I want independent tickets optionally run in parallel in git worktrees, so that wide ticket sets finish faster.
42. As a developer, I want a Merge check after parallel work: a subagent runs `mattpocock-skills:resolving-merge-conflicts`, the Gate is re-run, and two failures become a Checkpoint, so that parallelism can't silently break the branch.
43. As a developer, I want sequential execution to remain the default, so that parallelism is used only when it's clearly safe.
44. As a developer, I want the Operator and subagents never to push, force-push, reset, delete branches or touch files outside the repo, so that an unattended run can't do irreversible damage.
45. As a developer, I want a final Checkpoint listing the summary, all Rulings and the deferred Minor findings, so that I can pick which Minors become tickets for one more wave.
46. As a developer, I want push, PR creation and branch/worktree cleanup offered as options rather than done automatically, so that outward-facing and destructive actions stay mine.
47. As a developer, I want `/sdd` on a folder with only a `map.md` to work through the map's research tickets in parallel and its agent-doable tasks in sequence, so that wayfinding also runs unattended.
48. As a developer, I want grilling and prototype tickets on a map treated as Checkpoints, so that the decisions stay mine.
49. As a developer, I want wayfinding to stop when the map is clear and suggest `/to-spec` in its final message, so that I can move into planning.
50. As a developer, I want user-only upstream skills (`implement`, `wayfinder`, and others) followed by reading the newest installed `SKILL.md`, so that I benefit from upstream updates despite their invocation restrictions.
51. As a developer, I want each subagent dispatched with an explicit model (Sonnet for Implementer and Ticket reviewer, Opus for Branch review and late fix rounds), so that cost and quality are predictable.
52. As a developer, I want the plugin installable from this repo through a local marketplace, so that I can use it on other machines without publishing it.
53. As a developer, I want `implement-loop` and `wayfinder-loop` retired once `/sdd` works, so that I keep only one orchestrator.
54. As a developer, I want `/sdd` to play nicely with caveman and mattpocock-skills, with no always-on bootstrap hook, so that my existing setup isn't disrupted.

## Implementation Decisions

- **Plugin shape.** This repo becomes a Claude Code plugin with a plugin manifest and a local marketplace manifest. It is installed locally only and not published.
- **Operator is a skill in the main chat.** `/sdd` is a skill, not `context: fork`, because only the main chat can talk to the human (`AskUserQuestion` is unavailable in subagents). The Operator inherits the main chat's model.
- **Implementer and Ticket reviewer are plugin agents** with their models fixed in frontmatter (Sonnet). Their prompts invoke model-invocable upstream skills by name through the Skill tool: `mattpocock-skills:tdd`, `diagnosing-bugs`, `prototype`, `resolving-merge-conflicts`. They never copy those skills' text. Plugin agents ignore `permissionMode`, so permissions come from the main session.
- **User-only upstream skills** (`implement`, `wayfinder`, `to-spec`, `to-tickets`, `triage`) are followed by reading their `SKILL.md` from the newest installed mattpocock-skills version in the plugin cache (ADR-0001). The Operator resolves that path once per run. The Implementer covers what `/implement` does by calling `tdd` itself, then running typecheck and committing, rather than reading `/implement`.
- **Branch review** is `mattpocock-skills:code-review`, dispatched by the Operator on Opus against the feature branch's base.
- **Startup checks, in order:**
  1. Permission mode is auto or another mode that won't prompt, otherwise refuse with guidance.
  2. Resolve the upstream skill paths.
  3. Detect the Gate and record it as a Ruling, asking only if ambiguous.
  4. Run the Gate and abort if it is red.
  5. Detect the mode: a ticket set means ticket mode, a lone `map.md` means wayfinding mode, anything else is an error that names the planning skills to run first.
- **Ledger** lives in the feature's `.scratch/<slug>/` folder and is the source of truth for resuming. It records:
  - the Gate commands
  - the resolved skill paths
  - ticket outcomes with commit ranges
  - deferred Minor findings
  - Rulings in the form `what — why — cost if wrong`
- **Ticket lifecycle.** `Status:` lines go `ready-for-agent` / `ready-for-human` → `claimed` → `done (<sha>)` | `wontfix`. A split HITL ticket gets a child decision ticket that lists the agent-doable part under `Blocked by:`.
- **Per-ticket loop.**
  1. Record the base commit.
  2. Write the ticket brief to a file.
  3. Dispatch the Implementer.
  4. Read its status line and short report; the full report lives in a file.
  5. Verify the new commit and a green Gate.
  6. Write a review package (commits, stat, diff) to a file.
  7. Dispatch the Ticket reviewer.
  8. Run the fix loop on Critical or Important findings, or any spec failure.
- **Fix loop.**
  - Up to 5 rounds: rounds 1–3 resume the same Implementer, rounds 4–5 use a fresh Implementer on Opus.
  - Each round is followed by a scoped re-review of the fix diff that marks each finding ADDRESSED or NOT ADDRESSED.
  - If findings remain after round 5, the ticket becomes a Checkpoint.
- **Reviewer contract.** The reviewer must:
  - not trust the Implementer's report
  - cite file:line
  - flag what it cannot verify from the diff
  - not re-run the full suite

  Operator prompts must not pre-judge findings.
- **Implementer contract.** The Implementer:
  - follows TDD at the spec's seams
  - checks review feedback before applying it
  - backs every success claim with test evidence
  - never spawns further subagents
  - ends with exactly one of the four statuses
- **Scheduling.** Dependency order from `Blocked by:` lines, sequential by default. Parallel execution in worktrees is optional and followed by a Merge check.
- **Checkpoints.** Deferred until no unblocked AFK work remains. Before presenting them, the Operator runs the Gate on the integrated branch, then sends a push notification. It asks via `AskUserQuestion`, one question per item, and every item can be deferred. The run then continues.
- **Stop conditions.** The run stops when:
  - every ticket is done and the Branch review fix wave has been re-reviewed (final Checkpoint)
  - only Checkpoints remain
  - two consecutive rounds make no progress (notify and stop)
- **Notifications** use `PushNotification` only for: Checkpoints waiting, run done, run stalled.
- **Safety rules in all prompts.** No push, force-push, reset, branch deletion, or file access outside the repo. Cleanup of `prototype/*` branches and worktrees is offered at the final Checkpoint.
- **Wayfinding mode** absorbs `wayfinder-loop`:
  - The Operator follows upstream `wayfinder/SKILL.md` by path.
  - Research tickets run in parallel on Sonnet, and agent-doable tasks run in sequence.
  - Grilling and prototype tickets become Checkpoints.
  - When the map is clear, the run stops and suggests `/to-spec`.
- **Superpowers is not installed.** Its ideas (file handoffs, the four-status contract, two-axis review, the capped fix loop with model escalation, the Ledger, Rulings) are built into `/sdd`'s own prompts. Its prompt templates are reference material only.
- **Retirement.** `~/.claude/skills/implement-loop` and `~/.claude/skills/wayfinder-loop` are deleted once `/sdd` passes its evals.

## Testing Decisions

- **One seam: `claude plugin eval`.** Each case scaffolds a small fixture repo (spec, tickets, a working Gate), runs `/sdd <slug>`, and grades only the end state:
  - ticket `Status:` lines
  - Ledger contents
  - git log (one commit per done ticket)
  - Gate result
  - which skills and agents were used

  It never grades the conversation in between. A good test asserts outcomes a user would check, not the wording of prompts or the order of internal steps.
- **Cases:**
  1. **Happy path.** Three AFK tickets in a dependency chain lead to three `done (<sha>)` statuses, a green Gate and a Branch review that ran.
  2. **Mixed.** An AFK ticket plus a HITL ticket that blocks another ticket. The AFK work gets done and the HITL ticket split; the run ends at a Checkpoint with the blocked ticket untouched.
  3. **Fix loop.** A ticket whose spec contains a trap the reviewer should catch triggers at least one fix round, with the outcome in the Ledger.
  4. **Preflight refusal.** A Gate that is red at the start aborts the run with no commits.
  5. **Wayfinding.** A `map.md` with research tickets ends with them resolved and the map updated.
- **Headless caveat.** If `AskUserQuestion` and `PushNotification` don't work in headless eval runs, Checkpoint cases instead grade that the run stopped at a Checkpoint and recorded it in the Ledger.
- **Spike before building.** Manually confirm that a plugin subagent can call `mattpocock-skills:tdd` by name through the Skill tool. If it can't, fall back to reading by path (ADR-0001) for those skills too.
- **Prior art.** None in this repo yet. The `claude plugin eval` case format (`evals/**/case.yaml` with graders) is the reference.

## Out of Scope

- Interactive planning inside `/sdd`: grilling, `/to-spec`, `/to-tickets` stay manual in the main chat.
- Publishing the plugin to any public marketplace.
- Installing or depending on the superpowers plugin.
- Automatic push, merge, PR creation, or branch/worktree deletion.
- Time or cost caps on a run.
- Hard technical guards against destructive commands beyond prompt rules and the session's permission mode.
- Support for non-local issue trackers (GitHub/Linear).
- Copying upstream skill text into this plugin.

## Further Notes

- Glossary: `CONTEXT.md` (Operator, Implementer, Ticket reviewer, Ticket, AFK ticket, HITL ticket, Checkpoint, State files, Ledger, Ruling, Gate, Ticket review, Branch review, Merge check).
- ADR-0001 records why user-only upstream skills are read by path.
- The superpowers reference templates (`implementer-prompt.md`, `task-reviewer-prompt.md`, `re-review-prompt.md`, and the fix-loop and model-selection sections of `subagent-driven-development`) are worth reading when writing the agent prompts. They are in the obra/superpowers repo.
- Docs gaps to verify while building: the syntax for referencing plugin skills from a subagent's `skills:` field, and whether plugin agents can be used as `agent:` targets.

### Spike findings (ticket 01, Claude Code 2.1.296)

- **Plugin shape.** `.claude-plugin/plugin.json` plus `.claude-plugin/marketplace.json` (one plugin, `source: "./"`) validate with `claude plugin validate .`. The only warning is that a root `CLAUDE.md` is not loaded as plugin context, which is expected: it is repo context, not plugin content. Install with `claude plugin marketplace add <repo path>` then `claude plugin install cwi-skills@cwi-skills`. A directory marketplace is read live from the repo (`Read from: <repo>`), so edits apply without reinstalling.
- **Plugin agent calling an upstream skill by name: works.** A throwaway plugin agent (`tools: Skill, Read`, `model: sonnet`) was dispatched headless as `subagent_type: cwi-skills:spike-skill-caller`. It called the Skill tool with `mattpocock-skills:tdd` and received the skill text (`# Test-Driven Development`). Its skill listing showed only the model-invocable mattpocock-skills (`tdd`, `diagnosing-bugs`, `prototype`, `code-review`, `resolving-merge-conflicts`, and others); `implement`, `wayfinder`, `to-spec`, `to-tickets` and `triage` were absent, as ADR-0001 expects. ADR-0001 needs no change. Plugin agents are addressed as `<plugin>:<agent>`.
- **`AskUserQuestion` in headless runs: unavailable.** In a `claude plugin eval` case it is not in the tool list even when named in `allowed_tools`, and `ToolSearch` finds no deferred tool of that name. Plain `claude -p` behaves the same.
- **`PushNotification` in headless runs.** In `claude plugin eval` it is a gated tool (without `--allow-tools PushNotification` the run prints `not granted (missing --allow-tools grant, or a malformed entry): PushNotification`). Even with the grant it is unavailable: not listed, not found by `ToolSearch`. In plain `claude -p` it loads and can be called, but it reports `Not sent — this terminal is active, ...` instead of delivering.
- **Consequence for evals.** The headless caveat in Testing Decisions applies: Checkpoint cases must grade that the run stopped at a Checkpoint and recorded it in the Ledger, not that a question was asked or a notification sent. `/sdd` must treat a missing `AskUserQuestion` or `PushNotification` as "stop at the Checkpoint and record it", never as an error.
- **Eval fixture.** `evals/spike-headless-tools/` is kept as a cheap probe fixture (one run, about $0.05) so the suite exists and the headless tool behaviour is re-checked when Claude Code updates. The spike agent was removed.

### Build notes (ticket 02)

- **Plugin layout.** `/sdd` is `skills/sdd/SKILL.md`, user-invoked (`disable-model-invocation: true`). The Implementer is `agents/implementer.md` (`model: sonnet`, no Agent tool), dispatched as `cwi-skills:implementer`. State files stay uncommitted; briefs and reports live in `.scratch/<slug>/runs/`. On `main`/`master` the Operator switches to `sdd/<slug>` and records that as a Ruling.
- **Bash-granting evals cannot run on this machine.** `claude plugin eval` refuses any case granted Bash because `~/.docker/contexts` is a symlink (into `/mnt/c`), which its sandbox cannot exclude; a `/mnt/c` PATH entry it cannot stat trips a similar check. Both are user-level setup, outside this repo. Cases that need Bash therefore live in `evals-e2e/` (run with `--eval-dir evals-e2e --scaffold --allow-tools Bash Write Edit --ablation none`), and the default `evals/` suite holds only cheap cases that pass under `claude plugin eval . --trust-plugin`.
- **Verified instead with headless runs.** The happy-path fixture, scaffolded into a scratch directory and run with `claude -p "/sdd demo"` against the installed plugin, ended with all three tickets `done (<sha>)` in dependency order 02, 03, 01, three commits, a green Gate, the Gate Ruling in the Ledger and `mattpocock-skills:tdd` loaded by every Implementer (about $0.65 a run). A variant whose ticket 02 depends on a missing decision ended with `NEEDS_CONTEXT` in the Ledger, a Checkpoint, all tickets open and no commits.

### Build notes (ticket 03)

- **The permission mode is visible only to hooks.** Neither the system prompt nor the environment names it in `-p` runs (only plan mode announces itself). Hook input carries `permission_mode` (`default` for Manual, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`). A typed `/sdd x` fires `UserPromptExpansion` with `command_name: cwi-skills:sdd` and `command_args: x`, before the model sees the skill. So the check is a plugin hook scoped to that one command: not an always-on bootstrap, silent for every other prompt. A `{"decision":"block","reason":...}` reply stops the run and shows the reason to the user.
- **`claude plugin eval` runs cases in `dontAsk` mode**, so the hook passes there; denials, not prompts, are what an eval run meets. The permission refusal itself is therefore verified by headless runs, not an eval case.
- **Startup order differs from the list above.** Folder check runs before the Gate (no point running a Gate for a folder with nothing to do), and the branch switch runs after the Gate is green, so an aborted run leaves the repo as it found it apart from the Ledger and `runs/gate-start.log`.
- **Verified headless** (`claude -p "/sdd demo"`, Sonnet, about $0.10 each): Manual mode with no allowlist is blocked by the hook before any model turn; the red-Gate fixture (`evals-e2e/preflight-refusal`, auto mode) aborted with no commits, still on `main`, all tickets `ready-for-agent`, no Implementer, and the Checkpoint in the Ledger; acceptEdits with an allowlist lacking `Bash(npm test:*)` refused at the Gate-on-allowlist step without running anything. The Operator cannot read `permissions.md` when the plugin is installed from a directory outside `~/.claude/plugins/` (safety rule), so refusals give its path instead of quoting it.

### Build notes (ticket 04)

- **Review layout.** The Ticket reviewer is `agents/ticket-reviewer.md` (Sonnet). The Operator writes the review package with a shell redirect (`git log`, `--stat`, full diff into `runs/NN-package-R.md`) and reads only the reviewer's `VERDICT:` line and the review file's `## Minor` section. Review `0` is the first review; review `F` is the re-review after fix round `F`. Rounds 1–3 resume the Implementer through SendMessage (fresh Sonnet if it cannot be resumed, recorded as a Ruling); round 4 is a fresh Opus Implementer (Agent tool `model: opus`) and round 5 resumes it.
- **Fix commits.** Fix rounds add commits (`fix: ... (ticket NN, review round F)`), so a ticket that needed fixes owns several commits. Its status reads `done (<last sha>)` and its Ledger row gives the range. History is never squashed, because the safety rules forbid rewriting it. The happy-path case's one-commit-per-ticket grader holds only while no fix round is needed.
- **Ledger outcome `in review`.** It is written once the build commit passes verification and replaced by `done` or `stuck`. A resumed run picks up an `in review` ticket at its review. The fix-loop eval uses this to plant a flawed build commit deterministically.
- **The trap had to be planted.** In headless runs on fresh fixtures, the Sonnet Implementer applied spec-only rules unprompted. It honoured the 20-character cap in `slugify`, and again when `uniqueSlug` appended a suffix. A ticket example that contradicted the spec got `NEEDS_CONTEXT`, which is correct. So `evals-e2e/fix-loop` resumes a run at review, with a commit that ignores the cap for suffixed slugs and a report that claims every rule is covered.
- **Verified headless** (`claude -p "/sdd demo"`, Sonnet Operator, about $0.30 each):
  - On the fix-loop fixture, review 0 failed: spec Misunderstood (S1), one Critical (Q1), one Important (Q2, the report's claim was wrong). Fix round 1 went to a fresh Sonnet Implementer and its Ruling was recorded. Re-review 1 marked S1, Q1 and Q2 ADDRESSED and returned PASS. The ticket ended `done (<sha>)` with Ledger outcome `PASS after 1 fix rounds`, the Minor was deferred and the Gate was green.
  - On fresh fixtures, reviews that passed on the first try still deferred their Minors to the Ledger.
  - Not exercised headless: resuming through SendMessage, the Opus rounds 4–5, and the stuck path after round 5.

