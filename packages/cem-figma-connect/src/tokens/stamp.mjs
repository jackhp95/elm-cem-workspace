// Task D3: codeSyntax stamp/unstamp script generation (plans/plan/D-tokens.md
// Task D3; evidence #5 "ids re-mint across copies — anchor by NAME" + evidence
// #6, the proven Tailwind-leg mechanism demonstrated live 2026-07-10:
// `variable.setVariableCodeSyntax("WEB", "var(--md-sys-color-on-surface)")` via
// `use_figma` -> `get_design_context` immediately emits
// `var(--md-sys-color-on-surface,#1d1b20)` in generated layout code).
//
// This module GENERATES `use_figma` plugin-sandbox scripts from the checked-in
// token table (profiles/m3-kit/tokens.json, Task D2) — it never calls Figma
// itself. Applying a generated script to any real file is a per-file ⚑ HUMAN
// authorization (Task D7), executed later via the Figma MCP `use_figma` tool.
// See profiles/m3-kit/stamp/README.md for that runbook.
//
// SCOPE DECISION: only `status: "mapped"` rows are stamped. `status:
// "unmapped"` rows have no confidently-derived `--md-sys-*` name (D2's
// STATUS SEMANTICS) — stamping a guess would poison `get_design_context`
// output with a wrong vocabulary word, which is worse than leaving the
// variable unstamped (Figma falls back to its own slug, a visible "not yet
// wired" signal).
//
// PORTABILITY MANDATE (evidence #5): every generated script locates variables
// by NAME (`figma.variables.getLocalVariablesAsync()` + a name -> Variable
// map), never by the `figma` id baked into research/figma-dumps/kit-
// variables.json — that id is meaningless outside the exact file it was
// dumped from (duplicating the M3 kit re-mints every component/variable key;
// evidence #3). The token table's `figma` field (a name, e.g. "Schemes/On
// Surface") is the only portable anchor, which is exactly what the generated
// TARGETS array carries — grep any generated script for "VariableID:" (the
// dump's id prefix) and it will not be found; see stamp.test.mjs's assertion.
//
// IDEMPOTENCY: every generated script reads `v.codeSyntax.WEB` BEFORE writing
// and skips a variable already carrying the intended value — re-running the
// exact same script against a file that's already stamped (or a script
// covering an overlapping set) is a safe no-op, not a spurious "mutation".
//
// CHUNKING (Step 2): the figma-use skill's incremental-workflow rule ("work in
// small steps... keep scripts small enough to read errors") caps a single
// `use_figma` call at roughly 40 writes. Two of the three families exceed
// that (Schemes 49, Static 75 mapped rows) — this module's judgment call
// (documented, not silent, per the project's convention — see derive.mjs's
// STATUS SEMANTICS note for precedent): keep the brief's literal `NN-family
// .js` numbering (Schemes=01, Corner=02, Static=03, in that fixed order — NOT
// alphabetical; Corner would otherwise sort before Schemes) for a family's
// FIRST chunk, and any family whose mapped-row count exceeds MAX_CHUNK spills
// into `NN-family-2.js`, `NN-family-3.js`, ... sharing the same numeric
// prefix. Corner (10 rows) fits in one file and is unaffected; Schemes (49)
// and Static (75) each get exactly one continuation file at MAX_CHUNK=40:
// 01-schemes.js (40) + 01-schemes-2.js (9); 03-static.js (40) +
// 03-static-2.js (35).
//
// SNAPSHOT + INVERSE (Step 3): `00-snapshot.js` is a single READ-ONLY script
// (not chunked — it never mutates, so the incremental-writes rule doesn't
// apply) covering every mapped row's current `codeSyntax`, keyed by NAME (the
// same portability anchor) with the variable's current id carried along only
// as debugging metadata, never as a lookup key. A human runner executes it
// immediately before stamping and saves the returned JSON beside the run log
// (Step 5's runbook says exactly when). `unstamp/<same-filename>.js` mirrors
// every stamp script 1:1 and calls `removeVariableCodeSyntax("WEB")` — this
// restores the KNOWN pre-state, because the checked-in dump measures 0/304
// variables with any codeSyntax today (evidence #13): "restore to {}" and
// "restore to the recorded pre-state" are the same operation for this
// specific token table. If a target file already carried non-empty WEB
// codeSyntax before stamping (only possible on a file this tool didn't
// generate the pre-state from), the 00-snapshot.json capture is the
// authoritative record a human restores from instead — documented in the
// README, not automated (this generator has no way to know a future file's
// history offline).
//
// Zero new deps. Reuses ../lib/order.mjs (byKey) for determinism.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { byKey } from "../lib/order.mjs";
import { loadKitVariables } from "./ingest.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");

