#!/usr/bin/env node
// check-gates rule 4 — core.hooksPath must point at THIS repo's own hooks/
// directory, or every other rule check-gates enforces is itself unenforced:
// nothing ever calls `elm-cem check-gates` (or `npm run gate`) on push unless
// hooks/pre-push is actually wired in via core.hooksPath. See bin/check-gates.js.
//
// Proves:
//   - hooks/ absent → the rule does not fire (nothing to install).
//   - directory is not a git repo at all → the rule does not fire (git itself
//     is unavailable to ask), and check-gates does not crash or hang.
//   - hooks/ present + core.hooksPath unset, or pointing at some other
//     directory → FAIL, naming the problem and the remedy.
//   - hooks/ present + core.hooksPath=hooks (the conventional relative value)
//     → PASS.
//   - the same, run from inside a git WORKTREE whose SHARED config carries
//     core.hooksPath=hooks → PASS with no special-casing, because git resolves
//     a relative core.hooksPath against each worktree's own top level. This is
//     the scenario the fix exists to get right.
//   - a gate-waivers.json entry keyed `hooks#core.hooksPath` with a reason
//     waives the rule, via the same check(id, message) mechanism rules 1–3 use.
//
// Run standalone: `node tests/check-gates.test.mjs`

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo, makeCheck } from "./lib/harness.mjs";

const cli = path.join(repo, "bin", "elm-cem.js");

const { check, finish } = makeCheck("check-gates-test");

// CRITICAL isolation: this test creates throwaway git repos + worktrees under
// os.tmpdir() and drives them with `git init/commit/worktree add` and an
// `elm-cem check-gates` run. Git honours the GIT_DIR / GIT_WORK_TREE family of
// env vars OVER cwd-based repo discovery — and a git hook (pre-push) sets
// GIT_DIR to the REAL repo's .git for everything it spawns. Running this test
// under gate-all-under-pre-push therefore inherited GIT_DIR and made every
// "temp repo" git command operate on the real workspace repo instead — which
// once reset the working branch to a seed commit and got it pushed. Strip the
// whole GIT_* location family so these spawns always resolve the temp repo from
// cwd, no matter what the parent environment set.
const ISOLATED_GIT_ENV = (() => {
  const e = { ...process.env };
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
    delete e[k];
  }
  // Belt-and-suspenders: forbid upward repo discovery past the temp root, so a
  // temp dir that somehow lands under a real checkout still can't reach it.
  e.GIT_CEILING_DIRECTORIES = os.tmpdir();
  return e;
})();

// A minimal package.json that is already clean under rules 1–3: `check:x` is
// the only check:*/test:* script, and `gate` reaches it. Without this, rule 1
// would fire on every fixture and drown out the rule-4 assertions this file
// exists to make.
const CLEAN_SCRIPTS = {
  gate: "npm run check",
  check: 'run-p "check:*"',
  "check:x": "true",
};

const tmpDirs = [];
function mkTmp(prefix) {
  const d = fs.mkdtempSync(path.join(os.tmpdir(), prefix));
  tmpDirs.push(d);
  return d;
}

function writePkg(dir, scripts = CLEAN_SCRIPTS) {
  fs.writeFileSync(path.join(dir, "package.json"), JSON.stringify({ scripts }, null, 2));
}

function writeHooks(dir) {
  fs.mkdirSync(path.join(dir, "hooks"), { recursive: true });
  fs.writeFileSync(path.join(dir, "hooks", "pre-push"), "#!/bin/sh\nexit 0\n", { mode: 0o755 });
}

function git(args, cwd) {
  return spawnSync("git", args, { cwd, encoding: "utf8", env: ISOLATED_GIT_ENV });
}

function runCheckGates(cwd) {
  // check-gates itself shells out to git, so it needs the same isolation.
  return spawnSync("node", [cli, "check-gates"], { cwd, encoding: "utf8", env: ISOLATED_GIT_ENV });
}

