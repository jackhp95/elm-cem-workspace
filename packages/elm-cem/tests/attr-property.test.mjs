#!/usr/bin/env node
// attribute-vs-property emission policy gate (issue #41 / NB2).
//
// The generator's bottom layer must map each attribute SPACE to the runtime-
// correct HtmlIr primitive. This ran wrong in three ways, each e2e-proven in a
// consumer (feedback-fab, compass-social):
//
//   NB2a — a False boolean setter rendered `Html.Attributes.classList []`,
//          which sets the `className` PROPERTY to "" and CLOBBERS any `class`
//          attribute on the same element. Its replacement,
//          `Html.Attributes.style "" ""`, was wrong for a second reason: it is
//          a real STYLE fact, so it stayed visible to `Test.Html.Query` and
//          forced a style-bucket diff on every node carrying a false boolean.
//          False must contribute NO fact at all — `Ir.none`.
//   NB2b — a boolean the web component OBSERVES (a `fieldName`-backed reflected
//          prop) emitted as `Ir.property "<prop>"` — but web components
//          observe ATTRIBUTES, so the property was invisible to them. Booleans
//          must emit as attribute present/absent regardless of `fieldName`.
//   NB2c — `value`/`checked`/`selected` emitted as content-attribute writes
//          (`Ir.attribute "value"`), but elm/html deliberately uses the DOM
//          PROPERTY for these so controlled inputs update after user input.
//          They must emit as `Ir.property`.
//   NB2d — a reflected NON-controlled scalar (a number the CEM links to a backing
//          property via `fieldName`) was emitted as `Ir.property`, invisible to
//          server-rendered markup. A reflected attribute syncs its property when
//          the ATTRIBUTE is set, so these must emit as `Ir.attribute` — SSR-
//          visible and still reflected (issue #41 follow-up).
//   NB2e — `muted` emitted as a content attribute, but the `muted` content
//          attribute sets only the element's DEFAULT muted state; the live state
//          is the `muted` IDL property. `Ir.attribute "muted" ""` is therefore
//          inert after first render — `muted True` never muted a playing <video>.
//          It must be `Ir.property "muted" (Json.Encode.bool …)`.
//   NB2f — a controlled property with NO backing content attribute on a given
//          element (<output>'s defaultValue is a property only; <textarea>'s
//          default value is its CHILD TEXT) must NOT get a `default*` companion
//          there. Config `propertyOnly` suppresses it — the alternative was
//          emitting an `Ir.attribute "value"` the browser ignores.
//   NB2g — the controlled roster is CONFIG (`_controlled`), not a hardcoded list
//          in the emitter, and one element can opt back out with
//          `attrForm: { "<attr>": "attribute" }`. An opted-out attribute writes
//          the content attribute and gets no `default*` companion (that would be
//          two setters for one fact), and its docs must not promise a live
//          property.
//   NB2h — the roster is PER-ELEMENT (`elements`), not per-NAME. A name-only entry
//          is a claim about `HTMLElement`, and `value` is not one attribute: seven
//          native elements declare a `value` content attribute at THREE IDL types
//          (`DOMString` on button/data/option, `long` on li, `double` on
//          meter/progress). Only `<input>` has a live value that DIVERGES from its
//          content attribute; the other six reflect. So:
//            * an out-of-scope element writes the content attribute and earns no
//              `default*` companion (HTML gives `HTMLOptionElement` /
//              `HTMLButtonElement` no `defaultValue` either);
//            * an in-scope element keeps the live property AND its own companion;
//            * the shared `<Lib>.Attributes` canonical takes the PROPERTY form — see
//              NB2i for why that is the safe half of the split, not the reckless one —
//              and each content-attribute element keeps a local setter whose docs name
//              the live one;
//            * a `_variants` setter follows its base's per-element form.
//   NB2i — the ELEMENT SCOPE is not enough on its own, and this is the case that
//          proves it. `Ir.property "value" (Json.Encode.string "abc")` against the
//          `double` of `<progress>`/`<meter>` is a Web IDL **TypeError**, thrown inside
//          virtual-dom's `applyFacts` — i.e. mid-patch, so it aborts the patch and takes
//          the whole Elm render loop down, not just that node. Measured in a real Elm
//          app: the exception escapes the animation-frame draw callback, Elm
//          re-schedules, and it re-throws ~60 times a second, indefinitely, on a page
//          that is otherwise idle — a permanently stale DOM with no Elm crash screen.
//          (`<li>` is `long`, whose ToInt32 conversion silently yields 0 instead. Wrong
//          but not fatal.)
//
//          Scoping fixes the element's OWN module. It does not fix the shared
//          `<Lib>.Attributes` setter, which is an open producer admitted by every
//          element whose row carries the field — so as long as a `<progress>` keeps the
//          `value` capability row, `A.value "abc"` on one still compiles and still
//          crashes. The fix is to leave the ROW: `_renames` moves `elmName` and
//          `capName` together, so a differently-named setter is a different capability,
//          and `attrTypes` gives it the type its value space actually has. The bad call
//          then does not compile. Avoiding the crash and making it unrepresentable are
//          different things, and only the second one holds.
//
// Companion policy (`default*`): HTML's own IDL already models the live/default
// split (`value`/`defaultValue`, `checked`/`defaultChecked`,
// `selected`/`defaultSelected`, `muted`/`defaultMuted`). The plain setter is the
// live DOM property; `default<Name>` writes the content attribute — the initial
// state, and the only form that serializes to server-rendered markup. The
// companion SHARES the base capability row (`defaultValue` claims
// `{ c | value : Supported }`); minting a new row would grow every element's
// `Attrs` record for no safety gain.
//
// This test runs the REAL CLI on a fixture carrying one attribute per space and
// asserts the emitted form. Every assertion FAILS on the pre-fix output, so a
// regression cannot slip back in. Run standalone: `node tests/attr-property.test.mjs`.
// Wired into `npm test`.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const elmFormat = path.join(repo, "node_modules", ".bin", "elm-format");
const cem = path.join(here, "attr-property", "probe.cem.json");
const config = path.join(here, "attr-property", "probe.config.json");

