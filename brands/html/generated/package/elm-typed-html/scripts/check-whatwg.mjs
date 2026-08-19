#!/usr/bin/env node
// check-whatwg.mjs — curation-vs-WHATWG conformance gate.
//
// elm-typed-html is the de-facto owner of HTML-spec knowledge in the elm-cem
// family (a hand-curated manifest + config). Nothing else guards that curation
// against the spec, so an attribute silently dropped from `config/_globals`
// or the per-element `type` family (the B4 regression) went unnoticed for a
// full release cycle. This gate flags missing / again-dropped attributes.
//
// It checks four things against a pinned WHATWG reference:
//   1. every WHATWG *global* attribute is present in config `_globals`
//   1d. every global is EXPRESSIBLE — i.e. actually exposed by the emitted
//      `TypedHtml.Attributes` — unless it is in KERNEL_BLOCKED, in which case it must
//      be absent. Config presence alone was never the claim this gate makes
//   2. the `type` content attribute is present on input / button / script
//   2b. every attribute whose WHATWG value space is an INTEGER is declared `integer`,
//      not `number` — a `Float -> Attr` setter can serialize values HTML rejects
//   3. for every `_controlled` attribute, no element whose IDL attribute of that name is
//      NUMERIC shares the shared setter's capability ROW — because that shared setter is
//      the DOM-property form, and a string property write against a numeric IDL type
//      either throws or silently coerces
//
// Usage: node scripts/check-whatwg.mjs
// Exits non-zero (listing the gaps) if the curation has drifted below the spec.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, "..");

// ── WHATWG reference sets ──────────────────────────────────────────────────
// The global-attribute list per the WHATWG HTML Living Standard §3.2.6
// (plus `slot`, which the spec also defines as a global). These MUST be
// expressible on every element; dropping any is the B4-class regression.
const WHATWG_GLOBALS = [
  "accesskey",
  "autocapitalize",
  "autocorrect",
  "autofocus",
  "class",
  "contenteditable",
  "dir",
  "draggable",
  "enterkeyhint",
  "hidden",
  "id",
  "inert",
  "inputmode",
  "is",
  "itemid",
  "itemprop",
  "itemref",
  "itemscope",
  "itemtype",
  "lang",
  "nonce",
  "popover",
  "slot",
  "spellcheck",
  "style",
  "tabindex",
  "title",
  "translate",
  "writingsuggestions",
];

// Globals a `String -> Attr` setter gets WRONG, and what they must be instead.
//
// Every global used to be emitted as `String -> Attr`, which inverted four of
// them: `hidden "false"` HID the element and `inert "false"` made it inert,
// because these are boolean CONTENT attributes — any value at all is the true
// state. The enumerated ones were merely unguarded (`dir "rlt"` compiled), but
// four of THOSE must stay enums rather than becoming `Bool`, because their
// literal `"false"` / `"until-found"` is a distinct state that absence does not
// express. Re-flattening any of these to a bare string is that bug returning.
const MUST_NOT_BE_STRING = {
  autocapitalize: "enum (off | none | sentences | words | characters)",
  autocorrect: "enum (on | off)",
  autofocus: "bool (presence attribute)",
  contenteditable: 'enum — "false" differs from absence (which inherits)',
  dir: "enum (ltr | rtl | auto)",
  draggable: 'enum — draggable="false" is meaningful, so NOT a bool',
  enterkeyhint: "enum (enter | done | go | next | previous | search | send)",
  hidden: 'enum — hidden="until-found" is load-bearing, so NOT a bool',
  inert: "bool (presence attribute)",
  inputmode: "enum (none | text | tel | url | email | numeric | decimal | search)",
  itemscope: "bool (presence attribute)",
  popover: "enum (auto | manual | hint)",
  spellcheck: 'enum — spellcheck="false" is meaningful, so NOT a bool',
  tabindex: "int — negative values are load-bearing (-1 = script-focusable only)",
  translate: "enum (yes | no)",
  writingsuggestions: 'enum — writingsuggestions="false" is meaningful, so NOT a bool',
};

