#!/usr/bin/env node
// gate-all.mjs — M1 integration gate: the ONE command that proves the whole
// workspace is green.
//
// It runs, in this order:
//   1. every workspace package's own `check` and `test` script — DISCOVERED
//      from the pnpm workspace (`pnpm ls -r --depth -1 --json`), never
//      hardcoded, so a package added in a later milestone is picked up with no
//      edit here;
//   2. the cross-cutting workspace checks (coverage map, single Cem.Facts,
//      single @m3e/web pin, the A/B generation harness, the A/B split
//      harness, copy-fidelity for the migrated elm-m3e AND cem-figma-connect,
//      cem-figma-connect's gen:emit determinism proof, cem-figma-connect's
//      facts-bundle provenance, the root gate);
//   3. a REAL end-to-end facts-bundle proof: run the workspace elm-cem against
//      elm-m3e's own config into a temp dir, then validate both emitted faces
//      against docs/facts-bundle/schema.json with the shipped validator.
//
// Every item runs even if an earlier one fails — one run shows the whole
// picture, not just the first thing to break. Exits nonzero if ANY item fails.
//
// Zero dependencies (plain Node ESM).
//
// Env:
//   PRISTINE_ELM_CEM  passed through to tools/ab-elm-cem.sh
//   ELM_M3E           elm-m3e checkout used by the E2E bundle proof
//                     (default: the in-workspace packages/elm-m3e)

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const require = createRequire(import.meta.url);

const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");

// ── result accounting ─────────────────────────────────────────────────────
const results = [];

function record(name, ok, detail) {
    results.push({ name, ok, detail: detail || "" });
    console.log(`\n${ok ? "PASS" : "FAIL"}  ${name}${detail ? `  — ${detail}` : ""}`);
}

/** Run a command to completion, streaming its output. Never throws. */
function runItem(name, command, args, options = {}) {
    console.log(`\n${"─".repeat(72)}\n▶ ${name}\n$ ${command} ${args.join(" ")}${options.cwd ? `  (cwd: ${options.cwd})` : ""}`);
    const result = spawnSync(command, args, { stdio: "inherit", cwd: repoRoot, ...options });
    if (result.error) {
        record(name, false, `failed to spawn: ${result.error.message}`);
        return false;
    }
    const ok = result.status === 0;
    record(name, ok, ok ? "" : `exit code ${result.status ?? "signal " + result.signal}`);
    return ok;
}

// ── 1. discover workspace packages ────────────────────────────────────────
/**
 * Ask pnpm for the workspace members. Falls back to walking packages/ for
 * package.json files if pnpm cannot answer, so discovery never silently
 * degrades into "zero packages, all green".
 */
function discoverPackages() {
    const listed = spawnSync("pnpm", ["ls", "-r", "--depth", "-1", "--json"], {
        cwd: repoRoot,
        encoding: "utf8",
    });
    if (listed.status === 0 && listed.stdout) {
        try {
            return JSON.parse(listed.stdout)
                .filter((p) => path.resolve(p.path) !== path.resolve(repoRoot))
                .map((p) => ({ name: p.name, dir: p.path }));
        } catch (e) {
            console.error(`gate-all: could not parse pnpm ls output (${e.message}); falling back to a packages/ walk`);
        }
    } else {
        console.error("gate-all: `pnpm ls -r` failed; falling back to a packages/ walk");
    }

    const found = [];
    const SKIP = new Set(["node_modules", "elm-stuff", ".git"]);
    const walk = (dir) => {
        for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
            if (SKIP.has(entry.name)) continue;
            if (!entry.isDirectory()) continue;
            const full = path.join(dir, entry.name);
            if (fs.existsSync(path.join(full, "package.json"))) {
                const pkg = JSON.parse(fs.readFileSync(path.join(full, "package.json"), "utf8"));
                found.push({ name: pkg.name, dir: full });
            }
            walk(full);
        }
    };
    walk(path.join(repoRoot, "packages"));
    return found;
}

function scriptsOf(dir) {
    try {
        return JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8")).scripts || {};
    } catch {
        return {};
    }
}

