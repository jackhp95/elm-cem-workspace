#!/usr/bin/env node
// fetch-mdn-native-summaries.mjs
// =============================================================================
// MANUAL, periodic refresh of the `M3e.Native` doc-comment summaries.
//
// The typed native/HTML facade (`M3e.Native`, emitted by elm-cem from
// `config/slots.json` `_native`) needs a one-line doc summary above every
// element constructor and attribute setter (Elm's `elm make --docs` requires a
// doc comment on each exposed member). Rather than hand-curate that prose, we
// source it VERBATIM from MDN Web Docs' own open-source content repo
// (github.com/mdn/content) and write it into `config/native-mdn.json`, which
// elm-cem deep-merges under `_native.summaries` at regeneration time.
//
// This is a MANUAL tool — run it to refresh the summaries when MDN's content
// drifts, then regenerate + commit. It is NOT wired into CI or any Action, and
// the build never depends on the network: the summaries are baked into the
// committed config, and elm-cem falls back to a generic sentence for any
// element/attr with no config entry (so `--docs` stays green regardless).
//
//   Usage:   node scripts/fetch-mdn-native-summaries.mjs
//
//   Then regenerate the library (note the extra --config-from):
//     node ${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js} \
//       --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json \
//       --config-from=config/slots.json \
//       --config-from=config/native-mdn.json \
//       --config-from=config/examples.generated.json \
//       --output=src
//
// Requires Node 18+ (global `fetch`). Verified on Node 22.
//
// ATTRIBUTION: element and attribute summaries are adapted from MDN Web Docs
// (https://developer.mozilla.org), licensed CC BY-SA 2.5. See config/ATTRIBUTION.md.
// =============================================================================

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, "..");
const SLOTS = path.join(ROOT, "config", "slots.json");
const OUT = path.join(ROOT, "config", "native-mdn.json");

// The mdn/content reference tree. Element pages live under `elements/<tag>`;
// many attributes have a dedicated `attributes/<name>` page; element-specific
// attributes are documented in the owning element page's definition list.
const RAW = "https://raw.githubusercontent.com/mdn/content/main/files/en-us/web/html/reference";

// Attribute → owning element used to locate its definition when the attribute
// has no dedicated `attributes/<name>` page. Mirrors the generator's
// `nativeAttrTable` (elm-cem/codegen/Generate.elm); the key is the HTML attr
// name (Elm's `type_` is HTML `type`). Keep in sync if that table changes.
const ATTR_OWNER = {
  href: "a", target: "a", rel: "a", download: "a",
  for: "label",
  type: "input", value: "input", checked: "input", placeholder: "input",
  name: "input", disabled: "input", readonly: "input", required: "input",
  min: "input", max: "input", step: "input",
  multiple: "select", selected: "option",
  src: "img", alt: "img", width: "img", height: "img",
  rows: "textarea", cols: "textarea",
};

// ---- KumaScript macro handling ---------------------------------------------
// Replace the common text-bearing MDN macros with their plain-text meaning,
// then drop any remaining `{{…}}` macro entirely.
function replaceMacros(s) {
  return s
    .replace(/\{\{\s*([A-Za-z_]+)\s*\(([^)]*)\)\s*\}\}/g, (_, name, argStr) => {
      const args = [...argStr.matchAll(/"([^"]*)"|'([^']*)'/g)].map((m) => m[1] ?? m[2]);
      const n = name.toLowerCase();
      if (n === "htmlelement") return args[1] || (args[0] ? `<${args[0]}>` : "");
      // glossary/domxref/cssxref/httpheader/etc: prefer an explicit label, else the ref.
      return args[args.length - 1] || args[0] || "";
    })
    .replace(/\{\{[^}]*\}\}/g, ""); // any leftover no-arg / unknown macros
}

// Collapse a raw MDN markdown fragment to one clean line: macros → text,
// `[text](url)` → `text`, `**`/`*`/`_` emphasis removed, whitespace collapsed.
function clean(s) {
  return replaceMacros(s)
    .replace(/\[([^\]]+)\]\([^)]*\)/g, "$1") // markdown links → link text
    .replace(/\*\*([^*]+)\*\*/g, "$1") // bold
    .replace(/\*([^*]+)\*/g, "$1") // italic *
    .replace(/(^|[^\w`])_([^_]+)_(?=[^\w`]|$)/g, "$1$2") // italic _
    .replace(/\s+/g, " ")
    .replace(/\s+([.,;:])/g, "$1") // tidy spacing left by stripped macros
    .trim()
    .replace(/[:\s]+$/, "."); // a lead that runs into a sub-list ends on ":" → "."
}

function stripFrontmatter(t) {
  if (t.startsWith("---")) {
    const end = t.indexOf("\n---", 3);
    if (end !== -1) return t.slice(end + 4);
  }
  return t;
}

