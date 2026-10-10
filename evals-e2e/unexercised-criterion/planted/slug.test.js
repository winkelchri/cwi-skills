import { test } from "node:test";
import assert from "node:assert/strict";
import { slugify, uniqueSlug } from "../src/slug.js";

test("slugify lowercases, trims and joins words with -", () => {
  assert.equal(slugify("  Hello   World "), "hello-world");
});

test("uniqueSlug returns the slug when it is free", () => {
  assert.equal(uniqueSlug("Hello World", []), "hello-world");
});
