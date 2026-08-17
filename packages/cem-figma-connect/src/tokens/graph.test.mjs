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

import { buildGraph, DEFAULT_PATHS } from "./graph.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const graphModule = path.join(here, "graph.mjs");

// -- L1: three-tier node ingest, MEASURED (not enumerated by hand) -----------

test("L1: node tier counts equal the measured sources", () => {
  const graph = buildGraph();

  // Counts measured 2026-08-17 from the real sources (see graph.mjs header):
  //   seed.css: --md-seed-primary/-error
  //   ref/palette.css: 6 palettes x 12 tones
  //   sys/*.css: every --md-sys-* declaration
  //   cem-facts.json: unique --m3e-* cssProperties
  assert.equal(graph.tiers.seed, 2, "2 seed nodes (primary + error)");
  assert.equal(graph.tiers.reference, 72, "72 reference nodes (6 palettes x 12 tones)");
  assert.equal(graph.tiers.system, 220, "220 system nodes across sys/*.css");
  assert.equal(graph.tiers.component, 2251, "2251 unique --m3e-* component vars");
  assert.equal(graph.componentCount, 99, "99 components declare >=1 --m3e-* var");

  // The tier totals must actually be present as nodes (not just a header count).
  const byTier = {};
  for (const n of graph.nodes) byTier[n.tier] = (byTier[n.tier] ?? 0) + 1;
  assert.deepEqual(byTier, { seed: 2, reference: 72, system: 220, component: 2251 });
  assert.equal(graph.nodes.length, 2 + 72 + 220 + 2251);
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

test("L1: graph.mjs --check is byte-stable (committed == fresh regeneration)", () => {
  // The committed artifact must equal a fresh regeneration — the workspace
  // determinism ground rule. Uses the CLI so this exercises exactly what the
  // `check:token-graph` gate runs.
  const out = execFileSync(process.execPath, [graphModule, "--check"], { encoding: "utf8" });
  assert.match(out, /byte-stable/);
  assert.ok(fs.existsSync(DEFAULT_PATHS.graphPath), "token-graph.json exists");
});
