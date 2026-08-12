#!/usr/bin/env node
// Enumerates the whole family graph: pnpm JS workspace packages and Elm elm.json packages.
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));

function walk(dir, onFile, skipDirs) {
    let entries;
    try {
        entries = readdirSync(dir, { withFileTypes: true });
    } catch {
        return;
    }
    for (const entry of entries) {
        if (skipDirs.has(entry.name)) continue;
        const full = join(dir, entry.name);
        if (entry.isDirectory()) {
            walk(full, onFile, skipDirs);
        } else if (entry.isFile()) {
            onFile(full);
        }
    }
}

function findJsPackages(repoRoot) {
    const packagesDir = join(repoRoot, "packages");
    const results = [];
    const skip = new Set(["node_modules", "elm-stuff", ".git"]);

    let topLevel = [];
    try {
        topLevel = readdirSync(packagesDir, { withFileTypes: true }).filter((e) => e.isDirectory());
    } catch {
        return results;
    }

    for (const top of topLevel) {
        const topDir = join(packagesDir, top.name);
        const candidateDirs = [topDir];
        let nested = [];
        try {
            nested = readdirSync(topDir, { withFileTypes: true }).filter((e) => e.isDirectory());
        } catch {
            nested = [];
        }
        for (const n of nested) {
            if (skip.has(n.name)) continue;
            candidateDirs.push(join(topDir, n.name));
        }

        for (const dir of candidateDirs) {
            const pkgJsonPath = join(dir, "package.json");
            try {
                const stat = statSync(pkgJsonPath);
                if (!stat.isFile()) continue;
            } catch {
                continue;
            }
            const pkg = JSON.parse(readFileSync(pkgJsonPath, "utf8"));
            results.push({
                dir: relative(repoRoot, dir) || ".",
                name: pkg.name ?? "(unnamed)",
                scripts: pkg.scripts ?? {},
            });
        }
    }

    return results;
}

function findElmPackages(repoRoot) {
    const packagesDir = join(repoRoot, "packages");
    const results = [];
    const skip = new Set(["node_modules", "elm-stuff", ".git"]);

    walk(
        packagesDir,
        (file) => {
            if (file.endsWith("elm.json")) {
                const dir = relative(repoRoot, dirname(file));
                const elmJson = JSON.parse(readFileSync(file, "utf8"));
                if (elmJson.type === "package") {
                    results.push({ dir, type: "package", name: elmJson.name });
                } else {
                    results.push({ dir, type: "application", name: null });
                }
            }
        },
        skip,
    );

    return results;
}

function main() {
    const jsPackages = findJsPackages(repoRoot);
    const elmPackages = findElmPackages(repoRoot);

    console.log("== JS workspace packages (pnpm) ==");
    if (jsPackages.length === 0) {
        console.log("  (none)");
    } else {
        for (const pkg of jsPackages) {
            console.log(`  ${pkg.dir}  [${pkg.name}]`);
            const scriptNames = Object.keys(pkg.scripts);
            if (scriptNames.length === 0) {
                console.log("    scripts: (none)");
            } else {
                for (const scriptName of scriptNames) {
                    console.log(`    script: ${scriptName} -> ${pkg.scripts[scriptName]}`);
                }
            }
        }
    }

    console.log("");
    console.log("== Elm packages (elm.json) ==");
    if (elmPackages.length === 0) {
        console.log("  (none)");
    } else {
        for (const pkg of elmPackages) {
            if (pkg.type === "package") {
                console.log(`  ${pkg.dir}  [package: ${pkg.name}]`);
            } else {
                console.log(`  ${pkg.dir}  [application]`);
            }
        }
    }
}

main();
