// Task D2: the token correspondence table (plans/01-architecture.md §1 "token
// authority" + §5 "no Tailwind label"; plans/plan/D-tokens.md Task D2;
// evidence #4/#6/#13). Consumes D1's normalized ingest (src/tokens/ingest.mjs
// — `variables[]`, the `{id, name, family, collection, type,
// valuesByModeName, aliasOf?, codeSyntax}` shape) and derives one row per
// Figma variable:
//
//   { figma, md, tailwind: {theme, utils}|null, m3eFallback, provenance,
//     status, note }
//
// Task D6 addendum (family coverage closure): `status` has a third value,
// `"policy"`, alongside `"mapped"`/`"unmapped"` — a human decision (always
// `provenance:"human"`, arriving only via tokens-overrides.json) that a row
// deliberately has NO code-side correspondence to derive (e.g. State
// Layers/* — a Figma-only painting convenience; see
// profiles/m3-kit/README.md's "Token family coverage" table for the full
// per-family rationale). `buildRow` below never emits `"policy"` itself —
// only `mergeTokenRows`, by honoring a human override row, can produce one.
// See `checkCoverage` (bottom of this file) for the D6 Step 4 coverage
// assertion this third status makes possible: `mapped`, `policy`, or
// `unmapped`-with-a-note are all acceptable; `unmapped` with no note is a
// silent gap and fails `--check`.
//
// Zero new deps. Reuses ../lib/order.mjs (byKey) for determinism, and the
// same "never overwrite a human row" merge discipline src/correspond/
// merge.mjs (mergeCorrespondence) and src/correspond/review.mjs
// (upsertOverride) established for correspondence.json — reimplemented here
// keyed by `figma` instead of `cemTag` since tokens.json's primary key is the
// Figma variable name, not a CEM tag.
//
// SCOPE DECISION (documented, not silent): this module derives rows for
// `variables` only (Schemes/State Layers/Static/Corner/Tracking/Add-ons —
// the 304 measured in D1). D1's `styles` (30 TEXT styles, family
// "style:text") are OUT OF SCOPE for D2 — the brief's Step 1-4 derivation
// rules are written entirely in terms of variable families and their counts
// sum to exactly 304 (49+147+95+10+2+1), never mentioning text styles. The
// row-shape comment's "(or style: prefix)" anticipates a future task
// extending this table to styles; that extension is not built here. See
// task-D2-report.md "self-review" for the full rationale.
//
// STATUS SEMANTICS (a documented judgment call — the brief's own wording
// creates a tension, resolved here and written up in the report):
//   - Step 2 says a missing tailwind join is a REAL FINDING, "status:
//     unmapped, not an error".
//   - The Verify section separately hard-asserts "Schemes coverage = 49/49
//     rows mapped".
//   - MEASURED: 12 of the 49 Schemes/* color roles (the "*-fixed*" family —
//     Primary Fixed, Primary Fixed Dim, On Primary Fixed, On Primary Fixed
//     Variant, and the Secondary/Tertiary equivalents) have NO @theme join in
//     tailwind-m3e-web/src/theme.css (verified: no "fixed" anywhere in that
//     repo's src/, and no git history of one ever existing). Demoting those
//     12 rows to "unmapped" would make Schemes coverage 37/49, contradicting
//     the Verify line item.
//   - Resolution: `status` tracks confidence in the FIGMA -> MD
//     correspondence (this row's core job), not whether the tailwind/m3e
//     legs additionally resolve. Schemes and Corner derive mechanically with
//     zero ambiguity (kebab-case, 1:1, no semantic transform) — all 49+10 are
//     "mapped" regardless of tailwind join; a missing join is recorded via
//     `tailwind: null` + a `note`, never by demoting status. Static's
//     derivation, by contrast, involves a real semantic transform per prop
//     (Size -> font-size, Weight-emphasized -> a PREFIX reorder onto
//     "emphasized-<scale>-font-weight", Font -> no code-side axis at all) —
//     there confidence is verified by checking the derived name's actual
//     membership in typescale.css (the code-side naming source of truth per
//     the brief), and a Static row that doesn't verify there (which, as
//     measured, is exactly the same set that doesn't tailwind-join) IS
//     demoted to "unmapped", matching the brief's literal Step 4 example
//     ("any Static/* slug that didn't join").

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadKitVariables } from "./ingest.mjs";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");

