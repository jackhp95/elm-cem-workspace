// Orchestrator: run the deterministic HTML->Elm converter over the whole mined
// corpus (data/examples.json) and emit the generated example config the docs
// build consumes:
//
//   config/examples.generated.json  keyed by PascalCase module ->
//     { examples: [ { title, code, section? } ], docMeta: { category } }
//   config/examples.skipped.txt     one line per skipped example:
//     <module> :: <title> :: <reason>
//
// A component appears only if it has >=1 successfully-converted example. Each
// example's `code` is a self-contained Elm expression (or a gallery of several
// joined by a blank line). `section` is present only when non-null.
//
// Multi-root handling: many mined examples have several top-level sibling
// elements (e.g. five button variants). `toElm` maps a single root; here we
// detect >1 top-level node, convert EACH sibling separately, and assemble their
// code into ONE Elm LIST expression (`[ expr1\n    , expr2\n    ... ]`) — a
// single, compilable expression. Single-root examples stay a bare expression.
// If any sibling skips, the whole example skips with that reason.
//
// Every candidate example is then COMPILE-VERIFIED against the real M3e.* / Kit
// API (see verify-examples.mjs) at the Standard `M3e.*` (top) surface. A top that
// fails to compile (or that the converter couldn't map) is NULLED and the example
// is KEPT — it ships its always-present HTML surface (and any downstream
// Record/Build/barrel surface). Only registration-only <script>/<link> cards are
// filtered out. Each outcome is logged to config/examples.skipped.txt as either
// `degraded: top: <reason>` (kept, top nulled) or `filtered:`.

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { parseHTML } from "linkedom";

import { buildOracle } from "./lib/oracle.mjs";
import { loadFacts } from "./lib/facts.mjs";
import { toElm } from "./lib/to-elm.mjs";
import { deriveSection } from "./lib/sections.mjs";
import { pascal } from "./lib/naming.mjs";
import { verifyExamples } from "./verify-examples.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
// docs/scripts/examples-gen/examples-to-elm.mjs -> elm-m3e root is three up.
const REPO_ROOT = resolve(HERE, "..", "..", "..");

// The example corpus is the VERBATIM matraic doc-site source, extracted by
// extract-matraic-examples.mjs into a committed file (so clean checkouts need no
// upstream clone). Refresh it with: npm run build:examples-source. Overridable
// via M3E_EXAMPLES_PATH for experiments.
const EXAMPLES_PATH =
  process.env.M3E_EXAMPLES_PATH ||
  resolve(REPO_ROOT, "config", "examples.matraic.json");
const CATEGORIES_PATH = resolve(REPO_ROOT, "config", "categories.json");
const OUT_GENERATED = resolve(REPO_ROOT, "config", "examples.generated.json");
const OUT_RICH = resolve(REPO_ROOT, "config", "examples.rich.json");
const OUT_SKIPPED = resolve(REPO_ROOT, "config", "examples.skipped.txt");

const DEFAULT_CATEGORY = "Layout & style";

// A few example modules use a different PascalCase name than the reference
// module they map to; `categories.json` is keyed by the reference SLUG, so
// translate those before the lookup (mirrors build-examples-data.mjs).
const SLUG_ALIASES = {
  Chips: "chip", // <m3e-chip>
  Search: "searchbar", // <m3e-search-bar>
  ProgressIndicator: "progress", // linear/circular fold into M3e.Progress
};

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

/** Non-whitespace top-level nodes (elements + non-empty text). */
function topLevelNodes(htmlString) {
  const { document } = parseHTML(`<html><body>${htmlString}</body></html>`);
  return [...document.body.childNodes].filter(
    (n) =>
      n.nodeType === 1 ||
      (n.nodeType === 3 && n.textContent.trim() !== ""),
  );
}

/** Serialize a single top-level node back to an HTML string for re-conversion. */
function nodeToHtml(node) {
  if (node.nodeType === 3) return node.textContent;
  return node.outerHTML;
}

/**
 * Convert one mined example's raw HTML to the Standard `M3e.*` (top) surface,
 * handling multi-root galleries.
 * @returns {{ code: string } | { skip: string }}
 */
