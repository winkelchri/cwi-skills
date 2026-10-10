# 02 — Length cap

**What to build:** Slugs need a maximum length. Export `truncateSlug(slug, max)` from `src/slug.js`: it returns `slug` unchanged when it is at most `max` characters long; otherwise it cuts it after the last whole word (a `-`-separated part) that keeps it within `max`, or hard-cuts at `max` when even the first word is longer. Examples: `truncateSlug("hello-big-world", 9)` returns `"hello-big"`; `truncateSlug("supercalifragilistic", 5)` returns `"super"`.

Then decide the product's maximum slug length. The options are 20 characters (short, shareable URLs) and 60 characters (search-engine guidance). I have not decided yet.

**Blocked by:** 01

**Status:** ready-for-human

- [ ] `truncateSlug` behaves as described, tested at the spec's seam
- [ ] The maximum slug length is chosen
