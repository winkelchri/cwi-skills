---
name: cwi-research-parallel
description: >-
  Research the codebase by spawning one agent per
  topic in parallel, then assemble the index.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, Agent, Skill, WebSearch, WebFetch
effort: max
argument-hint: "[focus-area]"
---

Research the codebase by partitioning it into
disjoint topics, dispatching one agent per topic in
parallel, then writing the index. Each topic file
is self-contained context for future LLM reads, so
prioritize brevity.

## Phase 1 — partition (serial, main thread)

1. Glob source files (exclude node_modules, dist,
   build, .git, vendor, __pycache__).
2. If >50 source files, ask user what to focus on.
3. Skim directory structure and entry points to
   identify topics.
4. If `research/` exists at project root, move
   contents to `docs/research/` and update links.
5. If `research.md` and `docs/research/` exist,
   read them — reuse topic slugs where the scope
   still fits, mark stale ones for refresh.
6. Decide a topic list. Each entry has:
   - `slug`: kebab-case (e.g. `auth-flow`)
   - `path`: `docs/research/<slug>.md`
   - `scope`: one sentence stating what IS covered
     and what is NOT (point to the owning topic for
     boundary cases)
7. Validate: paths disjoint, every major area
   covered exactly once, 3–8 topics total. Merge
   thin topics into neighbors.

## Phase 2 — dispatch (parallel)

Spawn one Agent per topic in a **single message**
with multiple Agent tool calls so they run
concurrently. Use `subagent_type: general-purpose`
— workers must Write their topic file, which the
read-only `Explore` agent cannot do.

Pass `model: claude-sonnet-4-6` on each Agent call
— workers do narrow, single-topic research. Opus
reasoning not needed, and Sonnet thinking tokens
are far cheaper.

Each agent prompt MUST include:

- The topic slug, exact output path, and scope
  (what IS / what is NOT).
- Instruction to write `docs/research/<slug>.md`
  using the section template below.
- Size cap: <80 lines.
- Markdown rules (see bottom).
- **Caveman writing style** (see "Token efficiency"
  below) — file content is LLM-only, so compress
  prose. Code refs and fenced blocks unchanged.
- **Thinking budget**: "Topic is narrow. Do not
  deliberate alternatives. One read pass, one
  write pass. Keep any reasoning terse — caveman
  style applies to thoughts too."
- Instruction to return a one-paragraph summary
  (≤3 sentences) for the index, also in caveman
  style, plus any content it discovered that
  belongs to a different topic (so the main thread
  can route it).

Topic file template:

```markdown
# <Topic Title>

## Scope

One sentence: what this file covers.

## Behavior

What the code actually does. Reference files as
`path/to/file.ext:line`.

## Integration Points

How other parts of the system call into or depend
on this topic.

## Notable Details

Edge cases, workarounds, non-obvious decisions.
Omit if none.
```

## Phase 3 — assemble (serial, main thread)

1. Collect each agent's summary and any
   cross-topic notes.
2. Route cross-topic notes: if agent A flagged
   content owned by topic B, append it to B's file
   (or re-dispatch B if substantial).
3. Write `research.md` at project root using
   [research-index-template.md](research-index-template.md).
   Keep it <60 lines.
4. Verify each linked file exists and is non-empty.
5. Run a final markdown pass: line length, heading
   spacing, no trailing whitespace.

## Failure handling

- One agent failing does not abort the run. Note
  the gap in the index (`[Topic](...) — TODO,
  agent failed: <reason>`) and continue.
- If two agents both wrote substantial content for
  the same area despite disjoint scopes, the main
  thread picks the canonical home and moves the
  duplicate content.

## Size rules

- Research docs are LLM context — every line costs
  tokens on every future read.
- Describe what IS, not what COULD BE. No
  speculation, no alternatives-considered.
- Document behavior and integration points, not
  pre-implementation research.
- Target: <80 lines per topic file, <60 lines for
  the index.

## Token efficiency (caveman style)

All prose in `research.md` and `docs/research/*.md`
must be written in caveman style. Reference:
`caveman:caveman` skill (level: full).

Rules:

- Drop articles (a/an/the).
- Drop fillers (just, really, basically, simply,
  actually).
- Drop pleasantries and hedging.
- Fragments OK. Pattern: `[thing] [action]
  [reason]. [next step].`
- Short synonyms (big, fix, use) over long phrases
  (extensive, implement a solution for, utilize).
- **Do NOT compress**: code blocks, file paths,
  identifiers, error strings, URLs, fenced
  examples. Keep exact.
- Keep technical terms precise.

Example — uncompressed:
> The authentication middleware checks the JWT
> token on every request and rejects requests that
> have an expired or missing token.

Caveman:
> Auth middleware check JWT each request. Reject
> if expired or missing.

Optional post-step: run `caveman:compress` on each
generated file for a second pass. Skip if you want
to avoid the `.original.md` backup files it
creates.

## Reasoning cost

Thinking tokens are billed as output and dominate
cost at high effort. Levers, in order of impact:

1. **Model**: workers run on Sonnet
   (`claude-sonnet-4-6`) — see Phase 2. Opus
   thinking ~5× the price.
2. **Effort**: this skill sets `effort: max` on the
   parent because Phase 1 partition needs careful
   disjoint scoping. Drop to `high` or `medium`
   for small projects (<20 files) where partition
   is obvious.
3. **Caveman in thoughts**: instructing the model
   to think tersely helps but is not enforced. The
   caveman skill's communication mode primarily
   shapes outputs; thinking is the model's private
   scratchpad. Treat the worker thinking-budget
   line as a soft request, not a guarantee.

## Markdown rules

- Lines <=80 chars (code blocks exempt).
- Blank line before/after headings.
- No skipped heading levels.
- No trailing whitespace or consecutive blank lines.
- Lists: `-` unordered, `1.` ordered.
- Fenced code blocks need a language identifier.

If the user specified a focus area, weight the
topic partition toward it:
$ARGUMENTS
