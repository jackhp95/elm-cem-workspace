// Task D5: src/tokens/audit.mjs — the cross-source token mismatch audit.
//
// Run with the file-arg form:
//   node --test src/tokens/audit.test.mjs
//
// Mixes real-input tests (the actual measured counts/classifications this
// task's report is built from) with a synthetic-fixture test proving the
// audit actually DETECTS a real value disagreement (a deliberate corruption
// of one computed-palette role), per the brief's verify step.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadKitVariables } from "./ingest.mjs";
import {
  colorToHex,
  buildColorRows,
  buildNumericRows,
  listExtraModes,
  renderReport,
  runAudit,
  DEFAULT_PATHS,
  DEFAULT_TOLERANCE,
} from "./audit.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

// -- colorToHex ---------------------------------------------------------

test("colorToHex: matches the kit's own Primary Light value byte-for-byte", () => {
  assert.equal(
    colorToHex({ r: 0.40392157435417175, g: 0.3137255012989044, b: 0.6431372761726379, a: 1 }),
    "#6750A4"
  );
});

test("colorToHex: null-safe", () => {
  assert.equal(colorToHex(null), null);
  assert.equal(colorToHex(undefined), null);
});

// -- real-input color rows ------------------------------------------------

const { variables } = loadKitVariables(DEFAULT_PATHS.variablesPath);
const tokenRows = readJson(DEFAULT_PATHS.tokensPath);
const computedPalette = readJson(DEFAULT_PATHS.computedPalettePath);

test("buildColorRows: 49 Schemes rows total (37 comparable + 12 computed-unavailable *-fixed*)", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  assert.equal(rows.length, 49);
  const unavailable = rows.filter((r) => r.status === "computed-unavailable");
  assert.equal(unavailable.length, 12);
  for (const row of unavailable) {
    assert.ok(row.figma.includes("Fixed"), `expected a *Fixed* role, got ${row.figma}`);
  }
});

test("buildColorRows: fallback agrees with kit Light for essentially every role that has one (measured real-input fact backing the report's Light-only-fallback note; the on-*-container rows are the container-tone-regression's own evidence trail, so their fallback-vs-kit deltaE is small but not always exactly 0 — kept under a generous ceiling, well below the spec-failure floor of ~14)", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  for (const row of rows) {
    if (row.status === "computed-unavailable") {
      if (row.light.fallback) assert.ok(row.light.deFallback < 3.5, row.figma);
      continue;
    }
    if (row.light.fallback) assert.ok(row.light.deLightFallback < 3.5, row.figma);
  }
});

test("real inputs: every spec-failure row is one of the three investigated root causes (none unclassified)", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  const specFailures = rows.filter((r) => r.status === "spec-failure");
  assert.ok(specFailures.length > 0, "expected at least one real spec-failure on the real inputs");
  for (const row of specFailures) {
    assert.ok(
      row.rootCause === "container-tone-regression" ||
        row.rootCause === "model-divergence" ||
        row.rootCause === "tone-table-approximation-noise",
      `unclassified spec-failure: ${row.md}`
    );
  }
});

// Review finding: tertiary/on-tertiary/tertiary-container (~9.9-10.1 dE) and
// error (~5.4 dE) were previously lumped into "tone-table-approximation-noise"
// alongside genuine low-dE (~1-4.5) sampling noise. That remedy ("increase
// hue-sampling density in calibrate-tones.mjs") cannot fix these: the gap is
// a STRUCTURAL derivation choice in src/ref/palette.css (tertiary reuses
// primary's chroma with h+60; error is an independent seed), not a sampling
// issue. These 4 roles must carry the "model-divergence" root cause instead,
// and must never appear under "tone-table-approximation-noise" — see
// task-D5-report.md "Fix round".
test("real inputs: tertiary/on-tertiary/tertiary-container/error are classified 'model-divergence', not 'tone-table-approximation-noise'", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  const structuralRoles = ["tertiary", "on-tertiary", "tertiary-container", "error"];
  for (const role of structuralRoles) {
    const row = rows.find((r) => r.role === role);
    assert.ok(row, `expected a row for role "${role}"`);
    assert.equal(row.status, "spec-failure", `expected ${role} to be over tolerance (still detected)`);
    assert.equal(row.rootCause, "model-divergence", `${role} must be classified model-divergence, not noise`);
  }
  // The genuinely low-dE tone-table-noise cluster must be unaffected by the
  // reclassification — still present, still labeled noise.
  const stillNoise = rows.find((r) => r.role === "background");
  assert.equal(stillNoise.rootCause, "tone-table-approximation-noise");
});

