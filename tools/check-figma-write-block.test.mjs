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
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import path from "node:path";

import {
  checkFigmaCode,
  explain,
  WRITE_METHODS,
  WRITE_PROPERTIES,
  ALWAYS_DENY_TOOLS,
  INTERCEPTED_TOOLS,
  bareToolName,
} from "./check-figma-write-block.mjs";

const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

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

// ---------------------------------------------------------------------------
// C1 regression — the live-proven bypass payload from the final review.
// A pure-mutation script whose every write used a method/property that the
// original hand-enumerated denylist simply did not contain.
// ---------------------------------------------------------------------------

test("C1 regression: live-proven bypass payload (insertCharacters / deleteCharacters / setFillsAsync / setRangeFontSize / .x =) must block", () => {
  const code = `
const t = figma.currentPage.findOne(n => n.type === "TEXT");
await figma.loadFontAsync(t.fontName);
t.insertCharacters(0, "Hello ");
t.deleteCharacters(5, 6);
await t.setFillsAsync([{ type: "SOLID", color: { r: 1, g: 0, b: 0 } }]);
t.setRangeFontSize(0, 3, 24);
t.x = 120;
`;
  const result = checkFigmaCode(code);
  assert.equal(result.blocked, true, "the review's live bypass payload must now be caught");
});

// Each individual write from the C1 payload must block on its own, so a
// partial regeneration of the denylist can't silently drop one of them.
const c1Writes = [
  { label: "insertCharacters", code: 'textNode.insertCharacters(0, "hi");', expected: "insertCharacters" },
  { label: "deleteCharacters", code: "textNode.deleteCharacters(0, 3);", expected: "deleteCharacters" },
  { label: "setFillsAsync", code: "await node.setFillsAsync(paints);", expected: "setFillsAsync" },
  { label: "setStrokesAsync", code: "await node.setStrokesAsync(paints);", expected: "setStrokesAsync" },
  { label: "setRangeFontSize", code: "textNode.setRangeFontSize(0, 3, 24);", expected: "setRangeFontSize" },
  { label: "direct .x = assignment", code: "node.x = 120;", expected: "x" },
  { label: "direct .y = assignment", code: "node.y = 40;", expected: "y" },
  { label: "swapComponent", code: "instance.swapComponent(other);", expected: "swapComponent" },
  { label: "setValueForMode (variable write)", code: "v.setValueForMode(modeId, 8);", expected: "setValueForMode" },
  { label: ".effects = assignment", code: "node.effects = [];", expected: "effects" },
  { label: ".layoutMode = assignment", code: 'frame.layoutMode = "VERTICAL";', expected: "layoutMode" },
  { label: ".itemSpacing = assignment", code: "frame.itemSpacing = 8;", expected: "itemSpacing" },
  { label: ".opacity = assignment", code: "node.opacity = 0.5;", expected: "opacity" },
  { label: ".cornerRadius = assignment", code: "node.cornerRadius = 8;", expected: "cornerRadius" },
  { label: ".rotation = assignment", code: "node.rotation = 90;", expected: "rotation" },
  { label: "bulk node.set({...}) property write", code: 'node.set({ opacity: 0.5, name: "Card" });', expected: "set" },
];

for (const { label, code, expected } of c1Writes) {
  test(`C1 regression: must block ${label}`, () => {
    const result = checkFigmaCode(code);
    assert.equal(result.blocked, true, `expected block for: ${code}`);
    assert.equal(result.matchedPattern, expected);
  });
}

test("C1: denylist is a broad systematic sweep, not a token hand-picked subset", () => {
  assert.ok(
    WRITE_METHODS.length >= 120,
    `expected a systematic method sweep (>=120 names), got ${WRITE_METHODS.length}`,
  );
  assert.ok(
    WRITE_PROPERTIES.length >= 120,
    `expected a systematic property sweep (>=120 names), got ${WRITE_PROPERTIES.length}`,
  );
  // Every name the final review explicitly called out must be present.
  for (const m of [
    "insertCharacters",
    "deleteCharacters",
    "setFillsAsync",
    "setRangeFontSize",
    "setStrokesAsync",
    "swapComponent",
    "setValueForMode",
    "importVariableByKeyAsync",
    "resizeWithoutConstraints",
  ]) {
    assert.ok(WRITE_METHODS.includes(m), `missing write method: ${m}`);
  }
  for (const p of [
    "fills",
    "strokes",
    "effects",
    "characters",
    "visible",
    "locked",
    "name",
    "x",
    "y",
    "rotation",
    "opacity",
    "cornerRadius",
    "itemSpacing",
    "layoutMode",
    "textStyleId",
    "fillStyleId",
    "strokeStyleId",
    "effectStyleId",
    "gridStyleId",
  ]) {
    assert.ok(WRITE_PROPERTIES.includes(p), `missing write property: ${p}`);
  }
  // Sanity: generic JS scaffolding names deliberately excluded so ordinary
  // read-only inspection scripts don't trip the gate.
  for (const excluded of ["id", "type", "key", "value", "node", "nodes", "start", "end"]) {
    assert.ok(!WRITE_PROPERTIES.includes(excluded), `should not denylist generic name: ${excluded}`);
  }
});

