// Task D2: src/tokens/derive.mjs's token correspondence table.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per D1's note):
//   node --test src/tokens/derive.test.mjs
//
// OFFLINE, zero new deps. Loads the REAL committed dumps
// (research/figma-dumps/kit-variables.json), the co-located tailwind-m3e-web
// package (packages/tailwind-m3e-web), and the vendored @m3e/web fixture
// (test/fixtures/m3e-web-2.5.14) — this task's whole point is asserting
// MEASURED real join/coverage counts, not synthetic fixtures that could
// quietly drift from reality. Only the merge-discipline unit tests use
// synthetic in-memory rows (nothing real to measure there).

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  kebab,
  deriveMdName,
  parseThemeJoins,
  parseTypescaleNames,
  parseFallbacks,
  buildRow,
  mergeTokenRows,
  readTokenOverrides,
  deriveTokenRows,
  writeTokens,
  reviewRows,
  checkCoverage,
  familyStatusCounts,
  DEFAULT_PATHS,
} from "./derive.mjs";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

function mkScratch() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-derive-test-"));
}

// -- kebab --------------------------------------------------------------

test("kebab: mechanical Figma-role -> code-slug transform", () => {
  assert.equal(kebab("On Surface Variant"), "on-surface-variant");
  assert.equal(kebab("Extra-large-increased"), "extra-large-increased");
  assert.equal(kebab("Body Large"), "body-large");
  assert.equal(kebab("  Trim Me  "), "trim-me");
});

// -- deriveMdName ---------------------------------------------------------

test("deriveMdName: Schemes/<Role> -> --md-sys-color-<role>, always confident", () => {
  const v = { name: "Schemes/On Surface Variant", family: "Schemes" };
  assert.deepEqual(deriveMdName(v), { md: "--md-sys-color-on-surface-variant", confident: true });
});

test("deriveMdName: Corner/<Size> -> --md-sys-shape-corner-<size>, always confident", () => {
  const v = { name: "Corner/Extra-large-increased", family: "Corner" };
  assert.deepEqual(deriveMdName(v), { md: "--md-sys-shape-corner-extra-large-increased", confident: true });
});

test("deriveMdName: Static/<Scale>/Size -> font-size axis (NOT a literal 'size' suffix)", () => {
  const v = { name: "Static/Body Large/Size", family: "Static" };
  const d = deriveMdName(v);
  assert.equal(d.md, "--md-sys-typescale-body-large-font-size");
});

test("deriveMdName: Static/<Scale>/Weight-emphasized -> 'emphasized' PREFIXES the scale, not a suffix on the prop", () => {
  const v = { name: "Static/Body Large/Weight-emphasized", family: "Static" };
  const d = deriveMdName(v);
  assert.equal(d.md, "--md-sys-typescale-emphasized-body-large-font-weight");
});

test("deriveMdName: Static/Font/Brand (standalone constant, 2nd segment isn't a scale) is flagged with a note", () => {
  const v = { name: "Static/Font/Brand", family: "Static" };
  const d = deriveMdName(v);
  assert.ok(d.note, "expected a note explaining this isn't a per-scale axis");
  assert.match(d.note, /standalone constant/);
});

test("deriveMdName: deferred families (State Layers/Tracking/Add-ons) get md:null, confident:false, and a note", () => {
  for (const [name, family] of [
    ["State Layers/Primary/Opacity-08", "State Layers"],
    ["Tracking/Small", "Tracking"],
    ["Add-ons/Section background", "Add-ons"],
  ]) {
    const d = deriveMdName({ name, family });
    assert.equal(d.md, null);
    assert.equal(d.confident, false);
    assert.match(d.note, /no Step-1 derivation rule/);
  }
});

// -- parseThemeJoins / parseTypescaleNames / parseFallbacks (synthetic) ----

test("parseThemeJoins: joins a plain --color-* key and splits a --text-*--modifier key from its base", () => {
  const css = `
    @theme {
      --color-on-surface: var(--md-sys-color-on-surface);
      --text-body-lg: var(--md-sys-typescale-body-large-font-size);
      --text-body-lg--line-height: var(--md-sys-typescale-body-large-line-height);
    }
  `;
  const joins = parseThemeJoins(css);
  assert.deepEqual(joins.get("--md-sys-color-on-surface"), {
    twKey: "--color-on-surface",
    base: "--color-on-surface",
    modifier: null,
  });
  assert.deepEqual(joins.get("--md-sys-typescale-body-large-font-size"), {
    twKey: "--text-body-lg",
    base: "--text-body-lg",
    modifier: null,
  });
  assert.deepEqual(joins.get("--md-sys-typescale-body-large-line-height"), {
    twKey: "--text-body-lg--line-height",
    base: "--text-body-lg",
    modifier: "line-height",
  });
});

