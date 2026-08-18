// Phase 4 token-graph tests. Grows leaf by leaf:
//   L1 — 3-tier node ingest + measured counts + byte-stability
//   L3 — seed→ref + ref→sys edges (added in the L3 commit)
//   L4 — component tier is edge-less leaves (added in the L4 commit)
//   L5 — density family carries a measured domain + base unit (L5 commit)

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { test } from "node:test";

import { buildGraph, measureDensity, DEFAULT_PATHS } from "./graph.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const graphModule = path.join(here, "graph.mjs");

// -- L1: three-tier node ingest, MEASURED (not enumerated by hand) -----------

test("L1: node tier counts equal the measured sources", () => {
  const graph = buildGraph();

  // Counts measured from the real sources (see graph.mjs header):
  //   seed.css: --md-seed-primary/-error
  //   ref/palette.css: 6 palettes x 12 tones
  //   sys/*.css: every --md-sys-* declaration
  //   cem-facts.json: unique --m3e-* cssProperties
  // Component count re-measured 2026-08-18 after the @m3e/web 2.7.3 -> 2.7.6 bump
  // (facts regenerated from the 2.7.6 CEM): 2251 -> 2265 (+14 new --m3e-* component
  // vars). seed / reference / system tiers are @m3e/web-version-independent.
  assert.equal(graph.tiers.seed, 2, "2 seed nodes (primary + error)");
  assert.equal(graph.tiers.reference, 72, "72 reference nodes (6 palettes x 12 tones)");
  assert.equal(graph.tiers.system, 220, "220 system nodes across sys/*.css");
  assert.equal(graph.tiers.component, 2265, "2265 unique --m3e-* component vars (@m3e/web 2.7.6)");
  assert.equal(graph.componentCount, 99, "99 components declare >=1 --m3e-* var");

  // The tier totals must actually be present as nodes (not just a header count).
  const byTier = {};
  for (const n of graph.nodes) byTier[n.tier] = (byTier[n.tier] ?? 0) + 1;
  assert.deepEqual(byTier, { seed: 2, reference: 72, system: 220, component: 2265 });
  assert.equal(graph.nodes.length, 2 + 72 + 220 + 2265);
});

test("L1: every node carries a tier; families/components are shaped per tier", () => {
  const graph = buildGraph();
  for (const n of graph.nodes) {
    assert.ok(["seed", "reference", "system", "component"].includes(n.tier), `bad tier on ${n.name}`);
    if (n.tier === "component") {
      assert.ok(Array.isArray(n.components) && n.components.length >= 1, `${n.name} needs owner components`);
      assert.ok(n.name.startsWith("--m3e-"), `component node ${n.name} must be --m3e-*`);
    } else {
      assert.equal(typeof n.family, "string", `${n.name} needs a family`);
    }
  }

  // Prefix ↔ tier agreement (the tier is derivable from the name prefix).
  const tierByPrefix = (name) =>
    name.startsWith("--md-seed-") ? "seed"
    : name.startsWith("--md-ref-") ? "reference"
    : name.startsWith("--md-sys-") ? "system"
    : name.startsWith("--m3e-") ? "component"
    : "?";
  for (const n of graph.nodes) assert.equal(n.tier, tierByPrefix(n.name), `${n.name} tier/prefix mismatch`);
});

test("L1: a known var of each tier is present with the right shape", () => {
  const graph = buildGraph();
  const byName = new Map(graph.nodes.map((n) => [n.name, n]));

  assert.deepEqual(byName.get("--md-seed-primary"), { name: "--md-seed-primary", tier: "seed", family: "seed" });
  assert.deepEqual(byName.get("--md-ref-palette-primary-40"), {
    name: "--md-ref-palette-primary-40",
    tier: "reference",
    family: "primary",
  });
  // neutral-variant keeps its two-word family (trailing tone stripped, not the "-variant").
  assert.equal(byName.get("--md-ref-palette-neutral-variant-10").family, "neutral-variant");
  assert.equal(byName.get("--md-sys-color-primary").family, "color");
  assert.ok(byName.has("--m3e-button-container-color"));
  assert.ok(byName.get("--m3e-button-container-color").components.includes("m3e-button"));
});

// -- L3: measured seed→ref (derivesFrom) + ref→sys (aliases) edges -----------

test("L3: every ref palette node derivesFrom its seed", () => {
  const graph = buildGraph();
  const derivesFrom = graph.edges.filter((e) => e.kind === "derivesFrom");
  // 72 ref nodes, each with exactly one seed edge (error→error seed, the rest→primary seed).
  assert.equal(derivesFrom.length, 72);
  for (const n of graph.nodes.filter((x) => x.tier === "reference")) {
    const es = derivesFrom.filter((e) => e.from === n.name);
    assert.equal(es.length, 1, `${n.name} should derive from exactly one seed`);
    assert.ok(es[0].to.startsWith("--md-seed-"));
  }
  // error palette derives from the independent error seed.
  const err = derivesFrom.find((e) => e.from === "--md-ref-palette-error-40");
  assert.equal(err.to, "--md-seed-error");
  const pri = derivesFrom.find((e) => e.from === "--md-ref-palette-primary-40");
  assert.equal(pri.to, "--md-seed-primary");
});

