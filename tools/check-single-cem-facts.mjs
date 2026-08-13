#!/usr/bin/env node
// check-single-cem-facts.mjs — workspace guard: exactly one `Cem.Facts` in any
// compiled dependency graph.
//
// jackhp95/elm-cem-facts (packages/elm-cem/facts) is the sole canonical OWNER of
// the `Cem.Facts` module (the `Fact`/`Facet` types). Before the Stage-F cutover,
// elm-review-cem kept a byte-synced vendored copy so it could compile as an
// unpublished-dependency-free Elm package; that copy is gone now that
// elm-review-cem declares a real dependency on jackhp95/elm-cem-facts. This
// script is the regression guard against that duplicate ever coming back.
//
// ── What the invariant actually is ────────────────────────────────────────────
// The thing that must never happen is TWO `Cem.Facts` modules in ONE compiled
// graph. That breaks in two ways:
//   * `elm make` refuses to compile: the same module name is defined in two
//     files reachable from one elm.json (a consumer's `review/` config is the
//     usual victim — it stitches several `src/` trees together via
//     `source-directories`);
//   * even when the sources are byte-identical, two PUBLISHED packages exposing
//     `Cem.Facts` mint two distinct identities for the `Fact` type, so values
//     cannot cross between them.
//
// An earlier version of this script approximated that invariant with a blunt
// rule: "at most one `Cem/Facts.elm` FILE anywhere under packages/". That rule
// is WRONG in one direction — it condemns files that are provably not in any
// published graph. It cost us `packages/elm-m3e/editor/stub/Cem/Facts.elm`, a
// git-tracked, deliberately-designed, editor-only stub (see
// packages/elm-m3e/editor/README.md) that exists so Elm LSP can type-check
// elm-m3e's generated `src/` without resolving the real facts package. Deleting
// a legitimate tracked file to satisfy a checker is never the right repair; the
// checker's rule gets narrowed instead. That is what this file now does.
//
// ── The three checks ─────────────────────────────────────────────────────────
//
//   1. OWNERSHIP (unchanged, and non-negotiable). Scan every elm.json under
//      packages/ (skipping node_modules/elm-stuff). Exactly ONE elm.json with
//      `"type": "package"` may list `Cem.Facts` in `exposed-modules`. Zero is
//      also a failure — the canonical owner going missing is just as bad as a
//      second one appearing. The winner of this check is the CANONICAL OWNER and
//      every rule below is expressed relative to it; nothing is hardcoded.
//
//   2. PER-GRAPH AMBIGUITY. For every elm.json, resolve the module roots it
//      actually compiles from — its `source-directories` for an application, the
//      implicit `src/` for a package — and count how many DISTINCT
//      `Cem/Facts.elm` files sit at `<root>/Cem/Facts.elm`. Add one if that
//      elm.json also depends (direct or indirect) on the canonical owner
//      package, because that dependency drags in a `Cem.Facts` of its own. More
//      than one => FAIL: that is literally the elm-make module clash, detected
//      per graph rather than guessed at globally.
//
//   3. PER-FILE PROVENANCE. Every `Cem/Facts.elm` file under packages/ must fall
//      into exactly one of two legitimate categories:
//
//        (a) the CANONICAL file — it lives in the canonical owner package's
//            published source tree; or
//        (b) an EDITOR-ONLY STUB — it is reachable ONLY from elm.json files of
//            `"type": "application"`. Applications are never published and are
//            never a dependency of anything, so a module in one cannot leak into
//            another graph. Check 2 has already proven that no such application
//            also reaches the canonical file or depends on the owner package.
//
//      Anything else FAILS, specifically:
//        * a file inside ANY package's published source tree other than the
//          canonical owner's — this is the re-vendored copy the old rule was
//          built to catch (e.g. packages/elm-review-cem/src/Cem/Facts.elm), and
//          it still fails here, because a package's `src/` IS the published
//          graph;
//        * an ORPHAN file, reachable from no elm.json at all — dead code today
//          and a landmine the moment someone adds its directory to a
//          `source-directories` list.
//
// Why (b) is safe and not a loophole: legitimacy is decided by REACHABILITY, not
// by the file's name or path. There is no way to spell a path that turns a
// package `src/` tree into an application, and adding the stub's directory to a
// graph that also resolves the real facts package trips check 2. The stub is
// permitted precisely because it is unreachable from anything publishable.
//
// Zero dependencies. Exits 0 on success, 1 on any failure. Prints what it found
// either way.

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const packagesDir = join(repoRoot, "packages");
const SKIP_DIRS = new Set(["node_modules", "elm-stuff", ".git"]);
const MODULE_PATH = join("Cem", "Facts.elm");