test("parseTypescaleNames: extracts every declared --md-sys-typescale-* token name", () => {
  const css = `
    :root {
      --md-sys-typescale-body-large-font-size: 1rem;
      --md-sys-typescale-emphasized-body-large-font-weight: 500;
    }
  `;
  const names = parseTypescaleNames(css);
  assert.ok(names.has("--md-sys-typescale-body-large-font-size"));
  assert.ok(names.has("--md-sys-typescale-emphasized-body-large-font-weight"));
  assert.equal(names.size, 2);
});

test("parseFallbacks: extracts var(--md-sys-*, fallback) pairs, first occurrence wins", () => {
  const text = JSON.stringify({
    a: "var(--md-sys-color-primary, #6750A4)",
    b: "var(--md-sys-color-primary, #6750A4)", // same value repeated — not a divergence
  });
  const fallbacks = parseFallbacks(text);
  assert.equal(fallbacks.get("--md-sys-color-primary"), "#6750A4");
});

// -- real-dump measured counts (the acceptance criteria) --------------------

test("deriveTokenRows: real dump — 304 rows total (49 Schemes + 147 State Layers + 95 Static + 10 Corner + 2 Tracking + 1 Add-ons)", () => {
  const rows = deriveTokenRows();
  assert.equal(rows.length, 304);
});

test("deriveTokenRows: Schemes coverage is 49/49 rows status:'mapped' (the hard acceptance criterion)", () => {
  const rows = deriveTokenRows();
  const schemes = rows.filter((r) => r.figma.startsWith("Schemes/"));
  assert.equal(schemes.length, 49);
  const mapped = schemes.filter((r) => r.status === "mapped");
  assert.equal(mapped.length, 49, "every Schemes/* row must be status:'mapped'");
  assert.ok(
    schemes.every((r) => typeof r.md === "string" && r.md.startsWith("--md-sys-color-")),
    "every Schemes/* row must carry a real --md-sys-color-* md name"
  );
});

test("deriveTokenRows: MEASURED — 12 of the 49 Schemes rows (the '*-fixed*' roles) have no tailwind @theme join, yet remain status:'mapped' with a note (tailwind gap != derivation failure)", () => {
  const rows = deriveTokenRows();
  const schemes = rows.filter((r) => r.figma.startsWith("Schemes/"));
  const noJoin = schemes.filter((r) => r.tailwind === null);
  assert.equal(noJoin.length, 12);
  assert.ok(noJoin.every((r) => r.status === "mapped"));
  assert.ok(noJoin.every((r) => /no @theme join/.test(r.note)));
  assert.ok(noJoin.every((r) => /fixed/.test(r.md)), "the gap is specifically the *-fixed* role family");
});

test("deriveTokenRows: MEASURED — Corner is 10/10 tailwind-joined", () => {
  const rows = deriveTokenRows();
  const corner = rows.filter((r) => r.figma.startsWith("Corner/"));
  assert.equal(corner.length, 10);
  assert.ok(corner.every((r) => r.status === "mapped" && r.tailwind !== null));
});

test("deriveTokenRows: MEASURED — Static is 75/95 mapped (join-verified against typescale.css); the other 20 (Font axis + standalone Weight-name constants) are Task D6 'policy' decisions, not unmapped", () => {
  const rows = deriveTokenRows();
  const staticRows = rows.filter((r) => r.figma.startsWith("Static/"));
  assert.equal(staticRows.length, 95);
  const mapped = staticRows.filter((r) => r.status === "mapped");
  const policy = staticRows.filter((r) => r.status === "policy");
  const unmapped = staticRows.filter((r) => r.status === "unmapped");
  assert.equal(mapped.length, 75);
  assert.equal(policy.length, 20);
  assert.equal(unmapped.length, 0);
  assert.ok(policy.every((r) => r.note.length > 0));
  assert.ok(
    mapped.every((r) => r.tailwind !== null),
    "every mapped Static row must have actually joined tailwind"
  );
});

