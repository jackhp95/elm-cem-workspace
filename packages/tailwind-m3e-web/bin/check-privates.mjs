#!/usr/bin/env node
/*
 * bin/check-privates.mjs
 *
 * Reads utilities-private.template.css and verifies every --_*
 * var it declares still exists in the installed @m3e/web source. Exits
 * non-zero on any missing var, so the script is safe to run in CI or
 * a pre-version-bump workflow.
 *
 * Why: m3e privates (--_*) are internal implementation details that
 * upstream is free to rename or remove between versions. The template
 * is hand-curated against today's m3e; this check warns before a version
 * bump introduces a silent regression.
 *
 * Usage:
 *   pnpm exec tailwind-m3e-web-check-privates              # check template
 *   pnpm exec tailwind-m3e-web-check-privates <path/to/css> # check custom file
 */

import { readFile, readdir, stat } from "node:fs/promises";
import { existsSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");
const DEFAULT_INPUT_PATH = join(ROOT, "utilities-private.template.css");

/**
 * Locate @m3e/web's `dist/` directory in a way that survives dependency
 * hoisting. When this package is installed as a dependency, @m3e/web lands in
 * the CONSUMER's top-level node_modules (or pnpm's virtual store) — NOT nested
 * under tailwind-m3e-web — so the old hardcoded
 *   <ROOT>/node_modules/@m3e/web/dist
 * path did not exist for consumers. @m3e/web ships no bare/package.json export,
 * so we resolve a known subpath export (`@m3e/web/core` → .../dist/core.js) and
 * take its directory. Falls back to the local nested path (dev checkout) if
 * resolution fails.
 */
export function resolveM3eDist() {
  const require = createRequire(import.meta.url);
  try {
    const corePath = require.resolve("@m3e/web/core");
    return dirname(corePath);
  } catch {
    const fallback = join(ROOT, "node_modules", "@m3e", "web", "dist");
    if (existsSync(fallback)) return fallback;
    throw new Error(
      "Could not locate @m3e/web. Install it (peer dependency) before running check-privates.",
    );
  }
}

/* Recursively collect all .js files in dir (excluding .min.js to halve I/O — minified
   bundles contain a superset of the same identifiers as the unminified ones). */
async function collectJsFiles(dir) {
  const out = [];
  for (const entry of await readdir(dir)) {
    const full = join(dir, entry);
    const st = await stat(full);
    if (st.isDirectory()) {
      out.push(...(await collectJsFiles(full)));
    } else if (entry.endsWith(".js") && !entry.endsWith(".min.js")) {
      out.push(full);
    }
  }
  return out;
}

/**
 * Extract private var names (--_*) from CSS block.
 * Returns sorted array of unique var names.
 */
export function findPrivateVars(css) {
  // Match --_<word>- prefixes in @utility names: e.g. @utility m3e-_button-shape-*
  const matches = css.matchAll(/@utility\s+m3e-(_[a-z0-9-]+)-\*/gi);
  const vars = [...new Set([...matches].map((m) => `--${m[1]}`))];
  return vars.sort();
}

/**
 * Check which declared private vars are missing from m3e source.
 * Returns array of missing var names.
 */
export function verifyAgainstM3e(declaredVars, installedSource) {
  const missing = [];
  for (const v of declaredVars) {
    if (!installedSource.includes(v)) {
      missing.push(v);
    }
  }
  return missing;
}

async function main() {
  const inputPath = process.argv[2] || DEFAULT_INPUT_PATH;
  const css = await readFile(inputPath, "utf8");
  const privates = findPrivateVars(css);

  if (!privates.length) {
    console.log(`No private vars declared in ${inputPath}. Nothing to check.`);
    return;
  }

  console.log(`Checking ${privates.length} private vars against @m3e/web source…`);
  const jsFiles = await collectJsFiles(resolveM3eDist());
  console.log(`  (${jsFiles.length} m3e .js files in scope)`);

  let installedSource = "";
  for (const file of jsFiles) {
    installedSource += await readFile(file, "utf8");
  }

  const missing = verifyAgainstM3e(privates, installedSource);

  if (missing.length) {
    console.error(`\n❌ ${missing.length} private var(s) missing from @m3e/web source:`);
    for (const v of missing) console.error(`   - ${v}`);
    console.error(
      `\nThese were defined in ${inputPath} but no longer appear in the m3e source.`,
    );
    console.error(`Likely cause: upstream rename or removal in a recent m3e version.`);
    console.error(`Action: update or remove the corresponding @utility rule(s).`);
    process.exit(1);
  }

  console.log(`\n✅ All ${privates.length} private vars present in @m3e/web source.`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
