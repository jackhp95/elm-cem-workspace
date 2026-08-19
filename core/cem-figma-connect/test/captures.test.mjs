// test/captures.test.mjs
import { test } from "node:test";
import assert from "node:assert/strict";
import {
  emptyCaptures, upsertSetCaptures, capturedSetIds, resolveCaptureByVariant,
} from "../src/capture/captures.mjs";

const SET = {
  setNodeId: "53977:33575",
  setName: "Snackbar",
  variants: [
    { variantNodeId: "53977:33611", props: { Configuration: "Text only" }, boundsPx: { w: 688, h: 96 }, renderVia: "temp-frame", contentTree: { type: "COMPONENT" }, renderPath: "captures/53977-33575/53977-33611.png", degenerate: false },
  ],
};

test("emptyCaptures has the versioned shape", () => {
  const c = emptyCaptures("m3-kit", 2);
  assert.deepEqual(c, { meta: { profile: "m3-kit", scale: 2 }, captures: {} });
});

test("upsertSetCaptures adds a set, capturedSetIds lists it, re-upsert replaces (idempotent)", () => {
  let c = emptyCaptures("m3-kit", 2);
  c = upsertSetCaptures(c, SET);
  assert.deepEqual(capturedSetIds(c), ["53977:33575"]);
  const again = upsertSetCaptures(c, SET);
  assert.deepEqual(again, c, "same set re-upserted is byte-identical");
});

test("resolveCaptureByVariant finds a variant across sets by node id; null when absent", () => {
  const c = upsertSetCaptures(emptyCaptures("m3-kit", 2), SET);
  assert.deepEqual(resolveCaptureByVariant(c, "53977:33611"), {
    renderPath: "captures/53977-33575/53977-33611.png", boundsPx: { w: 688, h: 96 }, degenerate: false,
  });
  assert.equal(resolveCaptureByVariant(c, "9:9"), null);
});

test("a degenerate variant resolves with degenerate:true (gate treats it as no-capture)", () => {
  const c = upsertSetCaptures(emptyCaptures("m3-kit", 2),
    { setNodeId: "1:1", setName: "X", variants: [{ variantNodeId: "1:2", props: {}, boundsPx: { w: 1, h: 1 }, renderVia: "definition", contentTree: {}, renderPath: "captures/1-1/1-2.png", degenerate: true }] });
  assert.equal(resolveCaptureByVariant(c, "1:2").degenerate, true);
});
