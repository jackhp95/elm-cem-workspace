// Build the component reference (`docs/data/reference.json`) from native
// `elm make --docs docs.json` output.
//
// Why: the previous heuristic scanned Elm source with regex (fragile to
// multi-line signatures, comment placement quirks, and silently glossed over
// missing doc comments). `elm make --docs` is the elm compiler's own pipeline:
// it enforces a doc comment on every exposed value and produces type signatures
// it actually type-checked. Single source of truth; same artifact Phase 8
// (package-readiness) needs anyway.
//
// How: the library can't be a real package today (it vendors its `Cem.M3e.*`
// atoms instead of depending on them), so this script sets up a scratch package
// project in a per-worktree temp dir (a path derived from this checkout's
// location, so concurrent builds in separate worktrees never share/corrupt one
// another, while the dir stays stable across runs so its `elm-stuff` — and CI's
// cache of it — is reused) with symlinks to `src/M3e` (the library) and
// `vendor/elm-m3e/Cem` (the atoms, kept in source-dirs but NOT exposed), runs
// `elm make --docs` there, then maps the produced `docs.json` to the existing
// `reference.json` schema consumed by Route.Guide.Reference and Route.Components.Name_.
// `M3e.Internal` is the unexposed escape-hatch and is excluded from the docs.

import fs from "fs";
import os from "os";
import crypto from "crypto";
import path from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";

const here = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(here, "../..");
const SRC_M3E = path.resolve(REPO, "src/M3e");
// The one-import barrel (`module M3e`) is a *sibling* file next to the `src/M3e/`
// directory, so the per-component walk below never sees it. It IS the surface the
// Guide teaches (`M3e.button`, `M3e.variantFilled`, `M3e.slotIcon`, `M3e.attrName`),
// so the reference must document it too — symlinked in and exposed alongside the
// component modules (#187).
const SRC_M3E_BARREL = path.resolve(REPO, "src/M3e.elm");
const OUT = path.resolve(here, "../data/reference.json");
const ELM_BIN = path.resolve(REPO, "docs/node_modules/.bin/elm");

// The editorial nav override (`config/categories.json`): the single source that
// decides which components appear in the drawer and under which category/label.
// Keyed by component SLUG (lowercased module name) — the one identity the
// reference, the examples pipeline, and the nav all agree on (PascalCase names
// diverge: the examples pipeline calls them `Chips`/`Search`/`ProgressIndicator`
// while the reference exposes `Chip`/`SearchBar`/`Progress`). Each value is
// `{ category, label }`; an entry present here IS a nav component, and its
// `category`/`label` flow onto the matching reference record below. Entries
// absent here (base classes, sub-elements) get an empty category and fall back
// to their bare `name` for a label.
const CATEGORIES = JSON.parse(
  fs.readFileSync(path.resolve(REPO, "config/categories.json"), "utf8")
);

// Scratch dir for the elm package project. Stable per worktree (keyed by this
// checkout's path) so (a) concurrent builds in *separate* worktrees never share
// and corrupt one another, and (b) the dir persists across runs so `elm-stuff`
// is reused and CI can cache it. Overridable via M3E_DOCS_GEN_DIR (CI pins it to
// a fixed path so its cache `path:` matches).
const SCRATCH =
  process.env.M3E_DOCS_GEN_DIR ||
  path.join(
    os.tmpdir(),
    "m3e-docs-gen-" + crypto.createHash("sha1").update(REPO).digest("hex").slice(0, 12)
  );

// Modules that exist in src/M3e but are NOT part of the *component* reference:
// the IR primitives + escape-hatch (documented in the architecture guide, not
// the per-component catalogue).
const NOT_EXPOSED = new Set([
  "M3e.Internal",
  "M3e.Node",
  "M3e.Label",
  "M3e.Element",
  // Universal accessibility helper (settable on any component), not a component.
  "M3e.Aria",
  // Token-enum + IR infra, not per-component reference material (the Styles
  // pages cover tokens); their generated form omits per-value doc comments.
  "M3e.Token",
  "M3e.Content",
  "M3e.Attr",
  // The full Material Symbols icon-helper set (4083 nullary `m3e-icon`
  // producers + `custom`) — a helper module, not a per-component demo, and its
  // bare slug ("icon") collides with the real icon component (M3e.Component.Icon
  // → /components/icon). Documented via its own package (elm-m3e-icons), not the
  // component catalogue. Excluding it also keeps the per-slug route unique so the
  // all-components browser spec's slug list has no duplicate titles.
  "M3e.Icon",
]);

