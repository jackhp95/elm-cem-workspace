#!/usr/bin/env node
// tools/check-figma-write-block.mjs — dependency-free static-analysis
// classifier for Figma MCP tool calls PLUS the Claude Code `PreToolUse` hook
// CLI that uses it. BOTH live in this one file (mirroring
// tools/check-layout-only-classes.mjs's file shape: the pure classifier and
// the CLI entry point ship together; the test file imports the pure exports
// directly, never through the CLI).
//
// WHAT THIS FILE IS
//   1. `checkFigmaCode(code)` — a pure function that decides whether a
//      `use_figma` JavaScript `code` string is read-only inspection or
//      performs a Figma Plugin API WRITE. Returns
//      `{ blocked, reason, matchedPattern }`.
//   2. `explain(result)` — the human-readable deny message.
//   3. `--hook` mode — a Claude Code `PreToolUse` hook: reads the hook JSON on
//      stdin (`tool_name` + `tool_input`) and:
//        - any tool in ALWAYS_DENY_TOOLS (`create_new_file`,
//          `generate_figma_design`, `generate_diagram`, `upload_assets`,
//          `weave_upload_asset`): ALWAYS denied. These have no read-only mode;
//          every one of them creates or mutates Figma content.
//        - `use_figma`: runs checkFigmaCode(tool_input.code); denies with
//          explain(result) if blocked, allows otherwise.
//        - any other tool_name: passes through immediately, unaffected.
//      Blocking is signalled via the PreToolUse JSON contract (stdout JSON
//      body `{ hookSpecificOutput: { hookEventName, permissionDecision:
//      "deny", permissionDecisionReason } }`, exit 0), NOT via a nonzero exit
//      code — this is DIFFERENT from check-layout-only-classes.mjs's
//      PostToolUse contract (blocks via exit 2 + stderr text). Confirmed
//      against the working PreToolUse example already live in this harness,
//      ~/.claude/hooks/block-external-pr.sh.
//
// WIRE-NAME MATCHING
//   Claude Code MCP tool names arrive wire-formatted as `mcp__<server>__<tool>`
//   (confirmed live: `mcp__claude_ai_Figma__use_figma`). This hook matches on
//   the suffix after the last `__` (see bareToolName), so it is INDEPENDENT of
//   which MCP server name the Figma connector happens to register under. The
//   `.claude/settings.json` matcher is correspondingly written as a
//   prefix-tolerant regex — `^(mcp__.*__)?(use_figma|...)$` — because Claude
//   Code treats a matcher containing non-word characters as an unanchored
//   JavaScript regex (a matcher of only letters/digits/`_`/`-`/`|`/`,` is
//   compared as EXACT strings instead). That wiring is pinned by a test in
//   check-figma-write-block.test.mjs so a typo cannot ship silently.
//
// ERROR-SAFETY: an internal error reading/parsing THIS hook's own stdin JSON
// (bad JSON, missing fields, etc.) must NEVER accidentally block an unrelated
// tool call — it fails safe by NOT blocking (mirroring
// check-layout-only-classes.mjs's "never block an edit because THIS script
// broke" policy), but DOES log to stderr so the failure is visible. This is
// intentionally DIFFERENT from the "default to block on ambiguity" principle
// that governs classifying `use_figma` CODE content (checkFigmaCode's job) —
// that principle is about content classification, not hook-infrastructure
// errors.
//
// WHY THIS EXISTS (see docs/plans/2026-08-19-block-figma-content-authoring.md):
// on 2026-08-19 an agent used the `use_figma` tool to author Figma content
// directly via arbitrary JS (creating ~56 component instances with
// `figma.createAutoLayout()` / `.createInstance()` / `.appendChild()`,
// overriding text with `.setProperties()`, then `.remove()`-ing nodes during
// cleanup) instead of leaving content authoring to a human in the Figma UI.
// D6 (core/cem-figma-connect/plans/00-mission-and-decisions.md) bans
// code-driven Figma content authoring permanently; this file is the mechanical
// enforcement of that ban.
//
// ===========================================================================
// DENYLIST PROVENANCE — how WRITE_METHODS / WRITE_PROPERTIES were built
// ===========================================================================
// Source of truth (the ONLY source; nothing below was written from memory):
//   ~/.claude/plugins/cache/claude-plugins-official/figma/2.2.95/skills/
//     figma-use/references/plugin-api-standalone.d.ts
//   11,329 lines, Figma plugin package version 2.2.95, swept 2026-08-19.
//
// This section is deliberately self-contained: earlier revisions of this file
// pointed at `task-1-report.md` / `task-2-report.md` for the grep evidence,
// but those live under `.superpowers/sdd/` which is gitignored, so anyone who
// clones this branch cannot read them. The methodology is therefore inlined.
//
// METHODS sweep (mechanical, not hand-picked):
//   Extract every method DECLARATION in the typings file — lines matching
//     /^\s{2,}([A-Za-z_$][A-Za-z0-9_$]*)\??(?:<[^(]*>)?\(/
//   (indented `name(` or `name<T>(` signature; this shape excludes doc-comment
//   prose, which is always prefixed by `*`), then keep those whose name starts
//   with any of these 20 mutation-verb prefixes:
//     set insert delete add create move append swap combine clone remove
//     resize import edit union subtract intersect exclude group ungroup flatten
//   Raw hits: 160 distinct names. 8 were removed by hand as verified
//   NON-content-mutating, each checked at its declaration site:
//     - `set`            BaseNodeMixin.set(props) / QueryResult.set(props) —
//                        a REAL bulk write, but the bare name collides with
//                        `Map#set`/`Set#add`-style everyday JS. Handled
//                        separately by BULK_WRITE_PATTERNS below, which
//                        requires an object-literal first argument
//                        (`.set({ … })`) — see the residual-risk note.
//     - `setAsync`       ClientStorageAPI.setAsync — plugin-local storage.
//     - `setError`, `setSuggestions`, `setLoadingMessage`
//                        parameter-input UI (SuggestionResults), not content.
//     - `setCurrentPageAsync`  navigation only; a legitimate read-only script
//                        may need it to inspect another page.
//     - `setPaymentStatusInDevelopment`  payments API, not content.
//   Final: 152 method names.
//
// PROPERTIES sweep (mechanical, then hand-verified):
//   Extract every NON-`readonly` field declaration — lines matching
//     /^\s{2,}([A-Za-z_$][A-Za-z0-9_$]*)\??:\s/
//   (the `readonly ` keyword, when present, sits between the indentation and
//   the name, so `readonly` fields simply do not match this anchor). Then keep
//   a name only if at least one of its declaring interfaces is a document
//   object — interface name ending in Node / Mixin / Style / Variable /
//   VariableCollection / Document — and NOT an options/event/result-shaped
//   interface (…Options, …Event, …Change, …API, …Result, …Settings, …Data,
//   …Manifest, …Preferences, …Parameters, …Response, …Request, …Info,
//   …Payload, …Message, …Config).
//   Raw hits: 188 names. 26 removed by hand after checking each declaration
//   site: they matched only because they are method-PARAMETER-object or
//   return-object fields nested inside a Node/Mixin interface body, not
//   settable node properties — and each is a common everyday-JS identifier
//   whose inclusion would have caused real false positives:
//     id type node nodes start end side offset key value values field fields
//     options newValue criteria freeText variable variableId url currentUrl
//     resolvedType boundVariables modeId parentModeId libraryName placeholder
//   Final: 162 property names, including every name the review called out:
//   fills strokes effects characters visible locked name x y rotation opacity
//   cornerRadius itemSpacing layoutMode and all five *StyleId fields.
//
// HONEST SCOPE STATEMENT — READ THIS BEFORE TRUSTING THIS GATE
//   This is an ENUMERATION against a FIXED, SNAPSHOTTED API surface (Figma
//   plugin typings 2.2.95). It is NOT a formal guarantee and NOT a proof of
//   completeness. It is broad and systematically derived rather than
//   hand-picked, but:
//     - a write method that Figma ADDS in a future API version is not covered
//       until this sweep is re-run against the new typings;
//     - a write method whose name does not begin with one of the 20 mutation
//       verbs above (an unusual naming choice, but possible) is not covered;
//     - the 8 methods and 26 properties excluded above are deliberate
//       false-positive trade-offs, and `set`/`setAsync`/`value` in particular
//       are real (if awkwardly named) write surfaces that are only partially
//       covered.
//   A future or unusual write call not covered by this sweep CAN still slip
//   through this hook undetected. That is a disclosed residual risk, not a
//   solved problem. The durable protection against code-driven Figma authoring
//   remains the D6 ruling itself; this hook is a mechanical backstop for the
//   known API surface.
//
// DETECTION STRATEGY (deliberately not a JS parser):
//   - Method calls: matched by NAME ANYWHERE it is called, as
//     `\bmethodName\s*\(` — with or without a receiver. This intentionally
//     covers ALL of:
//         node.remove()                 ordinary call
//         node . remove ()              whitespace around the dot / paren
//         node\n  .remove()             chained/multiline formatting
//         const { createFrame } = figma; createFrame()
//                                       destructured / aliased call
//         getNode().remove()            computed receiver
//     Requiring a leading `.` (the previous behaviour) was live-proven
//     bypassable by ordinary destructuring, so the receiver is no longer part
//     of the pattern. The cost is that a hypothetical unrelated LOCAL function
//     sharing a Figma write-method name would also be blocked — accepted, the
//     same over-blocking trade-off already accepted for common-word property
//     names. `\b` + an immediately-following `(` still means
//     `removeCommentsList()` never matches `remove`, and generic JS built-ins
//     (`Map#set`, `Array#filter`, …) are not on the list at all.
//   - Method calls, bracket form: the computed member-access call with a
//     STATIC string-literal key is also matched —
//     `["methodName"](` / `['methodName'](` / `` [`methodName`]( ``.
//   - Property writes: matched as `.propName =` (whitespace tolerated around
//     the dot and before the `=`) or the bracket-literal equivalent
//     (`["propName"] =`), where the `=` is NOT followed by another `=` (so
//     `==` / `===` never match; `!=` / `<=` / `>=` never reach the lookahead
//     because the character right after propName+whitespace is `!`/`<`/`>`).
//     Property writes still REQUIRE a receiver dot/bracket — matching a bare
//     `propName =` would flag every `const name = …` in ordinary JS.
//
// KNOWN LIMITATIONS (documented, not silently accepted):
//   1. This is regex scanning over raw source text, NOT an AST parse. A write
//      call name appearing inside a STRING LITERAL or COMMENT (e.g.
//      `// never call instance.remove()`) WILL match and block, even though no
//      write executes. That is a false positive, not a false negative — for a
//      blocking gate we accept over-blocking over risking under-blocking.
//   2. Several Figma property names are common English words (`name`,
//      `visible`, `locked`, `x`, `y`, `description`, `code`). Direct
//      assignment to one of these on an unrelated local object also blocks.
//      Deliberate trade-off.
//   3. No control-flow understanding: a write inside `if (false)` still blocks.
//   4. Bracket access with a VARIABLE or computed key is NOT detected
//      (`const m = "remove"; node[m]()`, `` node[`re${"move"}`]() ``).
//      Resolving those needs constant folding / data-flow analysis.
//   5. Whole-object mutation helpers are NOT detected:
//      `Object.assign(node, { visible: false })`,
//      `Object.defineProperty(node, "visible", …)` — neither takes the
//      `.propName =` shape. `.set({ … })` IS detected (BULK_WRITE_PATTERNS),
//      but `node.set(propsFromAVariable)` is not.
//   6. See the HONEST SCOPE STATEMENT above: API-surface completeness is not
//      guaranteed.

