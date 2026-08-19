// Phase 4 (L1/L3/L4/L5): the TOKEN GRAPH — a derived, byte-stable facts
// artifact that models the three Material token tiers (reference `--md-ref-*`,
// system `--md-sys-*`, component `--m3e-*`) plus the seed layer, AS DATA.
//
// Per the Phase 4 plan (planning/2026-08-17-phase4-token-hardening-plan.md §4.1)
// and "deep seams only": this is a SEPARATE seam from tokens.json (the Figma
// overlay). tokens.json keeps its job (Figma↔code correspondence, system tier
// only); the token graph is the general tier model every tier reasoner (the
// L6 delta classifier, the L7 report) consumes.
//
// EVERYTHING here is MEASURED, never authored:
//   - seed nodes      ← tailwind-m3e-web/src/seed.css               (--md-seed-*)
//   - reference nodes ← tailwind-m3e-web/src/ref/palette.css        (--md-ref-palette-*)
//   - system nodes    ← tailwind-m3e-web/src/sys/*.css              (--md-sys-*)
//   - component nodes ← this profile's cem-facts.json cssProperties (--m3e-*)
//   - seed→ref edges  ← palette.css `oklch(from var(--md-seed-…))`   (L3)
//   - ref→sys edges   ← sys/color.css `var(--md-ref-palette-…)`      (L3, transitive
//                       through the non-namespaced convenience aliases)
//
// COMPONENT TIER IS EDGE-LESS (Decision 2b): the sys→comp fallback edges live
// in @m3e/web's dist CSS (`var(--m3e-…, var(--md-sys-…))`), NOT in the CEM —
// so component nodes are leaves in v1. The detector (L6) still catches new/
// renamed component vars via the regenerate-and-diff drift gate; it just can't
// yet trace a sys re-theme *into* a specific component var. See `NOTES` below.
//
// DENSITY (L5) is a first-class system family: the `--md-sys-density-scale`
// node carries a MEASURED `domain` ([0,-1,-2,-3], parsed from density.css's
// scope utilities) and `baseUnit` (parsed from sys/density.css), replacing the
// prose generalization the density docs used to carry. Per-component `minScale`
// (which components clamp at -1 vs -3) is Decision 5(a): NOT modeled in v1 (it
// lives in @m3e/web dist DensityToken; a documented-but-unmodeled note).
//
// Byte-stable: `graph.mjs --check` regenerates and byte-compares against the
// committed token-graph.json (the workspace determinism ground rule). All
// ordering is ordinal (../lib/order.mjs), never localeCompare.
//
// Zero new deps (plain Node ESM).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");
const twSrc = path.join(repoRoot, "..", "..", "brands", "m3e", "outputs", "tailwind-m3e-web", "src");

export const DEFAULT_PATHS = {
  seedCssPath: path.join(twSrc, "seed.css"),
  paletteCssPath: path.join(twSrc, "ref", "palette.css"),
  sysDir: path.join(twSrc, "sys"),
  densityScopeCssPath: path.join(twSrc, "density.css"),
  cemFactsPath: path.join(repoRoot, "profiles", "m3-kit", "facts", "cem-facts.json"),
  graphPath: path.join(repoRoot, "profiles", "m3-kit", "token-graph.json"),
};

// Fixed tier order — the sort rank so the emitted node list is deterministic
// regardless of which source file was parsed first.
const TIER_RANK = { seed: 0, reference: 1, system: 2, component: 3 };

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}
function readJson(filePath) {
  return JSON.parse(readText(filePath));
}

// -- CSS parsing helpers -----------------------------------------------------

