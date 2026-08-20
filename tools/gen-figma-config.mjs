#!/usr/bin/env node
// gen-figma-config.mjs — Phase 2.3,
// pipeline/elm-cem-figma-connect/plans/2026-08-17-figma-elm-config-integration-design.md.
//
// Joins pipeline/elm-cem-figma-connect/profiles/<profile>/figma-links.json (a
// DERIVED, read-only projection of correspondence.json — see
// pipeline/elm-cem-figma-connect/src/links/derive.mjs) with elm-cem's Face C
// facts bundle (component -> Elm module name) by cemTag, and writes
// brands/m3e/generated/package/elm-m3e/config/figma.generated.json: per-component `docMeta`
// entries (`figmaUrl`, `figmaStatus`) in the shape elm-cem's config decoder
// expects (`Generate/Config.elm`: `opt "docMeta" (keyValuePairs string) []`,
// keyed by CONSTRUCTOR NAME — the module's last dotted segment, e.g.
// "M3e.Component.AppBar" -> "AppBar", verified against the real
// config/examples.generated.json's key casing, NOT Face C's own lowercase
// `component` field).
//
// -- WIRED + VISIBLE (2026-08-19, docs/plans/2026-08-19-figma-docmeta-visible.md) ---
//
// This config is now CONSUMED end to end:
//   * `--config-from=config/figma.generated.json` is in elm-m3e's gen:src /
//     check:cem / check:families argv (elm-m3e/config is a symlink to
//     inputs/cem/config, so the relative path resolves).
//   * elm-cem's docMeta consumer (Generate/Config.elm) renders it via
//     pipeline/elm-cem/codegen/Docs.elm's docMetaMarker as an HTML-comment marker
//     (`<!-- elm-cem:docmeta k=v; ... -->`) in each generated module's doc
//     comment.
//   * That marker USED to be silently dropped by
//     brands/m3e/generated/docs/elm-m3e-docs/scripts/extract-reference.mjs; it now
//     PARSES it into reference.json's per-component `figma` field, which the
//     docs app (brands/m3e/generated/docs/elm-m3e-docs/app/Route/Components/Name_.elm) renders as a
//     "View in Figma" link.
//
// Publication stance: the URLs point at the PUBLIC "Material 3 Design Kit
// (Community)" Figma file (verified from the emitted URLs — NOT a private kit),
// so shipping them in the elm-m3e package + docs is safe and useful.
//
// The generator is no longer orphaned: elm-m3e's `gen:figma-config` runs this
// script as the first step of `gen`, and `check:figma-config` (this script's
// --check mode) gates the committed file against drift.
//
// Usage: node tools/gen-figma-config.mjs [--profile <name>]

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const cfcDir = path.join(repoRoot, "pipeline", "elm-cem-figma-connect");
const elmM3eConfigDir = path.join(repoRoot, "brands", "m3e", "inputs", "cem", "config");

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function parseArgs(argv) {
  const idx = argv.indexOf("--profile");
  return { profile: idx === -1 ? "m3-kit" : argv[idx + 1] };
}

// constructorKeyFor(module) -> "M3e.Component.AppBar" -> "AppBar". Matches
// the REAL key casing in config/examples.generated.json (verified: 'Button'
// is a real key, 'button' is not) — Face C's own `component` field is
// lowercase and would NOT match.
function constructorKeyFor(elmModule) {
  const parts = elmModule.split(".");
  return parts[parts.length - 1];
}

// deriveFigmaConfig({ figmaLinks, faceC }) -> the figma.generated.json
// object. Pure. `figmaLinks`/`faceC` are already-parsed JSON.
export function deriveFigmaConfig({ figmaLinks, faceC }) {
  const out = {};
  for (const link of figmaLinks.links) {
    const comp = faceC.components[link.cemTag];
    if (!comp) continue; // Web-Components-only binding (e.g. icons pre-R-026 shape) — no Elm module to attach docMeta to.
    const key = constructorKeyFor(comp.module);
    const primarySet = link.sets[0];
    if (!primarySet) continue;
    out[key] = {
      docMeta: {
        figmaUrl: primarySet.url,
        figmaStatus: link.gate ?? link.status,
      },
    };
  }
  return out;
}

function main(argv) {
  const check = argv.includes("--check");
  const { profile } = parseArgs(argv);
  const profileDir = path.join(cfcDir, "profiles", profile);
  const figmaLinks = readJson(path.join(profileDir, "figma-links.json"));
  const faceC = readJson(path.join(profileDir, "facts", "elm-api-facts.json"));
  const config = deriveFigmaConfig({ figmaLinks, faceC });
  const outPath = path.join(elmM3eConfigDir, "figma.generated.json");
  const serialized = `${JSON.stringify(config, null, 2)}\n`;
  const rel = path.relative(repoRoot, outPath);
  const n = Object.keys(config).length;

  // --check: regenerate in memory and byte-compare against the committed file,
  // exit nonzero on drift WITHOUT writing (the drift-gate half — same shape as
  // docs/scripts/gen-compose-attrs.mjs --check). This is elm-m3e's
  // `check:figma-config`, keeping the committed config from silently going
  // stale once cem-figma-connect's figma-links / faceC change.
  if (check) {
    const committed = fs.existsSync(outPath) ? fs.readFileSync(outPath, "utf8") : null;
    if (committed !== serialized) {
      console.error(`check-figma-config: FAIL — ${rel} is stale (${n} components derived). Regenerate with: node tools/gen-figma-config.mjs`);
      process.exit(1);
    }
    console.log(`check-figma-config: OK — ${rel} matches the generator's current output (${n} components).`);
    return;
  }

  fs.writeFileSync(outPath, serialized, "utf8");
  console.log(`gen-figma-config: wrote ${rel} (${n} components).`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
