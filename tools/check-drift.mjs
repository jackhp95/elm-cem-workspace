#!/usr/bin/env node
// check-drift.mjs — M4.b: the cross-cutting drift gate. Regenerates
// everything from the current facts bundle and requires zero diff against
// committed output, across the producer, the brand, and all three consumers.
//
// Two hazards, both handled explicitly (see the M4 spec for the write-up):
//
//   R-008 — packages/elm-m3e/docs/.elm-pages/Pages.elm is a TRACKED file
//   containing a build timestamp (`builtAt = Time.millisToPosix <epoch-ms>`).
//   Any docs build rewrites it. This gate normalizes that one field out
//   before comparing (tools/lib/check-drift-core.mjs), rather than excluding
//   the whole file or weakening the comparison generally — a real content
//   change in Pages.elm still fails the gate.
//
//   R-010 — elm-m3e's own committed `src/` is KNOWINGLY stale relative to a
//   fresh generation (Phase 0 deliberately did not refresh it: a fresh run
//   emits 143 files, `src/` holds 402). A naive regenerate-and-diff against
//   `src/` would be permanently red for a reason nobody can act on. This
//   gate uses A/B semantics instead (tools/ab-elm-cem.sh: pristine elm-cem
//   vs workspace elm-cem, same elm-m3e config) — immune to that
//   pre-existing staleness because it never compares against the stale
//   committed tree at all. `elm-m3e`'s own `check:cem` keeps `--skip-drift`
//   (unchanged): ab-elm-cem.sh, registered here and in tools/gate-all.mjs,
//   IS the drift proof for Face A at the workspace level.
//
// The three consumer bundle copies (cem-figma-connect, m3e-okf,
// tailwind-m3e-web) carry no such pre-existing staleness — each is kept in
// sync by its own `check-bundle-provenance*.mjs` gate already — so a naive
// regenerate-and-diff is the correct, and simplest, check for them.
//
// M4.b (round 2): the bundle-copy checks above only cover each consumer's
// intake of the facts bundle — they never regenerated a consumer's own
// GENERATED OUTPUT and diffed it against committed. That was a real hole
// (verified by hand: appending a line to
// packages/tailwind-m3e-web/generated/utilities.css left this gate green).
// checkConsumerOutputs() below closes it: each consumer's full pipeline runs
// in a scratch COPY of the package (tools/lib/consumer-output-drift.mjs,
// tools/lib/check-drift-core.mjs's regeneratePackageOutput) — never in
// place — and its output is byte-compared against committed.
//
// Zero dependencies. Exits 0 on success, 1 on any failure.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { generateBundleToTemp } from "./lib/regen.mjs";
import { checkConsumerBundleDrift, comparePagesElmIgnoringTimestamp } from "./lib/check-drift-core.mjs";
import { checkConsumerOutputDrift, consumerOutputDescriptors } from "./lib/consumer-output-drift.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const require = createRequire(import.meta.url);
const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");

const results = [];
function record(name, ok, detail) {
    results.push({ name, ok, detail: detail || "" });
    console.log(`${ok ? "PASS" : "FAIL"}  ${name}${detail ? `  — ${detail}` : ""}`);
}

