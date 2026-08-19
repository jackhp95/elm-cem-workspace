#!/usr/bin/env node
// publish-mirror.test.mjs — proves recordPublish() actually makes a publish
// record DURABLE (reaches a real origin remote, in the same run) instead of
// leaving it as an uncommitted local file — the exact gap that made
// elm-typed-html, elm-html-intermediate-representation, and elm-m3e all
// need manual "Backfilled" notes in tools/publish-mirror-state.json.

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { readState, recordPublish } from "./publish-mirror.mjs";

function sh(cwd, cmd, args) {
  return execFileSync(cmd, args, { cwd, encoding: "utf8" });
}

function initRepo(dir) {
  fs.mkdirSync(dir, { recursive: true });
  sh(dir, "git", ["init", "-q", "-b", "main"]);
  sh(dir, "git", ["config", "user.email", "test@example.com"]);
  sh(dir, "git", ["config", "user.name", "Test"]);
  return dir;
}

// origin.git (bare) <- work (the "workspace" recordPublish operates on)
function makeOriginAndClone(root) {
  const originDir = path.join(root, "origin.git");
  fs.mkdirSync(originDir, { recursive: true });
  sh(originDir, "git", ["init", "-q", "--bare", "-b", "main"]);

  const seedDir = initRepo(path.join(root, "seed"));
  fs.writeFileSync(path.join(seedDir, "README.md"), "seed\n");
  sh(seedDir, "git", ["add", "-A"]);
  sh(seedDir, "git", ["commit", "-q", "-m", "seed"]);
  sh(seedDir, "git", ["remote", "add", "origin", originDir]);
  sh(seedDir, "git", ["push", "-q", "origin", "HEAD:main"]);

  const workDir = path.join(root, "work");
  sh(root, "git", ["clone", "-q", originDir, workDir]);
  sh(workDir, "git", ["config", "user.email", "test@example.com"]);
  sh(workDir, "git", ["config", "user.name", "Test"]);
  return { originDir, workDir };
}

function tmp() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "publish-mirror-test-"));
}

test("recordPublish commits the state file AND pushes it to origin (not just local disk)", () => {
  const root = tmp();
  const { originDir, workDir } = makeOriginAndClone(root);
  const statePath = path.join(workDir, "state.json");

  recordPublish({
    repoRoot: workDir,
    statePath,
    name: "pkg-a",
    workspaceSha: "aaa111",
    mirrorSha: "bbb222bbb222bbb222bbb222bbb222bbb222bbb2",
    publishedAt: "2026-08-18T00:00:00.000Z",
  });

  assert.deepEqual(readState(statePath)["pkg-a"], {
    publishedWorkspaceSha: "aaa111",
    mirrorCommitSha: "bbb222bbb222bbb222bbb222bbb222bbb222bbb2",
    publishedAt: "2026-08-18T00:00:00.000Z",
  });

  // The durability proof: clone origin FRESH into a separate dir and check
  // the record is there too. Before this fix, writeState() only ever wrote
  // to workDir's local disk — a fresh clone of origin would never see it.
  const verifyDir = path.join(root, "verify");
  sh(root, "git", ["clone", "-q", originDir, verifyDir]);
  const verified = JSON.parse(fs.readFileSync(path.join(verifyDir, "state.json"), "utf8"));
  assert.equal(verified["pkg-a"].mirrorCommitSha, "bbb222bbb222bbb222bbb222bbb222bbb222bbb2");
});

