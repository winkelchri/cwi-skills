#!/usr/bin/env node
// The slug CLI: `node bin/slug.js <function> [args...]` calls the function of that name
// exported from src/slug.js and prints its result. An argument that starts with `[` or `{`
// is passed as parsed JSON (`'["a"]'` is an array); any other argument is passed as a
// string, so a title such as `2024` stays a string.
// With no function name it prints the exported names.
import * as slug from "../src/slug.js";

const [name, ...raw] = process.argv.slice(2);
const names = Object.keys(slug).filter((k) => typeof slug[k] === "function");
if (!name) {
  console.log(`usage: slug <function> [args...]\nfunctions: ${names.join(", ") || "(none yet)"}`);
  process.exit(0);
}
if (!names.includes(name)) {
  console.error(`slug: unknown function "${name}"`);
  process.exit(2);
}
const args = raw.map((a) => {
  if (!/^[[{]/.test(a)) return a;
  try {
    return JSON.parse(a);
  } catch {
    return a;
  }
});
const out = slug[name](...args);
console.log(typeof out === "string" ? out : JSON.stringify(out));
