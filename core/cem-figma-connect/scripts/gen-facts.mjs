#!/usr/bin/env node
// gen-facts.mjs — regenerate profiles/m3-kit/facts/{cem-facts,elm-api-facts}.json
// from the WORKSPACE producer (packages/elm-cem) against elm-m3e's own config.
// Shared implementation: tools/lib/gen-facts-runner.mjs (Theme 3 of the
// 2026-08-17 audit — this file shared the same core shape as m3e-okf's and
// tailwind-m3e-web's gen-facts.mjs, plus its own icon-names.json derivation).
//
// Usage: pnpm --filter cem-figma-connect run gen:facts
// Env:
//   ELM_M3E                  elm-m3e checkout to generate against (default:
//                            the in-workspace packages/elm-m3e)
//   PREGENERATED_BUNDLE_DIR  skip regeneration and copy from this directory
//                            instead (used by `tools/bump.mjs`)

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { runGenFacts } from "../../../tools/lib/gen-facts-runner.mjs";
import { deriveIconNamesFromOutput, serializeIconNames } from "../../../tools/lib/regen.mjs";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(path.dirname(pkgDir));
const destDir = path.join(pkgDir, "profiles", "m3-kit", "facts");
const ICON_NAMES_FILE = "icon-names.json";

runGenFacts({
    repoRoot,
    pkgDir,
    destDir,
    files: ["cem-facts.json", "elm-api-facts.json"],
    tmpPrefix: "cfc-gen-facts-",
    // Derive + write the opaque-`Name` icon catalog (R-026) from the same
    // regeneration's Face-A output. Kept next to the bundle copy so the
    // emitter's icon shape (`M3e.Icon.icon M3e.Icon.menu …`) is sourced from
    // the real generated icon module, never hardcoded.
    // `deriveIconNamesFromOutput`/`serializeIconNames` live in
    // tools/lib/regen.mjs so the provenance drift gate
    // (tools/lib/check-drift-core.mjs's checkConsumerBundleDrift) derives it
    // the exact same way.
    writeExtra: ({ outputDir }) => {
        const catalog = deriveIconNamesFromOutput(outputDir);
        fs.writeFileSync(path.join(destDir, ICON_NAMES_FILE), serializeIconNames(catalog), "utf8");
        console.log(
            `gen-facts: wrote ${path.join("profiles", "m3-kit", "facts", ICON_NAMES_FILE)} ` +
                `(${Object.keys(catalog.names).length} icon Name constants)`,
        );
    },
});