// ── The kernel-blocked allowance (gate 1d) ─────────────────────────────────
//
// Attributes `elm/virtual-dom` CANNOT WRITE, whatever the manifest says, and the
// exact reason for each. These are the only names allowed to be curated in config
// and absent from the emitted surface — and, conversely, each MUST be absent: an
// entry here that still has a setter means the guard regressed and the library is
// advertising something that renders as something else.
//
// This is not a hole in the gate; it is the gate recording a decided fact. Gate 1
// still requires all 29 WHATWG globals in `_globals`, because config is a
// description of HTML and `is` is a global. What changed is that "expressible" is
// no longer inferred from config presence: gate 1d reads the EMITTED
// `TypedHtml.Attributes` and checks each global either has a setter or is listed
// here with a reason. Deleting `is` from `_globals` to "make the gate pass" is
// exactly the B4-class silent drop this file exists to catch, and it would now
// fail gate 1 instead of quietly succeeding.
//
// Every reason below is a fact about elm/virtual-dom 1.0.5, in
// ~/.elm/0.19.1/packages/elm/virtual-dom/1.0.5/src/. Do NOT "restore the missing
// setter" — there is no working path from Elm for any of these. Use a port or a
// custom element. The generator-side home for the same facts, with the full
// case-by-case argument, is `Attr.kernelBlockedReason` in elm-cem.
const KERNEL_BLOCKED = {
  // Not rewritten — defeated one step earlier, at element creation.
  // `_VirtualDom_render` does `_VirtualDom_doc.createElement(vNode.__tag)` (and
  // `createElementNS(ns, tag)` in the namespaced branch): both two-argument, no
  // `{ is }` options object. A customized built-in element is opted in ONLY at
  // creation time, so by the time any attribute fact is applied the element is
  // already its plain built-in self and `setAttribute("is", …)` cannot upgrade it.
  // There is no `is` IDL attribute either, so a property write is an inert expando.
  is:
    "customized built-in elements need `document.createElement(tag, { is })`; " +
    "`_VirtualDom_render` calls `createElement(vNode.__tag)` with no options argument, so `is` " +
    "is inert once the element exists",

  // `_VirtualDom_RE_on_formAction = /^(on|formAction$)/i`. The `i` flag applies to
  // the whole pattern, so `^formAction$` matches HTML's lowercase `formaction`, and
  // `_VirtualDom_noOnOrFormAction` (run by `VirtualDom.attribute`) returns
  // `'data-' + key`. `Ir.attribute "formaction" url` renders `data-formaction="…"`:
  // a <button> that does not override its form's action, silently.
  //
  // The property path is closed too, so this is not a form problem:
  // `_VirtualDom_noInnerHtmlOrFormAction` (run by `VirtualDom.property`) rewrites the
  // exact key `formAction`, and the lowercase key `formaction` escapes that test only
  // to become an inert JS expando — <button> has no `formaction` property. There is NO
  // working path from Elm.
  //
  // Not a global; listed here because gate 1e checks the whole emitted surface, not
  // just the globals.
  formaction:
    "`_VirtualDom_noOnOrFormAction` rewrites every `VirtualDom.attribute` key matching " +
    "`/^(on|formAction$)/i` to `data-` + key, and the `i` flag makes `^formAction$` match the " +
    "lowercase content-attribute spelling; the property path is blocked by " +
    "`_VirtualDom_noInnerHtmlOrFormAction` (exact key `formAction`) or is an inert expando",
};

// Elements that carry a `type` content attribute (the B4 family).
const TYPE_ELEMENTS = ["Input", "Button", "Script"];

