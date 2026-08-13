#!/usr/bin/env node
// Committed builder that assembles test/fixtures/figma-export.m3-kit.json
// from the real, checked-in dumps under research/figma-dumps/. Re-running it
// must be byte-stable: meta.extractedAt and meta.kitVersionTag are PASSED IN
// (never computed here, e.g. no Date.now()/new Date()) — determinism is a
// hard gate for figma-export.json (D9).
//
// setProperties only contains the two button sets we captured live
// (research/figma-dumps/kit-props-button-{main,elevated}.json). The other
// 169 of 171 COMPONENT_SETs have no entry — the schema marks setProperties
// optional per-set on purpose; A3's live extractor fills the rest.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { validate } from "../../src/lib/validate.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..", "..");
const dumpsDir = path.join(repoRoot, "research", "figma-dumps");
const schemaPath = path.join(repoRoot, "src", "ingest", "figma-export.schema.json");
const outPath = path.join(here, "figma-export.m3-kit.json");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

// meta.fileKey per the task brief / evidence #3 (user's drafts duplicate of
// the M3 kit that the publish-gate verification used).
const FILE_KEY = "KujuFlfJSwHI6ua1b7RZvL";

export function buildM3KitFixture({ extractedAt, kitVersionTag }) {
  const components = readJson(path.join(dumpsDir, "m3-kit-components.json"));
  const docInfo = readJson(path.join(dumpsDir, "kit-doc-info.json"));
  const rawVariables = readJson(path.join(dumpsDir, "kit-variables.json"));
  const rawStyles = readJson(path.join(dumpsDir, "kit-styles.json"));
  const buttonMain = readJson(path.join(dumpsDir, "kit-props-button-main.json"));
  const buttonElevated = readJson(
    path.join(dumpsDir, "kit-props-button-elevated.json")
  );

  const meta = {
    fileKey: FILE_KEY,
    fileName: docInfo.name,
    extractedAt,
    kitVersionTag,
  };

  // Pass through the 6-field component shape as-is (already exactly
  // {id,name,type,key,description,page} in the raw dump).
  const fixtureComponents = components.map((c) => ({
    id: c.id,
    name: c.name,
    type: c.type,
    key: c.key,
    description: c.description,
    page: c.page,
  }));

  const setProperties = {
    [buttonMain.id]: buttonMain.properties,
    [buttonElevated.id]: buttonElevated.properties,
  };

  const variables = {
    collections: rawVariables.collections.map((collection) => ({
      id: collection.id,
      name: collection.name,
      modes: collection.modes.map((mode) => ({
        id: mode.modeId,
        name: mode.name,
      })),
    })),
    variables: rawVariables.variables.map((v) => ({
      id: v.id,
      name: v.name,
      resolvedType: v.type,
      collectionId: v.collectionId,
      valuesByMode: v.valuesByMode,
      codeSyntax: v.codeSyntax,
      scopes: v.scopes,
    })),
  };

  const styles = {
    paintStyles: rawStyles.paintStyles,
    textStyles: rawStyles.textStyles,
    effectStyles: rawStyles.effectStyles,
  };

  return { meta, components: fixtureComponents, setProperties, variables, styles };
}

function main() {
  // Fixed, committed values — NOT computed at build time. extractedAt marks
  // when the source dumps under research/figma-dumps/ were captured (see
  // research/evidence/2026-07-10-verification-ledger.md). kitVersionTag is
  // an explicit placeholder: the checked-in dumps don't carry a kit version
  // string (Figma community-file version numbers aren't in the plugin
  // getters we captured) and the true tag is A6/profile.json's job once A3's
  // live extractor exists.
  const extractedAt = "2026-07-10T00:00:00.000Z";
  const kitVersionTag = "unknown-pre-a3-fixture";

  const fixture = buildM3KitFixture({ extractedAt, kitVersionTag });

  const schema = readJson(schemaPath);
  const { valid, errors } = validate(schema, fixture);
  if (!valid) {
    console.error("Built fixture failed schema validation:");
    for (const error of errors) console.error(`  ${error}`);
    process.exit(1);
  }

  // Node's test runner treats every file under any directory literally named
  // "test" (recursively — so this file included) as a discoverable test,
  // regardless of filename. That means a bare `node --test` (what `pnpm
  // test`/`npm test` run) silently imports and executes this file's
  // top-level code. Gate the actual write behind an explicit --write flag so
  // that incidental auto-discovery only re-validates the schema (a useful,
  // side-effect-free check) instead of rewriting the committed fixture as a
  // surprise side effect of running the test suite.
  if (!process.argv.includes("--write")) {
    console.log(
      "Dry run: fixture matches the schema. Pass --write to regenerate " +
        `${path.relative(repoRoot, outPath)}.`
    );
    return;
  }

  fs.writeFileSync(outPath, `${JSON.stringify(fixture, null, 2)}\n`);
  console.log(`Wrote ${path.relative(repoRoot, outPath)}`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