// ---------------------------------------------------------------------------
// C2 regression — aliasing / destructuring must not bypass the gate.
// ---------------------------------------------------------------------------

test("C2 regression: destructured method call (no receiver dot) must block", () => {
  const result = checkFigmaCode("const { createFrame } = figma;\nconst f = createFrame();");
  assert.equal(result.blocked, true, "ordinary destructuring was a live-proven bypass");
  assert.equal(result.matchedPattern, "createFrame");
});

test("C2 regression: aliased method reference called bare must block", () => {
  const aliased = checkFigmaCode("const mk = figma.createFrame;\nconst f = figma.createFrame();");
  assert.equal(aliased.blocked, true, aliased.reason);

  const destructuredRemove = checkFigmaCode("const { remove } = node;\nremove();");
  assert.equal(destructuredRemove.blocked, true, destructuredRemove.reason);
  assert.equal(destructuredRemove.matchedPattern, "remove");

  const destructuredAppend = checkFigmaCode("const { appendChild } = frame;\nappendChild(child);");
  assert.equal(destructuredAppend.blocked, true, destructuredAppend.reason);
  assert.equal(destructuredAppend.matchedPattern, "appendChild");
});

// ---------------------------------------------------------------------------
// C3 regression — whitespace must not defeat the patterns.
// ---------------------------------------------------------------------------

test("C3 regression: whitespace around the dot and before the paren must block", () => {
  const spaced = checkFigmaCode("node . remove ()");
  assert.equal(spaced.blocked, true, "`node . remove ()` was a live-proven bypass");
  assert.equal(spaced.matchedPattern, "remove");
});

test("C3 regression: whitespace variants of method calls and property assignments all block", () => {
  const cases = [
    ["node\n  .remove();", "remove"],
    ["node .remove();", "remove"],
    ["node. remove();", "remove"],
    ["node.remove ();", "remove"],
    ["node . remove\n  ();", "remove"],
    ["figma . createFrame ();", "createFrame"],
    ["node . visible = false;", "visible"],
    ["node.\n  visible = false;", "visible"],
    ["node . x   =   10;", "x"],
    ['node [ "remove" ] ();', "remove"],
    ['node [ "name" ]  = "z";', "name"],
  ];
  for (const [code, expected] of cases) {
    const result = checkFigmaCode(code);
    assert.equal(result.blocked, true, `expected block for: ${JSON.stringify(code)}`);
    assert.equal(result.matchedPattern, expected, `wrong pattern for: ${JSON.stringify(code)}`);
  }
});

test("C3: whitespace tolerance did not create false positives on comparisons", () => {
  const cases = [
    "if (node . visible === true) {}",
    "if (node . name == 'x') {}",
    "if (node . locked !== false) {}",
    "if (node . x >= 10) {}",
    "if (node . y <= 10) {}",
  ];
  for (const code of cases) {
    const result = checkFigmaCode(code);
    assert.equal(result.blocked, false, `unexpected block for: ${code} — ${result.reason}`);
  }
});

// ---------------------------------------------------------------------------
// I1 — the always-deny tool set covers every content-creating live MCP tool.
// ---------------------------------------------------------------------------

test("I1: generate_diagram / upload_assets / weave_upload_asset are unconditionally denied", () => {
  for (const tool of [
    "create_new_file",
    "generate_figma_design",
    "generate_diagram",
    "upload_assets",
    "weave_upload_asset",
  ]) {
    assert.ok(ALWAYS_DENY_TOOLS.includes(tool), `missing always-deny tool: ${tool}`);
  }
  // Read-only Figma tools must NOT be in the always-deny set.
  for (const tool of [
    "get_design_context",
    "get_metadata",
    "get_screenshot",
    "search_design_system",
    "send_code_connect_mappings",
    "add_code_connect_map",
    "use_figma",
  ]) {
    assert.ok(!ALWAYS_DENY_TOOLS.includes(tool), `must not always-deny: ${tool}`);
  }
});

test("I1: bareToolName normalizes any MCP server prefix", () => {
  assert.equal(bareToolName("mcp__claude_ai_Figma__generate_diagram"), "generate_diagram");
  assert.equal(bareToolName("mcp__some_other_server__upload_assets"), "upload_assets");
  assert.equal(bareToolName("upload_assets"), "upload_assets");
  assert.equal(bareToolName(undefined), "");
});

// ---------------------------------------------------------------------------
// I2 — the .claude/settings.json wiring must actually match the real,
// fully-qualified tool names. A typo or a matcher-syntax change must break
// THIS test rather than silently disabling enforcement.
// ---------------------------------------------------------------------------

