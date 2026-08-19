// worktree-port.mjs — derive a TCP port from a git worktree's absolute path.
//
// Why this exists: playwright.config.ts and serve-dist.mjs used to hardcode
// port 1239, and `webServer.reuseExistingServer: !CI` meant that locally
// ANY process already bound to :1239 was treated as "my dev server" — even a
// sibling git worktree's own docs build. This repo runs many worktrees of
// the SAME monorepo concurrently (each agent gets its own), and more than
// one of them can contain a copy of `elm-m3e/docs`. Two agents on different
// branches would then race to bind :1239 first; the loser's Playwright suite
// silently reused the winner's server and ran assertions against the WRONG
// worktree's rendered markup — surfacing as broad, non-deterministic,
// escalating-with-more-agents test failures that look like flaky
// regressions but aren't.
//
// Fix: hash the worktree's absolute root path into a port. Same worktree,
// same run → same port every time, so `reuseExistingServer` still gives fast
// local iteration. Two DIFFERENT worktree paths hash to different ports with
// overwhelming probability (20000-slot range, single-digit concurrent
// worktrees in practice), so they can no longer collide.
//
// Escape hatch: on the rare hash collision between two worktrees, set
// WORKTREE_PORT_SALT=<n> in one of them to deterministically shift its port.

import { spawnSync } from "node:child_process";

export const PORT_RANGE = { min: 20000, max: 40000 };

// FNV-1a: tiny, dependency-free, stable across Node versions. A
// collision-avoidance hash, not a cryptographic one — that's all this needs.
export function fnv1a(input) {
  let hash = 0x811c9dc5;
  for (let i = 0; i < input.length; i += 1) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return hash >>> 0;
}

export function hashToPort(seed, range = PORT_RANGE, salt = 0) {
  const span = range.max - range.min;
  const hashed = fnv1a(salt ? `${seed}#${salt}` : seed);
  return range.min + (hashed % span);
}

// Side effect isolated here; everything above is pure. Falls back to `cwd`
// itself (still worktree-specific) if `git` is unavailable for any reason.
export function resolveWorktreeRoot(cwd = process.cwd()) {
  const result = spawnSync("git", ["rev-parse", "--show-toplevel"], { cwd, encoding: "utf8" });
  const root = result.status === 0 ? result.stdout.trim() : "";
  return root || cwd;
}

export function resolveWorktreePort(seed = resolveWorktreeRoot()) {
  const salt = Number(process.env.WORKTREE_PORT_SALT || 0);
  return hashToPort(seed, PORT_RANGE, salt);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  console.log(resolveWorktreePort());
}
