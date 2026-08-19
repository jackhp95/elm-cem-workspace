// tools/lib/build-site-cache.mjs — content-hash cache around a site build.
//
// NEVER a path/git-diff heuristic — always hashes actual input file bytes,
// so a cache hit is provably safe (spec §4: this repo forbids
// skip-if-path-unchanged heuristics; a hash miss always rebuilds, there is
// no "trust the diff" fallback anywhere here). A cache hit or miss is always
// returned in the result AND expected to be logged by the caller — this
// module never silently substitutes stale output; see build-site-cached.mjs
// for the CLI wrapper that does the logging.

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

/**
 * @param {object} opts
 * @param {string[]} opts.inputs - files (not directories) whose CONTENT is hashed
 * @param {() => void} opts.buildCommand - runs the real build; must populate distDir
 * @param {string} opts.distDir - the build's output directory
 * @param {string} opts.cacheDir - where cache entries are stored, keyed by hash
 * @returns {{cacheHit: boolean, hash: string}}
 */
export function cachedBuildSite({ inputs, buildCommand, distDir, cacheDir }) {
    fs.mkdirSync(cacheDir, { recursive: true });
    const hash = hashInputs(inputs);
    const entryDir = path.join(cacheDir, hash);

    if (fs.existsSync(entryDir)) {
        fs.rmSync(distDir, { recursive: true, force: true });
        fs.cpSync(entryDir, distDir, { recursive: true });
        return { cacheHit: true, hash };
    }

    buildCommand();
    // Populate the cache from whatever the build produced, so the NEXT run
    // with the same inputs can restore it — copy, not move, so this
    // invocation's own dist stays intact for its caller.
    fs.cpSync(distDir, entryDir, { recursive: true });
    return { cacheHit: false, hash };
}

function hashInputs(inputs) {
    const h = crypto.createHash("sha256");
    for (const file of [...inputs].sort()) {
        h.update(file);
        if (fs.existsSync(file) && fs.statSync(file).isFile()) {
            h.update(fs.readFileSync(file));
        } else {
            // A listed input that's missing/not-a-file still perturbs the
            // hash (rather than being silently skipped), so removing or
            // renaming a tracked input file is itself a cache-invalidating
            // change, not something the cache can accidentally paper over.
            h.update("<absent>");
        }
    }
    return h.digest("hex");
}
