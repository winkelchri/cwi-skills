import { test } from "node:test";

test("slug module loads", async () => {
  await import("../src/slug.js");
});
