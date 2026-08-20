// gen-install-facts.mjs — derive the install-page package identities from the
// REAL package metadata (elm.json / package.json) instead of hand-typed literals
// in `Route.GettingStarted.Installation`. Emits `data/install-facts.json`.
//
// WHY THIS EXISTS
//   The Installation page hardcoded package names and versions. repo-shape-v2
//   renamed the Tailwind bridge package `tailwind-m3e-web` -> `elm-m3e-tailwind`
//   and relocated it, but the install prose still said `tailwind-m3e-web` in the
//   package name and vendor paths — a live drift bug the moment the rename
//   landed. Sourcing the identifiers from metadata means the page follows a
//   rename automatically.
//
// SCOPE (deliberate): this derives the unambiguous package IDENTITIES — the Elm
//   package name, the `@m3e/web` npm package + pinned version, and the Tailwind
//   bridge package name. It does NOT derive prose component COUNTS ("128 typed
//   components"): there is no single authoritative source for that number
//   (the src/M3e/Component tree has 130 modules, the prose says 128, and other
//   pages carry their own hand-tuned counts), so interpolating a derived number
//   risks replacing plausible editorial prose with a WRONG figure. Counts stay
//   prose; identities derive.
//
// PRECONDITION: deterministic (pure function of committed metadata). Gated by
//   scripts/check-data-drift.mjs.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(here, "..");
const REPO = path.resolve(DOCS, "..", "..", "package", "elm-m3e");
const TAILWIND = path.resolve(DOCS, "..", "..", "style", "elm-m3e-tailwind");
const OUT = path.resolve(DOCS, "data/install-facts.json");

const readJson = (p) => JSON.parse(fs.readFileSync(p, "utf8"));
const fail = (msg) => {
  console.error(`gen-install-facts: ${msg}`);
  process.exit(1);
};

const elmJson = readJson(path.resolve(REPO, "elm.json"));
const docsPkg = readJson(path.resolve(DOCS, "package.json"));
const tailwindPkg = readJson(path.resolve(TAILWIND, "package.json"));

const elmPackage = elmJson.name;
if (!elmPackage) fail(`elm-m3e/elm.json has no "name"`);

const webPackage = "@m3e/web";
const webVersion = (docsPkg.dependencies || {})[webPackage] || (docsPkg.devDependencies || {})[webPackage];
if (!webVersion) fail(`${webPackage} not found in the docs package.json dependencies`);

const tailwindPackage = tailwindPkg.name;
if (!tailwindPackage) fail(`elm-m3e-tailwind/package.json has no "name"`);

// The Tailwind bridge is vendored via `git clone`, so the install page needs the
// repo URL + the directory basename the clone produces (so the subsequent `cp`
// reads from the same directory). Both are sourced from the package's own
// `repository.url` — the single source of truth — rather than hand-typed, so a
// repo rename propagates to the docs. `tailwindPackage` (the npm package name)
// and `tailwindRepoDir` (the GitHub repo basename) can legitimately differ:
// repo-shape-v2 renamed the local package but the external mirror repo keeps its
// old name until republished.
const rawRepoUrl = (typeof tailwindPkg.repository === "string" ? tailwindPkg.repository : tailwindPkg.repository?.url) || "";
if (!rawRepoUrl) fail(`elm-m3e-tailwind/package.json has no repository.url`);
const tailwindRepoUrl = rawRepoUrl.replace(/^git\+/, "");
const tailwindRepoDir = tailwindRepoUrl.replace(/\.git$/, "").split("/").pop();

const out = {
  elmPackage, // jackhp95/elm-m3e
  webPackage, // @m3e/web
  webVersion, // e.g. 2.7.6
  tailwindPackage, // elm-m3e-tailwind (was tailwind-m3e-web pre-reshape)
  tailwindRepoUrl, // https://github.com/jackhp95/tailwind-m3e-web.git
  tailwindRepoDir, // tailwind-m3e-web (the clone's directory basename)
};

fs.writeFileSync(OUT, JSON.stringify(out, null, 2) + "\n");
console.log(`gen-install-facts: wrote ${JSON.stringify(out)} to ${path.relative(process.cwd(), OUT)}`);
