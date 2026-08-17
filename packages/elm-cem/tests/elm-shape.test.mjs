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
} from "../src/elm-shape.mjs";

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
