#!/bin/bash
# Resumes a parallel /sdd run interrupted after ticket 01 was built in a worktree (Ledger
# outcome `built — worktree-agent-planted`) but before its Merge check. The planted commit
# (on worktree-agent-planted, in its worktree under .claude/worktrees/) passes the Gate (its unit and CLI tests use ordinary titles), but turns the real title
# "???" into an empty slug, which the spec forbids. Only the smoke run (`sh e2e.sh`, the
# CLI over data/titles.txt) catches it, so Merge check attempt 1 must fail on the smoke
# run alone, and attempt 2 (a fresh Opus Implementer) must fix it before the merge is
# committed. Ticket 02 is a decision blocked by 01, so the run then stops at a Checkpoint.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
rm -rf .scratch
mkdir -p .scratch/demo/issues .scratch/demo/runs data
cp "$here/spec.md" .scratch/demo/spec.md
cp "$here"/0*.md .scratch/demo/issues/
cp "$here/e2e.sh" e2e.sh
cp "$here/titles.txt" data/titles.txt
mv gitignore .gitignore
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture"
base="$(git rev-parse HEAD)"
git switch -q -c sdd/demo
# The Implementer of an interrupted parallel run built ticket 01 in its own worktree.
git worktree add -q -b worktree-agent-planted .claude/worktrees/agent-planted
cd .claude/worktrees/agent-planted
git config user.name "sdd eval"
cat > src/slug.js <<'JS'
export function slugify(title) {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-");
}
JS
cat > test/slug.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify } from "../src/slug.js";

test("slugify drops punctuation and joins words with -", () => {
  assert.equal(slugify("Hello, World!"), "hello-world");
});
JS
cat >> test/cli.test.js <<'JS'

test("slug slugify prints the slug of a title", () => {
  assert.equal(slugCli("slugify", "Hello, World!"), "hello-world");
});
JS
git add src/slug.js test/slug.test.js test/cli.test.js
git commit -q -m "feat: add slugify (ticket 01)"
head="$(git rev-parse --short HEAD)"
cd "$OLDPWD"
cat > .scratch/demo/runs/01-report.md <<REPORT
# Report ticket 01

- tdd skill loaded: yes
- Changed: src/slug.js (\`slugify\`), test/slug.test.js, test/cli.test.js
- Tests added: "slugify drops punctuation and joins words with -"; "slug slugify prints the slug of a title"
- Gate: \`npm test\` -> pass 4, fail 0

## Evidence

- "\`node bin/slug.js slugify "Hello, World!"\` prints \`hello-world\`, tested at the end-to-end seam" — test "slug slugify prints the slug of a title" — ok

STATUS: DONE — $head; npm test: 4 pass, 0 fail
REPORT
cat > .scratch/demo/ledger.md <<LEDGER
# Ledger — demo

## Run

- Mode: ticket
- Branch: sdd/demo (base $base)
- Parallel: on
- Gate: \`npm test\`
- Skills root: $(ls -d "$HOME"/.claude/plugins/cache/*/mattpocock-skills/*/skills 2>/dev/null | sort -V | tail -1)

## Tickets

| Ticket | Outcome | Commits | Review | Notes |
|---|---|---|---|---|
| 01 | built — worktree-agent-planted | ${base:0:7}..$head | | worktree .claude/worktrees/agent-planted |

## Rulings

- Gate is \`npm test\` — CLAUDE.md names it, no typecheck — cost if wrong: broken work counted as done
- Switched from \`main\` to \`sdd/demo\` — run started on the default branch — cost if wrong: commits land on a branch to merge

## Checkpoints

## Deferred findings
LEDGER
