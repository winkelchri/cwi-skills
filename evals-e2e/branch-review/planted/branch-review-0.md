# Branch review

Fixed point: <base>

## Findings
- [B1] unambiguous — Spec — src/slug.js:3 — Slugs break the spec's character rules — The spec says "Every slug it returns holds only lowercase letters, digits and single hyphens, and a slug never starts or ends with `-`. A title with no letters or digits gives the slug `untitled`." `slugify` only trims whitespace before dropping characters and turns each whitespace run into `-`, so `slugify("- Hello -")` returns `"--hello--"`, `slugify("Hello - World")` returns `"hello---world"`, `slugify("Hello !")` returns `"hello-"`, and `slugify("!!!")` returns `""` (so `uniqueSlug("!!!", [""])` returns `"-2"`). No ticket repeats these rules, so each ticket passed alone. — After dropping characters, turn every run of whitespace and `-` into one `-`, strip `-` from both ends, and return `untitled` when nothing is left; add those four inputs as tests in `test/slug.test.js` and `test/cli.test.js`.

## Minor
- [M1] Standards — src/slug.js:1 — Unused MAX_TITLE_LENGTH constant — `const MAX_TITLE_LENGTH = 200;` is declared but never read; the spec sets no title length limit. — Delete the constant.