let failures = 0;
const check = (ok, msg) => {
  if (ok) console.log(`  PASS  ${msg}`);
  else {
    console.error(`  FAIL  ${msg}`);
    failures += 1;
  }
};

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-attr-prop-"));
const outSrc = path.join(work, "src");
fs.mkdirSync(outSrc, { recursive: true });

try {
  execFileSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${cem}`,
      `--config-from=${config}`,
      `--output=${outSrc}`,
    ],
    { stdio: "pipe" },
  );
} catch (e) {
  console.error(`attr-property: FAIL — generator crashed: ${e.stdout || ""}${e.stderr || ""}${e.message}`);
  process.exit(1);
}

// elm-format so the assertions match the normalized (committed) form.
execFileSync(elmFormat, [outSrc, "--yes"], { stdio: "pipe" });

const walk = (dir) =>
  fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const full = path.join(dir, e.name);
    return e.isDirectory() ? walk(full) : full.endsWith(".elm") ? [full] : [];
  });

const files = walk(outSrc);
const all = Object.fromEntries(files.map((f) => [path.relative(outSrc, f), fs.readFileSync(f, "utf8")]));
const attrs = all[path.join("Probe", "Attributes.elm")];

if (!attrs) {
  console.error("attr-property: FAIL — generator emitted no Probe/Attributes.elm");
  process.exit(1);
}

// Cross-cutting: neither rejected no-op may EVER appear in an emitted file.
//   `classList []`            — sets className to "" and clobbers a sibling class.
//   `style "" ""`             — a real STYLE fact: visible to Test.Html.Query and
//                               enough to force a style-bucket diff on every node
//                               carrying a false boolean.
// The only correct false branch is `Ir.none`, which contributes no fact at all.
for (const [needle, label] of [
  ["classList []", `"classList []"`],
  ['Html.Attributes.style "" ""', `the style "" "" no-op`],
  ["import Html.Attributes", "an Html.Attributes import"],
]) {
  const hits = Object.entries(all)
    .filter(([, src]) => src.includes(needle))
    .map(([f]) => f);
  check(hits.length === 0, `no ${label} in any emitted file${hits.length ? ` (found in ${hits.join(", ")})` : ""}`);
}

// NB2a — plain boolean (no fieldName): present/absent, ABSENT false branch.
check(
  /handle value_ =\s*\n\s*if value_ then\s*\n\s*Ir\.attribute "handle" ""\s*\n\s*\n\s*else\s*\n\s*Ir\.none/.test(attrs),
  "NB2a: plain boolean `handle` emits attribute present/absent with an absent false branch",
);

// NB2b — reflected (fieldName-backed) boolean the web component observes: MUST be
// an attribute, NOT `Ir.property "open"`.
check(!attrs.includes('Ir.property "open"'), "NB2b: reflected boolean `open` does NOT emit as a JS property");
check(
  /open value_ =\s*\n\s*if value_ then\s*\n\s*Ir\.attribute "open" ""/.test(attrs),
  "NB2b: reflected boolean `open` emits as an observable attribute (present/absent)",
);

// NB2c — controlled form props emit as DOM properties.
check(attrs.includes('value value_ =\n    Ir.property "value" (Json.Encode.string value_)'), "NB2c: `value` emits as a string DOM property");
check(!/value =\n\s*Ir\.attribute "value"/.test(attrs), "NB2c: `value` is NOT a content-attribute write");
check(attrs.includes('checked value_ =\n    Ir.property "checked" (Json.Encode.bool value_)'), "NB2c: `checked` emits as a bool DOM property");
check(attrs.includes('selected value_ =\n    Ir.property "selected" (Json.Encode.bool value_)'), "NB2c: `selected` emits as a bool DOM property");
// The BASE setter must not be a content-attribute write. (`Ir.attribute "checked"`
// does now appear in the file — as the `defaultChecked` COMPANION, which is exactly
// what that content attribute means. So this has to name the setter, not the file.)
check(
  !/\nchecked value_ =\s*\n\s*if value_ then/.test(attrs) && !/\nchecked value_ =\s*\n\s*Ir\.attribute/.test(attrs),
  "NB2c: `checked` is NOT a content-attribute write",
);
check(
  !/\nselected value_ =\s*\n\s*if value_ then/.test(attrs) && !/\nselected value_ =\s*\n\s*Ir\.attribute/.test(attrs),
  "NB2c: `selected` is NOT a content-attribute write",
);

// NB2d — a reflected NON-controlled number emits the ATTRIBUTE: it serializes to
// SSR and (being reflected) syncs the backing property, so a separate
// `Ir.property` write is redundant and left the value invisible to server-
// rendered markup (issue #41 follow-up). Only the controlled trio above keeps the
// property form.
check(
  attrs.includes('count value_ =\n    Ir.attribute "count" (String.fromFloat value_)'),
  "NB2d: reflected numeric `count` emits as an attribute (SSR-visible, reflects to the property)",
);
check(!attrs.includes('Ir.property "count"'), "NB2d: reflected numeric `count` is NOT a DOM property");

// NB2e — `muted` is a controlled property, NOT a present/absent attribute. The
// content attribute is only `defaultMuted`, so the attribute form is inert after
// first render.
check(attrs.includes('muted value_ =\n    Ir.property "muted" (Json.Encode.bool value_)'), "NB2e: `muted` emits as a bool DOM property");
check(
  !/muted value_ =\s*\n\s*if value_ then\s*\n\s*Ir\.attribute "muted"/.test(attrs),
  "NB2e: `muted` is NOT a present/absent content-attribute write",
);

// The `default*` companions: the CONTENT-attribute half, sharing the BASE
// capability row (a new `default*` row field would grow every element's Attrs
// record for no safety gain).
for (const [name, base, body] of [
  ["defaultValue", "value", 'defaultValue =\n    Ir.attribute "value"'],
  ["defaultChecked", "checked", 'defaultChecked value_ =\n    if value_ then\n        Ir.attribute "checked" ""\n\n    else\n        Ir.none'],
  ["defaultSelected", "selected", 'defaultSelected value_ =\n    if value_ then\n        Ir.attribute "selected" ""\n\n    else\n        Ir.none'],
  ["defaultMuted", "muted", 'defaultMuted value_ =\n    if value_ then\n        Ir.attribute "muted" ""\n\n    else\n        Ir.none'],
]) {
  check(attrs.includes(body), `companion: \`${name}\` writes the \`${base}\` CONTENT attribute`);
  check(
    new RegExp(`^${name} : [^\\n]* -> Attr \\{ c \\| ${base} : Supported \\} msg$`, "m").test(attrs),
    `companion: \`${name}\` SHARES the \`${base}\` capability row (no new row minted)`,
  );
  check(!attrs.includes(`Ir.property "${name}"`), `companion: \`${name}\` is NOT a property write`);
}

