// elm.mjs — the profile-local "Elm" Code Connect emitter (task B3, decision
// D5). Conforms to task B2's emitter interface
// (`{ name, label:"Elm", emit(entry, ctx) -> [{path, contents}] }`) and is
// registered in profiles/m3-kit/profile.json's `emitters` array, loaded via
// src/emit/run.mjs's contained dynamic import.
//
// It turns ONE confirmed correspondence entry (src/correspond/schema.json)
// into one `.figma.ts` Code Connect template PER FUSED FIGMA SET — same
// template mechanics as B1's html-label emitter — but `figma.code` emits an
// ELM pipeline instead of a web-component tag.
//
// ⚑ CARDINAL RULE (task B3 brief): NEVER hardcode an Elm module / setter /
// token name. EVERY such name comes from elm-cem's own canonical facts
// bundle Face C (`elm-api-facts.json`, docs/facts-bundle/schema.json) —
// the generated-Elm API projection elm-cem itself emits, not a
// re-measurement of its output (M3.a; supersedes the deleted per-component
// re-parser this file used to load its facts from).
//
// ONE DELIBERATE EXCEPTION (fix round, post-fe41862): text CONTENT. Post-
// review elm-m3e has no library-exported text helper — text/link/label are
// config-declared, generator-typed, userland-filled SEAMS (elm-m3e
// docs/DESIGN.md §4). The prior fix correctly found no verified library
// export and fail-loud-threw; the CORRECT idiom is not a library name at
// all, but the documented seam convention `${textSeam}.text "..."` (default
// seam "Kit", matching every button/text example in elm-m3e's own
// config/examples.generated.json + docs/DESIGN.md §4). This is recorded in
// profile config (profile.json's `elm.textSeam`, default "Kit") — NOT a
// bundle fact (M3.a: userland seams aren't CEM-derived, so a producer has
// no way to measure one) — so it is never mistaken for a verified library
// export. Every other name (tokens, setters, Action.none, module/entry
// names) STAYS verified-or-throw — only the text/html/attr seams are
// profile config.
//
// TOKEN-RESOLUTION CHAIN (per getEnum value / fixed attr value):
//   Figma variant value  (getEnum key, e.g. "XSmall")
//     -> CEM enum value   (correspondence axis.valueMap, e.g. "extra-small")
//     -> Elm enum value   (elm-facts enums, matched by canonical key)
//     -> M3e.Token.<ctor> (verified exposed in M3e.Token by the build step)
// A value that cannot be resolved from facts is NEVER guessed — emit() throws,
// naming the axis/value, rather than fabricate a token name.
//
// SURFACE (decision D5): configurable via the profile key `elmSurface`, one of
// Face C's `surfaceKeys` ("top" | "raw" | "html" | "record" | "build");
// default "top" (the top-layer `M3e.*` module — the golden form). Each
// surface is a template over the SAME facts + the SAME getEnum/getString
// blocks; only the `figma.code` example shape differs (double-list, record +
// double-list, or phantom-typed pipeline), and each surface's module + entry
// function name are the ones Face C carries per faceCComponent.surfaces.
//
// PURITY: emit() is a pure function of (entry, ctx). The facts bundle is
// static COMMITTED data loaded ONCE at module init (analogous to a static
// JSON import) — not per-entry I/O — so re-runs stay byte-stable
// (emitter-api.mjs purity contract). No network, no env, no clock, no
// randomness.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { buildNodeUrl } from "../../../src/emit/emitter-api.mjs";

// The ONE canonical Face-C→Elm-syntax engine (elm-cem-workspace Phase 1). This
// emitter no longer carries its own copy of the shape grammar — the Layer-1
// resolvers (attr→setter, enum→token, slot→fn, icon→Name, action) and the Layer-2
// call/slot/list/seam renderers all live in elm-shape and are shared with the
// elm-m3e docs consumer. The dependency arrow is one-way: elm-cem → this profile.
// The resolvers return a discriminated result; `must()` maps `err` to THIS
// consumer's fail mode (throw, re-adding the `elm emitter: <ctx> — ` prefix so
// messages stay identical). See packages/elm-cem/src/elm-shape.mjs.
import {
  renderComponentCall,
  renderSlot,
  renderTextSeam,
  renderNativeAttr,
  renderTypedHtml,
  canon,
  setterOf as shapeSetterOf,
  resolveEnumToken,
  resolveAttrExpr,
  slotFnOf,
  slotAttrOf,
  actionNoneOf as shapeActionNoneOf,
  iconNameExpr as shapeIconNameExpr,
} from "elm-cem/elm-shape";

// Map a resolver's discriminated result to this emitter's fail-loud contract,
// re-adding the historical `elm emitter: ${ctxLabel} — ` prefix so a refused name
// throws the SAME message it always has (the CARDINAL RULE: never guess a name).
function must(result, ctxLabel) {
  if (!result.ok) throw new Error(`elm emitter: ${ctxLabel} — ${result.reason}`);
  return result.value;
}

const here = path.dirname(fileURLToPath(import.meta.url));

// Static committed facts, loaded once at module init (see PURITY note above).
// `FACTS` here is elm-cem's Face C (docs/facts-bundle/schema.json's `faceC`)
// verbatim, EXCEPT each surface entry gains a `.surface` field (= its own
// `facet`, e.g. "Standard"/"Build") purely for this module's header-comment
// provenance lines below — Face C itself has no separate field for it
// (`facet` already carries the same information under its own name).
const RAW_FACTS = JSON.parse(
  fs.readFileSync(path.join(here, "..", "facts", "elm-api-facts.json"), "utf8")
);
for (const comp of Object.values(RAW_FACTS.components)) {
  for (const surfaceDef of Object.values(comp.surfaces)) {
    surfaceDef.surface = surfaceDef.facet;
  }
}
const FACTS = RAW_FACTS;