// A custom-property DECLARATION is `--name:` where the `--` begins a property
// name (start of line, or after whitespace / `;` / `{`). A var REFERENCE is
// `var(--name)` — the `--` is preceded by `(` and is never followed by a
// colon — so this regex cleanly captures declarations only, never references.
const DECL_RE = /(?:^|[\s;{])(--[a-zA-Z0-9-]+)\s*:/gm;

// parseDeclarations(css) -> string[] of declared custom-property names, in
// source order, deduped (a name declared twice — e.g. once per scheme — is one
// node).
export function parseDeclarations(css) {
  const seen = new Set();
  const out = [];
  let m;
  DECL_RE.lastIndex = 0;
  while ((m = DECL_RE.exec(css))) {
    if (!seen.has(m[1])) {
      seen.add(m[1]);
      out.push(m[1]);
    }
  }
  return out;
}

// A var reference: `var(--name` (optionally with whitespace after the paren).
const VAR_REF_RE = /var\(\s*(--[a-zA-Z0-9-]+)/g;

// parseVarRefs(text) -> string[] of referenced custom-property names, in
// source order, WITH duplicates preserved (callers dedupe as needed).
export function parseVarRefs(text) {
  const out = [];
  let m;
  VAR_REF_RE.lastIndex = 0;
  while ((m = VAR_REF_RE.exec(text))) out.push(m[1]);
  return out;
}

// -- node construction -------------------------------------------------------

// buildSeedNodes(seedCss) -> [{name, tier:"seed", family:"seed"}]
export function buildSeedNodes(seedCss) {
  return parseDeclarations(seedCss)
    .filter((n) => n.startsWith("--md-seed-"))
    .map((name) => ({ name, tier: "seed", family: "seed" }));
}

// refFamilyOf("--md-ref-palette-neutral-variant-10") -> "neutral-variant"
// (the palette name, with the trailing `-<tone>` stripped).
function refFamilyOf(name) {
  const body = name.slice("--md-ref-palette-".length);
  const m = body.match(/^(.*)-\d+$/);
  return m ? m[1] : body;
}

// buildRefNodes(paletteCss) -> reference-tier nodes, one per
// --md-ref-palette-<family>-<tone> declaration.
export function buildRefNodes(paletteCss) {
  return parseDeclarations(paletteCss)
    .filter((n) => n.startsWith("--md-ref-palette-"))
    .map((name) => ({ name, tier: "reference", family: refFamilyOf(name) }));
}

// sysFamilyOf("--md-sys-color-primary") -> "color"
// sysFamilyOf("--md-sys-density-scale") -> "density"
function sysFamilyOf(name) {
  return name.slice("--md-sys-".length).split("-")[0];
}

// buildSystemNodes(sysCssByFile) -> system-tier nodes, one per --md-sys-*
// declaration across every sys/*.css file. `sysCssByFile` is {fileName: css};
// files are read in ordinal filename order so re-runs are stable.
export function buildSystemNodes(sysCssByFile) {
  const seen = new Set();
  const nodes = [];
  for (const file of Object.keys(sysCssByFile).sort((a, b) => (a < b ? -1 : a > b ? 1 : 0))) {
    for (const name of parseDeclarations(sysCssByFile[file])) {
      if (!name.startsWith("--md-sys-")) continue;
      if (seen.has(name)) continue;
      seen.add(name);
      nodes.push({ name, tier: "system", family: sysFamilyOf(name) });
    }
  }
  return nodes;
}

// buildComponentNodes(cemFacts) -> component-tier nodes, one per unique
// --m3e-* cssProperty name, each carrying the sorted list of component tags
// that declare it. (264 of the 2251 names are shared across >1 component —
// e.g. --m3e-list-divider-inset-start-size, declared by action-list / list /
// selection-list — so `components` is an array, honestly reflecting the CEM.)
//
// The 96 unique --md-sys-* names that ALSO appear in cssProperties are a
// component READING a system token, not a component-tier token — they are
// system-tier nodes (measured: all 96 are already declared in tailwind's
// sys/*.css, 0 gap) and are excluded here.
export function buildComponentNodes(cemFacts) {
  const owners = new Map(); // name -> Set<tag>
  for (const comp of cemFacts.components ?? []) {
    for (const prop of comp.cssProperties ?? []) {
      if (!prop.name.startsWith("--m3e-")) continue;
      if (!owners.has(prop.name)) owners.set(prop.name, new Set());
      owners.get(prop.name).add(comp.tag);
    }
  }
  return [...owners.entries()].map(([name, tags]) => ({
    name,
    tier: "component",
    components: [...tags].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)),
  }));
}

