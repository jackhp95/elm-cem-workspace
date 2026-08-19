#!/usr/bin/env node
// check-facts.mjs — provenance staleness gate for the elm-cem facts bundle
// (plans/2026-08-17-figma-elm-config-integration-design.md Phase 1.2).
//
// The bundle under profiles/<p>/facts/{cem-facts,elm-api-facts}.json is
// committed, elm-cem-generated data (scripts/gen-facts.mjs is the only
// writer — see its header). Nothing before this script asserted the copy
// actually matches the profile it's supposed to describe: a stale bundle
// (regenerated CEM package/version drifted from profile.json's cem block,
// or copied from the wrong brand) would silently mis-emit rather than fail
// loud. This turns that into a red gate.
//
// Checks, per profile:
//   1. cem-facts.json's provenance.source.{package,version} matches
//      profile.json's cem.{package,version} (Face B).
//   2. elm-api-facts.json's provenance.source.{package,version} matches the
//      same (Face C carries its own copy of the source stamp).
//   3. elm-api-facts.json's provenance.brand.name matches profile.json's
//      elm.expectedBrand, WHEN that field is present (optional,
//      backward-compatible — a profile with no Elm emitter has nothing to
//      assert here).
//
// Usage: node scripts/check-facts.mjs [--profile <name>]

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const pkgDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

// checkFacts(profileDir) -> { ok: boolean, issues: string[] }
// Pure given the files on disk; no network, no mutation. Exported for tests.
export function checkFacts(profileDir) {
  const issues = [];
  const profile = readJson(path.join(profileDir, "profile.json"));
  const cemExpected = profile.cem ?? {};
  const factsDir = path.join(profileDir, "facts");

  const cemFactsPath = path.join(factsDir, "cem-facts.json");
  if (!fs.existsSync(cemFactsPath)) {
    issues.push(`missing ${path.relative(profileDir, cemFactsPath)}`);
  } else {
    const cemFacts = readJson(cemFactsPath);
    const src = cemFacts.provenance?.source ?? {};
    if (src.package !== cemExpected.package) {
      issues.push(
        `cem-facts.json provenance.source.package (${JSON.stringify(src.package)}) !== ` +
          `profile.json cem.package (${JSON.stringify(cemExpected.package)})`,
      );
    }
    if (src.version !== cemExpected.version) {
      issues.push(
        `cem-facts.json provenance.source.version (${JSON.stringify(src.version)}) !== ` +
          `profile.json cem.version (${JSON.stringify(cemExpected.version)})`,
      );
    }
  }

  const elmFactsPath = path.join(factsDir, "elm-api-facts.json");
  if (fs.existsSync(elmFactsPath)) {
    const elmFacts = readJson(elmFactsPath);
    const src = elmFacts.provenance?.source ?? {};
    if (src.package !== cemExpected.package) {
      issues.push(
        `elm-api-facts.json provenance.source.package (${JSON.stringify(src.package)}) !== ` +
          `profile.json cem.package (${JSON.stringify(cemExpected.package)})`,
      );
    }
    if (src.version !== cemExpected.version) {
      issues.push(
        `elm-api-facts.json provenance.source.version (${JSON.stringify(src.version)}) !== ` +
          `profile.json cem.version (${JSON.stringify(cemExpected.version)})`,
      );
    }
    const expectedBrand = profile.elm?.expectedBrand;
    if (expectedBrand) {
      const brand = elmFacts.provenance?.brand?.name;
      if (brand !== expectedBrand) {
        issues.push(
          `elm-api-facts.json provenance.brand.name (${JSON.stringify(brand)}) !== ` +
            `profile.json elm.expectedBrand (${JSON.stringify(expectedBrand)})`,
        );
      }
    }
  }
  // elm-api-facts.json absent -> no Elm emitter for this profile, nothing to check (B1-style
  // backward compatibility, same pattern as loadProfile's optional-sidecar files).

  return { ok: issues.length === 0, issues };
}

function parseArgs(argv) {
  const idx = argv.indexOf("--profile");
  return { profile: idx === -1 ? "m3-kit" : argv[idx + 1] };
}

function main(argv) {
  const { profile } = parseArgs(argv);
  const profileDir = path.join(pkgDir, "profiles", profile);
  if (!fs.existsSync(profileDir)) {
    console.error(`check-facts: no such profile directory: ${profileDir}`);
    process.exitCode = 1;
    return;
  }
  const { ok, issues } = checkFacts(profileDir);
  if (ok) {
    console.log(`check-facts: profile "${profile}" — facts bundle provenance matches profile.json`);
    return;
  }
  console.error(`check-facts: profile "${profile}" — STALE facts bundle:`);
  for (const issue of issues) console.error(`  - ${issue}`);
  console.error(`  Run \`pnpm gen:facts\` to refresh the bundle, or update profile.json if the CEM version genuinely changed.`);
  process.exitCode = 1;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
