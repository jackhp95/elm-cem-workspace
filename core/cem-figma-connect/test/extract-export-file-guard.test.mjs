// Fix-round test for the file-identity guard added to extract/export.mjs
// runExport(): before this fix, runExport went straight from
// get_document_info into the bulk get_component_properties loop (one call
// per COMPONENT_SET — 171 in the reported incident) with no check that the
// connected Figma file is the one the operator intended via --file-key.
//
// These tests exercise runExport() directly with hand-built bridge stubs
// (same 5-method transport-agnostic shape createDryBridge()/createWsBridge()
// implement — see extract/export.mjs) rather than spawning the CLI, so the
// bulk-loop-not-fired assertion can be made directly via a call counter.

import { test } from "node:test";
import assert from "node:assert/strict";

import { runExport } from "../extract/export.mjs";

const SET_ID = "1:100";

function makeBridge(fileKey, calls) {
  return {
    async getDocumentInfo() {
      return { name: "Some Kit File", fileKey };
    },
    async getLocalComponents() {
      calls.getLocalComponents = (calls.getLocalComponents || 0) + 1;
      return [
        { id: SET_ID, name: "Example Component", type: "COMPONENT_SET", key: "0".repeat(40), description: "", page: "Page 1" },
      ];
    },
    async getComponentProperties(nodeId) {
      calls.getComponentProperties = (calls.getComponentProperties || 0) + 1;
      return {
        id: nodeId,
        name: "Example Component",
        type: "COMPONENT_SET",
        variantCount: 1,
        properties: [{ name: "Type", type: "VARIANT", defaultValue: "Filled", variantOptions: ["Filled"] }],
      };
    },
    async getVariables() {
      return { collections: [], variables: [], libraryCollections: [], warnings: [] };
    },
    async getStyles() {
      return { paintStyles: [], textStyles: [], effectStyles: [] };
    },
  };
}

const baseArgs = { fileLabel: "guard-test", kitVersion: "v0.0.0-guard", extractedAt: "2026-07-11T00:00:00.000Z" };

test("runExport: aborts BEFORE the bulk get_component_properties loop when the connected fileKey does not match --file-key", async () => {
  const calls = {};
  const bridge = makeBridge("LIVE_UNRELATED_FILE_KEY", calls);
  await assert.rejects(
    () => runExport(bridge, { ...baseArgs, fileKey: "INTENDED_FILE_KEY" }),
    /does not match/
  );
  assert.equal(calls.getComponentProperties, undefined, "the bulk get_component_properties loop must never fire on a fileKey mismatch");
  assert.equal(calls.getLocalComponents, undefined, "get_local_components must never fire either -- the guard runs right after get_document_info");
});

test("runExport: proceeds through the bulk loop and assembles output when the connected fileKey matches --file-key", async () => {
  const calls = {};
  const bridge = makeBridge("MATCHING_FILE_KEY", calls);
  const result = await runExport(bridge, { ...baseArgs, fileKey: "MATCHING_FILE_KEY" });
  assert.equal(calls.getComponentProperties, 1, "the one COMPONENT_SET should have been queried");
  assert.equal(result.meta.fileKey, "MATCHING_FILE_KEY");
  assert.ok(result.setProperties[SET_ID], "setProperties captured for the matching-file run");
});

test("runExport: --allow-file-mismatch escape hatch skips the guard and proceeds despite a mismatched fileKey", async () => {
  const calls = {};
  const bridge = makeBridge("LIVE_UNRELATED_FILE_KEY", calls);
  const result = await runExport(bridge, { ...baseArgs, fileKey: "INTENDED_FILE_KEY", allowFileMismatch: true });
  assert.equal(calls.getComponentProperties, 1, "escape hatch lets the bulk loop run");
  assert.equal(result.meta.fileKey, "INTENDED_FILE_KEY");
});

test("runExport: no fileKey signal from the plugin (name-only fallback) warns but does not abort", async () => {
  const calls = {};
  const bridge = makeBridge(null, calls);
  const result = await runExport(bridge, { ...baseArgs, fileKey: "WHATEVER_KEY" });
  assert.equal(calls.getComponentProperties, 1, "no-fileKey case must not abort -- only a warning is logged");
  assert.equal(result.meta.fileKey, "WHATEVER_KEY");
});
