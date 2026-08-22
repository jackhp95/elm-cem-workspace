#!/usr/bin/env node
// tools/check-package-dag.mjs — assert the DAG-rework's LINEAR package DAG is
// materialized and can never silently regress to the old parallel-siblings
// shape (P1-P5 of docs/plans/2026-08-21-dag-rework-plan.md).
//
// The rework's whole point is that Builders chain THROUGH Components instead of
// hanging off Elements as a parallel sibling. This gate encodes that as three
// independent, discriminating assertions, checked per brand:
//
//   (A) DEP EDGE (split brands only): the Build package's emitted elm.json
//       declares the Components package (`<owner>/<brand>-components`) — Build
//       consumes Components. On a MONOLITH brand (shoelace) Build/Components/
//       Elements all live in one package, so there is no inter-package edge to
//       assert; the import checks (C) carry the DAG proof there.
//   (B) NO CYCLE (split brands only): the Components package's elm.json does
//       NOT declare the Build package — Components never depends on Build. This
//       is the anti-cycle assertion that keeps the DAG a DAG.
//   (C) NO ELEMENT SHORTCUT (all brands): no `<Ns>.Build.*` module imports
//       `<Ns>.Element.*` directly. Every element access from a builder must
//       route through the Component facade (`<Ns>.Component.*`). This is the
//       assertion that discriminates the NEW shape from the OLD one at the
//       source level — under the old shape every builder hard-imported
//       `import <Ns>.Element.<X> as Component` (Component.elm:1691), so this
//       check went from 130 Element-importing Build modules (OLD) to 0 (NEW).
//
// Exit 0 iff every asserted brand satisfies all applicable conditions.
//
// This lives ALONGSIDE tools/check-m3e-5pkg.mjs (which asserts the packages.json
// SHAPE of the m3e split) — this one asserts the DAG EDGES + the import-level
// no-Element-shortcut, brand-agnostically, and additionally covers the monolith
// shoelace brand that check-m3e-5pkg does not look at.
import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

// Each brand: the generated package root, the module namespace prefix (`Ns`),
// and — for SPLIT brands — the split package dir names. A MONOLITH brand omits
// `split` (single package; only the import check (C) applies).
const BRANDS = [
    {
        brand: "m3e",
        ns: "M3e",
        owner: "jackhp95",
        packageRoot: path.join(repoRoot, "brands", "m3e", "generated", "package"),
        split: {
            build: "elm-m3e-build",
            components: "elm-m3e-components",
            elements: "elm-m3e-elements",
        },
    },
    {
        brand: "shoelace",
        ns: "Sl",
        owner: "jackhp95",
        packageRoot: path.join(repoRoot, "brands", "shoelace", "generated", "package"),
        // monolith — no `split`; the single package is elm-shoelace.
        monolith: "elm-shoelace",
    },
];

const problems = [];
const notes = [];

function elmJsonDeps(dir) {
    const p = path.join(dir, "elm.json");
    if (!existsSync(p)) return null;
    return JSON.parse(readFileSync(p, "utf8")).dependencies || {};
}

// Recursively collect every .elm file under a directory whose module namespace
// starts with `<Ns>.Build`. We locate by directory (…/src/<Ns>/Build) so the
// check is robust to per-family vs per-element module naming.
function buildElmFiles(srcRoot, ns) {
    const buildDir = path.join(srcRoot, ...ns.split("."), "Build");
    if (!existsSync(buildDir)) return [];
    const out = [];
    const walk = (dir) => {
        for (const entry of readdirSync(dir, { withFileTypes: true })) {
            const full = path.join(dir, entry.name);
            if (entry.isDirectory()) walk(full);
            else if (entry.isFile() && entry.name.endsWith(".elm")) out.push(full);
        }
    };
    walk(buildDir);
    // Also count the top-level barrel `<Ns>/Build.elm` if present.
    const barrel = path.join(srcRoot, ...ns.split("."), "Build.elm");
    if (existsSync(barrel) && statSync(barrel).isFile()) out.push(barrel);
    return out;
}

// Does this Build source file import `<Ns>.Element.*` directly?  Matches the
// canonical Elm import syntax `import <Ns>.Element` (with or without an `as`
// alias / `exposing`), anchored to the start of a line.
function importsElement(file, ns) {
    const src = readFileSync(file, "utf8");
    const re = new RegExp(`^import\\s+${ns.replace(/\./g, "\\.")}\\.Element(\\.|\\s|$)`, "m");
    return re.test(src);
}