export const DEFAULT_PATHS = {
  variablesPath: path.join(repoRoot, "research", "figma-dumps", "kit-variables.json"),
  themeCssPath: path.join(repoRoot, "..", "tailwind-m3e-web", "src", "theme.css"),
  typescaleCssPath: path.join(repoRoot, "..", "tailwind-m3e-web", "src", "sys", "typescale.css"),
  customElementsPath: path.join(repoRoot, "test", "fixtures", "m3e-web-2.5.14", "dist", "custom-elements.json"),
  tokensPath: path.join(repoRoot, "profiles", "m3-kit", "tokens.json"),
  overridesPath: path.join(repoRoot, "profiles", "m3-kit", "tokens-overrides.json"),
};

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function readJson(filePath) {
  return JSON.parse(readText(filePath));
}

// -- naming -------------------------------------------------------------

// kebab(segment) -> lowercase, non-alnum runs collapsed to one "-", no
// leading/trailing "-". Deliberately ordinal/ASCII-only (no localeCompare
// concerns here — this transforms one string, doesn't sort), matching the
// project's determinism ground rule in spirit even though this particular
// helper isn't a comparator.
export function kebab(segment) {
  return segment
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

// The 15 real M3 typescale scales (Display/Headline/Title/Body/Label x
// Large/Medium/Small) — used to distinguish a genuine per-scale Static
// variable (Static/Body Large/Size) from the 5 standalone constants
// (Static/Font/Brand, Static/Font/Plain, Static/Weight/Bold,
// Static/Weight/Medium, Static/Weight/Regular) whose 2nd segment ("Font",
// "Weight") is not a scale at all.
const TYPESCALE_ROLES = ["display", "headline", "title", "body", "label"];
const TYPESCALE_SIZES = ["large", "medium", "small"];
const KNOWN_SCALE_SLUGS = new Set(
  TYPESCALE_ROLES.flatMap((role) => TYPESCALE_SIZES.map((size) => `${role}-${size}`))
);

// Static/<Scale>/<Prop> -> axis word used inside the real
// --md-sys-typescale-<scale>-<axis> name, per typescale.css (measured
// 2026-07-11: FONT_SIZE -> font-size, FONT_STYLE(weight) -> font-weight,
// LINE_HEIGHT -> line-height, LETTER_SPACING(tracking) -> tracking). This is
// NOT trusted blindly — deriveStaticMd's output is re-verified against a
// live-parsed typescale.css token set below (parseTypescaleNames), so a
// future rename here would correctly demote to unmapped rather than silently
// keep asserting a stale mapping.
const STATIC_PROP_TO_AXIS = {
  Size: "font-size",
  Weight: "font-weight",
  "Line Height": "line-height",
  Tracking: "tracking",
};

// deriveStaticMd(scale, prop) -> candidate --md-sys-typescale-* name.
// "Weight-emphasized" is the one case that is NOT a simple
// <scale>-<axis> suffix: the real naming puts "emphasized" as a PREFIX on
// the whole scale ("--md-sys-typescale-emphasized-body-large-font-weight"),
// not a suffix on the prop — this is exactly the "slug spelling" the brief
// says to verify against typescale.css rather than assume mechanically.
function deriveStaticMd(scaleSlug, prop) {
  if (prop === "Weight-emphasized") {
    return `--md-sys-typescale-emphasized-${scaleSlug}-font-weight`;
  }
  const axis = STATIC_PROP_TO_AXIS[prop];
  if (axis) return `--md-sys-typescale-${scaleSlug}-${axis}`;
  // Anything else (the scale-level "Font" family prop, or an unanticipated
  // future prop): fall back to the brief's literal mechanical rule. Kept
  // honest rather than silently special-cased — the typescale.css
  // membership check below is what actually decides confidence.
  return `--md-sys-typescale-${scaleSlug}-${kebab(prop)}`;
}

// deriveMdName(variable) -> { md: string|null, confident: boolean, note?: string }
//
// Step 1 (mechanical derivation) for the 3 families the brief gives a rule
// for (Schemes, Corner, Static). Everything else (State Layers, Tracking,
// Add-ons) has NO derivation rule in the brief — Step 4 defers the whole
// family to human review rather than asking us to guess a naming scheme we
// have no source of truth for (see task-D2-report.md's "State Layers"
// finding: the code side collapses all 49 color roles into 3 GENERIC
// opacity tokens, --md-sys-state-{focus,hover,pressed}-state-layer-opacity —
// there is no per-role state-layer token to name at all, so no "confident"
// derivation exists to attempt).
export function deriveMdName(variable) {
  const segs = variable.name.split("/");

  if (variable.family === "Schemes") {
    return { md: `--md-sys-color-${kebab(segs[1])}`, confident: true };
  }

  if (variable.family === "Corner") {
    return { md: `--md-sys-shape-corner-${kebab(segs[1])}`, confident: true };
  }

  if (variable.family === "Static") {
    const scaleSlug = kebab(segs[1]);
    const prop = segs[2];
    if (KNOWN_SCALE_SLUGS.has(scaleSlug)) {
      return { md: deriveStaticMd(scaleSlug, prop) };
    }
    // Static/Font/* and Static/Weight/* — standalone typeface/weight
    // constants, not per-scale axes. No known code-side counterpart.
    return {
      md: `--md-sys-typescale-${scaleSlug}-${kebab(prop)}`,
      note: `"${variable.name}" is a standalone constant (2nd segment "${segs[1]}" is not a typescale scale), not a per-scale typescale axis`,
    };
  }

  return {
    md: null,
    confident: false,
    note: `no Step-1 derivation rule for family "${variable.family}" — deferred to human review (Step 4)`,
  };
}

// -- typescale.css: the code-side naming source of truth for Static -------

const TYPESCALE_TOKEN_RE = /(--md-sys-typescale-[a-z0-9-]+):/g;

// parseTypescaleNames(css) -> Set<mdName> of every --md-sys-typescale-*
// token actually DEFINED in typescale.css (the source of truth, per the
// brief, for Static/* slug spelling).
export function parseTypescaleNames(css) {
  const names = new Set();
  let m;
  while ((m = TYPESCALE_TOKEN_RE.exec(css))) names.add(m[1]);
  return names;
}

// -- theme.css @theme block: the tailwind join -----------------------------

// Matches one `--<tw-key>: var(--md-*);` declaration line. Tailwind v4
// "modifier" keys look like `--text-display-lg--line-height` — the `--XXX`
// suffix after the base key names a bundled modifier of that base utility,
// not a separate utility of its own (see theme.css's header comment).
const THEME_DECL_RE = /^\s*(--[a-zA-Z0-9-]+):\s*var\((--md-[a-zA-Z0-9-]+)\)\s*;?\s*$/;
const MODIFIER_RE = /^(--text-[a-z0-9-]+)--(line-height|letter-spacing|font-weight)$/;

// parseThemeJoins(css) -> Map<mdName, {twKey, base, modifier}>
// One entry per `--md-*` name referenced in the @theme block. Determinism
// doesn't depend on Map iteration order here — every consumer looks up by
// key, never iterates this map into an ordered artifact.
export function parseThemeJoins(css) {
  const joins = new Map();
  for (const line of css.split("\n")) {
    const m = THEME_DECL_RE.exec(line);
    if (!m) continue;
    const [, twKey, mdName] = m;
    const modMatch = MODIFIER_RE.exec(twKey);
    joins.set(mdName, {
      twKey,
      base: modMatch ? modMatch[1] : twKey,
      modifier: modMatch ? modMatch[2] : null,
    });
  }
  return joins;
}

// Representative-utility generators, one per @theme namespace this table
// actually reaches (Schemes -> color, Corner -> radius; Static's typescale
// vars join under "text" via their base key). Matches theme.css's own header
// comment 1:1 ("--color-primary -> bg-primary, text-primary, border-primary,
// ring-primary"; "--radius-md-corner-medium -> rounded-md-corner-medium").
const NAMESPACE_UTILS = {
  color: (slug) => [`bg-${slug}`, `text-${slug}`, `border-${slug}`, `ring-${slug}`],
  text: (slug) => [`text-${slug}`],
  radius: (slug) => [`rounded-${slug}`],
};

function namespaceOf(base) {
  for (const ns of Object.keys(NAMESPACE_UTILS)) {
    if (base.startsWith(`--${ns}-`)) return ns;
  }
  return null;
}

// tailwindFieldFor(join) -> {theme, utils}|null
function tailwindFieldFor(join) {
  if (!join) return null;
  const ns = namespaceOf(join.base);
  if (!ns) return { theme: join.base, utils: [] };
  const slug = join.base.slice(`--${ns}-`.length);
  const utils = NAMESPACE_UTILS[ns](slug);
  return { theme: join.base, utils };
}

// -- @m3e/web fallback join -------------------------------------------------

const FALLBACK_RE = /var\((--md-sys-[a-zA-Z0-9-]+),\s*([^)]*)\)/g;

