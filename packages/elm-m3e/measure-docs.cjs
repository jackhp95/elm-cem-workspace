// measure-docs.cjs — measure docs.json size for 3-package split, exposed-modules-only.
const fs = require("fs");
const path = require("path");
const os = require("os");
const { spawnSync } = require("child_process");

const ROOT = "/Users/jack/.paseo/worktrees/04t0kwkn/plan-api-consolidation";
const IR_SRC = "/Users/jack/.paseo/worktrees/04t0kwkn/elm-html-intermediate-representation/src";
const FACTS_SRC = "/Users/jack/Documents/code/elm-cem/facts/src";
const ELM_BIN = path.join(ROOT, "node_modules", ".bin", "elm");
const DOCS_LIMIT = 700000;

const ALL_PKG_DIRS = ["elm-m3e", "elm-m3e-components", "elm-m3e-builder"];

function copyDir(src, dst, filter) {
  if (!fs.existsSync(src)) return;
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, entry.name);
    const rel = path.relative(src, s).split(path.sep).join("/");
    const isDir = entry.isDirectory();
    if (!filter(rel, isDir)) continue;
    const d = path.join(dst, entry.name);
    if (isDir) {
      fs.mkdirSync(d, { recursive: true });
      copyDir(s, d, filter, s);
    } else {
      fs.copyFileSync(s, d);
    }
  }
}

function measurePackage(pkgDirName) {
  const pkgDir = path.join(ROOT, pkgDirName);
  const elmJsonPath = path.join(pkgDir, "elm.json");
  const elmJson = JSON.parse(fs.readFileSync(elmJsonPath, "utf8"));
  const exposed = elmJson["exposed-modules"];
  const deps = elmJson.dependencies || {};
  const pkgName = elmJson.name;

  const mDir = fs.mkdtempSync(path.join(os.tmpdir(), "docs-measure-"));
  const mSrc = path.join(mDir, "src");
  fs.mkdirSync(mSrc, { recursive: true });

  // Vendor ALL three packages' src/
  for (const pd of ALL_PKG_DIRS) {
    copyDir(path.join(ROOT, pd, "src"), mSrc, (rel, isDir) => isDir || rel.endsWith(".elm"));
  }
  // Override with freshly-generated flat output from src/ if present (post-regen).
  // elm-cem outputs a merged flat tree to src/; this supersedes the committed package dirs.
  const flatSrc = path.join(ROOT, "src");
  if (fs.existsSync(flatSrc)) {
    copyDir(flatSrc, mSrc, (rel, isDir) => isDir || rel.endsWith(".elm"));
  }
  copyDir(IR_SRC, mSrc, (rel, isDir) => isDir || rel.endsWith(".elm"));
  if (deps["jackhp95/elm-cem-facts"]) {
    copyDir(FACTS_SRC, mSrc, (rel, isDir) => isDir || rel.endsWith(".elm"));
  }

  // Patch: in builder modules, add {-|-} before `type alias Content` defs that lack doc comments.
  // The elm-m3e-builder/M3e/Build/*.elm files have one undocced type alias: Content.
  // Adding a doc comment to the temp copy is harmless.
  const buildDir = path.join(mSrc, "M3e", "Build");
  if (fs.existsSync(buildDir)) {
    const buildFiles = fs.readdirSync(buildDir, { withFileTypes: true });
    for (const f of buildFiles) {
      if (!f.isFile() || !f.name.endsWith(".elm")) continue;
      const fpath = path.join(buildDir, f.name);
      let content = fs.readFileSync(fpath, "utf8");
      const lines = content.split("\n");
      let changed = false;
      for (let i = 0; i < lines.length; i++) {
        const trimmed = lines[i].trimStart();
        if (trimmed === "type alias Content =") {
          let hasDoc = false;
          for (let j = i - 1; j >= Math.max(0, i - 10); j--) {
            const tl = lines[j].trim();
            if (tl === "") continue;
            if (tl === "-}" || tl.startsWith("{-|")) { hasDoc = true; break; }
            break;
          }
          if (!hasDoc) {
            lines.splice(i, 0, "{-|-}");
            i++;
            changed = true;
          }
        }
      }
      if (changed) {
        fs.writeFileSync(fpath, lines.join("\n"), "utf8");
      }
    }
  }

  // Build external deps
  const knownInternal = new Set([
    "jackhp95/elm-html-intermediate-representation", "jackhp95/elm-cem-facts",
    "jackhp95/elm-m3e", "jackhp95/elm-m3e-components", "jackhp95/elm-m3e-builder",
  ]);
  const externalDeps = {};
  for (const [dep, range] of Object.entries(deps)) {
    if (!knownInternal.has(dep)) externalDeps[dep] = range;
  }
  if (!externalDeps["elm/core"]) externalDeps["elm/core"] = "1.0.0 <= v < 2.0.0";
  if (!externalDeps["elm/html"]) externalDeps["elm/html"] = "1.0.0 <= v < 2.0.0";
  if (!externalDeps["elm/json"]) externalDeps["elm/json"] = "1.0.0 <= v < 2.0.0";
  if (!externalDeps["elm/virtual-dom"]) externalDeps["elm/virtual-dom"] = "1.0.0 <= v < 2.0.0";

  const shortSummary = (elmJson.summary || "").length > 75
    ? (elmJson.summary || "").slice(0, 72) + "..." : elmJson.summary || "docs-size measurement";

  const measureElmJson = {
    type: "package", name: pkgName, summary: shortSummary,
    license: "BSD-3-Clause", version: "1.0.0",
    "exposed-modules": [...exposed].sort(),
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: externalDeps, "test-dependencies": {},
  };
  fs.writeFileSync(path.join(mDir, "elm.json"), JSON.stringify(measureElmJson, null, 4) + "\n");

  const docsPath = path.join(mDir, "docs.json");
  const r = spawnSync(ELM_BIN, ["make", "--docs", docsPath, "--output=/dev/null"], {
    cwd: mDir, encoding: "utf8", stdio: "pipe", timeout: 120000,
  });

  const docsGenerated = fs.existsSync(docsPath);
  if (!docsGenerated) {
    const errDetail = (r.stderr || r.stdout || "").slice(0, 3000);
    fs.rmSync(mDir, { recursive: true, force: true });
    return { name: pkgName, error: errDetail, exposed: exposed.length };
  }

  const bytes = fs.statSync(docsPath).size;
  const docsRaw = fs.readFileSync(docsPath, "utf8");
  const docsContent = JSON.parse(docsRaw);
  const docsModules = Array.isArray(docsContent) ? docsContent.map(d => d.name) : [];
  const undocumented = docsModules.filter(m => !exposed.includes(m));

  fs.rmSync(mDir, { recursive: true, force: true });
  return {
    name: pkgName, bytes, exposed: exposed.length, exitCode: r.status,
    docsModules: docsModules.length, undocumented,
  };
}

