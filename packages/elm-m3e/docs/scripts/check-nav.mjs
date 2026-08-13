#!/usr/bin/env node
// Guards the docs drawer against dead links and silent nav gaps. The drawer's
// component list is DERIVED (not hand-maintained): every reference.json
// entry that `config/categories.json` gives a category is a nav component. This
// script re-derives that same set and checks (a) every nav slug resolves to a
// pre-rendered page, and (b) warns about example-bearing pages the drawer never
// links to — a category typo or a missing page is what would break nav.
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const HERE = dirname(fileURLToPath(import.meta.url));
const DOCS = resolve(HERE, "..");

// data/reference.json and data/examples.json are GENERATED, gitignored docs
// artifacts (produced by the docs build pipeline: gen:vendor + gen:reference).
// A fresh clone that has only run `pnpm install` does not have them, so this
// nav check has nothing to verify. Skip-with-reason rather than crash on
// ENOENT; on the dev machine and in CI (where the pipeline has run, or
// REQUIRE_CLONE_GATES=1 is set) it runs for real. See R-023.
const referencePath = resolve(DOCS, "data/reference.json");
const examplesPath = resolve(DOCS, "data/examples.json");
if (!existsSync(referencePath) || !existsSync(examplesPath)) {
    const missing = [referencePath, examplesPath].filter((p) => !existsSync(p)).map((p) => p.replace(DOCS + "/", ""));
    if (process.env.REQUIRE_CLONE_GATES === "1") {
        console.error(`check-nav: ${missing.join(", ")} absent and REQUIRE_CLONE_GATES=1 — run the docs build (gen:vendor + gen:reference) first.`);
        process.exit(1);
    }
    console.log(`SKIP: check-nav — generated docs data absent (${missing.join(", ")}); it is produced by the full docs build in a dev environment (examples.json is not cold-reproducible), so this gate only runs there or in CI with REQUIRE_CLONE_GATES=1`);
    process.exit(0);
}

const reference = JSON.parse(readFileSync(referencePath, "utf8"));
const examples = JSON.parse(readFileSync(examplesPath, "utf8"));

const pageSlugs = new Set(reference.map((c) => c.slug));
const exampleSlugs = new Set(Object.keys(examples));

// The nav components: every reference entry carrying a (non-empty) category,
// exactly what Shared.elm's derived drawer renders.
const navSlugs = reference.filter((c) => c.category).map((c) => c.slug);

if (navSlugs.length === 0) {
  console.error(
    "check-nav: 0 categorised components in reference.json — the categories.json " +
      "join or the reference build changed"
  );
  process.exit(1);
}

const dead = navSlugs.filter((s) => !pageSlugs.has(s));
const missingFromNav = [...exampleSlugs].filter((s) => !navSlugs.includes(s));

if (missingFromNav.length) {
  console.warn(
    `check-nav: WARNING — ${missingFromNav.length} example-bearing page(s) not in nav: ` +
      missingFromNav.sort().join(", ")
  );
}

if (dead.length) {
  console.error(
    `check-nav: FAIL — ${dead.length} drawer link(s) point at non-existent pages: ` +
      dead.sort().join(", ")
  );
  process.exit(1);
}

console.log(`check-nav: OK — ${navSlugs.length} drawer links all resolve.`);
