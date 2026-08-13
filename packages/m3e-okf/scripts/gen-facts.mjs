#!/usr/bin/env node
// gen-facts.mjs — regenerate data/cem-facts.json from the WORKSPACE producer
// (packages/elm-cem) against elm-m3e's own config, the same invocation
// tools/gate-all.mjs's E2E proof and tools/ab-elm-cem.sh use (shared
// definition: tools/lib/regen.mjs). This is the only writer of that file —
// never hand-edit it.
//
// Usage: pnpm --filter m3e-docs run gen:facts
// Env:
//   ELM_M3E                  elm-m3e checkout to generate against (default:
//                            the in-workspace packages/elm-m3e)
//   PREGENERATED_BUNDLE_DIR  skip regeneration and copy from this directory
//                            instead (used by `tools/bump.mjs` so the whole
//                            workspace bump regenerates the bundle exactly
//                            once, then fans the SAME bundle out to every
//                            consumer instead of regenerating per consumer)

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { generateBundleToTemp } from "../../../tools/lib/regen.mjs";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(path.dirname(pkgDir));
const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");
const destPath = path.join(pkgDir, "data", "cem-facts.json");

function main() {
    const pregenerated = process.env.PREGENERATED_BUNDLE_DIR;
    if (pregenerated) {
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(path.join(pregenerated, "cem-facts.json"), destPath);
        console.log(`gen-facts: wrote ${path.join("data", "cem-facts.json")} (from pregenerated bundle)`);
        return;
    }

    if (!fs.existsSync(elmM3e)) {
        console.error(`gen-facts: elm-m3e not found at ${elmM3e} (set ELM_M3E)`);
        process.exit(1);
    }

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "m3e-okf-gen-facts-"));
    try {
        const { bundleDir } = generateBundleToTemp({ repoRoot, elmM3e, workDir: work });
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(path.join(bundleDir, "cem-facts.json"), destPath);
        console.log(`gen-facts: wrote ${path.join("data", "cem-facts.json")}`);
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

main();
