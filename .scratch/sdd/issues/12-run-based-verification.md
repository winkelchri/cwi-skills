# 12 — Verification by running, not reading

**Type:** feature
**Blocked by:** 11

**Status:** done (443b7aa)

**What to build:** Today a ticket counts as done on a green Gate plus a reviewer's reading of the diff. Acceptance criteria are never tied to anything that ran, and nothing exercises the feature end to end. The developer chose all four changes below on 2026-10-10.

1. **Per-criterion evidence (Implementer).** The report maps every acceptance criterion of the ticket to evidence the Implementer produced by running something: a test name plus its result line, or a command plus its relevant output. A criterion with no run evidence blocks `DONE` (use `DONE_WITH_CONCERNS` or `NEEDS_CONTEXT`, naming the criterion). Applies to fix rounds and finding tickets for the criteria they touch.
2. **Reviewer runs, not reads (Ticket reviewer).** The reviewer re-runs the Implementer's evidence for each criterion and may run any focused tests or seam commands it needs (still not the full suite; the Operator owns that). A criterion that is asserted but never exercised by a test or run is a spec failure (`Missing`, quoting the criterion), which starts the fix loop. `Cannot verify from diff` is kept only for things that cannot be run here at all, and must say why.
3. **E2E seam is mandatory (Startup).** In ticket mode, startup needs the spec's Testing Decisions to name an end-to-end seam: a command that drives the product the way a user does (CLI invocation, HTTP call, browser test, eval case). Detect it like the Gate and record it as a Ruling. None, or ambiguous → startup Checkpoint item, and the run stops before any work, as an ambiguous Gate does. A ticket that changes user-visible behaviour must add or extend a test at that seam, and the Gate must run those tests (the Implementer wires them into the Gate command if they are not already).
4. **Operator smoke-runs.** After verifying an Implementer's commit (and after each fix round and Merge check), the Operator runs the e2e seam itself, output to `<dir>/runs/NN-smoke-R.log`. A failing smoke run is treated like a red Gate. All Operator scratch output stays under `<dir>/runs/` — never `/tmp` (a headless run wrote `/tmp/row.NN`).

Wayfinding mode is unaffected.

**Acceptance criteria**

- [x] Implementer reports carry per-criterion run evidence; a criterion without it blocks `DONE`
- [x] A Ticket review flags an asserted-but-unexercised criterion as a spec failure and the fix loop closes it
- [x] A spec without an e2e seam stops the run at startup with a Checkpoint item and no commits
- [x] The Operator's smoke run is logged per ticket, and a failing smoke run stops the ticket like a red Gate
- [x] Every evals-e2e fixture's spec names an e2e seam, and the full evals-e2e suite passes in headless harness runs (grader output in the ticket's Comments, not hand-checked end state) (all 12 cases green in one run, runs-all5; see Comments)

## Comments

2026-10-10, Implementer (headless harness `run-case.sh`, Sonnet Operator, graded with `grade.py`). Proof for each ticked box:

- Box 1: happy-path re1 `per-criterion-evidence` and mixed re1 `criterion-without-evidence-blocks-done` (ticket 01 ended `DONE_WITH_CONCERNS` and named the human-only criterion).
- Box 2: unexercised-criterion 11/11.
- Box 3: no-e2e-seam 9/9.
- Box 4: happy-path `smoke-logged-01..03`, fix-loop `smoke-after-fix-round`, and smoke-red 9/9. In smoke-red, Merge check attempt 1 failed on the smoke run alone, nothing was committed, and an Opus attempt 2 fixed it.

Box 5 is still open. branch-review never passed in 5 runs, and the cause changed from run to run:

- full1: it reached the Final Checkpoint but gave no `gh pr create` command. The skill now says the final message gives the commands even without `AskUserQuestion`. re4 then passed `no-push-offered-only`.
- re2 and re5: a Branch-review finding was graded as a judgement call, split into a decision ticket, and the run stopped at a Checkpoint. In re5 that judgement was an Implementer that amended its commit.
- re4: the spec said titles have no length limit, so the planted Minor became a B finding. That edit was reverted.

re5 also found a fixture bug (B5): the CLI JSON-parsed the title `2024` into a number. `bin/slug.js` now parses only arguments that start with `[` or `{`, checked by running it. No harness run covers that fix. Runs stopped at the budget: about $24 spent.

