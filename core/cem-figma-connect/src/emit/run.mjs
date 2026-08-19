// Deterministic emit runner (task B2; plans/01-architecture.md §4/§5 +
// plans/plan/B-emitters-publish.md Task B2). Owns EVERYTHING the pure
// emitters (src/emit/emitter-api.mjs's interface) don't: resolving which
// emitters run, which entries they see, and ALL file writing.
//
// Pipeline per `runEmit`:
//   1. Load the profile, correspondence, cem, and figma-export ONCE.
//   2. Filter correspondence to the emit set: `status:"confirmed"` entries,
//      MINUS anything a profile delta suppresses (src/correspond/merge.mjs's
//      `computeEmitSet` — already the tested single source of truth for
//      "suppressed/rejected entries emit nothing": `status !== "confirmed"`
//      is filtered here, and delta-suppression is computeEmitSet's job).
//      Sorted by cemTag (ordinal — src/lib/order.mjs) for determinism.
//   3. Optionally narrow further to entries whose figma sets live on one
//      Figma page (`--page`, Plan E's per-page fan-out).
//   4. Resolve each `profile.json` `emitters[]` entry to an emitter object:
//      the literal string `"html-label"` -> the built-in emitter
//      (src/emit/html-label.mjs's `emitter` export); anything else -> a
//      REPO-ROOT-RELATIVE path, dynamically `import()`ed (profile-local
//      emitters, e.g. B3's `profiles/m3-kit/emitters/elm.mjs`).
//   5. For each emitter, in `emitters[]`'s declared order (itself
//      deterministic — an authored array, not something this module sorts),
//      wipe and rewrite `generated/<profile>/<label-slug>/` from scratch
//      (so a re-run never leaves a stale file behind for an entry that's
//      since been unconfirmed/suppressed/deleted), call `emit(entry, ctx)`
//      per entry, write every returned `{path, contents}` under that
//      directory, and write `MANIFEST.json` (`{ [cemTag]: [path, ...] }`,
//      covering exactly — and only — the files actually written this run).
//
// Byte-stability: emitters are pure (emitter-api.mjs), and this runner does
// no per-run-varying work of its own (no timestamps, no randomness, no
// locale-sensitive sort — see src/lib/order.mjs) — so two runs over
// unchanged inputs produce byte-identical trees. See
// test/emitter-api.test.mjs's re-run test.

import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";

import { loadProfile, readCorrespondence, computeEmitSet, repoRoot } from "../correspond/merge.mjs";
import { loadCem } from "../ingest/cem.mjs";
import { loadFigmaExport } from "../ingest/figma.mjs";
import { byKey, byString } from "../lib/order.mjs";
import { slugify, buildEmitContext } from "./emitter-api.mjs";
import { emitter as htmlLabelEmitter } from "./html-label.mjs";

const byCemTag = byKey((e) => e.cemTag);

// The one reserved name in `profile.json`'s `emitters[]` array that resolves
// to a built-in rather than a dynamic-imported path. Kept as a small local
// registry (not in emitter-api.mjs) specifically to avoid a circular import
// — html-label.mjs imports its helpers FROM emitter-api.mjs, so
// emitter-api.mjs cannot also import html-label.mjs's `emitter` back.
const BUILTIN_EMITTERS = {
  "html-label": htmlLabelEmitter,
};

// missingEmitterFields(mod) -> string[] naming which required fields (of
// `name`, `label`, `emit`) `mod` is missing/malformed on. Empty array means
// `mod` conforms to the emitter interface.
function missingEmitterFields(mod) {
  if (!mod || typeof mod !== "object") return ["name", "label", "emit"];
  const missing = [];
  if (typeof mod.name !== "string") missing.push("name");
  if (typeof mod.label !== "string") missing.push("label");
  if (typeof mod.emit !== "function") missing.push("emit");
  return missing;
}

function isValidEmitter(mod) {
  return missingEmitterFields(mod).length === 0;
}

