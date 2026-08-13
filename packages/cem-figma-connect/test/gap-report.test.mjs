// Task A7: gap report — code-only/figma-only/valid-but-undrawn/unmapped-axes
// as a first-class artifact (D6: log, never author; plans/BRIEF.md §7.4).
//
// Run with the file-arg form (bare `node --test` mis-discovers the `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/gap-report.test.mjs
//
// IMPORTANT — measured truth, not the 06a estimate: research/evidence/
// 06a-expressive-delta.md's "53 matched / 68 code-only" is an optimistic
// human name-level read. The real conservative auto-matcher binds only 26
// distinct CEM tags (24 exact + 2 fuzzy) on this fixture, so code-only
// measures 121-26=95, NOT 68. Every count assertion below asserts the REAL
// measured number, not 06a's figure — see gap-report.mjs's module doc and
// task-A7-report.md for the full reconciliation.
//
// Fix 2 (2026-07-14): leading-dot COMPONENT_SET names (.Shape) are now
// excluded from the exact tier and fall through to fuzzy, changing the
// split from 25 exact + 1 fuzzy to 24 exact + 2 fuzzy. Total matched (26)
// and code-only (95) are unchanged.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadCem } from "../src/ingest/cem.mjs";
import { loadFigmaExport } from "../src/ingest/figma.mjs";
import { match } from "../src/match/matcher.mjs";
import { repoRoot } from "../src/correspond/merge.mjs";
import {
  computeCodeOnly,
  computeFigmaOnly,
  computeValidButUndrawn,
  computeUnmappedAxes,
  matchedDimensions,
  cartesianMinusDrawn,
  buildGapReport,
  renderGapReportMarkdown,
  runGapReport,
} from "../src/correspond/gap-report.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const cem = loadCem(
  path.join(here, "fixtures", "cem-facts.m3e-web-2.5.14.json"),
  { log: () => {} }
);
const figma = loadFigmaExport(path.join(here, "fixtures", "figma-export.m3-kit.json"));

// Loaded once — both fixtures are large. Every assertion reads this view.
const { candidates } = match(cem, figma);

function tmpPath(name) {
  return path.join(os.tmpdir(), `cem-figma-connect-${name}-${process.pid}-${Date.now()}.md`);
}

// -- code-only: the real measured count, not 06a's 68 -----------------------

test("code-only: measured count is 123 - 36 matched = 87, NOT 06a's 68", () => {
  const matchedTags = new Set(
    candidates
      .filter((c) => (c.tier === "exact" || c.tier === "fuzzy" || c.tier === "contains") && c.cemTag)
      .map((c) => c.cemTag)
  );
  assert.equal(matchedTags.size, 36, "matcher binds exactly 36 distinct CEM tags on this fixture (24 exact + 1 fuzzy + 11 contains)");
  const exact = candidates.filter((c) => c.tier === "exact" && c.cemTag).length;
  const fuzzy = candidates.filter((c) => c.tier === "fuzzy" && c.cemTag).length;
  const contains = candidates.filter((c) => c.tier === "contains" && c.cemTag).length;
  // Task 5 (2026-07-18): contains tier added. Fix 2 (2026-07-14): .Shape
  // excluded from exact tier → was 24 exact + 2 fuzzy. Now "Shape Set" is
  // consumed by the qualifier (contains tier) and .Shape goes to gap → 24 exact
  // + 1 fuzzy + 11 contains.
  assert.equal(exact, 24);
  assert.equal(fuzzy, 1);
  assert.equal(contains, 11);

  const codeOnly = computeCodeOnly(cem, candidates);
  // M3.a: Face B's reconciliation makes m3e-fab-menu-item/m3e-stepper-next
  // real, distinct components rather than tagName-collision casualties
  // (see test/cem-ingest.test.mjs), so the CEM tag total moves 121 -> 123;
  // the matched/exact/fuzzy/contains counts (figma-side driven) are unchanged.
  assert.equal(cem.components.length, 123);
  assert.equal(codeOnly.length, 123 - 36, "code-only = all CEM tags minus the 36 matched");
  assert.equal(codeOnly.length, 87);
});

