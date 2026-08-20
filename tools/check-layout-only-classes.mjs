#!/usr/bin/env node
// tools/check-layout-only-classes.mjs — fast, dependency-free, AGENT-TIME
// subset of the authoritative elm-review rule
// brands/m3e/generated/package/elm-m3e/review/src/NoProprietaryDsClasses.elm.
//
// WHY THIS EXISTS (see docs/plans/2026-08-19-durable-m3e-convention-enforcement.md):
// the AST rule already enforces "Tailwind is LAYOUT only" and the m3e-utility
// manifest, but it only runs where the docs pipeline is provisioned
// (check:review SKIPs in a bare clone / agent worktree) and only at
// pre-push/CI time. Agents write violations and present work as "done" long
// before that gate fires. This script closes the feedback gap: it runs in
// <100ms, needs NO node_modules, NO elm-pages codegen, NO network — so it can
// run as a Claude Code PostToolUse hook on every Edit/Write of an .elm file,
// or standalone on changed files.
//
// DRIFT DISCIPLINE: the layout/styling taxonomy is NOT duplicated here. The
// four lists (layoutKeywords, layoutPrefixes, stylingKeywords,
// stylingPrefixes) are parsed at runtime from the Elm rule's own source, and
// the m3e utility names come from the same committed manifest the rule uses
// (brands/m3e/generated/style/elm-m3e-tailwind/generated/utilities.json). Only the tiny, stable
// classifier scaffolding (ds-/t- proprietary prefixes, the [--m3e- arbitrary
// bridge, the inset-shadow-/inset-ring- shadowed-styling pair, classification
// order) is mirrored in code — each mirrors a named function in the rule.
//
// SCOPE (deliberate subset — the elm-review rule stays authoritative):
//   - checks string LITERALS passed to `class` / `…withClass` / `classList`.
//     Computed classes (`class (a ++ b)`) are left to the AST rule.
//   - module-level Seam fence mirrored: modules named `Seam` (or `Seam.*`)
//     are skipped, matching `NoProprietaryDsClasses.rule [ "Seam" ]`.
//   - generated/vendored/test/review/sample paths are skipped.
//
// MODES:
//   node tools/check-layout-only-classes.mjs FILE [FILE…]   exit 1 on violations
//   node tools/check-layout-only-classes.mjs --all          scan the reviewed dirs
//   node tools/check-layout-only-classes.mjs --hook         Claude Code PostToolUse:
//       reads the hook JSON on stdin, checks tool_input.file_path, exits 2 on
//       violations (blocking feedback to the agent), 0 otherwise. Internal
//       errors NEVER block an edit in hook mode (warn + exit 0).