// ---------------------------------------------------------------------------
// Denylist: Figma Plugin API methods that create, mutate, reparent, restyle,
// or delete document content. Generated by the METHODS sweep documented above
// (152 names, prefix-verb sweep of plugin typings 2.2.95, 8 hand-verified
// non-content names removed).
// ---------------------------------------------------------------------------

const WRITE_METHODS = [
  "addAnnotationCategoryAsync",
  "addComponentProperty",
  "addDevResourceAsync",
  "addMeasurement",
  "addMode",
  "appendChild",
  "appendChildAt",
  "clone",
  "cloneWidget",
  "combineAsVariants",
  "createAutoLayout",
  "createBooleanOperation",
  "createCanvasRow",
  "createCodeBlock",
  "createComponent",
  "createComponentFromNode",
  "createConnector",
  "createEffectStyle",
  "createEllipse",
  "createFrame",
  "createGif",
  "createGridStyle",
  "createImage",
  "createImageAsync",
  "createInstance",
  "createLine",
  "createLinkPreviewAsync",
  "createNodeFromJSXAsync",
  "createNodeFromSvg",
  "createPage",
  "createPageDivider",
  "createPaintStyle",
  "createPolygon",
  "createRectangle",
  "createSection",
  "createShapeWithText",
  "createSlice",
  "createSlide",
  "createSlideRow",
  "createStar",
  "createSticky",
  "createTable",
  "createText",
  "createTextPath",
  "createTextStyle",
  "createVariable",
  "createVariableAlias",
  "createVariableAliasByIdAsync",
  "createVariableCollection",
  "createVector",
  "createVideoAsync",
  "deleteAsync",
  "deleteCharacters",
  "deleteComponentProperty",
  "deleteDevResourceAsync",
  "deleteMeasurement",
  "editComponentProperty",
  "editDevResourceAsync",
  "editMeasurement",
  "exclude",
  "flatten",
  "group",
  "importComponentByKeyAsync",
  "importComponentSetByKeyAsync",
  "importStyleByKeyAsync",
  "importVariableByKeyAsync",
  "insertCharacters",
  "insertChild",
  "insertColumn",
  "insertRow",
  "intersect",
  "moveColumn",
  "moveLocalEffectFolderAfter",
  "moveLocalEffectStyleAfter",
  "moveLocalGridFolderAfter",
  "moveLocalGridStyleAfter",
  "moveLocalPaintFolderAfter",
  "moveLocalPaintStyleAfter",
  "moveLocalTextFolderAfter",
  "moveLocalTextStyleAfter",
  "moveNodesToCoord",
  "moveRow",
  "remove",
  "removeColumn",
  "removeMode",
  "removeOverrideForMode",
  "removeOverrides",
  "removeOverridesForVariable",
  "removeRow",
  "removeVariableCodeSyntax",
  "resize",
  "resizeColumn",
  "resizeRow",
  "resizeWithoutConstraints",
  "setBoundVariable",
  "setBoundVariableForEffect",
  "setBoundVariableForLayoutGrid",
  "setBoundVariableForPaint",
  "setBuzzAssetTypeForNode",
  "setCanvasGrid",
  "setColor",
  "setDevResourcePreviewAsync",
  "setEffectStyleIdAsync",
  "setExplicitVariableModeForCollection",
  "setFileThumbnailNodeAsync",
  "setFillStyleIdAsync",
  "setFillsAsync",
  "setGridChildPosition",
  "setGridStyleIdAsync",
  "setLabel",
  "setMediaAsync",
  "setProperties",
  "setRangeBoundVariable",
  "setRangeFillStyleId",
  "setRangeFillStyleIdAsync",
  "setRangeFills",
  "setRangeFontName",
  "setRangeFontSize",
  "setRangeHyperlink",
  "setRangeIndentation",
  "setRangeLetterSpacing",
  "setRangeLineHeight",
  "setRangeListOptions",
  "setRangeListSpacing",
  "setRangeParagraphIndent",
  "setRangeParagraphSpacing",
  "setRangeTextCase",
  "setRangeTextDecoration",
  "setRangeTextDecorationColor",
  "setRangeTextDecorationOffset",
  "setRangeTextDecorationSkipInk",
  "setRangeTextDecorationStyle",
  "setRangeTextDecorationThickness",
  "setRangeTextStyleId",
  "setRangeTextStyleIdAsync",
  "setReactionsAsync",
  "setRelaunchData",
  "setSharedPluginData",
  "setSlideGrid",
  "setSlideTransition",
  "setStrokeStyleIdAsync",
  "setStrokesAsync",
  "setTextStyleIdAsync",
  "setValueAsync",
  "setValueForMode",
  "setVariableCodeSyntax",
  "setVectorNetworkAsync",
  "setWidgetSyncedState",
  "subtract",
  "swapComponent",
  "ungroup",
  "union",
];

