# Report ticket 02

- tdd skill loaded: yes
- Changed: src/slug.js (`uniqueSlug`), test/slug.test.js, test/cli.test.js
- Tests added: "uniqueSlug returns the slug when it is free"; "uniqueSlug appends the first free numeric suffix"; "slug uniqueSlug prints the first free slug"
- Gate: `npm test` -> pass 8, fail 0
- Concerns: none. Every spec rule is covered.

## Evidence

- "`uniqueSlug` behaves as described, tested at the spec's seam" — test "uniqueSlug appends the first free numeric suffix" — ok; `node bin/slug.js uniqueSlug "Hello World" '["hello-world"]'` — hello-world-2

STATUS: DONE — <sha>; npm test: 8 pass, 0 fail
