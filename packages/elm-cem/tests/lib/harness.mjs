// Shared test-harness plumbing for tests/*.test.mjs.
//
// 12+ files in this directory independently re-declared the same `here`/`repo`
// path resolution plus a failures-counter/ok/check/exit-summary mechanism — see
// Theme 3 of the 2026-08-17 audit
// (docs/reviews/2026-08-17-thermonuclear-workspace-review.md). tests/phantom/
// suites.mjs already proved the right pattern here: a shared module computing
// its paths relative to ITS OWN import.meta.url so every caller agrees. This
// extends that pattern to the check/ok/exit boilerplate the other suites in
// this directory kept re-typing by hand.
//
// `repo` is safe to share because every tests/*.test.mjs file resolves to the
// same absolute path (`tests/..` == `tests/lib/../..`); a file's own `here`
// (its own directory) is NOT shareable and must still be computed locally by
// any file that needs it for something beyond deriving `repo`.

import path from "node:path";
import { fileURLToPath } from "node:url";

export const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

// The `<label>: OK — <msg>` / `<label>: FAIL — <msg>` style used by
// check-gates.test.mjs, gates.test.mjs, eject.test.mjs, depstamp.test.mjs,
// registry-check-nested-pkg.test.mjs and bin-entrypoints.test.mjs.
export function makeCheck(label) {
  let failures = 0;
  const ok = (msg) => console.log(`${label}: OK — ${msg}`);
  const check = (cond, msg, extra = "") => {
    if (cond) {
      ok(msg);
    } else {
      failures += 1;
      console.error(`${label}: FAIL — ${msg}${extra ? "\n" + extra : ""}`);
    }
  };
  const finish = (passMessage, failWord = "FAILURE(S)") => {
    if (failures > 0) {
      console.error(`\n${label}: ${failures} ${failWord}`);
      process.exit(1);
    }
    console.log(passMessage);
  };
  return { check, ok, finish };
}

// The unlabelled `  PASS  <msg>` / `  FAIL  <msg>` style used by
// enum-override.test.mjs, attr-property.test.mjs and
// facts-bundle-schema.test.mjs. Each of those files' own exit/summary wording
// differs enough (leading newline, "FAIL —" infix, pluralization) that it stays
// file-local; `failureCount()` is what they read to write it.
export function makePlainCheck() {
  let failures = 0;
  const check = (cond, msg) => {
    if (cond) {
      console.log(`  PASS  ${msg}`);
    } else {
      console.error(`  FAIL  ${msg}`);
      failures += 1;
    }
  };
  return { check, failureCount: () => failures };
}
