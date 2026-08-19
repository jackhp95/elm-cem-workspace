// regen.mjs — R-014: the ONE shared definition of the elm-cem regeneration
// invocation (`--flags-from`/`--config-from`/`--facts-bundle`) run against
// elm-m3e's own config. Before this existed, this exact argv was duplicated
// across eight sites (three consumer `scripts/gen-facts.mjs`,
// `tools/ab-elm-cem.sh`, `tools/ab-elm-m3e-split.sh`, `tools/gate-all.mjs`,
// and three now-retired `check-bundle-provenance*.mjs` scripts — Theme 3 of
// the 2026-08-17 audit folded their unique checks into
// `tools/lib/check-drift-core.mjs`'s `checkConsumerBundleDrift`, driven by
// `tools/family.json`). `tools/bump.mjs`, `tools/gate-all.mjs`, and the
// three consumer `gen-facts.mjs` scripts (via `tools/lib/gen-facts-runner.mjs`)
// now all route through this module (down to two remaining sites).
// `tools/ab-elm-cem.sh` and `tools/ab-elm-m3e-split.sh` are bash, not Node —
// routing them through this module would mean shelling out to a Node helper
// for a single argv list, which is more moving parts than the duplication it
// removes, and both are A/B harnesses the M4.b spec says not to touch. Left
// as-is.
//
// Zero dependencies (plain Node ESM).

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

/** The config/flags argv shared by every elm-cem invocation against elm-m3e's config. */
export const GEN_CONFIG_ARGS = [
    "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
    "--config-from=config/slots.json",
    "--config-from=config/native-mdn.json",
    "--config-from=config/examples.generated.json",
];

export function elmCemCli(repoRoot) {
    return path.join(repoRoot, "pipeline", "elm-cem", "bin", "elm-cem.js");
}

export function defaultElmM3e(repoRoot) {
    return process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "generated", "package", "elm-m3e");
}

/**
 * Run elm-cem against elmM3e's own config, writing to `output` (Face A) and/or
 * `factsBundle` (Face B/C). Returns the raw spawnSync result; never throws.
 */
export function runFactsGenerator({ repoRoot, elmM3e, output, factsBundle }) {
    const cli = elmCemCli(repoRoot);
    const args = [cli, ...GEN_CONFIG_ARGS];
    if (output) args.push(`--output=${output}`);
    if (factsBundle) args.push(`--facts-bundle=${factsBundle}`);
    return spawnSync(process.execPath, args, {
        cwd: elmM3e,
        encoding: "utf8",
        env: { ...process.env, PATH: `${path.join(elmM3e, "node_modules", ".bin")}:${process.env.PATH}` },
    });
}

// Phase 4 memoization (2026-08-18 gate-all parallelization plan): within a
// single `node` process, `check-drift.mjs`'s checkProducer() and its THREE
// checkConsumerBundleDrift() calls each independently regenerated an
// identical facts bundle (same repoRoot + elmM3e, same GEN_CONFIG_ARGS) —
// 4 regenerations of the same ~1.5-2s output per run, for nothing (every
// caller here only READS outputDir/bundleDir afterward, never mutates them,
// so sharing one generation across callers is a strict correctness
// improvement too: every consumer compares against the SAME bytes instead
// of separately-generated ones that could in principle diverge on a
// nondeterministic generator bug with nothing to notice). Cache is
// process-lifetime, keyed by the resolved (repoRoot, elmM3e) pair — safe
// because nothing in this module process ever calls it with a different
// pair. A cache hit is always logged (never silent), per this repo's
// no-silent-skip discipline.
//
// IMPORTANT: cached output lives in a directory THIS MODULE owns (a fresh
// mkdtempSync separate from any caller's `workDir`), never inside a
// caller-provided `workDir` — every existing caller wraps its own `workDir`
// in `try { ... } finally { fs.rmSync(workDir, ...) }`, which would delete
// the FIRST caller's directory (and therefore every later cache hit's
// backing files) the moment that first caller returned. Cache entries
// persist for the whole process regardless of what any individual caller
// does with its own scratch dir.
const _bundleCache = new Map();

/**
 * Generate a fresh facts bundle (Face B + Face C). Throws on nonzero exit
 * (after streaming stdout/stderr). Returns `{ outputDir, bundleDir }`
 * pointing into a directory this module owns — NOT `workDir` — so the
 * result outlives any individual caller's own cleanup (see the comment
 * above `_bundleCache`). Memoized per (repoRoot, elmM3e) pair for the
 * lifetime of this process; `workDir` is still accepted (and still created)
 * for backward compatibility with callers that pass it, but is unused on a
 * cache hit.
 */
