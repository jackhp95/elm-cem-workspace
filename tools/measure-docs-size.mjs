#!/usr/bin/env node
// Measure the UNCOMPRESSED docs.json the Elm registry would bound, for one or
// more package trees, and fail if any exceeds the cap.
//
//   node tools/measure-docs-size.mjs [<pkgDir> ...]
//
// With no arguments it measures every known publishable package tree (see
// DEFAULT_TARGETS). Exits non-zero if ANY target is at or over the hard cap, so
// this is usable directly as a gate.
//
// WHY THIS EXISTS (R-026): the registry rejects a package whose generated
// docs.json exceeds 768,000 bytes — a literal in package.elm-lang.org's
// src/backend/Package/Register.hs, applied UPSTREAM of the gzipper, so the bound
// is pre-compression. `elm-m3e-icons` sat at 140% of it and blocked the whole
// family from publishing. The number that proves it fixed has to be
// reproducible by anyone, on any machine, from a bare checkout.
//
// It replaces tools/move2/measure-*.mjs, which hardcoded an absolute
// `/Users/jhp/code/jackhp95/elm-cem-workspace` path, an ephemeral `/tmp/m2/out`
// output dir, and a `node_modules/.bin/elm` that is not installed in this
// workspace — so the repo's own documented way to reproduce these figures did
// not run. Everything here is derived or overridable:
//   repo root  — walked up from import.meta.url to the pnpm-workspace.yaml
//   elm binary — $ELM_BIN, else node_modules/.bin/elm, else ~/.elm/bin/elm, else PATH
//   family src — $IR_SRC / $FACTS_SRC, else the in-workspace package dirs
//
// METHOD (identical to the D-031a / D-035 / V-C7 harnesses, which it reproduces
// to the byte): assemble a self-contained package whose src/ is the target's own
// src/ (exposed per its elm.json) PLUS every family-internal dependency's src
// vendored UNEXPOSED, declare only elm/* deps, then run
// `elm make --docs docs.json --output=/dev/null` and stat the result. Vendoring
// unexposed is what makes the measured surface equal the published surface: the
// dependency's own modules must compile but must NOT contribute doc entries.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const HARD_CAP = 768000; // registry hard limit, bytes, uncompressed
const SOFT_GATE = 700000; // project's self-imposed headroom gate

// ---- repo root: walk up from this file to the workspace marker ----------------
function findRepoRoot(from) {
  let dir = from;
  while (dir !== path.dirname(dir)) {
    if (fs.existsSync(path.join(dir, "pnpm-workspace.yaml"))) return dir;
    dir = path.dirname(dir);
  }
  throw new Error("measure-docs-size: could not locate pnpm-workspace.yaml above " + from);
}
const ROOT = findRepoRoot(path.dirname(fileURLToPath(import.meta.url)));

// ---- elm binary: env, then workspace, then elm-tooling's home, then PATH ------
function resolveElm() {
  const candidates = [
    process.env.ELM_BIN,
    path.join(ROOT, "node_modules/.bin/elm"),
    path.join(os.homedir(), ".elm/bin/elm"),
  ].filter(Boolean);
  for (const c of candidates) if (fs.existsSync(c)) return c;
  const which = spawnSync("sh", ["-c", "command -v elm"], { encoding: "utf8" });
  if (which.status === 0 && which.stdout.trim()) return which.stdout.trim();
  console.error(
    "measure-docs-size: no elm compiler found. Set $ELM_BIN, or install the pinned\n" +
      "toolchain (elm-tooling.json pins elm 0.19.1) so one of these exists:\n" +
      candidates.map((c) => "  " + c).join("\n")
  );
  process.exit(2);
}
const ELM = resolveElm();

// ---- family-internal deps get vendored from source, not fetched --------------
const FAMILY_SRC = {
  "jackhp95/elm-virtual-dom-intermediate-representation":
    process.env.IR_SRC || path.join(ROOT, "packages/elm-virtual-dom-intermediate-representation/src"),
  "jackhp95/elm-cem-facts": process.env.FACTS_SRC || path.join(ROOT, "pipeline/elm-cem/facts/src"),
};

const DEFAULT_TARGETS = ["brands/m3e/generated/package/elm-m3e/elm-m3e-icons"];

