// check-drift-core.mjs — pure, importable comparison logic behind
// tools/check-drift.mjs. Split out from the CLI so tools/check-drift.test.mjs
// can inject staleness into a COPY of a consumer's committed bundle and prove
// the comparison goes RED, without ever touching the real tracked files.
//
// Zero dependencies (plain Node ESM).

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { generateBundleToTemp } from "./regen.mjs";

function diffSummary(committedPath, freshPath) {
    try {
        return execFileSync("diff", ["-u", committedPath, freshPath], { encoding: "utf8" });
    } catch (e) {
        // diff exits 1 when files differ; its stdout still carries the unified diff.
        return e.stdout || e.message;
    }
}

/**
 * Compare one or more committed bundle-copy files against a fresh
 * regeneration of the producer's output, byte for byte.
 *
 * @param {object} opts
 * @param {string} opts.repoRoot
 * @param {string} opts.elmM3e - elm-m3e checkout to generate against (read-only)
 * @param {string} opts.label - human-readable name for log lines
 * @param {{committedPath: string, bundleFile: string}[]} opts.files -
 *   committedPath: the file to check (may be a copy, for testing);
 *   bundleFile: its name within the freshly generated bundle (cem-facts.json, elm-api-facts.json)
 * @returns {{ok: boolean, failures: string[]}}
 */
export function checkConsumerBundleDrift({ repoRoot, elmM3e, label, files }) {
    const failures = [];

    for (const { committedPath } of files) {
        if (!fs.existsSync(committedPath)) {
            failures.push(`${label}: ${committedPath} is missing.`);
        }
    }
    if (!fs.existsSync(elmM3e)) {
        failures.push(`${label}: elm-m3e checkout not found at ${elmM3e}.`);
    }
    if (failures.length > 0) return { ok: false, failures };

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "check-drift-"));
    try {
        let bundleDir;
        try {
            ({ bundleDir } = generateBundleToTemp({ repoRoot, elmM3e, workDir: work, streamOutput: false }));
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
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }

    return { ok: failures.length === 0, failures };
}

// ── R-008: packages/elm-m3e/docs/.elm-pages/Pages.elm carries a build
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