test("deriveTokenRows: a Static/* typescale slug's derived md name matches typescale.css's real spelling (source of truth), including the 'emphasized' prefix reorder", () => {
  const rows = deriveTokenRows();
  const row = rows.find((r) => r.figma === "Static/Body Large/Weight-emphasized");
  assert.ok(row);
  assert.equal(row.md, "--md-sys-typescale-emphasized-body-large-font-weight");
  assert.equal(row.status, "mapped");
  assert.equal(row.tailwind.theme, "--text-body-emphasized-lg");
});

test("deriveTokenRows: Task D6 resolved the once-deferred families (State Layers 147, Tracking 2, Add-ons 1) to 'policy' via tokens-overrides.json — none remain bare-unmapped", () => {
  const rows = deriveTokenRows();
  for (const [family, count] of [
    ["State Layers", 147],
    ["Tracking", 2],
    ["Add-ons", 1],
  ]) {
    const familyRows = rows.filter((r) => r.figma.startsWith(`${family}/`));
    assert.equal(familyRows.length, count, `family ${family} count`);
    assert.ok(
      familyRows.every((r) => r.status === "policy" && r.provenance === "human" && r.note.length > 0),
      `every ${family}/* row must be a documented 'policy' override, not left unmapped`
    );
  }
});

test("reviewRows: 0 unmapped rows remain after Task D6's family coverage closure (170 policy + 134 mapped = 304)", () => {
  const rows = deriveTokenRows();
  const { unmapped, byFamily } = reviewRows(rows);
  const mappedCount = rows.filter((r) => r.status === "mapped").length;
  const policyCount = rows.filter((r) => r.status === "policy").length;
  assert.equal(mappedCount, 134); // 49 Schemes + 10 Corner + 75 Static
  assert.equal(policyCount, 170); // 147 State Layers + 20 Static + 2 Tracking + 1 Add-ons
  assert.equal(unmapped.length, 0);
  assert.deepEqual(Object.fromEntries([...byFamily.entries()].map(([f, rs]) => [f, rs.length])), {});
});

// -- determinism ------------------------------------------------------------

test("deriveTokenRows: byte-stable — two independent runs over the same inputs produce identical JSON", () => {
  const first = JSON.stringify(deriveTokenRows());
  const second = JSON.stringify(deriveTokenRows());
  assert.equal(first, second);
});

test("deriveTokenRows: sorted by figma (ordinal), not source-file order", () => {
  const rows = deriveTokenRows();
  const figmaNames = rows.map((r) => r.figma);
  const sorted = [...figmaNames].sort(byKey((n) => n));
  assert.deepEqual(figmaNames, sorted);
});

test("the checked-in profiles/m3-kit/tokens.json is exactly what deriveTokenRows produces right now (derive.mjs --check's own assertion, exercised in-process)", () => {
  const tokensPath = path.join(repoRoot, "profiles", "m3-kit", "tokens.json");
  const committed = fs.readFileSync(tokensPath, "utf8");
  const fresh = `${JSON.stringify([...deriveTokenRows()].sort(byKey((r) => r.figma)), null, 2)}\n`;
  assert.equal(committed, fresh, "profiles/m3-kit/tokens.json is stale — regenerate with `node src/tokens/derive.mjs`");
});

// -- human-preserving merge --------------------------------------------------

test("mergeTokenRows: a provenance:'human' override always wins over a fresh proposal, even when the proposal's fields differ", () => {
  const override = [
    {
      figma: "Schemes/Primary",
      md: "--md-sys-color-primary",
      tailwind: { theme: "--color-primary", utils: ["bg-primary"] },
      m3eFallback: "#000000", // deliberately WRONG vs. the real fallback, to prove it's untouched
      provenance: "human",
      status: "mapped",
      note: "human-confirmed, deliberately overridden fallback for test",
    },
  ];
  const proposed = [
    {
      figma: "Schemes/Primary",
      md: "--md-sys-color-primary",
      tailwind: { theme: "--color-primary", utils: ["bg-primary", "text-primary", "border-primary", "ring-primary"] },
      m3eFallback: "#6750A4",
      provenance: "auto",
      status: "mapped",
      note: "",
    },
  ];
  const merged = mergeTokenRows(override, proposed);
  assert.deepEqual(merged, override);
});

