// Phase 4 (L6): the "required code change" DELTA CLASSIFIER.
//
// Answers, for any design delta (a before→after change to the token inputs):
// can re-theming absorb this, or does it force an emitter/API/code change —
// and where? Grounded in the plan's core insight (§4.3):
//
//   A delta is RE-THEME-ABSORBABLE iff applying it changes only leaf *values*
//   of existing ref/sys nodes, leaving the name/alias GRAPH byte-identical AND
//   every covered EMITTER OUTPUT byte-identical after regeneration. Anything
//   that changes a name, an alias edge, or any emitter output is a
//   REQUIRED-CODE-CHANGE — and the diff itself names the output/file to change.
//
// This is a TIER-ATTRIBUTING WRAPPER over the same regenerate-and-diff idea as
// Phase 0's drift gate — not a second engine. It compares two axes:
//   (A) the token-graph names + edges (structural — reuses graph.mjs builders)
//   (B) each COVERED EMITTER OUTPUT, byte-for-byte (reuses the REAL emitters)
//
// ─────────────────────────────────────────────────────────────────────────
// CRITICAL CORRECTNESS INVARIANT (the plan's main design risk, §8):
//   The re-theme-vs-code verdict is only as trustworthy as the SET of outputs
//   diffed. If a real emitter output is missing from the covered set, a
//   code-forcing delta gets MISLABELED "retheme". So the covered-output set is
//   EXPLICIT (COVERED_OUTPUTS below) and GATED: `coveredInputFiles()` +
//   classify-delta.test.mjs assert that EVERY token INPUT source is observed by
//   at least one covered output or the graph axis, and that COVERED_OUTPUTS
//   names the Elm token surface + Code Connect bindings + Tailwind @theme keys
//   + utilities.css. A future output added to the drift gate but forgotten here
//   fails that test.
// ─────────────────────────────────────────────────────────────────────────
//
// Detector mode: POST-HOC only (Decision 4) — regenerate/derive-and-diff. The
// pre-flight classifier (L9, reasoning about a proposed delta from the graph
// alone, no regen) is deferred.
//
// Zero new deps (plain Node ESM).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  buildSeedNodes,
  buildRefNodes,
  buildSystemNodes,
  buildComponentNodes,
  buildSeedRefEdges,
  buildRefSysEdges,
} from "./graph.mjs";
import { parseThemeJoins, deriveTokenRows } from "./derive.mjs";
import {
  extractCssProperties,
  emitUtilities,
  emitDoc,
} from "../../../tailwind-m3e-web/bin/generate-component-utilities.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");
const twSrc = path.join(repoRoot, "..", "tailwind-m3e-web", "src");

export const DEFAULT_PATHS = {
  seedCssPath: path.join(twSrc, "seed.css"),
  paletteCssPath: path.join(twSrc, "ref", "palette.css"),
  sysDir: path.join(twSrc, "sys"),
  themeCssPath: path.join(twSrc, "theme.css"),
  cemFactsPath: path.join(repoRoot, "profiles", "m3-kit", "facts", "cem-facts.json"),
};

// A "source snapshot" is the full set of token INPUTS the classifier reads:
//   { seedCss, paletteCss, sysCssByFile:{file:css}, themeCss, cemFacts, tokenRows }
// readBaseSources() loads the committed state; fixtures clone + mutate it.
export function readBaseSources(paths = {}) {
  const p = { ...DEFAULT_PATHS, ...paths };
  const sysCssByFile = {};
  for (const file of fs.readdirSync(p.sysDir).sort()) {
    if (file.endsWith(".css")) sysCssByFile[file] = fs.readFileSync(path.join(p.sysDir, file), "utf8");
  }
  return {
    seedCss: fs.readFileSync(p.seedCssPath, "utf8"),
    paletteCss: fs.readFileSync(p.paletteCssPath, "utf8"),
    sysCssByFile,
    themeCss: fs.readFileSync(p.themeCssPath, "utf8"),
    cemFacts: JSON.parse(fs.readFileSync(p.cemFactsPath, "utf8")),
    // tokenRows is heavier (reads figma dumps); derived once. A theme.css delta
    // is caught primarily by the @theme covered output below; tokenRows is the
    // Code Connect / Elm token-surface projection.
    tokenRows: deriveTokenRows(),
  };
}

