// Task D3: src/tokens/stamp.mjs's codeSyntax stamp/unstamp script generation.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per D1's note):
//   node --test src/tokens/stamp.test.mjs
//
// OFFLINE, zero new deps, zero Figma calls. Loads the REAL checked-in
// profiles/m3-kit/tokens.json + research/figma-dumps/kit-variables.json —
// this task's whole point is asserting the MEASURED mapped-row count and
// generating scripts that are byte-stable and portable, not synthetic
// fixtures that could drift from reality.
//
// The idempotency + by-name tests EXECUTE the actual generated script text
// (via an AsyncFunction wrapping — the same "top-level await/return" shape
// the figma-use skill's harness auto-wraps) against a fake `figma` stub, so
// they exercise the real artifact's logic, not a reimplementation of it.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  DEFAULT_PATHS,
  FAMILY_ORDER,
  MAX_CHUNK,
  loadMappedRows,
  groupMappedRowsByFamily,
  chunkArray,
  codeSyntaxValue,
  familySlug,
  scriptFileName,
  buildTargets,
  buildStampPlan,
  renderStampScript,
  renderUnstampScript,
  renderSnapshotScript,
  generateStampFiles,
  dryRunDelta,
  renderDeltaTable,
} from "./stamp.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

function mkScratch() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-stamp-test-"));
}

// Executes a generated script's body (top-level await/return, no IIFE
// wrapper — exactly what use_figma expects) against a fake `figma` global.
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
async function runScript(scriptText, fakeFigma) {
  const fn = new AsyncFunction("figma", scriptText);
  return fn(fakeFigma);
}

// A minimal fake figma.variables.getLocalVariablesAsync() stub: variables is
// a Map<name, {id, codeSyntax}>; setVariableCodeSyntax/removeVariableCodeSyntax
// mutate that same object, mirroring the real Plugin API's in-place mutation.
function makeFakeFigma(variablesByName) {
  const list = [...variablesByName.entries()].map(([name, v]) => ({
    id: v.id,
    name,
    codeSyntax: v.codeSyntax ? { ...v.codeSyntax } : {},
    setVariableCodeSyntax(platform, value) {
      this.codeSyntax[platform] = value;
    },
    removeVariableCodeSyntax(platform) {
      delete this.codeSyntax[platform];
    },
  }));
  return {
    variables: {
      async getLocalVariablesAsync() {
        return list;
      },
    },
    _list: list,
  };
}

// -- loadMappedRows / grouping / chunking (unit-level) ----------------------

test("loadMappedRows: real dump — 134 mapped rows (49 Schemes + 10 Corner + 75 Static)", () => {
  const rows = loadMappedRows(DEFAULT_PATHS.tokensPath);
  assert.equal(rows.length, 134);
  const byFamily = {};
  for (const r of rows) {
    const f = r.figma.split("/")[0];
    byFamily[f] = (byFamily[f] ?? 0) + 1;
  }
  assert.deepEqual(byFamily, { Schemes: 49, Corner: 10, Static: 75 });
});

test("loadMappedRows: sorted ordinally by figma name", () => {
  const rows = loadMappedRows(DEFAULT_PATHS.tokensPath);
  const names = rows.map((r) => r.figma);
  const sorted = [...names].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
  assert.deepEqual(names, sorted);
});

test("groupMappedRowsByFamily: groups per FAMILY_ORDER (Schemes, Corner, Static — NOT alphabetical)", () => {
  const rows = loadMappedRows(DEFAULT_PATHS.tokensPath);
  const grouped = groupMappedRowsByFamily(rows);
  assert.deepEqual([...grouped.keys()], ["Schemes", "Corner", "Static"]);
  assert.equal(grouped.get("Schemes").length, 49);
  assert.equal(grouped.get("Corner").length, 10);
  assert.equal(grouped.get("Static").length, 75);
});