test("renderReport: the model-divergence section names the structural fix location (palette.css), not the tone table, for tertiary/error", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  const numRows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const report = renderReport({ colorRows: rows, numericRows: numRows, extraModes: [], tolerance: DEFAULT_TOLERANCE });
  assert.match(report, /src\/ref\/palette\.css/);
  assert.match(report, /structural derivation divergence/);
  // The tertiary/error roles must not be listed under the noise remedy's
  // affected-roles list.
  const noiseSection = report.slice(
    report.indexOf("tone-table approximation"),
    report.indexOf("## Full color-role comparison")
  );
  assert.doesNotMatch(noiseSection, /--md-sys-color-tertiary`/);
  assert.doesNotMatch(noiseSection, /--md-sys-color-on-tertiary`/);
  assert.doesNotMatch(noiseSection, /--md-sys-color-tertiary-container`/);
  assert.doesNotMatch(noiseSection, /--md-sys-color-error`/);
});

test("real inputs: the container-tone regression is exactly the 4 on-*-container roles, measured deltaE far past tolerance", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  const regression = rows.filter((r) => r.rootCause === "container-tone-regression");
  const names = regression.map((r) => r.md).sort();
  assert.deepEqual(names, [
    "--md-sys-color-on-error-container",
    "--md-sys-color-on-primary-container",
    "--md-sys-color-on-secondary-container",
    "--md-sys-color-on-tertiary-container",
  ]);
  for (const row of regression) {
    assert.ok(row.light.deLightComputed > 10, `expected a large deltaE, got ${row.light.deLightComputed}`);
    // @m3e/web's own fallback independently agrees with the kit for all 4 —
    // the evidence that this is tailwind-m3e-web's bug, not the kit's.
    assert.ok(row.light.deLightFallback < 3, row.md);
  }
});

test("real inputs: zero naming-discrepancies (D2's Schemes correspondence is already 1:1 mechanical — no alternate role name is ever a better match)", () => {
  const rows = buildColorRows({ variables, tokenRows, computedPalette });
  assert.equal(rows.filter((r) => r.status === "naming-discrepancy").length, 0);
});

// -- classification logic (synthetic) --------------------------------------

test("classification: a role within tolerance is 'match'", () => {
  const rows = buildColorRows({
    variables: [
      {
        name: "Schemes/Primary",
        valuesByModeName: {
          // The kit's real measured Primary Light/Dark rgb (-> #6750A4 / #D0BCFF).
          Light: { r: 0.40392157435417175, g: 0.3137255012989044, b: 0.6431372761726379, a: 1 },
          Dark: { r: 0.8156862854957581, g: 0.7372549176216125, b: 1, a: 1 },
        },
      },
    ],
    tokenRows: [
      { figma: "Schemes/Primary", md: "--md-sys-color-primary", m3eFallback: "#6750A4", status: "mapped" },
    ],
    computedPalette: {
      light: { primary: "#6750A4" }, // exact match, deltaE 0
      dark: { primary: "#D0BCFF" }, // exact match, deltaE 0
    },
  });
  assert.equal(rows[0].status, "match");
});