// 0. The barrel source, with type annotations backfilled for any exposed value
//    that lacks one. `elm make --docs` requires an annotation on every exposed
//    value; the generator occasionally emits a bare re-export (`foo =
//    M3e.Progress.foo`) without one, which would fail the whole all-or-nothing
//    docs build. For each such value we lift the annotation from the module it
//    re-exports — the barrel already imports the fully-qualified names those
//    signatures use, so they drop in verbatim. If a gap can't be resolved this
//    way it's left untouched and elm reports it (a genuine generator bug). (#187)
function barrelSource() {
  const src = fs.readFileSync(SRC_M3E_BARREL, "utf8");

  // Exposed names (the `module M3e exposing ( … )` block, which closes on its
  // own line as `    )` — the first `)` at start-of-content after the opener).
  const header = src.match(/^module M3e exposing\s*\(([\s\S]*?)\n\s*\)\n/m);
  const exposedNames = new Set(
    (header ? header[1] : "").match(/\b[a-z][A-Za-z0-9_]*/g) || []
  );

  // Values that already carry a `name :` annotation somewhere at column 0.
  const annotated = new Set(
    [...src.matchAll(/^([a-z][A-Za-z0-9_]*)\s*:/gm)].map((m) => m[1])
  );

  // Re-export bodies: `foo =\n    M3e.Some.Module.foo`.
  const reexports = new Map();
  for (const m of src.matchAll(
    /^([a-z][A-Za-z0-9_]*)\s*=\s*\n\s*(M3e\.[A-Za-z0-9_.]+)\.([a-z][A-Za-z0-9_]*)\s*$/gm
  )) {
    reexports.set(m[1], { module: m[2], member: m[3] });
  }

  // Cache of per-module source text (avoid re-reading).
  const moduleText = new Map();
  const readModule = (mod) => {
    if (moduleText.has(mod)) return moduleText.get(mod);
    // `M3e.Progress` -> src/M3e/Progress.elm
    const rel = mod.replace(/^M3e\./, "").replace(/\./g, "/");
    const file = path.join(SRC_M3E, rel + ".elm");
    const text = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : "";
    moduleText.set(mod, text);
    return text;
  };

  // Pull `member :\n   <signature>\nmember <args> =` from a module's source.
  const signatureOf = (mod, member) => {
    const text = readModule(mod);
    const re = new RegExp(
      "^" + member + "\\s*:\\n([\\s\\S]*?)\\n" + member + "\\b",
      "m"
    );
    const m = text.match(re);
    return m ? m[1].replace(/\s+$/, "") : null;
  };

  let out = src;
  const patched = [];
  for (const name of exposedNames) {
    if (annotated.has(name)) continue;
    const rx = reexports.get(name);
    if (!rx) continue;
    const sig = signatureOf(rx.module, rx.member);
    if (!sig) continue;
    // Insert `name :\n<sig>\n` immediately before the `name =` body.
    out = out.replace(
      new RegExp("(^" + name + "\\s*=)", "m"),
      name + " :\n" + sig + "\n$1"
    );
    patched.push(name);
  }
  if (patched.length) {
    console.log(
      `barrel: backfilled ${patched.length} missing annotation(s) for --docs: ` +
        patched.sort().join(", ")
    );
  }
  return out;
}

