# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs, and the slug CLI prints them. A slug holds only lowercase letters, digits and single hyphens. A title with no letters or digits gives the slug `untitled`: a slug is never empty.

## Testing Decisions

- Unit seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned strings for literal example inputs.
- End-to-end seam: the slug CLI, `node bin/slug.js <function> [args...]`, run as a user runs it. `test/cli.test.js` (`node:test`, so the Gate runs it too) covers it with literal examples; every function a ticket adds or changes gets a test there. The e2e command is `sh e2e.sh`: it runs `test/cli.test.js`, then the CLI's `slugify` over every real post title in `data/titles.txt`, and fails on any empty slug.
