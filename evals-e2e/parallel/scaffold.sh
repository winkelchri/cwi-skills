#!/bin/bash
# Builds the parallel fixture repo in the eval workspace (the current directory): the
# happy-path project files with this case's own spec and tickets. Tickets 01 and 02 are
# independent but both add to src/slug.js and create test/slug.test.js, so the second
# merge back conflicts; ticket 03 is blocked by both.
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
