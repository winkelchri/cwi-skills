---
name: cwi-research
description: >-
  Research the codebase and write research.md. For large
  projects, split topic files into docs/research/.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
effort: max
argument-hint: "[focus-area]"
---

Research the codebase following these steps:

1. Use Glob to get a complete file listing of all source code
   files (exclude node_modules, dist, build, .git, vendor,
   __pycache__)
2. If there are more than 50 source files, ask the user what to
   focus on. Otherwise proceed.
3. Read all source files systematically — group by
   directory/module
4. **Migrate legacy layout**: If a `research/` folder exists at
   the project root, move its contents to `docs/research/` and
   remove the old `research/` folder. Update any links in
   `research.md` to point to the new paths.
5. If a research.md already exists, read it and validate its
   contents against current code. Remove any outdated
   information. Also check `docs/research/` for existing
   sub-files.
6. If the user has given specific instructions, use WebSearch to
   verify technical assumptions before including them.

## Output structure

When research is complete, decide based on project size:

**Small projects** (research fits comfortably in one file):

- Write a single `research.md` at the project root using the
  structure from [research-template.md](research-template.md).

**Larger projects** (research would exceed ~300 lines):

- Write `research.md` at the project root as an **index** —
  it contains the Overview section and a linked list of topic
  files, but not the full detail.
- Write detailed topic files into `docs/research/`, one per
  major area (e.g., `docs/research/architecture.md`,
  `docs/research/auth-flow.md`).
- Each topic file should be self-contained with a clear heading
  and scope.
- Use the structure from
  [research-index-template.md](research-index-template.md) for
  the index and
  [research-template.md](research-template.md) for the overall
  section structure.

## Markdown compliance

All generated files **must** be clean Markdown:

- Lines must not exceed 80 characters (wrap prose). Code blocks
  are exempt when a single token exceeds 80 characters.
- One blank line before and after every heading.
- Heading levels must not skip (no `##` followed by `####`).
- No trailing whitespace, no multiple consecutive blank lines.
- Lists use `-` for unordered items and `1.` for ordered items.
- Fenced code blocks must have a language identifier.

If the user specified a focus area, prioritize researching:
$ARGUMENTS
