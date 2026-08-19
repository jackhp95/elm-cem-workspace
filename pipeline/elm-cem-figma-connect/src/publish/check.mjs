// Task B4: the CI drift/orphan gate — a port of VOLT-2003's
// `generate.mjs --check` semantics (plans/plan/B-emitters-publish.md Task
// B4; plans/00-mission-and-decisions.md's "Existing machinery to reuse").
//
// Re-emits every label IN MEMORY (computeInMemoryEmit, below — the exact
// same pure emitter calls run.mjs's runEmit makes, just without the fs
// writes) and diffs the result CODE-ONLY against whatever is committed at
// `generated/<profile>/<label-slug>/**`. Two independent failure classes:
//
//   DRIFT  — a file this run would (re)generate whose committed content
//            differs from (or is entirely missing vs.) the regenerated
//            content. MANIFEST.json is its own drift check (a JSON
//            structural compare, not code-only diffing).
//   ORPHAN — a file physically committed under a label's directory that
//            this run's manifest does NOT trace to any live correspondence
//            entry (a stale/hand-added file, or an entire label directory
//            the profile no longer registers at all).
//
// `runCheck` returns `{ ok, drift, orphan }` — never throws for a dirty
// tree (that's the whole point: a CI/publish gate reports, it doesn't
// crash) — non-zero-exit-code decisions live in the CLI layer
// (src/cli.mjs) and src/publish/runner.mjs's own `publish` guard.

import fs from "node:fs";
import path from "node:path";

import { computeEmitEntries, loadEmitters } from "../emit/run.mjs";
import { buildEmitContext, slugify } from "../emit/emitter-api.mjs";
import { repoRoot as defaultRepoRoot } from "../correspond/merge.mjs";
import { byString } from "../lib/order.mjs";

// One `// url=` header line, exactly as html-label.mjs/elm.mjs emit it:
//   // url=https://www.figma.com/design/<fileKey>/<slug>?node-id=<dashed-id>
// (the same shape src/publish/runner.mjs's URL_LINE_RE rewrites at publish
// time — kept independent here on purpose: check.mjs must never import
// runner.mjs, whose staging concerns are downstream of the drift gate).
const URL_LINE_RE =
  /^\s*\/\/ url=https:\/\/www\.figma\.com\/design\/[^/]+\/[^?]*\?node-id=([A-Za-z0-9-]+)\s*$/;

// codeOnly(source) -> comment/blank-line-stripped source, EXCEPT the
// `// url=` header line's node-id, which survives as a normalized
// `// node-id=<id>` marker.
//
// Only WHOLE-line comments are stripped (a line that is, modulo leading
// whitespace, a `//` comment in its entirety) — never anything trailing
// real code on a line, so a "//" inside a generated string/template literal
// (e.g. an "https://" URL baked into a code line) is never touched. Block
// comments (`/** ... */`, this project's GENERATED-header convention) are
// stripped as a whole. This is what makes DRIFT robust to: (a) the fileKey
// and filename-slug segments of the `// url=` header line, which ARE
// rewritten per fileKey only in publish's throwaway staging copy
// (src/publish/runner.mjs) and would otherwise falsely read as drift the
// moment a profile's canonical fileKey changes; (b) prose-only edits to the
// header block's rationale comments; (c) blank-line-count churn.
//
// It is deliberately NOT robust to a changed node-id (WB-review N1 fix):
// the node-id is the single most load-bearing binding value in a generated
// file (it's what a `figmaSets[].nodeId` correspondence-entry drift
// ultimately has to show up as), and it appears NOWHERE else in a generated
// file's code body — only in this `// url=` line and the stripped header
// docblock. Blanket-stripping the whole url= line (the pre-fix behavior)
// meant a correspondence.json nodeId change with a forgotten re-emit stayed
// invisible to `check`. So the url= line is normalized to `//
// node-id=<id>`, not dropped: the fileKey/slug (legitimately variable,
// publish-time-only) is discarded, but the node-id participates in the
// code-only diff like any other line.
export function codeOnly(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .split(/\r?\n/)
    .map((line) => {
      const urlMatch = line.match(URL_LINE_RE);
      if (urlMatch) return `// node-id=${urlMatch[1]}`;
      return /^\s*\/\//.test(line) ? "" : line.trimEnd();
    })
    .filter((line) => line.length > 0)
    .join("\n");
}

