// verify-roundtrip.mjs — round-trip verification harness.
// Layer 1 (default): join the config JSONs, scan each converted cell for escape
// hatches, and write docs/data/roundtrip-report.json.
// Layer 2 (--render): additionally SSR-render the full generated harness route
// via elm-pages and semantically DOM-diff each cell against its raw corpus HTML.

import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, rmSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseHTML } from "linkedom";
import { buildMatrix, SURFACES } from "./roundtrip/join.mjs";
import { scanEscapes } from "./roundtrip/escape-scan.mjs";
import { writeHarness } from "./roundtrip/gen-harness-route.mjs";
import { moduleResolves } from "./examples-gen/verify-examples.mjs";
import { diffHtml } from "./roundtrip/dom-diff.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..", "..");
const CONFIG = resolve(REPO, "config");
const OUT = resolve(REPO, "docs", "data", "roundtrip-report.json");

const readJson = (p) => JSON.parse(readFileSync(p, "utf8"));

// Layer 2: generate the transient harness route, SSR-render it via elm-pages,
// then DOM-diff each converted cell's rendered output against its raw corpus.
function runLayer2(cells) {
  // 1. Generate the transient harness route (converted cells only).
  const routePath = writeHarness(cells, moduleResolves);
  try {
    // 2. SSR pre-render via elm-pages. Use build:ci (skips build:assets — the
    //    harness embeds cells directly and needs no example regen) so this does
    //    NOT mutate config/ or docs/data/examples.json.
    execFileSync("npm", ["run", "build:ci"], { cwd: resolve(REPO, "docs"), stdio: "inherit" });
    // 3. Read the pre-rendered harness HTML.
    const html = readFileSync(resolve(REPO, "docs", "dist", "roundtrip-harness", "index.html"), "utf8");
    // 4. Split by data-rt marker → each cell's rendered inner HTML.
    const { document } = parseHTML(html);
    const rendered = new Map();
    for (const el of document.querySelectorAll("[data-rt]")) {
      rendered.set(el.getAttribute("data-rt"), el.innerHTML);
    }
    // 5. Diff each converted cell against its raw corpus HTML.
    for (const cell of cells) {
      if (!cell.converted) continue;
      const got = rendered.get(cell.id);
      if (got == null) { cell.roundtrip = { matches: false, functionalMatches: false, deviations: [{ kind: "not-rendered", cosmetic: false }] }; continue; }
      cell.roundtrip = diffHtml(cell.raw, got);
    }
  } finally {
    // 6. Remove the transient route so it never deploys / gets committed.
    rmSync(routePath, { force: true });
  }
}

function main() {
  const rich = readJson(resolve(CONFIG, "examples.rich.json"));
  const surfaces = readJson(resolve(CONFIG, "examples.surfaces.json"));
  const barrel = readJson(resolve(CONFIG, "examples.barrel.json"));

  // Mutable per-cell objects retaining everything Layer 2 needs (id/raw/elm/…).
  const cells = buildMatrix({ rich, surfaces, barrel }).map((cell) => {
    const escape = scanEscapes(cell.elm);
    return {
      id: `${cell.module}/${cell.index}/${cell.surface}`,
      module: cell.module,
      index: cell.index,
      surface: cell.surface,
      title: cell.title,
      raw: cell.raw,
      elm: cell.elm,
      converted: cell.converted,
      escapeHatch: {
        seam: escape.seam,
        native: escape.native,
        charsInside: escape.charsInside,
        benign: escape.benign,
      },
      roundtrip: null, // filled by Layer 2 (--render)
    };
  });

  const render = process.argv.includes("--render");
  if (render) runLayer2(cells);

  const perSurface = {};
  for (const s of SURFACES) {
    const scoped = cells.filter((c) => c.surface === s);
    const converted = scoped.filter((c) => c.converted);
    perSurface[s] = {
      total: scoped.length,
      converted: converted.length,
      clean: converted.filter((c) => c.escapeHatch.charsInside === 0).length,
      usedEscapeHatch: converted.filter((c) => c.escapeHatch.charsInside > 0).length,
    };
    if (render) {
      perSurface[s].roundtripMatched = converted.filter((c) => c.roundtrip && c.roundtrip.matches === true).length;
      perSurface[s].roundtripDeviated = converted.filter((c) => c.roundtrip && !c.roundtrip.matches).length;
      perSurface[s].roundtripFunctionalMatched = converted.filter((c) => c.roundtrip && c.roundtrip.functionalMatches === true).length;
      perSurface[s].roundtripFunctionalDeviated = converted.filter((c) => c.roundtrip && c.roundtrip.functionalMatches === false).length;
    }
  }

  // Written cell shape: keep Layer 1 fields (id/module/index/surface/title/
  // converted/escapeHatch) plus roundtrip (null when Layer 1 only). Drop the
  // bulky raw/elm source from the persisted report — they are only needed live.
  const outCells = cells.map((c) => ({
    id: c.id,
    module: c.module,
    index: c.index,
    surface: c.surface,
    title: c.title,
    converted: c.converted,
    escapeHatch: c.escapeHatch,
    roundtrip: c.roundtrip,
  }));

  const report = {
    generatedAtNote: "stamp externally; Date.now() intentionally not embedded",
    layer2: render,
    perSurface,
    cells: outCells,
  };
  writeFileSync(OUT, JSON.stringify(report, null, 2) + "\n");
  const totalConverted = cells.filter((c) => c.converted).length;
  const layer = render ? "Layer 2 (render)" : "Layer 1";
  console.log(`roundtrip ${layer}: ${cells.length} cells, ${totalConverted} converted -> ${OUT}`);
}

main();