// Figma document-object properties that are plain, settable (non-`readonly`)
// TS fields in the typings file — assigning to one directly mutates document
// content. Generated by the PROPERTIES sweep documented above (162 names).
const WRITE_PROPERTIES = [
  "annotations",
  "arcData",
  "authorName",
  "authorVisible",
  "autoRename",
  "backgroundStyleId",
  "backgrounds",
  "blendMode",
  "booleanOperation",
  "bottomLeftRadius",
  "bottomRightRadius",
  "characters",
  "clipsContent",
  "code",
  "complexStrokeProperties",
  "connectorEnd",
  "connectorEndStrokeCap",
  "connectorLineType",
  "connectorStart",
  "connectorStartStrokeCap",
  "constrainProportions",
  "constraints",
  "cornerRadius",
  "cornerSmoothing",
  "counterAxisAlignContent",
  "counterAxisAlignItems",
  "counterAxisSizingMode",
  "counterAxisSpacing",
  "dashPattern",
  "defaultValue",
  "description",
  "descriptionMarkdown",
  "devStatus",
  "documentationLinks",
  "effectStyleId",
  "effects",
  "expanded",
  "explicitVariableModes",
  "exportSettings",
  "fillStyleId",
  "fills",
  "flowStartingPoints",
  "focusedNode",
  "focusedSlide",
  "fontName",
  "fontSize",
  "gridChildHorizontalAlign",
  "gridChildVerticalAlign",
  "gridColumnCount",
  "gridColumnGap",
  "gridColumnSizes",
  "gridColumnSpan",
  "gridRowCount",
  "gridRowGap",
  "gridRowSizes",
  "gridRowSpan",
  "gridStyleId",
  "guides",
  "handleMirroring",
  "hangingList",
  "hangingPunctuation",
  "hiddenFromPublishing",
  "horizontalPadding",
  "hyperlink",
  "inferredAutoLayout",
  "innerRadius",
  "isExposedInstance",
  "isMask",
  "isPageDivider",
  "isSkippedSlide",
  "isWideWidth",
  "itemReverseZIndex",
  "itemSpacing",
  "layoutAlign",
  "layoutGrids",
  "layoutGrow",
  "layoutMode",
  "layoutPositioning",
  "layoutSizingHorizontal",
  "layoutSizingVertical",
  "layoutWrap",
  "leadingTrim",
  "letterSpacing",
  "lineHeight",
  "listSpacing",
  "locked",
  "mainComponent",
  "maskType",
  "maxHeight",
  "maxLines",
  "maxWidth",
  "minHeight",
  "minWidth",
  "name",
  "nodeId",
  "numberOfFixedChildren",
  "opacity",
  "overflowDirection",
  "overriddenFields",
  "paddingBottom",
  "paddingLeft",
  "paddingRight",
  "paddingTop",
  "paints",
  "paragraphIndent",
  "paragraphSpacing",
  "pointCount",
  "preferredValues",
  "primaryAxisAlignItems",
  "primaryAxisSizingMode",
  "propertyName",
  "prototypeBackgrounds",
  "reactions",
  "relativeTransform",
  "resolvedVariableModes",
  "rotation",
  "scaleFactor",
  "scopes",
  "sectionContentsHidden",
  "selectedTextRange",
  "selection",
  "speakerNotes",
  "strokeAlign",
  "strokeBottomWeight",
  "strokeCap",
  "strokeJoin",
  "strokeLeftWeight",
  "strokeMiterLimit",
  "strokeRightWeight",
  "strokeStyleId",
  "strokeTopWeight",
  "strokeWeight",
  "strokes",
  "strokesIncludedInLayout",
  "stuckTo",
  "syncedMap",
  "syncedMapOverrides",
  "syncedState",
  "syncedStateOverrides",
  "textAlignHorizontal",
  "textAlignVertical",
  "textAutoResize",
  "textCase",
  "textDecoration",
  "textDecorationColor",
  "textDecorationOffset",
  "textDecorationSkipInk",
  "textDecorationStyle",
  "textDecorationThickness",
  "textPathStartData",
  "textStyleId",
  "textTruncation",
  "topLeftRadius",
  "topRightRadius",
  "transformModifiers",
  "variableWidthStrokeProperties",
  "vectorNetwork",
  "vectorPaths",
  "verticalPadding",
  "visible",
  "x",
  "y",
];

