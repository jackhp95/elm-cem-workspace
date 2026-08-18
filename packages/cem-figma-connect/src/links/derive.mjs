// figma-links derivation (Phase 2.1,
// plans/2026-08-17-figma-elm-config-integration-design.md §3.2/§4).
//
// Per that design's verdict (D14, plans/00-mission-and-decisions.md):
// correspondence.json stays the one authored source of truth for CEM<->Figma
// binding. This module derives a SECOND, read-only projection of it —
// `profiles/<p>/figma-links.json`, one row per confirmed cemTag — meant for
// consumption by a downstream CEM-config channel (elm-cem's `config/*.json`)
// as GENERATED data, never hand-authored there. See docs/USAGE.md /
// STATUS.md for the fileKey-role split this reuses (extraction anchor vs
// publish target — this module only ever emits the profile's canonical
// fileKey, never a publish-target override).
//
// Pure function of the profile's on-disk inputs (correspondence.json,
// overrides.json, profile.json, the figma export's meta block) — no
// network, no live Figma, matching every other derived artifact in this
// repo (correspondence.json itself, gap-report.md).

import fs from "node:fs";
import path from "node:path";

import { buildNodeUrl } from "../emit/emitter-api.mjs";
import { byKey } from "../lib/order.mjs";
import { readOverrides } from "../correspond/review.mjs";
import { repoRoot } from "../correspond/merge.mjs";

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

// gateMapFrom(decisions) -> Map<cemTag, gate|undefined>. overrides.json is
// upsert-by-cemTag (src/correspond/review.mjs's upsertOverride) so there is
// at most one decision per cemTag already — no last-wins ambiguity here.
function gateMapFrom(decisions) {
  const map = new Map();
  for (const d of decisions) map.set(d.cemTag, d.gate);
  return map;
}

// nodeUrlConfig(profileRaw, figmaExportPath) -> the {fileKey, fileName}
// buildNodeUrl needs, sourced the same way every emitter does
// (ctx.figma.data.meta.fileName in html-label.mjs / elm.mjs) — read
// directly from the export file's meta block rather than pulling in the
// full loadFigmaExport() ingest pipeline (sets/standalones/variants), which
// this derivation has no other use for.
function nodeUrlConfig(profileRaw, figmaExportPath) {
  const exportMeta = readJson(figmaExportPath).meta;
  return { fileKey: profileRaw.fileKey, fileName: exportMeta.fileName };
}

// linkEntryFor(entry, urlConfig) -> a figma-links.json row, or null for an
// entry with nothing to link (code-only: figmaSets is empty and it isn't
// the iconTable).
function linkEntryFor(entry, urlConfig) {
  if (entry.kind === "iconTable") {
    // No single Figma node represents "the icon page" in the data we have —
    // each of the 141 icons is its own node (entry.icons[].figmaNodeId).
    // Rather than fabricate a page-level link that isn't in the export,
    // link the first icon as an honestly-labeled REPRESENTATIVE entry point
    // (representative: true) and record the true count.
    const first = entry.icons[0];
    return {
      cemTag: entry.cemTag,
      status: entry.status,
      sets: first
        ? [{ nodeId: first.figmaNodeId, setName: first.figmaName, url: buildNodeUrl(urlConfig, first.figmaNodeId), representative: true }]
        : [],
      iconCount: entry.icons.length,
    };
  }
  if (!entry.figmaSets || entry.figmaSets.length === 0) return null; // code-only: nothing to link
  return {
    cemTag: entry.cemTag,
    status: entry.status,
    sets: entry.figmaSets.map((s) => ({
      nodeId: s.nodeId,
      setName: s.setName,
      url: buildNodeUrl(urlConfig, s.nodeId),
    })),
  };
}

// deriveFigmaLinks(profileDir) -> { fileKey, kitVersionTag, labels, links: [...] }
// `labels` are the emitter labels this profile's `emitters[]` declares
// (constant across every row — every confirmed binding gets every active
// label, per architecture §5) so a consumer joining this file doesn't need
// to separately re-derive which labels exist for the profile.
export function deriveFigmaLinks(profileDir) {
  const profileRaw = readJson(path.join(profileDir, "profile.json"));
  const correspondence = readJson(path.join(profileDir, "correspondence.json"));
  const overridesPath = path.join(profileDir, "overrides.json");
  const gateMap = gateMapFrom(readOverrides(overridesPath));
  // profile.json paths are REPO-ROOT-relative (loadProfile's own resolve()
  // helper, src/correspond/merge.mjs) — never profileDir- or cwd-relative.
  const urlConfig = nodeUrlConfig(profileRaw, path.resolve(repoRoot, profileRaw.figmaExportPath));

  const labels = (profileRaw.emitters ?? []).map((e) =>
    e === "html-label" ? "Web Components" : path.basename(e, path.extname(e)) === "elm" ? "Elm" : e,
  );

  const links = correspondence
    .filter((e) => e.status === "confirmed")
    .map((e) => {
      const link = linkEntryFor(e, urlConfig);
      if (!link) return null;
      return { ...link, gate: gateMap.get(e.cemTag) ?? null, labels };
    })
    .filter((x) => x !== null)
    .sort(byKey((x) => x.cemTag));

  return {
    fileKey: profileRaw.fileKey,
    kitVersionTag: profileRaw.kitVersionTag,
    links,
  };
}

// serializeFigmaLinks(data) -> the exact bytes figma-links.json is written
// as (2-space, trailing newline) — shared by the writer and the drift check
// so both always compare byte-identically.
export function serializeFigmaLinks(data) {
  return `${JSON.stringify(data, null, 2)}\n`;
}

// writeFigmaLinks(profileDir) -> the written data (also writes
// profiles/<p>/figma-links.json).
export function writeFigmaLinks(profileDir) {
  const data = deriveFigmaLinks(profileDir);
  fs.writeFileSync(path.join(profileDir, "figma-links.json"), serializeFigmaLinks(data), "utf8");
  return data;
}

// checkFigmaLinks(profileDir) -> { ok, driftedFrom? } — recomputes in
// memory and diffs against the committed file, same pattern as
// src/publish/check.mjs's drift gate for generated/**.
export function checkFigmaLinks(profileDir) {
  const linksPath = path.join(profileDir, "figma-links.json");
  const fresh = serializeFigmaLinks(deriveFigmaLinks(profileDir));
  if (!fs.existsSync(linksPath)) {
    return { ok: false, reason: `missing ${linksPath} — run \`links\` to generate it` };
  }
  const committed = fs.readFileSync(linksPath, "utf8");
  if (committed !== fresh) {
    return { ok: false, reason: `${linksPath} is STALE (regenerating it differs from what's checked in) — run \`links\` to refresh it` };
  }
  return { ok: true };
}
