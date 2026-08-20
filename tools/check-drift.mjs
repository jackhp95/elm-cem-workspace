#!/usr/bin/env node
// check-drift.mjs — M4.b: the cross-cutting drift gate. Regenerates
// everything from the current facts bundle and requires zero diff against
// committed output, across the producer, the brand, and all three consumers.
//
// Two hazards, both handled explicitly (see the M4 spec for the write-up):
//
//   R-008 — brands/m3e/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm is a TRACKED file
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
// The consumer bundle copies declared in tools/family.json's `bundleCopy`
// blocks (cem-figma-connect, m3e-okf, tailwind-m3e-web) carry no such
// pre-existing staleness — each is kept in sync by checkConsumers() below —
// so a naive regenerate-and-diff is the correct, and simplest, check for them.
//
// M4.b (round 2): the bundle-copy checks above only cover each consumer's
// intake of the facts bundle — they never regenerated a consumer's own
// GENERATED OUTPUT and diffed it against committed. That was a real hole
// (verified by hand: appending a line to
// brands/m3e/generated/style/elm-m3e-tailwind/generated/utilities.css left this gate green).
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
const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "generated", "package", "elm-m3e");
const family = JSON.parse(fs.readFileSync(path.join(repoRoot, "tools", "family.json"), "utf8")).packages;

const results = [];
function record(name, ok, detail) {
    results.push({ name, status: ok ? "pass" : "fail", detail: detail || "" });
    console.log(`${ok ? "PASS" : "FAIL"}  ${name}${detail ? `  — ${detail}` : ""}`);
}
// A SKIP is a check whose external input (an upstream checkout absent from a
// fresh clone) is missing — it must never count as a pass, and under
// REQUIRE_CLONE_GATES=1 (CI that provisions the inputs) it becomes a hard
// fail instead. See tools/lib/snapshot-gate.sh for the sibling pattern.
function recordSkip(name, reason) {
    if (process.env.REQUIRE_CLONE_GATES === "1") {
        record(name, false, `${reason} (REQUIRE_CLONE_GATES=1)`);
        return;
    }
    results.push({ name, status: "skip", detail: reason });
    console.log(`SKIP: ${name} — ${reason}`);
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
        const { validate } = require(path.join(repoRoot, "pipeline", "elm-cem", "bin", "validate-facts-bundle.js"));

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
    // ab-elm-cem.sh skips (exit 0 + a SKIP line) when the pristine snapshot is
    // absent (fresh clone). Record that as a skip, not a pass.
    if (result.status === 0 && /(^|\n)SKIP[:\s]/.test(result.stdout || "")) {
        recordSkip(name, "ab-elm-cem snapshot absent (pristine elm-cem checkout) — Face A drift not verifiable in this clone");
        return;
    }
    record(name, result.status === 0, result.status === 0 ? "" : `ab-elm-cem.sh exited ${result.status}`);
}

// ── 3. consumers: naive regenerate-and-diff (no pre-existing staleness here) ──
// Driven by tools/family.json's `bundleCopy` blocks (Theme 3 "manifest move")
// instead of a hardcoded per-package list — adding a 4th consumer is a data
// change here. Also folds in what the now-retired standalone
// check-bundle-provenance*.mjs scripts uniquely checked (git-trackedness,
// cem-figma-connect's icon-names.json derivation) via checkConsumerBundleDrift.
function checkConsumers() {
    for (const [name, pkg] of Object.entries(family)) {
        if (!pkg.bundleCopy) continue;
        const bc = pkg.bundleCopy;
        const label = `check-drift: ${name} bundle copy`;
        const files = bc.files.map((f) => ({
            committedPath: path.join(repoRoot, pkg.srcDir, bc.dir, f),
            bundleFile: f,
        }));
        const iconNames = bc.iconNamesFile
            ? { committedPath: path.join(repoRoot, pkg.srcDir, bc.dir, bc.iconNamesFile) }
            : undefined;
        const { ok, failures } = checkConsumerBundleDrift({ repoRoot, elmM3e: ELM_M3E, label, files, iconNames });
        record(label, ok, ok ? "byte-identical to a fresh regeneration" : failures.join(" | "));
    }
}

// ── 4. consumers: GENERATED OUTPUT drift (not just the bundle-copy intake) ──
function checkConsumerOutputs() {
    for (const descriptor of consumerOutputDescriptors(repoRoot)) {
        // A descriptor that symlinks in an upstream `.cache` checkout cannot be
        // regenerated in a fresh clone that lacks it (m3e-okf's guidance/OKF
        // outputs derive from .cache/m3e — the matraic/m3e@v2.7.3 checkout,
        // gitignored). Skip-with-reason rather than fail; CI provisions it (or
        // sets REQUIRE_CLONE_GATES=1). See R-020 / R-023.
        if ((descriptor.symlinks || []).includes(".cache") && !fs.existsSync(path.join(descriptor.pkgDir, ".cache", "m3e"))) {
            recordSkip(
                descriptor.label,
                `${path.relative(repoRoot, path.join(descriptor.pkgDir, ".cache", "m3e"))} absent (upstream matraic/m3e@v2.7.3 checkout) — provision it (git clone --branch v2.7.3 https://github.com/matraic/m3e) or set REQUIRE_CLONE_GATES=1 in CI`,
            );
            continue;
        }
        try {
            const { ok, failures } = checkConsumerOutputDrift(descriptor, { repoRoot });
            record(descriptor.label, ok, ok ? "byte-identical to a fresh regeneration" : failures.join(" | "));
        } catch (e) {
            record(descriptor.label, false, `regeneration threw: ${e.message}`);
        }
    }
}

// ── 5. R-008: Pages.elm — normalize the build timestamp before comparing ──
function checkPagesElm() {
    const name = "check-drift: Pages.elm (R-008, timestamp-normalized)";
    const relPath = "brands/m3e/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm";
    const absPath = path.join(repoRoot, relPath);
    const head = spawnSync("git", ["show", `HEAD:${relPath}`], { cwd: repoRoot, encoding: "utf8" });
    if (head.status !== 0) {
        // After the 2026-08-14 re-integration onto elm-m3e main, docs/.elm-pages/
        // is GITIGNORED (untracked build output) — so R-008's tracked-timestamp
        // hazard no longer exists and there is nothing to drift-check. Pass.
        record(name, true, "docs/.elm-pages/ is gitignored build output on current main — R-008 no longer applies");
        return;
    }
    if (!fs.existsSync(absPath)) {
        record(name, false, `${relPath} tracked in HEAD but absent on disk`);
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

    const failed = results.filter((r) => r.status === "fail");
    const skipped = results.filter((r) => r.status === "skip");
    const passed = results.filter((r) => r.status === "pass");
    console.log(`\n${"═".repeat(72)}\nCHECK-DRIFT SUMMARY\n${"═".repeat(72)}`);
    for (const r of results) {
        const label = r.status === "pass" ? "PASS" : r.status === "skip" ? "SKIP" : "FAIL";
        console.log(`${label}  ${r.name}${r.detail ? `  ${r.detail}` : ""}`);
    }
    console.log(`${passed.length}/${results.length} passed, ${skipped.length} skipped, ${failed.length} failed`);

    if (failed.length > 0) {
        console.log("\nCHECK-DRIFT RED");
        process.exit(1);
    }
    // A bare `SKIP:` line (emitted by recordSkip above) is what tools/gate-all.mjs
    // detects to badge this whole item SKIP rather than PASS in a fresh clone.
    console.log("\nCHECK-DRIFT GREEN");
}

main();
