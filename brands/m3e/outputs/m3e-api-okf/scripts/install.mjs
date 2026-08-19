#!/usr/bin/env node
// install.mjs — one-command, idempotent m3e-okf install for a consuming repo.
//
//   node <m3e-okf>/scripts/install.mjs [--repo <path>] [--extra-ext .json,.yaml] [--assume-repo]
//
// Does two things, safely re-runnable:
//   1. Registers the m3e-okf skills — symlinks each skills/* into ~/.claude/skills
//      so `m3e`, `applying-material-design`, `updating-okf`, … are invocable.
//   2. Wires the disclosure hook into <repo>/.claude/settings.local.json (gitignored,
//      machine-local) with the RESOLVED absolute path to THIS checkout — no
//      hand-editing, no hardcoded /Users/jack/… .
//
// Replaces the old manual dance (symlink by hand + hand-edit settings.json with a
// hardcoded path) that left the whole system inert in real consuming repos.
// Zero deps beyond node builtins.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const argv = process.argv.slice(2);
const flag = (name) => { const i = argv.indexOf(name); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith("--") ? argv[i + 1] : null; };
const OKF = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const REPO = path.resolve(flag("--repo") || process.cwd());
const EXTRA_EXT = flag("--extra-ext"); // e.g. ".json" for config-driven repos
const ASSUME = argv.includes("--assume-repo") || true; // presence of the hook config implies m3e usage
const log = (m) => console.log("[m3e-okf install] " + m);

// 1. register skills -> ~/.claude/skills (symlink, idempotent)
const skillsSrc = path.join(OKF, "skills");
const skillsDst = path.join(os.homedir(), ".claude", "skills");
fs.mkdirSync(skillsDst, { recursive: true });
let linked = 0;
for (const name of fs.readdirSync(skillsSrc)) {
  const src = path.join(skillsSrc, name);
  if (!fs.statSync(src).isDirectory()) continue;
  const dst = path.join(skillsDst, name);
  try {
    if (fs.existsSync(dst) || fs.lstatSync(dst, { throwIfNoEntry: false })) {
      const cur = fs.lstatSync(dst).isSymbolicLink() ? fs.readlinkSync(dst) : null;
      if (cur === src) { continue; }            // already correct
      fs.rmSync(dst, { recursive: true, force: true });
    }
  } catch { /* not present */ }
  fs.symlinkSync(src, dst); linked++;
  log(`skill: ${name} -> ${src}`);
}
log(`skills registered (${linked} new/updated; ${fs.readdirSync(skillsSrc).length} total).`);

// 2. wire the hook into <repo>/.claude/settings.local.json (merge, don't clobber)
const claudeDir = path.join(REPO, ".claude");
fs.mkdirSync(claudeDir, { recursive: true });
const settingsPath = path.join(claudeDir, "settings.local.json");
let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, "utf8")); } catch {}
settings.hooks = settings.hooks || {};
const pre = (settings.hooks.PreToolUse = settings.hooks.PreToolUse || []);
const envPrefix = (ASSUME ? "M3E_OKF_ASSUME_REPO=1 " : "") + (EXTRA_EXT ? `M3E_OKF_EXTRA_EXT=${EXTRA_EXT} ` : "");
const command = `${envPrefix}node ${path.join(OKF, "hooks", "m3e-disclosure.mjs")}`;
// find an existing m3e block or add one
let block = pre.find((b) => b.matcher === "Edit|Write|MultiEdit" && (b.hooks || []).some((h) => /m3e-disclosure/.test(h.command || "")));
if (block) {
  const h = block.hooks.find((h) => /m3e-disclosure/.test(h.command || ""));
  h.command = command; log("hook: updated existing m3e-disclosure entry.");
} else {
  pre.push({ matcher: "Edit|Write|MultiEdit", hooks: [{ type: "command", command }] });
  log("hook: added m3e-disclosure PreToolUse entry.");
}
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + "\n");
log(`wrote ${settingsPath}`);
log("done. Note: .claude/settings.local.json is machine-local (gitignore it).");
