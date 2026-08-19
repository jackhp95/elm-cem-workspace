// Emitter plugin interface (task B2; plans/01-architecture.md §4 "emit/
// emitter-api.mjs — emitter plugin interface (consumer-provided labels, e.g.
// Elm)" + §5 "Label strategy"). This module is the CONTRACT every emitter
// (built-in `html-label`, B3's profile-local `elm.mjs`, a consumer's own
// label) implements, plus the small set of PURE helper functions every
// emitter needs so none of them re-derive the same string mechanics.
//
// -- THE INTERFACE ------------------------------------------------------------
//
//   {
//     name: string,                    // stable id, e.g. "html-label"
//     label: string,                   // Figma Code Connect label, e.g.
//                                      // "Web Components" — this is what
//                                      // gets slugify()'d into the output
//                                      // directory name (run.mjs).
//     emit(entry, ctx) -> [{ path, contents }],
//   }
//
// `entry` is one element of a profile's correspondence.json array (the
// schema in src/correspond/schema.json) — a single CEM-tag-keyed
// correspondence entry, EXACTLY as stored (run.mjs is the only thing that
// filters by status/suppression before handing an entry to emit()).
//
// `ctx` (built by buildEmitContext, below — run.mjs constructs one per
// entry and passes the SAME shape to every registered emitter) is:
//
//   {
//     profile,   // the profile config object returned by
//                // src/correspond/merge.mjs's loadProfile(profileDir) —
//                // fileKey, kitVersionTag, htmlLabel, emitters, cem meta,
//                // raw (untouched profile.json), etc. "Profile config."
//     figma,     // the FULL return value of src/ingest/figma.mjs's
//                // loadFigmaExport(profile.figmaExportPath) — { data, sets,
//                // standalones, variants, variantsByPage }. "Export views."
//     cem,       // the ONE CEM component matching entry.cemTag (an element
//                // of loadCem()'s `components[]`), or null if the tag has
//                // no CEM declaration (shouldn't happen for a real entry,
//                // but iconTable/synthetic entries may not resolve).
//                // "Resolved CEM data for the entry's tag" — deliberately
//                // narrowed to the one component, not the whole manifest;
//                // an emitter that legitimately needs sibling components
//                // can still reach them via `profile` + a fresh loadCem()
//                // call, but the common case (this component's attributes/
//                // slots/events) is handed over pre-resolved.
//     helpers: { buildNodeUrl, slugify, figmaFileSlug, assertMainFileUrl,
//                conditionalLine },
//   }
//
// -- PURITY (contract emitter authors MUST honor — not structurally enforced) -
//
// An emitter's `emit()` MUST be a pure function of (entry, ctx): no fs, no
// network, no process.env, no Date.now()/Math.random(), no mutation of
// ctx/entry. `run.mjs` (task B2) owns ALL file writing — every path an
// emitter returns is relative to its own `generated/<profile>/<label-slug>/`
// directory (never an absolute path, never `..`). Purity is what makes
// "re-run is byte-stable" a checkable property at all: a pure function of
// unchanged inputs returns unchanged outputs, so the only way output drifts
// is a real input change (a correspondence edit, a profile edit) — never an
// emitter side effect. See test/emitter-api.test.mjs's byte-stable-re-run
// test, and src/publish/check.mjs (B4), which diffs regenerated-in-memory
// output against what's committed and calls any difference DRIFT.
//
// -- WHAT AN EMITTER MUST NEVER DO SILENTLY --------------------------------
//
// Per plans/01-architecture.md §3 item 4 (Figma-only axes are "never
// silently dropped... they appear in the gap report") and the same policy
// mirrored here for generated code: an `unmapped` axis/prop on `entry` must
// surface as a VISIBLE comment/marker line in at least one generated file
// for that entry, never be silently absent. `src/emit/html-label.mjs`
// (task B1) is the reference implementation of this (`unmappedNote`).
//
// A `status:"confirmed"` entry that legitimately produces NO files (e.g. a
// code-only entry, `figmaSets: []`) should return `[]` from `emit()` rather
// than throw — run.mjs's manifest omits an entry with zero files rather
// than recording an empty array, so this is a normal, quiet no-op, not an
// error condition.
//
// -- REGISTRATION (how profile.json's `emitters` array resolves) ----------
//
// `run.mjs` (not this module — to avoid a circular import between the
// built-in registry and html-label.mjs, which imports its helpers FROM this
// module) resolves each string in `profile.json`'s `emitters` array:
//   - the literal "html-label" -> the built-in emitter
//     (`src/emit/html-label.mjs`'s exported `emitter` object)
//   - anything else -> a REPO-ROOT-RELATIVE path to a profile-local ES
//     module (e.g. "profiles/m3-kit/emitters/elm.mjs", B3), dynamically
//     `import()`ed, expected to export `emitter` (preferred) or a `default`
//     export matching this same `{name, label, emit}` shape.
//
// Zero deps beyond plain JS — these helpers touch no node builtins at all.

