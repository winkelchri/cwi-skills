# 02 — Unique slugs

**What to build:** Export `uniqueSlug(title, taken)` from `src/slug.js`. It returns `slugify(title)`, or, when that slug is in the array `taken`, the first of `<slug>-2`, `<slug>-3`, ... that is not in `taken`.

**Blocked by:** 01

**Status:** claimed

- [ ] `node bin/slug.js uniqueSlug "Hello World" '[]'` prints `hello-world`, tested at the end-to-end seam
- [ ] `node bin/slug.js uniqueSlug "Hello World" '["hello-world","hello-world-2"]'` prints `hello-world-3`, tested at the end-to-end seam