// ── The controlled-roster IDL table (gate 3) ───────────────────────────────
//
// For every attribute in config `_controlled`, the IDL TYPE of the same-named
// attribute on every element that declares it, per the WHATWG HTML Living Standard's
// interface definitions. Keyed by tag name.
//
// This exists because `_controlled` turns a content attribute into
// `Ir.property "<name>" (Json.Encode.string …)`, and a JS property assignment is not
// the inert, forgiving thing a content-attribute write is: it goes through Web IDL
// conversion. `DOMString` accepts anything. `long` runs ToInt32, so a non-numeric
// string quietly becomes 0. But **`double` REJECTS a non-finite value with a
// TypeError** — and virtual-dom applies property facts inside `_VirtualDom_applyFacts`
// during patch, so that exception is not contained to one node: it aborts the patch
// and takes the Elm render loop with it (~60 re-thrown TypeErrors per second on an
// otherwise idle page, measured). `TypedHtml.Text.value "abc"` on a `<progress>` was
// exactly that crash, and the roster was keyed by attribute NAME alone, so every one of
// the seven elements declaring a `value` attribute got the property treatment whether or
// not it could survive it.
//
// WHERE THE PROPERTY WRITE COMES FROM, and why the `elements` scope is not the whole
// guard. Two setters can write it:
//   - the element's OWN home-module setter, which the `elements` scope controls; and
//   - the shared `TypedHtml.Attributes.<name>` setter, which the scope does NOT control.
//     `TypedHtml.Attributes` is the loose surface: one open producer per name, admitted
//     by every element whose capability row carries the field. When a brand's forms are
//     split, elm-cem gives that one body the PROPERTY form (`Model.sharedAttrs`), because
//     the alternative pins `TypedHtml.Attributes.value model.text` on a dirty text input
//     — issue #41, on the most-used setter in the library. So an element that keeps the
//     `value` capability keeps admitting a property write no matter how the roster is
//     scoped.
//
// Hence the gate has to check the ROW, not just the scope. An element whose IDL type is
// not property-safe must have left the row via config `_renames` (which moves elm-cem's
// `elmName` and `capName` together, so a renamed setter is a genuinely different
// capability) AND been given the type its value space really has via `attrTypes` — a
// rename alone is the same lie under a new name.
//
// The gate refuses four things:
//   - a roster entry with no `elements` scope at all (a name-only claim is a claim
//     about `HTMLElement`, which is what went wrong);
//   - a scoped element whose IDL type here is not `DOMString`/`boolean`;
//   - an element with a non-property-safe IDL type that is still on the shared row, i.e.
//     one config `_renames` has not moved to its own setter name;
//   - such an element whose renamed setter has no `attrTypes` entry, or one that does not
//     match its IDL type (`double` -> float, `long` -> int).
//
// It also refuses an INCOMPLETE table: if the manifest gains an element declaring one
// of these attributes and nobody recorded its IDL type, the scoping decision was made
// without the fact it depends on. Add the row, then decide.
const CONTROLLED_IDL = {
  // `HTMLButtonElement.value`, `HTMLDataElement.value`, `HTMLOptionElement.value`:
  // `[CEReactions] attribute DOMString value;` — all reflect the content attribute.
  // `HTMLInputElement.value` is DOMString too, but is NOT a simple reflection: it has
  // a value MODE and a dirty-value flag, which is the whole reason it is controlled.
  // `HTMLLIElement.value` is `attribute long value;`. `HTMLMeterElement.value` and
  // `HTMLProgressElement.value` are `attribute double value;` — the crashers.
  value: {
    button: "DOMString",
    data: "DOMString",
    input: "DOMString",
    li: "long",
    meter: "double",
    option: "DOMString",
    progress: "double",
  },
  checked: { input: "boolean" },
  selected: { option: "boolean" },
  muted: { audio: "boolean", video: "boolean" },
};

// IDL types a `Json.Encode.string` property write survives. Anything else either
// silently coerces to a wrong value or throws.
const PROPERTY_SAFE_IDL = new Set(["DOMString", "boolean"]);

// The `attrTypes` scalar an element that LEFT the shared row must declare, per IDL type.
// This is the second half of the divergence and not a nicety: a renamed setter with no
// type override is still `String -> Attr`, which writes the same unconstrained string
// under a new name. With it, the Elm type makes the malformed attribute value
// unconstructible — `String.fromFloat` cannot emit a non-finite double and
// `String.fromInt` cannot emit a fractional ordinal.
const REQUIRED_ATTR_TYPE = { double: "float", long: "int" };

// Per-element attributes a `number` type gets WRONG, and what they must be instead.
//
// The sibling of MUST_NOT_BE_STRING, one level down: these are not globals, and the
// bug is the opposite direction — a value space that is NOT a single number typed as
// `number`, which emits `Float -> Attr` and makes the legal values unexpressible.
//
// All three came from one place: `native-manifest-gen/src/typing.mjs` classifies off
// the WHATWG attribute-index value cell, and its `float`/`int` patterns match a
// SUBSTRING. So "Valid list of floating-point numbers" (coords), "Valid floating-point
// number greater than zero, or 'any'" (step) and the `datetime` cell — whose long list
// of accepted string formats ends with "valid non-negative integer" — all matched a
// numeric pattern. `typeText` then collapses both int and float to `'number'`.
//
// `datetime` is the one that shipped: `<time>`'s `number` outranked `<ins>`/`<del>`'s
// `string` in the shared vocabulary and the string side was dropped silently.
const MUST_NOT_BE_NUMBER = {
  coords:
    'string — a COMMA-SEPARATED LIST ("0,0,82,126"); no single number is ever valid. `coordsAsInts` is the List Int variant',
  datetime:
    "string — a date/time string on <time>, a date-and-time string on <ins>/<del>. Only ONE of the accepted <time> formats is an integer",
  step:
    'string — must admit the keyword "any", which disables step-matching. `stepAsNumber` is the Float variant',
};