test("mergeTokenRows: a non-human (or missing) override is freely replaced by the fresh proposal", () => {
  const proposed = [{ figma: "Corner/Small", md: "--md-sys-shape-corner-small", provenance: "auto", status: "mapped" }];
  const merged = mergeTokenRows([], proposed);
  assert.deepEqual(merged, proposed);
});

test("mergeTokenRows: an override for a figma key the current proposal no longer produces is kept (deletion is a human action, not automatic)", () => {
  const override = [{ figma: "Static/Retired Scale/Size", md: "--md-sys-typescale-retired-font-size", provenance: "human", status: "mapped" }];
  const merged = mergeTokenRows(override, []);
  assert.deepEqual(merged, override);
});

test("readTokenOverrides: returns [] when the overrides file doesn't exist yet", () => {
  const scratch = mkScratch();
  try {
    assert.deepEqual(readTokenOverrides(path.join(scratch, "does-not-exist.json")), []);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("deriveTokenRows + writeTokens: an end-to-end re-derive — a hand-added human override row survives UNCHANGED across a fresh derivation pass", () => {
  const scratch = mkScratch();
  try {
    const overridesPath = path.join(scratch, "tokens-overrides.json");
    const tokensPath = path.join(scratch, "tokens.json");

    const humanRow = {
      figma: "Schemes/Primary",
      md: "--md-sys-color-primary",
      tailwind: { theme: "--color-primary", utils: ["bg-primary"] },
      m3eFallback: "#ABCDEF", // hand-edited value a human decided on
      provenance: "human",
      status: "mapped",
      note: "human override for the merge-preservation test",
    };
    fs.writeFileSync(overridesPath, `${JSON.stringify([humanRow], null, 2)}\n`, "utf8");

    const paths = { ...DEFAULT_PATHS, overridesPath, tokensPath };

    // Phase 4 (L2): every row is tier-attributed mechanically post-merge, so a
    // preserved human row keeps ALL its substantive fields verbatim and gains
    // exactly one derived field — `tier`, inserted right after `md` (here
    // "system", from the --md-sys-* prefix). That is the row deriveTokenRows
    // now returns; the human override is otherwise untouched.
    const expectedRow = {
      figma: humanRow.figma,
      md: humanRow.md,
      tier: "system",
      tailwind: humanRow.tailwind,
      m3eFallback: humanRow.m3eFallback,
      provenance: humanRow.provenance,
      status: humanRow.status,
      note: humanRow.note,
    };

    // Pass 1: derive + write.
    const firstRows = deriveTokenRows(paths);
    writeTokens(tokensPath, firstRows);
    const firstPrimary = firstRows.find((r) => r.figma === "Schemes/Primary");
    assert.deepEqual(firstPrimary, expectedRow);

    // Pass 2: re-derive from scratch (simulating a re-run after upstream
    // dumps/theme.css/fallbacks change) — the human row must be BYTE
    // IDENTICAL, not just "still present".
    const secondRows = deriveTokenRows(paths);
    const secondPrimary = secondRows.find((r) => r.figma === "Schemes/Primary");
    assert.deepEqual(secondPrimary, expectedRow);
    assert.deepEqual(firstRows, secondRows, "the whole table is byte-stable across re-derives, not just the human row");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("writeTokens: writes deterministic, schema-shaped JSON (2-space indent, trailing newline, sorted by figma)", () => {
  const scratch = mkScratch();
  try {
    const tokensPath = path.join(scratch, "tokens.json");
    const rows = [
      { figma: "Zzz/Last", md: null, tailwind: null, m3eFallback: null, provenance: "auto", status: "unmapped", note: "" },
      { figma: "Aaa/First", md: null, tailwind: null, m3eFallback: null, provenance: "auto", status: "unmapped", note: "" },
    ];
    const written = writeTokens(tokensPath, rows);
    assert.deepEqual(
      written.map((r) => r.figma),
      ["Aaa/First", "Zzz/Last"]
    );
    const onDisk = fs.readFileSync(tokensPath, "utf8");
    assert.ok(onDisk.endsWith("\n"));
    assert.equal(onDisk, `${JSON.stringify(written, null, 2)}\n`);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

// -- buildRow: fallback + tailwind wiring on a single synthetic variable ----

test("buildRow: wires tailwind + m3eFallback together for one Schemes variable given synthetic joins/fallbacks", () => {
  const variable = { name: "Schemes/On Surface", family: "Schemes" };
  const ctx = {
    themeJoins: parseThemeJoins("@theme {\n  --color-on-surface: var(--md-sys-color-on-surface);\n}\n"),
    fallbacks: parseFallbacks('"var(--md-sys-color-on-surface, #1D1B20)"'),
    typescaleNames: new Set(),
  };
  const row = buildRow(variable, ctx);
  assert.deepEqual(row, {
    figma: "Schemes/On Surface",
    md: "--md-sys-color-on-surface",
    tailwind: { theme: "--color-on-surface", utils: ["bg-on-surface", "text-on-surface", "border-on-surface", "ring-on-surface"] },
    m3eFallback: "#1D1B20",
    provenance: "auto",
    status: "mapped",
    note: "",
  });
});

test("buildRow: a Schemes variable with no tailwind join and no fallback is still 'mapped', with a tailwind-gap note", () => {
  const variable = { name: "Schemes/Primary Fixed", family: "Schemes" };
  const ctx = { themeJoins: new Map(), fallbacks: new Map(), typescaleNames: new Set() };
  const row = buildRow(variable, ctx);
  assert.equal(row.status, "mapped");
  assert.equal(row.tailwind, null);
  assert.equal(row.m3eFallback, null);
  assert.match(row.note, /no @theme join/);
});

// -- Task D6: checkCoverage / familyStatusCounts (the coverage assertion) ----

test("checkCoverage: ok on a set of rows that are all mapped/policy, or unmapped WITH a note", () => {
  const rows = [
    { figma: "Schemes/Primary", status: "mapped", note: "" },
    { figma: "State Layers/Primary/Opacity-08", status: "policy", note: "policy: whole-family decision" },
    { figma: "Static/Weird/Thing", status: "unmapped", note: "genuinely undecided — flagged for follow-up" },
  ];
  const result = checkCoverage(rows);
  assert.equal(result.ok, true);
  assert.deepEqual(result.bare, []);
});

test("checkCoverage: FAILS on a synthetic bare-unmapped row (status:'unmapped', no note) — this is the exact silent-gap shape Task D6 Step 4 must catch", () => {
  const rows = [
    { figma: "Schemes/Primary", status: "mapped", note: "" },
    { figma: "Static/Sneaky/Gap", status: "unmapped", note: "" },
  ];
  const result = checkCoverage(rows);
  assert.equal(result.ok, false);
  assert.equal(result.bare.length, 1);
  assert.equal(result.bare[0].figma, "Static/Sneaky/Gap");
});

test("checkCoverage: a missing `note` field (not just an empty string) is also treated as bare", () => {
  const rows = [{ figma: "Static/No/NoteField", status: "unmapped" }];
  const result = checkCoverage(rows);
  assert.equal(result.ok, false);
  assert.equal(result.bare.length, 1);
});

test("checkCoverage: a whitespace-only note does not count as documented", () => {
  const rows = [{ figma: "Static/Whitespace/Note", status: "unmapped", note: "   " }];
  const result = checkCoverage(rows);
  assert.equal(result.ok, false);
});

test("checkCoverage: the real committed tokens.json passes — 0 bare unmapped rows (Task D6's acceptance criterion, exercised end-to-end)", () => {
  const rows = deriveTokenRows();
  const result = checkCoverage(rows);
  assert.equal(result.ok, true, `expected 0 bare unmapped rows, found: ${result.bare.map((r) => r.figma).join(", ")}`);
});

test("familyStatusCounts: the real committed tokens.json's per-family breakdown matches the README coverage table (Task D6 acceptance criteria)", () => {
  const rows = deriveTokenRows();
  const counts = familyStatusCounts(rows);
  assert.deepEqual(counts.get("Schemes"), { mapped: 49, policy: 0, unmapped: 0 });
  assert.deepEqual(counts.get("Corner"), { mapped: 10, policy: 0, unmapped: 0 });
  assert.deepEqual(counts.get("Static"), { mapped: 75, policy: 20, unmapped: 0 });
  assert.deepEqual(counts.get("State Layers"), { mapped: 0, policy: 147, unmapped: 0 });
  assert.deepEqual(counts.get("Tracking"), { mapped: 0, policy: 2, unmapped: 0 });
  assert.deepEqual(counts.get("Add-ons"), { mapped: 0, policy: 1, unmapped: 0 });
});