// -- (B) COVERED EMITTER OUTPUTS — the explicit, gated set -------------------
//
// Each descriptor computes a canonical, deterministic string for a snapshot,
// reusing the REAL emitter where one exists. `inputs` names the token input
// files this output derives from (used by the gated completeness assertion).

function canonicalThemeKeys(themeCss) {
  // The Tailwind @theme --tw→--md join keys (from theme.css). Sorted, stable.
  const joins = parseThemeJoins(themeCss);
  const rows = [...joins.entries()].map(([md, j]) => [md, j.twKey]).sort((a, b) => (a[0] < b[0] ? -1 : 1));
  return JSON.stringify(rows, null, 0);
}

function canonicalTokenSurface(tokenRows) {
  // The Figma↔code token correspondence the Code Connect bindings + the Elm
  // token wrappers (M3e.Values/M3e.Attributes) derive from — projected to the
  // fields that force a code change (name/tier/tailwind join), sorted.
  const rows = [...tokenRows]
    .map((r) => ({ figma: r.figma, md: r.md, tier: r.tier, tailwind: r.tailwind ?? null }))
    .sort((a, b) => (a.figma < b.figma ? -1 : a.figma > b.figma ? 1 : 0));
  return JSON.stringify(rows, null, 0);
}

export const COVERED_OUTPUTS = [
  {
    key: "tailwind-m3e-web/generated/utilities.css",
    owner: "tailwind-m3e-web",
    surface: "utilities.css",
    tier: "component",
    inputs: ["cem-facts.json:cssProperties"],
    extract: (s) => emitUtilities(extractCssProperties(s.cemFacts).flatUnique),
  },
  {
    key: "tailwind-m3e-web/generated/CSS_CUSTOM_PROPERTIES.md",
    owner: "tailwind-m3e-web",
    surface: "component CSS-var reference doc",
    tier: "component",
    inputs: ["cem-facts.json:cssProperties"],
    extract: (s) => {
      const { byComponent, flatUnique } = extractCssProperties(s.cemFacts);
      return emitDoc(byComponent, flatUnique);
    },
  },
  {
    key: "tailwind-m3e-web/src/theme.css (@theme keys)",
    owner: "tailwind-m3e-web",
    surface: "Tailwind @theme keys",
    tier: "system",
    inputs: ["theme.css"],
    extract: (s) => canonicalThemeKeys(s.themeCss),
  },
  {
    key: "cem-figma-connect/tokens.json (Code Connect + Elm token surface)",
    owner: "cem-figma-connect",
    surface: "Elm token surface + Code Connect bindings",
    tier: "system",
    inputs: ["theme.css", "figma-dumps", "typescale.css"],
    extract: (s) => canonicalTokenSurface(s.tokenRows),
  },
];

// -- (A) token-graph structural signature ------------------------------------

export function graphSignature(s) {
  const nodes = [
    ...buildSeedNodes(s.seedCss),
    ...buildRefNodes(s.paletteCss),
    ...buildSystemNodes(s.sysCssByFile),
    ...buildComponentNodes(s.cemFacts),
  ];
  const nodeTierByName = new Map(nodes.map((n) => [n.name, n.tier]));
  const nodeNames = [...nodeTierByName.keys()].sort();

  const colorCss = s.sysCssByFile["color.css"] ?? "";
  const edges = [...buildSeedRefEdges(s.paletteCss), ...buildRefSysEdges(colorCss).edges]
    .map((e) => `${e.from} ${e.kind} ${e.to}`)
    .sort();

  return { nodeNames, edges, nodeTierByName };
}

