# 09 — Parallel tickets with Merge check

**What to build:** The Operator can optionally run independent tickets (those with no blocking path between them) in parallel, each in its own git worktree. After the parallel work merges back, a Merge check runs:

1. If there is a conflict, a fresh subagent resolves it using `mattpocock-skills:resolving-merge-conflicts`.
2. The Gate is re-run on the feature branch.
3. If the Merge check fails twice, it becomes a Checkpoint.

Sequential execution stays the default.

**Blocked by:** 04

**Status:** ready-for-agent

- [ ] Only tickets with no blocking path between them are run in parallel
- [ ] Each merge is followed by a Merge check with a green Gate
- [ ] Two failed Merge checks produce a Checkpoint item
- [ ] Runs without parallelism opted in behave exactly as before
- [ ] An eval case with two independent tickets passes