// The resync caveat. elm/virtual-dom's controlled-input machinery is hardcoded to
// the names `value`/`checked`, so a `selected`/`muted` property whose model value
// has not changed is skipped forever: the property form fixes INERTNESS, not
// RESYNC. The docs must say so and name the event to listen to.
for (const [name, ev] of [
  ["selected", "change"],
  ["muted", "volumechange"],
]) {
  const block = attrs.slice(0, attrs.indexOf(`\n${name} : `));
  const docStart = block.lastIndexOf("{-|");
  const docText = block.slice(docStart);
  check(/cannot RESYNC/.test(docText), `caveat: \`${name}\` documents that it cannot resync`);
  check(docText.includes(`a \\\`${ev}\\\` handler`) || docText.includes(`\`${ev}\` handler`), `caveat: \`${name}\` names the \`${ev}\` handler to keep the model in sync`);
}
for (const name of ["value", "checked"]) {
  const block = attrs.slice(0, attrs.indexOf(`\n${name} : `));
  const docText = block.slice(block.lastIndexOf("{-|"));
  check(!/cannot RESYNC/.test(docText), `caveat: \`${name}\` does NOT carry the caveat (virtual-dom DOES resync these two)`);
}

// NB2f — `propertyOnly` suppresses the companion on the element whose live property
// has no backing content attribute, while the sibling that DOES have one keeps it.
const output = all[path.join("Probe", "Output.elm")];
const widget = all[path.join("Probe", "Widget.elm")];
check(!!output && output.includes("value : String -> Attr"), "NB2f: `propertyOnly` element still gets the live property setter");
check(!!output && !output.includes("defaultValue"), "NB2f: `propertyOnly` element gets NO defaultValue companion");
check(!!widget && widget.includes("defaultValue ="), "NB2f: a sibling element WITH a content attribute keeps defaultValue");