// parseFallbacks(customElementsJson) -> Map<mdName, fallbackValue>
// First occurrence wins. MEASURED (2026-07-11): 190 distinct --md-sys-* names
// carry a fallback in the m3e-web-2.5.14 custom-elements.json fixture, 0 of
// which have divergent fallback values across occurrences (verified by
// scanning every occurrence, not just the first) — so "first occurrence
// wins" never actually discards a differing value in the measured fixture.
export function parseFallbacks(customElementsJsonText) {
  const map = new Map();
  let m;
  while ((m = FALLBACK_RE.exec(customElementsJsonText))) {
    const [, name, rawVal] = m;
    const val = rawVal.trim();
    if (!map.has(name)) map.set(name, val);
  }
  return map;
}

// -- row assembly ------------------------------------------------------------

// buildRow(variable, ctx) -> one tokens.json row, provenance:"auto".
// ctx: { themeJoins, fallbacks, typescaleNames }
export function buildRow(variable, ctx) {
  const { themeJoins, fallbacks, typescaleNames } = ctx;
  const figma = variable.name;
  const derived = deriveMdName(variable);
  const md = derived.md;

  let confident = derived.confident !== false;
  const notes = [];
  if (derived.note) notes.push(derived.note);

  // Static's confidence gate: re-verify the derived name against
  // typescale.css's REAL token set (the naming source of truth per the
  // brief), rather than trusting deriveStaticMd's table blindly.
  if (md && variable.family === "Static" && confident) {
    if (!typescaleNames.has(md)) {
      confident = false;
      notes.push(`derived name "${md}" is not a real token in typescale.css — not confidently mapped`);
    }
  }

  const join = md ? themeJoins.get(md) : undefined;
  const tailwind = join ? tailwindFieldFor(join) : null;
  if (md && !join) {
    notes.push(`no @theme join in tailwind-m3e-web/src/theme.css for ${md}`);
  }

  const m3eFallback = md ? (fallbacks.get(md) ?? null) : null;

  // status: see the module-doc "STATUS SEMANTICS" note for the full
  // rationale (Schemes/Corner: confident derivation always "mapped",
  // independent of tailwind join; Static: additionally gated on the
  // typescale.css-verified confidence check, which — as measured — lines up
  // exactly with the tailwind join outcome; deferred families: always
  // "unmapped", no md guessed).
  let status;
  if (!md || !confident) {
    status = "unmapped";
  } else if (variable.family === "Static" && !tailwind) {
    status = "unmapped";
  } else {
    status = "mapped";
  }

  return {
    figma,
    md: md ?? null,
    tailwind,
    m3eFallback,
    provenance: "auto",
    status,
    note: notes.join("; "),
  };
}

