# 09 — Parallel tickets with Merge check

**What to build:** The Operator can optionally run independent tickets (those with no blocking path between them) in parallel, each in its own git worktree. After the parallel work merges back, a Merge check runs:

1. If there is a conflict, a fresh subagent resolves it using `mattpocock-skills:resolving-merge-conflicts`.
2. The Gate is re-run on the feature branch.
3. If the Merge check fails twice, it becomes a Checkpoint.

Sequential execution stays the default.

**Blocked by:** 04

**Status:** done

- [x] Only tickets with no blocking path between them are run in parallel
- [x] Each merge is followed by a Merge check with a green Gate
- [ ] Two failed Merge checks produce a Checkpoint item
- [x] Runs without parallelism opted in behave exactly as before
- [ ] An eval case with two independent tickets passes

## Comments

- Built: `/sdd <slug> --parallel` opt-in (`Parallel: on|off` in the Ledger), the Parallel tickets and Merge check sections in `skills/sdd/SKILL.md`, worktree and merge briefs in `agents/implementer.md`, a parallel note in `permissions.md`, and the `evals-e2e/parallel` case. Evidence is in the spec's "Build notes (ticket 09)".
- Eval box left unticked: the case needs Bash, which `claude plugin eval` cannot grant on this machine. Two headless `--parallel` runs on its fixture met every grader by hand. The default suite (`claude plugin eval . --trust-plugin`) passes 3/3.
- "Only tickets with no blocking path" was exercised only with the simple shape (01 and 02 independent, 03 blocked by both): 01 and 02 ran in parallel, 03 waited for both merges. A batch of three, and a graph where two workable tickets share a blocking path, were not exercised.
- "Two failed Merge checks produce a Checkpoint item" is left unticked: not exercised. Both conflicting merges passed at attempt 1. Also not exercised: Merge check attempt 2 on Opus, `git merge --abort` after two failures, a merge committed by the resolver, the `parallel check failed` item, the run-branch-moved stall, resuming a `built` or `building in worktree` ticket or an in-progress merge, fix rounds for a merged ticket, and `--parallel` in Manual or acceptEdits mode (the hook does not check `Bash(git merge:*)`; `permissions.md` lists it).
- Known gap: a worktree is a fresh checkout without ignored files (installed dependencies), so the Gate may not run inside it; the Implementer then reports `BLOCKED`. Gates that discover tests under `.claude/worktrees/` would run them twice; `node --test` skips dot directories.