// NB2g — the per-component `attrForm` opt-out. `pressed` is in `_controlled` but
// Knob opts back out: attribute form, no companion, and no "live property" promise.
check(
  /pressed value_ =\s*\n\s*if value_ then\s*\n\s*Ir\.attribute "pressed" ""/.test(attrs),
  "NB2g: an `attrForm: attribute` opt-out emits the content attribute, not a property",
);
check(!attrs.includes("defaultPressed"), "NB2g: an opted-out attribute gets NO default* companion");
check(!attrs.includes('Ir.property "pressed"'), "NB2g: an opted-out attribute is NOT a DOM property");
{
  const block = attrs.slice(0, attrs.indexOf("\npressed : "));
  const docText = block.slice(block.lastIndexOf("{-|"));
  check(!/LIVE DOM property/.test(docText), "NB2g: an opted-out attribute's docs do NOT promise a live DOM property");
}

// NB2h — the `_controlled` ELEMENT SCOPE. `reading` is declared by wc-widget, wc-gauge
// AND wc-dial but scoped to `["wc-widget"]`. wc-widget stands in for <input> (live value,
// dirty-value flag), wc-gauge for <button>/<data>/<option> (reflected DOMString), and
// wc-dial for <progress>/<meter>/<li> (numeric IDL type) — see NB2i for that one.
const gauge = all[path.join("Probe", "Gauge.elm")];
const dial = all[path.join("Probe", "Dial.elm")];

// The in-scope element's setter reaches the live property. It DELEGATES, because the
// shared canonical is the property form and therefore already agrees with it — the
// delegation is proof of the agreement, not a shortcut.
check(!!widget && /\nreading : String -> Attr \{ c \| reading : Supported \} msg\nreading =\n    A\.reading\n/.test(widget), "NB2h: the in-scope element's `reading` delegates to the shared canonical");
check(!!widget && widget.includes('defaultReading =\n    A.defaultReading'), "NB2h: the in-scope element keeps its `default*` companion");