/**
 * Reimplements Claude Code's documented `matcher` semantics
 * (https://code.claude.com/docs/en/hooks): a matcher containing only letters,
 * digits, `_`, `-`, spaces, `,` and `|` is an exact string (or `|`/`,`-
 * separated list of exact strings); a matcher containing any other character
 * is an UNANCHORED JavaScript regular expression.
 */
function matcherMatches(matcher, toolName) {
  if (/^[A-Za-z0-9_\-, |]+$/.test(matcher)) {
    return matcher
      .split(/[|,]/)
      .map((s) => s.trim())
      .filter(Boolean)
      .includes(toolName);
  }
  return new RegExp(matcher).test(toolName);
}

function readSettings() {
  const raw = readFileSync(path.join(REPO_ROOT, ".claude", "settings.json"), "utf8");
  return JSON.parse(raw);
}

test("I2: .claude/settings.json is valid JSON and wires this hook under PreToolUse", () => {
  const settings = readSettings();
  const entries = (settings.hooks?.PreToolUse ?? []).filter((entry) =>
    (entry.hooks ?? []).some((h) => String(h.command ?? "").includes("check-figma-write-block.mjs")),
  );
  assert.equal(entries.length, 1, "expected exactly one PreToolUse entry for check-figma-write-block.mjs");
  assert.equal(typeof entries[0].matcher, "string");
});

test("I2: the settings.json matcher matches every real Figma tool name this hook must intercept", () => {
  const settings = readSettings();
  const entry = (settings.hooks?.PreToolUse ?? []).find((e) =>
    (e.hooks ?? []).some((h) => String(h.command ?? "").includes("check-figma-write-block.mjs")),
  );
  const { matcher } = entry;

  const liveToolNames = [
    "mcp__claude_ai_Figma__use_figma",
    "mcp__claude_ai_Figma__create_new_file",
    "mcp__claude_ai_Figma__generate_figma_design",
    "mcp__claude_ai_Figma__generate_diagram",
    "mcp__claude_ai_Figma__upload_assets",
    "mcp__claude_ai_Figma__weave_upload_asset",
  ];
  for (const toolName of liveToolNames) {
    assert.ok(
      matcherMatches(matcher, toolName),
      `settings.json PreToolUse matcher ${JSON.stringify(matcher)} does not match ${toolName}`,
    );
  }

  // Prefix-tolerant: a differently-named / reconnected Figma MCP server must
  // still be intercepted, and so must a bare (un-prefixed) spelling.
  for (const toolName of [
    "mcp__figma__use_figma",
    "mcp__plugin_figma_mcp__generate_diagram",
    "use_figma",
    "generate_figma_design",
  ]) {
    assert.ok(
      matcherMatches(matcher, toolName),
      `matcher is not prefix-tolerant: does not match ${toolName}`,
    );
  }

  // Every bare name the hook itself intercepts must be covered by the matcher.
  for (const bare of INTERCEPTED_TOOLS) {
    assert.ok(
      matcherMatches(matcher, `mcp__claude_ai_Figma__${bare}`),
      `matcher misses an intercepted tool: ${bare}`,
    );
  }

  // Must NOT over-match unrelated tools (the hook would pass them through
  // anyway, but firing on every tool call is wasteful and surprising).
  for (const toolName of [
    "Edit",
    "Write",
    "Bash",
    "mcp__claude_ai_Figma__get_design_context",
    "mcp__claude_ai_Figma__get_metadata",
    "mcp__claude_ai_Figma__send_code_connect_mappings",
  ]) {
    assert.equal(
      matcherMatches(matcher, toolName),
      false,
      `matcher should not intercept ${toolName}`,
    );
  }
});

test("I2: settings.json PostToolUse wiring is untouched by this change", () => {
  const settings = readSettings();
  const post = settings.hooks?.PostToolUse ?? [];
  assert.equal(post.length, 1);
  assert.equal(post[0].matcher, "Edit|Write");
  const commands = post[0].hooks.map((h) => h.command);
  assert.ok(commands.some((c) => c.includes("check-layout-only-classes.mjs")));
  assert.ok(commands.some((c) => c.includes("nudge-m3e-skill.mjs")));
});

// ---------------------------------------------------------------------------
// I4 — the deny message must not recommend a workflow that is itself blocked.
// ---------------------------------------------------------------------------

test("I4: the deny message offers no blocked workaround and points at the Figma UI", () => {
  const message = explain(checkFigmaCode("node.remove();"));
  assert.ok(message.includes("Figma UI"), "must direct the human to the Figma UI");
  assert.ok(
    /not available|NOT AVAILABLE/.test(message),
    "must state plainly that code-driven authoring is unavailable",
  );
  // These are themselves denied by this hook — recommending them causes a loop.
  assert.ok(!message.includes("figma-generate-design"), "must not recommend a blocked workflow");
  assert.ok(!message.includes("figma-code-connect"), "must not recommend a blocked workflow");
});
