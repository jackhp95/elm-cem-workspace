// check:review guard — elm-review over the docs needs the elm-pages ROUTER
// wiring in `.elm-pages/` (Main.elm/Route.elm/…), which imports the framework
// entry modules (Api, ErrorPage, Shared, Site, Route.*). That wiring is
// generated (`elm-pages gen`) and gitignored — absent, `NoUnused.Modules`/
// `Exports` flag every framework module as "never used" (false positives).
//
// So this guard generates the router first, then runs elm-review. If the router
// codegen can't run (a bare clone lacking docs inputs / elm-pages deps), the
// gate SKIPs with a reason — the same docs-pipeline-not-built pattern as
// check:nav / browser-guard / check:drift (R-023). REQUIRE_CLONE_GATES=1 turns
// the skip into a hard failure for a CI that provisions the docs pipeline.
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const DOCS = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const require1 = process.env.REQUIRE_CLONE_GATES === "1";
const router = resolve(DOCS, ".elm-pages/Main.elm");

function skipOrFail(why) {
    if (require1) {
        console.error(`check:review: ${why} and REQUIRE_CLONE_GATES=1 — provision the docs pipeline (pnpm --filter elm-m3e-docs run gen) first.`);
        process.exit(1);
    }
    console.log(`check:review: SKIP — ${why}. The elm-pages router wiring (.elm-pages/) is generated + gitignored; elm-review over docs needs it. Runs for real where the docs build is provisioned (or REQUIRE_CLONE_GATES=1). See R-023.`);
    process.exit(0);
}

// 1. Generate the elm-pages router wiring (idempotent; writes only to gitignored .elm-pages/).
const gen = spawnSync("npx", ["--no-install", "elm-pages", "gen"], { cwd: DOCS, stdio: "inherit" });
if (gen.status !== 0 || !existsSync(router)) {
    skipOrFail("elm-pages router codegen unavailable");
}

// 2. Run elm-review for real.
const review = spawnSync(
    "elm-review",
    ["--config", "../review", "--compiler", "node_modules/.bin/elm"],
    { cwd: DOCS, stdio: "inherit", env: { ...process.env, PATH: `${resolve(DOCS, "node_modules/.bin")}:${process.env.PATH || ""}` } }
);
process.exit(review.status ?? 1);
