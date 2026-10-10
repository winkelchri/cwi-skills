# Unicode normalization (vendored notes)

Source: summary of Unicode Standard Annex #15, kept here for offline reading.

- **NFC** composes characters: `e` + U+0301 COMBINING ACUTE ACCENT becomes one code point, `é` (U+00E9).
- **NFD** decomposes them: `é` becomes `e` followed by U+0301. Removing every combining mark
  (Unicode category `M`, for example with the regular expression `/\p{M}/gu`) then leaves the base letter:
  `"Crème Brûlée"` becomes `"Creme Brulee"`.
- **NFKD** decomposes like NFD and also folds compatibility characters: the ligature `ﬁ` (U+FB01)
  becomes `fi`, and the superscript `²` becomes `2`. NFD leaves both unchanged.
- **NFKC** is NFKD followed by composition, so accents come back.

In JavaScript: `title.normalize("NFKD").replace(/\p{M}/gu, "")`.

Normalization never changes the script: Cyrillic, Greek and Han characters stay as they are and
need transliteration to become ASCII.
