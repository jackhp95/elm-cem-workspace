// Verifies extract/export.mjs's --dry stub (task A3): it must run with no
// relay/Figma at all and emit output that validates against the Task-A2
// contract (src/ingest/figma-export.schema.json) — "the schema is the
// contract, not the transport."

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { validate } from "../src/lib/validate.mjs";
import { loadFigmaExport } from "../src/ingest/figma.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const exportPath = path.join(repoRoot, "extract", "export.mjs");
const schemaPath = path.join(repoRoot, "src", "ingest", "figma-export.schema.json");

function runDry(extraArgs = []) {
  const out = path.join(os.tmpdir(), `figma-export-dry-${process.pid}-${Date.now()}.json`);
  const result = spawnSync(
    process.execPath,
    [
      exportPath,
      "--dry",
      "--file-label",
      "dry-test",
      "--file-key",
      "DRYKEY123",
      "--kit-version",
      "v0.0.0-dry",
      "--extracted-at",
      "2026-07-11T00:00:00.000Z",
      "--out",
      out,
      ...extraArgs,
    ],
    { cwd: repoRoot, encoding: "utf8" }
  );
  return { result, out };
}

test("extract/export.mjs --dry: exits 0 and writes a file with no relay or Figma running", () => {
  const { result, out } = runDry();
  try {
    assert.equal(result.status, 0, result.stderr);
    assert.ok(fs.existsSync(out), "output file was written");
  } finally {
    fs.rmSync(out, { force: true });
  }
});

test("extract/export.mjs --dry: emits output that validates against figma-export.schema.json", () => {
  const { result, out } = runDry();
  try {
    assert.equal(result.status, 0, result.stderr);
    const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
    const data = JSON.parse(fs.readFileSync(out, "utf8"));
    const { valid, errors } = validate(schema, data);
    assert.deepEqual(errors, []);
    assert.equal(valid, true);
  } finally {
    fs.rmSync(out, { force: true });
  }
});

test("extract/export.mjs --dry: meta is stamped verbatim from CLI args, not computed", () => {
  const { result, out } = runDry();
  try {
    assert.equal(result.status, 0, result.stderr);
    const data = JSON.parse(fs.readFileSync(out, "utf8"));
    assert.deepEqual(data.meta, {
      fileKey: "DRYKEY123",
      fileName: "Dry-run fixture file",
      extractedAt: "2026-07-11T00:00:00.000Z",
      kitVersionTag: "v0.0.0-dry",
    });
  } finally {
    fs.rmSync(out, { force: true });
  }
});

test("extract/export.mjs --dry: output loads via loadFigmaExport() (the real pipeline consumer)", () => {
  const { result, out } = runDry();
  try {
    assert.equal(result.status, 0, result.stderr);
    const loaded = loadFigmaExport(out);
    assert.equal(loaded.sets.length, 1);
    assert.ok(loaded.sets[0].properties, "the one COMPONENT_SET has captured setProperties");
    assert.equal(loaded.variants.length, 2);
    assert.equal(loaded.standalones.length, 1);
  } finally {
    fs.rmSync(out, { force: true });
  }
});

test("extract/export.mjs: missing required args exits non-zero with usage, does not hang trying to reach a relay", () => {
  const result = spawnSync(process.execPath, [exportPath, "--dry"], { cwd: repoRoot, encoding: "utf8" });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Missing required/);
});

test("extract/export.mjs: --help prints usage and does not require any other flag", () => {
  const result = spawnSync(process.execPath, [exportPath, "--help"], { cwd: repoRoot, encoding: "utf8" });
  assert.equal(result.status, 0);
  assert.match(result.stdout, /Usage: node extract\/export\.mjs/);
});
