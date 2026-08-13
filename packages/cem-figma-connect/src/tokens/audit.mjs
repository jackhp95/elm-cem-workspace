// Task D5: the cross-source token mismatch audit (plans/BRIEF.md §9;
// architecture §1 "Figma wins on design intent"). For each M3 color role,
// compares THREE independent sources of truth:
//
//   1. Kit variable per-mode hex (design intent) — D1's ingest
//      (`loadKitVariables`, `Schemes/*` family, Light/Dark modes of record).
//   2. tailwind-m3e-web's OKLCH-computed Light/Dark — the checked-in
//      `test/fixtures/tailwind-computed-palette.json` fixture (produced by
//      `src/tokens/resolve-palette.mjs`, which reuses tailwind-m3e-web's own
//      tone-calibration table rather than reimplementing it — see that
//      module's header). No OKLCH math runs here; this file only reads the
//      already-resolved fixture, per the brief's determinism requirement.
//   3. @m3e/web's baked `var(--md-sys-color-*, <hex>)` fallback — already
//      extracted into `profiles/m3-kit/tokens.json`'s `m3eFallback` field by
//      D2 (`src/tokens/derive.mjs`). Read directly, not re-extracted here.
//
// Classification (Step 3): a comparison over the deltaE tolerance is
// `naming-discrepancy` if some OTHER computed role name is a much closer
// match to the kit value (the correspondence table likely points at the
// wrong code-side slot); otherwise `spec-failure` (a genuine value
// disagreement — Figma wins per architecture §1; file a required-code-change
// against the offending repo/file).
//
// Step 5 (typescale/shape) is a SEPARATE, non-deltaE numeric exact-match
// check: Static/*'s Size/Line-Height/Tracking axes and Corner/* radii
// (already unit-converted px<->rem) against tailwind-m3e-web's
// src/sys/{typescale,shape}.css literals. Font-weight is explicitly OUT OF
// SCOPE for this exact-match gate — the kit variable resolves to a named
// font-style STRING ("Regular"/"Medium"/"SemiBold"), not a CSS numeric
// font-weight, so there is no unit-comparable number to exact-match (see
// "Scope decision" in the module's report).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { parse, differenceCiede2000 } from "culori";

import { loadKitVariables, MODES_OF_RECORD } from "./ingest.mjs";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

export const DEFAULT_PATHS = {
  variablesPath: path.join(repoRoot, "research", "figma-dumps", "kit-variables.json"),
  tokensPath: path.join(repoRoot, "profiles", "m3-kit", "tokens.json"),
  computedPalettePath: path.join(repoRoot, "test", "fixtures", "tailwind-computed-palette.json"),
  typescaleCssPath: path.join(
    repoRoot,
    "test",
    "fixtures",
    "tailwind-m3e-web-0.1.0",
    "src",
    "sys",
    "typescale.css"
  ),
  shapeCssPath: path.join(repoRoot, "test", "fixtures", "tailwind-m3e-web-0.1.0", "src", "sys", "shape.css"),
  reportPath: path.join(repoRoot, "profiles", "m3-kit", "token-audit.md"),
};

// Step 2's starting tolerance — the brief's "perceptibility threshold."
// Calibrated (see task-D5-report.md "deltaE tolerance calibration") against
// the 30/37 Schemes roles where kit-Light and @m3e/web's fallback are
// independently-authored yet agree to deltaE 0.000 — those are the
// known-identical roles the brief asks this to be calibrated on. 2.0 is kept
// as the default: every real per-role mismatch this audit found on the real
// inputs (both the container-tone regression and the "on-*-container"
// findings) measures well past it (>8), and every roundtrip/approximation
// noise row measures under ~4.5 — 2.0 is conservative (flags the noise band
// as "over tolerance" too) rather than tuned to hide it; see the report.
export const DEFAULT_TOLERANCE = 2.0;

// Empirical split between "tone-table hue-averaging noise" (measured ceiling
// ~4.5 dE across every role in this dataset) and a genuine tone-assignment
// bug (measured floor ~14 dE for the on-*-container regression) — see
// task-D5-report.md. 8.0 sits in the gap between the two clusters; it is a
// labeling aid for the generated report only, not a pass/fail gate (pass/
// fail is decided by DEFAULT_TOLERANCE against the real measured deltaE).
const ROOT_CAUSE_SPLIT_DELTA_E = 8.0;