// ── 1. producer sanity: the generator runs and emits schema-valid, non-empty faces ──
function checkProducer() {
    const name = "check-drift: producer (fresh generate + schema validate)";
    const work = fs.mkdtempSync(path.join(os.tmpdir(), "check-drift-producer-"));
    try {
        let bundleDir;
        try {
            ({ bundleDir } = generateBundleToTemp({ repoRoot, elmM3e: ELM_M3E, workDir: work, streamOutput: false }));
        } catch (e) {
            record(name, false, `generation threw: ${e.message}`);
            return;
        }
        const schemaPath = path.join(repoRoot, "docs", "facts-bundle", "schema.json");
        const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
        const { validate } = require(path.join(repoRoot, "packages", "elm-cem", "bin", "validate-facts-bundle.js"));

        const problems = [];
        for (const { file, definition } of [
            { file: "cem-facts.json", definition: "faceB" },
            { file: "elm-api-facts.json", definition: "faceC" },
        ]) {
            const data = JSON.parse(fs.readFileSync(path.join(bundleDir, file), "utf8"));
            const { valid, errors } = validate(schema, data, definition);
            if (!valid) problems.push(`${file}: ${errors.slice(0, 5).join("; ")}`);
        }
        if (problems.length > 0) record(name, false, problems.join(" | "));
        else record(name, true, "both faces regenerate and validate against schema.json");
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

// ── 2. brand: Face A drift via A/B semantics (R-010) ──
function checkBrand() {
    const name = "check-drift: brand Face A (A/B semantics, R-010)";
    const result = spawnSync("bash", [path.join(repoRoot, "tools", "ab-elm-cem.sh")], {
        cwd: repoRoot,
        encoding: "utf8",
    });
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    record(name, result.status === 0, result.status === 0 ? "" : `ab-elm-cem.sh exited ${result.status}`);
}

// ── 3. consumers: naive regenerate-and-diff (no pre-existing staleness here) ──
function checkConsumers() {
    const consumers = [
        {
            label: "check-drift: cem-figma-connect bundle copy",
            files: [
                { committedPath: path.join(repoRoot, "packages", "cem-figma-connect", "profiles", "m3-kit", "facts", "cem-facts.json"), bundleFile: "cem-facts.json" },
                { committedPath: path.join(repoRoot, "packages", "cem-figma-connect", "profiles", "m3-kit", "facts", "elm-api-facts.json"), bundleFile: "elm-api-facts.json" },
            ],
        },
        {
            label: "check-drift: m3e-okf bundle copy",
            files: [{ committedPath: path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json"), bundleFile: "cem-facts.json" }],
        },
        {
            label: "check-drift: tailwind-m3e-web bundle copy",
            files: [{ committedPath: path.join(repoRoot, "packages", "tailwind-m3e-web", "data", "cem-facts.json"), bundleFile: "cem-facts.json" }],
        },
    ];
    for (const { label, files } of consumers) {
        const { ok, failures } = checkConsumerBundleDrift({ repoRoot, elmM3e: ELM_M3E, label, files });
        record(label, ok, ok ? "byte-identical to a fresh regeneration" : failures.join(" | "));
    }
}

// ── 4. consumers: GENERATED OUTPUT drift (not just the bundle-copy intake) ──
function checkConsumerOutputs() {
    for (const descriptor of consumerOutputDescriptors(repoRoot)) {
        try {
            const { ok, failures } = checkConsumerOutputDrift(descriptor);
            record(descriptor.label, ok, ok ? "byte-identical to a fresh regeneration" : failures.join(" | "));
        } catch (e) {
            record(descriptor.label, false, `regeneration threw: ${e.message}`);
        }
    }
}

// ── 5. R-008: Pages.elm — normalize the build timestamp before comparing ──
function checkPagesElm() {
    const name = "check-drift: Pages.elm (R-008, timestamp-normalized)";
    const relPath = "packages/elm-m3e/docs/.elm-pages/Pages.elm";
    const absPath = path.join(repoRoot, relPath);
    if (!fs.existsSync(absPath)) {
        record(name, false, `${relPath} not found`);
        return;
    }
    const head = spawnSync("git", ["show", `HEAD:${relPath}`], { cwd: repoRoot, encoding: "utf8" });
    if (head.status !== 0) {
        record(name, false, `could not read HEAD copy: ${head.stderr}`);
        return;
    }
    const { ok, onlyTimestampDiffers, detail } = comparePagesElmIgnoringTimestamp(fs.readFileSync(absPath, "utf8"), head.stdout);
    record(name, ok, onlyTimestampDiffers ? `${detail} — treated as clean` : detail);
}

function main() {
    checkProducer();
    checkBrand();
    checkConsumers();
    checkConsumerOutputs();
    checkPagesElm();

    const failed = results.filter((r) => !r.ok);
    console.log(`\n${"═".repeat(72)}\nCHECK-DRIFT SUMMARY\n${"═".repeat(72)}`);
    for (const r of results) console.log(`${r.ok ? "PASS" : "FAIL"}  ${r.name}${r.detail ? `  ${r.detail}` : ""}`);
    console.log(`${results.length - failed.length}/${results.length} passed, ${failed.length} failed`);

    if (failed.length > 0) {
        console.log("\nCHECK-DRIFT RED");
        process.exit(1);
    }
    console.log("\nCHECK-DRIFT GREEN");
}

main();