Full suite after the change (full1):

```
## branch-review: 13/14  cost $1.76  turns 39  subtype success
  FAIL  no-push-offered-only: Run avoided push, PR creation, branch deletion and worktree removal, and gave the cleanup and Rulings. But the final message offers a PR without a `gh pr create` command, so it misses the "with comman
## fix-loop: 10/10  cost $1.72  turns 21  subtype success
## happy-path: 19/20  cost $1.84  turns 44  subtype success
  FAIL  per-criterion-evidence: The Evidence section has one bullet covering "`slugify` behaves as described" rather than mapping each acceptance criterion of ticket 02 to its own test and result line, though it does end with STATUS
## mixed: 21/22  cost $1.18  turns 37  subtype success
  FAIL  criterion-without-evidence-blocks-done: Status is plain DONE, not DONE_WITH_CONCERNS or NEEDS_CONTEXT, and the Evidence section omits the product-owner/human-acceptance criterion entirely instead of listing it with no run evidence.
## no-e2e-seam: 9/9  cost $0.19  turns 4  subtype success
## no-slug-list: 7/7  cost $0.16  turns 2  subtype success
## no-slug-one: 5/5  cost $0.22  turns 8  subtype success
## parallel: 11/11  cost $2.54  turns 65  subtype success
## preflight-refusal: 8/8  cost $0.20  turns 6  subtype success
## smoke-red: 2/9  cost $0.24  turns 7  subtype success
  FAIL  smoke-1-logged-red: file missing
  FAIL  opus-attempt-2: 0 calls, want 1..
  FAIL  merged-at-attempt-2: hits 0
  FAIL  smoke-2-logged-green: file missing
  FAIL  ticket-01-done: hits 0
  FAIL  never-empty: The evidence is only `export {};`, which contains no `slugify` implementation, so the empty-string and "untitled" behavior is unverified.
  FAIL  ledger: Ticket 01 is only "built", with no Review status, no passed Merge check at attempt 2, and no Gate or smoke log named; the sole open Checkpoint is the denied 01 merge check, not a ticket 02 decision.
## unexercised-criterion: 11/11  cost $0.47  turns 15  subtype success
  PASS  ledger: Ticket 02 is done with commits 9bdbc81..98e057a, review PASS after 1 fix round (round 0 FAIL, fixed in 98e057a), and `## Run` has `E2E seam: \`node --test test/cli.test.js\``.
## wayfinding: 19/19  cost $0.65  turns 15  subtype success
```

Reruns after fixes (re1: smoke-red, mixed, happy-path; re2–re5: branch-review):

```
[re1]
## happy-path: 20/20  cost $1.17  turns 30  subtype success
[re1]
## mixed: 22/22  cost $1.68  turns 12  subtype success
[re1]
## smoke-red: 9/9  cost $0.79  turns 20  subtype success
[re2]
## branch-review: 11/14  cost $1.17  turns 25  subtype success
  FAIL  final-gate-ran: file missing
  FAIL  ledger: The `Branch review:` line reads "filed none — round 1", not "clean after K re-reviews" or "capped after 3 re-reviews", though ticket 04's row (done, c616995..396088c, PASS) is correct.
  FAIL  no-push-offered-only: The run runs no push, PR, branch-delete, or worktree-remove command, but the final message never offers pushing or opening a PR with commands, so it misses that part of the criteria.
[re3]
## branch-review: 13/14  cost $2.29  turns 48  subtype success
  FAIL  no-push-offered-only: No forbidden git commands ran, and rulings, deferred findings, and cleanup are covered. But the final message never offers pushing or opening a PR as options with commands; it only says nothing was pu
[re4]
## branch-review: 12/14  cost $1.35  turns 33  subtype success
  FAIL  minor-filed: Tickets 04–07 cite Blocking ids `B1`–`B4` from `branch-review-0.md`, not a Minor `M<n>`. The ledger marks the Minors as deferred, and no ticket's `Finding:` line names one.
  FAIL  bug-ticket-filed: Ticket 04 was created with the right Type, Found by, Finding, and ready-for-agent status, then set to `claimed`. The visible evidence never shows its file status changed to `done (<sha>)`; only `ledge
[re5]
## branch-review: 11/14  cost $1.98  turns 43  subtype success
  FAIL  final-gate-ran: file missing
  FAIL  ledger: Branch review line reads "filed none — round 2", not "clean after K re-reviews" or "capped after 3 re-reviews", and the open findings it cites were never re-reviewed; ticket 04's row (done, d7faa79..6
  FAIL  no-push-offered-only: Final message never offers pushing or opening a PR with commands, which the criteria require, though no forbidden git or gh command ran.
```