test("code-only: sorted by tag (ordinal), and a real name-collision loser (m3e-tab) carries its OWN rationale", () => {
  const codeOnly = computeCodeOnly(cem, candidates);
  const tags = codeOnly.map((r) => r.tag);
  assert.deepEqual(tags, [...tags].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)));

  const tab = codeOnly.find((r) => r.tag === "m3e-tab");
  assert.ok(tab, "m3e-tab (lost the tab/tabs slug collision to m3e-tabs) surfaces in code-only");
  assert.match(tab.rationale, /slug collision/);

  // An ordinary never-a-candidate tag gets the generic D6 rationale.
  const accordion = codeOnly.find((r) => r.tag === "m3e-accordion");
  assert.ok(accordion, "m3e-accordion (a real kit gap per 06a) is code-only");
  assert.match(accordion.rationale, /no Figma candidate reached the exact\/fuzzy match threshold/);
});

test("code-only: m3e-button-group is NOT code-only — the contains tier binds it via qualifier", () => {
  // Task 5 (2026-07-18): the contains tier correctly binds "Connected button
  // group" / "Standard button group" → m3e-button-group via qualifier
  // (mode:attr, variant attr). Previously this was a code-only gap.
  const codeOnly = computeCodeOnly(cem, candidates);
  assert.ok(!codeOnly.some((r) => r.tag === "m3e-button-group"), "m3e-button-group is now bound at contains tier");
  // Verify it IS at the contains tier.
  const bg = candidates.find((c) => c.cemTag === "m3e-button-group");
  assert.ok(bg && bg.tier === "contains", "m3e-button-group is at tier:contains");
});

// -- figma-only ---------------------------------------------------------------

test("figma-only: contains carousel + time pickers + side sheet + bottom app bar + XR sets (case-insensitive)", () => {
  const figmaOnly = computeFigmaOnly(candidates);
  const names = figmaOnly.map((r) => r.name.toLowerCase());

  assert.ok(names.some((n) => n.includes("carousel")), "carousel present");
  assert.ok(names.some((n) => n.includes("dial picker")), "a time-picker set (Dial picker) present");
  assert.ok(names.some((n) => n.includes("keyboard picker")), "a time-picker set (Keyboard picker) present");
  assert.ok(names.some((n) => n === "side sheet"), "Side Sheet present");
  assert.ok(names.some((n) => n === "bottom app bar"), "Bottom app bar present");
  assert.ok(names.some((n) => n.includes("xr")), "an XR set present");
});

test("figma-only: every row is a real cemTag:null gap tier candidate, sorted by page then name", () => {
  const figmaOnly = computeFigmaOnly(candidates);
  assert.ok(figmaOnly.length > 0);
  const sorted = [...figmaOnly].sort(
    (a, b) => (a.page < b.page ? -1 : a.page > b.page ? 1 : a.name < b.name ? -1 : a.name > b.name ? 1 : 0)
  );
  assert.deepEqual(figmaOnly, sorted);

  for (const row of figmaOnly) {
    const c = candidates.find((cand) => cand.figmaName === row.name && cand.page === row.page);
    assert.ok(c);
    assert.equal(c.tier, "gap");
    assert.equal(c.cemTag, null);
  }
});

// -- valid-but-undrawn: the completeness inversion (BRIEF §7.4) --------------