const rel = (p) => relative(repoRoot, p).replace(/\\/g, "/");

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
        if (entry.isDirectory()) walk(full, onFile);
        else if (entry.isFile()) onFile(full);
    }
}

/** Every elm.json under packages/, parsed, with its compile roots resolved. */
function readProjects() {
    const paths = [];
    walk(packagesDir, (file) => {
        if (file.endsWith("elm.json")) paths.push(file);
    });
    paths.sort();

    const projects = [];
    const parseErrors = [];
    for (const path of paths) {
        let json;
        try {
            json = JSON.parse(readFileSync(path, "utf8"));
        } catch (e) {
            parseErrors.push(`${rel(path)}: ${e.message}`);
            continue;
        }
        const dir = dirname(path);
        const type = json.type === "package" ? "package" : "application";
        // An Elm package has no `source-directories`; its published tree is `src/`.
        const roots = (type === "package" ? ["src"] : json["source-directories"] || []).map((d) => resolve(dir, d));
        const exposedRaw = json["exposed-modules"];
        const exposed = Array.isArray(exposedRaw) ? exposedRaw : Object.values(exposedRaw || {}).flat();
        const deps = new Set([
            ...Object.keys(json.dependencies?.direct || {}),
            ...Object.keys(json.dependencies?.indirect || {}),
            // A package's `dependencies` is a flat name -> range map.
            ...(json.dependencies && !json.dependencies.direct ? Object.keys(json.dependencies) : []),
        ]);
        projects.push({ path, dir, type, roots, exposed, deps, name: json.name || null });
    }
    return { projects, parseErrors };
}

/** Every Cem/Facts.elm file under packages/, as a real (symlink-free) path. */
function findFactsFiles() {
    const files = [];
    walk(packagesDir, (file) => {
        if (file.replace(/\\/g, "/").endsWith("/Cem/Facts.elm")) files.push(file);
    });
    return files.sort();
}

/** The Cem/Facts.elm files a project's compile roots actually resolve. */
function factsReachableFrom(project) {
    const hits = new Set();
    for (const root of project.roots) {
        const candidate = join(root, MODULE_PATH);
        try {
            if (existsSync(candidate) && statSync(candidate).isFile()) hits.add(candidate);
        } catch {
            /* unreadable root — nothing resolvable there */
        }
    }
    return [...hits];
}

