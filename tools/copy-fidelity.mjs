#!/usr/bin/env node
// copy-fidelity.mjs — ONE generic copy-fidelity gate, driven by tools/family.json's
// `copyFidelity` block per package. Replaces the four hand-duplicated
// tools/copy-fidelity-{cem-figma-connect,elm-m3e,m3e-okf,tailwind-m3e-web}.sh
// scripts (822 lines total, already diverged — AUTHORIZED_ABSENT_PREFIX existed
// in only 2 of 4). Fixes Theme 3 of
// docs/reviews/2026-08-17-thermonuclear-workspace-review.md ("the manifest move").
//
// Each package was flat-copied from its own standalone repo into this
// workspace. This gate proves the copy is FAITHFUL modulo an explicit, reasoned
// allowlist of authorized deletions/additions (docs/copy-fidelity-notes.md has
// the "why" per path) — not that any rewiring on top of the copy is correct.
//
// COMPARISON SEMANTICS: both sides are compared as GIT-TRACKED SETS, not
// directory listings. The workspace side = files git tracks under the
// package's srcDir, PLUS untracked files git would track (i.e. not covered by
// .gitignore). Locally-generated build output is gitignored and therefore
// correctly invisible here — comparing raw directory contents would flag
// legitimate build artifacts.
//
// Usage:
//   node tools/copy-fidelity.mjs <name>              # one package
//   node tools/copy-fidelity.mjs --all                # every package with a copyFidelity block
//
// Env (per package, see tools/family.json's copyFidelity.sourceEnvVar):
//   <sourceEnvVar>      path to the source checkout (default: computed below)
//   SNAPSHOT_ROOT       parent directory of the inert pre-migration snapshot
//                        checkouts (default: the workspace's parent directory)
//   REQUIRE_SNAPSHOT_GATES=1  make a missing source checkout a hard failure
//                        instead of a SKIP
//
// Zero dependencies (plain Node ESM).

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const family = JSON.parse(fs.readFileSync(path.join(repoRoot, "tools", "family.json"), "utf8")).packages;

function gitLsFiles(dir, args = []) {
    return execFileSync("git", ["-C", dir, "ls-files", ...args], { encoding: "utf8" })
        .trim()
        .split("\n")
        .filter(Boolean);
}

function stripPrefixes(paths, prefixes) {
    if (!prefixes || prefixes.length === 0) return paths;
    return paths.filter((p) => !prefixes.some((prefix) => p.startsWith(prefix)));
}

function matchesAnyPrefix(p, prefixes) {
    return (prefixes || []).some((prefix) => p.startsWith(prefix));
}

/** @returns {"ok"|"skip"|null} null means "proceed for real", others mean "stop here, this is the verdict" */
function requireSourceOrSkip(name, sourceDir, envVar) {
    if (fs.existsSync(sourceDir)) return null;
    if (process.env.REQUIRE_SNAPSHOT_GATES === "1") {
        console.error(`ERROR: copy-fidelity ${name}: snapshot not found at ${sourceDir} (override with $${envVar}).`);
        console.error(`ERROR: REQUIRE_SNAPSHOT_GATES=1 is set, so a missing snapshot is a hard failure.`);
        return "fail";
    }
    console.log(`SKIP: copy-fidelity ${name} — snapshot directory not found at ${sourceDir}`);
    console.log(`SKIP: override the path with $${envVar}, or set $SNAPSHOT_ROOT to the directory that contains it`);
    console.log(`SKIP: this is an inert pre-migration snapshot checkout, not part of this repository — it is expected to be absent on any machine other than the one that ran the migration`);
    console.log(`SKIP: set REQUIRE_SNAPSHOT_GATES=1 to make an absent snapshot a hard failure instead`);
    return "skip";
}