// ---------------------------------------------------------------------------
// Pattern compilation
// ---------------------------------------------------------------------------

// A JS string-literal quote character usable inside a `[...]` computed
// member access: `["name"]`, `['name']`, or a plain (no-interpolation)
// `` [`name`] `` template literal.
const QUOTE = `['"\`]`;

function methodPattern(name) {
  // Match the method NAME being CALLED, regardless of receiver:
  //   `node.remove()`, `node . remove ()`, `node\n  .remove()`,
  //   `createFrame()` (destructured off `figma`), `getNode().remove()`.
  // `\b` plus an immediately-following `(` (whitespace allowed) means
  // `removeCommentsList()` never matches `remove`.
  const bare = `\\b${name}\\s*\\(`;
  // Computed member access with a STATIC string-literal key.
  const bracket = `\\[\\s*${QUOTE}${name}${QUOTE}\\s*\\]\\s*\\(`;
  return { name, kind: "method call", regex: new RegExp(`(?:${bare}|${bracket})`, "g") };
}

function propertyPattern(name) {
  // `.name =` (whitespace tolerated around the dot and before the `=`) or the
  // bracket-literal equivalent. `=(?!=)` excludes `==`/`===`. A receiver
  // dot/bracket IS required here — a bare `name =` would flag every ordinary
  // `const name = …`.
  const dot = `\\.\\s*${name}\\s*=(?!=)`;
  const bracket = `\\[\\s*${QUOTE}${name}${QUOTE}\\s*\\]\\s*=(?!=)`;
  return { name, kind: "property assignment", regex: new RegExp(`(?:${dot}|${bracket})`, "g") };
}

