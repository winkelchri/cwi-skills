# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs and describes them.

## Testing Decisions

- Unit seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned values for literal example inputs.
- End-to-end seam: the slug CLI, `node bin/slug.js <function> [args...]`, run as a user runs it by `test/cli.test.js` (`node:test`, so the Gate runs it too). The e2e command is `node --test test/cli.test.js`. Every function a ticket adds or changes gets a test there that runs the CLI.