// ── 3. the end-to-end facts-bundle proof ──────────────────────────────────
// A gate that passes when nothing was produced is worthless, so this one
// insists on: the generator exits 0, BOTH faces exist, are non-empty, parse,
// carry non-trivial content, and validate against the real schema.
function factsBundleE2E() {
    const name = "e2e: facts bundle generate + validate (elm-m3e config)";
    console.log(`\n${"─".repeat(72)}\n▶ ${name}`);

    if (!fs.existsSync(ELM_M3E)) {
        record(name, false, `elm-m3e checkout not found at ${ELM_M3E} (set ELM_M3E)`);
        return false;
    }

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "gate-all-facts-"));
    try {
        const outDir = path.join(work, "out");
        const bundleDir = path.join(work, "bundle");
        const cli = path.join(repoRoot, "packages", "elm-cem", "bin", "elm-cem.js");

        console.log(`$ node ${cli} --facts-bundle=${bundleDir}  (cwd: ${ELM_M3E})`);
        const gen = spawnSync(
            process.execPath,
            [
                cli,
                "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
                "--config-from=config/slots.json",
                "--config-from=config/native-mdn.json",
                "--config-from=config/examples.generated.json",
                `--output=${outDir}`,
                `--facts-bundle=${bundleDir}`,
            ],
            {
                cwd: ELM_M3E,
                encoding: "utf8",
                env: { ...process.env, PATH: `${path.join(ELM_M3E, "node_modules", ".bin")}:${process.env.PATH}` },
            },
        );
        if (gen.stdout) process.stdout.write(gen.stdout);
        if (gen.stderr) process.stderr.write(gen.stderr);
        if (gen.status !== 0) {
            record(name, false, `generator exited ${gen.status}`);
            return false;
        }

        const schemaPath = path.join(repoRoot, "docs", "facts-bundle", "schema.json");
        if (!fs.existsSync(schemaPath)) {
            record(name, false, `schema not found at ${schemaPath}`);
            return false;
        }
        const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
        const { validate } = require(path.join(repoRoot, "packages", "elm-cem", "bin", "validate-facts-bundle.js"));

        const faces = [
            { file: "cem-facts.json", definition: "faceB", label: "Face B" },
            { file: "elm-api-facts.json", definition: "faceC", label: "Face C" },
        ];

        const problems = [];
        for (const face of faces) {
            const p = path.join(bundleDir, face.file);
            if (!fs.existsSync(p)) {
                problems.push(`${face.label}: ${face.file} was not written`);
                continue;
            }
            const raw = fs.readFileSync(p, "utf8");
            if (raw.trim().length === 0) {
                problems.push(`${face.label}: ${face.file} is empty`);
                continue;
            }
            let data;
            try {
                data = JSON.parse(raw);
            } catch (e) {
                problems.push(`${face.label}: ${face.file} is not valid JSON — ${e.message}`);
                continue;
            }
            // "Valid but vacuous" is the failure mode a schema alone will not
            // catch: an empty `components` satisfies both `type: array` and
            // `type: object`. Face B lists components as an array, Face C keys
            // them by tag, so count both shapes.
            const raw_components = data.components;
            const componentCount = Array.isArray(raw_components)
                ? raw_components.length
                : raw_components && typeof raw_components === "object"
                  ? Object.keys(raw_components).length
                  : null;
            if (componentCount === null) {
                problems.push(`${face.label}: no \`components\` array or object`);
                continue;
            }
            if (componentCount === 0) {
                problems.push(`${face.label}: \`components\` is empty — nothing was actually produced`);
                continue;
            }
            const { valid, errors } = validate(schema, data, face.definition);
            if (!valid) {
                problems.push(
                    `${face.label}: ${errors.length} schema error(s) — ${errors.slice(0, 5).join("; ")}` +
                        (errors.length > 5 ? ` … (+${errors.length - 5} more)` : ""),
                );
                continue;
            }
            console.log(`   ok  ${face.label} (${face.file}): ${componentCount} components, valid against schema.json`);
        }

        if (problems.length > 0) {
            for (const p of problems) console.error(`   bad ${p}`);
            record(name, false, problems.join(" | "));
            return false;
        }
        record(name, true, "both faces generated, non-empty, schema-valid");
        return true;
    } catch (e) {
        record(name, false, `threw: ${e.message}`);
        return false;
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

// ── main ──────────────────────────────────────────────────────────────────
function main() {
    const packages = discoverPackages();
    console.log(`gate-all: discovered ${packages.length} workspace package(s): ${packages.map((p) => p.name).join(", ")}`);

    const perPackage = [];
    for (const pkg of packages) {
        const scripts = scriptsOf(pkg.dir);
        for (const script of ["check", "test"]) {
            if (scripts[script]) perPackage.push({ pkg, script });
        }
    }
    if (perPackage.length === 0) {
        console.error("gate-all: no package defines a `check` or `test` script — discovery is broken, refusing to pass.");
        process.exit(1);
    }
    console.log(`gate-all: ${perPackage.length} package script(s) to run, plus cross-cutting checks and the E2E bundle proof.`);

    for (const { pkg, script } of perPackage) {
        runItem(`${pkg.name}: ${script}`, "pnpm", ["--filter", pkg.name, "run", script]);
    }

    runItem("workspace: check-coverage-map", process.execPath, [path.join(repoRoot, "tools", "check-coverage-map.mjs")]);
    runItem("workspace: check-single-cem-facts", process.execPath, [
        path.join(repoRoot, "tools", "check-single-cem-facts.mjs"),
    ]);
    runItem("workspace: check-single-m3e-web-pin", process.execPath, [
        path.join(repoRoot, "tools", "check-single-m3e-web-pin.mjs"),
    ]);
    runItem("workspace: check-bundle-provenance cem-figma-connect", process.execPath, [
        path.join(repoRoot, "tools", "check-bundle-provenance.mjs"),
    ]);
    runItem("workspace: check-bundle-provenance m3e-okf", process.execPath, [
        path.join(repoRoot, "tools", "check-bundle-provenance-m3e-okf.mjs"),
    ]);
    runItem("workspace: check-bundle-provenance tailwind-m3e-web", process.execPath, [
        path.join(repoRoot, "tools", "check-bundle-provenance-tailwind.mjs"),
    ]);
    runItem("workspace: ab-elm-cem (Face A byte-identity)", "bash", [path.join(repoRoot, "tools", "ab-elm-cem.sh")]);
    runItem("workspace: ab-elm-m3e-split (split-step byte-identity)", "bash", [path.join(repoRoot, "tools", "ab-elm-m3e-split.sh")]);

    // Copy fidelity for the migrated elm-m3e: proves no git-tracked source file
    // went missing and no untracked file got committed. This exists because a
    // migration can be entirely green while having silently DROPPED a tracked
    // file — every other check here would still pass. It belongs in the sweep,
    // not in a human's memory.
    runItem("workspace: copy-fidelity elm-m3e", "bash", [path.join(repoRoot, "tools", "copy-fidelity-elm-m3e.sh")]);
    runItem("workspace: copy-fidelity cem-figma-connect", "bash", [
        path.join(repoRoot, "tools", "copy-fidelity-cem-figma-connect.sh"),
    ]);
    runItem("workspace: copy-fidelity m3e-okf", "bash", [path.join(repoRoot, "tools", "copy-fidelity-m3e-okf.sh")]);
    runItem("workspace: copy-fidelity tailwind-m3e-web", "bash", [
        path.join(repoRoot, "tools", "copy-fidelity-tailwind-m3e-web.sh"),
    ]);
    runItem("workspace: check-emit-determinism cem-figma-connect", process.execPath, [
        path.join(repoRoot, "tools", "check-emit-determinism-cfc.mjs"),
    ]);
    runItem("workspace: root gate", process.execPath, [path.join(repoRoot, "tools", "gate.mjs")]);

    factsBundleE2E();

    // ── summary ───────────────────────────────────────────────────────────
    const failed = results.filter((r) => !r.ok);
    const width = Math.max(...results.map((r) => r.name.length));
    console.log(`\n${"═".repeat(72)}\nGATE-ALL SUMMARY\n${"═".repeat(72)}`);
    for (const r of results) {
        console.log(`${r.ok ? "PASS" : "FAIL"}  ${r.name.padEnd(width)}${r.detail ? `  ${r.detail}` : ""}`);
    }
    console.log("─".repeat(72));
    console.log(`${results.length - failed.length}/${results.length} passed, ${failed.length} failed`);

    if (failed.length > 0) {
        console.log("\nFAILED ITEMS:");
        for (const r of failed) console.log(`  - ${r.name}${r.detail ? `  (${r.detail})` : ""}`);
        console.log("\nGATE-ALL RED");
        process.exit(1);
    }
    console.log("\nGATE-ALL GREEN");
}

main();
