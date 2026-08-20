#!/usr/bin/env node
// m3e-okf disclosure hook — code-signal, L1 (the pragmatic slice of the rev-2 design
// at planning/execution/2026-07-21-m3e-okf-hook-design.md §7a).
//
// Wired as a PreToolUse hook on Edit|Write|MultiEdit. On the FIRST edit of a UI file
// inside an m3e repo, per agent per context window, it emits a one-time L1 nudge via
// hookSpecificOutput.additionalContext — pointing the agent at the `m3e` skill and the
// styling ladder, so it leans on the components instead of hand-rolling Material from
// memory. Silent otherwise. Zero deps, fast exit path.
//
// This is the L1-lite version: it points at the `m3e` skill rather than inlining the
// full catalog. The full rev-2 package (index builder, L2/L3 per-component disclosure,
// chat hook, plugin) is a separate build.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const UI_EXT = new Set([
  ".elm", ".html", ".htm", ".js", ".mjs", ".ts", ".jsx", ".tsx",
  ".astro", ".vue", ".svelte", ".css", ".templ",
]);
// Opt-in extra extensions for config-/data-driven m3e repos whose UI is authored
// in non-source files (e.g. a Code-Connect repo defines m3e markup in
// examples.json). Set M3E_OKF_EXTRA_EXT=".json,.yaml" in that repo's
// .claude/settings.local.json env. Kept opt-in so we don't nudge on every
// package.json/tsconfig edit in unrelated repos.
for (const e of (process.env.M3E_OKF_EXTRA_EXT || "").split(",").map((s) => s.trim()).filter(Boolean)) {
  UI_EXT.add(e.startsWith(".") ? e.toLowerCase() : "." + e.toLowerCase());
}

const silent = () => process.exit(0);

function readStdin() {
  try { return fs.readFileSync(0, "utf8"); } catch { return ""; }
}

let payload;
try { payload = JSON.parse(readStdin() || "{}"); } catch { silent(); }

// Tool gate
const tool = payload.tool_name || "";
if (tool !== "Edit" && tool !== "Write" && tool !== "MultiEdit") silent();

// Extension gate
const ti = payload.tool_input || {};
const filePath = ti.file_path || ti.path || "";
if (!filePath || !UI_EXT.has(path.extname(filePath).toLowerCase())) silent();

// Repo gate — walk up to a root, decide if it's an m3e repo
function findRoot(start) {
  let dir = path.dirname(path.resolve(start));
  for (let i = 0; i < 40; i++) {
    if (
      fs.existsSync(path.join(dir, ".git")) ||
      fs.existsSync(path.join(dir, "package.json")) ||
      fs.existsSync(path.join(dir, "elm.json"))
    ) return dir;
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }
  return null;
}

function repoIsM3e(root) {
  if (!root) return false;
  if (process.env.M3E_OKF_ASSUME_REPO === "1") return true;
  // package.json → @m3e/* dependency
  try {
    const j = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
    const deps = { ...(j.dependencies || {}), ...(j.devDependencies || {}) };
    if (Object.keys(deps).some((d) => d === "@m3e/web" || d.startsWith("@m3e/"))) return true;
  } catch {}
  // elm.json → an elm-m3e dependency
  try {
    if (/elm-m3e/i.test(fs.readFileSync(path.join(root, "elm.json"), "utf8"))) return true;
  } catch {}
  // vendored bundle (e.g. flightdeck embeds a self-hosted m3e.js) or node_modules/@m3e
  const markers = [
    "internal/web/static/m3e.js", "public/m3e.js", "static/m3e.js",
    "src/m3e.js", "node_modules/@m3e/web",
  ];
  if (markers.some((m) => fs.existsSync(path.join(root, m)))) return true;
  return false;
}

const root = findRoot(filePath);
if (!repoIsM3e(root)) silent();

// Disclose-once ledger, keyed by session_id + agent_id (per agent per context window)
const stateRoot =
  process.env.M3E_OKF_STATE ||
  path.join(os.homedir(), ".claude", "hook-state", "m3e-okf");
const sessionId = payload.session_id || "nosession";
const agentKey = payload.agent_id || "main";
const ledgerDir = path.join(stateRoot, String(sessionId));
const ledgerFile = path.join(ledgerDir, String(agentKey) + ".json");

let ledger = {};
try { ledger = JSON.parse(fs.readFileSync(ledgerFile, "utf8")); } catch {}
if (ledger.l1) silent(); // already disclosed to this agent

try {
  fs.mkdirSync(ledgerDir, { recursive: true });
  ledger.l1 = true;
  const tmp = ledgerFile + "." + process.pid + ".tmp";
  fs.writeFileSync(tmp, JSON.stringify(ledger));
  fs.renameSync(tmp, ledgerFile); // atomic
} catch { /* a duplicate disclosure is acceptable; a lost mark is not fatal */ }

const nudge = [
  "[m3e-okf] This repo uses @m3e/web (Material 3 Expressive) web components.",
  "Invoke the `m3e` skill for verified component tags / attributes / slots / CSS custom-property tokens —",
  "do NOT hand-roll Material surfaces or guess tokens from memory (they get hallucinated;",
  "e.g. the chip container color is `--m3e-elevated-chip-container-color`, not `--m3e-chip-container-color`).",
  "Styling ladder: m3e component → its attributes/slots → its CSS custom props → M3 design tokens → custom CSS LAST (layout-only).",
].join(" ");

process.stdout.write(JSON.stringify({
  hookSpecificOutput: { hookEventName: "PreToolUse", additionalContext: nudge },
}));
process.exit(0);