export function generateBundleToTemp({ repoRoot, elmM3e, workDir, streamOutput = true }) {
    const cacheKey = `${path.resolve(repoRoot)}::${path.resolve(elmM3e)}`;
    const cached = _bundleCache.get(cacheKey);
    if (cached) {
        // Always reported, regardless of `streamOutput` — that flag controls
        // whether the GENERATOR's own stdout/stderr gets relayed, not
        // whether a cache-hit decision is visible. A cache hit must never be
        // quieter than a miss (no-silent-skip discipline).
        console.log(
            `generateBundleToTemp: CACHE HIT — reusing the facts bundle already generated this run for ` +
                `${cacheKey} (bundleDir: ${cached.bundleDir}); not re-invoking the generator.`,
        );
        return cached;
    }

    const ownedDir = fs.mkdtempSync(path.join(os.tmpdir(), "regen-bundle-cache-"));
    const outputDir = path.join(ownedDir, "out");
    const bundleDir = path.join(ownedDir, "bundle");
    fs.mkdirSync(outputDir, { recursive: true });
    fs.mkdirSync(bundleDir, { recursive: true });

    const result = runFactsGenerator({ repoRoot, elmM3e, output: outputDir, factsBundle: bundleDir });
    if (streamOutput) {
        if (result.stdout) process.stdout.write(result.stdout);
        if (result.stderr) process.stderr.write(result.stderr);
    }
    if (result.status !== 0) {
        throw new Error(`elm-cem --facts-bundle exited ${result.status}`);
    }
    const value = { outputDir, bundleDir };
    _bundleCache.set(cacheKey, value);
    return value;
}

// ── the opaque-`Name` icon catalog (R-026) ──────────────────────────────────
// After R-026 the generated icon module is NOT the generic `component` ctor
// shape every other component uses: it is `icon : Name -> …` with one opaque
// `Name` value per Material Symbols ligature (`menu = Name "menu"`), plus
// `custom : String -> Name` as the escape hatch. The facts bundle's Face C
// still projects the icon component onto the GENERIC ctor entry ("component",
// a `name` string setter) — it has no way to know the icon module is special-
// cased — so a facts-only emitter would emit `M3e.Icon.component [ M3e.Icon.name
// "menu" ] []`, which does not exist in the real API.
//
// deriveIconNames reads the GENERATED icon module (the `--output` Face A
// `<Lib>/Icon.elm`) and extracts, from the source itself (never hardcoded),
// everything the emitter needs to emit the real opaque-`Name` shape:
//   { cemTag, module, iconFn, customFn, names }
// where `names` maps each ligature -> its exposed Elm `Name` constant
// ("10k" -> "icon10k", "menu" -> "menu"). A ligature absent from `names`
// (e.g. the Figma display-name artifact "GIF", whose real ligature is "gif")
// is emitted via `customFn` — the documented escape hatch — never guessed.
//
// This is the sole writer's source of truth for cem-figma-connect's committed
// `profiles/m3-kit/facts/icon-names.json`; the same derivation runs in the
// provenance drift gate, so the committed catalog can never go stale silently.
export function deriveIconNames(iconElmSource) {
    const src = iconElmSource;
    const moduleMatch = src.match(/module\s+(\S+)\s+exposing/);
    if (!moduleMatch) throw new Error("deriveIconNames: no `module … exposing` line in the icon source");
    const module = moduleMatch[1];

    // The render function: the exposed value whose first argument type is `Name`.
    const iconFnMatch = src.match(/\n(\w+) :\n {4}Name\n {4}->/);
    if (!iconFnMatch) throw new Error("deriveIconNames: could not find the `icon : Name -> …` render function");
    const iconFn = iconFnMatch[1];

    // The escape hatch: `custom : String -> Name`.
    const customFnMatch = src.match(/\n(\w+) : String -> Name\n/);
    if (!customFnMatch) throw new Error("deriveIconNames: could not find the `custom : String -> Name` escape hatch");
    const customFn = customFnMatch[1];

    // The CEM tag the icon function renders (`Ir.node "m3e-icon" …`).
    const tagMatch = src.match(/Ir\.node "(m3e-[^"]+)"/);
    if (!tagMatch) throw new Error("deriveIconNames: could not find the `Ir.node \"m3e-…\"` tag in the render function");
    const cemTag = tagMatch[1];

    // Per-icon opaque `Name` constants: `<constant> =\n    Name "<ligature>"`.
    const names = {};
    const re = /\n([a-zA-Z]\w*) =\n {4}Name "([^"]+)"\n/g;
    let m;
    while ((m = re.exec(src)) !== null) names[m[2]] = m[1];
    if (Object.keys(names).length === 0) throw new Error("deriveIconNames: parsed zero icon Name constants — the source shape changed");

    // Sort the ligature keys for byte-stable, deterministic output.
    const sortedNames = {};
    for (const lig of Object.keys(names).sort()) sortedNames[lig] = names[lig];

    return { cemTag, module, iconFn, customFn, names: sortedNames };
}

// The byte-exact serialization of the icon catalog (the sole committed form).
export function serializeIconNames(catalog) {
    return JSON.stringify(catalog, null, 2) + "\n";
}

/** Read a generated Face-A output dir's `<Module>/Icon.elm` and derive the catalog. */
export function deriveIconNamesFromOutput(outputDir) {
    const iconElm = path.join(outputDir, "M3e", "Icon.elm");
    if (!fs.existsSync(iconElm)) {
        throw new Error(`deriveIconNamesFromOutput: no generated icon module at ${iconElm}`);
    }
    return deriveIconNames(fs.readFileSync(iconElm, "utf8"));
}