export const DEFAULT_PATHS = {
  tokensPath: path.join(repoRoot, "profiles", "m3-kit", "tokens.json"),
  variablesPath: path.join(repoRoot, "research", "figma-dumps", "kit-variables.json"),
  outDir: path.join(repoRoot, "profiles", "m3-kit", "stamp"),
};

// The fixed family grouping order Task D3's brief numbers scripts by —
// deliberately NOT alphabetical (Corner would otherwise precede Schemes).
export const FAMILY_ORDER = ["Schemes", "Corner", "Static"];

// figma-use skill's incremental-workflow ceiling (Section 6: "at most ~10
// logical operations... keep scripts small enough to read errors" applied
// here at the coarser per-variable-write grain the D3 brief specifies: "chunk
// <= ~40 variable writes per script").
export const MAX_CHUNK = 40;

const PLATFORM = "WEB";

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function familyOf(figmaName) {
  return figmaName.split("/")[0];
}

// -- row selection --------------------------------------------------------

// loadMappedRows(tokensPath) -> status:"mapped" rows from tokens.json, sorted
// ordinally by figma name (tokens.json is already sorted this way per
// derive.mjs's writeTokens, but re-sorting here keeps this module correct
// independent of that invariant).
export function loadMappedRows(tokensPath) {
  const rows = readJson(tokensPath);
  return rows.filter((r) => r.status === "mapped").sort(byKey((r) => r.figma));
}

// groupMappedRowsByFamily(rows) -> Map<family, rows[]> ordered per
// FAMILY_ORDER; families outside FAMILY_ORDER (none exist among "mapped" rows
// today — Schemes/Corner/Static are the only families D2 ever marks "mapped")
// are appended afterward, ordinally, so a future family isn't silently
// dropped if the token table's derivation rules ever grow.
export function groupMappedRowsByFamily(rows) {
  const byFamily = new Map();
  for (const row of rows) {
    const family = familyOf(row.figma);
    if (!byFamily.has(family)) byFamily.set(family, []);
    byFamily.get(family).push(row);
  }

  const ordered = new Map();
  for (const family of FAMILY_ORDER) {
    if (byFamily.has(family)) {
      ordered.set(family, byFamily.get(family));
      byFamily.delete(family);
    }
  }
  for (const family of [...byFamily.keys()].sort(byKey((f) => f))) {
    ordered.set(family, byFamily.get(family));
  }
  return ordered;
}

// chunkArray(items, size) -> items split into sequential chunks of at most
// `size`, preserving order. The last chunk carries the remainder (never
// re-balanced) — simplest deterministic rule, and the one the module doc's
// worked example (49 -> [40, 9]) describes.
export function chunkArray(items, size) {
  const chunks = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks.length > 0 ? chunks : [[]];
}

// codeSyntaxValue(row) -> the intended codeSyntax.WEB value for one mapped
// row: `var(<md>)`, exactly evidence #6's proven form.
export function codeSyntaxValue(row) {
  return `var(${row.md})`;
}

// familySlug(family) -> lowercase, space-stripped file-name fragment ("State
// Layers" -> "state-layers"; unused today since only Schemes/Corner/Static
// are ever "mapped", but kept general rather than special-cased to 3 names).
export function familySlug(family) {
  return family.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
}

// scriptFileName(familyIndex, family, chunkIndex) -> "NN-family.js" for the
// first chunk of a family, "NN-family-K.js" (K = chunkIndex+1, 1-based) for
// any continuation chunk. familyIndex is 1-based per FAMILY_ORDER position
// (Schemes=1 -> "01", Corner=2 -> "02", Static=3 -> "03", ...).
export function scriptFileName(familyIndex, family, chunkIndex) {
  const prefix = String(familyIndex).padStart(2, "0");
  const slug = familySlug(family);
  return chunkIndex === 0 ? `${prefix}-${slug}.js` : `${prefix}-${slug}-${chunkIndex + 1}.js`;
}

// -- script rendering -------------------------------------------------------

// buildTargets(rows) -> [{name, value}] — the ONLY per-variable data a
// generated script embeds. `name` is the Figma variable's `name` (the
// portable, by-name anchor); `value` is the intended codeSyntax.WEB string.
// Deliberately NEVER includes the dump's `figma` id — see the module-doc
// PORTABILITY MANDATE note.
export function buildTargets(rows) {
  return rows.map((row) => ({ name: row.figma, value: codeSyntaxValue(row) }));
}