test("valid-but-undrawn: measured reality — only m3e-button + m3e-icon-button carry any dimension data on this pre-A3 fixture", () => {
  const { rows, noData } = computeValidButUndrawn(cem, candidates);
  // Fix 2 (2026-07-18): computeValidButUndrawn now includes contains-tier
  // candidates. All 36 matched distinct CEM tags are evaluated; 5 carry
  // dimension data (m3e-button, m3e-icon-button from fusion, plus
  // m3e-button-group, m3e-card, m3e-linear-progress-indicator from contains
  // qualifier-attr binding), so noData = 36 - 5 = 31.
  const allMatchedCount = new Set(
    candidates
      .filter((c) => (c.tier === "exact" || c.tier === "fuzzy" || c.tier === "contains") && c.cemTag)
      .map((c) => c.cemTag)
  ).size;

  // m3e-button: Size/Type from 2 of its 5 fused sibling sets' captured
  // setProperties, plus its 'variant' fusion attribute (bound from sibling
  // SET NAMES, no setProperties needed). m3e-icon-button: 'variant' only,
  // likewise bound purely from its 4 sibling sets' names (a fusion's
  // fixedValues need no captured setProperties at all). Newly visible
  // contains candidates: m3e-button-group (variant attr), m3e-card
  // (orientation attr), m3e-linear-progress-indicator (indeterminate boolean
  // attr — 2 of its 3 mode values are undrawn on this fixture).
  assert.ok(!noData.includes("m3e-button"), "m3e-button DOES carry axis/fusion data");
  assert.ok(!noData.includes("m3e-icon-button"), "m3e-icon-button DOES carry fusion (variant) data");
  assert.ok(!noData.includes("m3e-button-group"), "m3e-button-group (contains) DOES carry qualifier-attr data");
  assert.ok(!noData.includes("m3e-card"), "m3e-card (contains) DOES carry qualifier-attr data");
  assert.ok(!noData.includes("m3e-linear-progress-indicator"), "m3e-linear-progress-indicator (contains) DOES carry qualifier-attr data");
  assert.equal(noData.length, allMatchedCount - 5, "every OTHER matched component has zero dimension data");
  assert.equal(allMatchedCount, 36);
  assert.equal(noData.length, 31);

  // Verify against the fixture, don't assume: m3e-button's mapped cartesian
  // (size × shape × variant = 5×2×5 = 50) is FULLY drawn in this fixture —
  // both captured sibling sets (bare "Button" and "Button - elevated") are
  // complete 2×5×5 rectangular variant matrices (variantCount:50 each, per
  // research/figma-dumps/kit-props-button-{main,elevated}.json), so the
  // brief's illustrative "variant=elevated × shape=square × size=extra-small"
  // combination IS drawn — it must NOT appear in valid-but-undrawn.
  const buttonRows = rows.filter((r) => r.cemTag === "m3e-button");
  assert.equal(buttonRows.length, 0, "measured: 0 undrawn combinations for m3e-button on this fixture");
  assert.ok(
    !rows.some(
      (r) =>
        r.cemTag === "m3e-button" &&
        r.combo.variant === "elevated" &&
        r.combo.shape === "square" &&
        r.combo.size === "extra-small"
    ),
    "the brief's example combo is present in the dump, so it is correctly ABSENT from valid-but-undrawn"
  );

  // m3e-icon-button: its 'variant' fusion attribute is 4/4 drawn (standard,
  // outlined, tonal, filled — all 4 sibling sets present), so it too
  // measures 0 undrawn combinations on this fixture.
  const iconButtonRows = rows.filter((r) => r.cemTag === "m3e-icon-button");
  assert.equal(iconButtonRows.length, 0, "measured: 0 undrawn combinations for m3e-icon-button on this fixture");

  // m3e-linear-progress-indicator (contains tier): its qualifier binding maps
  // the `indeterminate` attr, and the `mode` enum (buffer, query) is partially
  // drawn. 2 combos undrawn on this fixture.
  const lpRows = rows.filter((r) => r.cemTag === "m3e-linear-progress-indicator");
  assert.equal(lpRows.length, 2, "measured: 2 undrawn mode combinations for m3e-linear-progress-indicator");
  assert.equal(rows.length, 2, "measured total across the whole fixture: 2 valid-but-undrawn combinations");
});

test("valid-but-undrawn: the underlying cartesian-minus-drawn logic correctly finds a gap on a synthetic incomplete case", () => {
  // The real fixture happens to be fully drawn for m3e-button, so it can't by
  // itself prove the algorithm detects an undrawn combination. Exercise the
  // pure logic directly with a synthetic, deliberately incomplete axis.
  const dims = [
    { label: "size", full: ["small", "large"], drawn: new Set(["small", "large"]) },
    { label: "variant", full: ["filled", "outlined"], drawn: new Set(["filled"]) }, // "outlined" never drawn
  ];
  const undrawn = cartesianMinusDrawn(dims);
  assert.equal(undrawn.length, 2, "both combos pairing with the undrawn 'outlined' value are gaps");
  assert.deepEqual(
    undrawn.map((c) => `${c.size}/${c.variant}`).sort(),
    ["large/outlined", "small/outlined"]
  );
});

test("valid-but-undrawn: matchedDimensions returns [] for a matched component with no captured setProperties (e.g. m3e-checkbox)", () => {
  const checkbox = candidates.find((c) => c.cemTag === "m3e-checkbox");
  assert.ok(checkbox);
  const checkboxComponent = cem.components.find((c) => c.tag === "m3e-checkbox");
  assert.deepEqual(matchedDimensions(checkbox, checkboxComponent), []);
});

test("valid-but-undrawn: cartesianMinusDrawn throws a clear error on duplicate dimension labels (defensive guard)", () => {
  // Synthetic case: a component whose fusion attribute name happens to equal
  // one of its own mapped axis attribute names — combo-building via
  // `{ ...combo, [dim.label]: value }` would otherwise silently collapse
  // both dims onto one object key and distort the combo count. Not
  // reachable on current fixtures, but must fail loud rather than silently
  // corrupt the count if it ever occurs.
  const dupDims = [
    { label: "variant", full: ["small", "large"], drawn: new Set(["small"]) },
    { label: "variant", full: ["filled", "outlined"], drawn: new Set(["filled"]) },
  ];
  assert.throws(
    () => cartesianMinusDrawn(dupDims),
    /duplicate dimension label "variant"/,
    "duplicate dim.label must throw a clear, actionable error, not silently distort the combo count"
  );
});

