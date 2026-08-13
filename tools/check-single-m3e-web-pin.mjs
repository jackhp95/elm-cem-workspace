#!/usr/bin/env node
// check-single-m3e-web-pin.mjs — workspace guard: exactly one `@m3e/web`
// version, declared as an exact pin, anywhere in this pnpm workspace.
//
// This whole project exists to end vendored-copy drift between a producer
// (elm-cem/elm-m3e) and a consumer that renders/generates against its
// output (cem-figma-connect). Two different `@m3e/web` pins in one
// workspace recreates exactly that drift: a consumer could read a facts
// bundle generated from one version while installing and rendering another.
//
// SCOPE: "the workspace" means the pnpm workspace this repo's root
// pnpm-workspace.yaml defines — discovered via `pnpm ls -r --depth -1
// --json`, the same mechanism tools/gate-all.mjs uses to enumerate
// packages, plus the workspace root itself. This deliberately excludes
// directories that are NOT part of this pnpm workspace even though they sit
// under packages/, notably:
//   - research/spikes/*/package.json — each spike is its OWN nested pnpm
//     workspace (own pnpm-lock.yaml + pnpm-workspace.yaml), historical and
//     already pinned/resolved independently of this workspace's lockfile.
//   - test/fixtures/**/package.json — static test data (e.g. a vendored
//     @m3e/web 2.5.14 manifest fixture) that is never `pnpm install`-ed;
//     its "name"/"version" fields describe the fixture's own identity, not
//     a live dependency declaration in this workspace's lockfile.
// Both are deliberately-pinned-elsewhere data, not the shared install this
// invariant protects.
//
// Zero dependencies. Exits 0 on success, 1 on any failure. Prints every
// `@m3e/web` declaration found either way.

import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const rel = (p) => relative(repoRoot, p).replace(/\\/g, "/");

const DEP_FIELDS = ["dependencies", "devDependencies", "peerDependencies", "optionalDependencies"];

// An acceptable pin is an exact semver, nothing else: no `^`, `~`, `*`, `x`,
// `>`, `<`, `=`, ` - ` ranges, `||`, `workspace:`, `latest`, `next`, etc.
const EXACT_VERSION = /^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$/;

function discoverWorkspaceDirs() {
    const listed = spawnSync("pnpm", ["ls", "-r", "--depth", "-1", "--json"], {
        cwd: repoRoot,
        encoding: "utf8",
    });
    if (listed.status !== 0 || !listed.stdout) {
        console.error("check-single-m3e-web-pin: `pnpm ls -r --depth -1 --json` failed; cannot enumerate the workspace.");
        console.error(listed.stderr || "");
        process.exit(1);
    }
    let parsed;
    try {
        parsed = JSON.parse(listed.stdout);
    } catch (e) {
        console.error(`check-single-m3e-web-pin: could not parse \`pnpm ls\` output: ${e.message}`);
        process.exit(1);
    }
    return parsed.map((p) => p.path);
}

function main() {
    const dirs = discoverWorkspaceDirs();
    console.log(`check-single-m3e-web-pin: scanning ${dirs.length} pnpm workspace package.json file(s).`);

    /** @type {{file: string, field: string, value: string}[]} */
    const declarations = [];

    for (const dir of dirs) {
        const pkgPath = join(dir, "package.json");
        let pkg;
        try {
            pkg = JSON.parse(readFileSync(pkgPath, "utf8"));
        } catch (e) {
            console.error(`check-single-m3e-web-pin: cannot read/parse ${rel(pkgPath)}: ${e.message}`);
            process.exit(1);
        }
        for (const field of DEP_FIELDS) {
            const value = pkg[field]?.["@m3e/web"];
            if (value) declarations.push({ file: rel(pkgPath), field, value });
        }
    }

    console.log(`check-single-m3e-web-pin: ${declarations.length} @m3e/web declaration(s) found:`);
    for (const d of declarations) console.log(`  - ${d.file}  (${d.field})  =  ${d.value}`);

    const failures = [];

    for (const d of declarations) {
        if (!EXACT_VERSION.test(d.value)) {
            failures.push(`${d.file} (${d.field}) declares "${d.value}", which is a RANGE, not an exact version.`);
        }
    }

    const distinctVersions = new Set(declarations.map((d) => d.value));
    if (distinctVersions.size > 1) {
        failures.push(
            `${distinctVersions.size} distinct @m3e/web versions declared in one workspace: ${[...distinctVersions].join(", ")}. ` +
                `Unify on exactly one version.`,
        );
    }

    if (declarations.length === 0) {
        failures.push("no @m3e/web declaration found anywhere in the workspace — expected at least one.");
    }

    if (failures.length > 0) {
        console.error(`\ncheck-single-m3e-web-pin: FAIL — ${failures.length} problem(s):`);
        for (const f of failures) console.error(`  - ${f}`);
        process.exit(1);
    }

    console.log(
        `\ncheck-single-m3e-web-pin: OK — exactly one @m3e/web version (${[...distinctVersions][0]}), exactly pinned, across the workspace.`,
    );
}

main();
