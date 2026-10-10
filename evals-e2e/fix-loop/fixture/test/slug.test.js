import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify } from "../src/slug.js";

test("slugify lowercases, trims and joins words with -", () => {
  assert.equal(slugify("  Hello   World "), "hello-world");
});

test("slugify cuts long slugs back to the last whole word within 20 characters", () => {
  assert.equal(slugify("The quick brown fox jumps"), "the-quick-brown-fox");
});
