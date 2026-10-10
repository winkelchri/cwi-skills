# 03 — Strip punctuation

**What to build:** `slugify` also drops every character that is not a lowercase letter, a digit, whitespace or `-`, before collapsing whitespace. Example: `slugify("Hello, World!")` returns `"hello-world"`.

**Blocked by:** 02

**Status:** ready-for-agent

- [ ] `slugify` drops punctuation as described, tested at the spec's seam