// The opaque-`Name` icon catalog (R-026), a sibling committed fact derived by
// scripts/gen-facts.mjs from the generated icon module itself (tools/lib/
// regen.mjs's deriveIconNames). Post-R-026 the icon module is NOT the generic
// `component` ctor shape Face C projects it onto: it is `icon : Name -> …` with
// one opaque `Name` value per ligature (`menu = Name "menu"`) plus
// `custom : String -> Name`. This catalog — { cemTag, module, iconFn, customFn,
// names } — is what lets this emitter render the REAL shape
// (`M3e.Icon.icon M3e.Icon.menu …`) instead of the non-existent
// `M3e.Icon.component [ M3e.Icon.name "menu" ]`. Every name is sourced here,
// never hardcoded (CARDINAL RULE); a ligature with no exposed constant uses the
// documented `custom` escape hatch, never a guessed identifier.
const ICON_NAMES = JSON.parse(
  fs.readFileSync(path.join(here, "..", "facts", "icon-names.json"), "utf8")
);

// iconNameExpr(symbolName) -> the Elm opaque-`Name` expression for a ligature:
// `M3e.Icon.<constant>` when the ligature has an exposed Name constant, else the
// escape hatch `M3e.Icon.custom "<ligature>"` (e.g. the Figma display-name
// artifact "GIF", whose real ligature is the lowercase "gif").
function iconNameExpr(symbolName) {
  return shapeIconNameExpr(symbolName, ICON_NAMES);
}

const IDENT_RE = /^[A-Za-z_$][A-Za-z0-9_$]*$/;
function objKey(key) {
  return IDENT_RE.test(key) ? key : JSON.stringify(key);
}

// camelCase of an arbitrary Figma display name ("Label text" -> "labelText").
function camel(name) {
  const parts = String(name)
    .split(/[^A-Za-z0-9]+/)
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1).toLowerCase());
  if (parts.length === 0) return "value";
  return parts[0][0].toLowerCase() + parts[0].slice(1) + parts.slice(1).join("");
}

// TEXT-content prop var name (mirrors B1's html-label contentVarName so the
// generated `const label = ...` matches the golden): camelCase, then drop a
// redundant trailing "Text" ("Label text" -> "label").
function contentVarName(prop) {
  const v = camel(prop.figmaProp);
  return prop.kind === "text" && v !== "text" && /Text$/.test(v) ? v.slice(0, -4) : v;
}

// kebab of a value, ordinal (matches emitter-api.mjs slugify's character class).
function kebab(s) {
  return String(s)
    .trim()
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
}

// The id suffix distinguishing this fused set (mirrors B1's setSlugOf): the
// fused CEM-attr VALUE when present (e.g. "filled"), else a kebab of the set
// name. `figmaAxisNames` (Set<string>) excludes axis-pin keys — those name
// Figma VARIANT axes, not CEM attrs, and must not affect the file slug.
function setSlugOf(figmaSet, figmaAxisNames = new Set()) {
  const cemAttrs = Object.entries(figmaSet.fixedAttrs ?? {})
    .filter(([k]) => !figmaAxisNames.has(k))
    .map(([, v]) => kebab(v));
  if (cemAttrs.length > 0) return cemAttrs.join("-");
  return kebab(figmaSet.setName);
}

// slotAttr(comp, attr) -> the matching slot-setter name when a CEM attr
// corresponds to an Elm SLOT (not a settable attr) on this component, else null.
// Post-review Button/IconButton `selected` is a slot function `Element … ->
// Element …` (recorded in elm-facts `slotSetters`), so emitting
// `M3e.Button.selected True` would NOT type-check — such attrs are dropped from
// the setter lines and surfaced as a header note (task B), never emitted.
// FilterChip/NavItem `selected` is a real Bool attr (absent from their
// slotSetters) and is unaffected. Canonical `slotAttrOf` from elm-shape.
function slotAttr(comp, attr) {
  return slotAttrOf(comp, attr);
}

// resolveToken(comp, setter, cemValue) -> "M3e.Token.<ctor>" | throws.
// Thin wrapper over elm-shape's resolveEnumToken (which owns the value-prefix
// fallback for digit-leading enum values). `must` re-adds the throw + prefix.
function resolveToken(comp, setter, cemValue, ctxLabel) {
  return must(resolveEnumToken(comp, setter, cemValue), ctxLabel);
}

// setterOf(comp, attr) -> the facts per-component setter name, or throws (never
// assume the attr name is a valid setter). Wrapper over elm-shape's setterOf.
function setterOf(comp, attr, ctxLabel) {
  return must(shapeSetterOf(comp, attr), ctxLabel);
}

// resolveSetAttrExpr(comp, attr, value, ctxLabel) -> Elm expression string.
// Wrapper over elm-shape's resolveAttrExpr (enum→token, Float/Int literal,
// True/False, else JSON string). Never guesses — throws if the attr is not a
// verified setter.
function resolveSetAttrExpr(comp, attr, value, ctxLabel) {
  return must(resolveAttrExpr(comp, attr, value), ctxLabel);
}

// textSeamOf(config) -> the userland SEAM module to call `.text` on for text
// content (fix round, replaces the old null-textFn-throws path).
//
// This is DELIBERATELY not a "verified library export" lookup like
// setterOf/resolveToken/actionNoneOf: post-review elm-m3e has no library
// module that exposes a text helper — text/link/label are config-declared,
// generator-typed, userland-filled SEAMS (elm-m3e docs/DESIGN.md §4;
// M3e/Element.elm's doc comment). The prior fix's "textFn:null -> throw" was
// correct that no LIBRARY export exists, but wrong to treat that as
// unresolved: the real, correct source for text content is the documented
// seam convention (M3.a: profile config, not a bundle fact — see this
// file's module doc). It is corroborated against elm-m3e's own
// docs/examples, not verified via an `exposing` list, because there is no
// library module to check one against.
//
// Configurable per-profile via profile.json's `elm.textSeam` (default
// "Kit") — override only if a consuming project's own userland seam module
// has a different name.
function textSeamOf(config) {
  return config.textSeam || "Kit";
}