// ── The integer value spaces (gate 2b) ─────────────────────────────────────
//
// The sibling of MUST_NOT_BE_NUMBER in the other direction: these attributes ARE a
// single number, and that number is a whole one. Every element that declares them
// must declare them `integer`, the CEM spelling `elm-cem`'s `Attr.classifyText`
// resolves to `AInt` and the emitter spells `Int -> Attr`.
//
// Declared `number` — which every one of them was, over 31 element/attribute pairs —
// they emit `Float -> Attr` and serialize with `String.fromFloat`, whose range
// includes four strings HTML's integer parsers REJECT:
//
//     String.fromFloat 2.5      == "2.5"
//     String.fromFloat (0 / 0)  == "NaN"
//     String.fromFloat (1 / 0)  == "Infinity"
//     String.fromFloat 1.0e21   == "1e+21"
//
// A rejected value is not an ignored one. HTML's "rules for parsing non-negative
// integers" fail, and the attribute falls back to its DEFAULT — so the bug is silent
// and value-changing: `colspan="2.5"` renders as ONE column and the table loses the
// other. `elm/html` types all eleven `Int` and always has.
//
// WHAT THIS GATE DOES NOT CLAIM. Six of the eleven are "greater than zero" per the
// value column, and `Int` still admits `0` and `-3`. That is deliberate and terminal,
// not a staged fix: Elm has no refinement, literal or dependent types, so no type has
// exactly the integers >= 1 as its inhabitants while `colspan 2` stays a bare literal.
// An opaque `Positive` with `fromInt : Int -> Maybe Positive` moves the check to
// RUNTIME and makes every call site discharge a `Maybe` — which callers do with
// `withDefault`, i.e. the guard evaporates. A `one`/`succ` encoding is compile-time
// but unusable past about three. And out-of-range-but-well-formed is the strictly
// milder failure anyway: HTML ACCEPTS it and clamps to the spec's stated default,
// where it DISCARDS a malformed one. The `value` column is recorded below so the next
// reader can see which is which without opening the spec.
//
// `elements` is the set of manifest DECLARATION names (not tag names — `Source` and
// `PictureSource` share the tag `source` and only the picture one has width/height).
// It is checked for completeness in both directions, because a gate that only judged
// attributes it FOUND would pass silently if one were dropped from the manifest.
const MUST_BE_INTEGER = {
  colspan: { value: "Valid non-negative integer greater than zero", elements: ["Td", "Th"] },
  // Not "greater than zero", unlike its sibling: `rowspan="0"` is legal and means
  // "span to the end of the row group". Do not "fix" this to match colspan.
  rowspan: { value: "Valid non-negative integer", elements: ["Td", "Th"] },
  rows: { value: "Valid non-negative integer greater than zero", elements: ["Textarea"] },
  cols: { value: "Valid non-negative integer greater than zero", elements: ["Textarea"] },
  size: { value: "Valid non-negative integer greater than zero", elements: ["Input", "Select"] },
  span: { value: "Valid non-negative integer greater than zero", elements: ["Col", "Colgroup"] },
  // "Valid integer", not non-negative: `<ol start="-3">` counts up from -3. The same
  // value space as `<li value>` (which is `valueOrdinal : Int` for an unrelated reason
  // — see CONTROLLED_IDL) and as the `tabindex` global. Negatives are load-bearing, so
  // even a hypothetical non-negative type would be WRONG here.
  start: { value: "Valid integer", elements: ["Ol"] },
  maxlength: { value: "Valid non-negative integer", elements: ["Input", "Textarea"] },
  minlength: { value: "Valid non-negative integer", elements: ["Input", "Textarea"] },
  width: {
    value: "Valid non-negative integer",
    elements: ["Canvas", "Embed", "Iframe", "Img", "Input", "Object", "Video", "PictureSource"],
  },
  height: {
    value: "Valid non-negative integer",
    elements: ["Canvas", "Embed", "Iframe", "Img", "Input", "Object", "Video", "PictureSource"],
  },
};

// The counterweight: attributes that really ARE floats and must stay `number`. Without
// these the gate above could be "satisfied" by retyping every numeric attribute
// `integer`, which would make `<meter high="0.8">` unwritable. `String.fromFloat` is
// correct here — "Valid floating-point number" is the spec's own words.
const MUST_STAY_NUMBER = {
  high: "Valid floating-point number (meter)",
  low: "Valid floating-point number (meter)",
  optimum: "Valid floating-point number (meter)",
};

