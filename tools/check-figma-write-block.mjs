#!/usr/bin/env node
// tools/check-figma-write-block.mjs — pure, dependency-free static-analysis
// classifier for `use_figma` MCP tool calls: decides whether a JS `code`
// string is read-only inspection or performs a Figma Plugin API WRITE.
//
// WHY THIS EXISTS (see docs/plans/2026-08-19-block-figma-content-authoring.md):
// on 2026-08-19 an agent used the `use_figma` tool to author Figma content
// directly via arbitrary JS (creating ~56 component instances with
// `figma.createAutoLayout()` / `.createInstance()` / `.appendChild()`,
// overriding text with `.setProperties()`, then `.remove()`-ing nodes during
// cleanup) instead of going through the reviewed, skill-driven authoring
// workflow. This module is the pure decision function for a later PreToolUse
// hook (NOT built here) that will block `use_figma` calls whose `code`
// contains a Plugin API write. This file only exports the classifier + a
// human-readable explainer; it does not read stdin, parse hook JSON, or wire
// into `.claude/settings.json` — that's a separate task.
//
// DENYLIST SOURCE OF TRUTH: every name below was found by grepping the
// installed Figma plugin's own TypeScript API typings —
//   ~/.claude/plugins/cache/claude-plugins-official/figma/2.2.95/skills/figma-use/references/plugin-api-standalone.d.ts
// (11,329 lines, checked 2026-08-19). See task-1-report.md for the exact
// grep commands and line numbers. Two names mentioned as "check for these"
// in the task brief do NOT exist in this typings file and are deliberately
// OMITTED (not invented): `createSlot` (no such method anywhere in the
// file) and any bare `setVariableCodeSyntax`-style getter — the real name is
// `Variable.setVariableCodeSyntax(platform, value)`, which IS included below.
//
// DETECTION STRATEGY (deliberate subset — this is NOT a JS parser):
//   - Method calls: matched as `.methodName(` OR the equivalent computed
//     member-access call with a STATIC string-literal key —
//     `["methodName"](`/`['methodName'](`/`` [`methodName`]( ``. The leading
//     `.` (or bracket) plus an immediately-following `(` (whitespace
//     allowed) means a bare function call (`remove()`) or an unrelated
//     identifier that merely CONTAINS the name (`removeCommentsList()`,
//     `list.set(...)` on a plain `Map`/`Array`) never matches. Only
//     Figma-specific, spelled-out method names are denylisted — generic JS
//     built-ins (`Map#set`, `Array#forEach`, `Array#filter`, …) are never in
//     this list, so `uniqueSets.set(key, …)` in an otherwise read-only
//     inspection script is not a match.
//   - Property writes: matched as `.propName` OR the bracket-literal
//     equivalent (`["propName"]`/`['propName']`), followed by optional
//     whitespace and a single `=` that is NOT itself followed by another
//     `=` (so `==` / `===` comparisons never match; `!=`/`<=`/`>=` already
//     fail because the character immediately after propName+whitespace is
//     `!`/`<`/`>`, not `=`).
//
// KNOWN LIMITATIONS (documented, not silently accepted):
//   1. This is regex/substring scanning over the raw source text, NOT an AST
//      parse. A write call name that happens to appear inside a STRING
//      LITERAL or a COMMENT (e.g. `// remember: instance.remove() is scary`
//      or `const msg = "call frame.appendChild(x)"`) WILL still match and
//      cause a block, even though no write actually executes. This is a
//      false positive, not a false negative — for a blocking security-ish
//      gate we accept over-blocking (safe failure mode) rather than risk
//      under-blocking disguised writes; see the "disguised write" test case.
//   2. A handful of Figma property names are common English words that could
//      appear as a plain-JS object's own property outside any Figma context
//      (`.name = `, `.visible = `, `.locked = `). If a `use_figma` script
//      also manipulates an unrelated local object with one of these property
//      names via direct assignment, that would also be flagged. This is a
//      deliberate false-positive risk we accept in exchange for catching
//      real Figma node renames/visibility/lock writes, which ARE
//      content-authoring actions.
//   3. Chained/computed receivers (`getNode().remove()`, `arr[0].remove()`)
//      still match because detection only requires a literal `.` immediately
//      before the name — it does not attempt to resolve what the receiver
//      is. This is intentional: we'd rather over-block an ambiguous receiver
//      than miss a real Figma write reached through a helper function.
//   4. No attempt is made to understand control flow, so a write call inside
//      an `if (false)` branch or dead code still blocks. Given the goal (gate
//      agent-authored `use_figma` scripts before they run), this is the
//      correct conservative default.
//   5. BRACKET NOTATION with a STATIC string-literal key IS detected
//      (`node["remove"]()`, `node['name'] = "x"`) — see DETECTION STRATEGY
//      above. What is still a genuine, UNDETECTED gap: a bracket access
//      whose key is a VARIABLE or computed expression, e.g.
//      `const m = "remove"; node[m]()`, or a template literal with
//      interpolation (`` node[`re${"move"}`]() ``). Resolving those requires
//      at minimum constant-folding/light data-flow analysis, which is out of
//      scope for a regex-based scanner. Also undetected: whole-object
//      mutation helpers like `Object.assign(node, { visible: false })` or
//      `Object.defineProperty(node, "visible", …)` — these never take the
//      `.propName =` or `["propName"] =` shape this scanner looks for. Both
//      are accepted gaps for this task; a later hardening pass could add a
//      lightweight check for `Object.assign(` / `Object.defineProperty(`
//      calls whose second argument is an object literal or string containing
//      a denylisted property name, if this proves to be exploited in
//      practice.

