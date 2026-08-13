#!/usr/bin/env node
// okf-update.mjs — deterministic m3e-okf self-update.
//
// Keeps a consumer's m3e-okf checkout current WITHOUT ever clobbering local
// work. Emits a JSON status on stdout; only mutates the repo in the safe
// fast-forward case. Everything else is reported for the LLM-in-the-loop
// (the `updating-okf` skill) to turn local divergence into a PR.
//
// States:
//   current    HEAD == origin/main, clean tree            → no-op
//   updated    behind only, clean tree                    → git merge --ff-only (done here)
//   diverged   local commits ahead, OR dirty tree         → DO NOT touch; skill opens a PR
//   error      git/fetch failed                           → reported, no mutation
//
// Rationale for `diverged`: a modified local checkout means the user fixed
// something on their machine. That's signal, not garbage — it must be
// preserved and upstreamed as a PR, never overwritten by an update.
//
// Usage: node scripts/okf-update.mjs [--repo <path>] [--no-fetch]
// Zero deps beyond node builtins + git.

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const argv = process.argv.slice(2);
const repoArg = (argv[argv.indexOf("--repo") + 1] && !argv[argv.indexOf("--repo") + 1].startsWith("--")) ? argv[argv.indexOf("--repo") + 1] : null;
const noFetch = argv.includes("--no-fetch");
const REPO = repoArg || path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const git = (...a) => execFileSync("git", ["-C", REPO, ...a], { encoding: "utf8" }).trim();
const out = (o) => { process.stdout.write(JSON.stringify(o, null, 2) + "\n"); process.exit(o.state === "error" ? 1 : 0); };

let branch, local, remote, dirty, ahead, behind;
try {
  branch = git("rev-parse", "--abbrev-ref", "HEAD");
  if (!noFetch) git("fetch", "--quiet", "origin", "main");
  local = git("rev-parse", "HEAD");
  remote = git("rev-parse", "origin/main");
  dirty = git("status", "--porcelain").length > 0;
  ahead = git("rev-list", "--count", "origin/main..HEAD") | 0;
  behind = git("rev-list", "--count", "HEAD..origin/main") | 0;
} catch (e) {
  out({ state: "error", repo: REPO, error: String(e.message || e).split("\n")[0] });
}

const base = { repo: REPO, branch, local, remote, ahead, behind, dirty };

// Divergence (local commits and/or uncommitted work) → preserve + escalate to PR.
if (ahead > 0 || dirty) {
  out({
    ...base,
    state: "diverged",
    action: "none",
    guidance:
      "Local checkout has changes not on origin/main" +
      (ahead ? ` (${ahead} local commit(s))` : "") +
      (dirty ? " (uncommitted working-tree changes)" : "") +
      ". These are the user's own fixes — DO NOT reset/clobber. The `updating-okf` skill should: " +
      "branch from HEAD, commit any uncommitted changes, push the branch, open a PR against main, " +
      "then resolve any merge conflicts (LLM-in-the-loop).",
  });
}

if (behind === 0) out({ ...base, state: "current", action: "none" });

// Clean + strictly behind → fast-forward. This is the only mutating path.
try {
  git("merge", "--ff-only", "origin/main");
  out({ ...base, state: "updated", action: "fast-forward", newHead: git("rev-parse", "HEAD") });
} catch (e) {
  out({ ...base, state: "error", error: "ff-only merge failed: " + String(e.message || e).split("\n")[0] });
}
