# Transliteration libraries (vendored comparison)

Collected from each project's README on 2026-09-01.

| Library | Version | Scripts covered | Runtime dependencies | Licence |
|---|---|---|---|---|
| `asciify-lite` | 2.1.0 | Latin, Greek | none | MIT |
| `polyglot-ascii` | 0.9.3 | Latin, Greek, Cyrillic, Han (pinyin), Kana | none | ISC |
| `translit-max` | 5.0.1 | Latin, Greek, Cyrillic, Han, Arabic, Hebrew | 4 (`lodash`, `xregexp`, `iconv-lite`, `debug`) | GPL-3.0 |

Notes:

- `polyglot-ascii` returns an empty string for characters it cannot map.
- `translit-max` throws on unmapped characters unless `{ strict: false }` is passed.
- `asciify-lite` leaves unmapped characters in place.
