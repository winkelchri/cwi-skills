---
name: cwi-plan-refine
description: >-
  Refine plan.md — resolve user comments, fill in missing detail,
  and ensure Markdown compliance.
allowed-tools: Read, Grep, Glob, Write, Edit
effort: high
---

When refining the plan, follow these steps:

1. Read plan.md thoroughly. If the plan references research,
   also read research.md and any topic files in
   `docs/research/` for context.
2. Search for user comments (look for `<!-- -->`, `TODO:`,
   `FIXME:`, `?`, or inline questions)
3. Address every comment — update the plan text, then remove or
   resolve the comment
4. If any user instruction is ambiguous, ask for clarification
   before changing the plan
5. If you disagree with the user's direction, explain your
   reasoning and propose an alternative
6. Verify every section meets the quality bar:
   - **Intention** explains the problem and why it matters
   - **Target Condition** lists concrete, checkable criteria
   - **Tasks** each have a description of *what*, *how*, and
     which files/modules are affected — no bare checkboxes
   - **Design Decisions** documents non-trivial choices with
     rationale
7. Fix any Markdown compliance issues: lines ≤ 80 chars, blank
   lines around headings, no skipped heading levels, no trailing
   whitespace, fenced code blocks have a language identifier
8. Do NOT implement any code — only update the plan document