// computeInMemoryEmit({ profileDir, profileName, page }) -> Promise<[{
//   name, label, labelSlug, files: {relPath: contents}, manifest
// }]>
//
// Deliberately NOT exported from src/emit/run.mjs itself — that module owns
// disk writing (task B2's contract; see its header). This is a check-only
// reducer over the SAME pure building blocks (computeEmitEntries,
// loadEmitters, buildEmitContext — all imported, never re-derived): it
// calls every emitter's `emit(entry, ctx)` exactly as run.mjs does, but
// collects `{path: contents}` into an in-memory map instead of writing
// files, and never touches `generated/**` itself.
export async function computeInMemoryEmit({ profileDir, profileName, page }) {
  const { profile, cem, figma, entries, iconTable, examples, setAttrs } = computeEmitEntries({ profileDir, page });
  const emitters = await loadEmitters(profile);

  return emitters.map((emitterDef) => {
    const labelSlug = slugify(emitterDef.label);
    const files = {};
    const manifest = {};

    for (const entry of entries) {
      const ctx = buildEmitContext({ profile, figma, cem, entry, iconTable, examples, setAttrs });
      const outFiles = emitterDef.emit(entry, ctx) ?? [];
      if (outFiles.length === 0) continue;

      const filePaths = [];
      for (const file of outFiles) {
        files[file.path] = file.contents;
        filePaths.push(file.path);
      }
      filePaths.sort(byString);
      manifest[entry.cemTag] = filePaths;
    }

    return { name: emitterDef.name, label: emitterDef.label, labelSlug, files, manifest };
  });
}

// readDirRecursive(dir) -> { relPath: contents } (POSIX-style relPath, "/"
// separators regardless of platform). Empty object for a nonexistent dir —
// "nothing committed yet" is a normal state (a brand-new label), not an
// error this function should throw on; the DRIFT loop above turns that into
// real drift entries (every regenerated file reads as "missing").
function readDirRecursive(dir, base = dir) {
  const out = {};
  if (!fs.existsSync(dir)) return out;
  for (const name of fs.readdirSync(dir)) {
    const abs = path.join(dir, name);
    const rel = path.relative(base, abs);
    if (fs.statSync(abs).isDirectory()) {
      Object.assign(out, readDirRecursive(abs, base));
    } else {
      out[rel.split(path.sep).join("/")] = fs.readFileSync(abs, "utf8");
    }
  }
  return out;
}

// runCheck({ profileDir, profileName, page, repoRoot, outRoot }) -> Promise<{
//   ok, drift: [{label, path, reason}], orphan: [{label, path}]
// }>
//
// `outRoot` defaults to `<repoRoot>/generated/<profileName>` (same default
// convention as run.mjs's `runEmit`) but is overridable so tests can point
// it at a scratch tree instead of mutating/depending on the real committed
// `generated/m3-kit/**`.
export async function runCheck({
  profileDir,
  profileName,
  page,
  repoRoot: root = defaultRepoRoot,
  outRoot,
}) {
  const labels = await computeInMemoryEmit({ profileDir, profileName, page });
  const generatedRoot = outRoot ?? path.join(root, "generated", profileName);

  const drift = [];
  const orphan = [];
  const knownSlugs = new Set(labels.map((l) => l.labelSlug));

  for (const { label, labelSlug, files, manifest } of labels) {
    const labelDir = path.join(generatedRoot, labelSlug);
    const committed = readDirRecursive(labelDir);

    for (const [relPath, contents] of Object.entries(files)) {
      const committedContents = committed[relPath];
      if (committedContents === undefined) {
        drift.push({
          label,
          path: `${labelSlug}/${relPath}`,
          reason: "missing from committed generated/** — run `emit` and commit the result",
        });
      } else if (codeOnly(committedContents) !== codeOnly(contents)) {
        drift.push({
          label,
          path: `${labelSlug}/${relPath}`,
          reason: "committed content differs from regenerated output (code-only diff)",
        });
      }
      delete committed[relPath];
    }

    const committedManifestRaw = committed["MANIFEST.json"];
    delete committed["MANIFEST.json"];
    if (committedManifestRaw === undefined) {
      drift.push({
        label,
        path: `${labelSlug}/MANIFEST.json`,
        reason: "missing from committed generated/**",
      });
    } else {
      let committedManifest;
      try {
        committedManifest = JSON.parse(committedManifestRaw);
      } catch {
        committedManifest = null;
      }
      if (JSON.stringify(committedManifest) !== JSON.stringify(manifest)) {
        drift.push({
          label,
          path: `${labelSlug}/MANIFEST.json`,
          reason: "manifest does not match the regenerated cemTag->files map",
        });
      }
    }

    // Whatever's left in `committed` after consuming every regenerated file
    // path + MANIFEST.json is present on disk but traces to no live
    // correspondence entry this run — an orphan.
    for (const relPath of Object.keys(committed).sort(byString)) {
      orphan.push({ label, path: `${labelSlug}/${relPath}` });
    }
  }

  // A whole label directory the profile no longer registers an emitter for
  // at all is entirely orphaned — every file in it, MANIFEST.json included
  // (the loop above never visits it, since it only iterates `labels`, i.e.
  // the profile's CURRENT emitters[]).
  if (fs.existsSync(generatedRoot)) {
    for (const name of fs.readdirSync(generatedRoot).sort(byString)) {
      if (knownSlugs.has(name)) continue;
      const strayDir = path.join(generatedRoot, name);
      if (!fs.statSync(strayDir).isDirectory()) continue;
      const strayFiles = readDirRecursive(strayDir);
      for (const relPath of Object.keys(strayFiles).sort(byString)) {
        orphan.push({ label: `(unregistered label dir: ${name})`, path: `${name}/${relPath}` });
      }
    }
  }

  return { ok: drift.length === 0 && orphan.length === 0, drift, orphan };
}