test("chunkArray: splits into sequential chunks of at most `size`, remainder last", () => {
  assert.deepEqual(chunkArray([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
  assert.deepEqual(chunkArray([], 40), [[]]);
  assert.deepEqual(chunkArray([1, 2, 3], 40), [[1, 2, 3]]);
});

test("codeSyntaxValue: wraps the md name in var(...) — evidence #6's exact proven form", () => {
  assert.equal(codeSyntaxValue({ md: "--md-sys-color-on-surface" }), "var(--md-sys-color-on-surface)");
});

test("familySlug: lowercase, non-alnum runs collapsed to '-'", () => {
  assert.equal(familySlug("Schemes"), "schemes");
  assert.equal(familySlug("State Layers"), "state-layers");
});

test("scriptFileName: NN-family.js for chunk 0, NN-family-K.js (1-based K) for continuations", () => {
  assert.equal(scriptFileName(1, "Schemes", 0), "01-schemes.js");
  assert.equal(scriptFileName(1, "Schemes", 1), "01-schemes-2.js");
  assert.equal(scriptFileName(2, "Corner", 0), "02-corner.js");
  assert.equal(scriptFileName(3, "Static", 0), "03-static.js");
  assert.equal(scriptFileName(3, "Static", 1), "03-static-2.js");
});

test("buildTargets: {name, value} pairs keyed by figma NAME, never the dump's id", () => {
  const targets = buildTargets([{ figma: "Schemes/On Surface", md: "--md-sys-color-on-surface" }]);
  assert.deepEqual(targets, [{ name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" }]);
});

// -- buildStampPlan: the full deterministic plan -----------------------------

test("buildStampPlan: real mapped rows -> 5 stamp scripts (Schemes split 40+9, Corner 10, Static split 40+35), 134 snapshot targets total", () => {
  const rows = loadMappedRows(DEFAULT_PATHS.tokensPath);
  const plan = buildStampPlan(rows);
  assert.deepEqual(
    plan.scripts.map((s) => [s.fileName, s.targets.length]),
    [
      ["01-schemes.js", 40],
      ["01-schemes-2.js", 9],
      ["02-corner.js", 10],
      ["03-static.js", 40],
      ["03-static-2.js", 35],
    ]
  );
  assert.equal(plan.snapshotTargets.length, 134);
  assert.equal(plan.scripts.every((s) => s.targets.length <= MAX_CHUNK), true);
});

// -- rendered script shape ----------------------------------------------------

test("renderStampScript: plain top-level await/return, no IIFE wrapper, no figma.notify/console.log", () => {
  const script = renderStampScript({
    family: "Schemes",
    chunkIndex: 0,
    chunkCount: 1,
    targets: [{ name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" }],
  });
  assert.match(script, /^\/\//); // starts with a header comment, not "(async"
  assert.doesNotMatch(script, /\(async\s*\(\s*\)\s*=>/);
  assert.doesNotMatch(script, /figma\.notify/);
  assert.doesNotMatch(script, /console\.log/);
  assert.match(script, /await figma\.variables\.getLocalVariablesAsync\(\)/);
  assert.match(script, /return \{ stamped, skipped, missing, mutatedVariableIds \}/);
});

test("renderStampScript / renderUnstampScript / renderSnapshotScript: NEVER embed a hardcoded Figma variable id (the by-name portability mandate)", () => {
  const rows = loadMappedRows(DEFAULT_PATHS.tokensPath);
  const plan = buildStampPlan(rows);
  const idLikePattern = /VariableID:/; // the dump's own id prefix (research/figma-dumps/kit-variables.json)

  for (const script of plan.scripts) {
    const stampText = renderStampScript(script);
    const unstampText = renderUnstampScript(script);
    assert.doesNotMatch(stampText, idLikePattern, `${script.fileName} (stamp) must not embed a variable id`);
    assert.doesNotMatch(unstampText, idLikePattern, `${script.fileName} (unstamp) must not embed a variable id`);
    // Every stamp script must reference the by-name lookup, not an id lookup.
    assert.match(stampText, /getLocalVariablesAsync/);
    assert.doesNotMatch(stampText, /getVariableByIdAsync/);
  }

  const snapshotText = renderSnapshotScript(plan.snapshotTargets);
  assert.doesNotMatch(snapshotText, idLikePattern);
});

// -- idempotency: EXECUTE the generated script against a fake figma stub ----

test("generated stamp script: EXECUTED against a fake figma — stamps an unset variable, is idempotent on re-run", async () => {
  const targets = [
    { name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" },
    { name: "Schemes/Primary", value: "var(--md-sys-color-primary)" },
  ];
  const script = renderStampScript({ family: "Schemes", chunkIndex: 0, chunkCount: 1, targets });

  const fake = makeFakeFigma(
    new Map([
      ["Schemes/On Surface", { id: "id-1", codeSyntax: {} }],
      ["Schemes/Primary", { id: "id-2", codeSyntax: {} }],
    ])
  );

  // First run: both variables are unset -> both stamped.
  const first = await runScript(script, fake);
  assert.deepEqual(first.stamped.sort(), ["Schemes/On Surface", "Schemes/Primary"].sort());
  assert.deepEqual(first.skipped, []);
  assert.deepEqual(first.missing, []);
  assert.equal(first.mutatedVariableIds.length, 2);
  assert.equal(fake._list.find((v) => v.name === "Schemes/On Surface").codeSyntax.WEB, "var(--md-sys-color-on-surface)");

  // Second run against the SAME (now-stamped) fake: idempotent — 0 stamped, all skipped.
  const second = await runScript(script, fake);
  assert.deepEqual(second.stamped, []);
  assert.deepEqual(second.skipped.sort(), ["Schemes/On Surface", "Schemes/Primary"].sort());
  assert.deepEqual(second.mutatedVariableIds, []);
});

test("generated stamp script: a variable already carrying the intended value is skipped; one carrying a DIFFERENT value is re-stamped; a missing name is reported, not thrown", async () => {
  const targets = [
    { name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" },
    { name: "Schemes/Primary", value: "var(--md-sys-color-primary)" },
    { name: "Schemes/Does Not Exist", value: "var(--md-sys-color-does-not-exist)" },
  ];
  const script = renderStampScript({ family: "Schemes", chunkIndex: 0, chunkCount: 1, targets });

  const fake = makeFakeFigma(
    new Map([
      ["Schemes/On Surface", { id: "id-1", codeSyntax: { WEB: "var(--md-sys-color-on-surface)" } }], // already correct
      ["Schemes/Primary", { id: "id-2", codeSyntax: { WEB: "var(--stale-slug)" } }], // wrong value
      // "Schemes/Does Not Exist" is absent entirely
    ])
  );

  const result = await runScript(script, fake);
  assert.deepEqual(result.skipped, ["Schemes/On Surface"]);
  assert.deepEqual(result.stamped, ["Schemes/Primary"]);
  assert.deepEqual(result.missing, ["Schemes/Does Not Exist"]);
  assert.deepEqual(result.mutatedVariableIds, ["id-2"]);
});

test("generated unstamp script: EXECUTED against a fake figma — restores a stamped variable's codeSyntax.WEB, idempotent on re-run, never touches an unrelated value", async () => {
  const targets = [
    { name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" },
    { name: "Schemes/Primary", value: "var(--md-sys-color-primary)" },
  ];
  const stampScript = renderStampScript({ family: "Schemes", chunkIndex: 0, chunkCount: 1, targets });
  const unstampScript = renderUnstampScript({ family: "Schemes", chunkIndex: 0, chunkCount: 1, targets });

  const fake = makeFakeFigma(
    new Map([
      ["Schemes/On Surface", { id: "id-1", codeSyntax: {} }],
      ["Schemes/Primary", { id: "id-2", codeSyntax: { WEB: "var(--not-ours)" } }], // a value we did NOT stamp
    ])
  );

  await runScript(stampScript, fake); // On Surface stamped; Primary left alone (value differs from ours -> stamped over it actually)
  // Re-set Primary back to an "unrelated" value to isolate the unstamp skip-logic test.
  fake._list.find((v) => v.name === "Schemes/Primary").codeSyntax.WEB = "var(--not-ours)";

  const result = await runScript(unstampScript, fake);
  assert.deepEqual(result.unstamped, ["Schemes/On Surface"]);
  assert.deepEqual(result.skipped, ["Schemes/Primary"]); // untouched — not our value, not blindly clobbered
  assert.equal(fake._list.find((v) => v.name === "Schemes/On Surface").codeSyntax.WEB, undefined);
  assert.equal(fake._list.find((v) => v.name === "Schemes/Primary").codeSyntax.WEB, "var(--not-ours)");

  // Re-running unstamp on the now-clean state is idempotent.
  const second = await runScript(unstampScript, fake);
  assert.deepEqual(second.unstamped, []);
  assert.deepEqual(second.skipped, ["Schemes/On Surface", "Schemes/Primary"]);
});

test("generated 00-snapshot script: EXECUTED against a fake figma — read-only, returns current codeSyntax keyed by NAME, mutates nothing", async () => {
  const targets = [
    { name: "Schemes/On Surface", value: "var(--md-sys-color-on-surface)" },
    { name: "Schemes/Missing", value: "var(--md-sys-color-missing)" },
  ];
  const snapshotScript = renderSnapshotScript(targets);

  const fake = makeFakeFigma(new Map([["Schemes/On Surface", { id: "id-1", codeSyntax: { WEB: "var(--pre-existing)" } }]]));

  const result = await runScript(snapshotScript, fake);
  assert.deepEqual(result.snapshot, { "Schemes/On Surface": { id: "id-1", codeSyntax: { WEB: "var(--pre-existing)" } } });
  assert.deepEqual(result.missing, ["Schemes/Missing"]);
  // No setVariableCodeSyntax/removeVariableCodeSyntax calls happened — codeSyntax unchanged.
  assert.deepEqual(fake._list.find((v) => v.name === "Schemes/On Surface").codeSyntax, { WEB: "var(--pre-existing)" });
});

// -- file generation: byte-stability + real committed artifacts -------------

test("generateStampFiles: real tokens.json -> writes 00-snapshot.js + 5 stamp scripts + 5 unstamp scripts (11 files)", () => {
  const scratch = mkScratch();
  try {
    const outDir = path.join(scratch, "stamp");
    const { written, plan } = generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir });
    assert.equal(written.length, 11); // 1 snapshot + 5 stamp + 5 unstamp
    assert.equal(plan.scripts.length, 5);
    assert.ok(fs.existsSync(path.join(outDir, "00-snapshot.js")));
    assert.ok(fs.existsSync(path.join(outDir, "01-schemes.js")));
    assert.ok(fs.existsSync(path.join(outDir, "01-schemes-2.js")));
    assert.ok(fs.existsSync(path.join(outDir, "02-corner.js")));
    assert.ok(fs.existsSync(path.join(outDir, "03-static.js")));
    assert.ok(fs.existsSync(path.join(outDir, "03-static-2.js")));
    assert.ok(fs.existsSync(path.join(outDir, "unstamp", "01-schemes.js")));
    assert.ok(fs.existsSync(path.join(outDir, "unstamp", "03-static-2.js")));
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("generateStampFiles: byte-stable — two independent generations produce byte-identical files", () => {
  const scratchA = mkScratch();
  const scratchB = mkScratch();
  try {
    const outA = path.join(scratchA, "stamp");
    const outB = path.join(scratchB, "stamp");
    const { written: writtenA } = generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir: outA });
    const { written: writtenB } = generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir: outB });
    assert.equal(writtenA.length, writtenB.length);
    for (const fileA of writtenA) {
      const rel = path.relative(outA, fileA);
      const fileB = path.join(outB, rel);
      assert.equal(fs.readFileSync(fileA, "utf8"), fs.readFileSync(fileB, "utf8"), `${rel} differs across generations`);
    }
  } finally {
    fs.rmSync(scratchA, { recursive: true, force: true });
    fs.rmSync(scratchB, { recursive: true, force: true });
  }
});

test("generateStampFiles: never touches a pre-existing unrelated file (e.g. README.md) already in outDir", () => {
  const scratch = mkScratch();
  try {
    const outDir = path.join(scratch, "stamp");
    fs.mkdirSync(outDir, { recursive: true });
    fs.writeFileSync(path.join(outDir, "README.md"), "hand-authored runbook\n", "utf8");

    generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir });

    assert.equal(fs.readFileSync(path.join(outDir, "README.md"), "utf8"), "hand-authored runbook\n");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("the checked-in profiles/m3-kit/stamp/ is exactly what generateStampFiles produces right now (byte-stable regen against the committed artifacts)", () => {
  const scratch = mkScratch();
  try {
    const outDir = path.join(scratch, "stamp");
    const { written } = generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir });
    for (const freshPath of written) {
      const rel = path.relative(outDir, freshPath);
      const committedPath = path.join(DEFAULT_PATHS.outDir, rel);
      assert.ok(fs.existsSync(committedPath), `${rel} is missing from the committed profiles/m3-kit/stamp/`);
      assert.equal(
        fs.readFileSync(committedPath, "utf8"),
        fs.readFileSync(freshPath, "utf8"),
        `${rel} is stale — regenerate with \`node src/tokens/stamp.mjs --profile m3-kit --out profiles/m3-kit/stamp/\``
      );
    }
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- --dry-run: delta table from the checked-in dump, no Figma call ----------

test("dryRunDelta: lists EXACTLY the 134 mapped rows, 'current' read from the checked-in dump (all null — evidence #13: 0/304 have codeSyntax), 'intended' is var(<md>)", () => {
  const delta = dryRunDelta({ tokensPath: DEFAULT_PATHS.tokensPath, variablesPath: DEFAULT_PATHS.variablesPath });
  assert.equal(delta.length, 134);
  assert.ok(delta.every((d) => d.current === null), "the checked-in dump has 0/304 codeSyntax — every 'current' must be null");
  const onSurface = delta.find((d) => d.figma === "Schemes/On Surface");
  assert.equal(onSurface.intended, "var(--md-sys-color-on-surface)");
});

test("renderDeltaTable: one block per row, variable name + current + intended", () => {
  const table = renderDeltaTable([{ figma: "Schemes/On Surface", current: null, intended: "var(--md-sys-color-on-surface)" }]);
  assert.match(table, /Schemes\/On Surface/);
  assert.match(table, /current:\s+\(none\)/);
  assert.match(table, /intended:\s+var\(--md-sys-color-on-surface\)/);
});

// -- no NUL bytes (self-review checklist item) -------------------------------

test("generated files contain no NUL byte", () => {
  const scratch = mkScratch();
  try {
    const outDir = path.join(scratch, "stamp");
    const { written } = generateStampFiles({ tokensPath: DEFAULT_PATHS.tokensPath, outDir });
    for (const file of written) {
      const buf = fs.readFileSync(file);
      assert.equal(buf.includes(0), false, `${file} contains a NUL byte`);
    }
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});