function header(lines) {
  return lines.map((l) => `// ${l}`.replace(/\s+$/, "")).join("\n");
}

// renderStampScript({family, chunkIndex, chunkCount, targets}) -> the JS text
// of one `use_figma`-ready stamp script. Plain JavaScript, top-level
// `await`/`return` (per the figma-use skill's Critical Rule #1/#2 — the
// harness auto-wraps in an async context; wrapping in an IIFE here would be
// wrong). Locates by NAME, skips already-correct values (idempotent), returns
// {stamped, skipped, missing, mutatedVariableIds}.
export function renderStampScript({ family, chunkIndex, chunkCount, targets }) {
  const chunkNote = chunkCount > 1 ? ` (chunk ${chunkIndex + 1}/${chunkCount})` : "";
  const lines = [
    "AUTO-GENERATED by src/tokens/stamp.mjs from profiles/m3-kit/tokens.json — DO NOT EDIT BY HAND.",
    "Regenerate: node src/tokens/stamp.mjs --profile m3-kit --out profiles/m3-kit/stamp/",
    "",
    `${family}${chunkNote} — stamps ${targets.length} Figma variable(s)' codeSyntax.${PLATFORM}`,
    "with the canonical --md-sys-* custom property (evidence #6, the proven",
    "Tailwind-leg mechanism: get_design_context then emits var(--md-sys-*,<fallback>)",
    "in generated layout code for every stamped role).",
    "",
    "PORTABLE BY NAME (evidence #5): locates each variable via",
    "figma.variables.getLocalVariablesAsync() + a name match — never a baked-in",
    "variable id, which re-mints across file copies. Run this SAME script",
    "unmodified against the canonical copy, a throwaway Copy, or ADS.",
    "",
    "IDEMPOTENT: a variable whose codeSyntax.WEB already equals the intended",
    "value is skipped, not re-stamped.",
    "",
    "⚑ HUMAN: applying this script to a real file is a per-file authorization —",
    "see profiles/m3-kit/stamp/README.md before running this via use_figma.",
  ];

  return `${header(lines)}

const TARGETS = ${JSON.stringify(targets, null, 2)};

const byName = new Map();
for (const v of await figma.variables.getLocalVariablesAsync()) {
  byName.set(v.name, v);
}

const stamped = [];
const skipped = [];
const missing = [];
const mutatedVariableIds = [];

for (const target of TARGETS) {
  const v = byName.get(target.name);
  if (!v) {
    missing.push(target.name);
    continue;
  }
  const current = v.codeSyntax ? v.codeSyntax["${PLATFORM}"] : undefined;
  if (current === target.value) {
    skipped.push(target.name);
    continue;
  }
  v.setVariableCodeSyntax("${PLATFORM}", target.value);
  stamped.push(target.name);
  mutatedVariableIds.push(v.id);
}

return { stamped, skipped, missing, mutatedVariableIds };
`;
}

// renderUnstampScript({family, chunkIndex, chunkCount, targets}) -> the
// inverse of renderStampScript: restores codeSyntax.WEB to "{}" (removes the
// key) for any variable currently carrying exactly the value this generator
// would have stamped. Idempotent the same way: a variable that ISN'T
// currently stamped with our value is skipped (already restored, or never
// touched by us — never blindly clobbered).
export function renderUnstampScript({ family, chunkIndex, chunkCount, targets }) {
  const chunkNote = chunkCount > 1 ? ` (chunk ${chunkIndex + 1}/${chunkCount})` : "";
  const lines = [
    "AUTO-GENERATED by src/tokens/stamp.mjs from profiles/m3-kit/tokens.json — DO NOT EDIT BY HAND.",
    "Regenerate: node src/tokens/stamp.mjs --profile m3-kit --out profiles/m3-kit/stamp/",
    "",
    `INVERSE of stamp/${scriptFileName(FAMILY_ORDER.indexOf(family) + 1, family, chunkIndex)}.`,
    `${family}${chunkNote} — restores ${targets.length} Figma variable(s)' codeSyntax.${PLATFORM}`,
    "to \"{}\" (removeVariableCodeSyntax). The checked-in token-table dump measures",
    "0/304 variables with any codeSyntax today (evidence #13) — for this table,",
    "\"restore to {}\" and \"restore to the recorded pre-state\" are the same",
    "operation. If a target file's PRE-stamp state was ever non-empty, restore",
    "from the 00-snapshot.json captured before stamping instead (see README.md).",
    "",
    "PORTABLE BY NAME, IDEMPOTENT: same discipline as the stamp script — locates",
    "by name, and skips a variable whose codeSyntax.WEB does not currently equal",
    "the value we would have stamped (already restored, or never ours to touch).",
  ];

  return `${header(lines)}

const TARGETS = ${JSON.stringify(targets, null, 2)};

const byName = new Map();
for (const v of await figma.variables.getLocalVariablesAsync()) {
  byName.set(v.name, v);
}

const unstamped = [];
const skipped = [];
const missing = [];
const mutatedVariableIds = [];

for (const target of TARGETS) {
  const v = byName.get(target.name);
  if (!v) {
    missing.push(target.name);
    continue;
  }
  const current = v.codeSyntax ? v.codeSyntax["${PLATFORM}"] : undefined;
  if (current !== target.value) {
    skipped.push(target.name);
    continue;
  }
  v.removeVariableCodeSyntax("${PLATFORM}");
  unstamped.push(target.name);
  mutatedVariableIds.push(v.id);
}

return { unstamped, skipped, missing, mutatedVariableIds };
`;
}

