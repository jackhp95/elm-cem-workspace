#!/usr/bin/env node
// tools/check-figma-write-block.mjs — pure, dependency-free static-analysis
// classifier for `use_figma` MCP tool calls: decides whether a JS `code`
// string is read-only inspection or performs a Figma Plugin API WRITE.
//
// MODES (mirrors tools/check-layout-only-classes.mjs's file shape: one file
// holds both the pure classifier AND the CLI/hook entry point; the test file
// imports the pure exports directly, never through the CLI):
//   node tools/check-figma-write-block.mjs --hook   Claude Code PreToolUse:
//       reads the hook JSON on stdin (tool_name + tool_input), and:
//         - `create_new_file` / `generate_figma_design` (any matched
//           wire-format spelling — see WIRE-NAME MATCHING below): ALWAYS
//           denied (D6 ruling: no code-driven Figma content authoring).
//         - `use_figma`: runs checkFigmaCode(tool_input.code); denies with
//           explain(result) if blocked, allows otherwise.
//         - any other tool_name: passes through immediately, unaffected.
//       Blocking is signalled via the PreToolUse JSON contract (stdout JSON
//       body `{ hookSpecificOutput: { hookEventName, permissionDecision:
//       "deny", permissionDecisionReason } }`, exit 0), NOT via a nonzero
//       exit code — this is DIFFERENT from check-layout-only-classes.mjs's
//       PostToolUse contract (blocks via exit 2 + stderr text). Confirmed
//       against the working PreToolUse example already live in this harness,
//       ~/.claude/hooks/block-external-pr.sh (wired in ~/.claude/settings.json
//       under PreToolUse/Bash), which uses this exact JSON+exit-0 shape.
//
// WIRE-NAME MATCHING (judgment call, flagged — see task-2-report.md):
//   `mcp__claude_ai_Figma__use_figma` and `mcp__claude_ai_Figma__create_new_file`
//   are CONFIRMED live wire-format tool names in this session's MCP surface
//   (prefix `mcp__claude_ai_Figma__` + snake_case tool name). `generate_figma_design`
//   is NOT currently invocable in this session's MCP surface (only documented
//   by name in shipped skill docs), so its exact wire name could not be
//   empirically confirmed. Ruling: match `mcp__claude_ai_Figma__generate_figma_design`
//   (same confirmed convention) AND ALSO match the bare name
//   `generate_figma_design` as defense-in-depth in case it ships under a
//   different prefix. This hook matches by taking the tool_name's suffix
//   after the last `__` (or the whole name if there is no `__`), so both the
//   prefixed and bare spellings of all three tool names are covered
//   uniformly without an explicit allowlist of full names.
//
// ERROR-SAFETY: an internal error reading/parsing THIS hook's own stdin JSON
// (bad JSON, missing fields, etc.) must NEVER accidentally block an
// unrelated tool call — it fails safe by NOT blocking (mirroring
// check-layout-only-classes.mjs's "never block an edit because THIS script
// broke" policy), but DOES log to stderr so the failure is visible. This is
// intentionally DIFFERENT from the "default to block on ambiguity" principle
// that governs classifying `use_figma` CODE content (checkFigmaCode's job,
// above) — that principle is about content classification, not
// hook-infrastructure errors.
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

// ---------------------------------------------------------------------------
// CLI / PreToolUse hook entry point.
// ---------------------------------------------------------------------------

import { fileURLToPath } from "node:url";

// Tool names that are ALWAYS denied, regardless of their argument content —
// these are pure code-driven content-authoring entry points with no
// read-only mode (D6 ruling). Matched against the tool_name SUFFIX (see
// bareToolName below), so both `mcp__claude_ai_Figma__create_new_file` and a
// bare `create_new_file` match.
const ALWAYS_DENY_TOOLS = ["create_new_file", "generate_figma_design"];

// Claude Code MCP tool names arrive wire-formatted as
// `mcp__<server>__<tool>` (confirmed live: `mcp__claude_ai_Figma__use_figma`,
// `mcp__claude_ai_Figma__create_new_file`). Taking the suffix after the last
// `__` recovers the bare tool name uniformly for both prefixed and
// (possible, unconfirmed for generate_figma_design) bare spellings.
function bareToolName(toolName) {
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
      payload = JSON.parse(input || "{}");
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
            `Blocked by design: \`${toolName}\` performs code-driven Figma content authoring,`,
            "which is never permitted regardless of arguments (D6 ruling — no code-driven",
            "Figma content authoring). Content authoring must go through the reviewed",
            "`figma-generate-design` / `figma-code-connect` skill workflows, not this tool.",
            "  - See: docs/plans/2026-08-19-block-figma-content-authoring.md",
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