// -- edges (L3): seed→ref (derivesFrom) + ref→sys (aliases) ------------------

// A palette declaration `--md-ref-palette-primary-40: oklch(from
// var(--md-seed-primary) …)` derives from the seed it references. Each ref
// node gets a `derivesFrom` edge to the seed var in its own declaration.
//
// buildSeedRefEdges(paletteCss, refNodeNames) -> edges[]
export function buildSeedRefEdges(paletteCss) {
  const edges = [];
  // Re-scan declarations WITH their right-hand side so we can attribute the
  // seed reference to the specific ref token being declared.
  for (const { name, rhs } of splitDeclarations(paletteCss)) {
    if (!name.startsWith("--md-ref-palette-")) continue;
    const seedRefs = [...new Set(parseVarRefs(rhs).filter((r) => r.startsWith("--md-seed-")))];
    for (const to of seedRefs) edges.push({ from: name, to, kind: "derivesFrom" });
  }
  return edges;
}

// A sys color role `--md-sys-color-primary: light-dark(var(--md-ref-palette-
// primary-40), …)` ALIASES the ref tokens it references. Some roles reference
// a non-namespaced convenience alias first (`--md-sys-color-on-surface:
// var(--on-surface)`, and `--on-surface: light-dark(var(--md-ref-palette-
// neutral-10), …)`) — we resolve transitively THROUGH those convenience
// aliases until we reach `--md-ref-palette-*` tokens, so on-surface correctly
// edges to neutral-10/90.
//
// A role whose declaration resolves to NO ref token (e.g. `--md-sys-color-
// shadow: var(--shadow)` and `--shadow: #000000`) gets a `documentedLiteral`
// flag instead of an edge — an honest "this system token is a literal, not a
// ref alias", never a silently-missing edge.
//
// buildRefSysEdges(colorCss) -> { edges, literals: string[] }
export function buildRefSysEdges(colorCss) {
  const decls = splitDeclarations(colorCss);
  const rhsByName = new Map(decls.map((d) => [d.name, d.rhs]));

  // resolveToRefs(startRhs) -> Set of terminal --md-ref-palette-* names,
  // following non-ref/non-seed convenience aliases transitively.
  const resolveToRefs = (startRhs) => {
    const refs = new Set();
    const stack = [startRhs];
    const guardedSeen = new Set();
    while (stack.length) {
      const rhs = stack.pop();
      for (const ref of parseVarRefs(rhs)) {
        if (ref.startsWith("--md-ref-palette-")) {
          refs.add(ref);
        } else if (rhsByName.has(ref) && !guardedSeen.has(ref)) {
          // a convenience alias declared in this same file — recurse into it
          guardedSeen.add(ref);
          stack.push(rhsByName.get(ref));
        }
        // else: a seed ref, or an undeclared ref — not a ref-palette edge
      }
    }
    return refs;
  };

  const edges = [];
  const literals = [];
  for (const { name, rhs } of decls) {
    if (!name.startsWith("--md-sys-color-")) continue;
    const refs = [...resolveToRefs(rhs)].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
    if (refs.length === 0) {
      literals.push(name);
    } else {
      for (const to of refs) edges.push({ from: name, to, kind: "aliases" });
    }
  }
  return { edges, literals };
}