// 1. Build a fresh scratch package project inside the unique temp dir.
function setupScratch() {
  // Refresh only the src tree (idempotent across runs — the dir persists); keep
  // elm-stuff + elm.json so `elm make` recompiles incrementally.
  fs.rmSync(path.join(SCRATCH, "src"), { recursive: true, force: true });
  fs.mkdirSync(path.join(SCRATCH, "src"), { recursive: true });
  fs.symlinkSync(SRC_M3E, path.join(SCRATCH, "src/M3e"));
  // HtmlIr.* and TypedHtml.* live in UNPUBLISHED sibling
  // repos, so their source is vendored into docs/vendor/elm-foundation (a committed
  // source-directory; see vendor/elm-foundation/VENDORED_FROM.txt and
  // `pnpm run build:vendor`). Symlink those vendored trees into the scratch src so
  // `elm make --docs` finds them — packages have no source-directories field, so
  // they must sit under src/. Using the committed vendor (not the `../../elm-*`
  // siblings) is what makes this build self-contained on CI, where only elm-m3e is
  // cloned. The names mirror what docs/elm.json exposes via that source-directory.
  const DOCS = path.resolve(here, "..");
  const FOUNDATION_SRC = path.resolve(DOCS, "vendor/elm-foundation");
  for (const name of ["HtmlIr", "HtmlIr.elm", "TypedHtml", "TypedHtml.elm"]) {
    const target = path.join(FOUNDATION_SRC, name.replace(".", path.sep));
    const link = path.join(SCRATCH, "src", name.replace(".", path.sep));
    if (fs.existsSync(target)) {
      fs.symlinkSync(target, link);
    }
  }
  // The barrel module (`module M3e`) is a sibling file. It's a *copy* (not a
  // symlink) so we can backfill type annotations `elm make --docs` requires but
  // the generator sometimes omits on a re-exported value (see barrelSource);
  // never mutating the real library source (#187).
  fs.writeFileSync(path.join(SCRATCH, "src/M3e.elm"), barrelSource());

  // Component sub-modules (M3e.Component.*) — these are the per-component
  // reference entries that map to categories.json slugs like "button", "theme".
  const SRC_M3E_COMPONENT = path.join(SRC_M3E, "Component");
  const componentModules = fs.existsSync(SRC_M3E_COMPONENT)
    ? fs
        .readdirSync(SRC_M3E_COMPONENT)
        .filter((f) => f.endsWith(".elm"))
        .map((f) => "M3e.Component." + f.replace(/\.elm$/, ""))
    : [];

  const exposed = [
    // The one-import barrel first — it is the taught surface (#187).
    "M3e",
    ...fs
      .readdirSync(SRC_M3E)
      .filter((f) => f.endsWith(".elm"))
      .map((f) => "M3e." + f.replace(/\.elm$/, ""))
      .filter((m) => !NOT_EXPOSED.has(m)),
    // Per-component modules under M3e.Component.* (Phase B layout).
    ...componentModules,
  ].sort();

  const elmJson = {
    type: "package",
    name: "jackhp95/elm-m3e",
    summary: "Material 3 Expressive — typed Elm builders over @m3e/web.",
    license: "BSD-3-Clause",
    version: "1.0.0",
    "exposed-modules": exposed,
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: {
      "elm/core": "1.0.0 <= v < 2.0.0",
      "elm/html": "1.0.0 <= v < 2.0.0",
      "elm/json": "1.0.0 <= v < 2.0.0",
      "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
    },
    "test-dependencies": {},
  };
  fs.writeFileSync(path.join(SCRATCH, "elm.json"), JSON.stringify(elmJson, null, 2));
}

// 2. Run `elm make --docs docs.json` in the scratch project. Any missing
//    doc-comment / unresolved @docs reference is a hard error here.
function buildDocsJson() {
  try {
    execSync(`${ELM_BIN} make --docs docs.json`, { cwd: SCRATCH, stdio: "pipe" });
  } catch (e) {
    process.stderr.write(e.stdout?.toString() || "");
    process.stderr.write(e.stderr?.toString() || "");
    throw new Error("elm make --docs failed in " + SCRATCH);
  }
  return JSON.parse(fs.readFileSync(path.join(SCRATCH, "docs.json"), "utf8"));
}