test("recordPublish recovers when origin/<branch> advanced since the local clone was made (concurrent publish)", () => {
  const root = tmp();
  const { originDir, workDir } = makeOriginAndClone(root);
  const statePath = path.join(workDir, "state.json");

  // Simulate a second worker pushing an unrelated commit to origin/main
  // *after* workDir cloned but *before* workDir pushes its own record.
  const otherDir = path.join(root, "other");
  sh(root, "git", ["clone", "-q", originDir, otherDir]);
  sh(otherDir, "git", ["config", "user.email", "test@example.com"]);
  sh(otherDir, "git", ["config", "user.name", "Test"]);
  fs.writeFileSync(path.join(otherDir, "unrelated.txt"), "from another publish\n");
  sh(otherDir, "git", ["add", "-A"]);
  sh(otherDir, "git", ["commit", "-q", "-m", "unrelated concurrent commit"]);
  sh(otherDir, "git", ["push", "-q", "origin", "HEAD:main"]);

  // workDir is now behind origin/main — recordPublish must still succeed.
  recordPublish({
    repoRoot: workDir,
    statePath,
    name: "pkg-b",
    workspaceSha: "ccc333",
    mirrorSha: "ddd444ddd444ddd444ddd444ddd444ddd444ddd4",
    publishedAt: "2026-08-18T00:00:00.000Z",
  });

  const verifyDir = path.join(root, "verify");
  sh(root, "git", ["clone", "-q", originDir, verifyDir]);
  assert.ok(fs.existsSync(path.join(verifyDir, "unrelated.txt")), "concurrent commit preserved");
  const verified = JSON.parse(fs.readFileSync(path.join(verifyDir, "state.json"), "utf8"));
  assert.equal(verified["pkg-b"].mirrorCommitSha, "ddd444ddd444ddd444ddd444ddd444ddd444ddd4");
});

test("recordPublish fails loud (not silently) on a genuine merge conflict, leaving the tree clean", () => {
  const root = tmp();
  const { originDir, workDir } = makeOriginAndClone(root);
  const statePath = path.join(workDir, "state.json");
  fs.writeFileSync(statePath, JSON.stringify({ "pkg-c": { mirrorCommitSha: "local-stale" } }, null, 2) + "\n");
  sh(workDir, "git", ["add", "-A"]);
  sh(workDir, "git", ["commit", "-q", "-m", "seed conflicting state.json"]);
  sh(workDir, "git", ["push", "-q", "origin", "HEAD:main"]);

  // Another worker also edits state.json's pkg-c key differently and pushes first.
  const otherDir = path.join(root, "other");
  sh(root, "git", ["clone", "-q", originDir, otherDir]);
  sh(otherDir, "git", ["config", "user.email", "test@example.com"]);
  sh(otherDir, "git", ["config", "user.name", "Test"]);
  fs.writeFileSync(
    path.join(otherDir, "state.json"),
    JSON.stringify({ "pkg-c": { mirrorCommitSha: "remote-conflicting" } }, null, 2) + "\n",
  );
  sh(otherDir, "git", ["add", "-A"]);
  sh(otherDir, "git", ["commit", "-q", "-m", "conflicting edit"]);
  sh(otherDir, "git", ["push", "-q", "origin", "HEAD:main"]);

  assert.throws(
    () =>
      recordPublish({
        repoRoot: workDir,
        statePath,
        name: "pkg-c",
        workspaceSha: "eee555",
        mirrorSha: "fff666fff666fff666fff666fff666fff666fff6",
        publishedAt: "2026-08-18T00:00:00.000Z",
      }),
    /conflicted/,
  );

  // No leftover conflict markers / mid-merge state — a retry could proceed cleanly.
  const status = sh(workDir, "git", ["status", "--porcelain"]).trim();
  assert.equal(status, "");
  assert.equal(fs.existsSync(path.join(workDir, ".git", "MERGE_HEAD")), false);
});

test("recordPublish refuses to run from a detached HEAD instead of pushing to nowhere", () => {
  const root = tmp();
  const { workDir } = makeOriginAndClone(root);
  const statePath = path.join(workDir, "state.json");
  const headSha = sh(workDir, "git", ["rev-parse", "HEAD"]).trim();
  sh(workDir, "git", ["checkout", "-q", headSha]);

  assert.throws(
    () =>
      recordPublish({
        repoRoot: workDir,
        statePath,
        name: "pkg-d",
        workspaceSha: "111aaa",
        mirrorSha: "222bbb222bbb222bbb222bbb222bbb222bbb222b",
      }),
    /detached HEAD/,
  );
});
