// build-examples.mjs — validate mined real-world compositions against ground
// truth, keep only the clean+correct ones, write data/examples.json.
// Validation rules live in lib/validate-markup.mjs (shared with check-skill).
// Rejections are reported with reasons (this doubles as a correctness probe).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { buildGroundTruth, validateMarkup } from "./lib/validate-markup.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const comps = JSON.parse(fs.readFileSync(path.join(ROOT, "data/components.json"), "utf8"));

// Two candidate sources, both validated against the same ground truth:
//   examples_raw.json       — mined from real projects (carries project/sourceFile)
//   authored_candidates.json — hand-authored straight from the CEM/TS API
// Authored entries get a provenance-tagged source string so the skill can be honest
// about origin while the validator stays the single gate for correctness.
const mined = JSON.parse(fs.readFileSync(path.join(ROOT, "data/examples_raw.json"), "utf8"))
  .map((e) => ({ ...e, origin: "mined" }));
const authoredPath = path.join(ROOT, "data/authored_candidates.json");
const authored = fs.existsSync(authoredPath)
  ? JSON.parse(fs.readFileSync(authoredPath, "utf8")).map((e) => ({ ...e, origin: "authored" }))
  : [];
const raw = [...mined, ...authored];

const GT = buildGroundTruth(comps);

// ---- run -----------------------------------------------------------------
const accepted = {};
const report = [];
for (const ex of raw) {
  const errs = validateMarkup(ex.code, GT);
  if (errs.length) {
    report.push({ ...ex, status: "REJECT", errs });
  } else {
    const source = ex.origin === "authored" ? "authored (validated vs CEM)" : `${ex.project}: ${ex.sourceFile}`;
    (accepted[ex.component] ||= []).push({ title: ex.title, code: ex.code, source, origin: ex.origin });
    report.push({ ...ex, status: "OK" });
  }
}

fs.writeFileSync(path.join(ROOT, "data/examples.json"), JSON.stringify(accepted, null, 2));

const ok = report.filter((r) => r.status === "OK").length;
console.log(`examples: ${ok}/${raw.length} accepted across ${Object.keys(accepted).length} components\n`);
for (const r of report)
  if (r.status === "REJECT") console.log(`✗ [${r.component}] ${r.title}\n    ${r.errs.join("\n    ")}`);
console.log("\nAccepted by component:", Object.fromEntries(Object.entries(accepted).map(([k, v]) => [k, v.length])));
