#!/usr/bin/env node
// gen-facts.mjs — regenerate profiles/m3-kit/facts/{cem-facts,elm-api-facts}.json
// from the WORKSPACE producer (packages/elm-cem) against elm-m3e's own config,
// the same invocation tools/gate-all.mjs's E2E proof and tools/ab-elm-cem.sh
// use. This is the only writer of that bundle — never hand-edit it.
//
// Usage: pnpm --filter cem-figma-connect run gen:facts
// Env:
//   ELM_M3E  elm-m3e checkout to generate against (default: the in-workspace
//            packages/elm-m3e)

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const repoRoot = path.dirname(path.dirname(pkgDir));
const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");
const cli = path.join(repoRoot, "packages", "elm-cem", "bin", "elm-cem.js");
const destDir = path.join(pkgDir, "profiles", "m3-kit", "facts");

function generateBundle(outDir) {
    const outputDir = path.join(outDir, "out");
    const bundleDir = path.join(outDir, "bundle");
    fs.mkdirSync(outputDir, { recursive: true });
    fs.mkdirSync(bundleDir, { recursive: true });

    const result = spawnSync(
        process.execPath,
        [
            cli,
            "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
            "--config-from=config/slots.json",
            "--config-from=config/native-mdn.json",
            "--config-from=config/examples.generated.json",
            `--output=${outputDir}`,
            `--facts-bundle=${bundleDir}`,
        ],
        {
            cwd: elmM3e,
            encoding: "utf8",
            env: { ...process.env, PATH: `${path.join(elmM3e, "node_modules", ".bin")}:${process.env.PATH}` },
        },
    );
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    if (result.status !== 0) {
        throw new Error(`elm-cem --facts-bundle exited ${result.status}`);
    }
    return bundleDir;
}

function main() {
    if (!fs.existsSync(elmM3e)) {
        console.error(`gen-facts: elm-m3e not found at ${elmM3e} (set ELM_M3E)`);
        process.exit(1);
    }

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "cfc-gen-facts-"));
    try {
        const bundleDir = generateBundle(work);
        fs.mkdirSync(destDir, { recursive: true });
        for (const file of ["cem-facts.json", "elm-api-facts.json"]) {
            fs.copyFileSync(path.join(bundleDir, file), path.join(destDir, file));
            console.log(`gen-facts: wrote ${path.join("profiles", "m3-kit", "facts", file)}`);
        }
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

main();
