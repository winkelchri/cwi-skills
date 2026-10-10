#!/bin/sh
# End-to-end run: the CLI tests, then the CLI over every real post title. Fails on an empty slug.
node --test test/cli.test.js || exit 1
status=0
while IFS= read -r title; do
  slug=$(node bin/slug.js slugify "$title") || { echo "e2e: CLI failed for title: $title"; status=1; continue; }
  [ -n "$slug" ] || { echo "e2e: FAIL empty slug for title: $title"; status=1; }
done < data/titles.txt
[ "$status" -eq 0 ] && echo "e2e: ok, every title has a slug"
exit "$status"
