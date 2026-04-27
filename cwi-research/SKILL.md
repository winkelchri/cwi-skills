---
name: cwi-research
description: >-
  Research the codebase and write research.md. For
  large projects, split topic files into
  docs/research/.
context: fork
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, WebSearch, WebFetch
effort: max
argument-hint: "[focus-area]"
---

Research the codebase and produce concise reference
documentation. Prioritize brevity -- every line
costs tokens on every future read.

## Steps

1. Glob all source files (exclude node_modules,
   dist, build, .git, vendor, __pycache__).
2. If >50 source files, ask user what to focus on.
3. Read source files grouped by directory.
4. If `research/` exists at project root, move
   contents to `docs/research/` and update links.
5. If research.md exists, validate against code.
   Remove outdated content.
6. If user gave specific instructions, use WebSearch
   to verify technical assumptions.

## Output

**Small projects** (<300 lines of research):
single `research.md` at project root.

**Larger projects**: `research.md` as index
(overview + linked topic list), detailed files in
`docs/research/` (one per topic, self-contained).

## Size rules

- Research docs are LLM context -- keep them as
  short as possible while remaining useful.
- Describe what IS, not what COULD BE. Remove
  speculative content and alternatives-considered.
- For implemented features: document behavior and
  integration points, not the pre-implementation
  research.
- Merge trivially small topic files into neighbors.
- Target: <80 lines per topic file, <60 lines for
  the index.

## Markdown rules

- Lines <=80 chars (code blocks exempt).
- Blank line before/after headings.
- No skipped heading levels.
- No trailing whitespace or consecutive blank lines.
- Lists: `-` unordered, `1.` ordered.
- Fenced code blocks need a language identifier.

If the user specified a focus area, prioritize:
$ARGUMENTS