test("classification: DELIBERATE seed-change fixture — corrupting one computed role produces a spec-failure row (verify step)", () => {
  // A small, fully-controlled synthetic fixture (2 distinct, non-confusable
  // roles) rather than the real 37-role palette — the real palette has many
  // legitimately near-identical roles (several white "on-*" text roles,
  // several near-black surfaces), so corrupting one there risks the
  // classifier correctly finding an unrelated near-twin and calling it a
  // naming-discrepancy instead, which would test the wrong thing. Here
  // "primary" and "secondary" are deliberately distinct hues so there is no
  // ambiguity: corrupting "primary" alone must surface as a spec-failure on
  // "primary" and must NOT be reclassified via some other role.
  const syntheticVariables = [
    {
      name: "Schemes/Primary",
      valuesByModeName: {
        Light: { r: 0.40392157435417175, g: 0.3137255012989044, b: 0.6431372761726379, a: 1 }, // #6750A4
        Dark: { r: 0.8156862854957581, g: 0.7372549176216125, b: 1, a: 1 }, // #D0BCFF
      },
    },
    {
      name: "Schemes/Secondary",
      valuesByModeName: {
        Light: { r: 0.3843137323856354, g: 0.3568627536296844, b: 0.4431372582912445, a: 1 }, // #625B71
        Dark: { r: 0.800000011920929, g: 0.7607843279838562, b: 0.8627451062202454, a: 1 }, // #CCC2DC
      },
    },
  ];
  const syntheticTokenRows = [
    { figma: "Schemes/Primary", md: "--md-sys-color-primary", m3eFallback: "#6750A4", status: "mapped" },
    { figma: "Schemes/Secondary", md: "--md-sys-color-secondary", m3eFallback: "#625B71", status: "mapped" },
  ];
  const goodPalette = {
    light: { primary: "#6750A4", secondary: "#625B71" },
    dark: { primary: "#D0BCFF", secondary: "#CCC2DC" },
  };

  const beforeRows = buildColorRows({ variables: syntheticVariables, tokenRows: syntheticTokenRows, computedPalette: goodPalette });
  assert.equal(beforeRows.find((r) => r.role === "primary").status, "match");

  // The deliberate corruption: "primary"'s computed Light value is replaced
  // with a hue nowhere near either role — simulating an upstream seed
  // change that broke exactly this one role's derivation.
  const corrupted = { ...goodPalette, light: { ...goodPalette.light, primary: "#00FF00" } };
  const afterRows = buildColorRows({ variables: syntheticVariables, tokenRows: syntheticTokenRows, computedPalette: corrupted });
  const after = afterRows.find((r) => r.role === "primary");

  assert.equal(after.status, "spec-failure", "corrupting the computed value must flip this role to spec-failure");
  assert.ok(after.light.deLightComputed > DEFAULT_TOLERANCE);
  // The untouched role must be unaffected (proves the audit isolates the
  // corruption to the one role that actually changed).
  assert.equal(afterRows.find((r) => r.role === "secondary").status, "match");
});

// -- Step 5: typescale/shape exact-match -----------------------------------

const typescaleCss = fs.readFileSync(DEFAULT_PATHS.typescaleCssPath, "utf8");
const shapeCss = fs.readFileSync(DEFAULT_PATHS.shapeCssPath, "utf8");

test("buildNumericRows: 55 rows (45 Static axes + 10 Corner), real inputs", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  assert.equal(rows.length, 55);
});

test("buildNumericRows: real-input mismatches are exactly Corner/Full (M5: tailwind-m3e-web's own Display Large/Tracking sign-flip is fixed upstream, now an exact match)", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const mismatches = rows.filter((r) => !r.match).map((r) => r.figma).sort();
  assert.deepEqual(mismatches, ["Corner/Full"]);
});

test("buildNumericRows: Display Large Tracking now matches — tailwind-m3e-web/src/sys/typescale.css corrected its sign (was a genuine kit-negative/tailwind-positive flip; both are -0.25 now)", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Static/Display Large/Tracking");
  assert.equal(row.kitPx, -0.25);
  assert.equal(row.codePx, -0.25);
  assert.equal(row.match, true);
});

test("buildNumericRows: bare-zero tracking tokens (no 'rem' unit in typescale.css) parse as 0, not null", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Static/Display Medium/Tracking");
  assert.equal(row.codePx, 0);
  assert.equal(row.match, true);
});

test("buildNumericRows: exact-match tolerates the kit's float32 rounding noise (e.g. Body Small Tracking 0.4000000059604645)", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Static/Body Small/Tracking");
  assert.equal(row.match, true);
});

test("buildNumericRows: Corner/Full mismatch is 1000px (kit) vs 9999px (tailwind) — both 'effectively infinite' pill radii", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Corner/Full");
  assert.equal(row.kitPx, 1000);
  assert.equal(row.codePx, 9999);
});

// -- Step 5 classification: required-code-change vs benign-equivalent -------

test("buildNumericRows: Display Large Tracking carries no classification now that it matches", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Static/Display Large/Tracking");
  assert.equal(row.match, true);
  assert.equal(row.classification, null);
});

test("buildNumericRows: Corner/Full is classified 'benign-equivalent', NOT a required change", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Corner/Full");
  assert.equal(row.classification, "benign-equivalent");
  assert.notEqual(row.classification, "required-code-change");
});