try {
  // 1. hooks/ present, core.hooksPath UNSET → FAIL, and the message names the key.
  {
    const dir = mkTmp("elm-cem-cg-unset-");
    writePkg(dir);
    git(["init", "-q"], dir);
    writeHooks(dir);

    const r = runCheckGates(dir);
    check(r.status === 1, "hooks/ present + core.hooksPath unset -> exit 1", r.stdout + r.stderr);
    check(/core\.hooksPath/.test(r.stdout + r.stderr), "failure output names core.hooksPath", r.stdout + r.stderr);
  }

  // 2. Same repo, core.hooksPath=hooks (the conventional relative value) → PASS.
  {
    const dir = mkTmp("elm-cem-cg-set-");
    writePkg(dir);
    git(["init", "-q"], dir);
    writeHooks(dir);
    git(["config", "core.hooksPath", "hooks"], dir);

    const r = runCheckGates(dir);
    check(r.status === 0, "core.hooksPath=hooks -> exit 0", r.stdout + r.stderr);
  }

  // 3. core.hooksPath points at some OTHER directory → FAIL.
  {
    const dir = mkTmp("elm-cem-cg-wrong-");
    writePkg(dir);
    git(["init", "-q"], dir);
    writeHooks(dir);
    fs.mkdirSync(path.join(dir, "not-hooks"));
    git(["config", "core.hooksPath", "not-hooks"], dir);

    const r = runCheckGates(dir);
    check(r.status === 1, "core.hooksPath pointing at another directory -> exit 1", r.stdout + r.stderr);
  }

  // 4. hooks/ ABSENT, hooksPath unset → nothing to install, so the rule must not
  // fire at all → PASS.
  {
    const dir = mkTmp("elm-cem-cg-nohooks-");
    writePkg(dir);
    git(["init", "-q"], dir);

    const r = runCheckGates(dir);
    check(r.status === 0, "hooks/ absent -> rule does not fire, exit 0", r.stdout + r.stderr);
  }

  // 5. hooks/ present + hooksPath unset, but a waiver with a reason is on file →
  // PASS, and stdout reports the waiver — the same mechanism rules 1–3 use.
  {
    const dir = mkTmp("elm-cem-cg-waived-");
    writePkg(dir);
    git(["init", "-q"], dir);
    writeHooks(dir);
    fs.writeFileSync(
      path.join(dir, "gate-waivers.json"),
      JSON.stringify(
        { "hooks#core.hooksPath": "sandboxed checkout — hooks cannot be installed here, tracked in #NN" },
        null,
        2
      )
    );

    const r = runCheckGates(dir);
    check(r.status === 0, "waived hooksPath rule -> exit 0", r.stdout + r.stderr);
    check(/hooks#core\.hooksPath/.test(r.stdout), "stdout reports the waiver id", r.stdout);
  }

  // 6. Worktrees. core.hooksPath lives in the SHARED config, so a worktree
  // inherits it. With the conventional relative value `hooks`, git resolves that
  // against the working tree's OWN top level — i.e. the WORKTREE's hooks/, not
  // the parent's. This is the case the fix exists to prove: no special-casing
  // for worktrees should be needed for it to pass.
  {
    const parent = mkTmp("elm-cem-cg-wtparent-");
    writePkg(parent);
    git(["init", "-q"], parent);
    git(["config", "user.email", "test@example.com"], parent);
    git(["config", "user.name", "Test"], parent);
    git(["add", "-A"], parent);
    const commit = git(["commit", "-q", "-m", "init"], parent);
    check(commit.status === 0, "parent repo commits", commit.stdout + commit.stderr);
    git(["config", "core.hooksPath", "hooks"], parent);

    const worktreeDir = path.join(parent, "..", path.basename(parent) + "-wt");
    const wt = git(["worktree", "add", worktreeDir, "-b", "elm-cem-cg-wt-branch"], parent);
    check(wt.status === 0, "git worktree add succeeds", wt.stdout + wt.stderr);
    tmpDirs.push(worktreeDir);

    // hooks/ is deliberately NOT part of the commit; copy it into the worktree
    // explicitly, proving the rule reads live filesystem state, not history.
    writeHooks(parent);
    fs.cpSync(path.join(parent, "hooks"), path.join(worktreeDir, "hooks"), { recursive: true });

    const r = runCheckGates(worktreeDir);
    check(r.status === 0, "check-gates run from inside a worktree passes with no special-casing", r.stdout + r.stderr);
  }

  // 7. Not a git repository at all → the hooksPath rule must not fire (and
  // check-gates must never crash or hang trying to ask git). The other three
  // rules still run against a clean package.json, so the overall result is a
  // plain PASS.
  {
    const dir = mkTmp("elm-cem-cg-notgit-");
    writePkg(dir);
    writeHooks(dir);
    // deliberately no `git init`

    const r = runCheckGates(dir);
    check(r.status === 0, "non-git directory -> hooksPath rule does not fire, exit 0", r.stdout + r.stderr);
  }

  // 8. Beyond the minimum: core.hooksPath set to an ABSOLUTE path that resolves
  // to this repo's own hooks/ directory must ALSO pass — the spec requires this
  // explicitly, and it is a distinct code path (isAbsolute) from cases 1–7, which
  // only ever exercise the conventional relative value.
  {
    const dir = mkTmp("elm-cem-cg-abs-");
    writePkg(dir);
    git(["init", "-q"], dir);
    writeHooks(dir);
    git(["config", "core.hooksPath", path.join(dir, "hooks")], dir);

    const r = runCheckGates(dir);
    check(r.status === 0, "core.hooksPath as an absolute path to the same dir -> exit 0", r.stdout + r.stderr);
  }
} finally {
  for (const d of tmpDirs) fs.rmSync(d, { recursive: true, force: true });
}

finish("\ncheck-gates-test: ALL CHECKS PASSED");