// htmlSeamOf / attrSeamOf -> the userland SEAMS for plain HTML scaffolding: a
// <div>/<span>/<p> carrier that holds MULTIPLE children (e.g. a right-aligned
// `<div slot="actions">` action row, or a trailing `<span>` holding text + a
// control). Kept DELIBERATELY SEPARATE from the CEM-derived M3e.* component
// facts — exactly like textSeam, these are userland seams sourced from
// elm-m3e's own example convention (config/examples.rich.json consistently
// renders scaffolding as `TypedHtml.div [ Native.attribute "k" "v" ] [ ... ]`
// and `Native.node "img" ...`), NOT verified against a library `exposing`
// list and NOT a CEM-measured bundle fact. Configurable per profile via
// profile.json's `elm.htmlSeam` / `elm.attrSeam`.
function htmlSeamOf(config) {
  return config.htmlSeam || "TypedHtml";
}
function attrSeamOf(config) {
  return config.attrSeam || "Native";
}

// actionNoneOf(comp) -> comp's verified "<ActionModule>.none", or throws.
// Wrapper over elm-shape's actionNoneOf.
function actionNoneOf(comp, ctxLabel) {
  return must(shapeActionNoneOf(comp), ctxLabel);
}

// The example `figma.code` body per surface form. `parts` carries the
// already-facts-resolved pieces: module, entry, finalizer, ordered setter
// lines ({ setter, expr }), the content expression, the token module, etc.
//
// `childrenExprs` (defect-D fix, double-list only): when non-null it is an
// ARRAY of already-facts-resolved Elm child Element expression strings (from
// examples.json / per-set inline examples). It renders as a multiline child
// list and takes precedence over the single `contentExpr` — this is how a
// composed component (Card/Dialog/NavBar/…) emits its real children instead of
// the empty `[]` shell. `null` preserves the pre-fix single-content behavior.
function renderExample(surfaceDef, comp, setterLines, contentExpr, childrenExprs = null) {
  // The top-level (multiline) call shape now comes from the canonical Layer-2
  // renderer (elm-shape). The one comp-dependent piece — the resolved
  // `action = <Mod>.none` record field — is resolved here (record/pipeline forms
  // only) and handed in as a string, so Layer 2 stays pure string composition.
  const actionNone =
    surfaceDef.form === "double-list"
      ? null
      : actionNoneOf(comp, `surface ${surfaceDef.surface}`);
  return renderComponentCall({
    module: surfaceDef.module,
    entry: surfaceDef.entry,
    form: surfaceDef.form,
    finalizer: surfaceDef.finalizer ?? null,
    setters: setterLines,
    content: contentExpr,
    children: childrenExprs,
    actionNone,
    label: `surface ${surfaceDef.surface}`,
    multiline: true,
  });
}

// importsFor(surfaceDef, comp, usesToken) -> the `imports` array, facts-derived:
// the surface module, the token module ONLY when the snippet actually references
// a token (task C — the dead-import fix: bindings that reference no enum token
// no longer import the token module), and (for record/build, which carry an
// action record) the action module.
function importsFor(surfaceDef, comp, usesToken) {
  const imports = [`import ${surfaceDef.module}`];
  if (usesToken) imports.push(`import ${comp.tokenModule}`);
  if (surfaceDef.form !== "double-list") {
    if (!comp.actionModule) {
      throw new Error(
        `elm emitter: surface ${surfaceDef.surface} — no verified action module for component ` +
          `"${comp.component}" (elm-facts recorded actionModule:null). Refusing to import an ` +
          `unverified action module.`
      );
    }
    imports.push(`import ${comp.actionModule}`);
  }
  return imports;
}

// ── examples.json / inline-example CHILDREN -> Elm children (defect D fix) ──
//
// The WC emitter injects examples.json ChildSpecs into WC slots
// (`<m3e-card><span slot="header">…</span>…</m3e-card>`); before this fix the
// Elm emitter dropped them and hardcoded `[]`, so every composed component was
// a contentless shell. These helpers render the SAME ChildSpecs as real Elm
// children, using the elm-m3e slot/compose API — every module/setter/slot name
// is facts-verified (CARDINAL RULE), never guessed.
//
// ChildSpec -> Elm mapping (mirrors src/emit/example-content.mjs's shapes):
//   - text                          -> `<textSeam>.text "<text>"` (Kit.text seam)
//   - custom element `m3e-x`        -> `M3e.X.view [ <attrs> ] [ <children> ]`
//   - slotted child `{slot:"header"}`-> `M3e.Parent.header ( <element> )`
//     (elm-m3e slots are `slotName : Element … -> Element …` functions; see
//      elm-m3e src/M3e/Card.elm). The slot fn name is resolved from the parent
//      component's `slotSetters` fact.
//   - HTML text carrier (span/div/p)-> TRANSPARENT: the wrapper drops away and
//     its text/single-child becomes the element (matching the WC span-carries-
//     slot / Elm slot-fn-carries-slot equivalence). A carrier with multiple
//     element children has no verified elm-m3e wrapper seam, so it throws
//     rather than guess one (never silently drop).

// Plain HTML scaffolding tags treated as transparent text/content carriers
// (parallels src/emit/example-content.mjs's HTML_TAGS text containers).
const HTML_TEXT_TAGS = new Set(["span", "div", "p"]);

function isTokenExpr(comp, expr) {
  return !!comp.tokenModule && String(expr).startsWith(`${comp.tokenModule}.`);
}

// slotSetterOf(parentComp, slotName) -> the verified elm-m3e slot FUNCTION name
// for a WC slot, or throws. Matched by exact name or canonical key (the WC slot
// "selected-icon" canon-matches the elm slot fn "selectedIcon").
function slotSetterOf(parentComp, slotName, ctxLabel) {
  return must(slotFnOf(parentComp, slotName), ctxLabel);
}

// resolveChildAttrExpr(comp, attr, value) -> Elm expr. Like resolveSetAttrExpr,
// but an empty-string value on a Bool setter is boolean-PRESENT -> True (the
// CEM/WC `selected=""` convention: a bare boolean attribute means true).
function resolveChildAttrExpr(comp, attr, value, ctxLabel) {
  return must(resolveAttrExpr(comp, attr, value, { boolPresentTrue: true }), ctxLabel);
}