const copyElm = (src, dst) => {
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, e.name);
    const d = path.join(dst, e.name);
    if (e.isDirectory()) {
      fs.mkdirSync(d, { recursive: true });
      copyElm(s, d);
    } else if (e.name.endsWith(".elm")) {
      fs.copyFileSync(s, d);
    }
  }
};

function measure(pkgDir) {
  const elmJson = JSON.parse(fs.readFileSync(path.join(pkgDir, "elm.json"), "utf8"));
  const exposedRaw = elmJson["exposed-modules"];
  // elm.json allows either a flat array or a {heading: [...]} grouping.
  const exposed = Array.isArray(exposedRaw) ? exposedRaw : Object.values(exposedRaw).flat();

  const work = fs.mkdtempSync(path.join(os.tmpdir(), "measure-docs-"));
  const src = path.join(work, "src");
  fs.mkdirSync(src, { recursive: true });
  copyElm(path.join(pkgDir, "src"), src);

  const vendored = [];
  for (const dep of Object.keys(elmJson.dependencies || {})) {
    const depSrc = FAMILY_SRC[dep];
    if (!depSrc) continue; // a real registry dep (elm/*) — elm fetches it
    if (!fs.existsSync(depSrc)) {
      console.error(`measure-docs-size: ${pkgDir} needs ${dep} but ${depSrc} does not exist`);
      process.exit(2);
    }
    copyElm(depSrc, src);
    vendored.push(dep);
  }

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify(
      {
        type: "package",
        name: "jackhp95/measure-" + path.basename(pkgDir),
        summary: elmJson.summary,
        license: elmJson.license || "BSD-3-Clause",
        version: "1.0.0",
        "exposed-modules": exposed,
        "elm-version": "0.19.0 <= v < 0.20.0",
        // Only the genuinely-external deps survive; family deps are now vendored
        // into src/ UNEXPOSED, which is exactly how the published package's own
        // docs.json is bounded.
        dependencies: Object.fromEntries(
          Object.entries(elmJson.dependencies || {}).filter(([d]) => !FAMILY_SRC[d])
        ),
        "test-dependencies": {},
      },
      null,
      4
    ) + "\n"
  );

  const docs = path.join(work, "docs.json");
  const r = spawnSync(ELM, ["make", "--docs", docs, "--output=/dev/null"], {
    cwd: work,
    encoding: "utf8",
    timeout: 900000,
  });

  if (r.status !== 0 || !fs.existsSync(docs)) {
    fs.rmSync(work, { recursive: true, force: true });
    return { pkgDir, name: elmJson.name, ok: false, bytes: 0, exposed: exposed.length, vendored, stderr: (r.stderr || r.stdout || "").split("\n").filter(Boolean).slice(0, 12) };
  }

  const bytes = fs.statSync(docs).size;
  fs.rmSync(work, { recursive: true, force: true });
  return { pkgDir, name: elmJson.name, ok: true, bytes, exposed: exposed.length, vendored };
}

const targets = (process.argv.slice(2).length ? process.argv.slice(2) : DEFAULT_TARGETS).map((t) =>
  path.isAbsolute(t) ? t : path.join(ROOT, t)
);

console.log(`measure-docs-size: elm=${ELM}`);
console.log(`measure-docs-size: hard cap ${HARD_CAP.toLocaleString()} B · soft gate ${SOFT_GATE.toLocaleString()} B\n`);

let failed = false;
for (const t of targets) {
  const res = measure(t);
  if (!res.ok) {
    failed = true;
    console.log(`✗ ${res.name}  COMPILE FAILED`);
    for (const l of res.stderr) console.log("    " + l);
    continue;
  }
  const overHard = res.bytes >= HARD_CAP;
  const overSoft = res.bytes >= SOFT_GATE;
  if (overHard) failed = true;
  const mark = overHard ? "✗" : overSoft ? "!" : "✓";
  console.log(
    `${mark} ${res.name}  (${res.exposed} exposed${res.vendored.length ? `, vendored ${res.vendored.length}` : ""})  ` +
      `${res.bytes.toLocaleString()} B  ${((res.bytes / HARD_CAP) * 100).toFixed(1)}% hard  ` +
      `${((res.bytes / SOFT_GATE) * 100).toFixed(1)}% soft` +
      (overHard ? "  OVER HARD CAP" : overSoft ? "  over soft gate" : "")
  );
}

process.exit(failed ? 1 : 0);
