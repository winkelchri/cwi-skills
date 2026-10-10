#!/bin/bash
# Builds the branch-review fixture repo in the eval workspace (the current directory): the
# happy-path project with all three tickets already done on sdd/demo, as a /sdd run leaves it
# when interrupted right after its first Branch review returned, before filing any ticket.
# This case's spec adds rules that no ticket repeats: a slug holds only single hyphens, never
# starts or ends with "-", and is "untitled" for a title with no letters or digits. The
# planted commits follow the tickets literally, so slugify("- Hello -") returns "--hello--".
# Each ticket passed review alone; the rules span them. Ticket 03's commit also declares an
# unused MAX_TITLE_LENGTH constant. The planted Branch review (planted/branch-review-0.md)
# reports both: one unambiguous finding B1 and one Minor M1, no judgement call, so the
# headless run never needs the human. The Ledger's `Branch review:` line is at `filing`, so
# the resumed run files tickets from that review, then live re-reviews follow.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
cp -R "$here/../happy-path/fixture/." .
cp "$here/spec.md" .scratch/demo/spec.md
mv gitignore .gitignore
git init -q -b main .
git config user.name "sdd eval"
git config user.email "sdd-eval@example.invalid"
git add -A -- . ':!.scratch'
git commit -q -m "chore: fixture"
base="$(git rev-parse HEAD)"
git switch -q -c sdd/demo

commit() { # <ticket> <subject>
  git add src/slug.js test/slug.test.js test/cli.test.js
  git commit -q -m "$2 (ticket $1)"
  sha="$(git rev-parse --short HEAD)"
  sed -i "s/^\*\*Status:\*\* ready-for-agent/**Status:** done ($sha)/" .scratch/demo/issues/"$1"-*.md
  echo "| $1 | done | $prev..$sha | PASS after 0 fix rounds | |" >> "$rows"
  prev="$sha"
}
rows="$(mktemp)"
prev="${base:0:7}"

cat > src/slug.js <<'JS'
export function slugify(title) {
  return title.toLowerCase().trim().replace(/\s+/g, "-");
}
JS
cat > test/slug.test.js <<'JS'
import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify } from "../src/slug.js";

test("slugify lowercases, trims and joins words with one hyphen", () => {
  assert.equal(slugify("  Hello   World "), "hello-world");
});
JS
cat >> test/cli.test.js <<'JS'

test("slug slugify prints the slug of a title", () => {
  assert.equal(slugCli("slugify", "  Hello   World "), "hello-world");
});
JS
commit 02 "feat: add slugify"

cat > src/slug.js <<'JS'
const MAX_TITLE_LENGTH = 200;

export function slugify(title) {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-");
}
JS
cat >> test/slug.test.js <<'JS'

test("slugify drops punctuation", () => {
  assert.equal(slugify("Hello, World!"), "hello-world");
});
JS
cat >> test/cli.test.js <<'JS'

test("slug slugify drops punctuation", () => {
  assert.equal(slugCli("slugify", "Hello, World!"), "hello-world");
});
JS
commit 03 "feat: strip punctuation in slugify"

cat >> src/slug.js <<'JS'

export function uniqueSlug(title, taken) {
  const slug = slugify(title);
  if (!taken.includes(slug)) return slug;
  let n = 2;
  while (taken.includes(`${slug}-${n}`)) n++;
  return `${slug}-${n}`;
}
JS
sed -i 's/import { slugify } from/import { slugify, uniqueSlug } from/' test/slug.test.js
cat >> test/slug.test.js <<'JS'

test("uniqueSlug appends the first free suffix", () => {
  assert.equal(uniqueSlug("Hello World", []), "hello-world");
  assert.equal(uniqueSlug("Hello World", ["hello-world"]), "hello-world-2");
  assert.equal(uniqueSlug("Hello World", ["hello-world", "hello-world-2"]), "hello-world-3");
});
JS
cat >> test/cli.test.js <<'JS'

test("slug uniqueSlug prints the first free slug", () => {
  assert.equal(slugCli("uniqueSlug", "Hello World", '["hello-world"]'), "hello-world-2");
});
JS
commit 01 "feat: add uniqueSlug"

head="$(git rev-parse HEAD)"
skills="$(ls -d "$HOME"/.claude/plugins/cache/*/mattpocock-skills/*/skills 2>/dev/null | sort -V | tail -1)"
mkdir -p .scratch/demo/runs
for f in branch-review-brief-0.md branch-review-0.md; do
  sed -e "s|<base>|$base|" -e "s|<skills>|$skills|" "$here/planted/$f" > .scratch/demo/runs/"$f"
done
# The fixture CLI must JSON-parse only arguments that start with [ or {, so a title such as 2024
# stays a string.
grep -qF '/^[[{]/' bin/slug.js

cat > .scratch/demo/ledger.md <<LEDGER
# Ledger — demo

## Run

- Mode: ticket
- Branch: sdd/demo (base $base)
- Parallel: off
- Gate: \`npm test\`
- E2E seam: \`node --test test/cli.test.js\`
- Skills root: $skills
- Branch review: filing — round 0 — .scratch/demo/runs/branch-review-0.md — wave base $head

## Tickets

| Ticket | Outcome | Commits | Review | Notes |
|---|---|---|---|---|
$(cat "$rows")

## Rulings

- Gate is \`npm test\` — CLAUDE.md names it, no typecheck — cost if wrong: broken work counted as done
- Switched from \`main\` to \`sdd/demo\` — run started on the default branch — cost if wrong: commits land on a branch to merge
- E2E seam is \`node --test test/cli.test.js\` — spec Testing Decisions, runs the CLI as a user does — cost if wrong: work counted as done that no user path exercises

## Checkpoints

## Deferred findings
LEDGER
rm -f "$rows"
