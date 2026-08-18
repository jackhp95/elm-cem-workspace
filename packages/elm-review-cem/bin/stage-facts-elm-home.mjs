#!/usr/bin/env node
// Seeds the local Elm package cache with `jackhp95/elm-cem-facts` (M1.d, Stage-F
// cutover). elm-review-cem now declares a real `dependencies` entry on the
// unpublished `jackhp95/elm-cem-facts` package (packages/elm-cem/facts), whose
// canonical source lives at `../elm-cem/facts/src/Cem/Facts.elm`. `elm` and
// `elm-review` resolve declared dependencies from the ELM_HOME package cache
// (~/.elm/0.19.1/packages/<author>/<pkg>/<version>/{elm.json,docs.json}), not
// from source-directories — packages can't declare source-directories at all.
// Since the dependency is unpublished, nothing ever populates that cache entry,
// so every tool that reads elm.json's `dependencies` (elm-review, `elm make`,
// elm-test-rs run against the package elm.json) needs it seeded first.
//
// This script builds that cache entry from the canonical facts src (elm.json +
// a freshly-compiled docs.json), idempotently — it no-ops if an entry already
// exists whose elm.json matches the canonical one byte-for-byte, and overwrites
// (recompiling docs.json) if it has drifted, so a stale cache from a prior
// package edit can never mask a real change.
//
// This is NOT the "vendor a copy of Cem/Facts.elm" workaround the Stage-F
// cutover retires: nothing is written under packages/. The ELM_HOME cache is
// the same place a real `elm install` of a published package would write to;
// this just seeds it locally for an unpublished in-workspace dependency.
//
// Standalone-checkout fallback: `jackhp95/elm-cem-facts` is deliberately kept
// OFF the Elm package registry (Jack's call — publishing there is effectively
// irreversible), but it does have its own `jackhp95/elm-cem-facts` GitHub
// mirror, published by `tools/publish-mirror.mjs` the same way this repo is.
// Outside the monorepo (a plain `git clone` of this repo on its own), the
// `packages/elm-cem/facts` relative path doesn't exist — this script falls
// back to a shallow clone of that mirror instead, cached and refreshed like
// any other dependency fetch. Override the mirror URL with
// `ELM_CEM_FACTS_GIT_URL` if you need to point at a fork or a local path.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const workspaceRoot = path.resolve(repoRoot, "..", "..");

function resolveFactsDir() {
  const monorepoFactsDir = path.resolve(workspaceRoot, "packages", "elm-cem", "facts");
  if (fs.existsSync(path.join(monorepoFactsDir, "elm.json"))) {
    return monorepoFactsDir;
  }

  const gitUrl = process.env.ELM_CEM_FACTS_GIT_URL || "https://github.com/jackhp95/elm-cem-facts.git";
  const mirrorCacheDir = path.join(os.tmpdir(), "elm-cem-facts-mirror-cache");

  if (fs.existsSync(path.join(mirrorCacheDir, ".git"))) {
    console.log(`stage-facts-elm-home: refreshing standalone-checkout fallback clone at ${mirrorCacheDir}`);
    spawnSync("git", ["-C", mirrorCacheDir, "fetch", "--depth", "1", "origin", "main"], { stdio: "inherit" });
    spawnSync("git", ["-C", mirrorCacheDir, "reset", "--hard", "origin/main"], { stdio: "inherit" });
  } else {
    console.log(`stage-facts-elm-home: no in-monorepo packages/elm-cem/facts — cloning ${gitUrl} as a fallback (standalone checkout)`);
    fs.rmSync(mirrorCacheDir, { recursive: true, force: true });
    const clone = spawnSync("git", ["clone", "--depth", "1", gitUrl, mirrorCacheDir], { stdio: "inherit" });
    if (clone.status !== 0) {
      fail(`could not clone ${gitUrl} — set ELM_CEM_FACTS_GIT_URL to override, or run this from inside elm-cem-workspace`);
    }
  }

  return mirrorCacheDir;
}

const factsDir = resolveFactsDir();
const factsElmJsonPath = path.join(factsDir, "elm.json");
const factsSrcDir = path.join(factsDir, "src");

const elmHome = process.env.ELM_HOME || path.join(os.homedir(), ".elm");
const cacheDir = path.join(elmHome, "0.19.1", "packages", "jackhp95", "elm-cem-facts", "1.0.0");
const cacheElmJsonPath = path.join(cacheDir, "elm.json");
const cacheDocsPath = path.join(cacheDir, "docs.json");
const cacheReadmePath = path.join(cacheDir, "README.md");

function resolveElm() {
  const binName = process.platform === "win32" ? "elm.cmd" : "elm";
  const cand = path.join(repoRoot, "node_modules", ".bin", binName);
  if (fs.existsSync(cand)) return cand;
  const rootCand = path.join(workspaceRoot, "node_modules", ".bin", binName);
  if (fs.existsSync(rootCand)) return rootCand;
  return binName;
}

function fail(msg) {
  console.error(`stage-facts-elm-home: FAIL — ${msg}`);
  process.exit(1);
}

if (!fs.existsSync(factsElmJsonPath) || !fs.existsSync(factsSrcDir)) {
  fail(`canonical facts package not found at ${factsDir}`);
}

const canonicalElmJson = fs.readFileSync(factsElmJsonPath, "utf8");

if (fs.existsSync(cacheElmJsonPath) && fs.readFileSync(cacheElmJsonPath, "utf8") === canonicalElmJson && fs.existsSync(cacheDocsPath)) {
  console.log(`stage-facts-elm-home: OK — cache already current at ${cacheDir}`);
  process.exit(0);
}

fs.mkdirSync(cacheDir, { recursive: true });

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-facts-cache-"));
fs.mkdirSync(path.join(scratch, "src"), { recursive: true });
for (const entry of fs.readdirSync(factsSrcDir)) {
  fs.cpSync(path.join(factsSrcDir, entry), path.join(scratch, "src", entry), { recursive: true });
}
fs.copyFileSync(factsElmJsonPath, path.join(scratch, "elm.json"));

const elm = resolveElm();
const r = spawnSync(elm, ["make", "--docs=docs.json"], { cwd: scratch, encoding: "utf8" });
if (r.status !== 0) {
  console.error((r.stdout || "") + (r.stderr || ""));
  fs.rmSync(scratch, { recursive: true, force: true });
  fail("compiling jackhp95/elm-cem-facts to generate docs.json failed");
}

fs.copyFileSync(path.join(scratch, "docs.json"), cacheDocsPath);
fs.copyFileSync(factsElmJsonPath, cacheElmJsonPath);
if (!fs.existsSync(cacheReadmePath)) {
  fs.writeFileSync(cacheReadmePath, "# jackhp95/elm-cem-facts\n\nWorkspace-local, unpublished. Seeded by bin/stage-facts-elm-home.mjs.\n");
}
fs.rmSync(scratch, { recursive: true, force: true });

console.log(`stage-facts-elm-home: OK — seeded ${cacheDir} from ${factsElmJsonPath}`);