// splitDeclarations(css) -> [{name, rhs}] — each custom-property declaration
// with its right-hand side (up to the matching `;` at brace depth 0 relative
// to the value). A robust-enough split for these hand-written token files:
// it tracks paren depth so a `;`-free `light-dark(a, b)` spanning lines is one
// declaration, and stops the value at the first top-level `;`.
export function splitDeclarations(css) {
  const out = [];
  const re = /(?:^|[\s;{])(--[a-zA-Z0-9-]+)\s*:/gm;
  let m;
  while ((m = re.exec(css))) {
    const name = m[1];
    let i = re.lastIndex;
    let depth = 0;
    let rhs = "";
    while (i < css.length) {
      const ch = css[i];
      if (ch === "(") depth++;
      else if (ch === ")") depth--;
      else if (ch === ";" && depth === 0) break;
      rhs += ch;
      i++;
    }
    out.push({ name, rhs: rhs.trim() });
  }
  return out;
}

// -- density (L5): measured domain + base unit -------------------------------

// measureDensity(scopeCss, sysDensityCss) -> {domain:number[], baseUnit:string}
// domain: the density SCALE values, parsed from density.css's scope utilities
//   (@utility density-N { --md-sys-density-scale: V }) — measured, not the
//   prose "[0,-1,-2,-3]".
// baseUnit: --md-sys-density-size's value from sys/density.css.
export function measureDensity(scopeCss, sysDensityCss) {
  // Strip CSS comments first: both density files mention these tokens in their
  // prose headers (e.g. "--md-sys-density-size:  0.25rem → base spatial unit"),
  // which would otherwise pollute the measured value.
  const stripComments = (css) => css.replace(/\/\*[\s\S]*?\*\//g, "");
  const scope = stripComments(scopeCss);
  const sysDensity = stripComments(sysDensityCss);

  const domain = [];
  const re = /--md-sys-density-scale:\s*(-?\d+)\s*;/g;
  let m;
  while ((m = re.exec(scope))) domain.push(Number(m[1]));
  const uniqueSorted = [...new Set(domain)].sort((a, b) => b - a); // 0, -1, -2, -3

  const sizeMatch = sysDensity.match(/--md-sys-density-size:\s*([^;]+);/);
  const baseUnit = sizeMatch ? sizeMatch[1].trim() : null;
  return { domain: uniqueSorted, baseUnit };
}

// -- graph assembly ----------------------------------------------------------

// Documented v1 model boundaries (Decisions 2b + 5a). Carried in the artifact
// so a consumer never has to read this source to learn what the graph does and
// doesn't yet model.
const NOTES = [
  "Component tier is edge-less in v1 (Decision 2b): the sys→comp fallback edges live in @m3e/web dist CSS (var(--m3e-*, var(--md-sys-*))), not in the CEM. Component nodes are leaves; the L6 detector still catches new/renamed component vars via the regenerate-and-diff drift gate.",
  "Per-component density minScale is not modeled in v1 (Decision 5a): the clamp lives in @m3e/web dist DensityToken. The density family carries the uniform measured domain + base unit only.",
];

export function buildGraph(paths = {}) {
  const p = { ...DEFAULT_PATHS, ...paths };

  const seedCss = readText(p.seedCssPath);
  const paletteCss = readText(p.paletteCssPath);
  const sysCssByFile = {};
  for (const file of fs.readdirSync(p.sysDir).sort()) {
    if (file.endsWith(".css")) sysCssByFile[file] = readText(path.join(p.sysDir, file));
  }
  const colorCss = sysCssByFile["color.css"] ?? "";
  const densityScopeCss = readText(p.densityScopeCssPath);
  const sysDensityCss = sysCssByFile["density.css"] ?? "";
  const cemFacts = readJson(p.cemFactsPath);

  const seedNodes = buildSeedNodes(seedCss);
  const refNodes = buildRefNodes(paletteCss);
  const systemNodes = buildSystemNodes(sysCssByFile);
  const componentNodes = buildComponentNodes(cemFacts);

  // L5: density is a first-class system family. Enrich the density-scale node
  // with the MEASURED domain ([0,-1,-2,-3], parsed from density.css's scope
  // utilities) + base unit (from sys/density.css) — replacing the density
  // docs' prose generalization. Per-component minScale stays unmodeled (5a).
  const density = measureDensity(densityScopeCss, sysDensityCss);
  for (const node of systemNodes) {
    if (node.name === "--md-sys-density-scale") {
      node.domain = density.domain;
      node.baseUnit = density.baseUnit;
    }
  }

  const nodes = [...seedNodes, ...refNodes, ...systemNodes, ...componentNodes].sort(
    (a, b) => TIER_RANK[a.tier] - TIER_RANK[b.tier] || (a.name < b.name ? -1 : a.name > b.name ? 1 : 0),
  );

  // L3 edges: seed→ref (derivesFrom) from palette.css, ref→sys (aliases) from
  // sys/color.css (resolved transitively through the non-namespaced
  // convenience aliases). Component tier stays edge-less (L4, Decision 2b).
  const seedRefEdges = buildSeedRefEdges(paletteCss);
  const { edges: refSysEdges, literals } = buildRefSysEdges(colorCss);
  const edges = [...seedRefEdges, ...refSysEdges].sort(byKey((e) => `${e.from} ${e.to} ${e.kind}`));

  const componentTags = new Set();
  for (const n of componentNodes) for (const t of n.components) componentTags.add(t);

  return {
    profile: "m3-kit",
    tiers: {
      seed: seedNodes.length,
      reference: refNodes.length,
      system: systemNodes.length,
      component: componentNodes.length,
    },
    componentCount: componentTags.size,
    // L5: the measured density model (domain + base unit), also attached to the
    // --md-sys-density-scale node. Surfaced at top level for easy consumption.
    density,
    // System color roles that resolve to a literal (e.g. --md-sys-color-shadow
    // → --shadow → #000000), NOT a ref alias — an honest flag, never a
    // silently-missing edge (L3 acceptance: each sys color role has >=1 ref
    // edge OR a documented-literal flag).
    documentedLiteralSystemColors: [...literals].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)),
    notes: NOTES,
    nodes,
    edges,
  };
}

