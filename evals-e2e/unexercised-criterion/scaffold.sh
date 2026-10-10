#!/bin/bash
# Resumes a /sdd run interrupted after ticket 02's build commit passed verification (Ledger
# outcome `in review`). The planted commit is correct, but only the first of ticket 02's
# two criteria is exercised by a test: the report "proves" the second (hello-world-3) by
# reading the loop. The Ticket reviewer must flag it as a spec failure (Missing, not
# exercised), and the fix round must close it with a test at the e2e seam. Ticket 03 is a
# decision blocked by 02, so the run stops at a Checkpoint instead of a Branch review.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
rm -rf .scratch
mkdir -p .scratch/demo/issues .scratch/demo/runs
cp "$here/spec.md" .scratch/demo/spec.md
cp "$here"/0*.md .scratch/demo/issues/
mv gitignore .gitignore
cat > src/slug.js <<'JS'
export function slugify(title) {
  return title.trim().toLowerCase().replace(/\s+/g, "-");
}
JS
head -7 "$here/planted/slug.test.js" | sed 's/import { slugify, uniqueSlug }/import { slugify }/' > test/slug.test.js
head -15 "$here/planted/cli.test.js" > test/cli.test.js
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture with ticket 01 built"
base="$(git rev-parse HEAD)"
git switch -q -c sdd/demo
cp "$here/planted/slug.js" src/slug.js
cp "$here/planted/slug.test.js" test/slug.test.js
cp "$here/planted/cli.test.js" test/cli.test.js
git add src/slug.js test/slug.test.js test/cli.test.js
git commit -q -m "feat: add uniqueSlug (ticket 02)"
head="$(git rev-parse --short HEAD)"
sed "s/<sha>/$head/" "$here/planted/report.md" > .scratch/demo/runs/02-report.md
cat > .scratch/demo/ledger.md <<LEDGER
# Ledger — demo

## Run

- Mode: ticket
- Branch: sdd/demo (base $base)
- Parallel: off
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
