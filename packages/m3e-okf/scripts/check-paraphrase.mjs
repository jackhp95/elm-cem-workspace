// check-paraphrase.mjs — D6 paraphrase guard for the OKF bundle (OPT-IN, network).
//
// The licensing discipline forbids pasting source prose: no run of N+ consecutive
// words in a knowledge/ page may be identical to one of its cited `sources:`. This
// script enforces that as a word-shingle comparison (okf-lib's `verbatimRuns`).
//
// It is NOT wired into CI: it must FETCH each cited m3.material.io page, which is a
// network + non-deterministic step, and CI runs against committed inputs only (see
// ci.yml). Run it locally while authoring/reviewing a page, or before a release:
//
//   node scripts/check-paraphrase.mjs                 # check every sources-cited page
//   node scripts/check-paraphrase.mjs foundations/color   # one page (bundle-relative)
//   node scripts/check-paraphrase.mjs --window 15     # run length (default 15)
//
// Exit 0 = clean (or nothing fetchable), 1 = a verbatim run was found.
//
// Design note: the check compares against the LIVE cited source. A local snapshot
// cache could make it deterministic/offline; that's a documented follow-on.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter, verbatimRuns } from "./lib/okf-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SRC = path.join(ROOT, "data/knowledge");

const argv = process.argv.slice(2);
const wi = argv.indexOf("--window");
const N = wi >= 0 ? Number(argv[wi + 1]) : 15;
const only = argv.filter((a) => !a.startsWith("--") && a !== String(N));

function walk(dir, files = []) {
  for (const f of fs.readdirSync(dir).sort()) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) walk(p, files);
    else if (f.endsWith(".md") && f !== "index.md" && f !== "log.md") files.push(p);
  }
  return files;
}

// Crude HTML→text: drop tags and collapse whitespace. verbatimRuns re-tokenizes,
// so this only needs to expose the words, not clean markup perfectly.
const htmlToText = (h) => h.replace(/<script[\s\S]*?<\/script>/gi, " ").replace(/<style[\s\S]*?<\/style>/gi, " ").replace(/<[^>]+>/g, " ");

async function fetchText(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) return null;
    return htmlToText(await res.text());
  } catch {
    return null;
  }
}

const files = walk(SRC).filter((f) => (only.length ? only.some((o) => f.includes(o)) : true));
let offenders = 0, checked = 0, unfetchable = 0;

for (const abs of files) {
  const { data, body } = parseFrontmatter(fs.readFileSync(abs, "utf8"));
  const sources = Array.isArray(data.sources) ? data.sources : [];
  const urls = sources.map((s) => (typeof s === "string" ? s : s.url)).filter(Boolean);
  if (!urls.length) continue;
  const rel = path.relative(SRC, abs);
  for (const url of urls) {
    const text = await fetchText(url);
    if (text == null) { unfetchable++; continue; }
    checked++;
    const runs = verbatimRuns(body, text, N);
    if (runs.length) {
      offenders++;
      console.error(`✗ ${rel}: ${runs.length} verbatim ${N}-word run(s) vs ${url}`);
      console.error(`    e.g. "${runs[0]}"`);
    }
  }
}

console.log(`\nparaphrase: ${checked} source comparison(s) run, ${unfetchable} unfetchable, ${offenders} offending run(s) (window=${N}).`);
if (offenders) process.exit(1);
