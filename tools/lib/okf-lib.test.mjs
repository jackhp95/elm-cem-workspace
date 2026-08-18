// okf-lib.test.mjs — unit tests for the dependency-free OKF frontmatter reader
// and link/claim helpers.
import { test } from "node:test";
import assert from "node:assert/strict";
import { parseFrontmatter, parseYaml, extractLinks, makesDesignClaim, words, shingles, verbatimRuns } from "./okf-lib.mjs";

test("parseFrontmatter splits fence from body and reports presence", () => {
  const md = `---\ntype: concept\ntitle: Color\n---\nBody text here.\n`;
  const { data, body, hasFrontmatter } = parseFrontmatter(md);
  assert.equal(hasFrontmatter, true);
  assert.equal(data.type, "concept");
  assert.equal(data.title, "Color");
  assert.equal(body.trim(), "Body text here.");
});

test("parseFrontmatter reports no frontmatter for a plain index", () => {
  const md = `# Foundations\n\nAn index with no YAML.\n`;
  const { data, hasFrontmatter } = parseFrontmatter(md);
  assert.equal(hasFrontmatter, false);
  assert.deepEqual(data, {});
});

test("parseYaml reads inline lists", () => {
  const data = parseYaml(`tags: [foundations, a11y, focus]`);
  assert.deepEqual(data.tags, ["foundations", "a11y", "focus"]);
});

test("parseYaml reads a block list of {url,retrieved,note} maps", () => {
  const y = [
    "sources:",
    "  - url: https://m3.material.io/foundations/designing/overview",
    "    retrieved: 2026-07-11",
    "    note: The overview.",
    "  - url: https://m3.material.io/styles/color/roles",
    "    retrieved: 2026-07-11",
  ].join("\n");
  const data = parseYaml(y);
  assert.equal(data.sources.length, 2);
  assert.equal(data.sources[0].url, "https://m3.material.io/foundations/designing/overview");
  assert.equal(data.sources[0].note, "The overview.");
  assert.equal(data.sources[1].retrieved, "2026-07-11");
});

test("parseYaml strips quotes", () => {
  const data = parseYaml(`description: "A quoted, comma-bearing value"`);
  assert.equal(data.description, "A quoted, comma-bearing value");
});

test("extractLinks pulls markdown targets and skips fenced code", () => {
  const body = "See [color](/styles/color) and [rel](./layout.md).\n\n```\n[not a link](/nope)\n```\n";
  assert.deepEqual(extractLinks(body), ["/styles/color", "./layout.md"]);
});

test("makesDesignClaim fires on directive prose, not neutral prose", () => {
  assert.equal(makesDesignClaim("You should pair the on-role."), true);
  assert.equal(makesDesignClaim("Use a dialog when the task must interrupt."), true);
  assert.equal(makesDesignClaim("A button is a labeled control."), false);
});

test("words normalizes to lowercase tokens and strips code fences", () => {
  assert.deepEqual(words("Role-based COLOR.  \n```\nignored code\n```\nSystem!"), ["role", "based", "color", "system"]);
});

test("shingles yields overlapping N-word windows", () => {
  const s = shingles(["a", "b", "c", "d"], 3);
  assert.deepEqual([...s].sort(), ["a b c", "b c d"]);
  assert.equal(shingles(["a", "b"], 3).size, 0); // fewer than N words -> none
});

test("verbatimRuns flags a 15-word lift and passes a paraphrase", () => {
  const source =
    "the role based color system generates a full scheme from a single source color automatically";
  // A verbatim 15+-word run copied from the source -> flagged.
  const lifted =
    "In practice the role based color system generates a full scheme from a single source color automatically here.";
  assert.ok(verbatimRuns(lifted, source, 15).length > 0);
  // The same idea, reworded -> no 15-word identical run.
  const paraphrase =
    "Color roles let one seed color cascade into an entire accessible scheme without hand-picking values.";
  assert.equal(verbatimRuns(paraphrase, source, 15).length, 0);
});
