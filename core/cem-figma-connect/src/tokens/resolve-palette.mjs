// Task D5, source #2 resolution: tailwind-m3e-web computes its M3 color
// roles ENTIRELY in CSS relative-color syntax — `oklch(from var(--md-seed-*)
// <L> <c-expr> <h-expr>)` (src/ref/palette.css) composed with `light-dark()`
// and a further `oklch(from <ref> calc(l ± delta) c h)` relative offset for
// the surface family (src/sys/color.css). There is no headless browser in
// this project's toolchain, so those CSS expressions have no JS evaluator to
// call — this module IS that evaluator, mirroring the two source files
// arithmetically via `culori`, cited line-for-line against the workspace
// package (packages/tailwind-m3e-web/src/{ref/palette.css,sys/color.css}).
// (M5: was a vendored, commit-pinned copy under
// test/fixtures/tailwind-m3e-web-0.1.0/ — repointed at the real co-located
// package now that both live in this workspace and move together; there is
// no separate pin to track.)
//
// What is REUSED, not reimplemented (the brief's hard requirement): the
// perceptual tone→OKLCH-lightness CALIBRATION — averaging
// @material/material-color-utilities's HCT output over 12 hues per tone,
// the actual judgment-laden "OKLCH math" bin/calibrate-tones.mjs performs —
// is read verbatim from the vendored, already-computed
// `src/ref/_tone-table.css` (checked in there BY tailwind-m3e-web itself, a
// deterministic artifact of that script). This module never recomputes a
// single L-per-tone value; it only plugs those numbers into the same
// relative-color arithmetic the CSS engine would run.
//
// Gamut mapping: CSS `oklch()` (and the relative-color form used here) is
// gamut-mapped by the browser per CSS Color 4 ("hold L and H, binary-search
// the maximum in-gamut C" — see https://www.w3.org/TR/css-color-4/#css-gamut-mapping).
// culori's `clampChroma(color, "oklch")` implements that same algorithm
// (CSS Color 4 gamut mapping onto the default "rgb" destination), so every
// resolved color is passed through it before formatting to hex — matching
// what a real browser does for any oklch() value, in-gamut or not (e.g. an
// out-of-gamut tone-100 "white-ish" primary correctly clamps to pure
// #ffffff, not a naive per-channel clip that leaves a color cast).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { converter, formatHex, parse, clampChroma } from "culori";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");

const VENDORED_DIR = path.join(repoRoot, "..", "..", "brands", "m3e", "outputs", "tailwind-m3e-web", "src");
const FIXTURE_PATH = path.join(repoRoot, "test", "fixtures", "tailwind-computed-palette.json");

// Version of the workspace tailwind-m3e-web package this fixture was computed
// from (read live, not pinned — see the header note above). Update the
// fixture (`--write`) whenever that package's src/seed.css, src/ref/*.css
// change.
const TAILWIND_M3E_WEB_VERSION = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "..", "..", "brands", "m3e", "outputs", "tailwind-m3e-web", "package.json"), "utf8")
).version;

const TONES = [10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];

const toOklch = converter("oklch");

function gamutMappedHex(oklchColor) {
  return formatHex(clampChroma(oklchColor, "oklch"));
}

// -- parsing the vendored CSS (numbers only; no CSS engine involved) --------

// parseToneTable(css) -> { rich: {10: L0..1, ...}, neutral: {...} }
// Reads `--_m3e-tone-<N>-<profile>: <pct>%;` (src/ref/_tone-table.css).
export function parseToneTable(css) {
  const out = { rich: {}, neutral: {} };
  for (const profile of ["rich", "neutral"]) {
    for (const tone of TONES) {
      const m = css.match(new RegExp(`--_m3e-tone-${tone}-${profile}:\\s*([\\d.]+)%`));
      if (!m) {
        throw new Error(`tone table missing --_m3e-tone-${tone}-${profile}`);
      }
      out[profile][tone] = parseFloat(m[1]) / 100;
    }
  }
  return out;
}

