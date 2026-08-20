// revendor-m3e.test.mjs — proves the manifest ALWAYS pins the full 40-char SHA,
// whatever commit-ish the caller passed (short SHA / full SHA / branch name).
//
// WHY THIS EXISTS: the CI drift gate (check-vendor.mjs) fetches canonical@pin
// from the public GitHub mirror BY SHA, and GitHub's fetch-by-SHA only resolves
// a FULL 40-char SHA — a short SHA fails "couldn't find remote ref" (rollout
// plan §11.7). A short SHA leaking into vendor/m3e-manifest.json therefore breaks
// every consumer's CI. This test is the regression guard for expandCommit().
//
// It stands up a throwaway git repo shaped like elm-cem-workspace (just the three
// vendored srcPaths, one file each), then runs the REAL revendor CLI as a
// subprocess against it — short-SHA, full-SHA, and branch-name inputs — and
// asserts every run writes the identical full-SHA manifest.

import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { expandCommit, DEFAULT_TREES } from "./revendor-m3e.mjs";

// CRITICAL isolation: this test builds throwaway git workspaces under tmpdir()
// and commits into them ("seed trees") + runs the revendor script (which shells
// out to git) + calls expandCommit() in-process (git rev-parse). Git honours
// the GIT_DIR / GIT_WORK_TREE family OVER `-C cwd`, and a git hook (pre-push)
// exports GIT_DIR=<the real repo>. Run under gate-all-under-pre-push, every git
// op here would target the real workspace repo instead (that is how a
// "seed trees" commit once landed on the working branch). Strip the whole GIT_*
// location family from process.env up front — covering the spawned git, the
// spawned revendor script, and in-process expandCommit alike.
for (const k of [
  "GIT_DIR",
  "GIT_WORK_TREE",
  "GIT_INDEX_FILE",
  "GIT_COMMON_DIR",
  "GIT_OBJECT_DIRECTORY",
  "GIT_ALTERNATE_OBJECT_DIRECTORIES",
  "GIT_NAMESPACE",
  "GIT_PREFIX",
  "GIT_CONFIG",
  "GIT_CONFIG_GLOBAL",
]) {
  delete process.env[k];
}
process.env.GIT_CEILING_DIRECTORIES = tmpdir();

const HERE = dirname(fileURLToPath(import.meta.url));
const SCRIPT = join(HERE, "revendor-m3e.mjs");
const FULL_SHA = /^[0-9a-f]{40}$/;

function git(cwd, ...args) {
  const r = spawnSync("git", ["-C", cwd, ...args], { encoding: "utf8" });
  if (r.status !== 0) throw new Error(`git ${args.join(" ")} failed:\n${r.stderr}`);
  return r.stdout.trim();
}

// Build a minimal git repo with the exact tree layout DEFAULT_TREES expects, one
// committed .elm file per srcPath. Returns { dir, full, short, branch }.
function makeWorkspace() {
  const dir = mkdtempSync(join(tmpdir(), "m3e-revendor-ws-"));
  git(dir, "init", "-q", "-b", "main");
  git(dir, "config", "user.email", "test@example.com");
  git(dir, "config", "user.name", "revendor test");
  for (const t of DEFAULT_TREES) {
    const abs = join(dir, t.srcPath);
    mkdirSync(abs, { recursive: true });
    // A distinct file per tree so the manifest is non-trivial (>1 key).
    writeFileSync(join(abs, `${t.name}.txt`), `content for ${t.name}\n`);
  }
  git(dir, "add", "-A");
  git(dir, "commit", "-q", "-m", "seed trees");
  const full = git(dir, "rev-parse", "HEAD");
  const short = git(dir, "rev-parse", "--short", "HEAD");
  return { dir, full, short, branch: "main" };
}

// Run the real CLI into a fresh consumer dir; return the parsed manifest.
function revendorInto(workspaceDir, commitish) {
  const consumer = mkdtempSync(join(tmpdir(), "m3e-revendor-consumer-"));
  const r = spawnSync(
    "node",
    [SCRIPT, "--commit", commitish, "--consumer", consumer, "--workspace", workspaceDir],
    { encoding: "utf8" },
  );
  assert.equal(r.status, 0, `revendor exited non-zero for "${commitish}":\n${r.stderr}\n${r.stdout}`);
  const manifest = JSON.parse(readFileSync(join(consumer, "vendor", "m3e-manifest.json"), "utf8"));
  rmSync(consumer, { recursive: true, force: true });
  return manifest;
}

test("expandCommit resolves short SHA, full SHA, and branch to the same full 40-char SHA", () => {
  const ws = makeWorkspace();
  try {
    const fromFull = expandCommit(ws.dir, ws.full);
    const fromShort = expandCommit(ws.dir, ws.short);
    const fromBranch = expandCommit(ws.dir, ws.branch);
    assert.match(fromFull, FULL_SHA, "full-SHA input must yield a 40-char SHA");
    assert.equal(fromShort, fromFull, "short-SHA input must expand to the same full SHA");
    assert.equal(fromBranch, fromFull, "branch-name input must expand to the same full SHA");
    assert.equal(fromFull, ws.full);
  } finally {
    rmSync(ws.dir, { recursive: true, force: true });
  }
});

test("expandCommit throws on an unresolvable ref", () => {
  const ws = makeWorkspace();
  try {
    assert.throws(() => expandCommit(ws.dir, "deadbeef0000nope"), /could not resolve/);
  } finally {
    rmSync(ws.dir, { recursive: true, force: true });
  }
});

test("manifest pins the full SHA regardless of short/full/branch input (end-to-end CLI)", () => {
  const ws = makeWorkspace();
  try {
    const mFull = revendorInto(ws.dir, ws.full);
    const mShort = revendorInto(ws.dir, ws.short);
    const mBranch = revendorInto(ws.dir, ws.branch);

    // The load-bearing property: every input pins the SAME full 40-char SHA.
    for (const [label, m] of [["full", mFull], ["short", mShort], ["branch", mBranch]]) {
      assert.match(m.source.commit, FULL_SHA, `${label} input wrote a non-full SHA: ${m.source.commit}`);
      assert.equal(m.source.commit, ws.full, `${label} input pinned the wrong commit`);
    }

    // The vendored content is identical across inputs (same commit → same trees).
    assert.deepEqual(mShort.files, mFull.files, "short-input file map differs from full-input");
    assert.deepEqual(mBranch.files, mFull.files, "branch-input file map differs from full-input");
    assert.ok(Object.keys(mFull.files).length >= DEFAULT_TREES.length, "expected a file per tree");
  } finally {
    rmSync(ws.dir, { recursive: true, force: true });
  }
});
