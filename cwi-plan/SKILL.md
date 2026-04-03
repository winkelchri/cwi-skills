---
name: cwi-plan
description: >-
  Create a plan.md that clearly describes intention, target condition,
  and implementation approach so the user can confirm before coding.
allowed-tools: Read, Grep, Glob, Write, Edit
effort: high
argument-hint: "[what to plan]"
---

Follow these steps to create the plan:

1. Read research.md deeply to understand the project structure.
   If research.md links to topic files in `docs/research/`,
   read those too.
2. If the user did not specify what to plan, ask them
3. If the user's instructions are ambiguous, ask for clarification
4. Challenge the user's intention if you disagree — explain your
   reasoning and propose an alternative
5. Clean up any previous plan.md file
6. Create plan.md using the structure from
   [plan-template.md](plan-template.md)

## Content rules

The plan exists so the user can **confirm intention and approach**
before any code is written. Every section must earn its place:

- **Intention**: Explain *what problem* we are solving and *why* it
  matters. Do not just restate the user's request — add the context
  that makes the motivation clear.
- **Target Condition**: Describe the concrete, observable end state.
  The reader should be able to tell whether implementation succeeded
  by checking this section alone.
- **Tasks**: Each task must include a short description of *what*
  will be done and *how* (approach, key files, relevant APIs). A bare
  checkbox like `- [ ] Refactor auth` is never acceptable — always
  add enough detail for the user to evaluate the approach.
- **Code snippets**: Include them when the approach is non-obvious or
  when the user needs to confirm a specific API usage, data shape, or
  algorithm. Keep snippets short and focused.
- **Design Decisions**: Document every non-trivial choice and its
  rationale so the user can push back before implementation.

## Markdown compliance

The generated plan.md **must** be clean Markdown:

- Lines must not exceed 80 characters (wrap prose, use short
  headings). Code blocks are exempt only when a single token like a
  URL or import path is longer than 80 characters.
- One blank line before and after every heading.
- Heading levels must not skip (no `##` followed by `####`).
- No trailing whitespace, no multiple consecutive blank lines.
- Lists use `-` for unordered items and `1.` for ordered items.
- Fenced code blocks must have a language identifier.

Create a plan for: $ARGUMENTS