test("valid-but-undrawn: rows (if any) are sorted by cemTag then combination", () => {
  const { rows } = computeValidButUndrawn(cem, candidates);
  const sorted = [...rows].sort((a, b) => {
    if (a.cemTag !== b.cemTag) return a.cemTag < b.cemTag ? -1 : 1;
    const ak = JSON.stringify(a.combo);
    const bk = JSON.stringify(b.combo);
    return ak < bk ? -1 : ak > bk ? 1 : 0;
  });
  assert.deepEqual(rows, sorted);
});

// -- unmapped-axes --------------------------------------------------------------

test("unmapped-axes: includes the button's State axis", () => {
  const unmappedAxes = computeUnmappedAxes(candidates);
  const state = unmappedAxes.find((r) => r.cemTag === "m3e-button" && r.figmaProp === "State");
  assert.ok(state, "button's State axis present in unmapped-axes");
  assert.match(state.reason, /no CEM enum attribute shares its value set/);
});

test("unmapped-axes: sorted by cemTag then figmaProp; no mapped axis leaks in", () => {
  const unmappedAxes = computeUnmappedAxes(candidates);
  assert.ok(unmappedAxes.length > 0);
  const sorted = [...unmappedAxes].sort(
    (a, b) => (a.cemTag < b.cemTag ? -1 : a.cemTag > b.cemTag ? 1 : a.figmaProp < b.figmaProp ? -1 : a.figmaProp > b.figmaProp ? 1 : 0)
  );
  assert.deepEqual(unmappedAxes, sorted);

  for (const row of unmappedAxes) {
    const c = candidates.find((cand) => cand.cemTag === row.cemTag);
    const axis = c.axisProposals.find((a) => a.axis === row.figmaProp);
    assert.equal(axis.mapped, false);
  }
});

// -- buildGapReport / rendering: counts never drift from the tables ---------

test("buildGapReport: counts header numbers match each section's actual row count", () => {
  const { codeOnly, figmaOnly, validButUndrawn, unmappedAxes, counts } = buildGapReport(cem, candidates);
  assert.equal(counts.codeOnly, codeOnly.length);
  assert.equal(counts.figmaOnly, figmaOnly.length);
  assert.equal(counts.validButUndrawn, validButUndrawn.rows.length);
  assert.equal(counts.validButUndrawnNoData, validButUndrawn.noData.length);
  assert.equal(counts.unmappedAxes, unmappedAxes.length);
  assert.equal(counts.matched, 36);
  // Task 5 (2026-07-18): contains tier added (11 tags). Fix 2 (2026-07-14):
  // .Shape was fuzzy (not exact). Now "Shape Set" is contains, .Shape→gap.
  // Split: 24 exact + 1 fuzzy + 11 contains.
  assert.equal(counts.exact, 24);
  assert.equal(counts.fuzzy, 1);
  assert.equal(counts.contains, 11);
  assert.equal(counts.cemTagsTotal, 123);
  assert.equal(counts.codeOnly, 87);
});