// Special-cased bulk writes whose method name is too generic to denylist by
// name alone. `BaseNodeMixin.set(props)` / `QueryResult.set(props)` are real
// bulk property writes (`node.set({ opacity: 0.5, name: "Card" })`), but the
// bare name `set` collides with `Map#set` and friends, so we require an
// object-literal first argument. `node.set(varHoldingProps)` is therefore an
// accepted gap (limitation 5 above).
const BULK_WRITE_PATTERNS = [
  {
    name: "set",
    kind: "bulk property write",
    regex: /\bset\s*\(\s*\{/g,
  },
];

const DENYLIST = [
  ...WRITE_METHODS.map(methodPattern),
  ...WRITE_PROPERTIES.map(propertyPattern),
  ...BULK_WRITE_PATTERNS,
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
 * Human-readable explanation for a blocked result, surfaced to the agent as
 * PreToolUse feedback.
 *
 * Deliberately offers NO code-driven workaround: every code path that could
 * author Figma content (`use_figma` writes, `generate_figma_design`,
 * `generate_diagram`, `create_new_file`, asset upload) is denied by this same
 * hook, so pointing at a "use the skill workflow instead" alternative would
 * send the agent into a loop.
 *
 * @param {{ blocked: boolean, reason: string | null, matchedPattern: string | null }} result
 * @returns {string}
 */
export function explain(result) {
  if (!result.blocked) return "";
  return [
    result.reason,
    "",
    "Code-driven Figma content authoring is NOT AVAILABLE in this repo, by",
    "design and permanently (decision D6). There is no alternative tool, skill,",
    "or workflow that will let you do this — every code path that creates or",
    "mutates Figma content is blocked by this same hook.",
    "",
    "Any Figma content change must be made by a HUMAN directly in the Figma UI.",
    "Report what needs to change and stop; do not look for a way around this.",
    "",
    "Read-only `use_figma` inspection is still allowed — if you only meant to",
    "inspect, remove the write call(s) named above and retry.",
    "  - See: docs/plans/2026-08-19-block-figma-content-authoring.md",
    "  - See: core/cem-figma-connect/plans/00-mission-and-decisions.md (D6)",
  ].join("\n");
}

export { DENYLIST, WRITE_METHODS, WRITE_PROPERTIES, BULK_WRITE_PATTERNS };

// ---------------------------------------------------------------------------
// CLI / PreToolUse hook entry point.
// ---------------------------------------------------------------------------

import { fileURLToPath } from "node:url";

// Tool names that are ALWAYS denied, regardless of their argument content —
// these are pure content-authoring entry points with no read-only mode (D6).
// Matched against the tool_name SUFFIX (see bareToolName), so both
// `mcp__claude_ai_Figma__create_new_file` and a bare `create_new_file` match.
//
// SCOPE NOTE: the originating plan named only `create_new_file` and
// `generate_figma_design`. `generate_diagram` (places a diagram into an
// EXISTING FigJam file when given a `fileKey`), `upload_assets` (creates
// frames with image fills) and `weave_upload_asset` (sets an image fill on an
// existing node) are additional live tools in this session's Figma MCP surface
// that create or mutate Figma content. They are covered here under the plan's
// own broader goal statement — "any tool call that creates or mutates Figma
// content" — as a controller-approved scope expansion.
const ALWAYS_DENY_TOOLS = [
  "create_new_file",
  "generate_figma_design",
  "generate_diagram",
  "upload_assets",
  "weave_upload_asset",
];

// The bare tool names this hook must intercept, exported so the settings.json
// wiring test can assert the matcher actually catches every one of them.
const INTERCEPTED_TOOLS = ["use_figma", ...ALWAYS_DENY_TOOLS];

export { ALWAYS_DENY_TOOLS, INTERCEPTED_TOOLS };

// Claude Code MCP tool names arrive wire-formatted as `mcp__<server>__<tool>`
// (confirmed live: `mcp__claude_ai_Figma__use_figma`). Taking the suffix after
// the last `__` recovers the bare tool name uniformly, so the hook is
// independent of the MCP server's registered name.
export function bareToolName(toolName) {
  if (typeof toolName !== "string") return "";
  const parts = toolName.split("__");
  return parts[parts.length - 1];
}

function denyAndExit(reason) {
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: reason,
      },
    }) + "\n",
  );
  process.exit(0);
}