// -- source-file attribution -------------------------------------------------

// changedInputFiles(before, after) -> the token input files whose content
// differs — the honest "where the delta lands" attribution.
export function changedInputFiles(before, after) {
  const changed = [];
  if (before.seedCss !== after.seedCss) changed.push("tailwind-m3e-web/src/seed.css");
  if (before.paletteCss !== after.paletteCss) changed.push("tailwind-m3e-web/src/ref/palette.css");
  for (const file of new Set([...Object.keys(before.sysCssByFile), ...Object.keys(after.sysCssByFile)])) {
    if ((before.sysCssByFile[file] ?? null) !== (after.sysCssByFile[file] ?? null)) {
      changed.push(`tailwind-m3e-web/src/sys/${file}`);
    }
  }
  if (before.themeCss !== after.themeCss) changed.push("tailwind-m3e-web/src/theme.css");
  if (JSON.stringify(before.cemFacts) !== JSON.stringify(after.cemFacts)) {
    changed.push("cem-facts.json (@m3e/web CEM cssProperties)");
  }
  return changed.sort();
}

// -- tier + reason classification --------------------------------------------

const TIER_RANK = { seed: 0, reference: 1, system: 2, component: 3 };

function tierOfNames(names, tierByNameBefore, tierByNameAfter) {
  let best = null;
  for (const name of names) {
    const tier =
      tierByNameAfter.get(name) ??
      tierByNameBefore.get(name) ??
      (name.startsWith("--m3e-") ? "component"
        : name.startsWith("--md-sys-") ? "system"
        : name.startsWith("--md-ref-") ? "reference"
        : name.startsWith("--md-seed-") ? "seed"
        : null);
    if (tier && (best === null || TIER_RANK[tier] > TIER_RANK[best])) best = tier;
  }
  return best;
}

// classifyReason -> one of: new-name | renamed | alias-repoint | structural |
// no-token. (no-token — a Figma concept with no CSS var, e.g. layout spacing —
// is in the taxonomy but not reachable from a CSS/CEM source delta; it is the
// spacing case, surfaced elsewhere.)
function classifyReason({ added, removed, edgesChanged, outputs }) {
  if (added.length && removed.length) return "renamed";
  if (added.length) return "new-name";
  if (edgesChanged) return "alias-repoint";
  if (outputs.length) return "structural";
  return "structural";
}

/**
 * classifyDelta(before, after) -> a tier-attributed verdict.
 *
 * @returns {{
 *   kind: "retheme" | "required-code-change",
 *   tier: string|null,
 *   outputs: {key, owner, surface, tier}[],   // covered emitter outputs that differ
 *   files: string[],                          // input files that changed (attribution)
 *   reason: string,
 *   detail: string,
 * }}
 */
