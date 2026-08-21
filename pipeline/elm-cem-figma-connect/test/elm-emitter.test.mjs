// Task B3: the profile-local "Elm" Code Connect emitter + its facts extraction.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/elm-emitter.test.mjs
//
// HERMETIC: this test never reads the live elm-m3e checkout. The button's
// facts are PINNED into test/fixtures/elm-facts.button.json (a copy of the
// button slice of the committed profiles/m3-kit/elm-facts.json); the test
// asserts the committed facts still match that pin, so a facts regeneration
// that changes a name fails LOUDLY here rather than silently drifting the
// golden expectations.
//
// FIX ROUND 1 (facts-purity gaps closed post-review of commit 2a87d09): two
// previously UNVERIFIED scaffolding identifiers were run through the SAME
// measured exposing-list verification the token/setter machinery already
// used: the barrel `text` helper and the `Action.none` helper. Verifying
// against the real elm-m3e checkout turned up a genuine finding: the root
// barrel module (M3e.elm) does NOT expose a bare "text" value (elm-m3e's
// M3e/Element.elm doc comment says it plainly: "There is no library-defined
// text constructor: text/link/label are config-declared userland seams.").
// `Action.none` DOES verify (exposed by M3e/Action.elm's own exposing list),
// and button's setters (shape/size/variant/type_) all verify against
// M3e.Button's own exposing list. That round correctly concluded the golden
// spike's "M3e.text" is stale — but then over-corrected: it recorded
// `textFn:null` and made emitEntry/emitter.emit THROW for any entry needing
// text content (fail-loud, mirroring resolveToken), which left button —
// the only live entry — unable to emit at all.
//
// FIX ROUND 2 (this round): the "no library export" finding was correct, but
// throwing was wrong — text content in post-review elm-m3e has a DIFFERENT,
// correct source: the userland SEAM convention. Every button/text example in
// elm-m3e's own config/examples.generated.json, and docs/DESIGN.md §4, call
// `Kit.text "..."` — `Kit` is the project's userland seam module (elm-m3e's
// docs/kit/Kit.elm is the community-blessed example of that shape; a real
// consuming project supplies its own). This is recorded as elm-facts.json's
// top-level `textSeam` fact with EXPLICIT provenance (corroborated against
// elm-m3e's own docs/examples, NOT verified via an `exposing` list — there is
// no library module to check one against, by design) so it can never be
// mistaken for an unverified *library* name. The per-component `textFn` field
// is gone; `emitEntry`/`emitter.emit` now SUCCEED for button, emitting
// `Kit.text "${label}"` + `import Kit`.
//
// The golden fixture profiles/m3-kit/fixtures/M3eButton.elm.figma.ts is a
// pre-review spike and stays UNCHANGED — its stale `M3e.Token.md`/`.xs` size
// tokens AND its stale `M3e.text` call both document the same lesson: names
// from before the review-2026-07 rename (or from before the seam convention
// was understood) are wrong by construction, which is exactly why B3 never
// diffs generated output against the golden verbatim.
//
// The cardinal B3 property under test: EVERY Elm LIBRARY name (module,
// setter, token, Action.none) is facts-derived and VERIFIED against
// elm-m3e's own exposing lists — never guessed, unverified -> throw. The one
// exception is the text SEAM, which is sourced-from-documented-convention
// (marked as such) rather than exposing-list-verified, because it names a
// userland module the library deliberately does not export.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { emitEntry, emitter, _internal } from "../profiles/m3-kit/emitters/elm.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const profileDir = path.join(repoRoot, "profiles", "m3-kit");

const buttonEntry = JSON.parse(
  fs.readFileSync(path.join(profileDir, "correspondence.json"), "utf8")
).find((e) => e.cemTag === "m3e-button");

const goldenPath = path.join(profileDir, "fixtures", "M3eButton.elm.figma.ts");
const golden = fs.readFileSync(goldenPath, "utf8");

const buttonComp = _internal.FACTS.components["m3e-button"];

// A minimal config exercising the pure emitEntry directly (the golden's own
// fileKey + fileName, so the `// url=` line reproduces the golden's URL).
const config = {
  fileKey: "KujuFlfJSwHI6ua1b7RZvL",
  fileName: "Material 3 Design Kit (Community)",
  surface: "top",
};

// ── facts provenance (M3.a: Face C's provenance object, not elmM3eCommit) ────
test("Face C carries a provenance stamp naming the producer + the brand it generated into", () => {
  assert.equal(_internal.FACTS.provenance.producer.elmCem.version, "0.3.1");
  assert.equal(_internal.FACTS.provenance.brand.name, "elm-m3e");
});

// ── the facts-derived token names (NOT the golden's stale short names) ───────
test("size/shape tokens are FACTS-derived, not the golden's stale md/xs", () => {
  const size = buttonComp.enums.size.values;
  const shape = buttonComp.enums.shape.values;

  // The measured truth (post-review-2026-07): long camelCase size ctors.
  assert.deepEqual(
    size.map((v) => v.token).sort(),
    [
      "M3e.Values.extraLarge",
      "M3e.Values.extraSmall",
      "M3e.Values.large",
      "M3e.Values.medium",
      "M3e.Values.small",
    ]
  );
  assert.deepEqual(shape.map((v) => v.token).sort(), ["M3e.Values.rounded", "M3e.Values.square"]);

  // And explicitly NOT the pre-review short names (post-rename the module is
  // M3e.Values; the long camelCase ctors above are the measured truth).
  for (const stale of ["M3e.Values.xs", "M3e.Values.sm", "M3e.Values.md", "M3e.Values.lg", "M3e.Values.xl"]) {
    assert.ok(
      !size.some((v) => v.token === stale),
      `facts must not carry the stale short token ${stale}`
    );
  }
});

test("the golden fixture DOES carry the stale names (documents the divergence)", () => {
  // Sanity check that the golden really is stale — the whole reason the golden
  // structural comparison would need to compare MODULO names rather than
  // verbatim. The golden's "M3e.text" is ALSO stale (Fix 1's finding below),
  // not just the short token names.
  assert.match(golden, /M3e\.Token\.md\b/);
  assert.match(golden, /M3e\.Token\.xs\b/);
  assert.match(golden, /M3e\.text\b/);
});

// ── Fix round: verify scaffolding identifiers against exposing lists ────────
test("M3.a: text content is profile config (elm.textSeam), not a bundle field — Face C has no textFn/textSeam fact at all", () => {
  // Face C carries no per-component `textFn` and no top-level `textSeam` —
  // userland seams aren't CEM-derived, so a producer has no way to measure
  // one (see this file's module doc / profiles/m3-kit/profile.json's
  // elm.textSeam comment).
  assert.equal(buttonComp.textFn, undefined);
  assert.equal(_internal.FACTS.textSeam, undefined);
});

