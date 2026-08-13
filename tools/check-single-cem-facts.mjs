#!/usr/bin/env node
// check-single-cem-facts.mjs — M1.d guard: exactly one `Cem.Facts` in the
// workspace graph.
//
// jackhp95/elm-cem-facts (packages/elm-cem/facts) is the sole canonical owner of
// the `Cem.Facts` module (the `Fact`/`Facet` types). Before the Stage-F cutover,
// elm-review-cem kept a byte-synced vendored copy so it could compile as an
// unpublished-dependency-free Elm package; that copy is gone now that
// elm-review-cem declares a real dependency on jackhp95/elm-cem-facts. This
// script is the regression guard: it fails the moment the workspace graph ever
// regains a duplicate, by two independent checks:
//
//   1. Elm-identity check: scan every elm.json under packages/ (excluding
//      node_modules/elm-stuff) and fail if more than one package's
//      `exposed-modules` lists `Cem.Facts`. Two exposers means two distinct
//      published identities for the `Fact` type — even if their source were
//      byte-identical, `elm make` would treat them as unrelated types.
//   2. File-identity check: fail if more than one `Cem/Facts.elm` file exists
//      anywhere under packages/ (excluding node_modules/elm-stuff). This catches
//      a reintroduced vendored copy (or a symlink recreating the path) even
//      before anyone adds it to an elm.json's exposed-modules.
//
// Zero dependencies. Exits 0 on success, 1 on any failure. Prints what it found
// either way.

import { readFileSync, readdirSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const packagesDir = join(repoRoot, "packages");
const SKIP_DIRS = new Set(["node_modules", "elm-stuff", ".git"]);

function walk(dir, onFile) {
    let entries;
    try {
        entries = readdirSync(dir, { withFileTypes: true });
    } catch {
        return;
    }
    for (const entry of entries) {
        if (SKIP_DIRS.has(entry.name)) continue;
        const full = join(dir, entry.name);
        if (entry.isDirectory()) {
            walk(full, onFile);
        } else if (entry.isFile()) {
            onFile(full);
        }
    }
}

function findElmJsonFiles() {
    const results = [];
    walk(packagesDir, (file) => {
        if (file.endsWith("elm.json")) results.push(file);
    });
    return results;
}

function findFactsElmFiles() {
    const results = [];
    walk(packagesDir, (file) => {
        if (file.replace(/\\/g, "/").endsWith("/Cem/Facts.elm")) {
            results.push(file);
        }
    });
    return results;
}

function main() {
    let failed = false;

    // ── 1. exposed-modules identity check ──────────────────────────────────
    const elmJsonFiles = findElmJsonFiles();
    const exposers = [];
    for (const elmJsonPath of elmJsonFiles) {
        let elmJson;
        try {
            elmJson = JSON.parse(readFileSync(elmJsonPath, "utf8"));
        } catch (e) {
            console.error(`check-single-cem-facts: cannot parse ${relative(repoRoot, elmJsonPath)}: ${e.message}`);
            failed = true;
            continue;
        }
        const exposed = elmJson["exposed-modules"];
        const names = Array.isArray(exposed) ? exposed : Object.values(exposed || {}).flat();
        if (names.includes("Cem.Facts")) {
            exposers.push({ path: relative(repoRoot, elmJsonPath), name: elmJson.name || "(unnamed)" });
        }
    }

    console.log(`check-single-cem-facts: scanned ${elmJsonFiles.length} elm.json file(s) under packages/.`);
    console.log(`check-single-cem-facts: ${exposers.length} package(s) expose Cem.Facts:`);
    for (const e of exposers) console.log(`  - ${e.name} (${e.path})`);

    if (exposers.length === 0) {
        console.error("check-single-cem-facts: FAIL — no package exposes Cem.Facts; the canonical owner is missing.");
        failed = true;
    } else if (exposers.length > 1) {
        console.error(
            `check-single-cem-facts: FAIL — ${exposers.length} packages expose Cem.Facts; exactly one owner is required.`,
        );
        failed = true;
    }

    // ── 2. Cem/Facts.elm file-identity check ───────────────────────────────
    const factsFiles = findFactsElmFiles().map((p) => relative(repoRoot, p));
    console.log(`check-single-cem-facts: ${factsFiles.length} Cem/Facts.elm file(s) found under packages/:`);
    for (const f of factsFiles) console.log(`  - ${f}`);

    if (factsFiles.length === 0) {
        console.error("check-single-cem-facts: FAIL — no Cem/Facts.elm file found; the canonical source is missing.");
        failed = true;
    } else if (factsFiles.length > 1) {
        console.error(
            `check-single-cem-facts: FAIL — ${factsFiles.length} Cem/Facts.elm files found; exactly one is required.`,
        );
        failed = true;
    }

    if (failed) {
        process.exit(1);
    }
    console.log("check-single-cem-facts: OK — exactly one Cem.Facts in the workspace graph.");
}

main();
