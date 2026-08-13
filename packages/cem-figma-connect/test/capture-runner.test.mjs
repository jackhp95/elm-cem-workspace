import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { runCapture, bridgeCaptureSet } from "../extract/capture.mjs";

function tmpDir() { return fs.mkdtempSync(path.join(os.tmpdir(), "cap-")); }

// A fake capture_set: one variant per set, a 1x1 PNG payload (base64).
const PNG_1x1 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=";
async function fakeCaptureSet(setNodeId) {
  return {
    setNodeId, setName: "Set-" + setNodeId,
    variants: [{ variantNodeId: setNodeId + ":v1", props: { A: "x" }, boundsPx: { w: 10, h: 10 }, renderVia: "definition", contentTree: { type: "COMPONENT" }, imageData: PNG_1x1, degenerate: false }],
  };
}

test("runCapture writes one PNG + a sidecar per set; renderPath is relative + correct", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  await runCapture({ setNodeIds: ["1:1", "2:2"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: fakeCaptureSet });

  const c = JSON.parse(fs.readFileSync(sidecarPath, "utf8"));
  assert.deepEqual(Object.keys(c.captures).sort(), ["1:1", "2:2"]);
  const v = c.captures["1:1"].variants[0];
  assert.equal(v.renderPath, "captures/1-1/1-1-v1.png");     // ":" -> "-" in path segments
  assert.ok(!("imageData" in v), "imageData is stripped from the sidecar (it's on disk)");
  assert.ok(fs.existsSync(path.join(dir, v.renderPath)), "PNG written to disk");
});

test("bridgeCaptureSet sends the target as `nodeId` (plugin's uniform param), not `setNodeId`, with paging params", async () => {
  const calls = [];
  const fakeQuery = async (cmd, params, opts) => { calls.push({ cmd, params, opts }); return { setName: "X", variants: [], total: 0 }; };
  const capture = bridgeCaptureSet("cem-test", 2, fakeQuery);
  await capture("58:99");
  assert.equal(calls.length, 1);
  assert.equal(calls[0].cmd, "capture_set");
  assert.deepEqual(calls[0].params, { nodeId: "58:99", scale: 2, offset: 0, limit: 50 }, "wire param is nodeId (matches the plugin dispatcher), NOT setNodeId, plus offset/limit");
  assert.equal(calls[0].opts.channel, "cem-test");
});

test("bridgeCaptureSet paginates: walks offset in chunks until `total`, merges variants client-side", async () => {
  const V = (id) => ({ variantNodeId: id, props: {}, boundsPx: { w: 4, h: 4 }, renderVia: "definition", imageData: "x", degenerate: false });
  const calls = [];
  // A 5-variant set served 2 at a time (chunk=2): expect offsets 0,2,4 -> 3 pages.
  const fakeQuery = async (cmd, params) => {
    calls.push(params.offset);
    const all = ["a", "b", "c", "d", "e"];
    const page = all.slice(params.offset, params.offset + params.limit).map(V);
    return { setName: "Big", variants: page, total: all.length, offset: params.offset };
  };
  const capture = bridgeCaptureSet("cem-test", 2, fakeQuery, 2);
  const res = await capture("9:9");
  assert.deepEqual(calls, [0, 2, 4], "offsets walked in chunk-of-2 steps");
  assert.equal(res.variants.length, 5, "all pages merged");
  assert.deepEqual(res.variants.map((v) => v.variantNodeId), ["a", "b", "c", "d", "e"]);
  assert.equal(res.setName, "Big");
});

test("bridgeCaptureSet throws with the set id + offset + plugin error on a rejected page", async () => {
  const capture = bridgeCaptureSet("cem-test", 2, async () => ({ error: "nodeId required" }));
  await assert.rejects(() => capture("58:99"), /capture_set\(58:99@0\): nodeId required/);
});

test("runCapture keeps an error variant (no imageData) without writing a PNG or throwing", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  const mixed = async (setNodeId) => ({
    setNodeId, setName: "Mixed",
    variants: [
      { variantNodeId: setNodeId + ":ok", props: {}, boundsPx: { w: 10, h: 10 }, renderVia: "definition", contentTree: {}, imageData: PNG_1x1, degenerate: false },
      { variantNodeId: setNodeId + ":bad", props: { A: "y" }, error: "export failed" },
    ],
  });
  await runCapture({ setNodeIds: ["9:9"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: mixed });

  const c = JSON.parse(fs.readFileSync(sidecarPath, "utf8"));
  const vs = c.captures["9:9"].variants;
  const ok = vs.find((v) => v.variantNodeId === "9:9:ok");
  const bad = vs.find((v) => v.variantNodeId === "9:9:bad");
  assert.ok(fs.existsSync(path.join(dir, ok.renderPath)), "good variant's PNG written");
  assert.equal(bad.error, "export failed", "error record preserved");
  assert.ok(!("renderPath" in bad), "no renderPath for an error variant");
  assert.ok(!("imageData" in bad), "no imageData leaked to the sidecar");
});

test("runCapture skips a set whose capture throws (e.g. timeout) and continues the sweep", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  const flaky = async (setNodeId) => {
    if (setNodeId === "2:2") throw new Error("Timeout after 300000ms waiting for response to 'capture_set'");
    return fakeCaptureSet(setNodeId);
  };
  const { captures, skipped } = await runCapture({ setNodeIds: ["1:1", "2:2", "3:3"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: flaky });

  assert.deepEqual(Object.keys(captures.captures).sort(), ["1:1", "3:3"], "the two good sets captured, the thrower skipped");
  assert.equal(skipped.length, 1);
  assert.equal(skipped[0].setNodeId, "2:2");
  assert.match(skipped[0].error, /Timeout/);
  // Skipped set stays uncaptured -> a later resume retries it.
  const onDisk = JSON.parse(fs.readFileSync(sidecarPath, "utf8"));
  assert.ok(!("2:2" in onDisk.captures), "skipped set not persisted");
});

test("runCapture is resumable: a second run skips already-captured sets", async () => {
  const dir = tmpDir();
  const sidecarPath = path.join(dir, "figma-captures.json");
  const rendersRoot = path.join(dir, "captures");
  const seen = [];
  const spy = async (id) => { seen.push(id); return fakeCaptureSet(id); };

  await runCapture({ setNodeIds: ["1:1"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy });
  await runCapture({ setNodeIds: ["1:1", "2:2"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy });
  assert.deepEqual(seen, ["1:1", "2:2"], "1:1 captured once, only 2:2 on the resume");

  // --force re-captures everything.
  await runCapture({ setNodeIds: ["1:1"], profile: "m3-kit", scale: 2, sidecarPath, rendersRoot, captureSet: spy, force: true });
  assert.deepEqual(seen, ["1:1", "2:2", "1:1"]);
});
