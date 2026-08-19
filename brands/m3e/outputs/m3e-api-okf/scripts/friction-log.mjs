#!/usr/bin/env node
// friction-log.mjs — append one m3e friction to the local ledger. Cheap, no judgment, no network.
//
//   node friction-log.mjs '{"component":"m3e-card","kind":"unknown-slot","note":"image→where?","resolved":"slot=header","docHadIt":true,"skillInstalled":false}'
//
// Fields (all optional except component+kind):
//   component     e.g. "m3e-card"
//   kind          "unknown-slot" | "wrong-attr" | "wrong-token" | "missing-fact" | …
//   note          what the agent was unsure about
//   resolved      the correct answer once known
//   docHadIt      bool — was it ALREADY documented in the m3e skill? (verify by grep first!)
//   skillInstalled bool — was the skill even available in this repo?
// The docHadIt/skillInstalled pair splits "install/discoverability problem"
// from "genuine content gap" — the distinction that decides what to do about it.
import fs from "node:fs"; import os from "node:os"; import path from "node:path";

const LEDGER = process.env.M3E_OKF_LEDGER || path.join(os.homedir(), ".claude", "m3e-okf-friction-log.jsonl");
let entry;
try { entry = JSON.parse(process.argv[2] || "{}"); } catch { console.error("friction-log: arg must be JSON"); process.exit(1); }
if (!entry.component || !entry.kind) { console.error("friction-log: component + kind required"); process.exit(1); }
entry.repo = entry.repo || path.basename(process.cwd());
entry.ts = process.env.M3E_OKF_TS || new Date().toISOString(); // caller may pass a fixed ts
fs.mkdirSync(path.dirname(LEDGER), { recursive: true });
fs.appendFileSync(LEDGER, JSON.stringify(entry) + "\n");
console.log(`[friction-log] +1 (${entry.component}/${entry.kind}) → ${LEDGER}`);