// The lead summary: the first real paragraph after the frontmatter, skipping
// blank lines, headings, and macro-only lines (e.g. `{{HTMLSidebar}}`).
function leadParagraph(t) {
  const para = [];
  for (const raw of stripFrontmatter(t).split("\n")) {
    const line = raw.trim();
    const macroless = line.replace(/\{\{[^}]*\}\}/g, "").trim();
    if (para.length === 0) {
      if (macroless === "") continue;
      if (line.startsWith("#") || line.startsWith(">") || line.startsWith("```") || line.startsWith("|")) continue;
      para.push(line);
    } else {
      if (line === "" || line.startsWith("```") || line.startsWith("{{") || line.startsWith("#")) break;
      para.push(line);
    }
  }
  const out = clean(para.join(" "));
  return out.length > 3 ? out : null;
}

// Parse an attribute's definition out of an element page's definition list.
// MDN writes the term as `- ` + `` `name` `` OR `- ` + `[` `name` `](url)`,
// optionally trailed by macros, then `  - : <description>` on the next line.
function attrDefinition(pageText, name) {
  const esc = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const re = new RegExp(
    "(?:^|\\n)- (?:\\[`" + esc + "`\\]\\([^)]*\\)|`" + esc + "`)(?:\\s*\\{\\{[^}]*\\}\\})*\\s*\\n\\s+- : (.+)",
    "m",
  );
  const m = pageText.match(re);
  return m ? clean(m[1]) : null;
}

async function getPage(relPath, cache) {
  if (cache.has(relPath)) return cache.get(relPath);
  let text = null;
  try {
    const res = await fetch(`${RAW}/${relPath}`);
    if (res.ok) text = await res.text();
  } catch (e) {
    console.warn(`  ! network error for ${relPath}: ${e.message}`);
  }
  cache.set(relPath, text);
  return text;
}

async function main() {
  const slots = JSON.parse(fs.readFileSync(SLOTS, "utf8"));
  const emit = slots?._native?.emit;
  if (!Array.isArray(emit) || emit.length === 0) {
    console.error("No `_native.emit` list found in config/slots.json — nothing to source.");
    process.exit(1);
  }

  const cache = new Map();
  const elements = {};
  const attributes = {};
  const elFallback = [];
  const attrFallback = [];

  // --- Elements: lead paragraph of the element's reference page -------------
  console.log(`Sourcing ${emit.length} element summaries from mdn/content…`);
  for (const tag of emit) {
    const page = await getPage(`elements/${tag}/index.md`, cache);
    const lead = page ? leadParagraph(page) : null;
    if (lead) elements[tag] = lead;
    else elFallback.push(tag);
  }

  // --- Attributes: dedicated page first, else owning-element definition -----
  const attrNames = Object.keys(ATTR_OWNER);
  console.log(`Sourcing ${attrNames.length} attribute summaries from mdn/content…`);
  for (const name of attrNames) {
    // 1) dedicated attribute reference page (shared attrs: rel, disabled, min, …)
    const dedicated = await getPage(`attributes/${name}/index.md`, cache);
    let summary = dedicated ? leadParagraph(dedicated) : null;
    // 2) else the owning element page's attribute definition list
    if (!summary) {
      const owner = ATTR_OWNER[name];
      const ownerPage = await getPage(`elements/${owner}/index.md`, cache);
      summary = ownerPage ? attrDefinition(ownerPage, name) : null;
    }
    if (summary) attributes[name] = summary;
    else attrFallback.push(name);
  }

  // Deterministic key order for a stable, re-runnable (idempotent) diff.
  const sortObj = (o) => Object.fromEntries(Object.keys(o).sort().map((k) => [k, o[k]]));
  const config = {
    "//": "GENERATED by scripts/fetch-mdn-native-summaries.mjs — do not edit by hand. Summaries adapted from MDN Web Docs (https://developer.mozilla.org), CC BY-SA 2.5. See config/ATTRIBUTION.md. Merged under `_native.summaries` at regen time.",
    _native: { summaries: { elements: sortObj(elements), attributes: sortObj(attributes) } },
  };
  fs.writeFileSync(OUT, JSON.stringify(config, null, 2) + "\n");

  // --- Report ---------------------------------------------------------------
  const elOk = emit.length - elFallback.length;
  const attrOk = attrNames.length - attrFallback.length;
  console.log(`\nWrote ${path.relative(ROOT, OUT)}`);
  console.log(`Elements:   ${elOk}/${emit.length} sourced from MDN` + (elFallback.length ? `, fell back: ${elFallback.join(", ")}` : ", 0 fell back"));
  console.log(`Attributes: ${attrOk}/${attrNames.length} sourced from MDN` + (attrFallback.length ? `, fell back: ${attrFallback.join(", ")}` : ", 0 fell back"));
  if (attrFallback.length || elFallback.length) {
    console.log("\nFell-back members use elm-cem's generic doc sentence (build stays green).");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