function runHookMode() {
  let input = "";
  process.stdin.on("data", (chunk) => (input += chunk));
  process.stdin.on("end", () => {
    let payload;
    try {
      // `.trim()` so an all-whitespace stdin falls back to the intended `{}`
      // default instead of throwing into the catch branch.
      payload = JSON.parse(input.trim() || "{}");
    } catch (err) {
      // Never block an unrelated tool call because THIS hook's own stdin
      // was malformed — but log it so the failure is visible.
      console.error(
        `check-figma-write-block: hook-mode internal error parsing stdin (not blocking): ${err.message}`,
      );
      process.exit(0);
      return;
    }

    try {
      const toolName = payload?.tool_name;
      const bareName = bareToolName(toolName);

      if (ALWAYS_DENY_TOOLS.includes(bareName)) {
        denyAndExit(
          [
            `Blocked by design: \`${toolName}\` creates or mutates Figma content, which is`,
            "never permitted from code in this repo regardless of arguments (decision D6).",
            "",
            "There is no alternative tool, skill, or workflow for this — every code path",
            "that authors Figma content is blocked by this same hook. Any Figma content",
            "change must be made by a HUMAN directly in the Figma UI. Report what needs to",
            "change and stop; do not look for a way around this.",
            "  - See: docs/plans/2026-08-19-block-figma-content-authoring.md",
            "  - See: core/cem-figma-connect/plans/00-mission-and-decisions.md (D6)",
          ].join("\n"),
        );
        return;
      }

      if (bareName === "use_figma") {
        const code = payload?.tool_input?.code;
        const result = checkFigmaCode(typeof code === "string" ? code : "");
        if (result.blocked) {
          denyAndExit(explain(result));
          return;
        }
        process.exit(0);
        return;
      }

      // Any other tool_name: pass through immediately, unaffected.
      process.exit(0);
    } catch (err) {
      console.error(
        `check-figma-write-block: hook-mode internal error (not blocking): ${err.message}`,
      );
      process.exit(0);
    }
  });
}

function main() {
  const args = process.argv.slice(2);
  if (args[0] === "--hook") {
    runHookMode();
    return;
  }
  console.error("usage: check-figma-write-block.mjs --hook");
  process.exit(64);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}
