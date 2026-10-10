# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs. Every slug it returns holds only lowercase letters, digits and single hyphens, and a slug never starts or ends with `-`. A title with no letters or digits gives the slug `untitled`. Characters outside `a`–`z`, `0`–`9`, whitespace and `-` are dropped, accented letters included: `Café` gives `caf`.

## Testing Decisions

- Unit seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned strings for literal example inputs.
- End-to-end seam: the slug CLI, `node bin/slug.js <function> [args...]`, run as a user runs it by `test/cli.test.js` (`node:test`, so the Gate runs it too). The e2e command is `node --test test/cli.test.js`. Every function a ticket adds or changes gets a test there that runs the CLI.