// renderChildElement(spec, config, acc, ctxLabel) -> single-line Elm Element
// expression (NO slot wrapping — the caller wraps a slotted child), or `null`
// when the child is opaque HTML with no verified elm-m3e representation (it is
// then recorded in `acc.skipped`, never silently dropped).
// `acc` = { imports: Set<string>, skipped: [{ tag, slot?, reason }] }.
function renderChildElement(spec, config, acc, ctxLabel) {
  const textSeam = textSeamOf(config);

  // HTML scaffolding tag: a transparent text/content carrier. Its slot (if any)
  // is applied by the caller against the PARENT component, so here we only
  // resolve the inner content.
  if (HTML_TEXT_TAGS.has(spec.tag)) {
    const inner = collectChildExprs(spec, null, config, acc, ctxLabel);
    if (inner.length === 1) return inner[0];
    if (inner.length === 0) {
      usedImportsAdd(acc, textSeam);
      return `${textSeam}.text ""`;
    }
    // Multiple children: wrap in the userland HTML seam — `TypedHtml.<tag> [
    // Native.attribute "k" "v", ... ] [ <children> ]`. A separate userland seam
    // from the CEM M3e.* facts (see htmlSeamOf/attrSeamOf). The `slot` attr is
    // intentionally NOT emitted here: the caller applies it against the PARENT
    // component's slot function (collectChildExprs), matching the WC side where
    // the wrapper carries slot= and the dialog/list-item places it.
    const htmlSeam = htmlSeamOf(config);
    const attrSeam = attrSeamOf(config);
    const attrExprs = Object.entries(spec.attrs ?? {})
      .filter(([k]) => k !== "slot")
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
      .map(([k, v]) => renderNativeAttr(attrSeam, k, v));
    usedImportsAdd(acc, htmlSeam);
    if (attrExprs.length) usedImportsAdd(acc, attrSeam);
    return renderTypedHtml(htmlSeam, spec.tag, attrExprs, inner);
  }

  const comp = FACTS.components[spec.tag];
  if (!comp) {
    // A plain (non-m3e) HTML tag with no text-carrier mapping — e.g. <input>,
    // <img>, <button>. elm-m3e has no verified element seam for these (its own
    // examples use a userland TypedHtml/Native seam this profile does not
    // configure), so they are SKIPPED and surfaced as a header note rather than
    // guessed. A genuinely unknown m3e-* child (should have facts) still throws.
    if (!spec.tag.startsWith("m3e-")) {
      acc.skipped.push({
        tag: spec.tag,
        slot: spec.slot,
        reason: "opaque HTML element with no verified elm-m3e element seam",
      });
      return null;
    }
    throw new Error(
      `elm emitter: ${ctxLabel} — child tag "${spec.tag}" has no elm facts (an m3e-* component ` +
        `the facts do not know). Refusing to guess a module name.`
    );
  }
  usedImportsAdd(acc, comp.module);

  // Opaque-`Name` icon (R-026): the ligature moves out of a `name` string
  // setter into the positional `Name` argument of `M3e.Icon.icon`; every other
  // attr (filled/weight/…) stays in the attr list. Sourced from ICON_NAMES,
  // never the generic `component`/`name` facts projection.
  if (spec.tag === ICON_NAMES.cemTag) {
    const symbol = spec.attrs?.name;
    if (symbol == null) {
      throw new Error(
        `elm emitter: ${ctxLabel} — <${ICON_NAMES.cemTag}> child has no "name" attribute to resolve an icon Name.`
      );
    }
    const nameExpr = iconNameExpr(symbol);
    const iconAttrExprs = Object.entries(spec.attrs ?? {})
      .filter(([k]) => k !== "name")
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
      .map(([attr, value]) => {
        const setter = setterOf(comp, attr, `${ctxLabel} attr "${attr}"`);
        const expr = resolveChildAttrExpr(comp, attr, value, `${ctxLabel} attr "${attr}"`);
        if (isTokenExpr(comp, expr)) usedImportsAdd(acc, comp.tokenModule);
        return `${comp.module}.${setter} ${expr}`;
      });
    const iconChildExprs = collectChildExprs(spec, comp, config, acc, ctxLabel);
    const iconAttrList = iconAttrExprs.length ? `[ ${iconAttrExprs.join(", ")} ]` : "[]";
    const iconChildList = iconChildExprs.length ? `[ ${iconChildExprs.join(", ")} ]` : "[]";
    return `${comp.module}.${ICON_NAMES.iconFn} ${nameExpr} ${iconAttrList} ${iconChildList}`;
  }

  const surfaceDef = comp.surfaces.top;
  if (!surfaceDef) {
    throw new Error(`elm emitter: ${ctxLabel} — component "${comp.component}" has no "top" surface.`);
  }

  const setterPairs = Object.entries(spec.attrs ?? {})
    .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
    .map(([attr, value]) => {
      const setter = setterOf(comp, attr, `${ctxLabel} attr "${attr}"`);
      const expr = resolveChildAttrExpr(comp, attr, value, `${ctxLabel} attr "${attr}"`);
      if (isTokenExpr(comp, expr)) usedImportsAdd(acc, comp.tokenModule);
      return { setter, expr };
    });
  const childExprs = collectChildExprs(spec, comp, config, acc, ctxLabel);

  // The nested call shape follows the component's own top-surface form (the
  // ctor-rename cascade moved several composed components — Button, Fab,
  // IconButton, chips, … — from `double-list` to `record-double-list`, so a
  // nested one MUST carry the `{ content, action }` record or it will not
  // type-check as `M3e.X.component [attrs] [children]`). It is rendered by the
  // canonical Layer-2 inline renderer (elm-shape) — the SAME grammar as the
  // top-level `renderExample`, only inline (single-line) instead of multiline.
  if (surfaceDef.form === "double-list") {
    return renderComponentCall({
      module: comp.module,
      entry: surfaceDef.entry,
      form: "double-list",
      setters: setterPairs,
      children: childExprs,
      multiline: false,
    });
  }
  if (surfaceDef.form === "record-double-list") {
    // The record `content` is prepended to the child list by the ctor
    // (`content :: children`): the first collected child folds into `content`,
    // the rest trail. No children -> an empty text-seam content element.
    let content = null;
    if (childExprs.length === 0) {
      const textSeam = textSeamOf(config);
      content = renderTextSeam(textSeam, "");
      usedImportsAdd(acc, textSeam);
    }
    const actionNone = actionNoneOf(comp, ctxLabel);
    usedImportsAdd(acc, comp.actionModule);
    return renderComponentCall({
      module: comp.module,
      entry: surfaceDef.entry,
      form: "record-double-list",
      setters: setterPairs,
      content,
      children: childExprs,
      actionNone,
      label: ctxLabel,
      multiline: false,
    });
  }
  throw new Error(
    `elm emitter: ${ctxLabel} — component "${comp.component}" top surface has form "${surfaceDef.form}", ` +
      `which the nested-child renderer does not support (only double-list / record-double-list).`
  );
}