// ── Load the curated inputs ────────────────────────────────────────────────
const config = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "..", "..", "..", "inputs", "config.json"), "utf8")
);
const manifest = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "manifest", "native.cem.json"), "utf8")
);

// A `_globals` entry is either a bare string (a free-string global) or a
// `{ name, type }` object, where `type` is "bool"/"int"/"float"/"string" or a
// token list for an enum. Both forms are legal config; only the NAME matters for
// spec coverage, and only the TYPE for the string-flattening check below.
const globalEntries = config._globals ?? ["class", "id", "slot", "style"];
const globalName = (g) => (typeof g === "string" ? g : g.name);
const globalType = (g) => (typeof g === "string" ? "string" : (g.type ?? "string"));

const globals = new Set(globalEntries.map(globalName));
const decls = manifest.modules.flatMap((m) => m.declarations ?? []);

const problems = [];

// 1. Globals
const missingGlobals = WHATWG_GLOBALS.filter((g) => !globals.has(g));
if (missingGlobals.length > 0) {
  problems.push(
    `config/_globals is missing WHATWG global attribute(s): ${missingGlobals.join(", ")}`
  );
}

// 1d. "Expressible" means a setter EXISTS, not that config mentions the name.
//
// Gate 1 above reads config, which is a description of HTML — and that is the right
// thing for it to read, since a name missing from `_globals` is curation drift. But it
// cannot see whether elm-cem actually emitted a setter, and one class of attribute is
// deliberately dropped: the names `elm/virtual-dom` rewrites or ignores
// (KERNEL_BLOCKED). Without this check the PASS line's "29 WHATWG globals expressible"
// would be a claim about config, not about the library.
//
// So: parse the emitted `TypedHtml.Attributes` exposing list, and require every global
// to be either present (and NOT kernel-blocked) or absent (and kernel-blocked). Both
// directions matter. A blocked name that reappears is a regressed guard shipping a
// setter that renders `data-formaction`; an unblocked name that vanishes is the B4
// silent drop.
const attributesModule = path.join(repoRoot, "src", "TypedHtml", "Attributes.elm");
if (!fs.existsSync(attributesModule)) {
  problems.push(
    `src/TypedHtml/Attributes.elm is missing, so "expressible" cannot be checked at all; ` +
      `run scripts/regen.sh first`
  );
} else {
  // The `module … exposing ( … )` header, up to the closing paren of the list. Setter
  // names are the bare identifiers in it; `@docs` lines would do equally well but the
  // exposing list is the actual public surface.
  const source = fs.readFileSync(attributesModule, "utf8");
  const header = source.slice(0, source.indexOf("\n{-|"));
  const exposed = new Set(header.match(/[A-Za-z_][A-Za-z0-9_]*/g) ?? []);

  for (const entry of globalEntries) {
    const name = globalName(entry);
    const blockedBecause = KERNEL_BLOCKED[name];
    const hasSetter = exposed.has(name);

    if (hasSetter && blockedBecause) {
      problems.push(
        `TypedHtml.Attributes exposes \`${name}\`, but it is KERNEL_BLOCKED: ${blockedBecause}. ` +
          `The setter compiles and renders and does the wrong thing silently — that is the bug the ` +
          `guard exists to prevent, so this means the guard regressed. Do not "restore the missing ` +
          `setter": see \`Attr.kernelBlockedReason\` in elm-cem`
      );
    } else if (!hasSetter && !blockedBecause) {
      problems.push(
        `WHATWG global \`${name}\` is curated in config/_globals but TypedHtml.Attributes exposes no ` +
          `setter for it, so it is NOT expressible (the B4-class silent drop). Either restore the ` +
          `setter, or — if elm/virtual-dom genuinely cannot write it — add it to KERNEL_BLOCKED in ` +
          `this file WITH the kernel function responsible`
      );
    }
  }

  // 1e. And the same both-directions check for the kernel-blocked names that are NOT
  // globals (`formaction` is a <button>/<input> attribute). The manifest must still
  // declare them — they are real HTML and the manifest's job is to describe HTML — and
  // the emitted surface must still not.
  //
  // The global/per-element split is taken from WHATWG_GLOBALS, the SPEC fact, not from
  // the config roster. Keyed off config, deleting `is` from `_globals` would trip this
  // loop's "not declared by any element" arm on top of gate 1's own complaint — two
  // messages for one mistake, the second of them misleading (`is` is not a per-element
  // attribute and never should be declared as one). Gate 1 already owns that mistake.
  for (const [name, because] of Object.entries(KERNEL_BLOCKED)) {
    if (WHATWG_GLOBALS.includes(name)) continue; // a global; gate 1 + 1d own it

    const declaring = decls.filter((d) => (d.attributes ?? []).some((a) => a.name === name));
    if (declaring.length === 0) {
      problems.push(
        `KERNEL_BLOCKED.${name} is not declared by any element in manifest/native.cem.json. Either the ` +
          `manifest dropped a real HTML attribute (fix the manifest — it describes HTML, blocked or not) ` +
          `or the entry is stale (remove it, with a note saying why it stopped being blocked)`
      );
    }
    if (exposed.has(name)) {
      problems.push(
        `TypedHtml.Attributes exposes \`${name}\`, but it is KERNEL_BLOCKED: ${because}. ` +
          `The guard regressed; see \`Attr.kernelBlockedReason\` in elm-cem`
      );
    }
  }
}