test("Fix 1: actionModule DOES verify — Action.none is exposed by M3e/Action.elm's own exposing list", () => {
  assert.equal(buttonComp.actionModule, "M3e.Action");
});

test("button's setters are keyed by CEM ATTRIBUTE name (M3.a correction), covering enum AND primitive attrs", () => {
  // Face C's `setters` map is keyed by the CEM attribute name (docs/facts-bundle
  // /schema.json's faceCComponent.setters), not the Elm identifier — the old
  // bundle keyed this map by the ELM name (`type_: "type_"`), which
  // setterOf's actual lookup (by CEM attr name from correspondence.json) never
  // matched whenever the two names differed (`type`/`disabled-interactive`).
  assert.deepEqual(buttonComp.setters, {
    shape: "shape",
    size: "size",
    type: "type_",
    variant: "variant",
    disabled: "disabled",
    "disabled-interactive": "disabledInteractive",
    download: "download",
    href: "href",
    name: "name",
    rel: "rel",
    selected: "selected",
    target: "target",
    toggle: "toggle",
    value: "value",
  });
  // None recorded null (unverified) for button.
  assert.ok(Object.values(buttonComp.setters).every((v) => v !== null));
  // `selected` IS present in Face C's setters map (Face C does not exclude
  // slot-overlapping attrs from it), but the emitter's OWN slotAttr() check
  // (against slotSetters) still filters it out of every emitted axis/fixed
  // setter line before setterOf ever runs — see the "selected renders as a
  // slot" tests below. `toggle` (a real Bool attr) stays a plain setter.
  assert.ok(buttonComp.slotSetters.includes("selected"), "selected recorded as a slot");
});