test("buildNumericRows: exact-match rows carry no classification (null)", () => {
  const rows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const row = rows.find((r) => r.figma === "Static/Body Large/Tracking");
  assert.equal(row.match, true);
  assert.equal(row.classification, null);
});

test("renderReport: Display Large Tracking no longer appears under REQUIRED CODE CHANGES (the sign-flip is fixed upstream in tailwind-m3e-web)", () => {
  const colorRows = buildColorRows({ variables, tokenRows, computedPalette });
  const numericRows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const report = renderReport({ colorRows, numericRows, extraModes: [], tolerance: DEFAULT_TOLERANCE });
  const requiredSection = report.slice(
    report.indexOf("## REQUIRED CODE CHANGES"),
    report.indexOf("## Naming discrepancies") !== -1
      ? report.indexOf("## Naming discrepancies")
      : report.indexOf("## Full color-role comparison")
  );
  assert.doesNotMatch(requiredSection, /display-large-tracking/);
});

test("renderReport: Corner/Full is annotated benign-equivalent in the Step 5 table and detail list, and does NOT appear in REQUIRED CODE CHANGES", () => {
  const colorRows = buildColorRows({ variables, tokenRows, computedPalette });
  const numericRows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const report = renderReport({ colorRows, numericRows, extraModes: [], tolerance: DEFAULT_TOLERANCE });
  const requiredSection = report.slice(
    report.indexOf("## REQUIRED CODE CHANGES"),
    report.indexOf("## Naming discrepancies") !== -1
      ? report.indexOf("## Naming discrepancies")
      : report.indexOf("## Full color-role comparison")
  );
  // Corner/Full may be mentioned in passing prose (e.g. pointing at its
  // benign-equivalent annotation), but must not appear as its own filed
  // remedy bullet (no "- `--md-sys-shape-corner-full`" line item).
  assert.doesNotMatch(requiredSection, /^- `--md-sys-shape-corner-full`/m);
  assert.match(report, /Corner\/Full.*benign-equivalent/);
  assert.match(report, /shape-corner-full.*benign-equivalent/);
});

// -- Step 4: extra modes ----------------------------------------------------

test("listExtraModes: 30 modes beyond Light/Dark (13 hue themes x LT/DT + 4 contrast tiers)", () => {
  const { collections } = loadKitVariables(DEFAULT_PATHS.variablesPath);
  const extra = listExtraModes(collections);
  assert.equal(extra.length, 30);
  assert.ok(!extra.includes("Light"));
  assert.ok(!extra.includes("Dark"));
  assert.ok(extra.includes("Light High Contrast"));
  assert.ok(extra.includes("Monochrome LT"));
});

// -- report rendering + determinism -----------------------------------------

test("renderReport: contains the required sections", () => {
  const colorRows = buildColorRows({ variables, tokenRows, computedPalette });
  const numericRows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const report = renderReport({ colorRows, numericRows, extraModes: [], tolerance: DEFAULT_TOLERANCE });
  assert.match(report, /# m3-kit token audit/);
  assert.match(report, /## Summary/);
  assert.match(report, /## REQUIRED CODE CHANGES/);
  assert.match(report, /## Full color-role comparison/);
  assert.match(report, /## Step 5 — typescale\/shape exact-match/);
});

test("runAudit: deterministic — two independent runs produce byte-identical reports", () => {
  const a = runAudit();
  const b = runAudit();
  assert.equal(a.report, b.report);
});

test("runAudit --profile m3-kit writes token-audit.md to a scratch path (file-arg CLI shape)", () => {
  const scratchDir = fs.mkdtempSync(path.join(os.tmpdir(), "d5-audit-"));
  const reportPath = path.join(scratchDir, "token-audit.md");
  const { report } = runAudit({ ...DEFAULT_PATHS, reportPath });
  fs.writeFileSync(reportPath, report, "utf8");
  assert.ok(fs.existsSync(reportPath));
  assert.match(fs.readFileSync(reportPath, "utf8"), /# m3-kit token audit/);
  fs.rmSync(scratchDir, { recursive: true, force: true });
});

test("checked-in profiles/m3-kit/token-audit.md matches a fresh run byte-for-byte (--check-style drift guard)", () => {
  const { report } = runAudit();
  const checkedIn = fs.readFileSync(DEFAULT_PATHS.reportPath, "utf8");
  assert.equal(checkedIn, `${report}\n`);
});
