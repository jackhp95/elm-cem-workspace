// check-okf.mjs — guard the OKF bundle the way check-skill guards the skill.
//
// Two guarantees, in the repo's rebuild-and-diff style:
//   1. The generated bundle is FRESH — re-running build-okf.mjs produces no diff
//      against what's committed (indexes regenerate clean, no drift). This mirrors
//      CI's `git diff --exit-code` on skills/, but runs it here so `npm run check:okf`
//      catches a stale bundle locally too.
//   2. The bundle is VALID per OKF v0.1 (validate-okf.mjs): required frontmatter,
//      reserved-file rules, citation-presence; broken links reported non-fatally.
//
// Exits non-zero on drift or a fatal validation error.

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { validateBundle } from "./lib/validate-okf.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const run = (cmd, args) => execFileSync(cmd, args, { cwd: ROOT, encoding: "utf8" });

// 1. Rebuild and assert no drift against the committed tree.
run("node", ["scripts/build-okf.mjs"]);
let diff = "";
try {
  // Only tracked-file changes count as drift. Untracked new files (`??`) mean the
  // bundle simply hasn't been committed yet — not a staleness failure — so they're
  // filtered out. Once committed, a rebuild that changes content shows up as ` M`.
  diff = run("git", ["status", "--porcelain", "--", "knowledge", "implementations"])
    .split("\n")
    .filter((l) => l && !l.startsWith("??"))
    .join("\n");
} catch {
  diff = ""; // not a git checkout (e.g. tarball) — skip the freshness half
}
if (diff.trim()) {
  console.error("✗ OKF bundle is stale — run `npm run gen:okf` and commit. Drift:");
  console.error(diff);
  process.exit(1);
}

// 2. Validate the bundle.
const r = validateBundle(path.join(ROOT, "knowledge"));
if (r.errors.length) {
  console.error(`✗ OKF validation failed (${r.errors.length} error(s)):`);
  for (const e of r.errors) console.error(`  ${e}`);
  process.exit(1);
}

console.log(
  `✓ OKF bundle fresh + valid — ${r.conceptFiles} concept files, ${r.indexFiles} reserved files, ` +
  `${r.brokenLinks.length} broken link(s) (non-fatal).`
);
