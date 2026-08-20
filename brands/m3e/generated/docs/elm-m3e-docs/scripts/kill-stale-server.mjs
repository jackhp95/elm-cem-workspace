#!/usr/bin/env node
// kill-stale-server.mjs — pretest:browser hook.
//
// Frees THIS worktree's derived port (scripts/worktree-port.mjs) before
// Playwright boots its webServer, so a leftover process from a previous
// crashed/interrupted run doesn't get silently reused as "fresh."
//
// Deliberately scoped to this worktree's OWN derived port, never a hardcoded
// one — the old `lsof -ti:1239 | xargs kill -9` version could kill a SIBLING
// worktree's legitimately-running dev/test server out from under it, or fail
// to kill anything useful if some unrelated process happened to hold :1239.
import { execSync } from "node:child_process";
import { resolveWorktreePort } from "./worktree-port.mjs";

const port = resolveWorktreePort();

try {
  const pids = execSync(`lsof -ti:${port}`, { encoding: "utf8" }).trim();
  if (pids) {
    execSync(`kill -9 ${pids.split("\n").join(" ")}`);
    // Give the OS a moment to release the socket before Playwright rebinds it.
    execSync("sleep 1");
    console.log(`pretest:browser: freed stale process(es) on :${port} (this worktree's derived port)`);
  }
} catch {
  // lsof exits non-zero when nothing is listening on this worktree's port —
  // nothing to free, which is the common case.
}