test("renderGapReportMarkdown: renders all four section headers, the counts header, and the 06a reconciliation note", () => {
  const markdown = renderGapReportMarkdown("m3-kit", cem, candidates);
  assert.match(markdown, /^# Gap report — m3-kit/);
  assert.match(markdown, /## Counts/);
  assert.match(markdown, /## code-only/);
  assert.match(markdown, /## figma-only/);
  assert.match(markdown, /## valid-but-undrawn/);
  assert.match(markdown, /## unmapped-axes/);
  assert.match(markdown, /Reconciliation vs 06a/);
  assert.match(markdown, /binds only 36/);
  assert.match(markdown, /code-only measures 87/);
  assert.match(markdown, /\| `m3e-tab` \|/);
});

test("renderGapReportMarkdown: the per-axis-vs-joint coverage caveat renders UNCONDITIONALLY in valid-but-undrawn, not gated on noData", () => {
  // This fixture's noData list is non-empty (23 of 25 exact/fuzzy matched components),
  // so this alone wouldn't distinguish "always shown" from "shown only when
  // noData is non-empty." Assert the caveat text directly, then also prove
  // via buildGapReport that noData is non-empty here so this test isn't
  // vacuously passing for the wrong reason.
  const { validButUndrawn } = buildGapReport(cem, candidates);
  assert.ok(validButUndrawn.noData.length > 0, "sanity: this fixture's noData is non-empty");

  const markdown = renderGapReportMarkdown("m3-kit", cem, candidates);
  assert.match(
    markdown,
    /Coverage caveat \(always applies, not just when data is missing\)/,
    "the per-axis-vs-joint caveat must be present"
  );
  assert.match(markdown, /no variant→owning-set parent/);
  assert.match(
    markdown,
    /Treat an empty result for a component as "no axis value was individually undrawn," NOT as proof of full combinatorial coverage/
  );
});

test("renderGapReportMarkdown: the caveat still renders when noData is EMPTY (proves it is truly unconditional, not noData-gated)", () => {
  // Synthetic cem/candidates where the one matched component DOES carry
  // full dimension data (noData ends up empty) — this is the case the real
  // fixture can't exercise, since its noData is always non-empty. Proves
  // the caveat line isn't accidentally riding along on the `if
  // (validButUndrawn.noData.length > 0)` block right above it.
  const syntheticCem = {
    components: [
      { tag: "x-foo", description: "synthetic", attributes: [{ name: "size", values: ["small", "large"] }] },
    ],
  };
  const syntheticCandidates = [
    {
      tier: "exact",
      cemTag: "x-foo",
      figmaName: "Foo",
      page: "p",
      rationale: [],
      axisProposals: [{ mapped: true, attribute: "size", axis: "Size", valueMap: [{ cem: "small" }, { cem: "large" }] }],
    },
  ];

  const { validButUndrawn } = buildGapReport(syntheticCem, syntheticCandidates);
  assert.equal(validButUndrawn.noData.length, 0, "sanity: synthetic component carries full dimension data");

  const markdown = renderGapReportMarkdown("synthetic", syntheticCem, syntheticCandidates);
  assert.match(
    markdown,
    /Coverage caveat \(always applies, not just when data is missing\)/,
    "caveat renders even when noData is empty — it is unconditional, not gated on noData"
  );
});

test("renderGapReportMarkdown: byte-stable across repeated runs on the same inputs (deterministic)", () => {
  const first = renderGapReportMarkdown("m3-kit", cem, candidates);
  const second = renderGapReportMarkdown("m3-kit", cem, candidates);
  assert.equal(first, second);
});

// -- CLI machinery: runGapReport against the real m3-kit profile ------------
//
// Since A8, profiles/m3-kit/gap-report.md IS checked in (generated tracer
// artifact). This test now asserts the complementary invariant: a
// temp-redirected runGapReport call never disturbs that checked-in real file.

test("CLI machinery: runGapReport against the real m3-kit profile writes ONLY to the redirected temp path", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const realGapReportPath = path.join(profileDir, "gap-report.md");
  const tmp = tmpPath("gap-report");

  assert.ok(fs.existsSync(realGapReportPath), "profiles/m3-kit/gap-report.md is the A8 tracer artifact and must be checked in");
  const realBefore = fs.readFileSync(realGapReportPath, "utf8");

  const { markdown, counts, outPath } = runGapReport({ profileDir, loadCem, loadFigmaExport, outPath: tmp });

  assert.equal(outPath, tmp);
  assert.ok(fs.existsSync(tmp));
  assert.equal(fs.readFileSync(tmp, "utf8"), markdown);
  assert.equal(counts.matched, 36);
  assert.equal(counts.codeOnly, 94);

  assert.equal(
    fs.readFileSync(realGapReportPath, "utf8"),
    realBefore,
    "runGapReport with an explicit outPath must not have touched the real checked-in file"
  );
  assert.equal(markdown, realBefore, "the redirected render must be byte-identical to the checked-in gap-report.md");

  fs.rmSync(tmp);
});

test("CLI machinery: runGapReport is byte-stable across two independent runs against the same profile", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const tmpA = tmpPath("gap-report-a");
  const tmpB = tmpPath("gap-report-b");

  runGapReport({ profileDir, loadCem, loadFigmaExport, outPath: tmpA });
  runGapReport({ profileDir, loadCem, loadFigmaExport, outPath: tmpB });

  assert.equal(fs.readFileSync(tmpA, "utf8"), fs.readFileSync(tmpB, "utf8"));

  fs.rmSync(tmpA);
  fs.rmSync(tmpB);
});
