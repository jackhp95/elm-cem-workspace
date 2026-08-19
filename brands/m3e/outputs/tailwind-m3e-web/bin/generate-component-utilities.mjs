#!/usr/bin/env node
/*
 * bin/generate-component-utilities.mjs
 *
 * Reads data/cem-facts.json — elm-cem's Face B facts bundle, the
 * reconciled/deduped projection of @m3e/web's Custom Elements Manifest —
 * and emits:
 *
 *   1. generated/utilities.css
 *      One @utility rule per public --m3e-* CSS custom property.
 *      Each rule uses Tailwind v4's --value(<type>, --<namespace>-*)
 *      syntax so call sites can pass either an arbitrary value or a
 *      theme key. Inert under Tailwind v3.
 *
 *   2. generated/CSS_CUSTOM_PROPERTIES.md
 *      Structured reference, grouped by component, with type + description.
 *
 * The generic transform (type inference, extraction, the three emitters)
 * lives in `tools/lib/component-css-utilities.mjs` — promoted there per the
 * thermonuclear audit (Theme 6 #2) so a second brand doesn't have to re-copy
 * it. This file keeps only what's genuinely package-specific: the bundle
 * path, the output paths, and the CLI entry point.
 *
 * Determinism: re-running this script on the same bundle produces
 * byte-identical output. Use `git diff` to verify after running.
 *
 * Ported from VOLT-2044 (avetta/ui lemon branch) and adapted for the
 * standalone tailwind-m3e-web package layout.
 */

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { fileURLToPath, pathToFileURL } from "node:url";
import { dirname, join } from "node:path";
import {
  inferType,
  extractCssProperties,
  emitUtilities,
  emitUtilityManifest,
  emitDoc,
} from "../../../../../tools/lib/component-css-utilities.mjs";

export { inferType, extractCssProperties, emitUtilities, emitUtilityManifest, emitDoc };

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");
const BUNDLE_PATH = join(ROOT, "data", "cem-facts.json");
const OUT_UTILITIES = join(ROOT, "generated", "utilities.css");
const OUT_MANIFEST = join(ROOT, "generated", "utilities.json");
const OUT_DOC = join(ROOT, "generated", "CSS_CUSTOM_PROPERTIES.md");

async function loadBundle() {
  const raw = await readFile(BUNDLE_PATH, "utf8");
  return JSON.parse(raw);
}

async function main() {
  const bundle = await loadBundle();
  const { byComponent, flatUnique } = extractCssProperties(bundle);

  await mkdir(dirname(OUT_UTILITIES), { recursive: true });
  await writeFile(OUT_UTILITIES, emitUtilities(flatUnique));
  await writeFile(OUT_MANIFEST, emitUtilityManifest(flatUnique));
  await writeFile(OUT_DOC, emitDoc(byComponent, flatUnique));

  console.log(`Wrote ${flatUnique.size} @utility rules → ${OUT_UTILITIES}`);
  console.log(`Wrote ${flatUnique.size} utility names → ${OUT_MANIFEST}`);
  console.log(`Wrote ${byComponent.size} component sections → ${OUT_DOC}`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
