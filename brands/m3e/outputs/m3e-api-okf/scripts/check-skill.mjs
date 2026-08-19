// check-skill.mjs — guard: assert no rendered skill file ships HTML markup that
// drifts from the CEM ground truth. Walks every ```html block in skills/m3e/**
// (component cards AND concept pages) and validates it against the manifest, so
// a regression — drift slipping into a concept page from guidance.json, a hand
// edit, a future generator change — fails loudly instead of teaching agents a
// tag/attribute/slot that doesn't exist. Exits non-zero on any drift.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { buildGroundTruth, validateMarkup } from "./lib/validate-markup.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const comps = JSON.parse(fs.readFileSync(path.join(ROOT, "data/components.json"), "utf8"));
const GT = buildGroundTruth(comps);

const SKILL = path.join(ROOT, "skills/m3e");
const files = [];
(function walk(dir) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) walk(p);
    else if (f.endsWith(".md")) files.push(p);
  }
})(SKILL);

let blocks = 0;
const problems = [];
for (const file of files.sort()) {
  const md = fs.readFileSync(file, "utf8");
  for (const m of md.matchAll(/```html\n([\s\S]*?)```/g)) {
    blocks++;
    const errs = validateMarkup(m[1], GT, { allowCss: true });
    if (errs.length) problems.push({ file: path.relative(ROOT, file), errs });
  }
}

if (problems.length) {
  console.error(`✗ ${problems.length}/${blocks} html block(s) drift from the CEM:\n`);
  for (const p of problems) console.error(`  [${p.file}]\n    ${p.errs.join("\n    ")}`);
  process.exit(1);
}

// README count-drift guard: the README's headline "N components (M elements)" is a
// single-sourced fact — assert it matches components.json so the two can't silently
// diverge (same lesson as the spec-map freshness guard).
const readme = fs.readFileSync(path.join(ROOT, "README.md"), "utf8");
const totalElements = comps.reduce((n, c) => n + c.elements.length, 0);
const countMatch = readme.match(/(\d+)\s+components\s+\((\d+)\s+elements\)/);
if (!countMatch) {
  console.error('✗ README is missing the "N components (M elements)" line the count guard checks.');
  process.exit(1);
}
if (+countMatch[1] !== comps.length || +countMatch[2] !== totalElements) {
  console.error(`✗ README counts (${countMatch[1]} components, ${countMatch[2]} elements) != components.json (${comps.length} components, ${totalElements} elements).`);
  process.exit(1);
}

console.log(`✓ ${blocks} html blocks across ${files.length} skill files — all valid against the CEM.`);
console.log(`✓ README counts match components.json (${comps.length} components, ${totalElements} elements).`);
