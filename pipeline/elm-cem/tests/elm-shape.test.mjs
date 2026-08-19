// elm-shape.test.mjs — L1 goldens for the canonical Layer-2 shape renderer.
//
// These goldens reproduce cem-figma-connect's `renderExample`
// (profiles/m3-kit/emitters/elm.mjs) BYTE-FOR-BYTE for the three surface forms
// (double-list, record-double-list, pipeline) plus the nested inline shape. L3
// then refactors that emitter to call THESE functions and proves — via the
// existing cem-figma-connect suite + committed-golden byte-diff — that the
// extraction is a no-op.
//
// The hardcoded expectations below were traced from `renderExample`'s exact
// string composition (including the deliberate trailing space on an empty attr
// list, which is B's current byte output).

import { test } from "node:test";
import assert from "node:assert/strict";
import {
  renderComponentCall,
  renderAttrList,
  renderList,
  renderSlot,
  renderTextSeam,
  renderNativeAttr,
  renderTypedHtml,
  canon,
  setterOf,
  resolveEnumToken,
  resolveAttrExpr,
  slotFnOf,
  slotAttrOf,
  actionNoneOf,
  entryOf,
  iconNameExpr,
} from "../src/elm-shape.mjs";

// A minimal Face-C-shaped `comp` fixture for the Layer-1 resolver tests.
const comp = {
  component: "Button",
  module: "M3e.Button",
  tokenModule: "M3e.Values",
  actionModule: "M3e.Button.Action",
  setters: { variant: "variant", href: "href", "optical-size": "opticalSize", nope: null },
  setterArgTypes: { opticalSize: "float", disabled: "bool" },
  enums: {
    variant: {
      values: [
        { key: "filled", elm: "filled", token: "M3e.Values.filled" },
        { key: "rounded", elm: "rounded", token: "M3e.Values.rounded" },
        // digit-leading: producer prefixes ctor + key with "value"
        { key: "value4sidedcookie", elm: "value4SidedCookie", token: "M3e.Values.value4SidedCookie" },
        // a measured-but-unexposed value (token:null)
        { key: "ghost", elm: "ghost", token: null },
      ],
    },
  },
  slotSetters: ["header", "selectedIcon"],
  surfaces: {
    top: { module: "M3e.Button", entry: "component", form: "record-double-list", finalizer: null },
    build: { module: "M3e.Button", entry: "build", form: "pipeline", finalizer: "toElement" },
  },
};

// ── renderComponentCall: multiline (top-level) — the three forms ───────────

test("double-list: setters + single content", () => {
  const out = renderComponentCall({
    module: "M3e.Icon",
    entry: "view",
    form: "double-list",
    setters: [
      { setter: "size", expr: "${size}" },
      { setter: "variant", expr: "M3e.Values.filled" },
    ],
    content: `Kit.text "Star"`,
  });
  assert.equal(
    out,
    `M3e.Icon.view
    [ M3e.Icon.size \${size}
    , M3e.Icon.variant M3e.Values.filled
    ]
    [ Kit.text "Star" ]`
  );
});

test("double-list: no setters, no content -> empty attr list (trailing space) + []", () => {
  const out = renderComponentCall({
    module: "M3e.Icon",
    entry: "view",
    form: "double-list",
    setters: [],
    content: null,
  });
  // Deliberate: the empty attr list keeps B's exact "[ \n    ]" bytes.
  assert.equal(out, "M3e.Icon.view\n    [ \n    ]\n    []");
});

test("double-list: children list takes precedence over content", () => {
  const out = renderComponentCall({
    module: "M3e.Tabs",
    entry: "view",
    form: "double-list",
    setters: [],
    content: `Kit.text "ignored"`,
    children: [`M3e.Tab.view [] [ Kit.text "A" ]`, `M3e.Tab.view [] [ Kit.text "B" ]`],
  });
  assert.equal(
    out,
    "M3e.Tabs.view\n    [ \n    ]\n" +
      '    [ M3e.Tab.view [] [ Kit.text "A" ]\n' +
      '    , M3e.Tab.view [] [ Kit.text "B" ]\n' +
      "    ]"
  );
});

test("record-double-list: content + action record, trailing []", () => {
  const out = renderComponentCall({
    module: "M3e.Button",
    entry: "component",
    form: "record-double-list",
    setters: [{ setter: "variant", expr: "M3e.Values.filled" }],
    content: `Kit.text "OK"`,
    actionNone: "M3e.Button.Action.none",
  });
  assert.equal(
    out,
    `M3e.Button.component
    { content = Kit.text "OK"
    , action = M3e.Button.Action.none
    }
    [ M3e.Button.variant M3e.Values.filled
    ]
    []`
  );
});