// The out-of-scope REFLECTING element writes the CONTENT attribute and earns no
// companion. It cannot delegate: the canonical is the property form, and delegating
// would compile and quietly stop serializing (`divergesFromCanonical`).
check(!!gauge && !gauge.includes("Ir.property"), "NB2h: the out-of-scope element writes NO DOM property at all");
check(!!gauge && gauge.includes('reading value_ =\n    Ir.attribute "reading" value_'), "NB2h: the out-of-scope element keeps a LOCAL content-attribute setter, not a delegation");
check(!!gauge && !gauge.includes("defaultReading"), "NB2h: the out-of-scope element gets NO default* companion");
check(!!gauge && /reading : String -> Attr \{ c \| reading : Supported \} msg/.test(gauge), "NB2h: the out-of-scope element still has a `reading` setter");
// …and so does its builder pipe, which INLINES the local body rather than piping
// `A.reading`. Same reason the setter cannot delegate: the shared canonical is the
// property form, and `divergesFromCanonical` is consulted at every delegation site.
check(
  !!gauge && /withReading value_ =\s*\n\s*B\.withAttribute \(Ir\.attribute "reading" value_\)/.test(gauge),
  "NB2h: the out-of-scope element's builder pipe writes the attribute form too, inlined rather than delegated",
);
{
  const block = gauge.slice(0, gauge.indexOf("\nreading : "));
  const docText = block.slice(block.lastIndexOf("{-|"));
  check(/CONTENT attribute/.test(docText), "NB2h: the reflecting element's docs say it writes the content attribute");
  check(
    docText.includes("Probe.Widget.reading") && /<wc-widget>/.test(docText),
    "NB2h: the reflecting element's docs name the element and the setter that ARE live",
  );
}

// The shared canonical: PROPERTY form. It is the form that cannot go INERT on a
// controlled element (a `setAttribute` write stops moving the live value once the
// dirty-value flag is set — issue #41, on the most-used setter in the library), and it
// is safe here only because every element still on this row can survive a string
// property write; the one that cannot has left the row entirely (NB2i). Being the
// property form, it also earns the `default*` companion beside it.
check(attrs.includes('reading value_ =\n    Ir.property "reading" (Json.Encode.string value_)'), "NB2h: the shared canonical takes the PROPERTY form when the brand's forms are split");
check(!/\nreading value_ =\n\s*Ir\.attribute "reading"/.test(attrs), "NB2h: the shared canonical is NOT a content-attribute write");
check(attrs.includes('defaultReading =\n    Ir.attribute "reading"'), "NB2h: the shared canonical earns its `default*` companion (the serializing half)");
check(
  new RegExp("^defaultReading : String -> Attr \\{ c \\| reading : Supported \\} msg$", "m").test(attrs),
  "NB2h: the companion SHARES the base capability row",
);
{
  const block = attrs.slice(0, attrs.indexOf("\nreading : "));
  const docText = block.slice(block.lastIndexOf("{-|"));
  check(/LIVE DOM property/.test(docText), "NB2h: the shared canonical's docs say it writes the live DOM property");
  check(/`defaultReading`/.test(docText), "NB2h: the shared canonical's docs name the serializing companion");
}

// A `_variants` setter writes the SAME fact as its base, so it follows the base's
// per-element form. On the property side it must go through `Json.Encode.string`, never
// `.float`: virtual-dom compares property facts by identity against the previously
// organized raw JS value, so a fact alternating between number and string under one
// property name would make every diff a false positive.
check(
  attrs.includes('readingAsNumber value_ =\n    Ir.property "reading" (Json.Encode.string (String.fromFloat value_))'),
  "NB2h: the variant follows its base to the PROPERTY form on the shared canonical, encoded as a string",
);
check(
  !attrs.includes("Json.Encode.float"),
  "NB2h: the property-form variant never writes a number fact under a property name virtual-dom diffs by identity",
);
check(
  !!gauge && gauge.includes('readingAsNumber value_ =\n    Ir.attribute "reading" (String.fromFloat value_)'),
  "NB2h: the variant follows its base to the ATTRIBUTE form on the reflecting element",
);