// renderSnapshotScript(allTargets) -> "00-snapshot.js": a single READ-ONLY
// script (never chunked — it mutates nothing, so the incremental-writes rule
// doesn't apply) returning the CURRENT codeSyntax for every mapped-row
// variable, keyed by NAME. `id` rides along as debugging metadata only — it
// is never used as a lookup key (see PORTABILITY MANDATE).
export function renderSnapshotScript(allTargets) {
  const names = allTargets.map((t) => t.name);
  const lines = [
    "AUTO-GENERATED by src/tokens/stamp.mjs from profiles/m3-kit/tokens.json — DO NOT EDIT BY HAND.",
    "Regenerate: node src/tokens/stamp.mjs --profile m3-kit --out profiles/m3-kit/stamp/",
    "",
    `READ-ONLY pre-stamp snapshot for all ${names.length} mapped token-table rows`,
    "(Schemes + Corner + Static). Run this BEFORE any of the stamp/ scripts and",
    "save the returned JSON beside the run log — it is the authoritative",
    "pre-state an unstamp pass restores from if a target file's codeSyntax was",
    "ever non-empty before stamping (see README.md).",
    "",
    "PORTABLE BY NAME: keyed by variable name, not id (ids re-mint across file",
    "copies, evidence #5) — `id` is carried per-entry only as debugging",
    "metadata, never as a lookup key.",
  ];

  return `${header(lines)}

const TARGET_NAMES = ${JSON.stringify(names, null, 2)};

const byName = new Map();
for (const v of await figma.variables.getLocalVariablesAsync()) {
  byName.set(v.name, v);
}

const snapshot = {};
const missing = [];

for (const name of TARGET_NAMES) {
  const v = byName.get(name);
  if (!v) {
    missing.push(name);
    continue;
  }
  snapshot[name] = { id: v.id, codeSyntax: v.codeSyntax ?? {} };
}

return { snapshot, missing };
`;
}

// -- plan assembly (pure, testable) ------------------------------------------

// buildStampPlan(mappedRows) -> { snapshot: {targets}, scripts: [{fileName,
// family, chunkIndex, chunkCount, targets}] } — the full deterministic plan
// for a set of mapped rows, independent of any filesystem I/O. Both
// generateStampFiles() and the --dry-run path build on this.
export function buildStampPlan(mappedRows, { maxChunk = MAX_CHUNK } = {}) {
  const byFamily = groupMappedRowsByFamily(mappedRows);
  const scripts = [];

  let familyIndex = 0;
  for (const [family, rows] of byFamily) {
    familyIndex += 1;
    const chunks = chunkArray(rows, maxChunk);
    chunks.forEach((chunkRows, chunkIndex) => {
      scripts.push({
        fileName: scriptFileName(familyIndex, family, chunkIndex),
        family,
        chunkIndex,
        chunkCount: chunks.length,
        targets: buildTargets(chunkRows),
      });
    });
  }

  const snapshotTargets = scripts.flatMap((s) => s.targets);
  return { snapshotTargets, scripts };
}

// -- file generation ----------------------------------------------------------

