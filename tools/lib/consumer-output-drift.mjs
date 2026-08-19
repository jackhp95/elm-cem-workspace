// consumer-output-drift.mjs — M4.b (round 2): the single, shared definition
// of "what pipeline each consumer runs to produce its GENERATED OUTPUT, and
// which paths of that output must match a fresh regeneration". Used by both
// tools/check-drift.mjs (the real gate) and tools/check-drift.test.mjs (the
// negative tests) so the two can never drift apart from each other — the
// exact failure mode R-014 exists to prevent, applied to this new check.
//
// Each descriptor's `generate` runs entirely inside a scratch copy of the
// package (see regeneratePackageOutput in check-drift-core.mjs) — never in
// place — so running this check can never mutate the real tracked tree.
//
// Zero dependencies (plain Node ESM).

import fs from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { compareGeneratedPaths, regeneratePackageOutput } from "./check-drift-core.mjs";

// `srcDir` per package is READ from tools/family.json (Theme 3 "manifest
// move") rather than hardcoded here a second time — this module used to be
// the audit's "independently invented a second [FAMILY]" (Theme 3 table).
// The `exclude`/`symlinks`/`paths`/`generate` shape below stays as code: it's
// each consumer's actual build-pipeline invocation, not portable data.
function familySrcDir(repoRoot, name) {
    const family = JSON.parse(fs.readFileSync(path.join(repoRoot, "tools", "family.json"), "utf8")).packages;
    const pkg = family[name];
    if (!pkg) throw new Error(`consumer-output-drift: no tools/family.json entry for "${name}"`);
    return path.join(repoRoot, pkg.srcDir);
}

function runNodeScript(cwd, relScriptPath, args = []) {
    const result = spawnSync(process.execPath, [relScriptPath, ...args], { cwd, encoding: "utf8" });
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    if (result.status !== 0) {
        throw new Error(`${relScriptPath} ${args.join(" ")} exited ${result.status}:\n${result.stdout}\n${result.stderr}`);
    }
}

/** One descriptor per consumer whose GENERATED OUTPUT (not just its bundle copy) must not drift. */
export function consumerOutputDescriptors(repoRoot) {
    return [
        {
            key: "elm-cem-figma-connect",
            label: "check-drift: elm-cem-figma-connect generated/m3-kit (regenerate + byte-compare)",
            pkgDir: familySrcDir(repoRoot, "elm-cem-figma-connect"),
            // gen:emit is proven byte-deterministic (tools/check-emit-determinism-cfc.mjs);
            // these excludes just skip large, irrelevant subtrees to keep the scratch copy
            // fast — research/ is NOT excluded: figma.mjs reads its figma-export dump as input.
            exclude: ["render-cache", "test", "plans"],
            // Phase 1 (L3): the m3-kit Elm emitter now imports the canonical
            // Face-C→Elm engine from `elm-cem/elm-shape` (a workspace:* dep),
            // resolved via node_modules/elm-cem → ../../elm-cem. rsync excludes
            // node_modules, so symlink just that one package back in read-only —
            // same pattern as m3e-okf's .cache below. Without it, `emit` throws
            // "Cannot find package 'elm-cem'" in the scratch copy.
            symlinks: ["node_modules/elm-cem"],
            paths: ["generated/m3-kit"],
            generate: (dest) => runNodeScript(dest, "src/cli.mjs", ["emit", "--profile", "m3-kit"]),
        },
        {
            key: "m3e-okf",
            label: "check-drift: m3e-okf components.json + skill/OKF outputs (regenerate + byte-compare)",
            pkgDir: familySrcDir(repoRoot, "m3e-okf"),
            // .cache/m3e is a gitignored upstream checkout (input only, never written by
            // the gen pipeline) — excluded from the copy and symlinked back in read-only.
            exclude: [".cache"],
            symlinks: [".cache"],
            // W6 promoted scripts/lib/okf-lib.mjs's generic core to the shared
            // workspace tools/lib/okf-lib.mjs (same pattern as tailwind-m3e-web
            // below) — build-okf.mjs imports it via a relative specifier that
            // walks out of brands/m3e/outputs/m3e-api-okf/scripts/ into tools/lib/, so the
            // scratch copy needs that sibling present at the same
            // repo-root-relative position.
            externalSymlinks: ["tools/lib"],
            // POST-REORG SPLIT (2026-08-18): "knowledge" removed -- it moved to the
            // sibling brands/m3e/inputs/material-okf package and is no longer
            // generated or present in m3e-api-okf's own tree.
            paths: ["data/components.json", "skills/m3e", "implementations/m3e-web"],
            generate: (dest) => {
                for (const script of [
                    "scripts/extract.mjs",
                    "scripts/guidance.mjs",
                    "scripts/build-examples.mjs",
                    "scripts/build-skill.mjs",
                    "scripts/build-okf.mjs",
                ]) {
                    runNodeScript(dest, script);
                }
            },
        },
        {
            key: "tailwind-m3e-web",
            label: "check-drift: tailwind-m3e-web generated utilities (regenerate + byte-compare)",
            pkgDir: familySrcDir(repoRoot, "tailwind-m3e-web"),
            exclude: [],
            symlinks: [],
            // Theme 6 (thermonuclear audit) promoted this script's generic core to
            // tools/lib/component-css-utilities.mjs, imported via a relative
            // specifier that walks out of packages/tailwind-m3e-web/bin/ into the
            // shared workspace tools/lib/ — needs the scratch copy to have that
            // sibling present at the same repo-root-relative position.
            externalSymlinks: ["tools/lib"],
            paths: ["generated/utilities.css", "generated/CSS_CUSTOM_PROPERTIES.md"],
            generate: (dest) => runNodeScript(dest, "bin/generate-component-utilities.mjs"),
        },
    ];
}

/**
 * Run one consumer descriptor: regenerate its output into a scratch copy,
 * then byte-compare the descriptor's paths against `committedRoot` (defaults
 * to the descriptor's own package directory; tests override this with a
 * perturbed COPY elsewhere so the real tracked tree is never touched).
 *
 * @returns {{ok: boolean, failures: string[]}}
 */
export function checkConsumerOutputDrift(descriptor, { committedRoot, repoRoot } = {}) {
    const { root, cleanup } = regeneratePackageOutput({
        repoRoot: repoRoot || path.resolve(descriptor.pkgDir, "..", ".."),
        pkgDir: descriptor.pkgDir,
        exclude: descriptor.exclude,
        symlinks: descriptor.symlinks,
        externalSymlinks: descriptor.externalSymlinks || [],
        generate: descriptor.generate,
    });
    try {
        return compareGeneratedPaths({
            label: descriptor.label,
            committedRoot: committedRoot || descriptor.pkgDir,
            freshRoot: root,
            paths: descriptor.paths,
        });
    } finally {
        cleanup();
    }
}