// slugify(s) -> ordinal-safe kebab-case. Used for BOTH the emitter label's
// output-directory slug (run.mjs: "Web Components" -> "web-components") and
// any emitter's own id-slugging needs (e.g. html-label.mjs's per-set file
// id). Deliberately NOT localeCompare-adjacent — this is a pure character
// class replace, locale-invariant by construction (project-wide determinism
// gate; see src/lib/order.mjs's header comment for the same rule applied to
// sorting).
export function slugify(s) {
  return String(s)
    .trim()
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
}

// figmaFileSlug(fileName) -> Figma's own file-name -> URL-slug algorithm:
// every non [A-Za-z0-9] character becomes ITS OWN literal "-" (NOT
// collapsed) — "Kit (Community)" -> two consecutive dashes ("space" then
// "("). Verified against the golden fixture's URL (task B1): "Material 3
// Design Kit (Community)" -> "Material-3-Design-Kit--Community-". This is
// deliberately a DIFFERENT algorithm from slugify() above (which collapses
// runs and lowercases) — reproducing Figma's URL exactly requires NOT
// collapsing/lowercasing.
export function figmaFileSlug(fileName) {
  return fileName.replace(/[^A-Za-z0-9]/g, "-");
}

// assertMainFileUrl(url) — throws if `url` is a Figma BRANCH url (contains
// a "/branch/" path segment). Code Connect node URLs must be main-file form
// only (VOLT-2003 lineage footgun, re-verified task B1). A no-op on
// non-string/undefined input so callers can pass an optional override
// through freely.
export function assertMainFileUrl(url) {
  if (typeof url === "string" && url.includes("/branch/")) {
    throw new Error(
      `assertMainFileUrl: node URL must be main-file form, not a /branch/ URL (got "${url}")`
    );
  }
}

// buildNodeUrl(config, nodeId) -> the "// url=" line's URL.
//
// `config.url`, if given, is an explicit full-URL-prefix override (tests
// exercising the /branch/ guard; consumer profiles pointing at a
// non-canonical file). Otherwise built from `config.fileKey` +
// `config.fileName` (the profile's canonical file) — B4's publish runner
// rewrites this per-target fileKey at publish time via the staging-copy
// mechanism; emitters always emit the profile's canonical URL.
export function buildNodeUrl(config, nodeId) {
  assertMainFileUrl(config.url);
  const base =
    config.url ?? `https://www.figma.com/design/${config.fileKey}/${figmaFileSlug(config.fileName)}`;
  assertMainFileUrl(base);
  const dashedNodeId = nodeId.replace(/:/g, "-");
  const url = `${base}?node-id=${dashedNodeId}`;
  assertMainFileUrl(url);
  return url;
}

// conditionalLine({ lineVar, condVar, trueBody }) -> source line.
//
// The VOLT-2003 conditional-line idiom (`code-connect/generate.mjs`'s
// `disabledLine` pattern, reproduced live-proven in task B1's
// `buildSlotBooleanBlock`): a boolean-gated fragment renders `trueBody`
// (already-composed template-literal source, e.g. an interpolated
// `\n  <m3e-icon slot="icon" name="${x}"></m3e-icon>`) only when `condVar`
// is true; otherwise the interpolation contributes an empty string, never
// an empty/broken tag. Generalized here (out of html-label.mjs) so any
// emitter needing this idiom (B3's Elm emitter included) shares ONE
// definition instead of re-deriving the template-string mechanics.
export function conditionalLine({ lineVar, condVar, trueBody }) {
  return `const ${lineVar} = ${condVar} ? figma.code\`${trueBody}\` : figma.code\`\``;
}

// resolveCemComponent(cem, cemTag) -> the one CEM component matching
// cemTag, or null. `cem` is loadCem()'s return value (its `components[]`
// array). Pure lookup, no fs.
export function resolveCemComponent(cem, cemTag) {
  return cem.components.find((c) => c.tag === cemTag) ?? null;
}

// buildEmitContext({ profile, figma, cem, entry }) -> ctx (see interface
// doc above). `profile`/`figma`/`cem` are the already-loaded, whole-profile
// values (loaded ONCE per emit run, not per entry) — this function's only
// per-entry work is narrowing `cem` down to the one component `entry`
// names. Pure; performs no I/O itself (the caller, run.mjs, already did the
// loading).
export function buildEmitContext({ profile, figma, cem, entry, iconTable = [], examples = {}, setAttrs = {} }) {
  return {
    profile,
    figma,
    cem: resolveCemComponent(cem, entry.cemTag),
    iconTable,
    examples,
    setAttrs,
    helpers: { buildNodeUrl, slugify, figmaFileSlug, assertMainFileUrl, conditionalLine },
  };
}