// NB2i — CAPABILITY-ROW DIVERGENCE. The scope above fixed wc-dial's own module, and that
// is not enough: `Probe.Attributes.reading` is an open producer admitted by every element
// whose row carries `reading : Supported`, so while wc-dial stayed on that row
// `A.reading "abc"` on one compiled — and against a `double` IDL attribute that is a Web
// IDL TypeError thrown mid-patch. So wc-dial leaves the row: `_renames` moves `elmName`
// and `capName` together, `attrTypes` gives the setter the type its value space has, and
// the bad call stops compiling.
check(!!dial && /^type alias Attrs =\n(?:.*\n)*?    \}$/m.test(dial), "NB2i: the diverged element still emits a closed Attrs row");
{
  const row = dial.slice(dial.indexOf("type alias Attrs ="), dial.indexOf("}", dial.indexOf("type alias Attrs =")));
  check(/readingNumeric : Supported/.test(row), "NB2i: the diverged element's Attrs row carries `readingNumeric`");
  check(
    !/\breading : Supported/.test(row),
    "NB2i: the diverged element's Attrs row has NO `reading` field, so `A.reading` on it is a COMPILE error",
  );
}
check(
  !!dial && /^readingNumeric : Float -> Attr \{ c \| readingNumeric : Supported \} msg$/m.test(dial),
  "NB2i: the diverged setter claims its OWN capability row, not the base's",
);
check(
  attrs.includes('readingNumeric value_ =\n    Ir.attribute "reading" (String.fromFloat value_)'),
  "NB2i: the diverged setter writes the CONTENT attribute, typed as its value space really is",
);
check(!!dial && !dial.includes("Ir.property"), "NB2i: the diverged element writes NO DOM property at all");
check(!!dial && !/\breading :/.test(dial), "NB2i: the diverged element has no `reading` setter to confuse with the shared one");
// And it gets no `_variants` setter either: `base` names a SETTER, so a rename opts the
// element out of that vocabulary. A `readingAsNumber : Float` beside an already-Float
// `readingNumeric` would be two names for one fact, claiming a row it does not own.
check(!!dial && !dial.includes("readingAsNumber"), "NB2i: the diverged element gets NO `_variants` setter (its base setter name is gone)");
check(
  !!dial && /withReadingNumeric value_ =\s*\n\s*B\.withAttribute \(A\.readingNumeric value_\)/.test(dial),
  "NB2i: the diverged element's builder pipe consumes the diverged capability",
);

fs.rmSync(work, { recursive: true, force: true });