function main() {
    const failures = [];
    const { projects, parseErrors } = readProjects();
    for (const e of parseErrors) failures.push(`cannot parse ${e}`);

    console.log(`check-single-cem-facts: scanned ${projects.length} elm.json file(s) under packages/.`);

    // ── 1. ownership ─────────────────────────────────────────────────────────
    const exposers = projects.filter((p) => p.type === "package" && p.exposed.includes("Cem.Facts"));
    console.log(`check-single-cem-facts: ${exposers.length} Elm package(s) expose Cem.Facts in exposed-modules:`);
    for (const p of exposers) console.log(`  - ${p.name || "(unnamed)"} (${rel(p.path)})`);

    if (exposers.length === 0) {
        failures.push("no Elm package exposes Cem.Facts — the canonical owner is missing.");
    } else if (exposers.length > 1) {
        failures.push(
            `${exposers.length} Elm packages expose Cem.Facts (${exposers
                .map((p) => p.name || rel(p.path))
                .join(", ")}); exactly one owner is required.`,
        );
    }
    const owner = exposers.length === 1 ? exposers[0] : null;

    // ── 2. per-graph ambiguity ───────────────────────────────────────────────
    const factsFiles = findFactsFiles();
    console.log(`check-single-cem-facts: ${factsFiles.length} Cem/Facts.elm file(s) present under packages/:`);
    for (const f of factsFiles) console.log(`  - ${rel(f)}`);

    if (factsFiles.length === 0) {
        failures.push("no Cem/Facts.elm file found; the canonical source is missing.");
    }

    /** file -> the projects whose compile roots resolve it */
    const reachedBy = new Map(factsFiles.map((f) => [f, []]));
    let clashes = 0;
    for (const project of projects) {
        const hits = factsReachableFrom(project);
        for (const hit of hits) {
            if (!reachedBy.has(hit)) reachedBy.set(hit, []);
            reachedBy.get(hit).push(project);
        }
        // A dependency on the owner package brings its own Cem.Facts into the graph.
        const dependsOnOwner = owner && owner.name && project !== owner && project.deps.has(owner.name);
        const total = hits.length + (dependsOnOwner ? 1 : 0);
        if (total > 1) {
            const sources = [
                ...hits.map((h) => rel(h)),
                ...(dependsOnOwner ? [`dependency on ${owner.name}`] : []),
            ];
            clashes += 1;
            failures.push(
                `${rel(project.path)} (${project.type}) resolves ${total} Cem.Facts in ONE graph — ` +
                    `elm make would report a module-name clash. Sources: ${sources.join(", ")}`,
            );
        }
    }
    if (clashes === 0) console.log("check-single-cem-facts: no elm.json resolves more than one Cem.Facts.");
    else console.log(`check-single-cem-facts: ${clashes} elm.json graph(s) resolve more than one Cem.Facts (see below).`);

    // ── 3. per-file provenance ───────────────────────────────────────────────
    for (const file of factsFiles) {
        const reachers = reachedBy.get(file) || [];
        const packageReachers = reachers.filter((p) => p.type === "package");
        const appReachers = reachers.filter((p) => p.type === "application");

        if (owner && packageReachers.includes(owner)) {
            const others = packageReachers.filter((p) => p !== owner);
            if (others.length > 0) {
                failures.push(
                    `${rel(file)} is also inside the published src/ of ${others.map((p) => p.name || rel(p.path)).join(", ")}.`,
                );
            } else {
                console.log(`check-single-cem-facts: ${rel(file)} — CANONICAL (published by ${owner.name}).`);
            }
            continue;
        }

        if (packageReachers.length > 0) {
            failures.push(
                `${rel(file)} sits in the published source tree of Elm package(s) ` +
                    `${packageReachers.map((p) => p.name || rel(p.path)).join(", ")}, which is not the canonical owner ` +
                    `(${owner ? owner.name : "none"}). A re-vendored Cem.Facts in a package's src/ mints a second ` +
                    `published identity for the Fact type — remove it and depend on the canonical package instead.`,
            );
            continue;
        }

        if (appReachers.length === 0) {
            failures.push(
                `${rel(file)} is an ORPHAN — no elm.json under packages/ compiles it. Dead code today, and a ` +
                    `module clash the moment its directory joins a source-directories list. Delete it, or put it in ` +
                    `an application's source-directories on purpose.`,
            );
            continue;
        }

        console.log(
            `check-single-cem-facts: ${rel(file)} — editor-only stub, reachable only from application(s) ` +
                `${appReachers.map((p) => rel(p.path)).join(", ")}; never part of a published graph.`,
        );
    }

    if (failures.length > 0) {
        console.error(`\ncheck-single-cem-facts: FAIL — ${failures.length} problem(s):`);
        for (const f of failures) console.error(`  - ${f}`);
        process.exit(1);
    }
    console.log("\ncheck-single-cem-facts: OK — exactly one Cem.Facts in every compiled graph.");
}

main();