// generateStampFiles({tokensPath, outDir}) -> writes 00-snapshot.js, every
// NN-family[-K].js stamp script, and unstamp/NN-family[-K].js mirrors.
// Byte-stable: re-running against the same tokens.json produces identical
// bytes (no timestamps, no non-deterministic ordering). Never touches any
// OTHER file already in outDir (e.g. README.md) — only ever (re)writes the
// specific generated filenames it owns.
export function generateStampFiles({ tokensPath = DEFAULT_PATHS.tokensPath, outDir = DEFAULT_PATHS.outDir } = {}) {
  const mappedRows = loadMappedRows(tokensPath);
  const plan = buildStampPlan(mappedRows);

  const unstampDir = path.join(outDir, "unstamp");
  fs.mkdirSync(outDir, { recursive: true });
  fs.mkdirSync(unstampDir, { recursive: true });

  const written = [];

  const snapshotPath = path.join(outDir, "00-snapshot.js");
  fs.writeFileSync(snapshotPath, renderSnapshotScript(plan.snapshotTargets), "utf8");
  written.push(snapshotPath);

  for (const script of plan.scripts) {
    const stampPath = path.join(outDir, script.fileName);
    fs.writeFileSync(stampPath, renderStampScript(script), "utf8");
    written.push(stampPath);

    const unstampPath = path.join(unstampDir, script.fileName);
    fs.writeFileSync(unstampPath, renderUnstampScript(script), "utf8");
    written.push(unstampPath);
  }

  return { mappedRows, plan, written };
}

// -- dry-run: delta table from the checked-in dump, no Figma call -----------

// dryRunDelta({tokensPath, variablesPath}) -> [{figma, current, intended}] for
// every mapped row, sorted per buildStampPlan's script order (family-grouped,
// then ordinal within family) — the SAME order the generated scripts stamp
// in, so this delta table doubles as a preview of exactly what 01/02/03 will
// do. `current` reads codeSyntax.WEB straight from the checked-in
// research/figma-dumps/kit-variables.json dump (evidence #13 measures 0/304
// populated there) — NEVER a live Figma call.
export function dryRunDelta({ tokensPath = DEFAULT_PATHS.tokensPath, variablesPath = DEFAULT_PATHS.variablesPath } = {}) {
  const mappedRows = loadMappedRows(tokensPath);
  const { variables } = loadKitVariables(variablesPath);
  const codeSyntaxByName = new Map(variables.map((v) => [v.name, v.codeSyntax]));

  const plan = buildStampPlan(mappedRows);
  const rowsInPlanOrder = plan.scripts.flatMap((s) => s.targets);

  return rowsInPlanOrder.map((target) => {
    const codeSyntax = codeSyntaxByName.get(target.name);
    const current = codeSyntax && codeSyntax[PLATFORM] !== undefined ? codeSyntax[PLATFORM] : null;
    return { figma: target.name, current, intended: target.value };
  });
}

// renderDeltaTable(delta) -> a plain-text table for stdout ("variable ->
// current -> intended"), one row per mapped variable.
export function renderDeltaTable(delta) {
  const lines = delta.map((d) => `${d.figma}\n  current:  ${d.current === null ? "(none)" : d.current}\n  intended: ${d.intended}`);
  return lines.join("\n");
}

// -- CLI ------------------------------------------------------------------

function parseArgs(argv) {
  const opts = { profile: undefined, out: undefined, dryRun: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--profile") {
      opts.profile = argv[++i];
    } else if (arg === "--out") {
      opts.out = argv[++i];
    } else if (arg === "--dry-run") {
      opts.dryRun = true;
    }
  }
  return opts;
}

function main(argv) {
  const opts = parseArgs(argv);
  const profile = opts.profile ?? "m3-kit";
  const tokensPath = path.join(repoRoot, "profiles", profile, "tokens.json");
  const outDir = opts.out ? path.resolve(opts.out) : path.join(repoRoot, "profiles", profile, "stamp");

  if (opts.dryRun) {
    const delta = dryRunDelta({ tokensPath });
    process.stdout.write(`stamp.mjs --dry-run: ${delta.length} mapped row(s) from ${tokensPath}\n\n`);
    process.stdout.write(`${renderDeltaTable(delta)}\n`);
    return;
  }

  const { mappedRows, plan, written } = generateStampFiles({ tokensPath, outDir });
  process.stdout.write(
    `stamp.mjs: wrote ${written.length} script(s) to ${outDir} (${plan.scripts.length} stamp + ${plan.scripts.length} unstamp + 1 snapshot) from ${mappedRows.length} mapped row(s).\n`
  );
  for (const script of plan.scripts) {
    process.stdout.write(`  ${script.fileName}: ${script.targets.length} variable(s) (${script.family})\n`);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