// Roles whose above-tolerance gap is a STRUCTURAL derivation choice in
// `src/ref/palette.css`, not tone-table sampling noise — confirmed by
// reading that file directly (see task-D5-report.md "Fix round"):
//   - tertiary (`tertiary`, `on-tertiary`, `tertiary-container`):
//     `--md-ref-palette-tertiary-*` reuses PRIMARY's full chroma with the
//     hue rotated `+60°` (`oklch(from var(--md-seed-primary) <L> c calc(h +
//     60))`) — the kit's own tertiary is measurably more muted (a distinct
//     chroma), so this is a color-MODEL choice (which chroma tertiary
//     should carry), not an approximation-density issue.
//   - error (`error`): `--md-ref-palette-error-*` is derived from a wholly
//     INDEPENDENT seed (`var(--md-seed-error)`), not primary's hue family
//     at all, so it isn't "further from the sampling grid" — it's a
//     different palette by construction.
// A denser tone-table hue-sampling grid (the noise bucket's remedy, in
// `bin/calibrate-tones.mjs`) cannot close either gap: neither is a sampling
// problem. Detection is unaffected — these rows were already over
// tolerance and already surfaced as spec-failures; this only corrects which
// bucket (and therefore which remedy) they're filed under.
const MODEL_DIVERGENCE_ROLES = new Set(["tertiary", "on-tertiary", "tertiary-container", "error"]);

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}
function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

// -- kit color values --------------------------------------------------------

// colorToHex({r,g,b,a}) -> "#RRGGBB" (alpha dropped — every Schemes/* role in
// the measured kit dump is opaque; see ingest.test.mjs's own coverage of the
// raw shape). Rounds like Figma's own color picker (round-half-up per
// channel), matching how the kit's dump was authored.
export function colorToHex(v) {
  if (v == null || typeof v !== "object") return null;
  const chan = (x) => Math.round(x * 255).toString(16).padStart(2, "0");
  return `#${chan(v.r)}${chan(v.g)}${chan(v.b)}`.toUpperCase();
}

// roleNameFromMd(md) -> "primary" from "--md-sys-color-primary" (the shared
// key this module, the computed-palette fixture, and D2's tokens.json rows
// all key color roles by).
function roleNameFromMd(md) {
  return md?.startsWith("--md-sys-color-") ? md.slice("--md-sys-color-".length) : null;
}

// -- Step 2 + 3: per-role color comparison -----------------------------------

// buildColorRows({ variables, tokenRows, computedPalette, tolerance }) ->
// one row per Schemes/* tokens.json entry:
//   { figma, md, role, light: {kit, computed, fallback, deLightComputed,
//     deLightFallback}, dark: {kit, computed, deDarkComputed},
//     status: "match"|"naming-discrepancy"|"spec-failure"|"computed-unavailable",
//     rootCause?, suggestion?, note }
export function buildColorRows({ variables, tokenRows, computedPalette, tolerance = DEFAULT_TOLERANCE }) {
  const de = differenceCiede2000();
  const variableByName = new Map(variables.map((v) => [v.name, v]));
  const rows = [];

  const schemesRows = tokenRows.filter((r) => r.figma.startsWith("Schemes/"));

  for (const row of schemesRows) {
    const role = roleNameFromMd(row.md);
    if (!role) continue; // not a --md-sys-color-* row (shouldn't occur for Schemes, defensive)

    const variable = variableByName.get(row.figma);
    if (!variable) {
      rows.push({
        figma: row.figma,
        md: row.md,
        role,
        status: "error",
        note: `kit variable "${row.figma}" referenced by tokens.json not found in kit-variables.json`,
      });
      continue;
    }

    const kitLight = colorToHex(variable.valuesByModeName.Light);
    const kitDark = colorToHex(variable.valuesByModeName.Dark);
    const computedLight = computedPalette.light[role] ?? null;
    const computedDark = computedPalette.dark[role] ?? null;
    const fallback = row.m3eFallback ?? null;

    if (computedLight === null && computedDark === null) {
      // The 12 *-fixed* roles — no tailwind-m3e-web counterpart at all
      // (see resolve-palette.mjs's "NOT covered" note). Honest 2-source
      // report (kit vs fallback only), never a guessed 3rd value.
      const deFallback = fallback ? de(parse(kitLight), parse(fallback)) : null;
      rows.push({
        figma: row.figma,
        md: row.md,
        role,
        light: { kit: kitLight, computed: null, fallback, deFallback },
        dark: { kit: kitDark, computed: null },
        status: "computed-unavailable",
        note: "tailwind-m3e-web's sys/color.css has no counterpart for this *-fixed* role (measured gap, see task-D2-report.md)",
      });
      continue;
    }

    const deLightComputed = de(parse(kitLight), parse(computedLight));
    const deDarkComputed = de(parse(kitDark), parse(computedDark));
    const deLightFallback = fallback ? de(parse(kitLight), parse(fallback)) : null;

    const overTolerance =
      deLightComputed > tolerance ||
      deDarkComputed > tolerance ||
      (deLightFallback !== null && deLightFallback > tolerance);

    let status = "match";
    let rootCause;
    let suggestion;

    if (overTolerance) {
      // Step 3 classification: search every OTHER computed role (same mode)
      // for a closer match than the one this row is currently paired with.
      // If found and clearly better, the correspondence table (not the
      // value) is probably wrong -> naming-discrepancy. Otherwise the name
      // pairing is fine and the VALUE genuinely disagrees -> spec-failure.
      const altLight = closestRole(computedPalette.light, kitLight, role, de);
      const altDark = closestRole(computedPalette.dark, kitDark, role, de);
      const bestAlt = [altLight, altDark]
        .filter(Boolean)
        .sort((a, b) => a.deltaE - b.deltaE)[0];

      if (bestAlt && bestAlt.deltaE <= tolerance && bestAlt.deltaE < Math.min(deLightComputed, deDarkComputed)) {
        status = "naming-discrepancy";
        suggestion = `kit role "${role}" values match computed role "${bestAlt.role}" (deltaE ${bestAlt.deltaE.toFixed(3)}) far better than its current pairing "${role}" — check the token table mapping`;
      } else {
        status = "spec-failure";
        const maxDe = Math.max(deLightComputed, deDarkComputed, deLightFallback ?? 0);
        if (role.startsWith("on-") && role.endsWith("-container") && maxDe >= ROOT_CAUSE_SPLIT_DELTA_E) {
          rootCause = "container-tone-regression";
        } else if (MODEL_DIVERGENCE_ROLES.has(role)) {
          rootCause = "model-divergence";
        } else {
          rootCause = "tone-table-approximation-noise";
        }
      }
    }

    rows.push({
      figma: row.figma,
      md: row.md,
      role,
      light: { kit: kitLight, computed: computedLight, fallback, deLightComputed, deLightFallback },
      dark: { kit: kitDark, computed: computedDark, deDarkComputed },
      status,
      rootCause,
      suggestion,
    });
  }

  rows.sort(byKey((r) => r.figma));
  return rows;
}