// -- human-preserving merge ---------------------------------------------------
// Reuses src/correspond/merge.mjs's discipline (never overwrite a
// provenance:"human" row) keyed by `figma` instead of `cemTag`, since
// tokens.json's primary key is the Figma variable name.

function isProtected(row) {
  return row.provenance === "human";
}

// mergeTokenRows(overrideRows, proposedRows) -> rows[], sorted by figma.
//   - A figma key with a human override: the override ALWAYS wins, verbatim,
//     never touched by a fresh proposal (even if the proposal's substantive
//     fields differ) — this is the hard guarantee the brief asks for ("the
//     deriver never overwrites a human row").
//   - A figma key with no override: the fresh auto proposal is used as-is.
//   - An override for a figma key the current proposal no longer produces
//     (e.g. a variable renamed/removed upstream): kept as-is — deletion is a
//     human action, never an automatic side effect of re-deriving.
export function mergeTokenRows(overrideRows, proposedRows) {
  const overrideByFigma = new Map(overrideRows.map((r) => [r.figma, r]));
  const proposedByFigma = new Map(proposedRows.map((r) => [r.figma, r]));
  const keys = new Set([...overrideByFigma.keys(), ...proposedByFigma.keys()]);

  const merged = [];
  for (const key of keys) {
    const override = overrideByFigma.get(key);
    const proposed = proposedByFigma.get(key);

    if (override && isProtected(override)) {
      merged.push(override);
    } else if (override) {
      // An override row present but not provenance:"human" isn't actually
      // protected — this shouldn't normally occur (tokens-overrides.json is
      // a human-authored file), but if it does, a fresh proposal still wins.
      merged.push(proposed ?? override);
    } else {
      merged.push(proposed);
    }
  }

  merged.sort(byKey((r) => r.figma));
  return merged;
}