// 1b. Globals that a free-string setter mistypes (see MUST_NOT_BE_STRING).
for (const entry of globalEntries) {
  const name = globalName(entry);
  const required = MUST_NOT_BE_STRING[name];
  if (required && globalType(entry) === "string") {
    problems.push(`config/_globals.${name} is typed as a free string; it must be ${required}`);
  }
}

// 1c. Per-element attributes a `number` setter mistypes (see MUST_NOT_BE_NUMBER).
// A missing declaration is not this check's business (gate 2 owns absence), so only
// entries actually present are judged.
for (const decl of decls) {
  for (const attr of decl.attributes ?? []) {
    const required = MUST_NOT_BE_NUMBER[attr.name];
    if (required && attr.type?.text === "number") {
      problems.push(
        `<${(decl.tagName ?? decl.name).toLowerCase()}>.${attr.name} is typed \`number\`; it must be ${required}`
      );
    }
  }
}

// 2b. Integer value spaces must be spelled `integer`, and float ones must stay
// `number` (see MUST_BE_INTEGER / MUST_STAY_NUMBER).
for (const [attrName, spec] of Object.entries(MUST_BE_INTEGER)) {
  const declaring = decls.filter((d) => (d.attributes ?? []).some((a) => a.name === attrName));
  const declaringNames = declaring.map((d) => d.name).sort();

  // Both directions of completeness. A missing element means the attribute silently
  // became unwritable there; an unrecorded extra one means a value space was added
  // without anyone checking the spec for it.
  const missing = spec.elements.filter((n) => !declaringNames.includes(n));
  if (missing.length > 0) {
    problems.push(
      `${missing.map((n) => `<${n.toLowerCase()}>`).join(", ")} should declare a \`${attrName}\` ` +
        `attribute ("${spec.value}") but does not — it is unwritable from Elm`
    );
  }
  const extra = declaringNames.filter((n) => !spec.elements.includes(n));
  if (extra.length > 0) {
    problems.push(
      `${extra.map((n) => `<${n.toLowerCase()}>`).join(", ")} declares \`${attrName}\` but is not in ` +
        `MUST_BE_INTEGER.${attrName}.elements in scripts/check-whatwg.mjs; record it (and check the ` +
        `WHATWG value column for that element) so its type is a decided fact`
    );
  }

  for (const decl of declaring) {
    const declared = decl.attributes.find((a) => a.name === attrName).type?.text;
    if (declared === "integer") continue;
    problems.push(
      `<${decl.name.toLowerCase()}>.${attrName} is typed \`${declared ?? "(untyped)"}\`; WHATWG's value column ` +
        `is "${spec.value}", so it must be \`integer\` (→ \`Int -> Attr\`). As \`number\` the setter is ` +
        `\`Float -> Attr\` and \`String.fromFloat\` can write "2.5"/"NaN"/"Infinity"/"1e+21" — none of which ` +
        `HTML's integer parser accepts, so the attribute falls back to its DEFAULT and the malformed value ` +
        `is silently discarded rather than reported`
    );
  }
}

for (const decl of decls) {
  for (const attr of decl.attributes ?? []) {
    const required = MUST_STAY_NUMBER[attr.name];
    if (required && attr.type?.text !== "number") {
      problems.push(
        `<${decl.name.toLowerCase()}>.${attr.name} is typed \`${attr.type?.text ?? "(untyped)"}\`; it must stay ` +
          `\`number\` (${required}) — narrowing it to \`integer\` would make a fractional value unwritable`
      );
    }
  }
}