function convertExample(html, oracle, facts) {
  const convert = (h) => toElm(h, oracle, facts);
  const roots = topLevelNodes(html);

  // Single root (or empty) -> defer entirely to the converter.
  if (roots.length <= 1) {
    return convert(html);
  }

  // Multiple roots -> convert each sibling independently, assemble as a single
  // Elm LIST expression so the whole example is one compilable expression.
  const pieces = [];
  for (const node of roots) {
    const res = convert(nodeToHtml(node));
    if (res.skip) return { skip: res.skip };
    pieces.push(res.code);
  }
  return { code: toElmList(pieces) };
}

/**
 * Assemble sibling expressions into one Elm list literal:
 *   [ expr1
 *   , expr2
 *   ]
 * Multi-line sibling expressions are re-indented so the list stays valid.
 */
function toElmList(pieces) {
  const indented = pieces.map((p) =>
    p.split("\n").join("\n      "),
  );
  return "[ " + indented.join("\n    , ") + "\n    ]";
}

function main() {
  // The matraic corpus (config/examples.matraic.json) is committed alongside the
  // generated config/examples.rich.json. If it is somehow absent, keep the
  // committed rich/generated files rather than failing the build.
  if (!existsSync(EXAMPLES_PATH)) {
    console.warn(
      `build:examples-config: corpus not found at ${EXAMPLES_PATH}; ` +
        "keeping committed config/examples.rich.json (skipping regeneration).",
    );
    return;
  }
  const corpus = readJson(EXAMPLES_PATH);
  const categories = readJson(CATEGORIES_PATH);
  const oracle = buildOracle();
  // Face C (component-API facts) from the ONE facts bundle — see lib/facts.mjs.
  const facts = loadFacts();

  const generated = {};
  const skippedLines = [];

  let total = 0;
  let filtered = 0;

  // Deterministic order over corpus keys.
  for (const slug of Object.keys(corpus).sort()) {
    const module = pascal(slug);
    // categories.json is `{ category, label }` keyed by the reference slug.
    const refSlug = SLUG_ALIASES[module] || module.toLowerCase();
    let category = categories[refSlug]?.category;
    if (category == null) {
      console.warn(
        `warning: no category for module "${module}" (slug "${slug}"); using "${DEFAULT_CATEGORY}"`,
      );
      category = DEFAULT_CATEGORY;
    }

    const examples = [];
    for (const ex of corpus[slug]) {
      total += 1;
      const { title, code: rawHtml } = ex;

      // Skip registration-only cards (e.g. "Native module support"): all
      // top-level nodes are <script>/<link>. They have no meaningful preview
      // or Elm surface, so they are filtered out entirely (not degraded).
      const tops = topLevelNodes(rawHtml);
      if (
        tops.length > 0 &&
        tops.every(
          (n) => n.nodeType === 1 && /^(script|link)$/i.test(n.tagName),
        )
      ) {
        filtered += 1;
        skippedLines.push(
          `${module} :: ${title} :: filtered: registration-only (script/link)`,
        );
        continue;
      }

      // Convert the strict top surface. A converter skip is NOT a drop: the
      // example still ships its HTML surface; its `top` field simply becomes
      // null. The skip reason is carried for the log.
      const res = convertExample(rawHtml, oracle, facts);
      const section = deriveSection(rawHtml, oracle);
      examples.push({
        title,
        // null when the top converter couldn't map it; a compile failure later
        // may also null a non-null top. Carried internally, split at write time.
        code: res.skip ? null : res.code,
        topSkip: res.skip || null,
        ...(section ? { section } : {}),
        html: rawHtml,
      });
    }

    if (examples.length > 0) {
      generated[module] = { examples, docMeta: { category } };
    }
  }

  // --- COMPILE-VERIFY each API surface INDEPENDENTLY against the real M3e.* /
  // Kit API. A layer that fails `elm make` (or that the converter couldn't map)
  // has its field NULLED — the example is KEPT, never dropped. Every example
  // always retains its HTML surface, so no example can lose all surfaces. This
  // is graceful degradation: an example ships at whatever surfaces compiled and
  // the docs-site toggle simply hides the tabs that didn't.
  //
  // `shadowFor` maps each example to a single code string for one layer,
  // substituting an unbound sentinel when that layer has no code (converter
  // skip) so verifyExamples attributes a compile failure to that exact (module,
  // idx) — which we then turn into a null field rather than a drop.
  const shadowFor = (getCode) => {
    const shadow = {};
    for (const module of Object.keys(generated)) {
      shadow[module] = {
        examples: generated[module].examples.map((ex) => ({
          title: ex.title,
          code: getCode(ex) || "layerSkippedSentinel",
        })),
      };
    }
    return shadow;
  };

  const verifyLayer = (getCode, label) => {
    const { failures, fatal } = verifyExamples(shadowFor(getCode));
    if (fatal) {
      console.error(
        `FATAL: ${label}-layer verification did not build (harness/elm.json issue):\n` +
          fatal,
      );
      process.exit(2);
    }
    return new Map(
      failures.map((f) => [`${f.module}#${f.idx}`, f.firstErrorLine]),
    );
  };

  // Top surface: code lives directly on the example (null ⇒ converter skip).
  // The Record/Build surfaces are produced downstream by gen-record-build.mjs
  // (elm-review-driven).
  const topFail = verifyLayer((ex) => ex.code, "top");

  // Split the built data into two outputs (stable, alphabetized keys):
  //   sortedGenerated -> elm-cem-facing {examples:[{title,code,section}],docMeta}
  //                      (carries ONLY compiling top expressions)
  //   rich            -> docs-facing   {Module:[{title,section,html,top}]}
  //                      (top string | null)
  const sortedGenerated = {};
  const rich = {};
  let fullyCompiled = 0;
  let degraded = 0;
  let droppedNoSurface = 0;
  const nulled = { top: 0 };

  for (const key of Object.keys(generated).sort()) {
    const richExs = [];
    const genExs = [];
    generated[key].examples.forEach((ex, idx) => {
      const k = `${key}#${idx}`;
      const topReason = ex.topSkip || topFail.get(k) || null;

      const top = topReason ? null : ex.code;

      // Defensive: drop only if the example truly has NO surface. `html` is
      // always present, so this branch is unreachable in practice.
      if (!ex.html && top == null) {
        droppedNoSurface += 1;
        skippedLines.push(`${key} :: ${ex.title} :: dropped: no surface`);
        return;
      }

      if (topReason) {
        nulled.top += 1;
        degraded += 1;
        skippedLines.push(
          `${key} :: ${ex.title} :: degraded: top: ${topReason}`,
        );
      } else {
        fullyCompiled += 1;
      }

      richExs.push({
        title: ex.title,
        ...(ex.section ? { section: ex.section } : {}),
        html: ex.html,
        top,
      });

      // The elm-cem-facing generated.json carries ONLY a compiling top
      // expression; an example whose top nulled contributes no `code` binding.
      if (top != null) {
        genExs.push({
          title: ex.title,
          code: top,
          ...(ex.section ? { section: ex.section } : {}),
        });
      }
    });

    if (richExs.length > 0) rich[key] = richExs;
    if (genExs.length > 0) {
      sortedGenerated[key] = {
        examples: genExs,
        docMeta: generated[key].docMeta,
      };
    }
  }

  // Keep the skip log deterministic.
  skippedLines.sort();

  writeFileSync(OUT_GENERATED, JSON.stringify(sortedGenerated, null, 2) + "\n");
  writeFileSync(OUT_RICH, JSON.stringify(rich, null, 2) + "\n");
  writeFileSync(
    OUT_SKIPPED,
    skippedLines.length ? skippedLines.join("\n") + "\n" : "",
  );

  const keptExamples = Object.values(rich).reduce((n, exs) => n + exs.length, 0);
  const componentCount = Object.keys(rich).length;
  const zeroExampleCount = Object.keys(corpus).length - componentCount;

  console.log(
    `kept ${keptExamples} / total ${total} examples across ${componentCount} components: ` +
      `${fullyCompiled} compiled top, ${degraded} degraded (nulled top ${nulled.top}); ` +
      `filtered ${filtered} (registration-only), dropped ${droppedNoSurface} (no surface)`,
  );
  console.log(`components with zero examples: ${zeroExampleCount}`);
}

main();
