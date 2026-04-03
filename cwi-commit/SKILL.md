---
name: cwi-commit
description: Group and commit changes in the current project
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Bash
effort: medium
argument-hint: "[commit message or grouping hint]"
---

Analyze and commit the current changes following these steps:

1. Review the current state:
   !`git status`
   !`git diff --stat`

2. Analyze all staged and unstaged changes using `git diff` (unstaged) and `git diff --cached` (staged)
3. Group related changes into logical, atomic commits — each commit should represent one coherent change (e.g., a feature, a bugfix, a refactor). If grouping is ambiguous, ask the user.
4. For each group:
   a. Stage only the relevant files using `git add <file>...`
   b. Write a conventional commit message following this format:

      ```
      <type>(<optional scope>): <short description>

      <optional body explaining why, not what>
      ```

      Types: feat, fix, refactor, chore, docs, test, style, perf, ci, build
   c. Execute `git commit`
5. After all commits, run `git log --oneline -10` to confirm the result

Rules:

- Never add "Co-Authored-By" or any attribution lines to commit messages
- Never use `git add -A` or `git add .` — always add specific files
- Never amend existing commits unless the user explicitly asks
- If the user provided a hint, use it to guide grouping or the message: $ARGUMENTS