// ── emitEntry now SUCCEEDS for button, rendering Kit.text + import Kit ──────
test("emitEntry succeeds and renders Kit.text (the correct post-review idiom, not the stale M3e.text)", () => {
  const files = emitEntry(buttonEntry, config);
  assert.ok(files.length > 0);
  for (const { contents } of files) {
    // The header note mentions the stale "M3e.text" name in prose (for
    // traceability); what must NOT appear is an actual M3e.text CALL in the
    // rendered figma.code example.
    assert.doesNotMatch(contents, /\[ M3e\.text /);
    // Invariant (amendment A2 + conditional seam import): a file imports Kit
    // iff its example actually calls Kit.text. No-text 2nd-sets render []
    // children and import no seam.
    assert.equal(
      /"import Kit"/.test(contents),
      /Kit\.text /.test(contents),
      "a file imports Kit iff it calls Kit.text"
    );
  }
  // The primary axis-grid sets prop-interpolate the label via the Kit.text
  // idiom; post-ctor-rename m3e-button's top surface is `record-double-list`, so
  // the label lands in the record's `content =` (not a `[ … ]` child list). The
  // appended representative-example 2nd-sets carry no ${label} binding.
  const labelFiles = files.filter((f) => /content = Kit\.text "\$\{label\}"/.test(f.contents));
  assert.ok(labelFiles.length > 0, "the primary sets render the Kit.text \"${label}\" idiom");
});

test("emitter.emit also succeeds via the same code path", () => {
  const files = emitter.emit(buttonEntry, {
    profile: { fileKey: config.fileKey, raw: { elm: { elmSurface: "top" } } },
    figma: { data: { meta: { fileName: config.fileName } } },
  });
  assert.ok(files.length > 0);
  assert.match(files[0].contents, /Kit\.text "\$\{label\}"/);
  assert.match(files[0].contents, /"import Kit"/);
});

test("emitter.emit honors a profile-configured elm.textSeam override", () => {
  const files = emitter.emit(buttonEntry, {
    profile: { fileKey: config.fileKey, raw: { elm: { elmSurface: "top", textSeam: "MyKit" } } },
    figma: { data: { meta: { fileName: config.fileName } } },
  });
  assert.match(files[0].contents, /MyKit\.text "\$\{label\}"/);
  assert.match(files[0].contents, /"import MyKit"/);
});

test("every surface renders Kit.text consistently (the seam is not per-surface)", () => {
  // Post-review m3e-button emits only at the surfaces whose per-surface modules
  // exist (measured into elm-facts); iterate those, not a fixed five.
  for (const surface of Object.keys(_internal.FACTS.components["m3e-button"].surfaces)) {
    const files = emitEntry(buttonEntry, { ...config, surface });
    assert.ok(files.length > 0, `expected surface "${surface}" to emit files`);
    // Text-bearing sets use the Kit seam on EVERY surface (the seam is not
    // per-surface); no-text 2nd-sets render [] on double-list surfaces (A2).
    const textFiles = files.filter((f) => /Kit\.text/.test(f.contents));
    assert.ok(textFiles.length > 0, `expected surface "${surface}" to render Kit.text on text-bearing sets`);
    for (const { contents } of textFiles) {
      assert.match(contents, /"import Kit"/, `expected surface "${surface}" text files to import Kit`);
    }
  }
});

// ── surface data is still measured correctly ────────────────────────────────
test("surfaces record every real facet Face C measured — the per-facet-path fiction is gone (M3.a)", () => {
  // Post the `el`/`view` -> `component` ctor rename, Face C records THREE real
  // surfaces for m3e-button: the single unified `component` ctor is the
  // Standard `top` surface (now `record-double-list`, since `component` takes a
  // `{ content, action }` record), the `build` pipeline, and the brand-wide
  // `M3e.Html` barrel. The old separate `Record` (`el`) surface is gone — it
  // WAS the record ctor, now merged into the one `component`.
  assert.deepEqual(buttonComp.surfaces.top, {
    facet: "Standard",
    surface: "Standard",
    module: "M3e.Element.Button",
    entry: "component",
    form: "record-double-list",
    finalizer: null,
  });
  assert.deepEqual(buttonComp.surfaces.build, {
    facet: "Build",
    surface: "Build",
    module: "M3e.Build.Button",
    entry: "build",
    form: "pipeline",
    // `toElement` CLOSES the pipeline; `build` (the entry above) is the
    // SEED — the old bundle's `finalizer: "build"` pointed the pipeline
    // form's closing call at the seed itself (Emit.elm:2351/2536).
    finalizer: "toElement",
  });
  assert.deepEqual(buttonComp.surfaces.html, {
    facet: "Html",
    surface: "Html",
    module: "M3e.Html",
    entry: "button",
    form: "double-list",
    finalizer: null,
  });
  assert.deepEqual(Object.keys(buttonComp.surfaces).sort(), ["build", "html", "top"]);
});

// ── _internal unit coverage: the logic untouched by the text-seam fix round ─
// (renderExample/importsFor/resolveToken/setterOf take facts-resolved pieces
// as PARAMETERS — they don't call textSeamOf themselves — so they're testable
// directly against the real committed button facts.)
test("_internal.resolveToken resolves the FACTS token, never the golden's stale short name", () => {
  const token = _internal.resolveToken(buttonComp, "size", "extra-small", "test");
  assert.equal(token, "M3e.Values.extraSmall");
  assert.throws(
    () => _internal.resolveToken(buttonComp, "size", "ginormous", "test"),
    /has no matching Elm enum value/
  );
});

test("_internal.setterOf resolves the FACTS setter, throws on an unknown attr", () => {
  assert.equal(_internal.setterOf(buttonComp, "shape", "test"), "shape");
  assert.throws(() => _internal.setterOf(buttonComp, "nope", "test"), /is not a known\/verified setter/);
});

test('_internal.textSeamOf: profile config wins, else "Kit" (M3.a: no bundle fallback — not a Face C fact)', () => {
  assert.equal(_internal.textSeamOf({ textSeam: "MyKit" }), "MyKit");
  assert.equal(_internal.textSeamOf({}), "Kit");
});

test("_internal.htmlSeamOf/attrSeamOf: profile config wins, else TypedHtml/Native defaults", () => {
  assert.equal(_internal.htmlSeamOf({ htmlSeam: "MyHtml" }), "MyHtml");
  assert.equal(_internal.htmlSeamOf({}), "TypedHtml");
  assert.equal(_internal.attrSeamOf({ attrSeam: "MyAttr" }), "MyAttr");
  assert.equal(_internal.attrSeamOf({}), "Native");
});

test("renderChildElement: a multi-child HTML carrier wraps in the userland HTML seam (TypedHtml.<tag> + Native.attribute), NOT the CEM M3e.* facts", () => {
  // A <div slot="actions" end> holding two buttons — the right-aligned action-row
  // pattern from DialogElement.d.ts. The Elm emitter must render it via the
  // userland TypedHtml/Native seam, since elm-m3e has no M3e.* fact for a <div>.
  const acc = { imports: new Set(), skipped: [] };
  const spec = {
    tag: "div",
    slot: "actions", // handled by the caller against the parent; NOT emitted here
    attrs: { end: "true" },
    children: [
      { tag: "m3e-button", attrs: { variant: "text" }, text: "Action 2" },
      { tag: "m3e-button", attrs: { variant: "text" }, text: "Action 1" },
    ],
  };
  const el = _internal.renderChildElement(spec, config, acc, "test");
  assert.match(el, /^TypedHtml\.div \[ Native\.attribute "end" "true" \] \[ M3e\.Element\.Button\.component /);
  assert.doesNotMatch(el, /Native\.attribute "slot"/, "the slot attr is applied by the parent, never emitted on the carrier");
  assert.ok(acc.imports.has("TypedHtml") && acc.imports.has("Native"), "the userland seam modules are imported");
});

test("renderChildElement: a single-child HTML carrier stays TRANSPARENT (no TypedHtml wrapper) — unchanged behavior", () => {
  const acc = { imports: new Set(), skipped: [] };
  const spec = { tag: "span", children: [{ tag: "m3e-button", text: "Only" }] };
  const el = _internal.renderChildElement(spec, config, acc, "test");
  assert.match(el, /^M3e\.Element\.Button\.component /, "single child drops the wrapper (span-carries-slot equivalence)");
  assert.ok(!acc.imports.has("TypedHtml"), "no HTML seam import when transparent");
});

test("_internal.actionNoneOf returns the verified M3e.Action.none for button, throws when null", () => {
  assert.equal(_internal.actionNoneOf(buttonComp, "test"), "M3e.Action.none");
  assert.throws(
    () => _internal.actionNoneOf({ ...buttonComp, actionModule: null }, "test"),
    /no verified action module/
  );
});

test("_internal.resolveSetAttrExpr: float argType renders a bare Elm number literal", () => {
  const comp = { component: "progress", setters: { value: "value" }, setterArgTypes: { value: "float" }, enums: {} };
  assert.equal(_internal.resolveSetAttrExpr(comp, "value", "70", "test"), "70");
});

test("_internal.resolveSetAttrExpr: float argType rejects a non-numeric value loudly", () => {
  const comp = { component: "progress", setters: { value: "value" }, setterArgTypes: { value: "float" }, enums: {} };
  assert.throws(() => _internal.resolveSetAttrExpr(comp, "value", "seventy", "test"), /not numeric/);
});

test("_internal.resolveSetAttrExpr: no argTypes -> existing behavior unchanged (string-quoted)", () => {
  const comp = { component: "x", setters: { href: "href" }, enums: {} };
  assert.equal(_internal.resolveSetAttrExpr(comp, "href", "70", "test"), '"70"');
});

test("_internal.importsFor: token import is conditional (task C); double-list never imports the action module; record/build do", () => {
  // The `M3e.Html` barrel surface is the double-list one post-ctor-rename (the
  // Standard `top` surface is now the record-form `component`). task C
  // (dead-import fix): the token module is imported ONLY when the snippet
  // actually references a token; a double-list surface never imports the action
  // module.
  const html = buttonComp.surfaces.html;
  assert.deepEqual(_internal.importsFor(html, buttonComp, true), ["import M3e.Html", "import M3e.Values"]);
  assert.deepEqual(_internal.importsFor(html, buttonComp, false), ["import M3e.Html"]);

  // The Standard `top` surface is now `record-double-list` — it carries an
  // action record and MUST import the action module.
  const top = buttonComp.surfaces.top;
  assert.deepEqual(_internal.importsFor(top, buttonComp, true), [
    "import M3e.Element.Button",
    "import M3e.Values",
    "import M3e.Action",
  ]);

  assert.throws(
    () => _internal.importsFor(top, { ...buttonComp, actionModule: null }, true),
    /no verified action module/
  );
});

test("_internal.renderExample reproduces each surface's call shape (double-list / record-double-list / pipeline)", () => {
  const setterLines = [{ setter: "variant", expr: "M3e.Values.filled" }];
  const contentExpr = 'Kit.text "${label}"'; // a pre-built content expr — renderExample takes it as a param

  // The Standard `top` surface is now the record-form `component` ctor: the
  // content lands in `content =`, plus `action = M3e.Action.none`.
  const top = _internal.renderExample(buttonComp.surfaces.top, buttonComp, setterLines, contentExpr);
  assert.match(top, /^M3e\.Element\.Button\.component/);
  assert.match(top, /M3e\.Element\.Button\.variant M3e\.Values\.filled/);
  assert.match(top, /content = Kit\.text "\$\{label\}"/);
  assert.match(top, /action = M3e\.Action\.none/);

  // The synthetic record/pipeline call shapes are still exercised with
  // synthetic surfaceDefs (renderExample is a pure function of its surfaceDef
  // param), to lock those two forms independently of which one `top` is.
  const recordDef = { surface: "Record", module: "M3e.Record.Button", entry: "view", form: "record-double-list" };
  const record = _internal.renderExample(recordDef, buttonComp, setterLines, contentExpr);
  assert.match(record, /^M3e\.Record\.Button\.view/);
  assert.match(record, /action = M3e\.Action\.none/);

  const buildDef = { surface: "Build", module: "M3e.Build.Button", entry: "button", form: "pipeline", finalizer: "build" };
  const build = _internal.renderExample(buildDef, buttonComp, setterLines, contentExpr);
  assert.match(build, /^M3e\.Build\.Button\.button/);
  assert.match(build, /action = M3e\.Action\.none/);
  assert.match(build, /\|> M3e\.Build\.Button\.variant M3e\.Values\.filled/);
  assert.match(build, /\|> M3e\.Build\.Button\.build$/);
});

// ── never silently do: unknown elmSurface / bad axis value still throw first
test("an unknown elmSurface throws before ever rendering content", () => {
  assert.throws(
    () => emitEntry(buttonEntry, { ...config, surface: "nonsense" }),
    /elmSurface "nonsense" is not one of/
  );
});

test("an axis value with no facts-resolvable Elm token throws rather than guess", () => {
  const bad = structuredClone(buttonEntry);
  const sizeAxis = bad.axes.find((a) => a.attr === "size");
  sizeAxis.valueMap = { ...sizeAxis.valueMap, Ginormous: "ginormous" };
  assert.throws(() => emitEntry(bad, config), /has no matching Elm enum value in "size"/);
});

// ── the emitter object conforms to B2's interface shape (name/label/emit) ──
test("emitter object conforms to the B2 interface (name/label/emit function)", () => {
  assert.equal(emitter.name, "elm");
  assert.equal(emitter.label, "Elm");
  assert.equal(typeof emitter.emit, "function");
});

test("emitter.emit is a quiet no-op for a cemTag with no elm facts", () => {
  const noFactsEntry = { ...buttonEntry, cemTag: "not-a-real-cem-tag" };
  const files = emitter.emit(noFactsEntry, {
    profile: { fileKey: config.fileKey, raw: { elm: { elmSurface: "top" } } },
    figma: { data: { meta: { fileName: config.fileName } } },
  });
  assert.deepEqual(files, []);
});

// ── boolean axis branch (RC1: switch Selected->checked) ────────────────────────
test("boolean axis emits Elm Bool literals (True/False), not enum tokens", () => {
  // A self-contained synthetic entry for m3e-switch with a boolean axis
  // (mimics the real Switch Selected->checked case from RC1).
  const switchEntry = {
    cemTag: "m3e-switch",
    status: "confirmed",
    axes: [
      {
        figmaProp: "Selected",
        attr: "checked",
        kind: "boolean",
        valueMap: { True: "true", False: "false" },
      },
    ],
    props: [],
    figmaSets: [
      {
        nodeId: "1:1",
        setName: "Switch",
        fixedAttrs: {},
      },
    ],
  };

  const files = emitEntry(switchEntry, config);
  assert.ok(files.length > 0, "expected switch to emit files");

  const { contents } = files[0];

  // (a) The getEnum block must emit Elm Bool literals (True/False), NOT M3e.Token.* names.
  // The value keys are "True"/"False" (Figma keys), values are "True"/"False" (Elm Bool).
  assert.match(
    contents,
    /const checked = instance\.getEnum\("Selected",[\s\S]*?True:\s*"True"[\s\S]*?False:\s*"False"/,
    "getEnum values must be Elm Bool literals (True/False), not token references"
  );

  // Verify the Bool values are NOT token expressions.
  assert.doesNotMatch(
    contents,
    /M3e\.Values\.true/i,
    "should not emit M3e.Values.true (boolean values are primitives, not enums)"
  );
  assert.doesNotMatch(
    contents,
    /M3e\.Values\.false/i,
    "should not emit M3e.Values.false (boolean values are primitives, not enums)"
  );

  // (b) The setter line must render as M3e.Switch.checked ${checked}, NOT routed
  // through resolveToken. The real module/setter names are from elm-facts.
  assert.match(
    contents,
    /M3e\.Element\.Switch\.checked \$\{checked\}/,
    "boolean setter must render as <Module>.<setter> <var>, not through token resolution"
  );

  // (c) Verify no token resolution occurred for this axis (no token module import
  // for a bool setter). The switch component has an `icons` enum setter, so the
  // token module IS imported for that — but not specifically for the `checked`
  // boolean setter.
  //
  // Since switch.enums only contains `icons` (and `checked` is a plain Bool
  // setter), the getEnum block for `checked` emits Bool literals, and the
  // setter line directly uses the Bool variable. No token module fact is tied
  // to the `checked` axis specifically.
  //
  // We can test this by checking that the generated code has the right structure:
  // a const checked = getEnum(...True/False...) line and a setter line using ${checked}.
  const lines = contents.split("\n");
  const constLine = lines.find((l) => l.includes("const checked =") && l.includes("getEnum"));
  const setterLine = lines.find(
    (l) =>
      l.includes("M3e.Element.Switch.checked") &&
      l.includes("${checked}") &&
      !l.includes("M3e.Values")
  );
  assert.ok(constLine, "must have const checked = getEnum(...)");
  assert.ok(setterLine, "must have M3e.Switch.checked ${checked} line without token resolution");
});

test("contrast: enum axis still routes through resolveToken (locks the boolean branch distinction)", () => {
  // Verify that an ENUM axis (like switch.icons) still routes through resolveToken
  // and emits M3e.Token.* references, distinguishing it from the boolean branch.
  const switchWithEnum = {
    cemTag: "m3e-switch",
    status: "confirmed",
    axes: [
      {
        figmaProp: "Icons",
        attr: "icons",
        kind: "enum",
        valueMap: { Both: "both", None: "none", Selected: "selected" },
      },
    ],
    props: [],
    figmaSets: [
      {
        nodeId: "2:2",
        setName: "Switch Icons",
        fixedAttrs: {},
      },
    ],
  };

  const files = emitEntry(switchWithEnum, config);
  assert.ok(files.length > 0, "expected enum axis to emit files");

  const { contents } = files[0];

  // The enum axis must have getEnum values that are M3e.Token.* references.
  assert.match(
    contents,
    /M3e\.Values\.(both|none|selected)/,
    "enum axis must emit token references (M3e.Values.*)"
  );

  // The setter line must also reference the token module (already imported).
  assert.match(
    contents,
    /M3e\.Element\.Switch\.icons \$\{icons\}/,
    "enum setter line must render with variable interpolation"
  );

  // Contrast with the boolean case: no Bool literals.
  assert.doesNotMatch(contents, /"True"/, "enum axis should not emit Elm Bool literal True");
  assert.doesNotMatch(
    contents,
    /"False"/,
    "enum axis should not emit Elm Bool literal False"
  );
});

// ── digit-name canon fix (RC2: m3e-shape enum with digit-leading values) ───────
//
// CEM enum values can start with digits (e.g. "4-sided-cookie" in m3e-shape's
// Shape axis). Elm identifiers cannot start with digits, so Face C prefixes
// the ELM CONSTRUCTOR NAME with "value" (e.g. "value4SidedCookie") — but its
// `key` (the canonical join key docs/facts-bundle/schema.json's
// faceCEnum.values.key) is left un-prefixed ("4sidedcookie"), matching
// `canon()`'s own un-prefixed form directly. resolveToken's digit-prefixed
// key fallback (canon(cemValue) not found -> try "value"+canon(cemValue))
// is therefore dead code against this bundle — kept as a harmless guard, not
// exercised — the primary lookup already succeeds.

test("resolveToken: digit-leading CEM value ('4-sided-cookie') resolves directly — Face C's key is already un-prefixed", () => {
  const shapeComp = _internal.FACTS.components["m3e-shape"];
  assert.ok(shapeComp, "m3e-shape component must be in Face C");
  const nameEnum = shapeComp.enums["name"];
  assert.ok(nameEnum, "m3e-shape must have a 'name' enum");

  // The Elm constructor name is value-prefixed; the join key is not.
  const digit4SidedEntry = nameEnum.values.find((v) => v.elm === "value4SidedCookie");
  assert.ok(digit4SidedEntry, "facts must contain value4SidedCookie entry");
  assert.equal(digit4SidedEntry.key, "4sidedcookie", "Face C's join key is canon-form, not value-prefixed");

  const token = _internal.resolveToken(shapeComp, "name", "4-sided-cookie", "test");
  assert.equal(token, "M3e.Values.value4SidedCookie");
  assert.doesNotThrow(
    () => _internal.resolveToken(shapeComp, "name", "4-sided-cookie", "test"),
    "resolveToken must not throw on digit-leading CEM value"
  );
});

test("emitEntry: synthetic m3e-shape entry with digit-leading name value emits without throwing", () => {
  // Build a synthetic correspondence entry for m3e-shape with a Shape axis
  // mapping to the real digit-leading CEM value.
  const shapeEntry = {
    cemTag: "m3e-shape",
    status: "confirmed",
    axes: [
      {
        figmaProp: "Shape",
        attr: "name",
        kind: "enum",
        // Map Figma "FourSided" to CEM "4-sided-cookie" (digit-leading).
        valueMap: { FourSided: "4-sided-cookie", Arch: "arch" },
      },
    ],
    props: [],
    figmaSets: [
      {
        nodeId: "1:1",
        setName: "Shape Set",
        fixedAttrs: {},
      },
    ],
  };

  // Must not throw; resolveToken's digit-prefix fallback must work.
  const files = emitEntry(shapeEntry, config);
  assert.ok(files.length > 0, "expected shape to emit files");

  const { contents } = files[0];

  // The getEnum block must map FourSided to M3e.Token.value4SidedCookie (via the fallback key).
  assert.match(
    contents,
    /M3e\.Values\.value4SidedCookie/,
    "must emit the value-prefixed token for digit-leading CEM value"
  );

  // The setter line must render as M3e.Element.Shape.name ${name}.
  assert.match(contents, /M3e\.Element\.Shape\.name \$\{name\}/);
});

// ── Task 4 / defect D: examples.json children -> real Elm children ───────────
//
// When config.examples has an entry for the component, emitEntry must:
//   (a) NOT throw — even when the entry has a text→content prop that would
//       normally produce a contentBlock / getString block.
//   (b) Render the examples.json ChildSpecs as real Elm children in the view's
//       child list (defect D fix), NOT the empty `[]` shell.
//   (c) Produce NO `instance.getString(...)` block in the output.
//
// m3e-segmented-button is in elm-facts (double-list surface, top) AND in
// examples.json, making it the representative target.

const segButtonEntry = {
  cemTag: "m3e-segmented-button",
  status: "confirmed",
  figmaSets: [{ nodeId: "53923:36615", setName: "Segmented button", fixedAttrs: {} }],
  axes: [],
  props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
};

const configWithExamples = {
  ...config,
  examples: {
    "m3e-segmented-button": {
      children: [
        { tag: "m3e-button-segment", text: "Label" },
        { tag: "m3e-button-segment", text: "Label" },
        { tag: "m3e-button-segment", text: "Label" },
      ],
    },
  },
};

test("Task 4: emitEntry with examples entry does NOT throw for a text→content prop", () => {
  assert.doesNotThrow(() => emitEntry(segButtonEntry, configWithExamples));
});

test("Task 4: emitEntry with examples entry emits no getString block (no prop-derived content var)", () => {
  const files = emitEntry(segButtonEntry, configWithExamples);
  assert.ok(files.length > 0, "expected at least one file");
  for (const { contents } of files) {
    assert.doesNotMatch(
      contents,
      /instance\.getString/,
      "examples-mode must not emit a getString block for the text→content prop"
    );
  }
});

test("defect D: emitEntry with examples entry renders the ChildSpecs as real Elm children (not [])", () => {
  const files = emitEntry(segButtonEntry, configWithExamples);
  for (const { contents } of files) {
    // The three { tag: "m3e-button-segment", text: "Label" } ChildSpecs become
    // three M3e.ButtonSegment.component children carrying the Kit.text seam — NOT
    // the old empty [] shell. m3e-segmented-button is now a record-form parent
    // (`component`), so the FIRST child folds into the record `content =` and the
    // other two are the trailing child list (ctor prepends content to children).
    assert.match(
      contents,
      /content = M3e\.Element\.ButtonSegment\.component \[\] \[ Kit\.text "Label" \]/,
      "the first ChildSpec renders as the record content (defect D, record form)"
    );
    assert.match(
      contents,
      /\[ M3e\.Element\.ButtonSegment\.component \[\] \[ Kit\.text "Label" \]\n    , M3e\.Element\.ButtonSegment\.component \[\] \[ Kit\.text "Label" \]\n    \]/,
      "the remaining ChildSpecs render as the trailing child list (defect D)"
    );
    // The rendered children call the Kit text seam, so the file DOES import Kit.
    assert.match(contents, /"import Kit"/, "children that call Kit.text import the Kit seam");
    assert.match(contents, /"import M3e\.Element\.ButtonSegment"/, "nested child module is imported");
  }
});

test("Task 4: m3e-button emits 9 files (5 primary prop-binding + 4 appended example 2nd-sets)", () => {
  const files = emitEntry(buttonEntry, config);
  assert.equal(files.length, 9, "5 primary axis-grid sets + 4 appended toggle 2nd-sets");
  const labelFiles = files.filter((f) => /Kit\.text "\$\{label\}"/.test(f.contents));
  assert.equal(labelFiles.length, 5, "the 5 primary sets prop-interpolate the label; the 4 appended render their inline example");
});

test("Task 4: emitter.emit threads examples correctly through ctx", () => {
  const files = emitter.emit(segButtonEntry, {
    profile: { fileKey: config.fileKey, raw: { elm: { elmSurface: "top" } } },
    figma: { data: { meta: { fileName: config.fileName } } },
    examples: { "m3e-segmented-button": { children: [{ tag: "m3e-button-segment", text: "Label" }] } },
  });
  assert.ok(files.length > 0, "emitter.emit must produce files");
  assert.doesNotMatch(files[0].contents, /instance\.getString/, "no getString in examples mode");
  // Record-form parent: the single ButtonSegment child folds into `content =`.
  assert.match(
    files[0].contents,
    /content = M3e\.Element\.ButtonSegment\.component \[\] \[ Kit\.text "Label" \]/,
    "examples children rendered via emitter.emit ctx (defect D)"
  );
});

// ── defect D: composed-component children emission (the core fix) ────────────
//
// A minimal synthetic Card entry exercising the full ChildSpec → Elm mapping:
// slotted text carriers (span slot="header"/"content"), a slotted nested custom
// element with its own attr + text (m3e-button slot="actions"), the slot-fn
// wrapping (M3e.Card.header/…), the Kit.text seam, and minimal imports.
const cardEntry = {
  cemTag: "m3e-card",
  status: "confirmed",
  figmaSets: [{ nodeId: "1:1", setName: "Card", fixedAttrs: {} }],
  axes: [],
  props: [],
};
const cardExamples = {
  "m3e-card": {
    children: [
      { tag: "span", slot: "header", text: "Header" },
      { tag: "span", slot: "content", text: "Supporting text goes here." },
      { tag: "m3e-button", slot: "actions", attrs: { variant: "text" }, text: "Action" },
    ],
  },
};

test("defect D: slotted text children render as M3e.Element.Card.<slot> (Kit.text ...)", () => {
  const files = emitEntry(cardEntry, { ...config, examples: cardExamples });
  assert.equal(files.length, 1);
  const { contents } = files[0];
  assert.match(contents, /M3e\.Element\.Card\.header \(Kit\.text "Header"\)/);
  assert.match(contents, /M3e\.Element\.Card\.content \(Kit\.text "Supporting text goes here\."\)/);
  // Nested custom element in a slot: m3e-button is now a record-form component,
  // so its content ("Action") folds into the record `content =`; its attr still
  // resolves to a token.
  assert.match(
    contents,
    /M3e\.Element\.Card\.actions \(M3e\.Element\.Button\.component \{ content = Kit\.text "Action", action = M3e\.Action\.none \} \[ M3e\.Element\.Button\.variant M3e\.Values\.text \] \[\]\)/
  );
  // Imports are minimal and include every referenced module + the Kit seam
  // (the nested record adds M3e.Action).
  assert.match(contents, /"import Kit", "import M3e\.Action", "import M3e\.Element\.Button", "import M3e\.Element\.Card", "import M3e\.Values"/);
  // No leftover empty-shell [] children.
  assert.doesNotMatch(contents, /\n    \[\]`/);
});

test("defect D: an empty-string boolean attr on a child (selected=\"\") becomes True", () => {
  // Mirrors examples.json m3e-tabs' <m3e-tab selected=""> and m3e-nav-menu.
  const tabsEntry = {
    cemTag: "m3e-tabs",
    status: "confirmed",
    figmaSets: [{ nodeId: "1:1", setName: "Tabs", fixedAttrs: {} }],
    axes: [],
    props: [],
  };
  const files = emitEntry(tabsEntry, {
    ...config,
    examples: {
      "m3e-tabs": {
        children: [
          { tag: "m3e-tab", attrs: { selected: "" }, text: "Flights" },
          { tag: "m3e-tab", text: "Trips" },
        ],
      },
    },
  });
  const { contents } = files[0];
  // `selected` is a real Bool setter on m3e-tab (not a slot); "" -> True. m3e-tab
  // is a double-list component, so `component` keeps the `[attrs] [children]` shape.
  assert.match(contents, /M3e\.Element\.Tab\.component \[ M3e\.Element\.Tab\.selected True \] \[ Kit\.text "Flights" \]/);
  assert.match(contents, /M3e\.Element\.Tab\.component \[\] \[ Kit\.text "Trips" \]/);
});

test("defect D: opaque HTML child (<input>) is skipped with a header note, never guessed", () => {
  // m3e-form-field's only example child is an <input> — elm-m3e has no verified
  // element seam for it, so it is omitted from the child list and surfaced as a
  // header note (never a guessed module name, never a silent drop).
  const formFieldEntry = {
    cemTag: "m3e-form-field",
    status: "confirmed",
    figmaSets: [{ nodeId: "1:1", setName: "Form field", fixedAttrs: {} }],
    axes: [],
    props: [],
  };
  const files = emitEntry(formFieldEntry, {
    ...config,
    examples: { "m3e-form-field": { children: [{ tag: "input", attrs: { placeholder: "Label" } }] } },
  });
  const { contents } = files[0];
  assert.match(contents, /example child \(not emitted\): <input>/, "skipped input is surfaced as a note");
  assert.match(contents, /\n    \[\]`/, "the child list is empty (the only child was skipped)");
  assert.doesNotMatch(contents, /TypedHtml|Native\.|input\b.*view/, "never guesses an HTML element seam");
});

test("_internal.slotSetterOf resolves by exact + canonical key, throws on an unknown slot", () => {
  const card = _internal.FACTS.components["m3e-card"];
  assert.equal(_internal.slotSetterOf(card, "header", "t"), "header");
  const splitButton = _internal.FACTS.components["m3e-split-button"];
  // WC slot "leading-button" canon-matches elm slot fn "leadingButton".
  assert.equal(_internal.slotSetterOf(splitButton, "leading-button", "t"), "leadingButton");
  assert.throws(() => _internal.slotSetterOf(card, "nope", "t"), /is not a known slot function/);
});

test("_internal.renderChildElement: nested custom element, transparent HTML carrier, opaque HTML null", () => {
  const cfg = { ...config };
  // Custom element with attr (token) + text.
  const acc1 = { imports: new Set(), skipped: [] };
  assert.equal(
    _internal.renderChildElement(
      { tag: "m3e-button", attrs: { variant: "text" }, text: "Action" },
      cfg,
      acc1,
      "t"
    ),
    // m3e-button is a record-form component: its text folds into `content =`.
    'M3e.Element.Button.component { content = Kit.text "Action", action = M3e.Action.none } [ M3e.Element.Button.variant M3e.Values.text ] []'
  );
  // Transparent HTML text carrier collapses to its single inner element.
  const acc2 = { imports: new Set(), skipped: [] };
  assert.equal(
    _internal.renderChildElement({ tag: "span", text: "Hi" }, cfg, acc2, "t"),
    'Kit.text "Hi"'
  );
  // Opaque HTML returns null and records a skip note.
  const acc3 = { imports: new Set(), skipped: [] };
  assert.equal(_internal.renderChildElement({ tag: "input" }, cfg, acc3, "t"), null);
  assert.equal(acc3.skipped.length, 1);
  assert.equal(acc3.skipped[0].tag, "input");
});

test("_internal.resolveChildAttrExpr: empty-string bool -> True; else delegates unchanged", () => {
  const tab = _internal.FACTS.components["m3e-tab"];
  assert.equal(_internal.resolveChildAttrExpr(tab, "selected", "", "t"), "True");
  assert.equal(_internal.resolveChildAttrExpr(tab, "selected", "true", "t"), "True");
  assert.equal(_internal.resolveChildAttrExpr(tab, "selected", "false", "t"), "False");
  // A String setter is unaffected (delegates to resolveSetAttrExpr).
  assert.equal(_internal.resolveChildAttrExpr(tab, "for", "x", "t"), '"x"');
});

// ── Task 4 (amendment scope): iconTable Elm emit branch ──────────────────────
const ICON_ENTRY = {
  cemTag: "m3e-icon",
  kind: "iconTable",
  status: "confirmed",
  icons: [
    { figmaNodeId: "1:1", figmaName: "wifi", symbolName: "wifi", filled: false },
    { figmaNodeId: "1:2", figmaName: "stars", symbolName: "stars", filled: true },
    { figmaNodeId: "1:3", figmaName: "settings", symbolName: "settings", filled: false },
    { figmaNodeId: "1:4", figmaName: "settings-2", symbolName: "settings", filled: false },
  ],
};
const ICON_CONFIG = { fileKey: "K", fileName: "F", surface: "top", textSeam: "Kit" };

test("elm iconTable: one file per row, facts-resolved names, [] children, -elm suffix", () => {
  const files = _internal.emitIconTableEntry(ICON_ENTRY, ICON_CONFIG);
  assert.equal(files.length, 4);
  assert.deepEqual(
    files.map((f) => f.path),
    [
      "m3e-icon-wifi-elm.figma.ts",
      "m3e-icon-stars-filled-elm.figma.ts",
      "m3e-icon-settings-elm.figma.ts",
      "m3e-icon-settings-2-elm.figma.ts", // dup (symbolName, filled) -> -2, icons-array order
    ]
  );
  // R-026 opaque-`Name` icons: the ligature is the positional `Name` argument of
  // `M3e.Icon.icon` (never a `name` string setter); children stay [].
  // Opaque-Name constructor + Name from the icons module (M3e.Icon); the filled
  // setter from the component surface (M3e.Element.Icon), which type-unifies
  // with M3e.Icon.icon's polymorphic attrs. Plain icons import only M3e.Icon;
  // filled icons import both (minimal).
  assert.match(files[0].contents, /M3e\.Icon\.icon M3e\.Icon\.wifi \[\] \[\]/);
  assert.match(files[1].contents, /M3e\.Icon\.icon M3e\.Icon\.stars \[ M3e\.Element\.Icon\.filled True \] \[\]/);
  assert.match(files[0].contents, /"import M3e\.Icon"/);
  assert.doesNotMatch(files[0].contents, /"import M3e\.Element\.Icon"/, "plain (unfilled) icon does not import the component surface");
  assert.match(files[1].contents, /"import M3e\.Element\.Icon", "import M3e\.Icon"/, "filled icon imports both, sorted");
  assert.doesNotMatch(files[0].contents, /Kit\.text|M3e\.Token|import Kit/, "no seam/token for icons");
});

test("elm iconTable: emitter.emit dispatches iconTable entries", () => {
  const ctx = {
    profile: { fileKey: "K", raw: { elm: { elmSurface: "top", textSeam: "Kit" } } },
    figma: { data: { meta: { fileName: "F" } } },
  };
  const files = emitter.emit(ICON_ENTRY, ctx);
  assert.equal(files.length, 4);
});

// ── Progress components: real setter/facet resolution + emission ────────────
test("circular progress: float set-attrs -> M3e.CircularProgressIndicator.view [ value 70 ] []", () => {
  const entry = {
    cemTag: "m3e-circular-progress-indicator",
    status: "confirmed",
    figmaSets: [
      { nodeId: "1:1", setName: "Circular-determinate progress indicator", fixedAttrs: {} },
      { nodeId: "1:2", setName: "Circular-indeterminate progress indicator", fixedAttrs: {} },
    ],
    axes: [],
    props: [],
  };
  const files = emitEntry(entry, {
    fileKey: "K",
    fileName: "F",
    surface: "top",
    setAttrs: {
      "m3e-circular-progress-indicator": {
        "Circular-determinate progress indicator": { value: "70" },
        "Circular-indeterminate progress indicator": { indeterminate: "true" },
      },
    },
  });
  assert.equal(files.length, 2);
  // Post-review this is a REGULAR component (M3e.Element.CircularProgressIndicator),
  // not a M3e.Progress group alias. `value` is a Float setter (setterArgTypes) ->
  // bare `70`, never a quoted string. `indeterminate` is Bool -> True.
  assert.match(files[0].contents, /M3e\.Element\.CircularProgressIndicator\.component\n    \[ M3e\.Element\.CircularProgressIndicator\.value 70\n    \]\n    \[\]/);
  assert.match(files[1].contents, /M3e\.Element\.CircularProgressIndicator\.indeterminate True/);
  assert.match(files[0].contents, /"import M3e\.Element\.CircularProgressIndicator"/);
  // task C: neither set references a token, so no token module is imported.
  assert.doesNotMatch(files[0].contents, /import M3e\.Values/);
});

test("linear progress: fixedAttrs mode -> M3e.Values enum + float set-attrs value", () => {
  const entry = {
    cemTag: "m3e-linear-progress-indicator",
    status: "confirmed",
    figmaSets: [
      { nodeId: "1:10", setName: "Linear-determinate progress indicator", fixedAttrs: { mode: "determinate" } },
      { nodeId: "1:11", setName: "Linear-indeterminate progress indicator", fixedAttrs: { mode: "indeterminate" } },
    ],
    axes: [],
    props: [],
  };
  const files = emitEntry(entry, {
    fileKey: "K",
    fileName: "F",
    surface: "top",
    setAttrs: { "m3e-linear-progress-indicator": { "Linear-determinate progress indicator": { value: "70" } } },
  });
  // Post-review: regular component M3e.Element.LinearProgressIndicator; `mode`
  // is an enum (-> M3e.Values token), `value` a Float set-attr (-> bare 70).
  assert.match(
    files[0].contents,
    /M3e\.Element\.LinearProgressIndicator\.component\n    \[ M3e\.Element\.LinearProgressIndicator\.mode M3e\.Values\.determinate\n    , M3e\.Element\.LinearProgressIndicator\.value 70\n    \]/
  );
  assert.match(files[1].contents, /M3e\.Element\.LinearProgressIndicator\.mode M3e\.Values\.indeterminate/);
});

// ── T3: per-set set-attrs injection in the Elm emitter ───────────────────────
//
// Synthetic fixture: m3e-button (IS in elm-facts) with two sets, one of which
// gets a set-attrs injection of the boolean `disabled` attr and one of which
// gets a set-attrs injection of an enum `variant` attr. This tests the full
// mechanism through the Elm setter/token resolution chain.
//
// Note: progress indicator tags (the real set-attrs.json entries) are NOT in
// elm-facts, so the elm emitter returns [] for them — the mechanism is still
// exercised here via m3e-button as the synthetic tag.

const fakeButtonEntry2Sets = {
  cemTag: "m3e-button",
  status: "confirmed",
  figmaSets: [
    { nodeId: "1:99", setName: "Button - disabled set", fixedAttrs: {} },
    { nodeId: "1:100", setName: "Button - filled set", fixedAttrs: {} },
  ],
  axes: [],
  props: [],
};

test("T3 set-attrs elm: boolean attr injection renders as Elm Bool literal (True)", () => {
  const cfg = {
    ...config,
    setAttrs: {
      "m3e-button": {
        "Button - disabled set": { "disabled": "true" },
      },
    },
  };
  const files = emitEntry(fakeButtonEntry2Sets, cfg);
  assert.equal(files.length, 2, "two files for two sets");
  const disabledFile = files.find((f) => f.id.includes("disabled-set"));
  assert.ok(disabledFile, "disabled-set file found");
  assert.match(disabledFile.contents, /disabled True/, "boolean set-attr renders as 'disabled True'");
  // The other set must NOT have the disabled setter
  const filledFile = files.find((f) => f.id.includes("filled-set"));
  assert.ok(filledFile, "filled-set file found");
  assert.doesNotMatch(filledFile.contents, /disabled True/, "filled set must not have disabled True");
});

test("T3 set-attrs elm: enum attr injection resolves to an M3e.Token", () => {
  const cfg = {
    ...config,
    setAttrs: {
      "m3e-button": {
        "Button - filled set": { "variant": "filled" },
      },
    },
  };
  const files = emitEntry(fakeButtonEntry2Sets, cfg);
  const filledFile = files.find((f) => f.id.includes("filled-set"));
  assert.ok(filledFile, "filled-set file found");
  assert.match(filledFile.contents, /variant M3e\.Values\.\w+/, "enum set-attr resolves to M3e.Values");
});

test("T3 set-attrs elm: injected attr does NOT appear in filename/id", () => {
  const cfg = {
    ...config,
    setAttrs: {
      "m3e-button": {
        "Button - disabled set": { "disabled": "true" },
      },
    },
  };
  const files = emitEntry(fakeButtonEntry2Sets, cfg);
  for (const f of files) {
    assert.doesNotMatch(f.id, /true/, "boolean value must not pollute elm file id");
  }
});

test("T3 set-attrs elm: unknown setName throws at emit time", () => {
  const cfg = {
    ...config,
    setAttrs: {
      "m3e-button": {
        "Typo set": { "disabled": "true" },
      },
    },
  };
  assert.throws(
    () => emitEntry(fakeButtonEntry2Sets, cfg),
    /set-attrs: unknown setName 'Typo set' for 'm3e-button'/,
    "unknown setName must throw in elm emitter"
  );
});

test("T3 set-attrs elm: entry with no set-attrs for this tag is unchanged", () => {
  const cfg = { ...config, setAttrs: {} };
  const cfgWithOther = { ...config, setAttrs: { "m3e-other": { "X": { "y": "z" } } } };
  const filesWithout = emitEntry(buttonEntry, cfg);
  const filesWith = emitEntry(buttonEntry, cfgWithOther);
  assert.equal(filesWithout.length, filesWith.length);
  for (let i = 0; i < filesWithout.length; i++) {
    assert.equal(filesWithout[i].contents, filesWith[i].contents, `elm file ${i} unchanged when no set-attrs for tag`);
  }
});

test("T3 set-attrs elm: emitter.emit threads setAttrs through ctx", () => {
  const files = emitter.emit(fakeButtonEntry2Sets, {
    profile: { fileKey: config.fileKey, raw: { elm: { elmSurface: "top" } } },
    figma: { data: { meta: { fileName: config.fileName } } },
    examples: {},
    setAttrs: { "m3e-button": { "Button - disabled set": { "disabled": "true" } } },
  });
  assert.ok(files.length > 0, "emitter.emit produces files");
  const disabledFile = files.find((f) => f.path.includes("disabled-set"));
  assert.ok(disabledFile, "disabled-set file found via emitter.emit");
  assert.match(disabledFile.contents, /disabled True/, "boolean set-attr present via ctx");
});

