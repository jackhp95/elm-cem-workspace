#!/usr/bin/env node
// gen-figma-config.mjs — Phase 2.3,
// core/cem-figma-connect/plans/2026-08-17-figma-elm-config-integration-design.md.
//
// Joins core/cem-figma-connect/profiles/<profile>/figma-links.json (a
// DERIVED, read-only projection of correspondence.json — see
// core/cem-figma-connect/src/links/derive.mjs) with elm-cem's Face C
// facts bundle (component -> Elm module name) by cemTag, and writes
// brands/m3e/generated/package/elm-m3e/config/figma.generated.json: per-component `docMeta`
// entries (`figmaUrl`, `figmaStatus`) in the shape elm-cem's config decoder
// expects (`Generate/Config.elm`: `opt "docMeta" (keyValuePairs string) []`,
// keyed by CONSTRUCTOR NAME — the module's last dotted segment, e.g.
// "M3e.Component.AppBar" -> "AppBar", verified against the real
// config/examples.generated.json's key casing, NOT Face C's own lowercase
// `component` field).
//
// -- WHY THIS IS NOT YET WIRED INTO tools/lib/regen.mjs's GEN_CONFIG_ARGS ---
//
// Verified this session (source-read, not assumed) against
// core/elm-cem/codegen/Docs.elm's docMetaMarker: `docMeta` renders as an
// INVISIBLE HTML-comment marker (`<!-- elm-cem:docmeta k=v; ... -->`) in the
// generated module's doc comment — not a visible Markdown line. Worse:
// brands/m3e/generated/docs/elm-m3e-docs/scripts/extract-reference.mjs (the docs-site's own
// reference extractor) explicitly DROPS `elm-cem:docmeta` directives before
// rendering the public reference pages. So wiring this file into
// GEN_CONFIG_ARGS today would embed Figma node-ids/URLs (pointing at Jack's
// PRIVATE kit file) into the actual shipped elm-m3e package's doc-comment
// bytes, for ZERO visible effect anywhere a human reads the docs — and it's
// exactly the kind of "publish Figma URLs?" call flagged as an open question
// in the design doc (§7, open question 2), now sharpened by this finding.
// Making it VISIBLE would require extending extract-reference.mjs (or the
// docs-app renderer) to parse `elm-cem:docmeta` back out and render
// something — real UI-design work, held pending Jack's steer on the
// publication-stance question. This script stops at "generate the file,
// verify the shape" — the config file it writes is real and immediately
// useful once (a) the publication question is answered and (b) it's added
// to GEN_CONFIG_ARGS.
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
  const { profile } = parseArgs(argv);
  const profileDir = path.join(cfcDir, "profiles", profile);
  const figmaLinks = readJson(path.join(profileDir, "figma-links.json"));
  const faceC = readJson(path.join(profileDir, "facts", "elm-api-facts.json"));
  const config = deriveFigmaConfig({ figmaLinks, faceC });
  const outPath = path.join(elmM3eConfigDir, "figma.generated.json");
  fs.writeFileSync(outPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
  console.log(
    `gen-figma-config: wrote ${path.relative(repoRoot, outPath)} (${Object.keys(config).length} components) — NOT wired into GEN_CONFIG_ARGS yet, see this file's header.`,
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