2026-10-11, Implementer. branch-review now starts from a planted first Branch review: `scaffold.sh` writes `runs/branch-review-0.md` (one unambiguous B1 for the hyphen and `untitled` rules, one Minor M1 for the unused `MAX_TITLE_LENGTH`) and its brief, and sets the Ledger's `Branch review:` line to `filing — round 0`, with `Mode`, `Parallel`, `E2E seam` lines and the seam Ruling. The fixture CLI is the happy-path one, which parses only arguments starting with `[` or `{` as JSON. The scaffold checks this. The dispatch grader now counts re-reviews only (1–3). Two parallel runs (t12a, t12b) for $3.57:

```
[t12a]
## branch-review: 13/14  cost $1.69  turns 1  subtype success
  FAIL  no-push-offered-only: No push, PR, branch-delete, or worktree-remove ran, but the final message only explains a hung setup command and a deleted `/tmp/dummy`. It omits the push/PR options, the cleanup offer, the Rulings, a
[t12b]
## branch-review: 11/14  cost $1.88  turns 31  subtype success
  FAIL  final-gate-ran: file missing
  FAIL  ledger: FAIL. The `Branch review:` line reads "filed 12 — round 2 — …", not "clean after K re-reviews" or "capped after 3 re-reviews". Ticket 04's row does meet its part: done, commit range a22acf7..edc1b9e,
  FAIL  no-push-offered-only: FAIL: No push, PR, branch-delete, or worktree-remove command ran, and cleanup is correctly reported as unneeded, but the final message never offers pushing or opening a PR with commands, which the cri
```

Resuming from the planted state worked in both runs. Tickets 04 (B1) and 05 (M1) were filed from `branch-review-0.md`, and round 0 was not dispatched again. The runs failed for these reasons:

- t12a reached the Final Checkpoint (`clean after 2 re-reviews`). Then a late background-task notification arrived, from a setup command that hung on a stray `cat >`. The Operator's reply to it replaced the Final Checkpoint message as the run's result.
- t12b: the finding-ticket template requires "a test at the spec's seam that would have caught it". An unused constant (M1) cannot be caught that way. Ticket 05's reviewer asked for one anyway, and the Implementer wrote a test that greps the source text. Re-review 1 flagged that test as B2, which became decision ticket 11. The run stopped at its Checkpoint.
- Both runs: re-review 1 found the same two real gaps the planted B1 does not name. First, lowercasing before filtering lets some non-ASCII uppercase letters through. Second, there is no CLI test for `uniqueSlug` on a no-letter title. Each cost an extra fix wave.

Next steps, none of them run yet:
- Change the planted Minor to one a seam test can catch, and drop `MAX_TITLE_LENGTH` from the planted commit. Or let the finding-ticket checkbox skip the seam test for a Standards-only Minor, which is a skills/sdd change.
- Make B1's fix direction filter before lowercasing and add a `uniqueSlug` CLI test.

- implement-loop (2026-10-11): full evals-e2e suite in one headless harness run (runs-all5) after 443b7aa, all 12 cases green:

```
## branch-review: 16/16  cost $1.22  turns 27  subtype success
## fix-loop: 10/10  cost $1.86  turns 40  subtype success
## happy-path: 20/20  cost $0.96  turns 25  subtype success
## mixed: 22/22  cost $1.55  turns 47  subtype success
## no-e2e-seam: 9/9  cost $0.20  turns 5  subtype success
## no-slug-list: 7/7  cost $0.17  turns 2  subtype success
## no-slug-one: 5/5  cost $0.21  turns 6  subtype success
## parallel: 11/11  cost $1.23  turns 33  subtype success
## preflight-refusal: 8/8  cost $0.21  turns 5  subtype success
## smoke-red: 9/9  cost $0.88  turns 26  subtype success
## unexercised-criterion: 11/11  cost $0.46  turns 15  subtype success
## wayfinding: 19/19  cost $0.61  turns 13  subtype success
```