test("L3: every --md-sys-color-* role has >=1 ref alias edge OR a documented-literal flag", () => {
  const graph = buildGraph();
  const sysColor = graph.nodes.filter((n) => n.name.startsWith("--md-sys-color-"));
  const aliasFrom = new Set(graph.edges.filter((e) => e.kind === "aliases").map((e) => e.from));
  const literal = new Set(graph.documentedLiteralSystemColors);
  const uncovered = sysColor.filter((n) => !aliasFrom.has(n.name) && !literal.has(n.name));
  assert.deepEqual(uncovered, [], "no sys-color role may be silently edge-less");
  // shadow/scrim are the two literals (#000000), not ref aliases.
  assert.ok(literal.has("--md-sys-color-shadow"));
  assert.ok(literal.has("--md-sys-color-scrim"));
});

test("L3: the known on-surface role aliases neutral tone 10/90 (transitive through convenience alias)", () => {
  const graph = buildGraph();
  const tos = graph.edges
    .filter((e) => e.from === "--md-sys-color-on-surface" && e.kind === "aliases")
    .map((e) => e.to)
    .sort();
  assert.deepEqual(tos, ["--md-ref-palette-neutral-10", "--md-ref-palette-neutral-90"]);

  const primary = graph.edges
    .filter((e) => e.from === "--md-sys-color-primary" && e.kind === "aliases")
    .map((e) => e.to)
    .sort();
  assert.deepEqual(primary, ["--md-ref-palette-primary-40", "--md-ref-palette-primary-80"]);
});

// -- L4 (Decision 2b): component tier is edge-less leaves + a recorded reason -

test("L4: component nodes are leaves — present, but never a source or target of any edge", () => {
  const graph = buildGraph();
  const componentNames = new Set(graph.nodes.filter((n) => n.tier === "component").map((n) => n.name));
  assert.ok(componentNames.size >= 2251, "component leaves are present");

  // No edge touches the component tier in v1 (the sys→comp fallback lives in
  // @m3e/web dist CSS, not the CEM — Decision 2b).
  for (const e of graph.edges) {
    assert.ok(!componentNames.has(e.from), `component node ${e.from} must have no outgoing edge in v1`);
    assert.ok(!componentNames.has(e.to), `component node ${e.to} must have no incoming edge in v1`);
  }

  // The reason for the edge-less component tier is RECORDED in the artifact,
  // not just in code — a consumer learns the v1 boundary from the graph itself.
  assert.ok(
    graph.notes.some((n) => /edge-less.*Decision 2b/i.test(n) && /@m3e\/web dist/i.test(n)),
    "the edge-less component-tier reason must be recorded in graph.notes",
  );
});

// -- L5: density as a first-class system family, MEASURED (not hardcoded) -----

test("L5: the density family carries a measured domain + base unit", () => {
  const graph = buildGraph();

  // Top-level density model.
  assert.deepEqual(graph.density.domain, [0, -1, -2, -3]);
  assert.equal(graph.density.baseUnit, "0.25rem");

  // Attached to the --md-sys-density-scale system node too.
  const scale = graph.nodes.find((n) => n.name === "--md-sys-density-scale");
  assert.equal(scale.tier, "system");
  assert.equal(scale.family, "density");
  assert.deepEqual(scale.domain, [0, -1, -2, -3]);
  assert.equal(scale.baseUnit, "0.25rem");

  // --md-sys-density-size is in the same family.
  const size = graph.nodes.find((n) => n.name === "--md-sys-density-size");
  assert.equal(size.family, "density");
});

test("L5: the density domain/baseUnit are MEASURED from the CSS, not hardcoded", () => {
  // Feed doctored CSS with a different scale set + base unit; the model must
  // follow the source, proving it's parsed rather than a constant. Comments
  // mentioning the tokens must NOT pollute the value.
  const fakeScope = `
    /* prose: --md-sys-density-scale: -9 and --md-sys-density-size: 99rem should be ignored */
    @utility density-0 { --md-sys-density-scale: 0; }
    @utility density-1 { --md-sys-density-scale: -1; }
    @utility density-2 { --md-sys-density-scale: -2; }
  `;
  const fakeSys = `
    /* --md-sys-density-size:  99rem → prose */
    :root { --md-sys-density-size: 0.5rem; }
  `;
  const measured = measureDensity(fakeScope, fakeSys);
  assert.deepEqual(measured.domain, [0, -1, -2], "domain follows the (doctored) source");
  assert.equal(measured.baseUnit, "0.5rem", "base unit follows the (doctored) source, ignoring the comment");
});

test("L1: graph.mjs --check is byte-stable (committed == fresh regeneration)", () => {
  // The committed artifact must equal a fresh regeneration — the workspace
  // determinism ground rule. Uses the CLI so this exercises exactly what the
  // `check:token-graph` gate runs.
  const out = execFileSync(process.execPath, [graphModule, "--check"], { encoding: "utf8" });
  assert.match(out, /byte-stable/);
  assert.ok(fs.existsSync(DEFAULT_PATHS.graphPath), "token-graph.json exists");
});
