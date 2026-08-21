#!/usr/bin/env node
// browser-guard.mjs — run the Playwright browser suite, but SKIP-with-reason
// when its heavy preconditions are absent from a fresh clone.
//
// `playwright test` here builds and serves the whole docs site as its
// webServer (playwright.config.ts: `npm run build:site && ... npm run serve`),
// which needs the GENERATED docs inputs (data/reference.json et al., produced
// by gen:vendor + gen:reference) AND the Playwright browser binaries
// (`npx playwright install`). A bare `pnpm install` clone has neither, so the
// suite cannot run. Skipping it keeps `node tools/gate-all.mjs` green-with-a-
// documented-skip off the migration machine, instead of a hard failure nobody
// on a fresh checkout can act on. On the dev machine and in CI — where the
// docs pipeline has run, or REQUIRE_CLONE_GATES=1 is set — it runs for real.
// See R-023.

import { existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const DOCS = resolve(HERE, "..");

const require = process.env.REQUIRE_CLONE_GATES === "1";
const referencePath = resolve(DOCS, "data/reference.json");
const missing = [];
if (!existsSync(referencePath)) missing.push("data/reference.json (generated docs input)");
if (!existsSync(resolve(DOCS, "node_modules/.bin/playwright"))) missing.push("@playwright/test binary");

if (missing.length > 0 && !require) {
    console.log(`SKIP: test:browser — ${missing.join(", ")} absent; the browser suite runs in a dev environment (docs data built + 'npx playwright install') or in CI with REQUIRE_CLONE_GATES=1`);
    process.exit(0);
}
if (missing.length > 0 && require) {
    console.error(`test:browser: ${missing.join(", ")} absent and REQUIRE_CLONE_GATES=1 — provision the docs pipeline and browsers first.`);
    process.exit(1);
}

// The @heavy tests (full-catalog kitchen-sink renders — e.g. /components/all's
// ~2200-upgrade page) are broad smoke nets whose per-component depth is already
// covered by all-components.spec.ts + usage.spec.ts. They dominate local
// `gate-all` wall time, so the fast local gate excludes them; CI
// (REQUIRE_CLONE_GATES=1) and an explicit RUN_HEAVY=1 run the full suite so
// full-scale-mount coverage is never lost. `--grep-invert` is prepended so a
// caller-supplied grep still composes (Playwright ANDs the two).
const runHeavy = require || process.env.RUN_HEAVY === "1";
const heavyFilter = runHeavy ? [] : ["--grep-invert", "@heavy"];
if (!runHeavy) {
    console.log("test:browser: excluding @heavy full-catalog tests (fast local gate) — set RUN_HEAVY=1 or REQUIRE_CLONE_GATES=1 to include them");
}

const res = spawnSync(resolve(DOCS, "node_modules/.bin/playwright"), ["test", ...heavyFilter, ...process.argv.slice(2)], {
    cwd: DOCS,
    stdio: "inherit",
});
process.exit(res.status ?? 1);
