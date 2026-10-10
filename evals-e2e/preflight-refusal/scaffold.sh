#!/bin/bash
# Builds the happy-path fixture repo in the eval workspace (the current directory),
# plus one failing test, so the Gate is already red before /sdd starts.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
mv gitignore .gitignore
cat > test/legacy.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";

test("legacy behaviour still holds", () => {
  assert.equal(1 + 1, 3);
});
JS
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A
git commit -q -m "chore: fixture with a red Gate"
