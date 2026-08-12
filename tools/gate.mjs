#!/usr/bin/env node
// Root gate: runs the task enumeration, then compiles the Elm probe with the root-pinned elm binary.
import { spawnSync } from "node:child_process";
import { existsSync, statSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));

function run(label, command, args, options) {
    console.log(`$ ${command} ${args.join(" ")}${options?.cwd ? `  (cwd: ${options.cwd})` : ""}`);
    const result = spawnSync(command, args, { stdio: "inherit", ...options });
    if (result.error) {
        console.error(`${label} failed to run: ${result.error.message}`);
        process.exit(1);
    }
    if (result.status !== 0) {
        console.error(`${label} failed with exit code ${result.status}`);
        process.exit(result.status ?? 1);
    }
}

function main() {
    run("tasks", process.execPath, [join(repoRoot, "tools", "tasks.mjs")]);

    const appDir = join(repoRoot, "packages", "_probe", "elm-probe-app");
    const outDir = join(repoRoot, ".gate-out");
    const outFile = join(outDir, "probe.js");
    const elmBin = join(repoRoot, "node_modules", ".bin", "elm");

    if (!existsSync(elmBin)) {
        console.error(`root-pinned elm binary not found at ${elmBin}`);
        process.exit(1);
    }

    run("elm make", elmBin, ["make", "src/Main.elm", `--output=${outFile}`], { cwd: appDir });

    if (!existsSync(outFile) || statSync(outFile).size === 0) {
        console.error(`expected compiled output at ${outFile} but it is missing or empty`);
        process.exit(1);
    }

    console.log("GATE GREEN");
}

main();
