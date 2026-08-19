// check-drift-core.mjs — pure, importable comparison logic behind
// tools/check-drift.mjs. Split out from the CLI so tools/check-drift.test.mjs
// can inject staleness into a COPY of a consumer's committed bundle and prove
// the comparison goes RED, without ever touching the real tracked files.
//
// Zero dependencies (plain Node ESM).

import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { generateBundleToTemp, deriveIconNamesFromOutput, serializeIconNames } from "./regen.mjs";

function isGitTracked(repoRoot, absPath) {
    const relPath = path.relative(repoRoot, absPath);
    const result = spawnSync("git", ["ls-files", "--error-unmatch", relPath], { cwd: repoRoot, encoding: "utf8" });
    return result.status === 0;
}

function diffSummary(committedPath, freshPath) {
    try {
        return execFileSync("diff", ["-u", committedPath, freshPath], { encoding: "utf8" });
    } catch (e) {
        // diff exits 1 when files differ; its stdout still carries the unified diff.
        return e.stdout || e.message;
    }
}

// listFilesRecursive(dir) -> sorted relative paths, so directory-listing
// order differences never masquerade as content differences. Exported: also
// used by tools/check-emit-determinism-cfc.mjs for the same reason.
export function listFilesRecursive(dir) {
    const out = [];
    const walk = (d, rel) => {
        for (const entry of fs.readdirSync(d, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
            const full = path.join(d, entry.name);
            const relPath = rel ? `${rel}/${entry.name}` : entry.name;
            if (entry.isDirectory()) walk(full, relPath);
            else out.push(relPath);
        }
    };
    if (fs.existsSync(dir)) walk(dir, "");
    return out;
}

// ── M4.b (round 2): a consumer's committed GENERATED OUTPUT (not just its
// bundle copy) can drift from what the producer's full pipeline emits today,
// and nothing previously caught that (verified by hand: appending a line to
// brands/m3e/generated/style/elm-m3e-tailwind/generated/utilities.css left check-drift green).
// These two helpers close that hole for any consumer, generically:
//
//   regeneratePackageOutput — copies a package to a scratch temp dir (so the
//   real tracked tree is NEVER touched or mutated in place) and runs its own
//   generation pipeline there.
//
//   compareGeneratedPaths — byte-compares a set of relative paths (files or
//   whole directories) between the committed tree and a fresh regeneration.
//
// Zero pre-existing staleness applies to these three consumers (unlike
// elm-m3e's src/, see R-010 above) — see the M4 spec — so a plain
// regenerate-and-diff is correct and simplest here too.

/**
 * Copy `pkgDir` into a fresh scratch temp directory, optionally symlinking
 * read-only inputs that were excluded from the copy (e.g. a large upstream
 * checkout under .cache/ that the generator only reads), then run `generate`
 * with the scratch copy's root as its argument.
 *
 * The scratch copy preserves `pkgDir`'s real position relative to `repoRoot`
 * (e.g. `brands/m3e/generated/style/elm-m3e-tailwind`, not just `tailwind-m3e-web`) — a
 * generation script that imports a REPO-ROOT-relative sibling via a relative
 * specifier (e.g. `../../../tools/lib/x.mjs`, walking up out of `packages/*`
 * to a shared `tools/lib/`) resolves against the running script's own real
 * path, so a flattened scratch copy silently breaks that import. Preserving
 * depth is what lets `externalSymlinks` below hand back exactly the same
 * relative path shape the script already uses in the real tree.
 *
 * @param {object} opts
 * @param {string} opts.repoRoot - the real workspace root (for locating externalSymlinks sources and computing pkgDir's depth)
 * @param {string} opts.pkgDir - the real, tracked package directory (read-only)
 * @param {string[]} [opts.exclude] - extra rsync --exclude patterns beyond node_modules/.git
 * @param {string[]} [opts.symlinks] - paths, relative to pkgDir, to symlink from pkgDir into the copy after rsync (e.g. an excluded node_modules/ entry)
 * @param {string[]} [opts.externalSymlinks] - paths, relative to repoRoot, OUTSIDE pkgDir, to symlink into the scratch tree at the same repo-root-relative position (e.g. "tools/lib" for a script that imports out of its package into shared workspace tooling)
 * @param {(scratchPkgDir: string) => void} opts.generate - runs the generation pipeline in-place inside the copy; throws on failure
 * @returns {{root: string, cleanup: () => void}}
 */
export function regeneratePackageOutput({ repoRoot, pkgDir, exclude = [], symlinks = [], externalSymlinks = [], generate }) {
    const parent = fs.mkdtempSync(path.join(os.tmpdir(), "check-drift-regen-"));
    const relPkgDir = path.relative(repoRoot, pkgDir);
    const dest = path.join(parent, relPkgDir);
    fs.mkdirSync(dest, { recursive: true });
    const cleanup = () => fs.rmSync(parent, { recursive: true, force: true });

    const excludeArgs = ["node_modules", ".git", ...exclude].flatMap((e) => ["--exclude", e]);
    const rsync = execFileSyncSafe("rsync", ["-a", ...excludeArgs, `${pkgDir}/`, `${dest}/`]);
    if (!rsync.ok) {
        cleanup();
        throw new Error(`rsync copy of ${pkgDir} failed: ${rsync.error}`);
    }
    for (const link of symlinks) {
        // A link may be nested (e.g. "node_modules/elm-cem" — a workspace
        // dependency that lives under an excluded node_modules/). rsync skipped
        // node_modules, so its parent dir won't exist in the copy: create it
        // before symlinking the one read-only input back in.
        const linkDest = path.join(dest, link);
        fs.mkdirSync(path.dirname(linkDest), { recursive: true });
        fs.symlinkSync(path.join(pkgDir, link), linkDest);
    }
    for (const rootRel of externalSymlinks) {
        // Same shape as `symlinks` above, but the source lives OUTSIDE pkgDir
        // (repo-root-relative), so both the source and the link position are
        // resolved against repoRoot / parent instead of pkgDir / dest.
        const linkDest = path.join(parent, rootRel);
        fs.mkdirSync(path.dirname(linkDest), { recursive: true });
        fs.symlinkSync(path.join(repoRoot, rootRel), linkDest);
    }
    try {
        generate(dest);
    } catch (e) {
        cleanup();
        throw e;
    }
    return { root: dest, cleanup };
}

function execFileSyncSafe(cmd, args) {
    try {
        execFileSync(cmd, args, { encoding: "utf8" });
        return { ok: true };
    } catch (e) {
        return { ok: false, error: e.stderr || e.message };
    }
}

/**
 * Byte-compare a set of relative paths (files or whole directories) between
 * a committed tree and a fresh regeneration. Missing files on either side,
 * extra files on either side, and byte differences are all reported as
 * failures — never silently ignored.
 *
 * @param {object} opts
 * @param {string} opts.label
 * @param {string} opts.committedRoot - directory to treat as "committed" (normally the real package dir; a scratch copy in tests)
 * @param {string} opts.freshRoot - directory holding a fresh regeneration (normally a regeneratePackageOutput() result)
 * @param {string[]} opts.paths - paths relative to both roots; each may be a file or a directory
 * @returns {{ok: boolean, failures: string[]}}
 */
export function compareGeneratedPaths({ label, committedRoot, freshRoot, paths }) {
    const failures = [];

    for (const rel of paths) {
        const committedPath = path.join(committedRoot, rel);
        const freshPath = path.join(freshRoot, rel);
        const committedExists = fs.existsSync(committedPath);
        const freshExists = fs.existsSync(freshPath);

        if (!committedExists && !freshExists) continue;
        if (!committedExists) {
            failures.push(`${label}: ${rel} is missing from the committed tree but the fresh regeneration produced it.`);
            continue;
        }
        if (!freshExists) {
            failures.push(`${label}: ${rel} is missing from the fresh regeneration but exists in the committed tree.`);
            continue;
        }

        if (fs.statSync(committedPath).isDirectory()) {
            const committedFiles = listFilesRecursive(committedPath);
            const freshFiles = listFilesRecursive(freshPath);
            const onlyCommitted = committedFiles.filter((f) => !freshFiles.includes(f));
            const onlyFresh = freshFiles.filter((f) => !committedFiles.includes(f));
            if (onlyCommitted.length > 0) {
                failures.push(`${label}: ${rel} has file(s) only in the committed tree: ${onlyCommitted.join(", ")}`);
            }
            if (onlyFresh.length > 0) {
                failures.push(`${label}: ${rel} has file(s) only in the fresh regeneration: ${onlyFresh.join(", ")}`);
            }
            const diffs = [];
            for (const f of committedFiles) {
                if (!freshFiles.includes(f)) continue;
                const a = fs.readFileSync(path.join(committedPath, f));
                const b = fs.readFileSync(path.join(freshPath, f));
                if (!a.equals(b)) diffs.push(f);
            }
            if (diffs.length > 0) {
                failures.push(
                    `${label}: ${rel} — ${diffs.length} file(s) DRIFTED from a fresh regeneration: ${diffs.slice(0, 20).join(", ")}${diffs.length > 20 ? ` … (+${diffs.length - 20} more)` : ""}`,
                );
            }
        } else {
            const committedBytes = fs.readFileSync(committedPath);
            const freshBytes = fs.readFileSync(freshPath);
            if (!committedBytes.equals(freshBytes)) {
                const summary = diffSummary(committedPath, freshPath);
                const lines = summary.split("\n").slice(0, 40).join("\n");
                failures.push(`${label}: ${rel} DRIFTED from a fresh regeneration. First diff lines:\n${lines}`);
            }
        }
    }

    return { ok: failures.length === 0, failures };
}

/**
 * Compare one or more committed bundle-copy files against a fresh
 * regeneration of the producer's output, byte for byte.
 *
 * Also enforces the two checks the now-retired standalone
 * `check-bundle-provenance*.mjs` scripts used to do that this generic engine
 * didn't: every committed file must be git-TRACKED (not merely present on
 * disk — a `git rm`'d-but-not-committed file would otherwise pass silently),
 * and — when `iconNames` is given — the opaque-`Name` icon catalog (R-026)
 * must match a fresh derivation from the same regeneration's Face-A output.
 *
 * @param {object} opts
 * @param {string} opts.repoRoot
 * @param {string} opts.elmM3e - elm-m3e checkout to generate against (read-only)
 * @param {string} opts.label - human-readable name for log lines
 * @param {{committedPath: string, bundleFile: string}[]} opts.files -
 *   committedPath: the file to check (may be a copy, for testing);
 *   bundleFile: its name within the freshly generated bundle (cem-facts.json, elm-api-facts.json)
 * @param {{committedPath: string}} [opts.iconNames] - if set, also derive the
 *   icon-Name catalog from the same regeneration's Face-A output and compare
 *   it against this committed file (cem-figma-connect's icon-names.json).
 * @returns {{ok: boolean, failures: string[]}}
 */
export function checkConsumerBundleDrift({ repoRoot, elmM3e, label, files, iconNames }) {
    const failures = [];

    const trackedTargets = iconNames ? [...files, { committedPath: iconNames.committedPath }] : files;
    for (const { committedPath } of trackedTargets) {
        if (!fs.existsSync(committedPath)) {
            failures.push(`${label}: ${committedPath} is missing.`);
        } else if (!isGitTracked(repoRoot, committedPath)) {
            failures.push(`${label}: ${committedPath} exists but is not git-tracked.`);
        }
    }
    if (!fs.existsSync(elmM3e)) {
        failures.push(`${label}: elm-m3e checkout not found at ${elmM3e}.`);
    }
    if (failures.length > 0) return { ok: false, failures };

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "check-drift-"));
    try {
        let outputDir, bundleDir;
        try {
            ({ outputDir, bundleDir } = generateBundleToTemp({ repoRoot, elmM3e, workDir: work, streamOutput: false }));
        } catch (e) {
            return { ok: false, failures: [`${label}: regeneration threw: ${e.message}`] };
        }

        for (const { committedPath, bundleFile } of files) {
            const freshPath = path.join(bundleDir, bundleFile);
            if (!fs.existsSync(freshPath)) {
                failures.push(`${label}: regeneration did not produce ${bundleFile}.`);
                continue;
            }
            const committedBytes = fs.readFileSync(committedPath);
            const freshBytes = fs.readFileSync(freshPath);
            if (!committedBytes.equals(freshBytes)) {
                const summary = diffSummary(committedPath, freshPath);
                const lines = summary.split("\n").slice(0, 40).join("\n");
                failures.push(`${label}: ${committedPath} DRIFTED from a fresh regeneration. First diff lines:\n${lines}`);
            }
        }

        if (iconNames) {
            let freshBytes;
            try {
                freshBytes = Buffer.from(serializeIconNames(deriveIconNamesFromOutput(outputDir)), "utf8");
            } catch (e) {
                failures.push(`${label}: could not derive icon names from the fresh output: ${e.message}`);
                freshBytes = null;
            }
            if (freshBytes) {
                const committedBytes = fs.readFileSync(iconNames.committedPath);
                if (!committedBytes.equals(freshBytes)) {
                    const freshPath = path.join(work, "icon-names.json");
                    fs.writeFileSync(freshPath, freshBytes);
                    const summary = diffSummary(iconNames.committedPath, freshPath);
                    const lines = summary.split("\n").slice(0, 40).join("\n");
                    failures.push(`${label}: ${iconNames.committedPath} DRIFTED from a fresh derivation. First diff lines:\n${lines}`);
                }
            }
        }
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }

    return { ok: failures.length === 0, failures };
}

