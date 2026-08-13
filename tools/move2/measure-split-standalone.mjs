#!/usr/bin/env node
// Compile each EMITTED split package standalone and measure its docs.json.
// For package P: assemble a package whose src = P's own src (exposed per its
// elm.json) PLUS every family dependency's src vendored UNEXPOSED (IR, facts,
// and the other split packages P depends on). This compiles P's real emitted
// tree against its declared deps and yields the exact docs.json the registry
// would bound. DAG-respect (split.js) already proved no illegal cross-imports.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { spawnSync } from "node:child_process";

const WS = "/Users/jhp/code/jackhp95/elm-cem-workspace";
const OUT = "/tmp/m2/out";
const ELM = path.join(WS, "node_modules/.bin/elm");
const IR_SRC = path.join(WS, "packages/elm-html-intermediate-representation/src");
const FACTS_SRC = path.join(WS, "packages/elm-cem/facts/src");
const HARD_CAP = 768000, SOFT = 700000;

const copyElm = (src, dst) => {
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, e.name), d = path.join(dst, e.name);
    if (e.isDirectory()) { fs.mkdirSync(d, { recursive: true }); copyElm(s, d); }
    else if (e.name.endsWith(".elm")) fs.copyFileSync(s, d);
  }
};

const pkgDirs = fs.readdirSync(OUT).filter((d) => fs.existsSync(path.join(OUT, d, "elm.json")));
// family-internal package names -> their emitted src dirs
const familySrc = {}; // "jackhp95/elm-m3e" -> /tmp/m2/out/elm-m3e/src
for (const d of pkgDirs) {
  const ej = JSON.parse(fs.readFileSync(path.join(OUT, d, "elm.json"), "utf8"));
  familySrc[ej.name] = path.join(OUT, d, "src");
}

const f = (b) => `${b} B  ${(b/HARD_CAP*100).toFixed(1)}% cap  ${(b/SOFT*100).toFixed(1)}% soft`;

for (const d of pkgDirs) {
  const ej = JSON.parse(fs.readFileSync(path.join(OUT, d, "elm.json"), "utf8"));
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "m2-pkg-"));
  const src = path.join(dir, "src");
  fs.mkdirSync(src, { recursive: true });
  // this package's own src (exposed)
  copyElm(path.join(OUT, d, "src"), src);
  // vendor every family-internal dependency's src UNEXPOSED, plus IR + facts
  for (const dep of Object.keys(ej.dependencies)) {
    if (dep === "jackhp95/elm-html-intermediate-representation") copyElm(IR_SRC, src);
    else if (dep === "jackhp95/elm-cem-facts") copyElm(FACTS_SRC, src);
    else if (familySrc[dep]) copyElm(familySrc[dep], src);
  }
  fs.writeFileSync(path.join(dir, "elm.json"), JSON.stringify({
    type: "package", name: "jackhp95/measure-" + d, summary: ej.summary,
    license: "BSD-3-Clause", version: "1.0.0",
    "exposed-modules": ej["exposed-modules"], "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: {
      "elm/core": "1.0.0 <= v < 2.0.0", "elm/html": "1.0.0 <= v < 2.0.0",
      "elm/json": "1.0.0 <= v < 2.0.0", "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
    }, "test-dependencies": {},
  }, null, 4) + "\n");
  const docs = path.join(dir, "docs.json");
  const r = spawnSync(ELM, ["make", "--docs", docs, "--output=/dev/null"], { cwd: dir, encoding: "utf8", timeout: 900000 });
  const ok = r.status === 0 && fs.existsSync(docs);
  const bytes = ok ? fs.statSync(docs).size : 0;
  const nExp = ej["exposed-modules"].length;
  const under = bytes > 0 && bytes < HARD_CAP;
  console.log(`${ej.name}  (${nExp} exposed)  exit=${r.status}  ${ok ? f(bytes) : "COMPILE FAILED"}  ${under ? "UNDER CAP ✓" : "OVER/FAIL ✗"}`);
  if (!ok) console.log("   " + (r.stderr || r.stdout || "").split("\n").filter(Boolean).slice(0, 6).join("\n   "));
  fs.rmSync(dir, { recursive: true, force: true });
}
