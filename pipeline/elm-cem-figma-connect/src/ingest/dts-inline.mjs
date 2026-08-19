// Standalone port of elm-cem's `inlineTypeAliases()` / `collectLiteralAliases()`
// (bin/elm-cem.js, ~lines 391-520). Deliberately NOT imported from elm-cem —
// this package has its own zero-runtime-dep rule, and the algorithm is small
// enough to vendor faithfully rather than add a cross-repo dependency.
//
// A Custom Elements Manifest often types an enum attribute as a bare
// TypeScript alias name (`{ "type": { "text": "ButtonVariant" } }`) rather
// than an inlined literal union — the manifest analyzer doesn't resolve
// named types. This scans the package's shipped `.d.ts` declarations for
// PURE string/numeric-literal-union type aliases and inlines them into
// every `type.text` in the manifest that references one (bare, or as part
// of a `X | null` / `X | undefined` compound).
//
// Single pass, no alias-of-alias resolution: the 2.5.14 @m3e/web audit
// (research/evidence/06b-dts-inlining-coverage.md, evidence #7) found ZERO
// alias-of-alias chains in the package. Do not add multi-pass resolution
// speculatively — YAGNI until a real package needs it.

import fs from "node:fs";
import path from "node:path";

// Strip `//` line comments and `/* … */` block comments from TypeScript
// source, so a multiline / commented string-literal union still matches.
export function stripTsComments(src) {
  return src.replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/[^\n]*/g, "");
}

// All `.d.ts` files under `dir`, recursive. Missing dir -> empty list
// (defensive; mirrors elm-cem's behavior of no-op'ing rather than throwing
// when there's nothing to scan).
export function dtsFiles(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...dtsFiles(full));
    else if (entry.name.endsWith(".d.ts")) out.push(full);
  }
  return out;
}

// Map of `AliasName -> "<literal union>"` for every PURE literal-union type
// alias declared in any `.d.ts` under `rootDir` — both string unions
// (`"a" | "b"`) and numeric unions (`1 | 2 | 3`). Handles multiline unions
// and an optional leading `|`, and ignores comments.
export function collectLiteralAliases(rootDir) {
  const map = {};
  const re = /\b(?:export\s+)?(?:declare\s+)?type\s+([A-Za-z_$][\w$]*)\s*=\s*([^;]+);/g;
  // A member is a quoted string literal OR a numeric literal.
  const member = `(?:"[^"]*"|'[^']*'|-?\\d+(?:\\.\\d+)?)`;
  // Optional leading `|`, then one-or-more literal members separated by `|`.
  const onlyLiteralUnion = new RegExp(`^\\|?\\s*${member}(?:\\s*\\|\\s*${member})*$`);
  for (const file of dtsFiles(rootDir)) {
    let src;
    try {
      src = fs.readFileSync(file, "utf8");
    } catch {
      continue;
    }
    src = stripTsComments(src);
    let m;
    while ((m = re.exec(src))) {
      const name = m[1];
      const body = m[2].replace(/\s+/g, " ").trim();
      if (onlyLiteralUnion.test(body)) {
        // Normalise to double quotes and drop any leading `|`.
        map[name] = body.replace(/^\|\s*/, "").replace(/'/g, '"');
      }
    }
  }
  return map;
}

// Expand a CEM `type.text` if (any of) its `|`-separated parts name a known
// string/numeric-literal alias. Returns null when nothing resolves. Keeps
// non-alias parts (e.g. `undefined`) so a nullable alias still yields a
// literal union: `ShapeName | null` -> `"round" | "square" | null`.
export function resolveAlias(text, aliases) {
  const parts = text.split("|").map((s) => s.trim());
  if (!parts.some((p) => aliases[p])) return null;
  return parts.map((p) => aliases[p] || p).join(" | ");
}

// Deep-clones `cem`, walks every node, and rewrites `node.type.text` in
// place wherever resolveAlias() finds something to expand — attributes,
// members, anything shaped `{ type: { text: "..." } }` anywhere in the
// manifest tree (mirrors elm-cem's generic `visit`, which doesn't special-
// case attributes vs. other declaration members).
//
// Returns `{ cem, changed, aliases }`:
//   - cem: the rewritten manifest (new object; input is never mutated)
//   - changed: count of `type.text` rewrites performed
//   - aliases: the literal-alias map collected from `dtsDir` (exposed for
//     callers/tests that want to report on what was available to inline)
export function inlineTypeAliases(cem, dtsDir) {
  const aliases = collectLiteralAliases(dtsDir);
  const next = JSON.parse(JSON.stringify(cem));
  let changed = 0;

  if (Object.keys(aliases).length === 0) return { cem: next, changed, aliases };

  const visit = (node) => {
    if (Array.isArray(node)) {
      node.forEach(visit);
      return;
    }
    if (node && typeof node === "object") {
      if (node.type && typeof node.type.text === "string") {
        const resolved = resolveAlias(node.type.text, aliases);
        if (resolved && resolved !== node.type.text) {
          node.type.text = resolved;
          changed++;
        }
      }
      for (const key of Object.keys(node)) visit(node[key]);
    }
  };
  visit(next);

  return { cem: next, changed, aliases };
}
