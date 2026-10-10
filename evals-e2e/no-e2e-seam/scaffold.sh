#!/bin/bash
# The happy-path fixture with a spec whose Testing Decisions name only a unit seam: no
# command drives the product the way a user does. The CLI and its e2e test are removed, so
# nothing in the repo suggests one either. /sdd must stop at startup with an E2E seam
# Checkpoint item, before the Gate runs and before any work.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
mv gitignore .gitignore
rm -rf bin test/cli.test.js
cat > .scratch/demo/spec.md <<'SPEC'
# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs.

## Testing Decisions

- One seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned strings for literal example inputs.
SPEC
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture without an e2e seam"