function usedImportsAdd(acc, module) {
  acc.imports.add(module);
}

// collectChildExprs(spec, parentComp, config, acc, ctxLabel) -> string[]
// The Element expressions that make up `spec`'s content: its own text (as a
// text-seam call) followed by each nested child (slot-wrapped against
// `parentComp` when the child carries a `slot`). Opaque HTML children (null
// from renderChildElement) are omitted here — including a slotted one, whose
// empty slot is dropped rather than emitted.
function collectChildExprs(spec, parentComp, config, acc, ctxLabel) {
  const textSeam = textSeamOf(config);
  const exprs = [];
  if (spec.text != null && spec.text !== "") {
    usedImportsAdd(acc, textSeam);
    exprs.push(renderTextSeam(textSeam, spec.text));
  }
  for (const child of spec.children ?? []) {
    const childLabel = `${ctxLabel} > <${child.tag}>`;
    const el = renderChildElement(child, config, acc, childLabel);
    if (el === null) continue; // opaque HTML — recorded in acc.skipped
    if (child.slot) {
      if (!parentComp) {
        throw new Error(
          `elm emitter: ${childLabel} — a slotted child ("${child.slot}") appears under HTML carrier ` +
            `<${spec.tag}>, which has no component to resolve the slot function against.`
        );
      }
      const slotFn = slotSetterOf(parentComp, child.slot, childLabel);
      usedImportsAdd(acc, parentComp.module);
      exprs.push(renderSlot(parentComp.module, slotFn, el));
    } else {
      exprs.push(el);
    }
  }
  return exprs;
}

// renderExampleChildrenElm(childSpecs, parentComp, config, acc) -> string[]
// The top-level Elm child expressions for a composed component's examples.json
// / inline-example children. `acc` = { imports: Set, skipped: [] }.
function renderExampleChildrenElm(childSpecs, parentComp, config, acc) {
  usedImportsAdd(acc, parentComp.module);
  return collectChildExprs(
    { tag: parentComp.cemTag, children: childSpecs },
    parentComp,
    config,
    acc,
    parentComp.cemTag
  );
}