// closestRole(paletteMode, targetHex, excludeRole, de) -> {role, deltaE} for
// the best (lowest deltaE) OTHER role in `paletteMode`, or null if empty.
function closestRole(paletteMode, targetHex, excludeRole, de) {
  const target = parse(targetHex);
  let best = null;
  for (const [role, hex] of Object.entries(paletteMode)) {
    if (role === excludeRole) continue;
    const deltaE = de(target, parse(hex));
    if (!best || deltaE < best.deltaE) best = { role, deltaE };
  }
  return best;
}

// -- Step 5: typescale/shape EXACT numeric match -----------------------------

// Matches either `<name>: <num>rem;` or the bare-zero form `<name>: 0;`
// (typescale.css writes untracked axes as literal `0`, no unit — measured:
// display-medium/small, headline-large/medium/small, title-large-tracking).
const REM_DECL_RE = (name) => new RegExp(`${name}:\\s*([\\d.]+)(rem)?\\s*;`);

function parseRemToken(css, name) {
  const m = css.match(REM_DECL_RE(name));
  if (!m) return null;
  const value = parseFloat(m[1]);
  return m[2] ? value * 16 : value; // rem -> px, or already a bare unitless 0
}

// resolveShapeToken(css, md) -> literal px for a --md-sys-shape-corner-<slug>
// role token: "full" has its own literal; everything else is `var(...)` onto
// --md-sys-shape-corner-value-<slug>, which IS the literal (shape.css lines
// 14-22 vs 24-36).
function resolveShapeToken(css, md) {
  const slug = md.replace("--md-sys-shape-corner-", "");
  if (slug === "full") return parseRemToken(css, "--md-sys-shape-corner-full");
  if (slug === "none") return 0; // --md-sys-shape-corner-value-none: 0 (unitless)
  return parseRemToken(css, `--md-sys-shape-corner-value-${slug}`);
}

const EXACT_EPSILON = 1e-3; // absorbs float32 rounding noise measured in the kit dump (e.g. 0.4000000059604645)