// ---------------------------------------------------------------------------
// Denylist: Figma Plugin API methods that create, mutate, reparent, restyle,
// or delete document content. Grouped by typings-file section for traceability.
// ---------------------------------------------------------------------------

const WRITE_METHODS = [
  // Node/style/variable creation (figma.createX(...) factory methods).
  "createRectangle",
  "createLine",
  "createEllipse",
  "createPolygon",
  "createStar",
  "createVector",
  "createText",
  "createFrame",
  "createAutoLayout",
  "createComponent",
  "createComponentFromNode",
  "createPage",
  "createPageDivider",
  "createSlice",
  "createSlide",
  "createSlideRow",
  "createSticky",
  "createConnector",
  "createShapeWithText",
  "createCodeBlock",
  "createSection",
  "createTable",
  "createTextPath",
  "createNodeFromJSXAsync",
  "createBooleanOperation",
  "createPaintStyle",
  "createTextStyle",
  "createEffectStyle",
  "createGridStyle",
  "createNodeFromSvg",
  "createImage",
  "createImageAsync",
  "createVideoAsync",
  "createLinkPreviewAsync",
  "createGif",
  "createCanvasRow",
  "createVariable",
  "createVariableCollection",
  "createVariableAlias",
  "createVariableAliasByIdAsync",
  "createInstance",

  // Tree mutation: reparenting, resizing, duplicating, deleting.
  "appendChild",
  "appendChildAt",
  "insertChild",
  "remove",
  "resize",
  "clone",
  "group",
  "ungroup",
  "flatten",
  "union",
  "subtract",
  "intersect",
  "exclude",

  // Instance/component-property content overrides.
  "setProperties",

  // Variable binding (ties node fields to design-token variables).
  "setBoundVariable",
  "setBoundVariableForPaint",
  "setBoundVariableForEffect",
  "setBoundVariableForLayoutGrid",
  "setVariableCodeSyntax",

  // Style application — the async setters that assign a shared style id.
  "setFillStyleIdAsync",
  "setStrokeStyleIdAsync",
  "setEffectStyleIdAsync",
  "setGridStyleIdAsync",
  "setTextStyleIdAsync",

  // Component/variant authoring.
  "combineAsVariants",
  "addComponentProperty",
  "editComponentProperty",
  "deleteComponentProperty",

  // Node metadata writes + library imports (imports create local nodes/styles).
  // NOTE: `setPluginData` (without "Shared") was removed from this list after
  // a 2026-08-19 review found zero occurrences of that exact name anywhere in
  // the typings file — only `setSharedPluginData` is real. Do not re-add it
  // without a fresh grep hit as evidence.
  "setSharedPluginData",
  "setRelaunchData",
  "importComponentByKeyAsync",
  "importComponentSetByKeyAsync",
  "importStyleByKeyAsync",
];

