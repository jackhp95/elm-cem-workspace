#!/usr/bin/env node
// measure.mjs — re-verify C7 on the CANONICAL flat 143-module tree.
// Adapted from the spike's Appendix A harness. Assembles a self-contained Elm
// package, vendors IR + facts UNEXPOSED (zero docs bytes), runs
// `elm make --docs docs.json` (exactly what elm publish bounds), records bytes.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { spawnSync } from "node:child_process";

const WS = "/Users/jhp/code/jackhp95/elm-cem-workspace";
const GEN = "/tmp/m2/gen";                     // the flat 143 tree
const ELM = path.join(WS, "node_modules/.bin/elm");
const IR_SRC = path.join(WS, "packages/elm-html-intermediate-representation/src");
const FACTS_SRC = path.join(WS, "packages/elm-cem/facts/src");
const HARD_CAP = 768000;

const copyElm = (src, dst) => {
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, e.name), d = path.join(dst, e.name);
    if (e.isDirectory()) { fs.mkdirSync(d, { recursive: true }); copyElm(s, d); }
    else if (e.name.endsWith(".elm")) fs.copyFileSync(s, d);
  }
};

// discover all modules in the flat tree by path
function allModules(root) {
  const out = [];
  const walk = (sub) => {
    for (const e of fs.readdirSync(path.join(root, sub), { withFileTypes: true })) {
      const rel = path.join(sub, e.name);
      if (e.isDirectory()) walk(rel);
      else if (e.name.endsWith(".elm")) out.push(rel.replace(/\.elm$/, "").split(path.sep).join("."));
    }
  };
  walk("");
  return out.sort();
}

function measure(label, exposed) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "m2-measure-"));
  const src = path.join(dir, "src");
  fs.mkdirSync(src, { recursive: true });
  copyElm(GEN, src);
  copyElm(IR_SRC, src);
  copyElm(FACTS_SRC, src);
  fs.writeFileSync(path.join(dir, "elm.json"), JSON.stringify({
    type: "package", name: "jackhp95/elm-m3e-spike",
    summary: "docs.json size measurement", license: "BSD-3-Clause", version: "1.0.0",
    "exposed-modules": [...exposed].sort(), "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: {
      "elm/core": "1.0.0 <= v < 2.0.0", "elm/html": "1.0.0 <= v < 2.0.0",
      "elm/json": "1.0.0 <= v < 2.0.0", "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
    }, "test-dependencies": {},
  }, null, 4) + "\n");
  const docs = path.join(dir, "docs.json");
  const r = spawnSync(ELM, ["make", "--docs", docs, "--output=/dev/null"],
    { cwd: dir, encoding: "utf8", timeout: 900000 });
  const ok = r.status === 0 && fs.existsSync(docs);
  const bytes = ok ? fs.statSync(docs).size : 0;
  let perModule = null;
  if (ok && exposed.length > 1) {
    const arr = JSON.parse(fs.readFileSync(docs, "utf8"));
    perModule = {};
    for (const m of arr) perModule[m.name] = Buffer.byteLength(JSON.stringify(m), "utf8");
  }
  fs.rmSync(dir, { recursive: true, force: true });
  return { label, exit: r.status, ok, bytes, pct: ((bytes / HARD_CAP) * 100).toFixed(1),
    err: ok ? "" : (r.stderr || r.stdout || "").split("\n").slice(0, 4).join(" | "), perModule };
}

const mods = allModules(GEN);
const exposedAll = mods.filter((m) => m !== "M3e.Build.Internal"); // unexposed internal
console.error(`total modules: ${mods.length}, exposed(full surface): ${exposedAll.length}`);

const full = measure("full-canonical-surface", exposedAll);
console.log(JSON.stringify({ full: { exit: full.exit, bytes: full.bytes, pct: full.pct, err: full.err } }, null, 2));

// dump per-module sizes for the cut (only from the full run)
if (full.perModule) {
  const rows = Object.entries(full.perModule).sort((a, b) => b[1] - a[1]);
  fs.writeFileSync("/tmp/m2/per-module.json", JSON.stringify(full.perModule, null, 1));
  console.log("\nTop 8 modules by docs.json bytes:");
  for (const [n, b] of rows.slice(0, 8)) console.log(`  ${b.toString().padStart(8)}  ${n}`);
  const comp = rows.filter(([n]) => /^M3e\.[A-Za-z]+$/.test(n) &&
    !["M3e.Action","M3e.Attributes","M3e.Events","M3e.Html","M3e.Kind","M3e.Unsafe","M3e.Values","M3e.Build"].includes(n));
  const compBytes = comp.reduce((s, [, b]) => s + b, 0);
  console.log(`\ncomponents: ${comp.length} modules, ${compBytes} docs bytes (${(compBytes/HARD_CAP*100).toFixed(1)}% of cap)`);
}