function runOne(name) {
    const pkg = family[name];
    if (!pkg) {
        console.error(`copy-fidelity: unknown package "${name}". Known: ${Object.keys(family).join(", ")}`);
        return 1;
    }
    const cf = pkg.copyFidelity;
    if (!cf) {
        console.error(`copy-fidelity: ${name} has no copyFidelity block in tools/family.json — nothing to check.`);
        return 1;
    }

    const pkgRel = pkg.srcDir;
    const snapshotRoot = process.env.SNAPSHOT_ROOT || path.join(repoRoot, "..");
    const defaultSource = cf.sourceDefaultRelToRepoRoot
        ? path.join(repoRoot, cf.sourceDefaultRelToRepoRoot)
        : path.join(snapshotRoot, name);
    const sourceDir = process.env[cf.sourceEnvVar] || defaultSource;
    const pkgAbs = path.join(repoRoot, pkgRel);

    const verdict = requireSourceOrSkip(name, sourceDir, cf.sourceEnvVar);
    if (verdict === "skip") return 0;
    if (verdict === "fail") return 1;

    if (!fs.existsSync(pkgAbs)) {
        console.error(`ERROR: workspace copy not found at ${pkgAbs}`);
        return 1;
    }

    let sourceFiles = gitLsFiles(sourceDir).sort();
    sourceFiles = stripPrefixes(sourceFiles, cf.sourceFilterExcludePrefixes);

    const trackedRel = gitLsFiles(repoRoot, ["--", pkgRel]);
    const untrackedRel = gitLsFiles(repoRoot, ["--others", "--exclude-standard", "--", pkgRel]);
    let workspaceFiles = [...new Set([...trackedRel, ...untrackedRel])]
        .filter((p) => fs.existsSync(path.join(repoRoot, p)))
        .map((p) => path.relative(pkgRel, p))
        .sort();
    workspaceFiles = stripPrefixes(workspaceFiles, cf.sourceFilterExcludePrefixes);

    const sourceSet = new Set(sourceFiles);
    const workspaceSet = new Set(workspaceFiles);
    const authorizedAbsent = new Set([...(cf.authorizedAbsent || []), ...(cf.authorizedAbsentM6 || [])]);
    const authorizedExtra = new Set(cf.authorizedExtra || []);

    const missing = sourceFiles.filter(
        (p) => !workspaceSet.has(p) && !authorizedAbsent.has(p) && !matchesAnyPrefix(p, cf.authorizedAbsentPrefixes),
    );
    const extra = workspaceFiles.filter(
        (p) => !sourceSet.has(p) && !authorizedExtra.has(p) && !matchesAnyPrefix(p, cf.authorizedExtraPrefixes),
    );

    console.log(`copy-fidelity ${name}: source tracked=${sourceFiles.length}  workspace tracked+addable=${workspaceFiles.length}`);
    console.log(`copy-fidelity ${name}: authorized-absent=${authorizedAbsent.size}  authorized-extra=${authorizedExtra.size}`);

    let status = 0;
    if (missing.length > 0) {
        console.error(`\nMISSING — git-tracked in the source repo but absent from the workspace copy:`);
        for (const p of missing) console.error(`  ${p}`);
        status = 1;
    }
    if (extra.length > 0) {
        console.error(`\nEXTRA — tracked/addable in the workspace but NOT git-tracked in the source repo:`);
        for (const p of extra) console.error(`  ${p}`);
        console.error(`\n(If one of these is a deliberate migration addition, add it to tools/family.json's`);
        console.error(` "${name}".copyFidelity.authorizedExtra (with a reason in docs/copy-fidelity-notes.md)`);
        console.error(` — do not silence this gate wholesale.)`);
        status = 1;
    }

    if (status !== 0) {
        console.error(`\nCOPY-FIDELITY RED (${name}) — ${missing.length} missing, ${extra.length} extra`);
    } else {
        console.log(`\nCOPY-FIDELITY GREEN (${name}) — every tracked source file present or authorized-absent, no unauthorized extra file`);
    }
    return status;
}

function main() {
    const argv = process.argv.slice(2);
    const names = argv.includes("--all")
        ? Object.keys(family).filter((n) => family[n].copyFidelity)
        : argv.filter((a) => !a.startsWith("--"));

    if (names.length === 0) {
        console.error(`Usage: node tools/copy-fidelity.mjs <name> [<name> ...] | --all`);
        console.error(`Known (with a copyFidelity block): ${Object.keys(family).filter((n) => family[n].copyFidelity).join(", ")}`);
        process.exit(1);
    }

    let status = 0;
    for (const name of names) {
        const code = runOne(name);
        if (code !== 0) status = code;
    }
    process.exit(status);
}

if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}
