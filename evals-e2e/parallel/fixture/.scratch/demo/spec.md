# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs and describes them.

## Testing Decisions

- One seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned values for literal example inputs.