// Step 5 mismatch classification (this round's fix): every numeric mismatch
// is either a real code-side value disagreement ("required-code-change" —
// files under REQUIRED CODE CHANGES, Figma wins per architecture §1) or a
// "benign-equivalent" — the two values differ but are semantically the same
// in practice. Classification is by VALUE RELATIONSHIP, not by hardcoding
// which row is "the bug": the default for any mismatch is
// required-code-change; a row is downgraded to benign-equivalent ONLY if
// it's explicitly allowlisted below with a documented reason. This keeps the
// rule principled (annotate the known-equivalent pairs; everything else is a
// real spec failure) without special-casing today's known bug (the
// Display Large tracking sign-flip) in the classifier itself.
//
// `Corner/Full` (--md-sys-shape-corner-full): kit 1000px vs tailwind-m3e-web
// 9999px. Both numbers exist purely to force full-pill rounding — CSS
// border-radius clamps to min(radius, half the box's shorter side), so ANY
// value at or beyond that half-side renders an identical fully-rounded
// pill/circle for every realistic component size. 1000 and 9999 are both
// far past that threshold for every M3e component; there is no value of
// "corner radius" at which these two numbers would ever render differently.
const BENIGN_EQUIVALENT_NUMERIC_MISMATCHES = new Map([
  [
    "Corner/Full",
    "both force full-pill rounding (border-radius clamps to half the box's " +
      "shorter side, so any value past that threshold renders identically) — " +
      "1000px and 9999px are both \"effectively infinite\" pill radii for every " +
      "realistic component size. Semantically equivalent — not a required change.",
  ],
]);

// classifyNumericMismatch(row) -> { classification: "required-code-change" |
// "benign-equivalent", detail } | null (null for exact matches — nothing to
// classify). `detail` names the value relationship (sign-flip vs magnitude
// disagreement) for required-code-change rows, or the benign-equivalence
// reason for allowlisted rows.
export function classifyNumericMismatch(row) {
  if (row.match) return null;

  if (BENIGN_EQUIVALENT_NUMERIC_MISMATCHES.has(row.figma)) {
    return { classification: "benign-equivalent", detail: BENIGN_EQUIVALENT_NUMERIC_MISMATCHES.get(row.figma) };
  }

  if (row.codePx === null) {
    return { classification: "required-code-change", detail: "code-side token not found" };
  }

  const sameMagnitude = Math.abs(Math.abs(row.kitPx) - Math.abs(row.codePx)) < EXACT_EPSILON;
  const oppositeSign = Math.sign(row.kitPx) !== Math.sign(row.codePx) && row.kitPx !== 0 && row.codePx !== 0;
  const detail =
    sameMagnitude && oppositeSign
      ? `sign-flipped — same magnitude (${Math.abs(row.kitPx)}), opposite sign (kit ${row.kitPx} vs code ${row.codePx})`
      : `magnitude disagreement (kit ${row.kitPx} vs code ${row.codePx})`;
  return { classification: "required-code-change", detail };
}

// buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss }) ->
// one row per Static/*{Size,Line Height,Tracking} + Corner/* tokens.json
// entry that D2 marked "mapped": { figma, md, axis, kitPx, codePx, match,
// classification, classificationDetail }. classification/classificationDetail
// are null for exact matches (see classifyNumericMismatch above).
export function buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss }) {
  const variableByName = new Map(variables.map((v) => [v.name, v]));
  const rows = [];

  for (const row of tokenRows) {
    if (row.status !== "mapped") continue;
    const isStaticAxis =
      row.figma.startsWith("Static/") && /\/(Size|Line Height|Tracking)$/.test(row.figma);
    const isCorner = row.figma.startsWith("Corner/");
    if (!isStaticAxis && !isCorner) continue;

    const variable = variableByName.get(row.figma);
    if (!variable) continue;
    const kitPx = variable.valuesByModeName.Baseline;
    if (typeof kitPx !== "number") continue;

    const codePx = isCorner ? resolveShapeToken(shapeCss, row.md) : parseRemToken(typescaleCss, row.md);
    const codeFile = isCorner ? "tailwind-m3e-web/src/sys/shape.css" : "tailwind-m3e-web/src/sys/typescale.css";
    if (codePx === null) {
      const built = { figma: row.figma, md: row.md, kitPx, codePx: null, match: false, note: "code-side token not found", codeFile };
      const cls = classifyNumericMismatch(built);
      rows.push({ ...built, classification: cls.classification, classificationDetail: cls.detail });
      continue;
    }

    const match = Math.abs(kitPx - codePx) < EXACT_EPSILON;
    const built = { figma: row.figma, md: row.md, kitPx, codePx, match, codeFile };
    const cls = classifyNumericMismatch(built);
    rows.push({ ...built, classification: cls?.classification ?? null, classificationDetail: cls?.detail ?? null });
  }

  rows.sort(byKey((r) => r.figma));
  return rows;
}

// -- Step 4: extra modes (report-only, never gating) -------------------------

