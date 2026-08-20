// gen-style-tokens.mjs — derive the `/styles/*` token tables from the REAL
// `--md-sys-*` design-token manifest (the hand-authored CSS custom properties in
// the elm-m3e-tailwind brand package) instead of hand-typed copies in the Elm
// route modules. Emits `data/style-tokens.json`, read at build time by
// `Route.Styles.Typography`, `Route.Styles.Shape`, and `Route.Styles.Color`.
//
// WHY THIS EXISTS
//   `Route.Styles.Typography` carried the 15 type-scale roles' font-size /
//   line-height / weight as literal strings; `Route.Styles.Shape` carried the 10
//   corner-radius rem values as literals. Both were hand-copied from
//   `sys/typescale.css` / `sys/shape.css` with a "do not edit here without
//   editing the token" comment — i.e. a manual mirror that can silently drift
//   from the token when the scale changes. This derives them, so the page cannot
//   disagree with the tokens the components actually render with.
//
//   `Route.Styles.Color` references M3 color ROLES by their Tailwind utility name
//   (`bg-primary`, `text-on-surface`); the swatch color is resolved from
//   `--md-sys-color-*` by the browser, not copied here. The risk there is a
//   referenced role being renamed/removed at the source. So for color this script
//   emits the curated accent + surface lists mechanically AND validates every
//   role they name against the full `--md-sys-color-*` inventory parsed from
//   `sys/color.css` — a vanished role fails the build instead of shipping a dead
//   utility. (The page's curation is intentionally NOT exhaustive; the full
//   inventory is emitted as `colorRoleInventory` for anyone extending it.)
//
// PRECONDITION: deterministic (pure function of the committed CSS). Gated by
//   scripts/check-data-drift.mjs.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
// The brand's hand-authored token manifest, a sibling package of the docs.
const SYS = path.resolve(here, "..", "..", "..", "style", "elm-m3e-tailwind", "src", "sys");
const OUT = path.resolve(here, "../data/style-tokens.json");

const readCss = (name) => fs.readFileSync(path.resolve(SYS, `${name}.css`), "utf8");

/** All `--<prefix><name>: <value>;` declarations in a CSS string, as a Map. */
function customProps(css, prefix) {
  const map = new Map();
  // Values can span lines (color.css); capture up to the terminating `;`.
  const re = new RegExp(`--${prefix}([a-z0-9-]+)\\s*:\\s*([^;]+);`, "gi");
  let m;
  while ((m = re.exec(css)) !== null) map.set(m[1], m[2].trim().replace(/\s+/g, " "));
  return map;
}

const fail = (msg) => {
  console.error(`gen-style-tokens: ${msg}`);
  process.exit(1);
};

// ── Typography ──────────────────────────────────────────────────────────────
// The 15 standard M3 type-scale roles, in the page's display->label order. Each
// role's metrics string is `font-size / line-height · font-weight`, read from
// `--md-sys-typescale-<role>-<axis>`. The Tailwind class is `text-<family>-<sz>`.
const TS = customProps(readCss("typescale"), "md-sys-typescale-");
const SZ_ABBR = { large: "lg", medium: "md", small: "sm" };
const typography = [];
for (const family of ["display", "headline", "title", "body", "label"]) {
  for (const size of ["large", "medium", "small"]) {
    const role = `${family}-${size}`;
    const fontSize = TS.get(`${role}-font-size`);
    const lineHeight = TS.get(`${role}-line-height`);
    const weight = TS.get(`${role}-font-weight`);
    if (!fontSize || !lineHeight || !weight) {
      fail(`typescale role "${role}" is missing font-size/line-height/font-weight in sys/typescale.css`);
    }
    typography.push({
      class: `text-${family}-${SZ_ABBR[size]}`,
      metrics: `${fontSize} / ${lineHeight} · ${weight}`,
    });
  }
}

// ── Shape: corner-radius scale ───────────────────────────────────────────────
// The 10 canonical corner sizes, in the page's none->full order. Value is the
// `--md-sys-shape-corner-value-<size>` token literal (`corner-full` for the pill,
// which has no `-value-` twin). The utility is `rounded-md-corner-<size>`; the
// label is the size with dashes->spaces and only its first word capitalised
// ("extra-large-increased" -> "Extra large increased").
const SHAPE = customProps(readCss("shape"), "md-sys-shape-");
const titleize = (s) => {
  const words = s.replace(/-/g, " ");
  return words.charAt(0).toUpperCase() + words.slice(1);
};
const CORNER_SIZES = [
  "none",
  "extra-small",
  "small",
  "medium",
  "large",
  "large-increased",
  "extra-large",
  "extra-large-increased",
  "extra-extra-large",
  "full",
];
const shapeCorners = CORNER_SIZES.map((size) => {
  const value = SHAPE.get(`corner-value-${size}`) ?? SHAPE.get(`corner-${size}`);
  if (value === undefined) fail(`shape corner "${size}" not found in sys/shape.css`);
  return { utility: `rounded-md-corner-${size}`, label: titleize(size), value };
});

// ── Color: role inventory + curated accent/surface lists ─────────────────────
const COLOR = customProps(readCss("color"), "md-sys-color-");
const colorRoleInventory = [...COLOR.keys()].sort();
const has = (role) => COLOR.has(role);
const need = (role, ctx) => {
  if (!has(role)) fail(`color role "--md-sys-color-${role}" referenced by ${ctx} is absent from sys/color.css`);
  return role;
};

// Accent families: each contributes a bold role + its container, both with a
// paired on-* color. Derived by rule from the four canonical accent seeds, every
// role validated against the manifest.
const colorAccents = ["primary", "secondary", "tertiary", "error"].map((seed) => {
  need(seed, "accents");
  need(`on-${seed}`, "accents");
  need(`${seed}-container`, "accents");
  need(`on-${seed}-container`, "accents");
  return {
    name: titleize(seed),
    base: `bg-${seed} text-on-${seed}`,
    baseBg: `bg-${seed}`,
    container: `bg-${seed}-container text-on-${seed}-container`,
    containerBg: `bg-${seed}-container`,
  };
});

// Surface roles: the page's curated neutral-surface selection (NOT the full
// ladder — the exhaustive set is `colorRoleInventory`). Each is [label, bg-role,
// on-role]; both roles validated against the manifest.
const SURFACE_SELECTION = [
  ["Surface", "surface", "on-surface"],
  ["Surface Container", "surface-container", "on-surface"],
  ["Surface Container High", "surface-container-high", "on-surface"],
  ["Inverse Surface", "inverse-surface", "inverse-on-surface"],
];
const colorSurfaces = SURFACE_SELECTION.map(([label, bgRole, onRole]) => {
  need(bgRole, "surfaces");
  need(onRole, "surfaces");
  return { label, bg: `bg-${bgRole}`, role: `bg-${bgRole} text-${onRole}` };
});

const out = { typography, shapeCorners, colorAccents, colorSurfaces, colorRoleInventory };
fs.writeFileSync(OUT, JSON.stringify(out, null, 2) + "\n");
console.log(
  `gen-style-tokens: wrote ${typography.length} type roles, ${shapeCorners.length} corners, ` +
    `${colorAccents.length} accents, ${colorSurfaces.length} surfaces (${colorRoleInventory.length} color roles) ` +
    `to ${path.relative(process.cwd(), OUT)}`
);