// 3. Extract the module overview prose: everything in `comment` before the
//    first `# <section>` header or `@docs` line. Collapse internal blank runs.
function overview(comment) {
  const lines = comment.replace(/\r\n/g, "\n").split("\n");
  const out = [];
  for (const raw of lines) {
    const l = raw.replace(/\s+$/, "");
    if (/^@docs\b/.test(l.trim())) break;
    // Stop at ANY ATX heading (h1–h6). The prose overview precedes every
    // section; `## Examples` / `### Variants` and their code dumps belong to
    // the live "Usage" section, not the intro (the old `/^#\s/` only caught h1,
    // so `## Examples` leaked the whole example code block into the overview).
    if (/^#{1,6}\s/.test(l)) break;
    // Drop elm-cem HTML-comment directives (e.g. `<!-- elm-cem:docmeta … -->`).
    if (/^<!--.*-->\s*$/.test(l.trim())) continue;
    out.push(l);
  }
  return out.join("\n").replace(/\n{3,}/g, "\n\n").trim();
}

// 4. Order members by their first appearance in the module comment's `@docs`
//    sections (docs.json sorts each array alphabetically, but the @docs order
//    is what the rendered page should reflect). Anything not referenced by
//    @docs falls to the end in alphabetical order.
function memberOrder(comment) {
  const names = [];
  for (const line of comment.split("\n")) {
    const m = line.match(/^@docs\s+(.+)$/);
    if (!m) continue;
    for (const tok of m[1].split(",")) {
      const n = tok.trim().split(/\s+/)[0];
      if (n) names.push(n);
    }
  }
  return names;
}

// 4c. The one-line CEM summary: the first prose paragraph of the overview
//     (everything before the first blank line), whitespace-collapsed. This is
//     the clean sentence shown under the page's display heading — the rest of
//     the overview (Component Info / Events / Slots bullet lists) is redundant
//     with the colocated API section below, so the page drops it.
function summary(overviewText) {
  const first = (overviewText || "").split(/\n\s*\n/)[0] || "";
  return first.replace(/\s+/g, " ").trim();
}

// 4d. Classify a member into the elm-module-page groups the API section renders,
//     preserving @docs order within each group. `type` (aliases/unions) colocate
//     with the constructor; `ctor` is `view`; `slot` setters return
//     `M3e.Content.Content`; `event` setters are the `onX` attribute producers;
//     everything else that produces an `Attr` is a plain attribute setter.
function roleOf(m) {
  const sig = m.signature || "";
  if (m.kind === "type") return "type";
  if (m.name === "view") return "ctor";
  if (/\bM3e\.Content\.Content\b/.test(sig)) return "slot";
  if (/^on[A-Z]/.test(m.name) && /\bM3e\.Cem\.Attr\.Attr\b/.test(sig)) return "event";
  if (/\bM3e\.Cem\.Attr\.Attr\b/.test(sig)) return "attr";
  return "other";
}

// 5. Build the per-module reference record. `kind`: type for unions and
//    aliases; value for everything else. Signature on values is the elm type
//    (multi-line collapsed to a single line by docs.json already). Each member
//    also carries a `role` so the API section can render elm-module-page groups
//    (constructor+types, attributes, slots, events) while preserving @docs order.
function moduleEntry(mod) {
  const name = mod.name.replace(/^M3e\./, "");
  // For M3e.Component.Button → slug "button" (strip intermediate namespace so
  // categories.json keys stay simple). Top-level M3e.Action → slug "action" unchanged.
  const slug = name.replace(/^Component\./, "").toLowerCase();
  const byName = new Map();
  for (const u of mod.unions || []) {
    byName.set(u.name, { name: u.name, kind: "type", signature: "", doc: (u.comment || "").trim() });
  }
  for (const a of mod.aliases || []) {
    byName.set(a.name, { name: a.name, kind: "type", signature: "", doc: (a.comment || "").trim() });
  }
  for (const v of mod.values || []) {
    byName.set(v.name, { name: v.name, kind: "value", signature: v.type || "", doc: (v.comment || "").trim() });
  }

  const ordered = memberOrder(mod.comment || "");
  const members = [];
  const seen = new Set();
  for (const n of ordered) {
    if (byName.has(n) && !seen.has(n)) {
      members.push(byName.get(n));
      seen.add(n);
    }
  }
  for (const n of [...byName.keys()].sort()) {
    if (!seen.has(n)) members.push(byName.get(n));
  }
  for (const m of members) m.role = roleOf(m);

  const over = overview(mod.comment || "");
  // Join the editorial override (config/categories.json) by slug: a matched
  // entry makes this a nav component (category + editorial label); an unmatched
  // one gets an empty category (dropped from the nav) and falls back to `name`.
  const override = CATEGORIES[slug];
  return {
    name,
    // Fully-qualified, importable module path exactly as elm.json exposes it
    // (`M3e.Button`), so the reference page labels modules under the real
    // namespace the package ships — never a phantom prefix. `name` stays the
    // bare form for friendly page headings; `module` is the copy-pasteable one.
    module: mod.name,
    slug,
    category: override ? override.category : "",
    // The editorial nav label (e.g. "App Bar", "FAB"). Non-nav modules keep the
    // bare `name` so every record carries a non-empty label.
    label: override ? override.label : name,
    summary: summary(over),
    overview: over,
    members,
  };
}

// ----- run -----
// The scratch dir is intentionally NOT removed on exit: it is stable per
// worktree, so keeping it lets `elm make` reuse its `elm-stuff` (and lets CI
// cache it) instead of recompiling the standard library every run. Bounded to
// one dir per checkout, not one per run.

// `elm make --docs` is strict and all-or-nothing: one exposed module with an
// incomplete generated `@docs` block fails the whole build. When that happens we
// keep the last-good `data/reference.json` (committed) rather than crash the dev
// server — regenerating cleanly is a generator-side @docs-completeness fix. If no
// prior reference exists, the failure is genuinely fatal.
setupScratch();
let modules;
try {
  modules = buildDocsJson();
} catch (e) {
  process.stderr.write((e.message || String(e)) + "\n");
  if (fs.existsSync(OUT)) {
    console.warn(
      `⚠ reference regeneration failed — keeping existing ${path.relative(REPO, OUT)}. ` +
        `Fix the generator's @docs output to refresh it.`
    );
    process.exit(0);
  }
  throw e;
}

const components = modules
  // Keep the bare `M3e` barrel plus every `M3e.*` component module.
  .filter((m) => m.name === "M3e" || /^M3e\./.test(m.name))
  .map(moduleEntry)
  .sort((a, b) => a.name.localeCompare(b.name));

// Build guard: the package exposes ZERO `Ui.*` modules — every module is
// `M3e.*` (see elm.json). A stray `Ui.` in any generated prose (overviews,
// summaries, member docs/signatures, or a module label) means a reader would
// copy an `import Ui.X` that is an instant compile error. Fail the build hard
// rather than ship it. (Scoped to the generated JSON we emit; `#193`.)
const uiHits = [];
for (const c of components) {
  const fields = {
    module: c.module,
    name: c.name,
    summary: c.summary,
    overview: c.overview,
  };
  for (const [field, val] of Object.entries(fields)) {
    if (/\bUi\.[A-Z]/.test(val || "")) uiHits.push(`${c.module} .${field}`);
  }
  for (const m of c.members) {
    if (/\bUi\.[A-Z]/.test(m.doc || "")) uiHits.push(`${c.module}.${m.name} .doc`);
    if (/\bUi\.[A-Z]/.test(m.signature || "")) uiHits.push(`${c.module}.${m.name} .signature`);
  }
}
if (uiHits.length) {
  process.stderr.write(
    `\n✗ reference guard: phantom \`Ui.*\` namespace found in generated prose ` +
      `(the package ships only M3e.* modules — see elm.json). Offending entries:\n` +
      uiHits.map((h) => "    - " + h).join("\n") +
      "\n"
  );
  throw new Error("reference generation produced phantom `Ui.` module references (#193)");
}

fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, JSON.stringify(components));
const totalMembers = components.reduce((n, c) => n + c.members.length, 0);
console.log(
  `reference (via elm make --docs): ${components.length} components, ${totalMembers} members -> data/reference.json`
);
