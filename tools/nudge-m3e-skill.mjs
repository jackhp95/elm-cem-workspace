#!/usr/bin/env node
// tools/nudge-m3e-skill.mjs — Claude Code PostToolUse NUDGE (not a gate).
//
// WHY THIS EXISTS (see docs/plans/2026-08-19-durable-m3e-convention-enforcement.md,
// "m3e-skill-nudge hook" section): the plan's R4 argued against a blocking
// invoke-the-skill gate — hooks can't reliably introspect session skill state,
// and the deterministic downstream net (facts rules + compile errors + the
// utility manifest + check-layout-only-classes.mjs) already catches WRONG m3e
// usage after the fact. Jack overrode that and asked for a proactive nudge
// anyway, on top of (not instead of) the downstream catches: when an edit
// touches m3e, tell the CURRENT agent to consult the `m3e` skill / m3e-okf
// ground truth BEFORE it continues, so it has a chance to get tags/attributes/
// slots/tokens right on the first try instead of via a retry loop.
//
// MECHANISM: the documented Claude Code hook contract for injecting visible
// context without blocking — print
//   { hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext } }
// to stdout and exit 0. This is the same contract this repo's own harness
// already relies on for UserPromptSubmit injection
// (~/code/claude-harness/router/liaison-hook.ts) — PostToolUse additionalContext
// is the same documented field, different hookEventName.
//
// THIS IS A NUDGE, NOT A GATE:
//   - never exits non-zero, regardless of match/no-match/internal error.
//   - fires on a real m3e-pattern match, otherwise silent (no stdout at all).
//   - stateless / per-invocation: no session-scoped debounce. Repeated edits to
//     the same file re-nudge every time — simpler and safer than trying to
//     track "have I already nudged for this file this session" across
//     independent hook invocations with no shared session state file. If this
//     turns out noisy in practice, add a debounce cache keyed on
//     (session_id, file_path) — deliberately not built until there's
//     transcript evidence it's needed.
//
// MODES:
//   node tools/nudge-m3e-skill.mjs --hook   Claude Code PostToolUse: reads the
//       hook JSON on stdin, checks tool_input.file_path (.elm or .html), reads
//       the file fresh off disk (hook runs POST-write, so it already has the
//       new content), and — if it matches an m3e pattern — prints the
//       additionalContext nudge JSON. Always exits 0.
//   node tools/nudge-m3e-skill.mjs FILE     standalone: prints the nudge text
//       to stdout if FILE matches, prints nothing and exits 0 otherwise.
//       (Useful for manual/CI smoke-testing without faking stdin JSON.)

import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";

// Calibrated against real usage under brands/m3e/generated/docs/elm-m3e-docs/app/Route/Components/
// and brands/m3e/generated/package/elm-m3e/src: `import M3e exposing (...)`, `import M3e.Attributes`,
// `import M3e.Component.Badge` etc. (module-qualified Elm imports), plus raw
// custom-element tags (`<m3e-icon>`, `<m3e-theme>`) that show up in embedded
// HTML/doc comments, and the npm package name itself.
const M3E_PATTERNS = [
  /\bimport\s+M3e\b/, // import M3e / import M3e.Component.Button / import M3e exposing (...)
  /\bM3e\.Component\./, // qualified use without a bare import, e.g. M3e.Component.Badge.view
  /\bM3e\.Attributes\b/,
  /<m3e-[a-z-]+/, // raw custom-element tag, e.g. <m3e-icon>, <m3e-theme>, <m3e-button>
  /@m3e\/web\b/, // the underlying npm package name
];

const NUDGE_TEXT =
  "This file touches m3e (@m3e/web) components or the M3e Elm package — " +
  "invoke the `m3e` skill before continuing. It is backed by " +
  "brands/m3e/generated/okf/elm-m3e-okf (component API ground truth: " +
  "skills/m3e/components/<name>.md) and brands/m3e/inputs/material-okf " +
  "(type roles: knowledge/styles/typography.md; anti-patterns: " +
  "knowledge/anti-patterns/). " +
  "Verify tags, attributes, slots, and CSS tokens there — do not reconstruct " +
  "them from generic Material Design memory, and do not guess an m3e-* class " +
  "or attribute name.";

const EXTENSIONS = [".elm", ".html"];

export function matchesM3ePattern(content) {
  return M3E_PATTERNS.some((re) => re.test(content));
}

export function checkFileForNudge(filePath) {
  if (!EXTENSIONS.some((ext) => filePath.endsWith(ext))) return false;
  if (!existsSync(filePath)) return false;
  let content;
  try {
    content = readFileSync(filePath, "utf8");
  } catch {
    return false;
  }
  return matchesM3ePattern(content);
}

function emitNudge() {
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: NUDGE_TEXT,
      },
    }) + "\n",
  );
}

function runHookMode() {
  let input = "";
  process.stdin.on("data", (chunk) => (input += chunk));
  process.stdin.on("end", () => {
    try {
      const payload = JSON.parse(input || "{}");
      const filePath = payload?.tool_input?.file_path;
      if (filePath && checkFileForNudge(filePath)) {
        emitNudge();
      }
    } catch {
      // Internal error: stay silent. This is a nudge, never a blocker —
      // no stdout, no non-zero exit, regardless of what went wrong.
    }
    process.exit(0);
  });
}

function main() {
  const args = process.argv.slice(2);
  if (args[0] === "--hook") {
    runHookMode();
    return;
  }
  const [file] = args;
  if (!file) {
    console.error("usage: nudge-m3e-skill.mjs (--hook | FILE)");
    process.exit(64);
  }
  if (checkFileForNudge(file)) {
    console.log(NUDGE_TEXT);
  }
  process.exit(0);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  main();
}