export function classifyDelta(before, after) {
  // (B) covered emitter-output diff.
  const outputs = [];
  for (const out of COVERED_OUTPUTS) {
    let a;
    let b;
    try {
      a = out.extract(before);
      b = out.extract(after);
    } catch (e) {
      throw new Error(`covered output "${out.key}" failed to extract: ${e.message}`);
    }
    if (a !== b) outputs.push({ key: out.key, owner: out.owner, surface: out.surface, tier: out.tier });
  }

  // (A) graph structural diff.
  const gB = graphSignature(before);
  const gA = graphSignature(after);
  const beforeNames = new Set(gB.nodeNames);
  const afterNames = new Set(gA.nodeNames);
  const added = gA.nodeNames.filter((n) => !beforeNames.has(n));
  const removed = gB.nodeNames.filter((n) => !afterNames.has(n));
  const nodesChanged = added.length > 0 || removed.length > 0;
  const edgesChanged = JSON.stringify(gB.edges) !== JSON.stringify(gA.edges);
  const graphChanged = nodesChanged || edgesChanged;

  const files = changedInputFiles(before, after);

  if (!graphChanged && outputs.length === 0) {
    return {
      kind: "retheme",
      tier: seedTierForFiles(files),
      outputs: [],
      files,
      reason: "value-only",
      detail:
        "no name/alias-edge change and no covered emitter-output change — a seed/leaf-value re-theme, absorbed without regenerating any code.",
    };
  }

  // The names/edges that moved — for tier attribution.
  const affected = new Set([...added, ...removed]);
  if (edgesChanged) {
    for (const line of [...gB.edges, ...gA.edges]) {
      // "from kind to" — attribute both endpoints (a sys role repoint touches
      // its sys node and the ref node it now/previously pointed at).
      const [from, , to] = line.split(" ");
      affected.add(from);
      affected.add(to);
    }
  }
  const reason = classifyReason({ added, removed, edgesChanged, outputs });
  const tier =
    tierOfNames(affected, gB.nodeTierByName, gA.nodeTierByName) ??
    (outputs.length ? highestTier(outputs.map((o) => o.tier)) : seedTierForFiles(files));

  return {
    kind: "required-code-change",
    tier,
    outputs,
    files,
    reason,
    detail: reasonDetail(reason, { added, removed, outputs, files }),
  };
}

function highestTier(tiers) {
  let best = null;
  for (const t of tiers) if (best === null || TIER_RANK[t] > TIER_RANK[best]) best = t;
  return best;
}

function seedTierForFiles(files) {
  if (files.some((f) => f.endsWith("seed.css"))) return "seed";
  if (files.some((f) => f.includes("palette.css"))) return "reference";
  if (files.some((f) => f.includes("/sys/"))) return "system";
  return "reference";
}

function reasonDetail(reason, { added, removed, outputs, files }) {
  switch (reason) {
    case "new-name":
      return `new token name(s): ${added.slice(0, 5).join(", ")}${added.length > 5 ? ` (+${added.length - 5})` : ""} — regenerate: ${outputs.map((o) => o.surface).join(", ") || "(names only)"}.`;
    case "renamed":
      return `renamed token(s): -[${removed.slice(0, 3).join(", ")}] +[${added.slice(0, 3).join(", ")}] — the correspondence overlay + emitter outputs must follow.`;
    case "alias-repoint":
      return `an alias edge repointed in ${files.join(", ")} — a derivation code change (not a consumer re-theme).`;
    case "structural":
      return `a covered emitter output changed without a graph name/edge change (${outputs.map((o) => o.surface).join(", ")}) — a binding/emitter change.`;
    default:
      return "";
  }
}

// -- gated completeness surface ----------------------------------------------

// coveredInputFiles() -> the set of token INPUT files observed by the covered
// outputs (B) plus the graph axis (A). The completeness test asserts EVERY
// real token input is in this set — the invariant that keeps a code-forcing
// delta from being mislabeled a re-theme.
export function coveredInputFiles() {
  const fromOutputs = new Set();
  for (const out of COVERED_OUTPUTS) for (const i of out.inputs) fromOutputs.add(i);
  // The graph axis observes the structural sources directly:
  const fromGraph = new Set([
    "seed.css",
    "ref/palette.css",
    "sys/*.css",
    "cem-facts.json:cssProperties",
  ]);
  return { fromOutputs: [...fromOutputs].sort(), fromGraph: [...fromGraph].sort() };
}

// -- CLI (report a demo delta against the committed base) --------------------

function main() {
  const base = readBaseSources();
  const verdict = classifyDelta(base, base); // identity delta → retheme(value-only), sanity
  process.stdout.write(
    `classify-delta.mjs: covered outputs = ${COVERED_OUTPUTS.length} ` +
      `(${COVERED_OUTPUTS.map((o) => o.surface).join("; ")}). ` +
      `identity-delta verdict = ${verdict.kind}.\n`,
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
