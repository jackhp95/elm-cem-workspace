// tools/check-figma-write-block.test.mjs — picked up automatically by
// gate-all's tools/*.test.mjs discovery (see tools/gate-all.mjs).
//
// Pins the near-zero-false-positive bar a blocking PreToolUse hook needs:
// legitimate read-only `use_figma` inspection scripts (including the
// figma-generate-design skill's own documented example) must never block,
// while the reconstructed 2026-08-19 incident and each individual write
// pattern family must always block.

import { test } from "node:test";
import assert from "node:assert/strict";

import { checkFigmaCode, explain, WRITE_METHODS } from "./check-figma-write-block.mjs";

test("must NOT block: empty / trivial read-only script", () => {
  const result = checkFigmaCode("");
  assert.equal(result.blocked, false);
  assert.equal(result.matchedPattern, null);

  const trivial = checkFigmaCode("return figma.currentPage.name;");
  assert.equal(trivial.blocked, false, trivial.reason);
});

test("must NOT block: figma-generate-design skill's own '2a-ii inspect existing screens' example", () => {
  // Copied verbatim from the skill doc's documented example. Note the
  // `uniqueSets.set(key, {...})` call is a plain JS Map#set, NOT a Figma
  // write — the denylist must never generically match `.set(`.
  const code = `
const frame = figma.currentPage.findOne(n => n.name === "Existing Screen");
const uniqueSets = new Map();
frame.findAllWithCriteria({ types: ["INSTANCE"] }).forEach(inst => {
  const mc = inst.mainComponent;
  const cs = mc?.parent?.type === "COMPONENT_SET" ? mc.parent : null;
  const key = cs ? cs.key : mc?.key;
  const name = cs ? cs.name : mc?.name;
  if (key && !uniqueSets.has(key)) {
    uniqueSets.set(key, { name, key, isSet: !!cs, sampleVariant: mc.name });
  }
});
return [...uniqueSets.values()];
`;
  const result = checkFigmaCode(code);
  assert.equal(result.blocked, false, result.reason);
  assert.equal(result.matchedPattern, null);
});

test("must block: reconstructed 2026-08-19 incident shape (create + populate + override + cleanup)", () => {
  const code = `
const screenA = figma.createAutoLayout();
const screenB = figma.createAutoLayout();
screenA.name = "Screen A";
screenB.name = "Screen B";
const component = figma.currentPage.findOne(n => n.type === "COMPONENT");
for (let i = 0; i < 56; i++) {
  const instance = component.createInstance();
  screenA.appendChild(instance);
  instance.setProperties({ Label: "Item " + i });
}
// cleanup pass
const stale = figma.currentPage.findAll(n => n.name === "stale");
stale.forEach(n => n.remove());
`;
  const result = checkFigmaCode(code);
  assert.equal(result.blocked, true);
  assert.ok(result.matchedPattern, "expected a matched pattern");
  assert.ok(explain(result).length > 0);
});

// One test per write-pattern family, each on its own minimal snippet.
const writePatternFamilies = [
  {
    label: "creation (figma.createFrame)",
    code: "const f = figma.createFrame();",
    expectedPattern: "createFrame",
  },
  {
    label: "appendChild (tree mutation)",
    code: "parentFrame.appendChild(childFrame);",
    expectedPattern: "appendChild",
  },
  {
    label: "remove (deletion)",
    code: "node.remove();",
    expectedPattern: "remove",
  },
  {
    label: "setProperties (instance content override)",
    code: "instance.setProperties({ Size: 'Large' });",
    expectedPattern: "setProperties",
  },
  {
    label: "style/variable mutation (setFillStyleIdAsync)",
    code: "await node.setFillStyleIdAsync(styleId);",
    expectedPattern: "setFillStyleIdAsync",
  },
  {
    label: "variable binding (setBoundVariable)",
    code: "node.setBoundVariable('visible', showVariable);",
    expectedPattern: "setBoundVariable",
  },
  {
    label: "property assignment (.characters =)",
    code: "textNode.characters = 'Hello';",
    expectedPattern: "characters",
  },
  {
    label: "property assignment (.visible =)",
    code: "node.visible = false;",
    expectedPattern: "visible",
  },
];

for (const { label, code, expectedPattern } of writePatternFamilies) {
  test(`must block: ${label}`, () => {
    const result = checkFigmaCode(code);
    assert.equal(result.blocked, true, `expected block for: ${code}`);
    assert.equal(result.matchedPattern, expectedPattern);
  });
}

test("must NOT false-positive on generic JS built-ins that share write-method names", () => {
  const code = `
const uniqueSets = new Map();
uniqueSets.set("a", 1);
const arr = [1, 2, 3].filter(x => x > 1);
const removeCommentsList = [];
function removeCommentsList2() { return []; }
const label = { toRemove: true };
`;
  const result = checkFigmaCode(code);
  assert.equal(result.blocked, false, result.reason);
});

test("must NOT false-positive on comparison operators against write-property names", () => {
  const code = `
if (node.visible === true) {}
if (node.locked !== false) {}
if (node.name == "x") {}
`;
  const result = checkFigmaCode(code);
  assert.equal(result.blocked, false, result.reason);
});

test("denylist does not contain unverified names: setPluginData is not a real typings-file method (only setSharedPluginData is)", () => {
  assert.ok(!WRITE_METHODS.includes("setPluginData"));
  assert.ok(WRITE_METHODS.includes("setSharedPluginData"));
});

test("must block: static bracket-notation method call (computed member access with a literal key)", () => {
  const doubleQuote = checkFigmaCode('node["remove"]();');
  assert.equal(doubleQuote.blocked, true, doubleQuote.reason);
  assert.equal(doubleQuote.matchedPattern, "remove");

  const singleQuote = checkFigmaCode("node['remove']();");
  assert.equal(singleQuote.blocked, true, singleQuote.reason);
  assert.equal(singleQuote.matchedPattern, "remove");
});

test("must block: static bracket-notation property assignment (computed member access with a literal key)", () => {
  const result = checkFigmaCode('node["name"] = "x";');
  assert.equal(result.blocked, true, result.reason);
  assert.equal(result.matchedPattern, "name");
});

test("must NOT false-positive: bracket-notation comparison against a write-property name", () => {
  const result = checkFigmaCode('if (node["visible"] === true) {}');
  assert.equal(result.blocked, false, result.reason);
});

test("documented limitation: a VARIABLE (non-literal) bracket key is not resolved and does not block", () => {
  const result = checkFigmaCode('const m = "remove"; node[m]();');
  assert.equal(
    result.blocked,
    false,
    "variable-key bracket access cannot be statically resolved by a regex scanner — documented gap, not silently accepted",
  );
});

test("known limitation: a write call disguised inside a string literal or comment still blocks (documented over-blocking, not silently accepted as a gap)", () => {
  const disguisedInComment = `
// reminder to self: never call instance.remove() carelessly
figma.currentPage.name;
`;
  const commentResult = checkFigmaCode(disguisedInComment);
  assert.equal(
    commentResult.blocked,
    true,
    "regex-based scanning is not comment-aware — this is the documented, safe-direction false positive",
  );

  const disguisedInString = `
const msg = "call frame.appendChild(x) if you want to be sneaky";
figma.currentPage.name;
`;
  const stringResult = checkFigmaCode(disguisedInString);
  assert.equal(
    stringResult.blocked,
    true,
    "regex-based scanning is not string-literal-aware — this is the documented, safe-direction false positive",
  );
});