console.log("=".repeat(72));
console.log(`DOCS-SIZE MEASUREMENT — 3-package split, exposed-modules-only`);
console.log(`Cap: ${DOCS_LIMIT.toLocaleString()} B (700 KB)`);
console.log(`Elm: ${ELM_BIN}`);
console.log("=".repeat(72));

const results = [];
for (const pd of ALL_PKG_DIRS) {
  console.log(`\nMeasuring ${pd}...`);
  const r = measurePackage(pd);
  results.push(r);
  if (r.error) {
    console.error(`  FAIL: ${r.error.slice(0, 500)}`);
    continue;
  }
  const pct = ((r.bytes / DOCS_LIMIT) * 100).toFixed(1);
  const barLen = Math.min(20, Math.round(pct / 5));
  const pctBar = "█".repeat(barLen) + "░".repeat(Math.max(0, 20 - barLen));
  console.log(`  modules: ${r.exposed} exposed, ${r.docsModules} in docs.json` +
    (r.undocumented.length ? ` ⚠ extra: ${r.undocumented.join(",")}` : ""));
  console.log(`  docs.json: ${r.bytes.toLocaleString()} B (${pct}% of cap) ${r.bytes > DOCS_LIMIT ? "⚠ OVER" : "✓ under"}`);
  console.log(`  ${pctBar}`);
  console.log(`  exit: ${r.exitCode}`);
}

console.log("\n" + "=".repeat(72));
console.log("SUMMARY");
console.log("-".repeat(72));
for (const r of results) {
  if (r.error) {
    console.log(`  ${r.name.padEnd(34)} FAILED — ${r.error.slice(0, 80)}`);
  } else {
    const pct = ((r.bytes / DOCS_LIMIT) * 100).toFixed(1);
    const status = r.bytes > DOCS_LIMIT ? "⚠ OVER" : "✓";
    console.log(`  ${r.name.padEnd(34)} ${r.bytes.toLocaleString().padStart(10)} B  ${pct}%  ${status}`);
  }
}
console.log("=".repeat(72));