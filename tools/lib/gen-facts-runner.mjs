// gen-facts-runner.mjs — the shared implementation behind every consumer's
// `scripts/gen-facts.mjs` (cem-figma-connect, m3e-okf, tailwind-m3e-web).
// Before this existed, tailwind-m3e-web's and m3e-okf's copies were
// byte-identical except for a tmp-dir prefix string and a usage comment, and
// cem-figma-connect's was the same shape plus its own icon-names.json
// derivation (Theme 3 of docs/reviews/2026-08-17-thermonuclear-workspace-review.md).
//
// Regenerates one or more bundle-copy files from the WORKSPACE producer
// (core/elm-cem) against elm-m3e's own config — the same invocation
// tools/gate-all.mjs's E2E proof and tools/ab-elm-cem.sh use (shared
// definition: tools/lib/regen.mjs) — and writes them into `destDir`. This is
// the only writer of those files; never hand-edit them.
//
// DEPRECATION (repo-shape-v2, 2026-08-19): this runner stays in tools/lib only
// because there is no real `elm-m3e-facts` package yet — its 3 consumers
// (elm-cem-figma-connect, m3e-okf/elm-m3e-okf, tailwind-m3e-web/elm-m3e-tailwind)
// each keep a redundant private copy of the same facts bundle, fanned out through
// this shared runner. When the deferred 5-package explosion (spec decision #7)
// creates a real `elm-m3e-facts` package, delete/gut this runner and switch the 3
// consumers to a `workspace:*` dependency on `elm-m3e-facts` instead of a private copy.
//
// Zero dependencies (plain Node ESM).

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { generateBundleToTemp } from "./regen.mjs";

/**
 * @param {object} opts
 * @param {string} opts.repoRoot
 * @param {string} opts.pkgDir - the consumer package's own directory (for relative log paths)
 * @param {string} opts.destDir - where to write the bundle-copy files
 * @param {string[]} opts.files - bundle file names to copy verbatim (e.g. ["cem-facts.json"])
 * @param {string} opts.tmpPrefix - os.tmpdir() prefix for this consumer's scratch regen dir
 * @param {(ctx: {destDir: string, outputDir: string}) => void} [opts.writeExtra] -
 *   optional extra artifact derived from the same regeneration's Face-A output
 *   (cem-figma-connect's icon-names.json). Called with PREGENERATED_OUTPUT_DIR
 *   (or the conventional `<bundle>/../out` sibling) when PREGENERATED_BUNDLE_DIR
 *   short-circuits regeneration.
 */
export function runGenFacts({ repoRoot, pkgDir, destDir, files, tmpPrefix, writeExtra }) {
    const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");

    // PREGENERATED_BUNDLE_DIR: skip regeneration and copy from this directory
    // instead (used by tools/bump.mjs so the whole workspace bump regenerates
    // the bundle exactly once, then fans the SAME bundle out to every
    // consumer instead of regenerating per consumer).
    const pregenerated = process.env.PREGENERATED_BUNDLE_DIR;
    if (pregenerated) {
        fs.mkdirSync(destDir, { recursive: true });
        for (const file of files) {
            fs.copyFileSync(path.join(pregenerated, file), path.join(destDir, file));
            console.log(`gen-facts: wrote ${path.relative(pkgDir, path.join(destDir, file))} (from pregenerated bundle)`);
        }
        if (writeExtra) {
            const outputDir = process.env.PREGENERATED_OUTPUT_DIR || path.join(pregenerated, "..", "out");
            writeExtra({ destDir, outputDir });
        }
        return;
    }

    if (!fs.existsSync(elmM3e)) {
        console.error(`gen-facts: elm-m3e not found at ${elmM3e} (set ELM_M3E)`);
        process.exit(1);
    }

    const work = fs.mkdtempSync(path.join(os.tmpdir(), tmpPrefix));
    try {
        const { outputDir, bundleDir } = generateBundleToTemp({ repoRoot, elmM3e, workDir: work });
        fs.mkdirSync(destDir, { recursive: true });
        for (const file of files) {
            fs.copyFileSync(path.join(bundleDir, file), path.join(destDir, file));
            console.log(`gen-facts: wrote ${path.relative(pkgDir, path.join(destDir, file))}`);
        }
        if (writeExtra) writeExtra({ destDir, outputDir });
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}