test("record-double-list: children fold first->content, rest->trailing list", () => {
  const out = renderComponentCall({
    module: "M3e.Card",
    entry: "component",
    form: "record-double-list",
    setters: [],
    children: [`M3e.Card.header (Kit.text "H")`, `Kit.text "body"`],
    actionNone: "M3e.Card.Action.none",
  });
  assert.equal(
    out,
    "M3e.Card.component\n" +
      '    { content = M3e.Card.header (Kit.text "H")\n' +
      "    , action = M3e.Card.Action.none\n" +
      "    }\n" +
      "    [ \n    ]\n" +
      '    [ Kit.text "body"\n' +
      "    ]"
  );
});

test("pipeline: record + piped setters + finalizer", () => {
  const out = renderComponentCall({
    module: "M3e.Button",
    entry: "build",
    form: "pipeline",
    finalizer: "toElement",
    setters: [
      { setter: "variant", expr: "M3e.Values.filled" },
      { setter: "size", expr: "M3e.Values.small" },
    ],
    content: `Kit.text "Go"`,
    actionNone: "M3e.Button.Action.none",
  });
  assert.equal(
    out,
    `M3e.Button.build
    { content = Kit.text "Go"
    , action = M3e.Button.Action.none
    }
    |> M3e.Button.variant M3e.Values.filled
    |> M3e.Button.size M3e.Values.small
    |> M3e.Button.toElement`
  );
});

test("pipeline: no finalizer -> no trailing pipe", () => {
  const out = renderComponentCall({
    module: "M3e.Search",
    entry: "build",
    form: "pipeline",
    finalizer: null,
    setters: [{ setter: "mode", expr: "M3e.Values.docked" }],
    content: `Kit.text ""`,
    actionNone: "M3e.Search.Action.none",
  });
  assert.equal(
    out,
    `M3e.Search.build
    { content = Kit.text ""
    , action = M3e.Search.Action.none
    }
    |> M3e.Search.mode M3e.Values.docked`
  );
});

// ── renderComponentCall: inline (nested child) ─────────────────────────────

test("inline double-list: single line, empty child list -> []", () => {
  const out = renderComponentCall({
    module: "M3e.Icon",
    entry: "view",
    form: "double-list",
    setters: [{ setter: "name", expr: `"add"` }],
    children: [],
    multiline: false,
  });
  assert.equal(out, `M3e.Icon.view [ M3e.Icon.name "add" ] []`);
});

test("inline record-double-list: content from first child, rest trail", () => {
  const out = renderComponentCall({
    module: "M3e.Chip",
    entry: "component",
    form: "record-double-list",
    setters: [],
    children: [`Kit.text "A"`],
    actionNone: "M3e.Chip.Action.none",
    multiline: false,
  });
  assert.equal(out, `M3e.Chip.component { content = Kit.text "A", action = M3e.Chip.Action.none } [] []`);
});

// ── the primitives ─────────────────────────────────────────────────────────

test("renderAttrList multiline vs inline", () => {
  const setters = [{ setter: "a", expr: "1" }, { setter: "b", expr: "2" }];
  assert.equal(renderAttrList("M3e.X", setters, { multiline: true }), "[ M3e.X.a 1\n    , M3e.X.b 2\n    ]");
  assert.equal(renderAttrList("M3e.X", setters, { multiline: false }), "[ M3e.X.a 1, M3e.X.b 2 ]");
  assert.equal(renderAttrList("M3e.X", [], { multiline: false }), "[]");
  assert.equal(renderAttrList("M3e.X", [], { multiline: true }), "[ \n    ]");
});

test("renderList multiline vs inline vs empty", () => {
  assert.equal(renderList(["a", "b"], { multiline: false }), "[ a, b ]");
  assert.equal(renderList(["a", "b"], { multiline: true }), "[ a\n    , b\n    ]");
  assert.equal(renderList([], { multiline: true }), "[]");
  assert.equal(renderList(null), "[]");
});

test("renderSlot wraps a child against the parent module", () => {
  assert.equal(renderSlot("M3e.Card", "header", `Kit.text "H"`), `M3e.Card.header (Kit.text "H")`);
});

test("seam helpers", () => {
  assert.equal(renderTextSeam("Kit", `He said "hi"`), `Kit.text "He said \\"hi\\""`);
  assert.equal(renderTextSeam("Kit", ""), `Kit.text ""`);
  assert.equal(renderNativeAttr("Native", "data-x", "y"), `Native.attribute "data-x" "y"`);
  assert.equal(renderTypedHtml("TypedHtml", "div", [`Native.attribute "class" "g"`], [`Kit.text "x"`]),
    `TypedHtml.div [ Native.attribute "class" "g" ] [ Kit.text "x" ]`);
  assert.equal(renderTypedHtml("TypedHtml", "img", [`Native.attribute "src" "/x"`], []),
    `TypedHtml.img [ Native.attribute "src" "/x" ] []`);
});