// The #33 guard: `AsProperty` names its property `fieldName` ?? `htmlName` VERBATIM,
// never a camel-cased guess. A hyphenated name therefore has no same-named IDL
// property, so asking for the property form on one must FAIL LOUD rather than emit
// `Ir.property "aria-label"` — an inert own-property nobody observes.
{
  const badWork = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-attr-prop-bad-"));
  const badConfig = path.join(badWork, "config.json");
  fs.writeFileSync(
    badConfig,
    JSON.stringify({ _phantom: true, _brand: "Probe", _controlled: { "aria-pressed": {} }, Widget: {} }),
  );
  const badCem = path.join(badWork, "probe.cem.json");
  const manifest = JSON.parse(fs.readFileSync(cem, "utf8"));
  manifest.modules[0].declarations[0].attributes.push({
    name: "aria-pressed",
    type: { text: "boolean" },
    description: "Hyphenated: has no same-named IDL property.",
  });
  fs.writeFileSync(badCem, JSON.stringify(manifest));

  let failedLoudly = false;
  let message = "";
  try {
    execFileSync(
      "node",
      [path.join(repo, "bin", "elm-cem.js"), `--flags-from=${badCem}`, `--config-from=${badConfig}`, `--output=${path.join(badWork, "src")}`],
      { stdio: "pipe" },
    );
  } catch (e) {
    failedLoudly = true;
    message = `${e.stdout || ""}${e.stderr || ""}`;
  }
  check(failedLoudly, "#33 guard: the PROPERTY form on a hyphenated attribute fails the run");
  check(/aria-pressed/.test(message) && /#33/.test(message), "#33 guard: the error names the attribute and issue #33");
  fs.rmSync(badWork, { recursive: true, force: true });
}

// NB2h fail-loud guards. The element scope is only worth having if it is CHECKED: a
// scope that silently matches nothing reverts the attribute to the content-attribute
// form with no diagnostic anywhere, which for `value` on an `<input>` is issue #41
// straight back. Same for the contradiction of asking for `propertyOnly` outside it.
{
  const runBad = (config) => {
    const badWork = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-attr-prop-scope-"));
    const badConfig = path.join(badWork, "config.json");
    fs.writeFileSync(badConfig, JSON.stringify(config));
    let message = "";
    let failedLoudly = false;
    try {
      execFileSync(
        "node",
        [path.join(repo, "bin", "elm-cem.js"), `--flags-from=${cem}`, `--config-from=${badConfig}`, `--output=${path.join(badWork, "src")}`],
        { stdio: "pipe" },
      );
    } catch (e) {
      failedLoudly = true;
      message = `${e.stdout || ""}${e.stderr || ""}`;
    }
    fs.rmSync(badWork, { recursive: true, force: true });
    return { failedLoudly, message };
  };

  const typo = runBad({ _phantom: true, _brand: "Probe", _controlled: { reading: { elements: ["wc-widgt"] } } });
  check(typo.failedLoudly, "NB2h guard: an `elements` scope naming an unknown element fails the run");
  check(/wc-widgt/.test(typo.message), "NB2h guard: the error names the unmatched element");

  const wrongElement = runBad({ _phantom: true, _brand: "Probe", _controlled: { reading: { elements: ["wc-knob"] } } });
  check(wrongElement.failedLoudly, "NB2h guard: an `elements` scope naming an element that does not declare the attribute fails the run");
  check(/wc-knob/.test(wrongElement.message) && /reading/.test(wrongElement.message), "NB2h guard: the error names the element and the attribute");

  const emptyScope = runBad({ _phantom: true, _brand: "Probe", _controlled: { reading: { elements: [] } } });
  check(emptyScope.failedLoudly, "NB2h guard: an EMPTY `elements` list fails the run rather than disabling the entry");

  const contradiction = runBad({
    _phantom: true,
    _brand: "Probe",
    _controlled: { reading: { companion: "defaultReading", elements: ["wc-widget"] } },
    Gauge: { propertyOnly: ["reading"] },
  });
  check(contradiction.failedLoudly, "NB2h guard: `propertyOnly` on an element OUTSIDE the scope fails the run");
  check(
    /propertyOnly/.test(contradiction.message) && /Gauge/.test(contradiction.message),
    "NB2h guard: the contradiction error names `propertyOnly` and the element",
  );

  // A split form across two elements of ONE home module is unrepresentable, exactly as a
  // split TYPE is (the `datetime` guard). A home emits one re-exported setter per
  // attribute name, so `dedupBy_` would keep whichever the manifest lists first and
  // publish its form for both — and the loser gets a setter that writes the wrong kind
  // of fact with nothing for the type checker to object to.
  const mixedHome = runBad({
    _phantom: true,
    _brand: "Probe",
    _controlled: { reading: { elements: ["wc-widget"] } },
    Widget: { home: "Dials" },
    Gauge: { home: "Dials" },
  });
  check(mixedHome.failedLoudly, "NB2h guard: two elements of ONE home at different forms fails the run");
  check(
    /FORM CONFLICT/.test(mixedHome.message) && /Probe\.Dials/.test(mixedHome.message) && /Gauge : attribute/.test(mixedHome.message) && /Widget : property/.test(mixedHome.message),
    "NB2h guard: the FORM CONFLICT error names the module and each member's form",
  );
}

if (failures > 0) {
  console.error(`\nattr-property: FAIL — ${failures} assertion(s) failed`);
  process.exit(1);
}
console.log(`\nattr-property: OK — every attribute space emits the runtime-correct HtmlIr primitive.`);
