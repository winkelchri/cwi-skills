#!/bin/bash
# Builds the mixed fixture repo in the eval workspace (the current directory): the
# happy-path project files with this case's own spec and tickets. Ticket 02 is HITL with
# agent work plus a real decision and blocks ticket 03; ticket 04 is labelled HITL but
# holds no decision.
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
