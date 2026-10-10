# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs for the blog's post URLs.

## Implementation Decisions

- Slugs go into URLs that the old blog engine truncates at 20 characters. Every slug `src/slug.js` returns is therefore at most 20 characters long. A longer slug is cut back to the last whole word (the last `-` boundary) that fits, so it never ends in a partial word or a `-`. Example: `"The quick brown fox jumps"` gives `"the-quick-brown-fox"` (19 characters).

## Testing Decisions

- Unit seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned strings for literal example inputs.
- End-to-end seam: the slug CLI, `node bin/slug.js <function> [args...]`, run as a user runs it by `test/cli.test.js` (`node:test`, so the Gate runs it too). The e2e command is `node --test test/cli.test.js`. Every function a ticket adds or changes gets a test there that runs the CLI.
