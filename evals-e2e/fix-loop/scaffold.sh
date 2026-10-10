#!/bin/bash
# Builds the fix-loop fixture repo in the eval workspace (the current directory): the
# happy-path project files with this case's own spec and tickets, as a /sdd run left it
# when interrupted after ticket 02's build commit passed verification but before its
# Ticket review. That commit (planted/) misses the spec's 20-character cap for suffixed
# slugs; its report claims every spec rule is covered.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
rm -rf .scratch
cp -R "$here/fixture/." .
mv gitignore .gitignore
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture"
base="$(git rev-parse HEAD)"
git switch -q -c sdd/demo
cp "$here/planted/slug.js" src/slug.js
cp "$here/planted/slug.test.js" test/slug.test.js
git add src/slug.js test/slug.test.js
git commit -q -m "feat: add uniqueSlug (ticket 02)"
head="$(git rev-parse --short HEAD)"
mkdir -p .scratch/demo/runs
sed "s/<sha>/$head/" "$here/planted/report.md" > .scratch/demo/runs/02-report.md
cat > .scratch/demo/ledger.md <<LEDGER
# Ledger — demo

## Run

- Branch: sdd/demo (base $base)
- Gate: \`npm test\`
- Skills root: $(ls -d "$HOME"/.claude/plugins/cache/*/mattpocock-skills/*/skills 2>/dev/null | sort -V | tail -1)

## Tickets

| Ticket | Outcome | Commits | Review | Notes |
|---|---|---|---|---|
| 02 | in review | ${base:0:7}..$head | | |

## Rulings

- Gate is \`npm test\` — CLAUDE.md names it, no typecheck — cost if wrong: broken work counted as done
- Switched from \`main\` to \`sdd/demo\` — run started on the default branch — cost if wrong: commits land on a branch to merge

## Checkpoints

## Deferred findings
LEDGER
