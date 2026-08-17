// Phase 4 (L6): the delta classifier — the three plan fixtures + the GATED
// covered-output-set completeness assertion (the plan's main design risk §8).

import assert from "node:assert/strict";
import { test } from "node:test";

import {
  classifyDelta,
  readBaseSources,
  COVERED_OUTPUTS,
  coveredInputFiles,
} from "./classify-delta.mjs";

// A deep-ish clone that keeps the shape the classifier reads.
function cloneSources(s) {
  return {
    seedCss: s.seedCss,
    paletteCss: s.paletteCss,
    sysCssByFile: { ...s.sysCssByFile },
    themeCss: s.themeCss,
    cemFacts: JSON.parse(JSON.stringify(s.cemFacts)),
    tokenRows: s.tokenRows,
  };
}

const base = readBaseSources();

// -- Fixture (a): seed-only re-theme -----------------------------------------

test("L6(a): a seed-only value change is a RE-THEME with an empty emitter diff", () => {
  const after = cloneSources(base);
  // Change the primary seed hue only — a leaf value, no name/edge change.
  after.seedCss = after.seedCss.replace("--md-seed-primary: #6750a4;", "--md-seed-primary: #2e7d32;");
  assert.notEqual(after.seedCss, base.seedCss, "fixture must actually change the seed");

  const verdict = classifyDelta(base, after);
  assert.equal(verdict.kind, "retheme");
  assert.equal(verdict.outputs.length, 0, "no covered emitter output may change for a pure re-theme");
  assert.deepEqual(verdict.files, ["tailwind-m3e-web/src/seed.css"]);
});

// -- Fixture (b): a new component var -----------------------------------------

test("L6(b): a new --m3e-* component var is a REQUIRED-CODE-CHANGE naming utilities.css", () => {
  const after = cloneSources(base);
  const target = after.cemFacts.components.find((c) => (c.cssProperties ?? []).length);
  target.cssProperties.push({
    name: "--m3e-fake-phase4-new-var-color",
    description: "A synthetic new component var (L6 fixture).",
    default: null,
    syntax: null,
  });

  const verdict = classifyDelta(base, after);
  assert.equal(verdict.kind, "required-code-change");
  assert.equal(verdict.tier, "component");
  assert.equal(verdict.reason, "new-name");
  const surfaces = verdict.outputs.map((o) => o.surface);
  assert.ok(surfaces.includes("utilities.css"), `utilities.css must be named; got ${surfaces.join(", ")}`);
  assert.ok(verdict.files.some((f) => f.includes("cem-facts.json")));
});

// -- Fixture (c): the container-tone regression (an alias repoint) ------------

test("L6(c): repointing a sys-color alias is a REQUIRED-CODE-CHANGE naming sys/color.css derivation", () => {
  const after = cloneSources(base);
  // The container-tone regression: on-primary-container should alias tone 30,
  // not 90 — here we PERTURB it to tone 90 (light) to force the edge to move.
  const colorCss = after.sysCssByFile["color.css"];
  const perturbed = colorCss.replace(
    "--md-sys-color-on-primary-container: light-dark(\n    var(--md-ref-palette-primary-30),",
    "--md-sys-color-on-primary-container: light-dark(\n    var(--md-ref-palette-primary-90),",
  );
  assert.notEqual(perturbed, colorCss, "fixture must actually repoint the alias");
  after.sysCssByFile = { ...after.sysCssByFile, "color.css": perturbed };

  const verdict = classifyDelta(base, after);
  assert.equal(verdict.kind, "required-code-change");
  assert.equal(verdict.reason, "alias-repoint");
  assert.equal(verdict.tier, "system");
  assert.ok(
    verdict.files.some((f) => f.endsWith("sys/color.css")),
    `the offending derivation file must be named; got ${verdict.files.join(", ")}`,
  );
  // An alias repoint produces NO emitter-output byte diff — it's caught by the
  // graph-edge axis, not the output axis. That distinction must hold.
  assert.equal(verdict.outputs.length, 0);
});

// -- GATED: the covered-output set is complete (the mislabeling guard) --------

test("L6: COVERED_OUTPUTS names the Elm token surface + Code Connect + @theme + utilities.css", () => {
  const surfaces = COVERED_OUTPUTS.map((o) => o.surface);
  assert.ok(surfaces.includes("utilities.css"), "utilities.css must be covered");
  assert.ok(surfaces.includes("Tailwind @theme keys"), "@theme keys must be covered");
  assert.ok(
    surfaces.includes("Elm token surface + Code Connect bindings"),
    "the Elm token surface + Code Connect bindings must be covered",
  );
  // Every covered output declares which token inputs it derives from.
  for (const out of COVERED_OUTPUTS) {
    assert.ok(Array.isArray(out.inputs) && out.inputs.length >= 1, `${out.key} must declare its inputs`);
    assert.equal(typeof out.extract, "function");
  }
});

test("L6: every token INPUT source is observed by a covered output or the graph axis (no silent hole)", () => {
  const { fromOutputs, fromGraph } = coveredInputFiles();
  const observed = new Set([...fromOutputs, ...fromGraph]);

  // The complete universe of token inputs a design delta can touch:
  const universe = [
    "seed.css", // graph (seed node names) + value-only re-theme
    "ref/palette.css", // graph nodes + edges
    "sys/*.css", // graph nodes + color edges
    "theme.css", // @theme keys
    "cem-facts.json:cssProperties", // utilities.css + doc + graph component nodes
  ];
  for (const input of universe) {
    assert.ok(observed.has(input), `token input "${input}" is NOT observed by any covered output/graph axis`);
  }
});

test("L6: an identity delta (base vs base) is a value-only re-theme (sanity)", () => {
  const verdict = classifyDelta(base, base);
  assert.equal(verdict.kind, "retheme");
  assert.equal(verdict.outputs.length, 0);
  assert.deepEqual(verdict.files, []);
});