// -- deterministic write / check ---------------------------------------------

export function serializeGraph(graph) {
  return `${JSON.stringify(graph, null, 2)}\n`;
}

export function writeGraph(graphPath, graph) {
  fs.mkdirSync(path.dirname(graphPath), { recursive: true });
  fs.writeFileSync(graphPath, serializeGraph(graph), "utf8");
}

function main(argv) {
  const check = argv.includes("--check");
  const graph = buildGraph();
  const fresh = serializeGraph(graph);

  if (check) {
    const existing = fs.existsSync(DEFAULT_PATHS.graphPath) ? readText(DEFAULT_PATHS.graphPath) : null;
    if (existing !== fresh) {
      process.stderr.write(
        `graph.mjs --check: ${DEFAULT_PATHS.graphPath} is stale (regenerating it differs from what's checked in). ` +
          `Run \`node src/tokens/graph.mjs\` to refresh it.\n`,
      );
      process.exitCode = 1;
      return;
    }
    process.stdout.write(
      `graph.mjs --check: ${DEFAULT_PATHS.graphPath} is byte-stable ` +
        `(${graph.tiers.seed} seed / ${graph.tiers.reference} reference / ${graph.tiers.system} system / ${graph.tiers.component} component nodes, ${graph.edges.length} edges).\n`,
    );
    return;
  }

  writeGraph(DEFAULT_PATHS.graphPath, graph);
  process.stdout.write(
    `graph.mjs: wrote ${DEFAULT_PATHS.graphPath} — ` +
      `${graph.nodes.length} nodes (${graph.tiers.seed} seed, ${graph.tiers.reference} reference, ${graph.tiers.system} system, ${graph.tiers.component} component across ${graph.componentCount} components), ` +
      `${graph.edges.length} edges.\n`,
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