import { readFileSync, readdirSync, statSync, existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

const RULE_SOURCE = path.join(
  repoRoot,
  "brands/m3e/generated/package/elm-m3e/review/src/NoProprietaryDsClasses.elm",
);
const UTILITIES_MANIFEST = path.join(
  repoRoot,
  "brands/m3e/generated/style/elm-m3e-tailwind/generated/utilities.json",
);
// The rule's wiring — carries the documented specimen exemptions
// (Rule.ignoreErrorsForDirectories/Files on Route/Styles/ etc.), which this
// script parses rather than duplicates.
const REVIEW_CONFIG = path.join(
  repoRoot,
  "brands/m3e/generated/package/elm-m3e/review/src/ReviewConfig.elm",
);

// Mirrors CodegenReviewConfig.elm: NoProprietaryDsClasses.rule [ "Seam" ].
const SEAM_MODULES = ["Seam"];

// Path fragments that are out of scope: vendored, generated wiring, derived
// fixtures, and the rule/tests trees whose fixtures INTENTIONALLY contain
// violations.
const SKIP_PATH_FRAGMENTS = [
  "/node_modules/",
  "/elm-stuff/",
  "/vendor/",
  "/.elm-pages/",
  "/samples/",
  "/tests/",
  "/review/",
];

// The directories the docs review config actually reviews (docs/elm.json
// source-directories, minus generated/vendored ones), used by --all.
const ALL_DIRS = [
  "brands/m3e/generated/docs/elm-m3e-docs/app",
  "brands/m3e/generated/docs/elm-m3e-docs/src",
  "brands/m3e/generated/package/elm-m3e/src",
  "pipeline/elm-cem-compose/src",
];

// ---------------------------------------------------------------------------
// Taxonomy: parsed from the Elm rule source, never duplicated.
// ---------------------------------------------------------------------------

function parseElmStringList(elmSource, name) {
  // elm-format normalizes a top-level list binding to:
  //   name =\n    [ "a"\n    , "b"\n    …\n    ]
  const declStart = elmSource.indexOf(`\n${name} =`);
  if (declStart === -1) throw new Error(`list binding not found: ${name}`);
  const close = elmSource.indexOf("\n    ]", declStart);
  if (close === -1) throw new Error(`unterminated list: ${name}`);
  const body = elmSource.slice(declStart, close);
  const items = [...body.matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((m) => m[1]);
  if (items.length === 0) throw new Error(`parsed empty list: ${name}`);
  return items;
}

// Parse the specimen exemptions out of materialDiscipline in ReviewConfig.elm:
// every path-shaped string literal (contains "/") in that binding is an
// ignoreErrorsForDirectories/Files entry. ["Seam"] has no slash, so it is
// naturally excluded.
function parseExemptions(reviewConfigSource) {
  const start = reviewConfigSource.indexOf("\nmaterialDiscipline =");
  if (start === -1) throw new Error("materialDiscipline binding not found");
  const end = reviewConfigSource.indexOf("\n\n\n", start);
  const body = reviewConfigSource.slice(start, end === -1 ? undefined : end);
  return [...body.matchAll(/"((?:[^"\\]|\\.)*)"/g)]
    .map((m) => m[1])
    .filter((s) => s.includes("/"));
}

function loadTaxonomy() {
  const src = readFileSync(RULE_SOURCE, "utf8");
  const manifest = JSON.parse(readFileSync(UTILITIES_MANIFEST, "utf8"));
  const exemptions = parseExemptions(readFileSync(REVIEW_CONFIG, "utf8"));
  const m3eNames = manifest.utilities;
  if (!Array.isArray(m3eNames) || m3eNames.length === 0) {
    throw new Error(`no utilities in ${UTILITIES_MANIFEST}`);
  }
  return {
    layoutKeywords: new Set(parseElmStringList(src, "layoutKeywords")),
    layoutPrefixes: parseElmStringList(src, "layoutPrefixes"),
    stylingKeywords: new Set(parseElmStringList(src, "stylingKeywords")),
    stylingPrefixes: parseElmStringList(src, "stylingPrefixes"),
    m3eNameSet: new Set(m3eNames),
    m3eNames,
    exemptions,
  };
}

// Mirror Rule.ignoreErrorsForDirectories/Files: an exemption ending in "/" is
// a directory prefix, otherwise an exact file path — both relative to the
// review target (the docs project), so match on path suffix/containment.
function isExemptPath(normalizedPath, taxonomy) {
  return taxonomy.exemptions.some((entry) =>
    entry.endsWith("/")
      ? normalizedPath.includes(`/${entry}`)
      : normalizedPath.endsWith(`/${entry}`),
  );
}

// ---------------------------------------------------------------------------
// Token classification — mirrors classify/utilityPart/stripModifiers/… in
// NoProprietaryDsClasses.elm, one function per Elm counterpart.
// ---------------------------------------------------------------------------

// Elm: utilityPart — keep the final depth-0 `:`-separated segment.
function utilityPart(token) {
  let depth = 0;
  let current = "";
  for (const char of token) {
    if (char === "[" || char === "(") {
      depth += 1;
      current += char;
    } else if (char === "]" || char === ")") {
      depth -= 1;
      current += char;
    } else if (char === ":" && depth === 0) {
      current = "";
    } else {
      current += char;
    }
  }
  return current;
}

// Elm: stripModifiers — drop `!` then a leading `-`.
function stripModifiers(utility) {
  let u = utility;
  if (u.startsWith("!")) u = u.slice(1);
  if (u.startsWith("-")) u = u.slice(1);
  return u;
}

// Elm: isProprietary.
const isProprietary = (base) => base.startsWith("ds-") || base.startsWith("t-");

// Elm: isM3eTokenUtility — manifest membership, name or name + "-".
function isM3eTokenUtility(base, taxonomy) {
  if (!base.startsWith("m3e-")) return false;
  if (taxonomy.m3eNameSet.has(base)) return true;
  return taxonomy.m3eNames.some((name) => base.startsWith(name + "-"));
}

// Elm: classifyArbitraryProperty — only the `--m3e-*` token bridge is allowed.
const classifyArbitraryProperty = (base) =>
  base.startsWith("[--m3e-") ? "Allowed" : "Styling";

// Elm: isShadowedStyling — styling families hiding under a layout prefix.
const isShadowedStyling = (base) =>
  base.startsWith("inset-shadow-") || base.startsWith("inset-ring-");

// Elm: classify — same branch order.
export function classify(token, taxonomy) {
  const base = stripModifiers(utilityPart(token));
  if (base === "") return "Allowed";
  if (isProprietary(base)) return "Proprietary";
  if (isM3eTokenUtility(base, taxonomy)) return "Allowed";
  if (base.startsWith("m3e-")) return "DeadM3eUtility";
  if (base.startsWith("[")) return classifyArbitraryProperty(base);
  if (isShadowedStyling(base)) return "Styling";
  if (
    taxonomy.layoutKeywords.has(base) ||
    taxonomy.layoutPrefixes.some((p) => base.startsWith(p))
  ) {
    return "Allowed";
  }
  if (
    taxonomy.stylingKeywords.has(base) ||
    taxonomy.stylingPrefixes.some((p) => base.startsWith(p))
  ) {
    return "Styling";
  }
  return "Allowed";
}

// ---------------------------------------------------------------------------
// Elm source scanning: comment/string-aware tokenizer, so class literals
// inside doc comments or inside OTHER string literals (markdown samples)
// never false-positive.
// ---------------------------------------------------------------------------

// Tokenize into code chunks and string literals. Comments are dropped.
// Returns [{ kind: "code"|"string", text, offset }] where a string token's
// `text` is the CONTENT (no quotes) and `offset` is the content start.
export function tokenizeElm(source) {
  const tokens = [];
  let code = "";
  let codeStart = 0;
  let i = 0;
  const n = source.length;

  const flushCode = () => {
    if (code !== "") tokens.push({ kind: "code", text: code, offset: codeStart });
    code = "";
  };

  while (i < n) {
    const two = source.slice(i, i + 2);
    if (two === "--") {
      // Line comment.
      flushCode();
      while (i < n && source[i] !== "\n") i += 1;
      codeStart = i;
    } else if (two === "{-") {
      // Nested block comment.
      flushCode();
      let depth = 1;
      i += 2;
      while (i < n && depth > 0) {
        if (source.slice(i, i + 2) === "{-") {
          depth += 1;
          i += 2;
        } else if (source.slice(i, i + 2) === "-}") {
          depth -= 1;
          i += 2;
        } else {
          i += 1;
        }
      }
      codeStart = i;
    } else if (source.slice(i, i + 3) === '"""') {
      // Triple-quoted string.
      flushCode();
      i += 3;
      const start = i;
      while (i < n && source.slice(i, i + 3) !== '"""') {
        i += source[i] === "\\" ? 2 : 1;
      }
      tokens.push({ kind: "string", text: source.slice(start, i), offset: start });
      i += 3;
      codeStart = i;
    } else if (source[i] === '"') {
      flushCode();
      i += 1;
      const start = i;
      while (i < n && source[i] !== '"') {
        i += source[i] === "\\" ? 2 : 1;
      }
      tokens.push({ kind: "string", text: source.slice(start, i), offset: start });
      i += 1;
      codeStart = i;
    } else if (source[i] === "'") {
      // Char literal — may contain a quote ('"') or escape ('\'').
      code += source[i];
      i += 1;
      while (i < n && source[i] !== "'") {
        code += source[i];
        i += source[i] === "\\" ? 2 : 1;
      }
      if (i < n) {
        code += source[i];
        i += 1;
      }
    } else {
      code += source[i];
      i += 1;
    }
  }
  flushCode();
  return tokens;
}

// A string literal is a class argument when the code immediately before it
// ends in the word `class` or `…withClass`/`…WithClass` (qualified or not),
// or when it sits inside a `classList [ … ]` span.
export function collectClassStrings(source) {
  const tokens = tokenizeElm(source);
  const found = [];
  let classListDepth = null; // bracket depth inside an open classList span

  for (let t = 0; t < tokens.length; t += 1) {
    const token = tokens[t];
    if (token.kind === "code") {
      const text = token.text;
      let scanFrom = 0;
      if (classListDepth === null) {
        const idx = text.lastIndexOf("classList");
        if (idx === -1) continue;
        classListDepth = 0; // pending: waiting for the span's opening `[`
        scanFrom = idx;
      }
      for (const char of text.slice(scanFrom)) {
        if (char === "[") {
          classListDepth += 1;
        } else if (char === "]") {
          classListDepth -= 1;
          if (classListDepth <= 0) {
            classListDepth = null; // span closed
            break;
          }
        }
      }
    } else {
      const prev = tokens[t - 1];
      const before = prev && prev.kind === "code" ? prev.text.trimEnd() : "";
      const isDirect = /(^|[^\w'.])(?:[A-Z][\w.]*\.)?class$/.test(before);
      const isSetter = /[wW]ithClass$/.test(before);
      const inClassList = classListDepth !== null && classListDepth > 0;
      if (isDirect || isSetter || inClassList) {
        found.push({ text: token.text, offset: token.offset });
      }
    }
  }
  return found;
}

const lineOf = (source, offset) =>
  source.slice(0, offset).split("\n").length;

function moduleName(source) {
  const m = source.match(/^(?:port\s+|effect\s+)?module\s+([\w.]+)/m);
  return m ? m[1] : null;
}

const isSeamModule = (name) =>
  name !== null &&
  SEAM_MODULES.some((seam) => name === seam || name.startsWith(seam + "."));

// ---------------------------------------------------------------------------
// File checking
// ---------------------------------------------------------------------------

export function checkFile(filePath, taxonomy) {
  const normalized = filePath.split(path.sep).join("/");
  if (!normalized.endsWith(".elm")) return [];
  if (SKIP_PATH_FRAGMENTS.some((f) => normalized.includes(f))) return [];
  if (isExemptPath(normalized, taxonomy)) return [];

  const source = readFileSync(filePath, "utf8");
  if (isSeamModule(moduleName(source))) return [];

  const violations = [];
  for (const literal of collectClassStrings(source)) {
    for (const token of literal.text.split(/\s+/).filter(Boolean)) {
      const verdict = classify(token, taxonomy);
      if (verdict !== "Allowed") {
        violations.push({
          file: filePath,
          line: lineOf(source, literal.offset),
          token,
          verdict,
        });
      }
    }
  }
  return violations;
}

function explain(violations) {
  const lines = violations.map(
    (v) => `${v.file}:${v.line}: ${v.verdict === "DeadM3eUtility" ? "dead m3e utility" : "non-layout class"} \`${v.token}\``,
  );
  return [
    ...lines,
    "",
    "Tailwind is for LAYOUT only in this workspace. Colour, background, border,",
    "radius, elevation and TYPOGRAPHY must come from an m3e component or an",
    "m3e-* token utility — never a text-*/font-*/bg-*/… class.",
    "  - Type roles:  brands/m3e/inputs/material-okf/knowledge/styles/typography.md",
    "  - Component API ground truth: brands/m3e/generated/okf/elm-m3e-okf/skills/m3e/components/",
    "  - Authoritative rule: brands/m3e/generated/package/elm-m3e/review/src/NoProprietaryDsClasses.elm",
    "    (run: pnpm --filter elm-m3e run check:review)",
    "  - A genuine, reviewed escape belongs in a `Seam` module, nowhere else.",
  ].join("\n");
}

function walkElmFiles(dir, acc = []) {
  for (const entry of readdirSync(dir)) {
    const full = path.join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) {
      if (!["node_modules", "elm-stuff", ".elm-pages", "vendor"].includes(entry)) {
        walkElmFiles(full, acc);
      }
    } else if (entry.endsWith(".elm")) {
      acc.push(full);
    }
  }
  return acc;
}

// ---------------------------------------------------------------------------
// Entry points
// ---------------------------------------------------------------------------

function runHookMode() {
  let input = "";
  process.stdin.on("data", (chunk) => (input += chunk));
  process.stdin.on("end", () => {
    try {
      const payload = JSON.parse(input || "{}");
      const filePath = payload?.tool_input?.file_path;
      if (!filePath || !filePath.endsWith(".elm") || !existsSync(filePath)) {
        process.exit(0);
      }
      const violations = checkFile(filePath, loadTaxonomy());
      if (violations.length > 0) {
        console.error(explain(violations));
        process.exit(2); // blocking feedback to the agent
      }
      process.exit(0);
    } catch (err) {
      // Never block an edit because THIS script broke.
      console.error(`check-layout-only-classes: hook-mode internal error (not blocking): ${err.message}`);
      process.exit(0);
    }
  });
}

function main() {
  const args = process.argv.slice(2);
  if (args[0] === "--hook") {
    runHookMode();
    return;
  }

  const taxonomy = loadTaxonomy();
  const files =
    args[0] === "--all"
      ? ALL_DIRS.map((d) => path.join(repoRoot, d))
          .filter(existsSync)
          .flatMap((d) => walkElmFiles(d))
      : args;

  if (files.length === 0) {
    console.error(
      "usage: check-layout-only-classes.mjs (--hook | --all | FILE.elm [FILE.elm…])",
    );
    process.exit(64);
  }

  const violations = files.flatMap((f) => checkFile(f, taxonomy));
  if (violations.length > 0) {
    console.error(explain(violations));
    process.exit(1);
  }
  console.log(`check-layout-only-classes: OK (${files.length} file(s), 0 violations)`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}

export { loadTaxonomy, explain };
