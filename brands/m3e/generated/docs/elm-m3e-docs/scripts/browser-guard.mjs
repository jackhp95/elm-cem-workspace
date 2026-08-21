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

// Browser-suite tiers (2026-08-21):
//   • SMOKE (default — the fast local `gate-all` inner loop): only @smoke-tagged
//     tests, a curated handful (~6) that assures the app shell hydrates and a
//     couple of components mount + interact cleanly. Seconds, not minutes. This
//     is deliberately NOT full coverage — it's a fast proxy so `gate-all` stays
//     tight for iteration.
//   • FULL (CI via REQUIRE_CLONE_GATES=1, or RUN_FULL_BROWSER=1 locally): the
//     entire suite — the 53-page all-components sweep, every functional spec,
//     and the @heavy full-catalog renders. This is the real per-component
//     coverage; it MUST run in CI on every branch before merge.
// A caller-supplied grep (process.argv) still composes — Playwright ANDs them.
// RUN_HEAVY=1 is kept as a full-suite alias for back-compat with the earlier
// @heavy-only opt-in.
const runFull = require || process.env.RUN_FULL_BROWSER === "1" || process.env.RUN_HEAVY === "1";
const tierFilter = runFull ? [] : ["--grep", "@smoke"];
console.log(
    runFull
        ? "test:browser: FULL suite (all specs + all-components sweep + @heavy full-catalog renders)"
        : "test:browser: SMOKE subset (@smoke-tagged only) — set RUN_FULL_BROWSER=1 or REQUIRE_CLONE_GATES=1 for the full suite",
);

const res = spawnSync(resolve(DOCS, "node_modules/.bin/playwright"), ["test", ...tierFilter, ...process.argv.slice(2)], {
    cwd: DOCS,
    stdio: "inherit",
});
process.exit(res.status ?? 1);
