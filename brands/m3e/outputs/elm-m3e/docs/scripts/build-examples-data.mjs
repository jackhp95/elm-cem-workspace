// Build the docs-site Usage data (`docs/data/examples.json`) from the rich
// converter output (`config/examples.rich.json`) + category taxonomy
// (`config/categories.json`).
//
// Output schema (consumed by Route.Components.Name_):
//   { "<slug>": { category, examples: [ { title, section?, html,
//                 top, record, build } ] } }
// keyed by component SLUG (lowercased module name, matching reference.json
// slugs and the /components/:slug route). `html` is always present; every Elm
// surface (top/record/build) is nullable — a null means that surface didn't
// compile (or didn't translate) for this example, and the UI hides its tab.
// `formatElm`/`surfaceOrNull` pass null straight through.
//
// The rich file is keyed by PascalCase module (e.g. "Button", "IconButton").
// A module's slug is its lowercased name. A handful of corpus family-names
// (matraic groupings like "Chips"/"Search") have no single Elm-module slug;
// those are WARNED about (not silently dropped) — they render no Usage section
// until an explicit alias is added. No silent caps.

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { execFileSync } from "child_process";
import { referencedModules } from "./examples-gen/lib/scratch-harness.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(here, "../..");

const RICH = path.resolve(REPO, "config/examples.rich.json");
const SURFACES = path.resolve(REPO, "config/examples.surfaces.json");
const BARREL = path.resolve(REPO, "config/examples.barrel.json");
const CATEGORIES = path.resolve(REPO, "config/categories.json");
const REFERENCE = path.resolve(here, "../data/reference.json");
const OUT = path.resolve(here, "../data/examples.json");
const EXAMPLES_DIR = path.resolve(here, "../app/Route/Examples");
const EXAMPLE_USAGE_OUT = path.resolve(here, "../data/example-usage.json");

const DEFAULT_CATEGORY = "Layout & style";

// A few corpus family-names (matraic groupings) don't equal any single Elm
// module's slug. Map them to the representative reference slug their examples
// actually use (verified by the <m3e-*> tags in the example HTML).
const SLUG_ALIASES = {
  Chips: "chip", // <m3e-chip>
  Search: "searchbar", // <m3e-search-bar>
  ProgressIndicator: "progress", // linear/circular fold into M3e.Progress
};

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

const ELM_FORMAT = path.resolve(here, "../node_modules/.bin/elm-format");

// The converter emits each example as ONE long unwrapped expression (a bare
// expr, or `[ e1\n    , e2\n    ]`), which reads as broken indentation and
// overflows. Run it through elm-format by wrapping it in a trivial declaration,
// formatting the module, then extracting + de-indenting the body. Falls back to
// the original string if elm-format is unavailable or the wrapped form doesn't
// parse (so a single odd example never breaks the build).
function tryFormat(code) {
  const wrapped =
    "module F exposing (s)\n\n\ns =\n" +
    code
      .split("\n")
      .map((l) => "    " + l)
      .join("\n") +
    "\n";
  try {
    const out = execFileSync(ELM_FORMAT, ["--stdin"], {
      input: wrapped,
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    });
    const marker = "\ns =\n";
    const i = out.indexOf(marker);
    if (i < 0) return null;
    return out
      .slice(i + marker.length)
      .replace(/\s+$/, "")
      .split("\n")
      .map((l) => (l.startsWith("    ") ? l.slice(4) : l))
      .join("\n");
  } catch {
    return null;
  }
}

function formatElm(code) {
  if (!code || typeof code !== "string") return code;
  // elm-format never wraps by width, so a long single-line expression stays
  // long. Force a multi-line layout by inserting a newline before every `, `
  // and ` |> `; elm-format then re-indents it canonically. If the pre-broken
  // form doesn't parse (e.g. a `, ` inside a string literal), fall back to
  // formatting the original as-is, then to the raw string.
  const broken = code.replace(/, /g, "\n, ").replace(/ \|> /g, "\n|> ");
  return tryFormat(broken) ?? tryFormat(code) ?? code;
}

// The ④ Record (`M3e.<Comp>.el { … }`) / ⑤ Build (`M3e.<Comp>.build |> … |>
// M3e.<Comp>.toElement`) surfaces (config/examples.surfaces.json) are produced by
// the surface translator harness (gen-record-build.mjs), index-aligned with the
// rich file. The harness writes a surface field ONLY when it genuinely translated
// the example to that surface AND the result compiles; a non-translating example
// leaves the field absent. So a present surface is always a real translation —
// pass it through; an absent one becomes `null` and the UI hides the tab (shown as
// an identical-by-design rationale tab) rather than a hollow duplicate of the M3e tab.
function surfaceOrNull(code) {
  return code && typeof code === "string" ? formatElm(code) : null;
}

