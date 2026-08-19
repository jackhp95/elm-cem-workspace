// Shared helpers for the elm-cem brand-contract subcommands (gate / validate /
// acid / brand-sync). Centralizing these here — inside the one generator repo —
// is the whole point of issue #50: the brands stopped hand-copying divergent
// forks of measure-docs.mjs / validate.mjs / acid-probe.mjs, and now carry only
// config. Everything here is portable (no absolute authoring-machine paths): the
// elm / elm-format binaries and the unpublished family sources (IR, facts) are
// resolved by walking node_modules and the sibling repo layout, with env
// overrides (ELM_CEM_BIN pattern established by #49).

"use strict";

const fs = require("fs");
const path = require("path");

// The docs.json byte cap a single published package must stay under (elm docs
// preview / registry practicality). Single-sourced here so validate and the
// split-measure path agree.
const DOCS_LIMIT = 700_000;

// Resolve an executable from node_modules/.bin, walking up from the invoking
// project (cwd) first and then from this elm-cem checkout. Returns an absolute
// path or null. Same strategy regen-drift/registry-check use — kept identical so
// every subcommand finds the same pinned tools.
function resolveBin(name) {
  const binName = process.platform === "win32" ? `${name}.cmd` : name;
  const roots = [process.cwd(), path.resolve(__dirname, "..")];
  const seen = new Set();
  for (const start of roots) {
    let dir = start;
    while (dir && !seen.has(dir)) {
      seen.add(dir);
      const cand = path.join(dir, "node_modules", ".bin", binName);
      if (fs.existsSync(cand)) return cand;
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }
  return null;
}

// Local src/ for the unpublished IR package. Env override wins, then a sibling
// layout relative to either this elm-cem checkout or the brand being processed.
function resolveIrSrc() {
  const candidates = [];
  if (process.env.IR_SRC) candidates.push(process.env.IR_SRC);
  candidates.push(path.resolve(__dirname, "..", "elm-virtual-dom-intermediate-representation", "src")); // in-repo renamed symlink (workspace)
  candidates.push(path.resolve(__dirname, "..", "..", "..", "packages", "elm-virtual-dom-intermediate-representation", "src")); // workspace packages/
  candidates.push(path.resolve(__dirname, "..", "..", "elm-html-intermediate-representation", "src")); // standalone sibling (external mirror dir name)
  candidates.push(path.resolve(process.cwd(), "..", "elm-html-intermediate-representation", "src")); // brand-sibling (external mirror dir name)
  return candidates.find((c) => c && fs.existsSync(c)) || null;
}

// Local src/ for the unpublished elm-cem-facts package (bundled inside elm-cem).
function resolveFactsSrc() {
  const candidates = [];
  if (process.env.FACTS_SRC) candidates.push(process.env.FACTS_SRC);
  candidates.push(path.resolve(__dirname, "..", "facts", "src"));
  candidates.push(path.resolve(process.cwd(), "..", "elm-cem", "facts", "src"));
  return candidates.find((c) => c && fs.existsSync(c)) || null;
}

// Recursively copy a source tree, preserving structure. `filter(relPath, isDir)`
// may exclude entries (relPath is POSIX-normalised, relative to the copy root).
// NOTE callers: a directory whose filter returns false is skipped wholesale, so
// a file-only predicate must still admit directories (isDir === true) or the
// whole subtree — and every module under it — is dropped.
function copyDir(src, dst, filter = () => true, base = src) {
  if (!fs.existsSync(src)) return;
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const rel = path.relative(base, s).split(path.sep).join("/");
    const isDir = entry.isDirectory();
    if (!filter(rel, isDir)) continue;
    const d = path.join(dst, entry.name);
    if (isDir) {
      fs.mkdirSync(d, { recursive: true });
      copyDir(s, d, filter, base);
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

// Every non-Internal, non-Review .elm module under dir, as dotted module names.
// (Internal.* is private; Review.* ships separately and imports the unpublished
// elm-review-cem — neither belongs in a package's exposed/docs surface.)
function walkElmModules(dir, base = dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...walkElmModules(full, base));
    } else if (entry.name.endsWith(".elm")) {
      const rel = path.relative(base, full).replace(/\.elm$/, "").split(path.sep).join(".");
      if (!/(^|\.)Internal(\.|$)/.test(rel) && !/(^|\.)Review(\.|$)/.test(rel)) out.push(rel);
    }
  }
  return out;
}

module.exports = {
  DOCS_LIMIT,
  resolveBin,
  resolveIrSrc,
  resolveFactsSrc,
  copyDir,
  walkElmModules,
};