// listExtraModes(collections) -> mode names beyond Light/Dark on the M3
// collection (13 hue LT/DT + contrast tiers). No comparison is performed —
// tailwind-m3e-web derives its 13 hue variants from independent CSS seeds,
// a different mechanism with no per-mode computed counterpart to diff
// against (documented in the brief; restated in the generated report).
export function listExtraModes(collections) {
  const m3 = collections.find((c) => c.name === "M3");
  if (!m3) return [];
  return m3.modes.map((m) => m.name).filter((name) => !MODES_OF_RECORD.includes(name));
}

// -- Markdown report ----------------------------------------------------------

function fmtHex(hex) {
  return hex ?? "—";
}
function fmtDe(de) {
  return de === undefined || de === null ? "—" : de.toFixed(3);
}

export function renderReport({ colorRows, numericRows, extraModes, tolerance }) {
  const lines = [];
  lines.push("# m3-kit token audit — cross-source mismatch report (Task D5)");
  lines.push("");
  lines.push(
    "Generated by `node src/tokens/audit.mjs --profile m3-kit`. Compares, per M3 color role, " +
      "three independent sources: **kit** (Figma variable Light/Dark hex — design intent), " +
      "**computed** (tailwind-m3e-web's OKLCH-derived Light/Dark, from the checked-in " +
      "`test/fixtures/tailwind-computed-palette.json` fixture), and **fallback** (@m3e/web's " +
      "baked `var(--md-sys-color-*, <hex>)` default, from `profiles/m3-kit/tokens.json`'s " +
      "`m3eFallback` field). Per architecture §1, Figma wins on design intent: a value " +
      "disagreement is classified a code-side spec-failure, never silently papered over."
  );
  lines.push("");
  lines.push(
    `DeltaE via culori's CIEDE2000 (\`differenceCiede2000\`); tolerance **${tolerance.toFixed(1)}** ` +
      "(perceptibility threshold — see task-D5-report.md for calibration)."
  );
  lines.push("");
  lines.push(
    "**Mode scope (Step 4):** Light + Dark are gating (asserted below for every role). " +
      "The 13 hue themes + contrast tiers are report-only, listed in the appendix — " +
      "tailwind-m3e-web derives its theme variants from independent CSS seeds, a " +
      "different mechanism with no per-mode computed counterpart to diff against, so no " +
      "comparison is attempted for them."
  );
  lines.push("");
  lines.push(
    "**Fallback is Light-only by construction:** @m3e/web's baked fallback is a single " +
      "static default (measured: it equals the kit's Light hex for every role that has one, " +
      "and never the Dark hex) — comparing it against kit Dark would always show a large, " +
      "meaningless deltaE. Fallback is therefore only compared against kit Light."
  );
  lines.push("");

  const byStatus = { match: [], "naming-discrepancy": [], "spec-failure": [], "computed-unavailable": [], error: [] };
  for (const row of colorRows) byStatus[row.status]?.push(row);

  const numericRequiredChanges = numericRows.filter((r) => r.classification === "required-code-change");
  const numericBenign = numericRows.filter((r) => r.classification === "benign-equivalent");

  lines.push("## Summary");
  lines.push("");
  lines.push(`- Color roles compared (Schemes/\\*, Light + Dark gating): **${colorRows.length}**`);
  lines.push(`  - match (within tolerance): **${byStatus.match.length}**`);
  lines.push(`  - naming-discrepancy: **${byStatus["naming-discrepancy"].length}**`);
  lines.push(`  - spec-failure: **${byStatus["spec-failure"].length}**`);
  lines.push(
    `  - computed-unavailable (*-fixed* roles — no tailwind-m3e-web counterpart): **${byStatus["computed-unavailable"].length}**`
  );
  if (byStatus.error.length) lines.push(`  - error: **${byStatus.error.length}**`);
  lines.push(`- Typescale/shape exact-match rows (Step 5): **${numericRows.length}**`);
  lines.push(`  - exact match: **${numericRows.filter((r) => r.match).length}**`);
  lines.push(`  - mismatch: **${numericRows.filter((r) => !r.match).length}**`);
  lines.push(`    - required-code-change: **${numericRequiredChanges.length}**`);
  lines.push(`    - benign-equivalent (semantically the same value, not a required change): **${numericBenign.length}**`);
  lines.push("");

  if (byStatus["spec-failure"].length || numericRequiredChanges.length) {
    lines.push("## REQUIRED CODE CHANGES (spec-failures — Figma wins on design intent)");
    lines.push("");
    const byRootCause = new Map();
    for (const row of byStatus["spec-failure"]) {
      const key = row.rootCause ?? "unclassified";
      if (!byRootCause.has(key)) byRootCause.set(key, []);
      byRootCause.get(key).push(row);
    }
    if (byRootCause.has("container-tone-regression")) {
      const affected = byRootCause.get("container-tone-regression");
      const fallbackDes = affected.map((r) => r.light.deLightFallback).filter((d) => d !== null && d !== undefined);
      const fbMin = Math.min(...fallbackDes);
      const fbMax = Math.max(...fallbackDes);
      lines.push("### 1. `tailwind-m3e-web` — `src/sys/color.css`: on-\\*-container tone regression");
      lines.push("");
      lines.push(
        "The file's own header comment (lines 14-16) documents `on-container` roles at **tone 10** " +
          "(the original M3 spec). The kit — and @m3e/web's own baked fallback, independently " +
          `(deltaE ${fbMin.toFixed(3)}–${fbMax.toFixed(3)} vs kit, per role below) — use **tone 30** for these same roles, ` +
          "matching the current M3 spec revision. `sys/color.css` is stale."
      );
      lines.push("");
      lines.push("Affected roles (measured deltaE, Light mode, kit vs computed; and kit vs @m3e/web fallback):");
      for (const row of affected) {
        lines.push(`- \`${row.md}\`: deltaE ${fmtDe(row.light.deLightComputed)} (kit \`${row.light.kit}\` vs computed \`${row.light.computed}\`; @m3e/web fallback \`${row.light.fallback}\` deltaE ${fmtDe(row.light.deLightFallback)} vs kit)`);
      }
      lines.push("");
      lines.push(
        "**Required change:** re-derive `--md-sys-color-on-{primary,secondary,tertiary,error}-container` " +
          "(light mode) from tone **30** of the respective palette, not tone 10."
      );
      lines.push("");
    }
    if (byRootCause.has("model-divergence")) {
      const affected = byRootCause.get("model-divergence");
      lines.push("### 2. `tailwind-m3e-web` — `src/ref/palette.css`: tertiary/error structural derivation divergence");
      lines.push("");
      lines.push(
        "These roles' gap is NOT tone-table sampling noise — it comes from a structural derivation " +
          "choice in `src/ref/palette.css` itself, confirmed by reading the file directly: " +
          "`--md-ref-palette-tertiary-*` reuses **primary's own full chroma**, only rotating hue by " +
          "`+60°` (`oklch(from var(--md-seed-primary) <L> c calc(h + 60))`), while the kit's tertiary " +
          "is measurably more muted — a genuinely different chroma model, a color-model choice, not an " +
          "approximation-density issue. `--md-ref-palette-error-*` is derived from a wholly " +
          "**independent seed** (`var(--md-seed-error)`), not primary's hue family at all, so it isn't " +
          "\"further from the sampling grid\" the way the tone-table-noise roles are — it's a different " +
          "palette by construction. Denser hue-sampling in `bin/calibrate-tones.mjs` (the remedy below " +
          "for genuine tone-table noise) cannot fix either of these; the fix belongs in the tertiary/" +
          "error derivation itself, not the tone table."
      );
      lines.push("");
      lines.push("Affected roles (measured max deltaE across Light/Dark/fallback):");
      for (const row of affected) {
        const maxDe = Math.max(row.light.deLightComputed, row.dark.deDarkComputed, row.light.deLightFallback ?? 0);
        lines.push(`- \`${row.md}\`: max deltaE ${maxDe.toFixed(3)}`);
      }
      lines.push("");
      lines.push(
        "**Required change:** reconcile the tertiary/error derivation in `src/ref/palette.css` " +
          "(e.g. give tertiary its own calibrated chroma instead of reusing primary's, and/or verify " +
          "error's independent seed against the kit's intended error hue/chroma) — do **not** " +
          "adjust the tone table's hue-sampling density for these roles; that would not change the result."
      );
      lines.push("");
    }
    if (byRootCause.has("tone-table-approximation-noise")) {
      const affected = byRootCause.get("tone-table-approximation-noise");
      lines.push("### 3. `tailwind-m3e-web` — `bin/calibrate-tones.mjs` tone-table approximation");
      lines.push("");
      lines.push(
        "The calibrated tone table averages OKLCH L over only 12 sampled hues per tone " +
          "(`bin/calibrate-tones.mjs`'s own header: \"L doesn't perfectly match M3's HCT tone\"). " +
          "This is a documented, accepted approximation — but it measurably crosses the " +
          `${tolerance.toFixed(1)} deltaE tolerance for several roles on this kit's specific seed hue. ` +
          "(Tertiary and error are excluded from this group — see the structural-divergence section " +
          "above; their gap is a derivation-model choice, not tone-table sampling density.)"
      );
      lines.push("");
      lines.push("Affected roles (measured max deltaE across Light/Dark/fallback):");
      for (const row of affected) {
        const maxDe = Math.max(row.light.deLightComputed, row.dark.deDarkComputed, row.light.deLightFallback ?? 0);
        lines.push(`- \`${row.md}\`: max deltaE ${maxDe.toFixed(3)}`);
      }
      lines.push("");
      lines.push(
        "**Required change (quality improvement, not a functional bug):** increase the tone table's " +
          "hue-sampling density (or switch from averaging to hue-interpolation) in " +
          "`bin/calibrate-tones.mjs` so approximation error stays under the perceptibility threshold " +
          "across the sampled hue range."
      );
      lines.push("");
    }
    for (const [key, affected] of byRootCause) {
      if (
        key === "container-tone-regression" ||
        key === "model-divergence" ||
        key === "tone-table-approximation-noise"
      )
        continue;
      lines.push(`### Unclassified spec-failure group: ${key}`);
      lines.push("");
      for (const row of affected) lines.push(`- \`${row.md}\``);
      lines.push("");
    }
    if (numericRequiredChanges.length) {
      const numberedKnownKeys = ["container-tone-regression", "model-divergence", "tone-table-approximation-noise"];
      const nextIndex = numberedKnownKeys.filter((k) => byRootCause.has(k)).length + 1;
      lines.push(`### ${nextIndex}. Step 5 (typescale/shape) numeric spec-failures`);
      lines.push("");
      lines.push(
        "Unlike the color rows above (deltaE tolerance), these are EXACT-match rows (px, unit-" +
          "converted) — any mismatch not explicitly allowlisted as benign-equivalent (see the " +
          "`Corner/Full` note under Step 5 below) is a real value disagreement. Figma wins on " +
          "design intent (architecture §1)."
      );
      lines.push("");
      for (const row of numericRequiredChanges) {
        lines.push(
          `- \`${row.md}\` (${row.figma}): ${row.classificationDetail}. **Remedy:** \`${row.codeFile}\` — ` +
            `change \`${row.md}\` to \`${row.kitPx}\` (kit value, matches the public M3 spec).`
        );
      }
      lines.push("");
    }
  } else {
    lines.push("## REQUIRED CODE CHANGES");
    lines.push("");
    lines.push("None — every color role is within tolerance across all three sources, and every Step 5 numeric mismatch is benign-equivalent.");
    lines.push("");
  }

  if (byStatus["naming-discrepancy"].length) {
    lines.push("## Naming discrepancies (fix the token table mapping, not the code)");
    lines.push("");
    for (const row of byStatus["naming-discrepancy"]) {
      lines.push(`- \`${row.md}\`: ${row.suggestion}`);
    }
    lines.push("");
  }

  lines.push("## Full color-role comparison (Schemes/\\*)");
  lines.push("");
  lines.push("| Figma | md | Light: kit / computed (dE) / fallback (dE) | Dark: kit / computed (dE) | status |");
  lines.push("|---|---|---|---|---|");
  for (const row of colorRows) {
    if (row.status === "computed-unavailable") {
      lines.push(
        `| ${row.figma} | \`${row.md}\` | ${fmtHex(row.light?.kit)} / — / ${fmtHex(row.light?.fallback)} (${fmtDe(row.light?.deFallback)}) | ${fmtHex(row.dark?.kit)} / — | ${row.status} |`
      );
      continue;
    }
    if (row.status === "error") {
      lines.push(`| ${row.figma} | \`${row.md}\` | — | — | error: ${row.note} |`);
      continue;
    }
    lines.push(
      `| ${row.figma} | \`${row.md}\` | ${fmtHex(row.light.kit)} / ${fmtHex(row.light.computed)} (${fmtDe(row.light.deLightComputed)}) / ${fmtHex(row.light.fallback)} (${fmtDe(row.light.deLightFallback)}) | ${fmtHex(row.dark.kit)} / ${fmtHex(row.dark.computed)} (${fmtDe(row.dark.deDarkComputed)}) | ${row.status}${row.rootCause ? ` (${row.rootCause})` : ""} |`
    );
  }
  lines.push("");

  lines.push("## Step 5 — typescale/shape exact-match (px, unit-converted; NOT deltaE)");
  lines.push("");
  lines.push(
    "Font-weight is out of scope for this gate: the kit's `Static/*/Weight[-emphasized]` " +
      "variables resolve to a named font-STYLE string (`\"Regular\"`/`\"Medium\"`/`\"SemiBold\"`), " +
      "not a CSS numeric `font-weight` — there is no unit-comparable number to exact-match without " +
      "an interpretive Regular/Medium/SemiBold -> 400/500/700 translation table, which is a naming " +
      "question, not this step's numeric gate."
  );
  lines.push("");
  lines.push("| Figma | md | kit (px) | code (px) | match | classification |");
  lines.push("|---|---|---|---|---|---|");
  for (const row of numericRows) {
    const classificationLabel = row.match
      ? "—"
      : row.classification === "required-code-change"
        ? "**required-code-change**"
        : "benign-equivalent";
    lines.push(
      `| ${row.figma} | \`${row.md}\` | ${row.kitPx} | ${row.codePx ?? "—"} | ${row.match ? "✅" : "❌ MISMATCH"} | ${classificationLabel} |`
    );
  }
  lines.push("");

  const mismatches = numericRows.filter((r) => !r.match);
  if (mismatches.length) {
    lines.push("### Step 5 mismatches — detail");
    lines.push("");
    for (const row of mismatches) {
      if (row.classification === "required-code-change") {
        lines.push(
          `- \`${row.md}\` (${row.figma}): kit **${row.kitPx}px** vs tailwind-m3e-web **${row.codePx}px** — ` +
            `**required-code-change** (${row.classificationDetail}) — see REQUIRED CODE CHANGES above for the remedy.`
        );
      } else {
        lines.push(
          `- \`${row.md}\` (${row.figma}): kit **${row.kitPx}px** vs tailwind-m3e-web **${row.codePx}px** — ` +
            `**benign-equivalent** — ${row.classificationDetail}`
        );
      }
    }
    lines.push("");
  }

  if (extraModes.length) {
    lines.push("## Appendix — extra modes (Step 4, report-only, `--audit-all-modes`)");
    lines.push("");
    lines.push(
      `${extraModes.length} additional M3 modes exist in the kit dump beyond Light/Dark ` +
        "(13 hue themes × LT/DT + contrast tiers). tailwind-m3e-web has no per-mode computed " +
        "counterpart for these (it derives hue variants from independent CSS seeds, not from " +
        "this kit's per-mode values) — listed for completeness only, never compared or gated:"
    );
    lines.push("");
    for (const mode of extraModes) lines.push(`- ${mode}`);
    lines.push("");
  }

  return lines.join("\n");
}

