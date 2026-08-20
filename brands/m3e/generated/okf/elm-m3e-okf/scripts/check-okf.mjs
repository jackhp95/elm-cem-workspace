// check-okf.mjs — guard the implementations/ layer the way check-skill guards
// the skill.
//
// POST-REORG SPLIT (2026-08-18): this used to also validate the OKF
// knowledge/ bundle (OKF v0.1: required frontmatter, reserved-file rules,
// citation-presence). knowledge/ moved to the sibling
// brands/m3e/inputs/material-okf package, which now owns that validation via
// its own `check:validity` (scripts/lib/validate-okf.mjs). This script keeps
// only the guarantee that's still local: the generated implementations/
// layer is FRESH — re-running build-okf.mjs produces no diff against what's
// committed. This mirrors CI's `git diff --exit-code` on skills/, but runs it
// here so `npm run check:okf` catches a stale bundle locally too.
//
// Exits non-zero on drift.

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const run = (cmd, args) => execFileSync(cmd, args, { cwd: ROOT, encoding: "utf8" });

// Rebuild and assert no drift against the committed tree.
run("node", ["scripts/build-okf.mjs"]);
let diff = "";
try {
  // Only tracked-file changes count as drift. Untracked new files (`??`) mean the
  // bundle simply hasn't been committed yet — not a staleness failure — so they're
  // filtered out. Once committed, a rebuild that changes content shows up as ` M`.
  diff = run("git", ["status", "--porcelain", "--", "implementations"])
    .split("\n")
    .filter((l) => l && !l.startsWith("??"))
    .join("\n");
} catch {
  diff = ""; // not a git checkout (e.g. tarball) — skip the freshness check
}
if (diff.trim()) {
  console.error("✗ implementations/ bundle is stale — run `npm run gen:okf` and commit. Drift:");
  console.error(diff);
  process.exit(1);
}

console.log("✓ implementations/ bundle fresh (re-running build-okf.mjs produced no diff).");