// emitEntry(entry, config) -> [{ path, contents, id }]
export function emitEntry(entry, config) {
  const comp = FACTS.components[entry.cemTag];
  if (!comp) return []; // no elm facts for this tag (e.g. a CEM-only component) — quiet no-op

  const surfaceKey = config.surface;
  if (!FACTS.surfaceKeys.includes(surfaceKey)) {
    throw new Error(
      `elm emitter: elmSurface "${surfaceKey}" is not one of ${FACTS.surfaceKeys.join(", ")}.`
    );
  }
  const surfaceDef = comp.surfaces[surfaceKey];
  if (!surfaceDef) {
    throw new Error(
      `elm emitter: component "${comp.component}" does not emit at surface "${surfaceKey}" ` +
        `(available: ${Object.keys(comp.surfaces).join(", ")}).`
    );
  }

  // Mapped axes, sorted by figmaProp (ordinal) — deterministic, and it
  // reproduces the golden's block/pipeline order ("Size" < "Type" -> size
  // before shape).
  const mappedAxesAll = entry.axes
    .filter((a) => a.valueMap !== undefined)
    .sort((a, b) => (a.figmaProp < b.figmaProp ? -1 : a.figmaProp > b.figmaProp ? 1 : 0));
  // Axes whose CEM attr is an Elm SLOT (task B: Button/IconButton `selected`)
  // are dropped from the binding and surfaced as a header note — never emitted
  // as `Module.<slot> <bool>` (a type error against a slot function).
  const slotMappedAxes = mappedAxesAll.filter((a) => slotAttr(comp, a.attr));
  const mappedAxes = mappedAxesAll.filter((a) => !slotAttr(comp, a.attr));
  const unmappedAxes = entry.axes.filter((a) => a.valueMap === undefined);

  const textContentProp = entry.props.find((p) => p.kind === "text" && p.binding === "content");
  // Mapped props this Elm surface does not (yet) BIND in the pipeline — e.g.
  // the icon slot boolean/instanceSwap. Never silently dropped: surfaced as a
  // visible header note (mirrors B1's unmapped policy / emitter-api.mjs "never
  // silently do" rule). The golden spike also renders only the text content.
  const unboundMappedProps = entry.props.filter(
    (p) => p.unmapped === undefined && p !== textContentProp
  );
  const unmappedProps = entry.props.filter((p) => p.unmapped !== undefined);

  // getEnum blocks (one per mapped axis): keys are the Figma option verbatim
  // (case-sensitive), values are facts-resolved token expressions.
  const axisBlocks = mappedAxes.map((axis) => {
    const setter = setterOf(comp, axis.attr, `axis "${axis.figmaProp}"`);
    const lines = Object.entries(axis.valueMap)
      .map(([figmaKey, cemValue]) => {
        // A boolean axis (RC1: e.g. switch Selected->checked) maps to a Bool
        // setter — `M3e.Switch.checked True`, NOT an enum token. Emit the Elm
        // Bool literal directly and never route it through resolveToken (there
        // is no enum fact for a primitive setter; the facts extractor now
        // records `checked` as a plain setter, not an enum).
        const value =
          axis.kind === "boolean"
            ? cemValue === "true" || cemValue === true
              ? "True"
              : "False"
            : resolveToken(comp, setter, cemValue, `axis "${axis.figmaProp}" value "${figmaKey}"`);
        return `  ${objKey(figmaKey)}: ${JSON.stringify(value)},`;
      })
      .join("\n");
    return {
      varName: axis.attr,
      setter,
      code: `const ${axis.attr} = instance.getEnum(${JSON.stringify(axis.figmaProp)}, {\n${lines}\n})`,
    };
  });

  // hasExamplesEntry: whether the cemTag-level examples.json has an entry.
  // Per-set inline examples (appendSets mechanism) are handled inside the
  // per-set loop — a figmaSet's own example.children takes precedence.
  const hasExamplesEntry = !!(config.examples && config.examples[entry.cemTag]);

  // contentBlock is emitted only when NOT in examples-mode. Since examples-mode
  // is now resolved per-set, we determine whether to emit the content const
  // inside the loop. Pre-calculate the block shape here for reuse.
  const contentBlockShape = textContentProp
    ? {
        varName: contentVarName(textContentProp),
        code: `const ${contentVarName(textContentProp)} = instance.getString(${JSON.stringify(textContentProp.figmaProp)})`,
      }
    : null;

  const textSeam = textSeamOf(config);

  const allAxisCodes = axisBlocks.map((b) => b.code);

  // importsArr is computed inside the per-set loop (it stays constant across
  // sets, but is defined there for locality with the other per-set state).

  // figmaAxisNames: keys that name a Figma VARIANT axis. fixedAttrs entries
  // with these keys are axis-pin entries (drive.mjs: select a Figma variant
  // for gate comparison) — NOT CEM setters; they must not be emitted as
  // setter lines or affect the file slug.
  const figmaAxisNames = new Set(entry.axes.map((a) => a.figmaProp));

  // Per-set static attr injection (set-attrs.json). Validate all setName keys
  // before the per-set loop — a typo is a build error, never a silent no-op.
  const setAttrsForTag = (config.setAttrs ?? {})[entry.cemTag] ?? null;
  if (setAttrsForTag !== null) {
    const knownSetNames = new Set(entry.figmaSets.map((s) => s.setName));
    for (const setName of Object.keys(setAttrsForTag)) {
      if (!knownSetNames.has(setName)) {
        throw new Error(
          `set-attrs: unknown setName '${setName}' for '${entry.cemTag}' — ` +
            `not one of this entry's figmaSets (${[...knownSetNames].join(", ")}). ` +
            `Fix the typo in set-attrs.json.`
        );
      }
    }
  }

  return entry.figmaSets.map((figmaSet) => {
    const url = buildNodeUrl(config, figmaSet.nodeId);

    // Per-set inline example (appendSets mechanism) takes precedence over the
    // cemTag-level examples.json entry. A figmaSet WITHOUT an inline example
    // falls back to the cemTag-level check.
    const setHasInlineExample = figmaSet.example?.children != null;
    const setHasExamplesEntry = setHasInlineExample || hasExamplesEntry;

    // Defect-D fix: the examples.json / per-set-inline ChildSpecs for this set,
    // rendered as real Elm children. Both the double-list AND record-double-list
    // forms carry a trailing child list (the ctor-rename cascade moved many
    // composed components — Segmented Button, chips, Search View, … — to the
    // record form), so example children must render for BOTH; renderExample
    // folds the first child into the record `content` for the record form.
    const exampleChildrenSpecs = setHasInlineExample
      ? figmaSet.example.children
      : hasExamplesEntry
        ? config.examples[entry.cemTag].children
        : null;
    const childAcc = { imports: new Set(), skipped: [] };
    const childrenExprs =
      exampleChildrenSpecs &&
      (surfaceDef.form === "double-list" || surfaceDef.form === "record-double-list")
        ? renderExampleChildrenElm(exampleChildrenSpecs, comp, config, childAcc)
        : null;

    // Resolve content block + content expression for this set.
    const contentBlock =
      !setHasExamplesEntry && contentBlockShape
        ? contentBlockShape
        : null;
    // A2 (kit-wide): a set with no text content renders [] children on a
    // double-list surface (null -> [] in renderExample). Record/pipeline forms
    // still require a single content element, so keep the empty seam text there.
    const contentExpr = contentBlock
      ? `${textSeam}.text "\${${contentBlock.varName}}"`
      : surfaceDef.form === "double-list"
        ? null
        : `${textSeam}.text ""`;

    // blocks: axis codes always included; content block only in non-examples-mode.
    const blocks = [...allAxisCodes, ...(contentBlock ? [contentBlock.code] : [])];

    // slugSuffix (appendSets mechanism): when present, REPLACES the fixedAttrs
    // slug entirely (the appended set controls its filename). Order: <cemTag>-<slug>-elm.
    const baseSlug = figmaSet.slugSuffix != null ? kebab(figmaSet.slugSuffix) : setSlugOf(figmaSet, figmaAxisNames);
    const id = `${entry.cemTag}-${baseSlug}-elm`;

    // Setter lines: fixed CEM-attr entries first (axis-pin keys like Style on
    // m3e-avatar are skipped — they select Figma variants, not CEM setters),
    // then the mapped axes (already sorted by figmaProp). Fixed values render
    // as literal facts tokens; mapped values render as the getEnum var
    // interpolation. This reproduces the golden order (variant, size, shape).
    // Fixed CEM-attr entries whose attr is an Elm SLOT (task B: Button/IconButton
    // `selected`) are dropped here — collected for a header note, never emitted
    // as `Module.<slot> True` (a type error against a slot function).
    const slotFixedAttrs = [];
    const fixedLines = Object.entries(figmaSet.fixedAttrs ?? {})
      .filter(([k]) => !figmaAxisNames.has(k))
      .filter(([attr]) => {
        if (slotAttr(comp, attr)) {
          slotFixedAttrs.push(attr);
          return false;
        }
        return true;
      })
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
      .map(([attr, value]) => {
        const expr = resolveSetAttrExpr(comp, attr, value, `fixed attr "${attr}"`);
        const setter = setterOf(comp, attr, `fixed attr "${attr}"`);
        return { setter, expr };
      });
    const mappedLines = axisBlocks.map((b) => ({ setter: b.setter, expr: "${" + b.varName + "}" }));

    // Per-set static attrs (from set-attrs.json) appended last, sorted.
    // Throws on key collision with fixedAttrs (same policy as html-label).
    const perSetAttrs = setAttrsForTag ? (setAttrsForTag[figmaSet.setName] ?? {}) : {};
    const fixedAttrKeys = new Set(
      Object.entries(figmaSet.fixedAttrs ?? {})
        .filter(([k]) => !figmaAxisNames.has(k))
        .map(([k]) => k)
    );
    const perSetLines = Object.entries(perSetAttrs)
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
      .map(([attr, value]) => {
        if (fixedAttrKeys.has(attr)) {
          throw new Error(
            `set-attrs: key collision '${attr}' already in fixedAttrs for '${entry.cemTag}' ` +
              `set '${figmaSet.setName}'. Remove the key from one source.`
          );
        }
        const ctxLabel = `set-attr "${attr}" for "${figmaSet.setName}"`;
        const setter = setterOf(comp, attr, ctxLabel);
        const expr = resolveSetAttrExpr(comp, attr, value, ctxLabel);
        return { setter, expr };
      });

    const setterLines = [...fixedLines, ...mappedLines, ...perSetLines];

    const example = renderExample(surfaceDef, comp, setterLines, contentExpr, childrenExprs);

    // task C (dead-import fix): import the token module ONLY when the snippet
    // actually references a token. Tokens are qualified `<tokenModule>.<ctor>`
    // and appear either in a getEnum block value (mapped enum axis) or as a
    // fixed/per-set enum setter expr — both live in `blocks`/`example`. The
    // surface/action/seam module names are all distinct, so this never false-hits.
    const usesToken = (blocks.join("\n") + "\n" + example).includes(`${comp.tokenModule}.`);

    let importsArr;
    if (childrenExprs !== null) {
      // examples-mode (defect-D fix): the surface module, the parent's token
      // module when ITS own setter lines reference a token, plus every
      // module/seam the rendered children pulled in (usedChildImports —
      // nested M3e.* modules, their token modules, and the Kit text seam).
      // Sorted for deterministic, byte-stable, tidy output.
      const imps = new Set([`import ${surfaceDef.module}`]);
      if (usesToken) imps.add(`import ${comp.tokenModule}`);
      // A record/pipeline parent renders `action = <Module>.none`, so it must
      // import the action module even when the children pulled in none.
      if (surfaceDef.form !== "double-list") {
        imps.add(`import ${actionNoneOf(comp, `surface ${surfaceDef.surface}`).replace(/\.none$/, "")}`);
      }
      for (const m of childAcc.imports) imps.add(`import ${m}`);
      importsArr = [...imps]
        .sort()
        .map((i) => JSON.stringify(i))
        .join(", ");
    } else {
      importsArr = [
        ...importsFor(surfaceDef, comp, usesToken),
        ...(contentExpr !== null ? [`import ${textSeam}`] : []),
      ]
        .map((i) => JSON.stringify(i))
        .join(", ");
    }

    // Header notes — visible, never a silent drop of a Figma prop/axis.
    const headerLines = [
      ` * GENERATED by cem-figma-connect (profiles/m3-kit/emitters/elm.mjs) — do not edit by hand.`,
      ` * ${entry.cemTag} -> ${surfaceDef.module}.${surfaceDef.entry} (elmSurface: "${surfaceKey}", surface ${surfaceDef.surface}).`,
      ` * bound to Figma set "${figmaSet.setName}" (${figmaSet.nodeId}).`,
      ` * token names resolved from the elm-cem facts bundle Face C (profiles/m3-kit/facts/elm-api-facts.json); provenance stamp lives in that file's provenance object; NOT the golden's stale short names.`,
      ...(contentExpr !== null
        ? [
            ` * text content -> ${textSeam}.text (userland SEAM, not a library export or a bundle fact; see` +
              ` profiles/m3-kit/profile.json's elm.textSeam — NOT the golden spike's stale "M3e.text").`,
          ]
        : []),
      ...(childrenExprs !== null
        ? [
            ` * children -> rendered from examples.json / inline example into the ${surfaceDef.module}.${surfaceDef.entry} child list (defect D fix).`,
          ]
        : []),
      ...childAcc.skipped.map(
        (s) =>
          ` * example child (not emitted): <${s.tag}>${s.slot ? ` slot="${s.slot}"` : ""} — ${s.reason}; the Web Components emitter renders it, the Elm emitter has no verified seam.`
      ),
      ...mappedAxes.map((a) => ` * axis: ${a.figmaProp} -> ${setterOf(comp, a.attr, a.figmaProp)}`),
      ...unmappedAxes.map((a) => ` * axis (unmapped): ${a.figmaProp} — ${a.unmapped}`),
      ...slotMappedAxes.map(
        (a) => ` * axis (slot, not emitted): ${a.figmaProp} -> ${slotAttr(comp, a.attr)} is an Elm SLOT (Element -> Element), not a settable attr; omitted (task B).`
      ),
      ...slotFixedAttrs.map(
        (attr) => ` * attr (slot, not emitted): ${attr} -> ${slotAttr(comp, attr)} is an Elm SLOT on ${surfaceDef.module}, not a settable bool; omitted (task B).`
      ),
      ...(textContentProp ? [` * prop: ${textContentProp.figmaProp} -> content`] : []),
      ...unboundMappedProps.map(
        (p) => ` * prop (mapped, not bound in this Elm surface): ${p.figmaProp} -> ${p.binding} (kind ${p.kind})`
      ),
      ...unmappedProps.map((p) => ` * prop (unmapped): ${p.figmaProp} — ${p.unmapped}`),
    ];

    const contents =
      `// url=${url}\n` +
      `import figma from "figma"\n` +
      `\n` +
      `/**\n${headerLines.join("\n")}\n */\n` +
      `\n` +
      `const instance = figma.selectedInstance\n` +
      `\n` +
      (blocks.length ? blocks.join("\n\n") + "\n\n" : "") +
      `export default {\n` +
      `  example: figma.code\`${example}\`,\n` +
      `  imports: [${importsArr}],\n` +
      `  id: ${JSON.stringify(id)},\n` +
      `  metadata: {\n` +
      `    nestable: true,\n` +
      `  },\n` +
      `}\n`;

    return { path: `${id}.figma.ts`, contents, id };
  });
}

