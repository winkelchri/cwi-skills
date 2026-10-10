// End-to-end seam: runs the slug CLI as a user does and checks what it prints.
import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";

const slugCli = (...args) =>
  execFileSync(process.execPath, ["bin/slug.js", ...args], { encoding: "utf8" }).trimEnd();

test("the slug CLI starts and prints its usage", () => {
  assert.match(slugCli(), /^usage: slug <function>/);
});

test("slug slugify prints the slug of a title", () => {
  assert.equal(slugCli("slugify", "  Hello   World "), "hello-world");
});
