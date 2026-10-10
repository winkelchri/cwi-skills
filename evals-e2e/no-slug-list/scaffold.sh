#!/bin/bash
# Two runnable slugs (demo: tickets, maps: a wayfinding map) and one folder that is not
# runnable (notes: a spec only). A bare /sdd must list demo and maps, skip notes, and stop.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
mv gitignore .gitignore
mkdir -p .scratch/maps/issues .scratch/notes
cp -R "$here/../wayfinding/fixture/.scratch/demo/." .scratch/maps/
cp .scratch/demo/spec.md .scratch/notes/spec.md
sed -i 's/^\(\*\*Status:\*\*\) ready-for-agent/\1 done (abc1234)/' .scratch/demo/issues/02-*.md
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A
git commit -q -m "chore: fixture with two runnable slugs"