// emitIconTableEntry(entry, config) -> [{ path, contents, id }]
//
// The Elm mirror of html-label.mjs's emitIconTableEntry (kind:"iconTable", the
// 141-row m3e-icon table): ONE file per icon row. Post-R-026 each maps a real
// Figma icon node -> the opaque-`Name` idiom
// `M3e.Icon.icon M3e.Icon.<constant> [ (M3e.Icon.filled True) ] []` — the
// ligature is the positional `Name` argument (NOT a `name` string setter), and
// children stay EMPTY (amendment A2). The icon module/render-fn/Name constant
// all come from the ICON_NAMES catalog (CARDINAL RULE — sourced from the
// generated icon module, never hardcoded); `filled` stays a facts setter.
//
// Collision handling mirrors html-label byte-for-byte in spirit: duplicate
// (symbolName, filled) filenames get -2/-3… in icons-array order (first
// unsuffixed), plus the Elm emitter's own `-elm` suffix:
// m3e-icon-<kebab(symbol)>[-filled][-N]-elm. PURE (no fs/network).
function emitIconTableEntry(entry, config) {
  const comp = FACTS.components[entry.cemTag];
  if (!comp) return []; // no elm facts for this tag — same quiet no-op as emitEntry

  const filledSetter = setterOf(comp, "filled", "iconTable filled");

  const files = [];
  const usedBases = new Map();
  for (const row of entry.icons) {
    const baseName = `${entry.cemTag}-${kebab(row.symbolName)}${row.filled ? "-filled" : ""}`;
    const priorCount = usedBases.get(baseName) ?? 0;
    const suffix = priorCount === 0 ? "" : `-${priorCount + 1}`;
    usedBases.set(baseName, priorCount + 1);
    const id = `${baseName}${suffix}-elm`;

    const url = buildNodeUrl(config, row.figmaNodeId);
    const nameExpr = iconNameExpr(row.symbolName);
    const attrList = row.filled ? `[ ${comp.module}.${filledSetter} True ]` : "[]";
    const example = `${comp.module}.${ICON_NAMES.iconFn} ${nameExpr} ${attrList} []`;
    const usesCustom = nameExpr.includes(`${ICON_NAMES.module}.${ICON_NAMES.customFn} `);

    const headerLines = [
      ` * GENERATED by cem-figma-connect (profiles/m3-kit/emitters/elm.mjs) — do not edit by hand.`,
      ` * ${entry.cemTag} (iconTable row "${row.figmaName}") -> ${comp.module}.${ICON_NAMES.iconFn} ${nameExpr} (opaque-Name icon, R-026).`,
      ` * bound to Figma icon node ${row.figmaNodeId}; symbol "${row.symbolName}"${row.filled ? " (filled)" : ""}.`,
      ...(usesCustom
        ? [
            ` * "${row.symbolName}" has no exposed Name constant — emitted via the ${comp.module}.${ICON_NAMES.customFn} escape hatch (not guessed).`,
          ]
        : []),
      ` * icon Name resolved from the opaque-Name catalog (profiles/m3-kit/facts/icon-names.json), derived from the generated ${comp.module} module; filled from the elm-cem facts bundle Face C.`,
    ];

    const contents =
      `// url=${url}\n` +
      `import figma from "figma"\n` +
      `\n` +
      `/**\n${headerLines.join("\n")}\n */\n` +
      `\n` +
      `export default {\n` +
      `  example: figma.code\`${example}\`,\n` +
      `  imports: [${JSON.stringify(`import ${comp.module}`)}],\n` +
      `  id: ${JSON.stringify(id)},\n` +
      `  metadata: {\n` +
      `    nestable: true,\n` +
      `  },\n` +
      `}\n`;

    files.push({ path: `${id}.figma.ts`, contents, id });
  }
  return files;
}

