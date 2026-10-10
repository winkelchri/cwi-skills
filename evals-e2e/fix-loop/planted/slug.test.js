import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify, uniqueSlug } from "../src/slug.js";

test("slugify lowercases, trims and joins words with -", () => {
  assert.equal(slugify("  Hello   World "), "hello-world");
});

test("slugify cuts long slugs back to the last whole word within 20 characters", () => {
  assert.equal(slugify("The quick brown fox jumps"), "the-quick-brown-fox");
});

test("uniqueSlug returns the slug when it is free", () => {
  assert.equal(uniqueSlug("Hello World", []), "hello-world");
});

test("uniqueSlug appends the first free numeric suffix", () => {
  assert.equal(uniqueSlug("Hello World", ["hello-world"]), "hello-world-2");
  assert.equal(uniqueSlug("Hello World", ["hello-world", "hello-world-2"]), "hello-world-3");
});