// -- top-level orchestration --------------------------------------------------

export function runAudit(paths = {}, { tolerance = DEFAULT_TOLERANCE, auditAllModes = false } = {}) {
  const p = { ...DEFAULT_PATHS, ...paths };

  const { collections, variables } = loadKitVariables(p.variablesPath);
  const tokenRows = readJson(p.tokensPath);
  const computedPalette = readJson(p.computedPalettePath);
  const typescaleCss = readText(p.typescaleCssPath);
  const shapeCss = readText(p.shapeCssPath);

  const colorRows = buildColorRows({ variables, tokenRows, computedPalette, tolerance });
  const numericRows = buildNumericRows({ variables, tokenRows, typescaleCss, shapeCss });
  const extraModes = auditAllModes ? listExtraModes(collections) : [];

  const report = renderReport({ colorRows, numericRows, extraModes, tolerance });
  return { colorRows, numericRows, extraModes, report };
}

// -- CLI ----------------------------------------------------------------------

function parseCliArgs(argv) {
  const options = { tolerance: DEFAULT_TOLERANCE, auditAllModes: false };
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--tolerance") {
      options.tolerance = parseFloat(argv[++i]);
    } else if (argv[i] === "--audit-all-modes") {
      options.auditAllModes = true;
    } else if (argv[i] === "--profile") {
      options.profile = argv[++i]; // accepted for CLI-shape parity; m3-kit is the only wired profile
    }
  }
  return options;
}

function main(argv) {
  const options = parseCliArgs(argv);
  const { colorRows, numericRows, report } = runAudit({}, options);

  fs.mkdirSync(path.dirname(DEFAULT_PATHS.reportPath), { recursive: true });
  fs.writeFileSync(DEFAULT_PATHS.reportPath, `${report}\n`, "utf8");

  const specFailures = colorRows.filter((r) => r.status === "spec-failure").length;
  const mismatches = numericRows.filter((r) => !r.match).length;
  process.stdout.write(
    `audit.mjs: wrote ${DEFAULT_PATHS.reportPath} ` +
      `(${colorRows.length} color rows, ${specFailures} spec-failures; ` +
      `${numericRows.length} numeric rows, ${mismatches} mismatches)\n`
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
