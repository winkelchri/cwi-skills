# 01 — Slugify

**What to build:** Export `slugify(title)` from `src/slug.js`. It lowercases the title, drops every character that is not a lowercase letter, a digit, whitespace or `-`, trims it and replaces each run of whitespace with one `-`. Example: `slugify("Hello, World!")` returns `"hello-world"`.

**Blocked by:** None — can start immediately.

**Status:** claimed

- [ ] `node bin/slug.js slugify "Hello, World!"` prints `hello-world`, tested at the end-to-end seam
