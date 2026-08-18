#!/usr/bin/env node
// check-links.mjs — drift gate for profiles/<p>/figma-links.json (Phase 2.2,
// plans/2026-08-17-figma-elm-config-integration-design.md). Same pattern as
// check-facts.mjs / src/publish/check.mjs's generated/** drift gate:
// recompute in memory, diff byte-for-byte against the committed file.
//
// Usage: node scripts/check-links.mjs [--profile <name>]

import path from "node:path";
import fs from "node:fs";
import { fileURLToPath } from "node:url";

import { checkFigmaLinks } from "../src/links/derive.mjs";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

function parseArgs(argv) {
  const idx = argv.indexOf("--profile");
  return { profile: idx === -1 ? "m3-kit" : argv[idx + 1] };
}

function main(argv) {
  const { profile } = parseArgs(argv);
  const profileDir = path.join(pkgDir, "profiles", profile);
  if (!fs.existsSync(profileDir)) {
    console.error(`check-links: no such profile directory: ${profileDir}`);
    process.exitCode = 1;
    return;
  }
  const { ok, reason } = checkFigmaLinks(profileDir);
  if (ok) {
    console.log(`check-links: profile "${profile}" — figma-links.json is byte-stable`);
    return;
  }
  console.error(`check-links: profile "${profile}" — ${reason}`);
  process.exitCode = 1;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
