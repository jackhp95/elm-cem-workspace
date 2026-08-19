#!/usr/bin/env node
// build-site-cached.mjs — content-hash cache wrapper around `npm run
// build:site` (elm-pages build + search-index gen), for Playwright's
// webServer (playwright.config.ts). Only used from there — `npm run
// build:site` itself is untouched, so `build:ci` and elm-m3e's own `build`
// script (which chain build:site directly) are unaffected by this cache.
//
// Design: docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md §3.3 Tier 2,
//   "Cache build:site ... this must be a cache-and-verify, not a
//   skip-if-path-unchanged ... any cache hit must show up in the gate's
//   summary output the same way an existing SKIP does — named, reasoned,
//   attributable — never a silent no-op."
//
// Input list: derived from `git ls-files` over the directories elm-pages
// actually reads content/config from (app/ elm-pages routes+data,
// data/*.json content, gen/ + codegen/ generated modules the app imports,
// public/ static assets elm-pages copies verbatim, vendor/ vendored CSS,
// plus elm.json/package.json/elm-pages.config.mjs/style.css) — reasoned
// from elm-pages' documented conventions and this package's own directory
// layout (a live `fs_usage`/`strace` trace was judged not worth the time
// cost for this pass; if `build:site`'s actual read set ever diverges from
// this list, a false cache-hit would show up as `check:drift`/`check:nav`
// staleness in the SAME gate run, since those compare committed output
// against a fresh regeneration independently of this cache).
//
// Cache storage: NOT inside the repo (build:site output is itself
// git-tracked under docs/dist — see .gitignore's `!docs/dist/` override —
// so cache entries live under os.tmpdir(), keyed by this worktree's path,
// never committed and never risk being mistaken for tracked output).

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { cachedBuildSite } from "../../../../../../tools/lib/build-site-cache.mjs";

const docsRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const distDir = path.join(docsRoot, "dist");

const INPUT_DIRS = ["app", "data", "gen", "codegen", "public", "vendor"];
const INPUT_FILES = ["elm.json", "package.json", "elm-pages.config.mjs", "style.css"];

function trackedFiles() {
    const out = execFileSync("git", ["ls-files", ...INPUT_DIRS, ...INPUT_FILES], {
        cwd: docsRoot,
        encoding: "utf8",
    });
    return out
        .split("\n")
        .filter(Boolean)
        .map((f) => path.join(docsRoot, f));
}

function cacheDirFor(root) {
    const slug = root.replace(/[^a-z0-9]+/gi, "-").toLowerCase();
    return path.join(os.tmpdir(), "gate-all-build-site-cache", slug);
}

const inputs = trackedFiles();
const cacheDir = cacheDirFor(docsRoot);

const { cacheHit, hash } = cachedBuildSite({
    inputs,
    distDir,
    cacheDir,
    buildCommand: () => {
        execFileSync("npm", ["run", "build:site"], { cwd: docsRoot, stdio: "inherit" });
    },
});

if (cacheHit) {
    console.log(
        `build-site-cache: CACHE HIT — hash ${hash.slice(0, 12)} matched ${inputs.length} tracked input file(s); ` +
            `restored dist/ from the scratch cache instead of re-running \`npm run build:site\`.`,
    );
} else {
    console.log(
        `build-site-cache: CACHE MISS — hash ${hash.slice(0, 12)} over ${inputs.length} tracked input file(s) not ` +
            `seen before; ran \`npm run build:site\` for real and cached the result.`,
    );
}