function firstSrcRoot(pkgDir) {
    // elm.json source-directories, or the conventional src/.
    const ej = path.join(pkgDir, "elm.json");
    if (existsSync(ej)) {
        const dirs = JSON.parse(readFileSync(ej, "utf8"))["source-directories"];
        if (Array.isArray(dirs) && dirs.length) return path.resolve(pkgDir, dirs[0]);
    }
    return path.join(pkgDir, "src");
}

for (const b of BRANDS) {
    if (!existsSync(b.packageRoot)) {
        notes.push(`${b.brand}: no generated package tree at ${path.relative(repoRoot, b.packageRoot)} — skipped`);
        continue;
    }

    if (b.split) {
        const buildDir = path.join(b.packageRoot, b.split.build);
        const compsDir = path.join(b.packageRoot, b.split.components);
        const componentsPkg = `${b.owner}/${b.brand === "m3e" ? "elm-m3e-components" : `${b.split.components}`}`;
        const buildPkg = `${b.owner}/${b.split.build}`;
        const elementsPkg = `${b.owner}/${b.split.elements}`;

        // (A) Build declares Components.
        const buildDeps = elmJsonDeps(buildDir);
        if (buildDeps === null) {
            problems.push(`${b.brand}: cannot read ${b.split.build}/elm.json — Build must be a generated package`);
        } else {
            if (!(componentsPkg in buildDeps))
                problems.push(`${b.brand}: ${b.split.build}/elm.json must declare ${componentsPkg} (Build consumes Components — the linear DAG)`);
            if (elementsPkg in buildDeps)
                problems.push(
                    `${b.brand}: ${b.split.build}/elm.json must NOT declare ${elementsPkg} directly — Build reaches Elements through Components (no parallel-siblings shape)`,
                );
        }

        // (B) Components does NOT declare Build (no cycle).
        const compsDeps = elmJsonDeps(compsDir);
        if (compsDeps === null) {
            problems.push(`${b.brand}: cannot read ${b.split.components}/elm.json`);
        } else if (buildPkg in compsDeps) {
            problems.push(`${b.brand}: ${b.split.components}/elm.json declares ${buildPkg} — that is a CYCLE (Components must never depend on Build)`);
        }
    }

    // (C) No Build module imports Element directly — every asserted brand.
    // On a split brand the Build package holds the modules; on a monolith it is
    // the single package.
    const pkgWithBuild = b.split
        ? path.join(b.packageRoot, b.split.build)
        : path.join(b.packageRoot, b.monolith);
    const srcRoot = firstSrcRoot(pkgWithBuild);
    const files = buildElmFiles(srcRoot, b.ns);
    if (files.length === 0) {
        // A brand with no Build tier at all (svg/html) legitimately has zero —
        // but the brands we assert here (m3e, shoelace) DO have one, so zero is
        // suspicious. Flag it rather than pass vacuously.
        problems.push(`${b.brand}: found ZERO ${b.ns}.Build.* modules under ${path.relative(repoRoot, srcRoot)} — the import check would pass vacuously; expected a real Build tier`);
        continue;
    }
    const offenders = files.filter((f) => importsElement(f, b.ns)).map((f) => path.relative(repoRoot, f));
    if (offenders.length) {
        problems.push(
            `${b.brand}: ${offenders.length} ${b.ns}.Build.* module(s) import ${b.ns}.Element.* directly (must route through ${b.ns}.Component.*):\n      ` +
                offenders.slice(0, 8).join("\n      ") +
                (offenders.length > 8 ? `\n      … (+${offenders.length - 8} more)` : ""),
        );
    } else {
        notes.push(`${b.brand}: ${files.length} ${b.ns}.Build.* module(s), 0 import ${b.ns}.Element.* (all route through ${b.ns}.Component.*)`);
    }
}

if (problems.length) {
    console.error("check-package-dag: the linear Build→Components→Elements→Core DAG is NOT intact:\n  " + problems.join("\n  "));
    process.exit(1);
}
for (const n of notes) console.log("  " + n);
console.log("check-package-dag: OK — Build consumes Components (no Elements dep, no Components→Build cycle) and no Build module imports Elements directly. Linear DAG intact.");