// ── R-008: brands/m3e/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm carries a build
// timestamp (`builtAt = Time.millisToPosix <epoch-ms>`) that any docs build
// rewrites. A naive byte-diff against this file is red on every docs build
// for a reason nobody can act on. Normalize the timestamp out before
// comparing — but only the timestamp: any OTHER difference in the file is
// real drift and must still be reported.
const BUILT_AT_RE = /Time\.millisToPosix\s+\d+/;

/**
 * Compare a working-tree copy of Pages.elm against a reference copy (e.g. the
 * git HEAD blob), ignoring only the `builtAt` timestamp.
 * @returns {{ok: boolean, onlyTimestampDiffers: boolean, detail: string}}
 */
export function comparePagesElmIgnoringTimestamp(workingContent, referenceContent) {
    if (workingContent === referenceContent) {
        return { ok: true, onlyTimestampDiffers: false, detail: "byte-identical" };
    }
    const normalizedWorking = workingContent.replace(BUILT_AT_RE, "Time.millisToPosix <normalized>");
    const normalizedReference = referenceContent.replace(BUILT_AT_RE, "Time.millisToPosix <normalized>");
    if (normalizedWorking === normalizedReference) {
        return { ok: true, onlyTimestampDiffers: true, detail: "only the builtAt timestamp differs (R-008, normalized)" };
    }
    return { ok: false, onlyTimestampDiffers: false, detail: "differs beyond the builtAt timestamp — real content drift" };
}
