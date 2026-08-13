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

import { spawnSync } from "node:child_process";
import path from "node:path";
import { compareGeneratedPaths, regeneratePackageOutput } from "./check-drift-core.mjs";

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
            key: "cem-figma-connect",
            label: "check-drift: cem-figma-connect generated/m3-kit (regenerate + byte-compare)",
            pkgDir: path.join(repoRoot, "packages", "cem-figma-connect"),
            // gen:emit is proven byte-deterministic (tools/check-emit-determinism-cfc.mjs);
            // these excludes just skip large, irrelevant subtrees to keep the scratch copy
            // fast — research/ is NOT excluded: figma.mjs reads its figma-export dump as input.
            exclude: ["render-cache", "test", "plans"],
            symlinks: [],
            paths: ["generated/m3-kit"],
            generate: (dest) => runNodeScript(dest, "src/cli.mjs", ["emit", "--profile", "m3-kit"]),
        },
        {
            key: "m3e-okf",
            label: "check-drift: m3e-okf components.json + skill/OKF outputs (regenerate + byte-compare)",
            pkgDir: path.join(repoRoot, "packages", "m3e-okf"),
            // .cache/m3e is a gitignored upstream checkout (input only, never written by
            // the gen pipeline) — excluded from the copy and symlinked back in read-only.
            exclude: [".cache"],
            symlinks: [".cache"],
            paths: ["data/components.json", "skills/m3e", "knowledge", "implementations/m3e-web"],
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
            pkgDir: path.join(repoRoot, "packages", "tailwind-m3e-web"),
            exclude: [],
            symlinks: [],
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
export function checkConsumerOutputDrift(descriptor, { committedRoot } = {}) {
    const { root, cleanup } = regeneratePackageOutput({
        pkgDir: descriptor.pkgDir,
        exclude: descriptor.exclude,
        symlinks: descriptor.symlinks,
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