// Figma node properties that are plain, settable (non-readonly) TS fields in
// the typings file — assigning to them directly mutates document content.
const WRITE_PROPERTIES = [
  "fills",
  "strokes",
  "characters",
  "visible",
  "locked",
  "name",
  "textStyleId",
  "fillStyleId",
  "strokeStyleId",
  "effectStyleId",
  "gridStyleId",
];

// ---------------------------------------------------------------------------
// Pattern compilation
// ---------------------------------------------------------------------------

// A JS string-literal quote character usable inside a `[...]` computed
// member access: `["name"]`, `['name']`, or a plain (no-interpolation)
// `` [`name`] `` template literal.
const QUOTE = `['"\`]`;

function methodPattern(name) {
  // Two call shapes, either is a real Figma write:
  //   - `.name(`               dot-prefixed so a bare `remove()` call never
  //                            matches, and the immediately-following `(`
  //                            (mod whitespace) so `removeCommentsList(`
  //                            never matches `remove`.
  //   - `["name"](`/`['name'](` — the equivalent computed-member-access call
  //                            shape with a STATIC string-literal key. Only
  //                            a literal key is detected; a *variable* key
  //                            (`node[m]()`) cannot be resolved by regex and
  //                            remains a documented limitation (see header).
  const dot = `\\.${name}\\s*\\(`;
  const bracket = `\\[\\s*${QUOTE}${name}${QUOTE}\\s*\\]\\s*\\(`;
  return { name, kind: "method call", regex: new RegExp(`(?:${dot}|${bracket})`, "g") };
}

function propertyPattern(name) {
  // Two assignment shapes, either is a real Figma write:
  //   - `.name =`         but not `.name ==`/`.name ===`. `.name !=`/
  //                       `.name <=`/`.name >=` never reach the lookahead
  //                       because the char right after `name`+whitespace is
  //                       `!`/`<`/`>`, not `=`.
  //   - `["name"] =`/`['name'] =` — the equivalent computed-member-access
  //                       assignment with a STATIC string-literal key; same
  //                       `==`/`===` exclusion. A variable key remains a
  //                       documented limitation.
  const dot = `\\.${name}\\s*=(?!=)`;
  const bracket = `\\[\\s*${QUOTE}${name}${QUOTE}\\s*\\]\\s*=(?!=)`;
  return { name, kind: "property assignment", regex: new RegExp(`(?:${dot}|${bracket})`, "g") };
}

const DENYLIST = [
  ...WRITE_METHODS.map(methodPattern),
  ...WRITE_PROPERTIES.map(propertyPattern),
];

// ---------------------------------------------------------------------------
// Classification
// ---------------------------------------------------------------------------

const lineOf = (source, index) => source.slice(0, index).split("\n").length;

/**
 * Classify a `use_figma` `code` string as read-only or blocked.
 *
 * @param {string} code
 * @returns {{ blocked: boolean, reason: string | null, matchedPattern: string | null }}
 */
export function checkFigmaCode(code) {
  if (typeof code !== "string" || code.length === 0) {
    return { blocked: false, reason: null, matchedPattern: null };
  }

  for (const pattern of DENYLIST) {
    pattern.regex.lastIndex = 0;
    const match = pattern.regex.exec(code);
    if (match) {
      const line = lineOf(code, match.index);
      return {
        blocked: true,
        reason: `Figma Plugin API write detected: ${pattern.kind} \`${match[0].trim()}\` (pattern: ${pattern.name}) at line ${line}.`,
        matchedPattern: pattern.name,
      };
    }
  }

  return { blocked: false, reason: null, matchedPattern: null };
}

/**
 * Human-readable explanation for a blocked result, suitable for surfacing to
 * an agent as PreToolUse feedback (built by the later hook-wiring task).
 *
 * @param {{ blocked: boolean, reason: string | null, matchedPattern: string | null }} result
 * @returns {string}
 */
export function explain(result) {
  if (!result.blocked) return "";
  return [
    result.reason,
    "",
    "Direct `use_figma` JavaScript may not create, mutate, restyle, reparent,",
    "or delete Figma document content. Content authoring must go through the",
    "reviewed `figma-generate-design` / `figma-code-connect` skill workflows,",
    "not ad hoc Plugin API calls.",
    "  - See: docs/plans/2026-08-19-block-figma-content-authoring.md",
  ].join("\n");
}

export { DENYLIST, WRITE_METHODS, WRITE_PROPERTIES };
