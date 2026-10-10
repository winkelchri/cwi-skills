#!/bin/bash
# Builds the fixture repo in the eval workspace (the current directory).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/fixture/." .
mv gitignore .gitignore
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A
git commit -q -m "chore: fixture"