// ── Layer 1 resolvers (discriminated result) ───────────────────────────────

test("canon bridges kebab and camel", () => {
  assert.equal(canon("extra-small"), "extrasmall");
  assert.equal(canon("value4SidedCookie"), "value4sidedcookie");
});

test("setterOf: verified setter vs unverified/absent -> err", () => {
  assert.deepEqual(setterOf(comp, "variant"), { ok: true, value: "variant" });
  const bad = setterOf(comp, "nope"); // measured-but-null
  assert.equal(bad.ok, false);
  assert.match(bad.reason, /attribute "nope" is not a known\/verified setter for component "Button"/);
  const absent = setterOf(comp, "wat");
  assert.equal(absent.ok, false);
});

test("resolveEnumToken: digit-leading value4SidedCookie via value-prefix fallback", () => {
  // CEM "4-sided-cookie" canons to "4sidedcookie" (digit-leading) -> falls back to
  // the "value4sidedcookie" key -> the correct value-prefixed token.
  assert.deepEqual(resolveEnumToken(comp, "variant", "4-sided-cookie"), {
    ok: true,
    value: "M3e.Values.value4SidedCookie",
  });
  // plain values resolve directly
  assert.deepEqual(resolveEnumToken(comp, "variant", "rounded"), { ok: true, value: "M3e.Values.rounded" });
});

test("resolveEnumToken: unexposed token (token:null) -> err, never guessed", () => {
  const r = resolveEnumToken(comp, "variant", "ghost");
  assert.equal(r.ok, false);
  assert.match(r.reason, /not exposed in the token module \(elm-facts recorded token:null\)/);
});

test("resolveEnumToken: no matching enum value -> err", () => {
  const r = resolveEnumToken(comp, "variant", "made-up");
  assert.equal(r.ok, false);
  assert.match(r.reason, /has no matching Elm enum value in "variant"/);
});

test("resolveEnumToken: no enum for setter -> err", () => {
  const r = resolveEnumToken(comp, "href", "x");
  assert.equal(r.ok, false);
  assert.match(r.reason, /no enum "href" in elm-facts/);
});

test("resolveAttrExpr: enum, number, bool-present, string", () => {
  assert.deepEqual(resolveAttrExpr(comp, "variant", "filled"), { ok: true, value: "M3e.Values.filled" });
  assert.deepEqual(resolveAttrExpr(comp, "optical-size", "24"), { ok: true, value: "24" });
  assert.deepEqual(resolveAttrExpr(comp, "href", "/a"), { ok: true, value: `"/a"` });
  assert.deepEqual(resolveAttrExpr(comp, "href", "true"), { ok: true, value: "True" });
  // non-numeric on a float setter -> err
  const bad = resolveAttrExpr(comp, "optical-size", "big");
  assert.equal(bad.ok, false);
  assert.match(bad.reason, /is not numeric, but setter "opticalSize" takes Float/);
});

test("slotFnOf: exact + canonical match, else err", () => {
  assert.deepEqual(slotFnOf(comp, "header"), { ok: true, value: "header" });
  assert.deepEqual(slotFnOf(comp, "selected-icon"), { ok: true, value: "selectedIcon" });
  const r = slotFnOf(comp, "footer");
  assert.equal(r.ok, false);
  assert.match(r.reason, /slot "footer" is not a known slot function of M3e.Button/);
});

test("slotAttrOf: returns slot name or null (not an err)", () => {
  assert.equal(slotAttrOf(comp, "header"), "header");
  assert.equal(slotAttrOf(comp, "selected-icon"), "selectedIcon");
  assert.equal(slotAttrOf(comp, "variant"), null);
});

test("actionNoneOf: verified module vs null", () => {
  assert.deepEqual(actionNoneOf(comp), { ok: true, value: "M3e.Button.Action.none" });
  const r = actionNoneOf({ ...comp, actionModule: null });
  assert.equal(r.ok, false);
  assert.match(r.reason, /no verified action module for component "Button"/);
});

test("entryOf: known surface vs unknown", () => {
  assert.deepEqual(entryOf(comp, "top"), {
    ok: true,
    value: { module: "M3e.Button", entry: "component", form: "record-double-list", finalizer: null },
  });
  assert.deepEqual(entryOf(comp, "build").value, {
    module: "M3e.Button",
    entry: "build",
    form: "pipeline",
    finalizer: "toElement",
  });
  const r = entryOf(comp, "nope");
  assert.equal(r.ok, false);
});

test("iconNameExpr: exposed constant vs custom escape", () => {
  const catalog = { module: "M3e.Icon", customFn: "custom", names: { add: "add", menu: "menu" } };
  assert.equal(iconNameExpr("add", catalog), "M3e.Icon.add");
  assert.equal(iconNameExpr("GIF", catalog), `M3e.Icon.custom "GIF"`);
});