// 2. type family
for (const name of TYPE_ELEMENTS) {
  const decl = decls.find((d) => d.name === name);
  if (!decl) {
    problems.push(`manifest is missing the <${name}> declaration entirely`);
    continue;
  }
  const hasType = (decl.attributes ?? []).some((a) => a.name === "type");
  if (!hasType) {
    problems.push(`<${name.toLowerCase()}> is missing the \`type\` content attribute (B4)`);
  }
}

// 3. The controlled roster's element scope AND capability rows, against the IDL table.
const controlled = config._controlled ?? {};
const renames = config._renames ?? {};
const tagOf = (decl) => (decl.tagName ?? decl.name).toLowerCase();

// The setter name an element's attribute ends up with: the `_renames` override if config
// gave one, else the attribute's own name (every `_controlled` name is a single lowercase
// word, so elm-cem's camel-casing is the identity here). Equal setter names mean equal
// capability rows — elm-cem moves `elmName` and `capName` together.
const setterNameFor = (decl, attrName) => renames[decl.name]?.[`attr:${attrName}`] ?? attrName;

for (const [attrName, entry] of Object.entries(controlled)) {
  const idl = CONTROLLED_IDL[attrName];
  const declaringDecls = decls.filter((d) => (d.attributes ?? []).some((a) => a.name === attrName));
  const declaringTags = declaringDecls.map(tagOf).sort();

  if (!idl) {
    problems.push(
      `config/_controlled.${attrName} has no IDL row in scripts/check-whatwg.mjs; ` +
        `add one (declared by ${declaringTags.join(", ") || "no element"}) so the property form is a checked decision`
    );
    continue;
  }

  // 3a. The table must cover every element that declares the attribute.
  for (const tag of declaringTags) {
    if (!(tag in idl)) {
      problems.push(
        `<${tag}> declares a \`${attrName}\` attribute but CONTROLLED_IDL.${attrName} has no entry for it; ` +
          `record its IDL type before deciding whether it belongs in the \`elements\` scope`
      );
    }
  }

  // 3b. A name-only entry is the bug this table exists to prevent.
  const scope = entry?.elements;
  if (!Array.isArray(scope) || scope.length === 0) {
    problems.push(
      `config/_controlled.${attrName} has no \`elements\` scope, so it claims the DOM-property form for ` +
        `every element declaring it (${declaringTags.join(", ")}). Name the elements whose LIVE state ` +
        `diverges from the content attribute`
    );
    continue;
  }

  // 3c. Every scoped element must survive a string property write.
  for (const tag of scope) {
    const type = idl[tag.toLowerCase()];
    if (type === undefined) {
      problems.push(
        `config/_controlled.${attrName}.elements names "${tag}", which has no CONTROLLED_IDL row ` +
          `(scope must be tag names: ${Object.keys(idl).join(", ")})`
      );
    } else if (!PROPERTY_SAFE_IDL.has(type)) {
      problems.push(
        `config/_controlled.${attrName}.elements includes <${tag}>, whose \`${attrName}\` IDL attribute is ` +
          `\`${type}\`. The generator writes \`Ir.property "${attrName}" (Json.Encode.string …)\` there, and Web IDL ` +
          `rejects a non-numeric string for that type — a TypeError thrown mid-patch, which kills the render loop. ` +
          `Drop <${tag}> from the scope and let it stay a reflected content attribute`
      );
    }
  }

  // 3d. And the part the scope cannot cover: every element whose IDL type is NOT
  // property-safe must have LEFT the shared capability row. The shared
  // `TypedHtml.Attributes.<attr>` setter is the property form (see the header), and it is
  // admitted by every element whose row still carries the field — in or out of scope. So
  // the row, not the scope, is what actually makes the bad call impossible, and the only
  // way off the row is a `_renames` entry giving the element its own setter name.
  const sharedSetter = attrName;
  for (const decl of declaringDecls) {
    const tag = tagOf(decl);
    const type = idl[tag];
    if (type === undefined || PROPERTY_SAFE_IDL.has(type)) continue;

    const setter = setterNameFor(decl, attrName);
    if (setter === sharedSetter) {
      problems.push(
        `<${tag}>.${attrName} is IDL \`${type}\`, but it still claims the shared \`${sharedSetter}\` capability row. ` +
          `\`TypedHtml.Attributes.${sharedSetter}\` writes \`Ir.property "${attrName}" (Json.Encode.string …)\`, and that ` +
          `row is what admits it — so scoping \`_controlled.${attrName}\` away from <${tag}> is not enough; the call still ` +
          `compiles and still ${type === "double" ? "throws a Web IDL TypeError mid-patch, killing the render loop" : "coerces to a wrong value silently"}. ` +
          `Add \`"${decl.name}": { "attr:${attrName}": "<newName>" }\` to config \`_renames\` so <${tag}> gets its own ` +
          `setter name and capability row, and the shared setter stops compiling against it`
      );
      continue;
    }

    // The rename is only half of it: without a matching `attrTypes` override the renamed
    // setter is still `String -> Attr`, i.e. the same unconstrained string under a new
    // name. The type is what makes the malformed value unconstructible.
    const required = REQUIRED_ATTR_TYPE[type];
    const elmType = required === "float" ? "Float" : "Int";
    const declared = config[decl.name]?.attrTypes?.[attrName];
    if (required && declared !== required) {
      problems.push(
        `<${tag}>.${attrName} is renamed to \`${setter}\` (good — it leaves the shared \`${sharedSetter}\` row) but ` +
          `config.${decl.name}.attrTypes.${attrName} is ${declared === undefined ? "absent" : `"${declared}"`}, not ` +
          `"${required}". IDL \`${type}\` means the setter must take an Elm \`${elmType}\`; left as a String it is the same ` +
          `unconstrained value under a new name, and \`String.from${elmType}\` is what makes a malformed \`${attrName}\` ` +
          `unconstructible`
      );
    }
  }
}