// parseSeeds(css) -> { primary: "#6750a4", error: "#b3261e" } (src/seed.css)
export function parseSeeds(css) {
  const primary = css.match(/--md-seed-primary:\s*(#[0-9a-fA-F]{3,8})/);
  const error = css.match(/--md-seed-error:\s*(#[0-9a-fA-F]{3,8})/);
  if (!primary || !error) {
    throw new Error("seed.css missing --md-seed-primary/--md-seed-error");
  }
  return { primary: primary[1], error: error[1] };
}

// -- Layer 1: src/ref/palette.css — one 12-tone scale per named palette ----
//
// Mirrors palette.css lines 22-106 exactly:
//   primary          L=rich[N]     c=seed.c          h=seed.h
//   secondary        L=rich[N]     c=seed.c*0.33     h=seed.h
//   tertiary         L=rich[N]     c=seed.c          h=seed.h+60
//   neutral          L=neutral[N]  c=0.01 (fixed)     h=seed.h
//   neutral-variant  L=neutral[N]  c=0.025 (fixed)    h=seed.h
//   error            L=rich[N]     c=errorSeed.c     h=errorSeed.h  (independent seed)
export function resolveRefPalette({ toneTable, seeds }) {
  const seedPrimary = toOklch(parse(seeds.primary));
  const seedError = toOklch(parse(seeds.error));

  function scale(L, seed, cFn, hOffset = 0) {
    const out = {};
    for (const tone of TONES) {
      out[tone] = gamutMappedHex({
        mode: "oklch",
        l: L[tone],
        c: cFn(seed),
        h: (seed.h ?? 0) + hOffset,
      });
    }
    return out;
  }

  return {
    primary: scale(toneTable.rich, seedPrimary, (s) => s.c),
    secondary: scale(toneTable.rich, seedPrimary, (s) => s.c * 0.33),
    tertiary: scale(toneTable.rich, seedPrimary, (s) => s.c, 60),
    neutral: scale(toneTable.neutral, seedPrimary, () => 0.01),
    neutralVariant: scale(toneTable.neutral, seedPrimary, () => 0.025),
    error: scale(toneTable.rich, seedError, (s) => s.c),
  };
}

// relOffset(hex, deltaL) -> gamut-mapped hex for
//   oklch(from <hex> calc(l + deltaL) c h)
// (the src/sys/color.css surface-family relative-offset pattern).
function relOffset(hex, deltaL) {
  const o = toOklch(parse(hex));
  return gamutMappedHex({ mode: "oklch", l: o.l + deltaL, c: o.c, h: o.h });
}

// -- Layer 2: src/sys/color.css — light-dark() role pairs ------------------
//
// Mirrors sys/color.css lines 42-223. Each entry is [lightExpr, darkExpr]
// evaluated against the ref palette `P` resolved above. Direct role pairs
// read a single palette tone per mode (M3's 40/100/90/10 light,
// 80/20/30/90 dark spec ladder); the surface/background family additionally
// applies the file's own `calc(l ± delta)` relative offsets.
//
// NOT covered (documented gap, not silently dropped): the 12 "*-fixed*"
// color roles (Primary/Secondary/Tertiary Fixed[-Dim], On-*-Fixed[-Variant])
// have NO counterpart anywhere in sys/color.css — grepped, confirmed absent,
// matching task-D2-report.md's independent finding. resolveSysColorRoles
// simply never emits `on-primary-fixed` etc.; audit.mjs is responsible for
// treating those 12 kit roles as "computed: unavailable", not for guessing.
export function resolveSysColorRoles(P) {
  const role = (light, dark) => ({ light, dark });

  return {
    primary: role(P.primary[40], P.primary[80]),
    "on-primary": role(P.primary[100], P.primary[20]),
    "primary-container": role(P.primary[90], P.primary[30]),
    "on-primary-container": role(P.primary[10], P.primary[90]),

    secondary: role(P.secondary[40], P.secondary[80]),
    "on-secondary": role(P.secondary[100], P.secondary[20]),
    "secondary-container": role(P.secondary[90], P.secondary[30]),
    "on-secondary-container": role(P.secondary[10], P.secondary[90]),

    tertiary: role(P.tertiary[40], P.tertiary[80]),
    "on-tertiary": role(P.tertiary[100], P.tertiary[20]),
    "tertiary-container": role(P.tertiary[90], P.tertiary[30]),
    "on-tertiary-container": role(P.tertiary[10], P.tertiary[90]),

    error: role(P.error[40], P.error[80]),
    "on-error": role(P.error[100], P.error[20]),
    "error-container": role(P.error[90], P.error[30]),
    "on-error-container": role(P.error[10], P.error[90]),

    surface: role(relOffset(P.neutral[99], -0.01), relOffset(P.neutral[10], -0.04)),
    "on-surface": role(P.neutral[10], P.neutral[90]),
    "surface-variant": role(P.neutralVariant[90], P.neutralVariant[30]),
    "on-surface-variant": role(P.neutralVariant[30], P.neutralVariant[80]),
    "surface-dim": role(relOffset(P.neutral[90], -0.03), relOffset(P.neutral[10], -0.04)),
    "surface-bright": role(relOffset(P.neutral[99], -0.01), relOffset(P.neutral[20], 0.04)),
    "surface-container-lowest": role(P.neutral[100], relOffset(P.neutral[10], -0.06)),
    "surface-container-low": role(relOffset(P.neutral[95], 0.01), P.neutral[10]),
    "surface-container": role(relOffset(P.neutral[95], -0.01), relOffset(P.neutral[10], 0.02)),
    "surface-container-high": role(relOffset(P.neutral[90], 0.02), relOffset(P.neutral[20], -0.03)),
    "surface-container-highest": role(P.neutral[90], relOffset(P.neutral[20], 0.02)),
    "surface-tint": role(P.primary[40], P.primary[80]),

    outline: role(P.neutralVariant[50], P.neutralVariant[60]),
    "outline-variant": role(P.neutralVariant[80], P.neutralVariant[30]),

    "inverse-surface": role(P.neutral[20], P.neutral[90]),
    "inverse-on-surface": role(P.neutral[95], P.neutral[20]),
    "inverse-primary": role(P.primary[80], P.primary[40]),

    background: role(relOffset(P.neutral[99], -0.01), relOffset(P.neutral[10], -0.04)),
    "on-background": role(P.neutral[10], P.neutral[90]),

    // Fixed opaque black in both schemes (sys/color.css lines 108-109).
    shadow: role("#000000", "#000000"),
    scrim: role("#000000", "#000000"),
  };
}

// resolveComputedPalette({ seedCss, toneTableCss }) -> { light: {role: hex},
// dark: {role: hex} } — the top-level entry point audit.mjs and the fixture
// generator both call.
export function resolveComputedPalette({ seedCss, toneTableCss }) {
  const seeds = parseSeeds(seedCss);
  const toneTable = parseToneTable(toneTableCss);
  const P = resolveRefPalette({ toneTable, seeds });
  const roles = resolveSysColorRoles(P);

  const light = {};
  const dark = {};
  for (const [name, { light: l, dark: d }] of Object.entries(roles)) {
    light[name] = l;
    dark[name] = d;
  }
  return { light, dark };
}

// -- deterministic fixture write --------------------------------------------

// sortedRoleMap(map) -> the same {role: hex} object, re-inserted in ordinal
// key order (src/lib/order.mjs's byKey) — insertion order above already
// happens to be stable (resolveSysColorRoles builds it in a fixed literal
// order), but sorting here makes the fixture's byte-stability independent of
// that incidental fact, matching this project's determinism ground rule.
function sortedRoleMap(map) {
  const sorted = {};
  for (const key of Object.keys(map).sort(byKey((k) => k))) {
    sorted[key] = map[key];
  }
  return sorted;
}

// buildFixture() -> the full checked-in fixture document: a provenance
// header (which package version + which script produced this, so a
// reviewer never has to reverse-engineer where these hex values came from)
// plus the resolved light/dark role maps.
export function buildFixture() {
  const seedCss = fs.readFileSync(path.join(VENDORED_DIR, "seed.css"), "utf8");
  const toneTableCss = fs.readFileSync(path.join(VENDORED_DIR, "ref", "_tone-table.css"), "utf8");
  const { light, dark } = resolveComputedPalette({ seedCss, toneTableCss });

  return {
    _provenance: {
      $comment:
        "Task D5 source #2 — tailwind-m3e-web's OKLCH-computed M3 color roles, " +
        "resolved by src/tokens/resolve-palette.mjs (NOT reimplementing the tone " +
        "calibration — that is read verbatim from the co-located package's " +
        "_tone-table.css; only the relative-color arithmetic in ref/palette.css + " +
        "sys/color.css is mirrored, gamut-mapped via culori's clampChroma per CSS " +
        "Color 4). Regenerate with: node src/tokens/resolve-palette.mjs --write",
      tailwindM3eWebVersion: TAILWIND_M3E_WEB_VERSION,
      vendoredFrom: "packages/tailwind-m3e-web/src/{seed.css,ref/_tone-table.css,ref/palette.css,sys/color.css}",
      resolver: "src/tokens/resolve-palette.mjs (resolveComputedPalette)",
      seeds: parseSeeds(seedCss),
      knownGap:
        "The 12 *-fixed*/*-fixed-dim*/on-*-fixed[-variant] Schemes roles have no " +
        "counterpart in sys/color.css and are absent from light/dark below " +
        "(see task-D2-report.md's independent finding of the same gap).",
    },
    light: sortedRoleMap(light),
    dark: sortedRoleMap(dark),
  };
}

// writeFixture() -> writes the deterministic fixture (2-space indent,
// trailing newline — this project's standard write discipline).
export function writeFixture() {
  const fixture = buildFixture();
  fs.writeFileSync(FIXTURE_PATH, `${JSON.stringify(fixture, null, 2)}\n`, "utf8");
  return fixture;
}

export { FIXTURE_PATH };

function main(argv) {
  if (argv.includes("--write")) {
    writeFixture();
    process.stdout.write(`resolve-palette.mjs: wrote ${FIXTURE_PATH}\n`);
    return;
  }
  if (argv.includes("--check")) {
    const fresh = `${JSON.stringify(buildFixture(), null, 2)}\n`;
    const existing = fs.existsSync(FIXTURE_PATH) ? fs.readFileSync(FIXTURE_PATH, "utf8") : null;
    if (existing !== fresh) {
      process.stderr.write(
        `resolve-palette.mjs --check: ${FIXTURE_PATH} is stale. Run \`node src/tokens/resolve-palette.mjs --write\`.\n`
      );
      process.exitCode = 1;
      return;
    }
    process.stdout.write(`resolve-palette.mjs --check: ${FIXTURE_PATH} is byte-stable.\n`);
    return;
  }
  process.stdout.write("Usage: node src/tokens/resolve-palette.mjs --write | --check\n");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