// assertContainedEmitterModulePath(spec, repoRoot) -> absPath, or throws.
//
// SECURITY (review fix, task B2): a profile-local `emitters[]` entry is
// dynamically `import()`ed as CODE — strictly more dangerous than the
// returned-file-path guard below (~line 185), which only constrains where
// WRITTEN DATA lands. An untrusted/external profile.json (the exact risk
// Plan F's external consumer profiles introduce) could otherwise name an
// absolute path or a `../`-escaping relative path and get arbitrary code
// executed by this process. Boundary chosen: the repo root — NOT
// profileDir — because loadProfile's own documented convention (this file's
// header, emitter-api.mjs's header) is that every path in profile.json,
// `emitters[]` included, is resolved against the repo root, not profileDir;
// legitimate specs (e.g. "profiles/m3-kit/emitters/elm.mjs",
// "test/fixtures/toy-profile/emitters/toy.mjs") are already repo-root-
// relative, never profileDir-relative, so profileDir cannot be the
// containment boundary without breaking the documented convention itself.
// The built-in "html-label" keyword never reaches this function (resolved
// via BUILTIN_EMITTERS above, by bare name — never a path).
function assertContainedEmitterModulePath(spec, repoRoot) {
  if (path.isAbsolute(spec)) {
    throw new Error(
      `run.mjs: profile-local emitter module spec "${spec}" must not be an absolute path — ` +
        `emitters[] entries are resolved relative to the repo root ("${repoRoot}")`
    );
  }

  const absPath = path.resolve(repoRoot, spec);
  const rel = path.relative(repoRoot, absPath);
  if (rel === ".." || rel.startsWith(`..${path.sep}`) || path.isAbsolute(rel)) {
    throw new Error(
      `run.mjs: profile-local emitter module "${spec}" resolves to "${absPath}", which escapes ` +
        `the repo root ("${repoRoot}") — refusing to dynamically import it`
    );
  }

  return absPath;
}

// loadEmitters(profile) -> Promise<emitter[]>
//
// Resolves every string in `profile.emitters` (see loadProfile,
// src/correspond/merge.mjs) to an emitter object, in the array's own order.
// Profile-local paths are REPO-ROOT-RELATIVE (architecture convention: every
// path in profile.json is resolved against the repo root, not profileDir,
// not process.cwd() — see loadProfile's own doc comment), CONTAINED to the
// repo root (assertContainedEmitterModulePath, above — an absolute path or a
// `..`-escaping relative path throws rather than being dynamically
// `import()`ed; see that function's doc comment for why the repo root, not
// profileDir, is the containment boundary), dynamically `import()`ed, and
// expected to export `emitter` (preferred) or a `default` matching the
// `{name, label, emit}` shape.
export async function loadEmitters(profile) {
  const specs = profile.emitters ?? [];
  const emitters = [];

  for (const spec of specs) {
    if (Object.prototype.hasOwnProperty.call(BUILTIN_EMITTERS, spec)) {
      emitters.push(BUILTIN_EMITTERS[spec]);
      continue;
    }

    const absPath = assertContainedEmitterModulePath(spec, repoRoot);
    const mod = await import(pathToFileURL(absPath).href);
    const candidate = mod.emitter ?? mod.default;
    const missing = missingEmitterFields(candidate);
    if (missing.length > 0) {
      throw new Error(
        `run.mjs: profile-local emitter module "${spec}" does not export a valid emitter ` +
          `({name, label, emit}) via \`emitter\` or \`default\` — missing/invalid: ${missing.join(", ")}`
      );
    }
    emitters.push(candidate);
  }

  return emitters;
}

// nodeIdToPage(figma) -> Map<nodeId, page> covering every component the
// figma-export loader saw (sets, standalones, variants alike) — used only
// by the `--page` filter below.
function nodeIdToPage(figma) {
  const index = new Map();
  for (const component of figma.data.components) {
    index.set(component.id, component.page);
  }
  return index;
}

// entryOnPage(entry, pageIndex, page) -> true if ANY of the entry's figma
// sets resolve (by nodeId) to `page`. An entry whose figmaSets don't appear
// in the export's own component index at all (shouldn't happen for a real
// correspondence entry, but not this filter's job to validate) never
// matches any page filter.
function entryOnPage(entry, pageIndex, page) {
  return (entry.figmaSets ?? []).some((set) => pageIndex.get(set.nodeId) === page);
}