// ── Report ─────────────────────────────────────────────────────────────────
if (problems.length > 0) {
  console.error("check-whatwg: FAIL — curation has drifted below the WHATWG spec:");
  for (const p of problems) console.error(`  - ${p}`);
  process.exit(1);
}

// Everything the row check above proved has left the shared vocabulary, so the PASS line
// names it: this is the part a reader is most likely to assume is missing.
const diverged = Object.entries(controlled).flatMap(([attrName, _entry]) =>
  decls
    .filter((d) => (d.attributes ?? []).some((a) => a.name === attrName))
    .filter((d) => setterNameFor(d, attrName) !== attrName)
    .map((d) => `<${tagOf(d)}>.${attrName}→${setterNameFor(d, attrName)}:${CONTROLLED_IDL[attrName]?.[tagOf(d)]}`)
);

const integerPairs = Object.values(MUST_BE_INTEGER).reduce((n, s) => n + s.elements.length, 0);

// "Expressible" is now a checked claim about the emitted surface (gate 1d), so the
// PASS line has to be honest about the exceptions rather than reporting a bare 29: the
// kernel-blocked globals are curated, verified absent, and NOT expressible. Naming them
// here is what keeps a reader from having to re-derive why the count is short.
const blockedGlobals = WHATWG_GLOBALS.filter((g) => KERNEL_BLOCKED[g]);
const blockedNonGlobals = Object.keys(KERNEL_BLOCKED).filter((n) => !globals.has(n));

console.log(
  `check-whatwg: PASS — ${WHATWG_GLOBALS.length - blockedGlobals.length} of ${WHATWG_GLOBALS.length} ` +
    `WHATWG globals expressible, ${blockedGlobals.length} curated but kernel-blocked ` +
    `(${blockedGlobals.join(", ") || "none"}); ${blockedNonGlobals.length} other kernel-blocked ` +
    `attribute(s) declared and verified absent from the emitted surface ` +
    `(${blockedNonGlobals.join(", ") || "none"}); ` +
    `${Object.keys(MUST_NOT_BE_NUMBER).length} non-numeric value spaces not flattened to \`number\`; ` +
    `${Object.keys(MUST_BE_INTEGER).length} integer value spaces typed \`integer\` over ${integerPairs} ` +
    `element/attribute pairs, and ${Object.keys(MUST_STAY_NUMBER).length} genuine float(s) still \`number\`; ` +
    `type family present on ${TYPE_ELEMENTS.map((e) => e.toLowerCase()).join(", ")}; ` +
    `${Object.keys(controlled).length} controlled attribute(s) scoped to IDL-safe elements ` +
    `(${Object.entries(controlled)
      .map(([n, e]) => `${n}→${(e.elements ?? []).join("+")}`)
      .join(", ")}); ` +
    `${diverged.length} IDL-unsafe element(s) off the shared row (${diverged.join(", ") || "none"}).`
);
