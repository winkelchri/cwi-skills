# 10 — Retire the old loops

**What to build:** Now that `/sdd` covers both, remove the developer's old user-level `implement-loop` and `wayfinder-loop` skills. That leaves a single orchestrator. The developer must confirm first, because this deletes files outside the repo.

**Blocked by:** 03, 06, 07, 08, 09

**Status:** done

- [ ] All `/sdd` eval cases pass
- [x] The developer confirmed the deletion
- [x] `implement-loop` and `wayfinder-loop` no longer appear among available skills

## Comments

- 2026-10-10: The developer confirmed in session deleting `~/.claude/skills/implement-loop` and `~/.claude/skills/wayfinder-loop` outright, with no backup. Both were deleted; nothing else under `~/.claude/skills/` was touched.
- Verified: `ls ~/.claude/skills/` now shows only `synced` (plus `.trash`). A headless `claude -p` asked to list its available skills returned 67 names, none of them `implement-loop` or `wayfinder-loop`.
- **Unmet, accepted by the developer:** "All `/sdd` eval cases pass" is not ticked. The default `evals/` suite passes (`claude plugin eval . --trust-plugin`: 3/3), and `claude plugin validate .` exits 0. The `evals-e2e/` cases cannot run on this machine (the eval sandbox refuses Bash-granting cases, see Build notes (ticket 02)); they are backed only by the headless runs recorded in the spec's Build notes.
- Repo wording checked: no docs, skills, agents or `CONTEXT.md` describe the old loops as current. Mentions in the spec and in earlier tickets' comments are historical and stay.
