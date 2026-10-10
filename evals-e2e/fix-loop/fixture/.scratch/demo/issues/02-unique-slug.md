# 02 — Unique slugs

**What to build:** Export `uniqueSlug(title, taken)` from `src/slug.js`. It returns `slugify(title)`, or, when that slug is in the array `taken`, the first of `<slug>-2`, `<slug>-3`, ... that is not in `taken`. Example: `uniqueSlug("Hello World", ["hello-world"])` returns `"hello-world-2"`.

**Blocked by:** 01

**Status:** claimed

- [ ] `uniqueSlug` behaves as described, tested at the spec's seam
