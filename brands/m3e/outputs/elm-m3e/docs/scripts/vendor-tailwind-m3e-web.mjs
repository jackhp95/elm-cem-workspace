#!/usr/bin/env node
// Re-vendor the CSS surface of the co-located tailwind-m3e-web package into
// docs/vendor/tailwind-m3e-web, which docs/style.css imports via relative
// paths instead of the bare "tailwind-m3e-web" specifier.
//
// WHY THIS EXISTS
//   docs/style.css used to `@import "tailwind-m3e-web"` / "tailwind-m3e-web/utilities",
//   resolved via the pnpm workspace link to the sibling packages/tailwind-m3e-web
//   package. That works in this monorepo, but the docs site is ALSO deployed on
//   Netlify from the standalone published mirror repo jackhp95/elm-m3e (see
//   tools/publish-mirror.mjs), which does not contain a sibling
//   tailwind-m3e-web package — so `pnpm install` in the mirror fails with
//   ERR_PNPM_WORKSPACE_PKG_NOT_FOUND. We vendor a committed copy of the CSS
//   instead, same as docs/vendor/elm-foundation vendors HtmlIr.*/TypedHtml.*
//   Elm source for the same reason (see vendor-foundation.mjs).
//
// WHAT GETS VENDORED
//   Only the CSS files actually reachable from the two entry points docs/
//   imports — src/index.css (the default barrel) and generated/utilities.css
//   (the component-utility surface) — walked by following each file's
//   `@import "./relative.css"` graph. As of writing that is:
//     src/index.css
//     src/seed.css
//     src/ref/palette.css
//     src/ref/_tone-table.css
//     src/sys/color.css, typescale.css, motion.css, shape.css, elevation.css,
//       state.css, density.css
//     src/theme.css
//     src/density.css
//     generated/utilities.css
//   roles-extended.css (an opt-in extra docs does not import) and
//   test/fixtures/**, utilities-private.template.css (not part of the CSS
//   @import graph) are deliberately NOT vendored.
//
// WHEN TO RUN
//   After changing tailwind-m3e-web's CSS, run:
//     pnpm run gen:vendor-tailwind
//   (or the umbrella `pnpm run gen:vendor`, which runs this alongside
//   vendor-foundation.mjs) then commit the refreshed
//   docs/vendor/tailwind-m3e-web/. The COMMITTED copy is what CI/Netlify use —
//   this script is a local-dev sync convenience, never run on CI.
//
// The sibling package is expected next to elm-m3e (../../ from docs/):
//   ../../tailwind-m3e-web
// Override with env var TAILWIND_M3E_WEB_SRC if it lives elsewhere.

import { cpSync, rmSync, mkdirSync, existsSync, readdirSync, statSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url)); // docs/scripts
const docsDir = resolve(here, "..");
const vendorDir = join(docsDir, "vendor", "tailwind-m3e-web");

export const tailwindM3eWebSrc =
  process.env.TAILWIND_M3E_WEB_SRC ?? resolve(docsDir, "..", "..", "tailwind-m3e-web");

// Files vendored, relative to the package root, mirroring the src/ and
// generated/ structure so the relative @imports inside them keep resolving.
export const VENDORED_FILES = [
  "src/index.css",
  "src/seed.css",
  "src/density.css",
  "src/theme.css",
  "src/ref/palette.css",
  "src/ref/_tone-table.css",
  "src/sys/color.css",
  "src/sys/typescale.css",
  "src/sys/motion.css",
  "src/sys/shape.css",
  "src/sys/elevation.css",
  "src/sys/state.css",
  "src/sys/density.css",
  "generated/utilities.css",
];

/**
 * Copy the CSS @import-graph files from `srcPkg` (a tailwind-m3e-web package
 * root) into `targetDir`, exactly as the CLI below does for
 * docs/vendor/tailwind-m3e-web. Throws (does not process.exit) on a missing
 * source, so callers — the check:vendor scratch-dir comparison included — can
 * handle the failure themselves.
 */
export function copyTailwindM3eWebInto(targetDir, { srcPkg = tailwindM3eWebSrc } = {}) {
  if (!existsSync(srcPkg)) {
    throw new Error(
      `tailwind-m3e-web source not found at ${srcPkg}\n` +
        `  Clone the sibling package next to elm-m3e, or set TAILWIND_M3E_WEB_SRC.`,
    );
  }

  // Fresh tree every run so deletions/renames upstream propagate.
  rmSync(targetDir, { recursive: true, force: true });
  mkdirSync(targetDir, { recursive: true });

  for (const rel of VENDORED_FILES) {
    const from = join(srcPkg, rel);
    if (!existsSync(from)) {
      throw new Error(`expected vendored file missing from source: ${from}`);
    }
    const to = join(targetDir, rel);
    mkdirSync(dirname(to), { recursive: true });
    cpSync(from, to);
  }
}

function fail(msg) {
  console.error(`vendor-tailwind-m3e-web: ${msg}`);
  process.exit(1);
}

function countCss(dir) {
  let n = 0;
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) n += countCss(p);
    else if (entry.endsWith(".css")) n += 1;
  }
  return n;
}

function main() {
  try {
    copyTailwindM3eWebInto(vendorDir);
  } catch (err) {
    fail(err.message);
  }

  console.log(
    `vendor-tailwind-m3e-web: refreshed ${vendorDir}\n` +
      `  from: ${tailwindM3eWebSrc}\n` +
      `  ${countCss(vendorDir)} .css files vendored.`,
  );
}

// Only run as a script — importing this module (e.g. from check-vendor-drift.mjs)
// must never mutate docs/vendor/tailwind-m3e-web as a side effect.
if (fileURLToPath(import.meta.url) === process.argv[1]) {
  main();
}
