// verify-samples.mjs — `npm run check:samples`.
//
// Judges the modules `gen:samples` extracted from the guide's displayed Elm.
// Three questions, one per bucket of the manifest:
//
//   good/   must COMPILE, and must be CLEAN under the samples review config
//           (docs/samples/review) — the escape-discipline and facts-driven rules.
//   bad/    must FAIL TO COMPILE. A page that shows code and says "the compiler
//           rejects this" is making a claim; skipping it would leave the claim
//           unchecked, so the probe asserts the rejection instead. Modelled on
//           `elm-typed-html/verify/` (`good` must compile, `bad/*` must not).
//   expect-review  must compile AND produce an error from the NAMED rule, and no
//           error from any other. This is how "the linter catches this" stops
//           being prose: `/guide/accessible-by-construction` claims
//           `missingRequiredAttribute` refuses a nameless icon button, and the
//           run below is what makes that true.
//
// A sample marked `skip` is reported but not judged; the marker carries a reason
// and `gen:samples` refuses one without it.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(HERE, "..", "..");
const SAMPLES = path.join(DOCS, "samples");
const ELM = path.join(DOCS, "node_modules", ".bin", "elm");
const ELM_REVIEW = path.join(DOCS, "node_modules", ".bin", "elm-review");

const manifest = JSON.parse(fs.readFileSync(path.join(SAMPLES, "manifest.json"), "utf8"));
const problems = [];
const fail = (msg) => problems.push(msg);

/** elm's rich message chunks -> plain text. */
function renderMessage(message) {
  if (typeof message === "string") return message;
  if (!Array.isArray(message)) return String(message);
  return message.map((c) => (typeof c === "string" ? c : c.string || "")).join("");
}

function firstLine(text) {
  return (text.split("\n").find((l) => l.trim()) || "").trim();
}

/** Run `elm make` over some files; returns { ok, byFile: Map<relPath, string[]> }. */
function elmMake(files) {
  if (files.length === 0) return { ok: true, byFile: new Map() };
  let stderr = "";
  try {
    execFileSync(ELM, ["make", ...files, "--output=/dev/null", "--report=json"], {
      cwd: SAMPLES,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
      maxBuffer: 64 * 1024 * 1024,
    });
    return { ok: true, byFile: new Map() };
  } catch (err) {
    stderr = String(err.stderr || err.stdout || "");
  }
  let report;
  try {
    report = JSON.parse(stderr);
  } catch {
    // Not JSON at all: elm.json is broken, elm crashed, something structural.
    // Never treat this as "every sample failed as expected".
    return { ok: false, structural: stderr.slice(0, 4000), byFile: new Map() };
  }
  const byFile = new Map();
  const push = (file, message) => {
    const rel = path.relative(SAMPLES, file);
    if (!byFile.has(rel)) byFile.set(rel, []);
    byFile.get(rel).push(message);
  };
  if (report.type === "compile-errors") {
    for (const fileErr of report.errors || []) {
      for (const problem of fileErr.problems || []) {
        push(fileErr.path, `${problem.title}: ${firstLine(renderMessage(problem.message))}`);
      }
    }
  } else if (report.type === "error") {
    push(report.path || path.join(SAMPLES, "?"), firstLine(renderMessage(report.message)));
  }
  return { ok: false, byFile };
}

// ---------------------------------------------------------------------------
// 1. good/ must compile.

const good = manifest.filter((m) => m.file && m.file.startsWith("good/"));
const bad = manifest.filter((m) => m.file && m.file.startsWith("bad/"));

const goodResult = elmMake(good.map((m) => m.file));
if (goodResult.structural) {
  fail(`the samples project did not build at all:\n${goodResult.structural}`);
} else {
  for (const [file, messages] of goodResult.byFile) {
    const entry = good.find((m) => m.file === file);
    const who = entry ? `${entry.page}.${entry.sample}` : file;
    fail(`${who} does not compile (docs/samples/${file}):\n      ${messages.join("\n      ")}`);
  }
}

// ---------------------------------------------------------------------------
// 2. bad/ must NOT compile — one at a time, because a single failure aborts a
//    shared `elm make` and would let the rest pass by accident.