// computeEmitEntries({ profileDir, page }) -> { profile, cem, figma, entries }
//
// The load + filter steps shared by `runEmit` — factored out so tests (or a
// future `check`/`publish`, B4) can get the exact same deterministic entry
// set without re-running the write side.
export function computeEmitEntries({ profileDir, page, loadCemFn = loadCem, loadFigmaExportFn = loadFigmaExport }) {
  const profile = loadProfile(profileDir);
  const correspondencePath = path.join(profileDir, "correspondence.json");
  const allEntries = readCorrespondence(correspondencePath);

  // The kind:"iconTable" entry (D7/evidence #12 — the 141-row m3e-icon table)
  // is never in the emit set itself (the emitter skips it), but emitters that
  // resolve an INSTANCE_SWAP glyph to a Material Symbols name need its rows —
  // thread them through the context (see buildEmitContext / html-label's
  // buildSlotBooleanBlock approach A). [] when a profile has no iconTable.
  const iconTableEntry = allEntries.find((e) => e.kind === "iconTable");
  const iconTable = iconTableEntry?.icons ?? [];

  const confirmed = allEntries.filter((e) => e.status === "confirmed");
  const emitSet = computeEmitSet(confirmed, profile.raw.deltas ?? []);

  const cem = loadCemFn(profile.cemManifestPath, { dtsDir: profile.cemDtsDir, log: () => {} });
  const figma = loadFigmaExportFn(profile.figmaExportPath);

  let entries = emitSet;
  if (page !== undefined) {
    const pageIndex = nodeIdToPage(figma);
    entries = entries.filter((entry) => entryOnPage(entry, pageIndex, page));
  }

  entries = [...entries].sort(byCemTag);

  return { profile, cem, figma, entries, iconTable, examples: profile.examples ?? {}, setAttrs: profile.setAttrs ?? {} };
}

// runEmit({ profileDir, profileName, page }) -> Promise<[{
//   name, label, labelSlug, dir, manifest, fileCount
// }]>
//
// `profileName` is the directory-name segment under `generated/` (normally
// the same bare name passed to `--profile`; kept as an explicit param
// rather than re-deriving it from `profileDir` so tests can point
// `profileDir` at a fixture while still writing under a clean
// `generated/<profileName>/` name).
export async function runEmit({ profileDir, profileName, page, outRoot }) {
  const { profile, cem, figma, entries, iconTable, examples, setAttrs } = computeEmitEntries({ profileDir, page });
  const emitters = await loadEmitters(profile);

  const root = outRoot ?? path.join(repoRoot, "generated", profileName);
  const results = [];

  for (const emitterDef of emitters) {
    const labelSlug = slugify(emitterDef.label);
    const labelDir = path.join(root, labelSlug);

    // Wipe first: a re-run must never leave a file behind for an entry
    // that's since been unconfirmed/suppressed/removed — MANIFEST.json's
    // "lists exactly the emitted files" guarantee depends on the directory
    // containing NOTHING this run didn't just write.
    fs.rmSync(labelDir, { recursive: true, force: true });
    fs.mkdirSync(labelDir, { recursive: true });

    const manifest = {};
    let fileCount = 0;

    for (const entry of entries) {
      const ctx = buildEmitContext({ profile, figma, cem, entry, iconTable, examples, setAttrs });
      const files = emitterDef.emit(entry, ctx) ?? [];
      if (files.length === 0) continue;

      const filePaths = [];
      for (const file of files) {
        if (path.isAbsolute(file.path) || file.path.split(/[\\/]/).includes("..")) {
          throw new Error(
            `run.mjs: emitter "${emitterDef.name}" returned an unsafe path "${file.path}" for entry ` +
              `"${entry.cemTag}" — emitted paths must be relative, without ".." segments`
          );
        }
        const dest = path.join(labelDir, file.path);
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.writeFileSync(dest, file.contents, "utf8");
        filePaths.push(file.path);
      }

      filePaths.sort(byString);
      manifest[entry.cemTag] = filePaths;
      fileCount += filePaths.length;
    }

    const manifestPath = path.join(labelDir, "MANIFEST.json");
    fs.writeFileSync(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");

    results.push({
      name: emitterDef.name,
      label: emitterDef.label,
      labelSlug,
      dir: labelDir,
      manifest,
      fileCount,
    });
  }

  return results;
}
