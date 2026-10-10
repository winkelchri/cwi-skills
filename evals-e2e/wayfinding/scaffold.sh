#!/bin/bash
# Builds the wayfinding fixture repo in the eval workspace (the current directory): a small
# slugs project with vendored research notes and a title list, and a wayfinding map under
# .scratch/demo/ with no spec and no implementation tickets. The map holds two research
# tickets (01, 02), an agent-doable task (03), a grilling ticket blocked by 02 (04) and a
# prototype ticket (05). There is no Gate: wayfinding plans, it builds nothing.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/fixture/." .
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture"
