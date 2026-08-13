#!/usr/bin/env node
// Replicates elm-cem's inlineTypeAliases()/collectLiteralAliases() from
// /Users/jhp/code/jackhp95/elm-cem/bin/elm-cem.js (read-only; nothing in the
// elm-cem repo is touched) and measures attribute-type coverage against
// @m3e/web's CEM + .d.ts tree.
//
// Buckets (per attribute with a type.text):
//   primitive        — string/boolean/number/literal unions of those (+null/undefined)
//   inlineLiteral    — already a pure literal union in the CEM (no alias needed)
//   resolvedFull     — inliner rewrites it into a pure literal(/nullish) union
//   resolvedPartial  — inliner rewrites some parts, but non-literal parts remain
//   unresolved       — inliner changes nothing and the type names something non-primitive

const fs = require("fs");
const path = require("path");

const PKG = process.argv[2];
if (!PKG) { console.error("usage: inline-coverage.js <path-to-@m3e/web>"); process.exit(1); }
const cemPath = path.join(PKG, "dist", "custom-elements.json");
const cem = JSON.parse(fs.readFileSync(cemPath, "utf8"));
// elm-cem: dtsDir = dirname of the CEM file => dist/, scanned recursively.
const dtsDir = path.dirname(cemPath);

// ---- verbatim algorithm copies (bin/elm-cem.js lines 444-504) --------------
function stripTsComments(src) {
  return src.replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/[^\n]*/g, "");
}
function dtsFiles(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...dtsFiles(full));
    else if (entry.name.endsWith(".d.ts")) out.push(full);
  }
  return out;
}
function collectLiteralAliases(rootDir) {
  const map = {};
  const re = /\b(?:export\s+)?(?:declare\s+)?type\s+([A-Za-z_$][\w$]*)\s*=\s*([^;]+);/g;
  const member = `(?:"[^"]*"|'[^']*'|-?\\d+(?:\\.\\d+)?)`;
  const onlyLiteralUnion = new RegExp(`^\\|?\\s*${member}(?:\\s*\\|\\s*${member})*$`);
  for (const file of dtsFiles(rootDir)) {
    let src;
    try { src = fs.readFileSync(file, "utf8"); } catch { continue; }
    src = stripTsComments(src);
    let m;
    while ((m = re.exec(src))) {
      const name = m[1];
      const body = m[2].replace(/\s+/g, " ").trim();
      if (onlyLiteralUnion.test(body)) {
        map[name] = body.replace(/^\|\s*/, "").replace(/'/g, '"');
      }
    }
  }
  return map;
}
function resolveAlias(text, aliases) {
  const parts = text.split("|").map((s) => s.trim());
  if (!parts.some((p) => aliases[p])) return null;
  return parts.map((p) => aliases[p] || p).join(" | ");
}
// ---------------------------------------------------------------------------

// All type aliases (any body), to explain unresolved names and detect chains.
function collectAllAliases(rootDir) {
  const map = {};
  const re = /\b(?:export\s+)?(?:declare\s+)?type\s+([A-Za-z_$][\w$]*)(?:<[^=]*?>)?\s*=\s*([^;]+);/g;
  for (const file of dtsFiles(rootDir)) {
    let src;
    try { src = fs.readFileSync(file, "utf8"); } catch { continue; }
    src = stripTsComments(src);
    let m;
    while ((m = re.exec(src))) {
      const body = m[2].replace(/\s+/g, " ").trim();
      if (!(m[1] in map)) map[m[1]] = { body, file: path.relative(rootDir, file) };
    }
  }
  return map;
}

const aliases = collectLiteralAliases(dtsDir);
const allAliases = collectAllAliases(dtsDir);

const PRIMITIVE = /^(string|boolean|number|String|Boolean|Number)$/;
const NULLISH = /^(null|undefined)$/;
const LITERAL = /^("[^"]*"|'[^']*'|-?\d+(\.\d+)?)$/;
function parts(t) { return t.split("|").map((s) => s.trim()).filter(Boolean); }
function isPrimitiveish(t) {
  const ps = parts(t).filter((p) => !NULLISH.test(p));
  return ps.length > 0 && ps.every((p) => PRIMITIVE.test(p) || LITERAL.test(p));
}
// pure literal union (optionally with null/undefined) — fully enumerable
function isPureLiteralUnion(t) {
  const ps = parts(t).filter((p) => !NULLISH.test(p));
  return ps.length > 0 && ps.every((p) => LITERAL.test(p));
}

const rows = [];
for (const mod of cem.modules || []) {
  for (const decl of mod.declarations || []) {
    if (!decl.customElement || !decl.tagName) continue;
    for (const attr of decl.attributes || []) {
      const text = attr.type && attr.type.text;
      rows.push({ tag: decl.tagName, attr: attr.name, text: text == null ? null : text.trim() });
    }
  }
}

const buckets = { noType: [], primitive: [], inlineLiteral: [], resolvedFull: [], resolvedPartial: [], unresolved: [] };
for (const r of rows) {
  if (r.text == null) { buckets.noType.push(r); continue; }
  if (isPrimitiveish(r.text)) { buckets.primitive.push(r); continue; }
  if (isPureLiteralUnion(r.text)) { buckets.inlineLiteral.push(r); continue; }
  const res = resolveAlias(r.text, aliases);
  if (res) {
    r.resolvedTo = res;
    if (isPureLiteralUnion(res) || isPrimitiveish(res)) buckets.resolvedFull.push(r);
    else buckets.resolvedPartial.push(r);
  } else {
    buckets.unresolved.push(r);
  }
}

function classify(text) {
  return parts(text).map((p) => {
    if (NULLISH.test(p)) return { part: p, kind: "nullish" };
    if (PRIMITIVE.test(p)) return { part: p, kind: "primitive" };
    if (LITERAL.test(p)) return { part: p, kind: "literal" };
    if (allAliases[p]) {
      const a = allAliases[p];
      const chained = resolveAlias(a.body, aliases);
      return { part: p, kind: "alias-not-in-literal-map", body: a.body, file: a.file, chainResolvesTo: chained };
    }
    return { part: p, kind: "not-an-alias-in-dts" };
  });
}

const named = buckets.resolvedFull.length + buckets.resolvedPartial.length + buckets.unresolved.length;
console.log(JSON.stringify({
  pkg: PKG,
  dtsFileCount: dtsFiles(dtsDir).length,
  literalAliasCount: Object.keys(aliases).length,
  allAliasCount: Object.keys(allAliases).length,
  totals: {
    attributes: rows.length,
    noType: buckets.noType.length,
    primitive: buckets.primitive.length,
    inlineLiteralUnion: buckets.inlineLiteral.length,
    namedOrComplex: named,
    resolvedFull: buckets.resolvedFull.length,
    resolvedPartial: buckets.resolvedPartial.length,
    unresolved: buckets.unresolved.length,
  },
  resolvedPartial: buckets.resolvedPartial.map((r) => ({ tag: r.tag, attr: r.attr, from: r.text, to: r.resolvedTo })),
  unresolved: buckets.unresolved.map((r) => ({ tag: r.tag, attr: r.attr, text: r.text, explain: classify(r.text) })),
  inlineLiteral: buckets.inlineLiteral.map((r) => ({ tag: r.tag, attr: r.attr, text: r.text })),
  noType: buckets.noType.map((r) => `${r.tag}.${r.attr}`),
}, null, 2));
