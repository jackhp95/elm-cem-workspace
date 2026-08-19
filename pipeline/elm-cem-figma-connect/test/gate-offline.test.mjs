// test/gate-offline.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import { resolveFigmaRender } from "../src/visual/gate.mjs";

test("resolveFigmaRender returns a captured render path when present + non-degenerate", () => {
  const captures = { meta: {}, captures: { "1:1": { setName: "X", variants: [
    { variantNodeId: "1:2", boundsPx: { w: 100, h: 40 }, renderPath: "captures/1-1/1-2.png", degenerate: false },
  ] } } };
  assert.deepEqual(resolveFigmaRender(captures, "1:2"), { renderPath: "captures/1-1/1-2.png", boundsPx: { w: 100, h: 40 } });
});

test("resolveFigmaRender returns null for a missing OR degenerate capture (=> caller falls back to live)", () => {
  const captures = { meta: {}, captures: { "1:1": { setName: "X", variants: [
    { variantNodeId: "1:2", boundsPx: { w: 1, h: 1 }, renderPath: "captures/1-1/1-2.png", degenerate: true },
  ] } } };
  assert.equal(resolveFigmaRender(captures, "1:2"), null);
  assert.equal(resolveFigmaRender(captures, "9:9"), null);
  assert.equal(resolveFigmaRender(null, "1:2"), null);
});
