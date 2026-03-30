---
name: cwi-implement-sonnet
description: Implement the plan.md using Sonnet for faster, cost-efficient execution
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Agent
model: sonnet
effort: high
---

Before implementing:

1. Read research.md for full project context
2. Read plan.md completely — understand all phases and tasks before writing any code

Implementation rules:

1. Work through plan.md phases in order, top to bottom
2. After completing each task, mark it as done in plan.md: `- [x]`
3. After each phase, run the project's test/build/lint commands to verify no regressions
4. If a test or build fails, fix it before moving to the next task
5. Do not add comments unless the logic is non-obvious
6. Do not refactor code outside the plan's scope
7. If you encounter an ambiguity or blocker not covered by the plan, stop and ask the user

Do not stop until all phases and tasks in plan.md are marked complete.