const verifiedFailures = [];
for (const entry of bad) {
  const result = elmMake([entry.file]);
  if (result.structural) {
    fail(`${entry.page}.${entry.sample}: the samples project did not build:\n${result.structural}`);
    continue;
  }
  const messages = result.byFile.get(entry.file) || [];
  if (result.ok || messages.length === 0) {
    fail(
      `${entry.page}.${entry.sample} is marked \`@sample expect-compile-error\` but it COMPILES ` +
        `(docs/samples/${entry.file}). Either the sample stopped being the broken thing the page ` +
        `says it is, or the marker is wrong — both are page bugs.`,
    );
    continue;
  }
  verifiedFailures.push(`${entry.page}.${entry.sample} — ${messages[0]}`);
}

// ---------------------------------------------------------------------------
// 3. good/ must be clean under the samples review config, except where a sample
//    declares the rule it is supposed to trip.

const expectedRule = new Map(good.filter((m) => m.rule).map((m) => [m.file, m.rule]));
const sawRule = new Map();

let review;
try {
  const out = execFileSync(
    ELM_REVIEW,
    // The whole project, not just `good/` — see docs/samples/review/src/ReviewConfig.elm.
    ["--config", "review", "--compiler", ELM, "--report=json"],
    { cwd: SAMPLES, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"], maxBuffer: 256 * 1024 * 1024 },
  );
  review = JSON.parse(out);
} catch (err) {
  const out = String(err.stdout || "");
  try {
    review = JSON.parse(out);
  } catch {
    fail(
      `elm-review did not return a report for docs/samples:\n${out.slice(0, 1200)}\n` +
        String(err.stderr || "").slice(0, 1200),
    );
    review = { type: "review-errors", errors: [] };
  }
}

if (review.type === "compile-errors" || review.type === "error") {
  fail(`the samples review config did not build:\n${JSON.stringify(review).slice(0, 1200)}`);
}

for (const fileErr of review.errors || []) {
  const rel = path.relative(SAMPLES, path.resolve(SAMPLES, fileErr.path));
  const entry = manifest.find((m) => m.file === rel);
  const who = entry ? `${entry.page}.${entry.sample}` : rel;
  for (const err of fileErr.errors || []) {
    if (expectedRule.get(rel) === err.rule) {
      sawRule.set(rel, true);
      continue;
    }
    fail(
      `${who} trips \`${err.rule}\` (docs/samples/${rel}):\n      ${err.message}\n` +
        `      A displayed sample must pass the discipline it teaches. Fix the sample on the page, ` +
        `or — if the finding IS the lesson — mark it \`-- @sample expect-review ${err.rule}: <reason>\`.`,
    );
  }
}
for (const [file, rule] of expectedRule) {
  if (sawRule.get(file)) continue;
  const entry = good.find((m) => m.file === file);
  fail(
    `${entry.page}.${entry.sample} is marked \`@sample expect-review ${rule}\` but elm-review did NOT ` +
      `report that rule. The page claims the linter catches this; it no longer does.`,
  );
}

// ---------------------------------------------------------------------------

const skipped = manifest.filter((m) => m.disposition === "skip");
for (const s of skipped) console.log(`check:samples: skipped ${s.page}.${s.sample} — ${s.reason}`);
for (const v of verifiedFailures) console.log(`check:samples: verified rejected — ${v}`);
for (const [file, rule] of expectedRule) {
  if (!sawRule.get(file)) continue;
  const entry = good.find((m) => m.file === file);
  console.log(`check:samples: verified flagged by ${rule} — ${entry.page}.${entry.sample}`);
}

if (problems.length) {
  console.error("\ncheck:samples: FAIL — a guide page is teaching something the tools reject:\n");
  for (const p of problems) console.error(`  - ${p}\n`);
  process.exit(1);
}

const derived = manifest.filter((m) => m.disposition === "derived").length;
console.log(
  `check:samples: OK — ${derived} derived from live code, ${good.length} compiled + reviewed, ` +
    `${bad.length} verified rejected, ${skipped.length} opted out.`,
);
