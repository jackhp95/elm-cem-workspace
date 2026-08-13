// validate-okf.mjs — validate the Open Knowledge Format (OKF) v0.1 bundle.
//
// Checks, per the OKF v0.1 spec (https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md):
//   1. FRONTMATTER — every concept file (a .md that is NOT index.md/log.md) carries
//      the required `type` key. Recommended keys (title/description/resource/tags/
//      timestamp) are reported, not required.
//   2. INDEX/LOG — index.md and log.md are reserved and carry NO frontmatter.
//   3. LINKS — a resolution report over bundle-absolute (`/foundations/color`) and
//      relative links. Broken links are reported NON-fatally (the spec says consumers
//      must tolerate broken links).
//   4. CITATIONS — any knowledge/ concept file that makes a design claim must carry a
//      `sources:` key (or an inline m3.material.io citation). This reuses the guidance
//      audit's claim/citation logic (audit-lib) so the two stay aligned.
//
// FATAL (exit 1): a concept file missing `type`; an index.md/log.md WITH frontmatter;
// a design-claim knowledge/ file with no citation. Non-fatal (report only): broken
// links, missing recommended keys.
//
//   node scripts/lib/validate-okf.mjs            # report + gate
//   node scripts/lib/validate-okf.mjs --quiet    # only print on failure

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter, extractLinks, makesDesignClaim } from "./okf-lib.mjs";
import { classifyLinks } from "./audit-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../../..");
const BUNDLE = path.join(ROOT, "knowledge");

const RECOMMENDED = ["title", "description", "resource", "tags", "timestamp"];
const RESERVED = new Set(["index.md", "log.md"]);

// Walk the bundle, collecting every .md with its bundle-relative concept id.
function walk(dir, files = []) {
  for (const f of fs.readdirSync(dir).sort()) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) walk(p, files);
    else if (f.endsWith(".md")) files.push(p);
  }
  return files;
}

// Concept ID = bundle path minus .md, relative to the bundle root.
// `<root>/foundations/color.md` -> `/foundations/color`.
const conceptId = (root, abs) => "/" + path.relative(root, abs).replace(/\.md$/, "");

export function validateBundle(bundleRoot) {
  const files = fs.existsSync(bundleRoot) ? walk(bundleRoot) : [];
  const ids = new Set(files.map((f) => conceptId(bundleRoot, f)));
  // A directory index resolves a `/foundations` or `/foundations/` link.
  const dirs = new Set(files.map((f) => path.dirname(conceptId(bundleRoot, f))));

  const errors = [];   // fatal
  const warnings = []; // reported, non-fatal
  const brokenLinks = [];
  let conceptFiles = 0, indexFiles = 0;

  for (const abs of files) {
    const rel = path.relative(bundleRoot, abs);
    const base = path.basename(abs);
    const raw = fs.readFileSync(abs, "utf8");
    const { data, body, hasFrontmatter } = parseFrontmatter(raw);

    if (RESERVED.has(base)) {
      indexFiles++;
      // Reserved files must NOT carry frontmatter.
      if (hasFrontmatter) errors.push(`${rel}: reserved file (${base}) must have NO frontmatter`);
    } else {
      conceptFiles++;
      // Required key.
      if (!data.type) errors.push(`${rel}: missing required frontmatter key 'type'`);
      // Recommended keys (report only).
      const missing = RECOMMENDED.filter((k) => data[k] == null || (Array.isArray(data[k]) && data[k].length === 0));
      if (missing.length) warnings.push(`${rel}: missing recommended key(s): ${missing.join(", ")}`);

      // Citation-presence: a design-claim file needs a `sources:` list or an inline
      // m3.material.io citation. Reuses the guidance audit's link classifier.
      if (makesDesignClaim(body)) {
        const hasSources = Array.isArray(data.sources) && data.sources.length > 0;
        const inlineM3 = classifyLinks(body).m3 > 0;
        if (!hasSources && !inlineM3) {
          errors.push(`${rel}: makes a design claim but carries no citation (add 'sources:' or an inline m3.material.io link)`);
        }
      }
    }

    // Link resolution (bundle-absolute + relative). External/anchor/mailto skipped.
    for (const href of extractLinks(body)) {
      const [target] = href.split("#");
      if (!target || /^(https?:|mailto:)/.test(target)) continue;
      if (target.startsWith("/implementations/") || target === "/index") continue; // outside bundle / root, tolerated
      let id;
      if (target.startsWith("/")) id = target.replace(/\/$/, "");
      else {
        // relative to this file's directory, as a concept id
        const ab = path.resolve(path.dirname(abs), target);
        id = "/" + path.relative(bundleRoot, ab ).replace(/\.md$/, "").replace(/\/$/, "");
      }
      const resolvable = ids.has(id) || dirs.has(id) || ids.has(id + "/index") || id === "";
      if (!resolvable) brokenLinks.push(`${rel}: unresolved link -> ${href}`);
    }
  }

  return { conceptFiles, indexFiles, errors, warnings, brokenLinks };
}

function report(r, quiet) {
  const lines = [];
  lines.push(`# OKF bundle validation`);
  lines.push(``);
  lines.push(`- Concept files: ${r.conceptFiles}`);
  lines.push(`- Reserved files (index.md/log.md): ${r.indexFiles}`);
  lines.push(`- Fatal errors: ${r.errors.length}`);
  lines.push(`- Warnings (recommended keys): ${r.warnings.length}`);
  lines.push(`- Broken links (non-fatal, spec-tolerated): ${r.brokenLinks.length}`);
  lines.push(``);
  if (r.errors.length) lines.push(`## Errors\n` + r.errors.map((e) => `- ✗ ${e}`).join("\n") + "\n");
  if (r.brokenLinks.length) lines.push(`## Broken links (report only)\n` + r.brokenLinks.map((e) => `- ⚠ ${e}`).join("\n") + "\n");
  if (r.warnings.length) lines.push(`## Recommended-key warnings\n` + r.warnings.map((e) => `- · ${e}`).join("\n") + "\n");
  const out = lines.join("\n");
  if (!quiet || r.errors.length) console.log(out);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const quiet = process.argv.includes("--quiet");
  const r = validateBundle(BUNDLE);
  report(r, quiet);
  if (r.errors.length) {
    console.error(`\n✗ OKF validation failed: ${r.errors.length} error(s).`);
    process.exit(1);
  }
  console.log(`\n✓ OKF bundle valid (${r.conceptFiles} concept files; ${r.brokenLinks.length} broken link(s) reported non-fatally).`);
}
