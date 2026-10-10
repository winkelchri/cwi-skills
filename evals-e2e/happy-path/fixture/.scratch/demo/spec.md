# Spec: slugs

Status: ready-for-agent

## Solution

`src/slug.js` turns titles into URL slugs.

## Testing Decisions

- One seam: the functions exported from `src/slug.js`, tested with `node:test` in `test/slug.test.js`.
- Tests assert returned strings for literal example inputs.
