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
//
// POST-REORG SPLIT (2026-08-18): the brand-neutral color-science files
// (seed.css, ref/*, theme.css) moved out of tailwind-m3e-web into the new
// core/tailwind-md3 package. This script now vendors from TWO source roots —
// tailwindM3eWebSrc for the brand-specific files (sys/*, density.css,
// generated/utilities.css) and tailwindMd3Src for the files that moved.
// Override with TAILWIND_MD3_SRC if it lives elsewhere. "src/index.css" is
// NOT byte-copied from either source: the real tailwind-m3e-web/src/index.css
// now `@import`s the bare "tailwind-md3" specifier, which the standalone
// mirror build cannot resolve (no node_modules/tailwind-md3 there). The
// vendored copy gets a self-contained barrel instead (INDEX_CSS_CONTENT
// below), inlining the same import graph via the relative paths the
// vendoring flattens into one directory.

import { cpSync, rmSync, mkdirSync, existsSync, readdirSync, statSync, writeFileSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url)); // docs/scripts
const docsDir = resolve(here, "..");
const vendorDir = join(docsDir, "vendor", "tailwind-m3e-web");

export const tailwindM3eWebSrc =
  process.env.TAILWIND_M3E_WEB_SRC ?? resolve(docsDir, "..", "..", "..", "..", "..", "brands", "m3e", "outputs", "tailwind-m3e-web");
export const tailwindMd3Src =
  process.env.TAILWIND_MD3_SRC ?? resolve(docsDir, "..", "..", "..", "..", "..", "core", "tailwind-md3");

// Files vendored, relative to their OWN package root, mirroring the src/ and
// generated/ structure so the relative @imports inside them keep resolving.
// Split by which source package now owns each file post-reorg.
export const VENDORED_FILES_M3E_WEB = [
  "src/density.css",
  "src/sys/color.css",
  "src/sys/typescale.css",
  "src/sys/motion.css",
  "src/sys/shape.css",
  "src/sys/elevation.css",
  "src/sys/state.css",
  "src/sys/density.css",
  "generated/utilities.css",
];
export const VENDORED_FILES_MD3 = [
  "src/seed.css",
  "src/theme.css",
  "src/ref/palette.css",
  "src/ref/_tone-table.css",
];
// Back-compat export: the full combined list (including the synthesized
// src/index.css), for anything still importing it.
export const VENDORED_FILES = ["src/index.css", ...VENDORED_FILES_M3E_WEB, ...VENDORED_FILES_MD3];

// Self-contained vendored barrel — mirrors the pre-reorg (single-package)
// index.css import graph. Every import here is relative, resolving fine
// within the flattened vendored tree regardless of which real package a
// given file was copied from.
const INDEX_CSS_CONTENT = `/*
 * Vendored barrel for the standalone published mirror build (see the header
 * comment in this file's generator, vendor-tailwind-m3e-web.mjs). NOT a byte
 * copy of the real tailwind-m3e-web/src/index.css -- that one @imports the
 * bare "tailwind-md3" package specifier, unresolvable here. This inlines the
 * same import graph via the relative paths the vendoring flattens into.
 */

/* Layer 0 -- seed tokens (from tailwind-md3). */
@import "./seed.css";

/* Layer 1 -- ref palette tonal scales (from tailwind-md3). */
@import "./ref/palette.css";

/* Layer 2 -- M3 sys tokens, @m3e/web-specific. color must load before
   typescale (some typescale tokens reference --md-sys-color-* in their
   fallbacks). */
@import "./sys/color.css";
@import "./sys/typescale.css";
@import "./sys/motion.css";
@import "./sys/shape.css";
@import "./sys/elevation.css";
@import "./sys/state.css";
@import "./sys/density.css";

/* Layer 3 -- Tailwind v4 @theme keys (from tailwind-md3). */
@import "./theme.css";

/* Layer 3 (m3e-specific) -- density scope utilities (density-0...density-3). */
@import "./density.css";
`;

/**
 * Copy the CSS @import-graph files from `srcPkg` (tailwind-m3e-web) and
 * `md3SrcPkg` (tailwind-md3) into `targetDir`, exactly as the CLI below does
 * for docs/vendor/tailwind-m3e-web. Throws (does not process.exit) on a
 * missing source, so callers — the check:vendor scratch-dir comparison
 * included — can handle the failure themselves.
 */
export function copyTailwindM3eWebInto(targetDir, { srcPkg = tailwindM3eWebSrc, md3SrcPkg = tailwindMd3Src } = {}) {
  if (!existsSync(srcPkg)) {
    throw new Error(
      `tailwind-m3e-web source not found at ${srcPkg}\n` +
        `  Clone the sibling package next to elm-m3e, or set TAILWIND_M3E_WEB_SRC.`,
    );
  }
  if (!existsSync(md3SrcPkg)) {
    throw new Error(
      `tailwind-md3 source not found at ${md3SrcPkg}\n` +
        `  Clone core/tailwind-md3 next to it, or set TAILWIND_MD3_SRC.`,
    );
  }

  // Fresh tree every run so deletions/renames upstream propagate.
  rmSync(targetDir, { recursive: true, force: true });
  mkdirSync(targetDir, { recursive: true });

  for (const [root, files] of [
    [srcPkg, VENDORED_FILES_M3E_WEB],
    [md3SrcPkg, VENDORED_FILES_MD3],
  ]) {
    for (const rel of files) {
      const from = join(root, rel);
      if (!existsSync(from)) {
        throw new Error(`expected vendored file missing from source: ${from}`);
      }
      const to = join(targetDir, rel);
      mkdirSync(dirname(to), { recursive: true });
      cpSync(from, to);
    }
  }

  const indexTo = join(targetDir, "src", "index.css");
  mkdirSync(dirname(indexTo), { recursive: true });
  writeFileSync(indexTo, INDEX_CSS_CONTENT);
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
      `  and: ${tailwindMd3Src}\n` +
      `  ${countCss(vendorDir)} .css files vendored.`,
  );
}

// Only run as a script — importing this module (e.g. from check-vendor-drift.mjs)
// must never mutate docs/vendor/tailwind-m3e-web as a side effect.
if (fileURLToPath(import.meta.url) === process.argv[1]) {
  main();
}