// -- overrides.json I/O -------------------------------------------------------

// readTokenOverrides(path) -> rows[] ([] if the file doesn't exist yet, or is
// the empty-array scaffold — no overrides recorded is a normal state).
export function readTokenOverrides(overridesPath) {
  if (!fs.existsSync(overridesPath)) return [];
  return readJson(overridesPath);
}

// -- top-level derivation ------------------------------------------------------

// deriveTokenRows(paths) -> rows[], sorted by figma, merged with whatever
// human rows already exist in tokens-overrides.json.
export function deriveTokenRows(paths = {}) {
  const p = { ...DEFAULT_PATHS, ...paths };

  const { variables } = loadKitVariables(p.variablesPath);
  const themeCss = readText(p.themeCssPath);
  const typescaleCss = readText(p.typescaleCssPath);
  const customElementsText = readText(p.customElementsPath);

  const themeJoins = parseThemeJoins(themeCss);
  const typescaleNames = parseTypescaleNames(typescaleCss);
  const fallbacks = parseFallbacks(customElementsText);

  const ctx = { themeJoins, fallbacks, typescaleNames };
  const proposed = variables.map((v) => buildRow(v, ctx));

  const overrides = readTokenOverrides(p.overridesPath);
  return mergeTokenRows(overrides, proposed);
}

// reviewRows(rows) -> unmapped rows, grouped by Figma family (first "/"
// segment) — a query helper over the same rows tokens.json already carries;
// not a separate artifact (the brief's Step 4 deliverables list doesn't ask
// for one; status+note on each row already IS the "review section").
export function reviewRows(rows) {
  const unmapped = rows.filter((r) => r.status === "unmapped");
  const byFamily = new Map();
  for (const row of unmapped) {
    const family = row.figma.split("/")[0];
    if (!byFamily.has(family)) byFamily.set(family, []);
    byFamily.get(family).push(row);
  }
  return { unmapped, byFamily };
}

// -- Task D6: family coverage closure — the coverage assertion ---------------
//
// Three valid statuses now exist: "mapped" (a real, verified code-side
// correspondence — the only status buildRow ever emits on its own),
// "policy" (a human override recording a deliberate "not a gap" decision —
// buildRow never emits this; it only ever arrives via a provenance:"human"
// row in tokens-overrides.json), and "unmapped" (buildRow's default when no
// confident derivation exists AND no human override has resolved it yet).
//
// The brief's hard rule (Task D6 Step 4): "zero silent gaps" — every row
// must be `mapped`, `policy`, or (if truly undecidable) `unmapped` WITH a
// note that documents the open question. A "bare" unmapped row — no note at
// all — is the one shape this assertion exists to catch: a row nobody has
// looked at yet, silently sitting there as neither mapped nor an explicit
// policy call.
//
// checkCoverage(rows) -> { ok: boolean, bare: rows[] }
export function checkCoverage(rows) {
  const bare = rows.filter((r) => r.status === "unmapped" && (!r.note || r.note.trim() === ""));
  return { ok: bare.length === 0, bare };
}

