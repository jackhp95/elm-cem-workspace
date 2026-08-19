#!/usr/bin/env node
// gen-facts.mjs — regenerate data/cem-facts.json from the WORKSPACE producer
// (packages/elm-cem) against elm-m3e's own config. Shared implementation:
// tools/lib/gen-facts-runner.mjs (this file used to duplicate
// tailwind-m3e-web's gen-facts.mjs byte-for-byte — Theme 3 of the
// 2026-08-17 audit).
//
// Usage: pnpm --filter m3e-okf run gen:facts
// Env:
//   ELM_M3E                  elm-m3e checkout to generate against (default:
//                            the in-workspace packages/elm-m3e)
//   PREGENERATED_BUNDLE_DIR  skip regeneration and copy from this directory
//                            instead (used by `tools/bump.mjs`)

import path from "node:path";
import { fileURLToPath } from "node:url";
import { runGenFacts } from "../../../../../tools/lib/gen-facts-runner.mjs";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(path.dirname(path.dirname(path.dirname(pkgDir))));

runGenFacts({
    repoRoot,
    pkgDir,
    destDir: path.join(pkgDir, "data"),
    files: ["cem-facts.json"],
    tmpPrefix: "m3e-okf-gen-facts-",
});