export const _internal = {
  camel,
  emitIconTableEntry,
  contentVarName,
  setSlugOf,
  canon,
  resolveToken,
  resolveSetAttrExpr,
  setterOf,
  textSeamOf,
  htmlSeamOf,
  attrSeamOf,
  actionNoneOf,
  renderExample,
  importsFor,
  slotSetterOf,
  resolveChildAttrExpr,
  renderChildElement,
  renderExampleChildrenElm,
  iconNameExpr,
  FACTS,
  ICON_NAMES,
};

// emitter — the emitter-api.mjs (task B2) conformant object. run.mjs's loader
// picks up this `emitter` export.
export const emitter = {
  name: "elm",
  label: "Elm",
  emit(entry, ctx) {
    const config = {
      fileKey: ctx.profile.fileKey,
      fileName: ctx.figma.data.meta.fileName,
      surface:
        ctx.profile.raw?.elm?.elmSurface ??
        ctx.profile.raw?.elmSurface ??
        FACTS.defaultSurface,
      textSeam: ctx.profile.raw?.elm?.textSeam ?? FACTS.textSeam?.module ?? "Kit",
      examples: ctx.examples ?? {},
      setAttrs: ctx.setAttrs ?? {},
    };

    if (entry.kind === "iconTable") {
      return emitIconTableEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
    }
    if (!entry.figmaSets || entry.figmaSets.length === 0) return [];

    return emitEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
  },
};