// familyStatusCounts(rows) -> Map<family, {mapped, policy, unmapped}> — the
// data behind the README's coverage table, computed straight from the rows
// so the table can never silently drift from what's actually checked in.
export function familyStatusCounts(rows) {
  const counts = new Map();
  for (const row of rows) {
    const family = row.figma.split("/")[0];
    if (!counts.has(family)) counts.set(family, { mapped: 0, policy: 0, unmapped: 0 });
    const entry = counts.get(family);
    entry[row.status] = (entry[row.status] ?? 0) + 1;
  }
  return counts;
}

// -- deterministic write -------------------------------------------------------

// writeTokens(tokensPath, rows) -> sorted rows, byte-stable JSON (2-space
// indent, trailing newline) — same write discipline as
// src/correspond/merge.mjs's writeCorrespondence.
export function writeTokens(tokensPath, rows) {
  const sorted = [...rows].sort(byKey((r) => r.figma));
  fs.mkdirSync(path.dirname(tokensPath), { recursive: true });
  fs.writeFileSync(tokensPath, `${JSON.stringify(sorted, null, 2)}\n`, "utf8");
  return sorted;
}

// -- CLI ------------------------------------------------------------------

function main(argv) {
  const check = argv.includes("--check");
  const rows = deriveTokenRows();

  if (check) {
    const existing = fs.existsSync(DEFAULT_PATHS.tokensPath) ? readText(DEFAULT_PATHS.tokensPath) : null;
    const fresh = `${JSON.stringify([...rows].sort(byKey((r) => r.figma)), null, 2)}\n`;
    if (existing !== fresh) {
      process.stderr.write(
        `derive.mjs --check: ${DEFAULT_PATHS.tokensPath} is stale (regenerating it differs from what's checked in). Run \`node src/tokens/derive.mjs\` to refresh it.\n`
      );
      process.exitCode = 1;
      return;
    }

    // Task D6 Step 4: the coverage assertion — fails on any row that is
    // `unmapped` with no note explaining why (a silent gap). This is checked
    // over the freshly-derived rows (not re-read from disk), same as the
    // byte-stability check above, so it's exercising exactly what's about to
    // be (or already is) committed.
    const { ok, bare } = checkCoverage(rows);
    if (!ok) {
      process.stderr.write(
        `derive.mjs --check: coverage assertion FAILED — ${bare.length} row(s) are 'unmapped' with no note ` +
          `(a silent gap). Every unmapped row must carry a note explaining why, or be resolved to 'mapped'/'policy'.\n`
      );
      for (const row of bare) process.stderr.write(`  bare unmapped: ${row.figma}\n`);
      process.exitCode = 1;
      return;
    }

    process.stdout.write(
      `derive.mjs --check: ${DEFAULT_PATHS.tokensPath} is byte-stable and coverage is complete ` +
        `(0 bare unmapped rows).\n`
    );
    return;
  }

  const written = writeTokens(DEFAULT_PATHS.tokensPath, rows);
  const counts = familyStatusCounts(written);
  const mappedCount = written.filter((r) => r.status === "mapped").length;
  const policyCount = written.filter((r) => r.status === "policy").length;
  const unmappedCount = written.filter((r) => r.status === "unmapped").length;
  process.stdout.write(
    `derive.mjs: wrote ${written.length} rows to ${DEFAULT_PATHS.tokensPath} ` +
      `(${mappedCount} mapped, ${policyCount} policy, ${unmappedCount} unmapped-for-review).\n`
  );
  for (const [family, c] of [...counts.entries()].sort(byKey(([f]) => f))) {
    process.stdout.write(`  ${family}: mapped=${c.mapped} policy=${c.policy} unmapped=${c.unmapped}\n`);
  }
  const { ok, bare } = checkCoverage(written);
  if (!ok) {
    process.stdout.write(`  WARNING: ${bare.length} bare unmapped row(s) (no note) — run --check to fail CI on this.\n`);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