// Derive `data/example-usage.json` — a map `componentSlug -> [{ title, route }]`
// of the five Examples routes (Dashboard/Mail/Shop/Travel/Settings) that
// instantiate each component. The example apps reference components three ways:
// aliased/qualified component-module imports (`import M3e.Fab as Fab`),
// fully-qualified refs (caught by `referencedModules`), and barrel functions
// (`M3e.appBar`, `M3e.cardSlotContent`). A barrel token `M3e.<tok>` is attributed
// to the component whose camelCase name is the LONGEST prefix of `<tok>` with the
// remainder empty or starting uppercase — so `buttonGroupSlot…` maps to
// ButtonGroup, not Button. Reuses `referencedModules` from the examples-gen lib.
function buildExampleUsage(reference) {
  const lowerFirst = (s) => s.charAt(0).toLowerCase() + s.slice(1);
  const moduleToSlug = new Map();
  const camelBases = []; // { base, slug }, longest-first
  for (const c of reference) {
    const bare = c.module.replace(/^M3e\./, "");
    // Components live under the `M3e.*` module namespace (e.g. `M3e.Button`).
    moduleToSlug.set(`M3e.${bare}`, c.slug);
    camelBases.push({ base: lowerFirst(c.name), slug: c.slug });
  }
  camelBases.sort((a, b) => b.base.length - a.base.length);

  const slugForBarrelToken = (tok) => {
    for (const { base, slug } of camelBases) {
      if (tok === base) return slug;
      if (tok.startsWith(base)) {
        const rem = tok[base.length];
        if (rem >= "A" && rem <= "Z") return slug;
      }
    }
    return null;
  };
  const files = fs
    .readdirSync(EXAMPLES_DIR)
    .filter((f) => f.endsWith(".elm"))
    .sort();
  const usage = {}; // slug -> [{ title, route }]
  for (const file of files) {
    const name = file.replace(/\.elm$/, ""); // "Dashboard"
    const route = `/examples/${name.toLowerCase()}`;
    const src = fs.readFileSync(path.join(EXAMPLES_DIR, file), "utf8");
    const slugs = new Set();

    // 1. explicit component-module imports (aliased or qualified)
    for (const m of src.matchAll(/^import\s+(M3e(?:\.[A-Za-z0-9]+)*)/gm)) {
      if (moduleToSlug.has(m[1])) slugs.add(moduleToSlug.get(m[1]));
    }
    // 2. fully-qualified references (e.g. `M3e.Button.view`)
    for (const mod of referencedModules(src)) {
      if (moduleToSlug.has(mod)) slugs.add(moduleToSlug.get(mod));
    }
    // 3. barrel functions (`M3e.appBar`, `M3e.cardSlotContent`, …)
    for (const m of src.matchAll(/\bM3e\.([a-z][A-Za-z0-9]*)/g)) {
      const slug = slugForBarrelToken(m[1]);
      if (slug) slugs.add(slug);
    }

    for (const slug of slugs) (usage[slug] ??= []).push({ title: name, route });
  }

  // Stable output: sort slug keys and each list by route.
  const sorted = {};
  for (const slug of Object.keys(usage).sort()) {
    sorted[slug] = usage[slug].sort((a, b) => a.route.localeCompare(b.route));
  }
  fs.writeFileSync(EXAMPLE_USAGE_OUT, JSON.stringify(sorted, null, 2) + "\n");
  console.log(
    `wrote ${EXAMPLE_USAGE_OUT} — ${Object.keys(sorted).length} components ` +
      `cross-linked to example apps`,
  );
}

function main() {
  const rich = readJson(RICH);
  const surfaces = fs.existsSync(SURFACES) ? readJson(SURFACES) : {};
  // Barrel-first `top` overrides (config/examples.barrel.json), index-aligned with
  // rich[module]; a null entry (or a missing file) keeps the Standard `top`.
  const barrel = fs.existsSync(BARREL) ? readJson(BARREL) : {};
  const categories = readJson(CATEGORIES);

  // Known route slugs (for a non-silent mismatch warning). reference.json may
  // not exist on a clean checkout; if so, skip validation rather than fail.
  let knownSlugs = null;
  let referenceArr = null;
  if (fs.existsSync(REFERENCE)) {
    const ref = readJson(REFERENCE);
    referenceArr = Array.isArray(ref) ? ref : Object.values(ref);
    knownSlugs = new Set(referenceArr.map((x) => x.slug));
  }

  const out = {};
  const unmatched = [];

  for (const module of Object.keys(rich).sort()) {
    const slug = SLUG_ALIASES[module] || module.toLowerCase();
    // categories.json is now `{ category, label }` keyed by SLUG (the shared
    // identity), not the PascalCase module name — look it up by `slug`.
    const category = categories[slug]?.category || DEFAULT_CATEGORY;

    if (knownSlugs && !knownSlugs.has(slug)) {
      unmatched.push(module);
      // Still emit it — harmless dead data — so nothing is silently lost.
    }

    const moduleSurfaces = surfaces[module] ?? [];
    const moduleBarrel = barrel[module] ?? [];
    out[slug] = {
      category,
      examples: rich[module].map((ex, idx) => {
        const surf = moduleSurfaces[idx] ?? {};
        return {
          title: ex.title,
          ...(ex.section ? { section: ex.section } : {}),
          html: ex.html,
          top: formatElm(moduleBarrel[idx] ?? ex.top),
          record: surfaceOrNull(surf.record),
          build: surfaceOrNull(surf.build),
        };
      }),
    };
  }

  fs.writeFileSync(OUT, JSON.stringify(out, null, 2) + "\n");

  const total = Object.values(out).reduce((n, c) => n + c.examples.length, 0);
  console.log(
    `wrote ${OUT} — ${Object.keys(out).length} components, ${total} examples`,
  );
  if (unmatched.length) {
    console.warn(
      `warning: ${unmatched.length} module(s) have no matching route slug ` +
        `(no Usage section until aliased): ${unmatched.join(", ")}`,
    );
  }

  // Cross-link component pages to the example apps that instantiate them.
  if (referenceArr) {
    buildExampleUsage(referenceArr);
  } else {
    console.warn(
      "warning: reference.json absent — skipping example-usage.json cross-links",
    );
  }
}

main();
