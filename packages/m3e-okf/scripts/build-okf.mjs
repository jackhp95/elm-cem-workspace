// build-okf.mjs — assemble the Open Knowledge Format (OKF) v0.1 bundle.
//
// DECISION (Phase 5b): knowledge/ is a GENERATED TARGET, not a hand-edited tree.
// The source of truth is data/knowledge/** (technology-neutral authored prose with
// OKF frontmatter) + data/knowledge/*/_dir.json (per-directory metadata). This build
// copies the concept files verbatim into knowledge/**, copies log.md, and DERIVES
// each directory's index.md deterministically from _dir.json + the frontmatter of
// the concept files present. Rationale: the same lesson as skills/m3e — rendered
// pages are build outputs, so authoring in a source dir and generating the tree
// keeps index.md TOCs from drifting and lets validate-okf/CI diff-guard them.
//
// The implementations/m3e-web/ layer is the tech-specific, CEM-verified counterpart:
// its component cards are the SAME cards build-skill.mjs renders (tag-level API),
// re-emitted here under a clearly-labeled implementation root. build-skill.mjs stays
// the source of those cards; this build copies them so the OKF layout is complete.
//
//   knowledge/                THE OKF BUNDLE ROOT (technology-neutral)
//   implementations/m3e-web/  the verified, tech-specific layer

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter } from "./lib/okf-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SRC = path.join(ROOT, "data/knowledge");
const OUT = path.join(ROOT, "knowledge");
const IMPL = path.join(ROOT, "implementations/m3e-web");
const CARDS = path.join(ROOT, "skills/m3e/components");

const isConcept = (f) => f.endsWith(".md") && f !== "index.md" && f !== "log.md";

// Reset the generated bundle root so removed source files don't linger. Only the
// two generated trees are wiped; data/ (source) is never touched.
function rmrf(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}
rmrf(OUT);
rmrf(IMPL);

// ---------------------------------------------------------------------------
// Bundle: copy neutral concept files + generate index.md per directory
// ---------------------------------------------------------------------------
function readDirMeta(srcDir) {
  const p = path.join(srcDir, "_dir.json");
  return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : { title: path.basename(srcDir), intro: "" };
}

// A directory's index.md is a table of contents: an intro, links to sub-indexes,
// then a table of the concept files in this directory (title + description pulled
// from each file's frontmatter). index.md itself carries NO frontmatter (OKF rule).
function buildIndex(srcDir, outDir, relBase) {
  fs.mkdirSync(outDir, { recursive: true });
  const meta = readDirMeta(srcDir);

  const entries = fs.readdirSync(srcDir).sort();
  const subdirs = entries.filter((e) => fs.statSync(path.join(srcDir, e)).isDirectory());
  const conceptFiles = entries.filter(isConcept);

  // Respect an explicit subdir order from the root _dir.json when present.
  const orderedSubdirs = meta.subdirs
    ? meta.subdirs.filter((s) => subdirs.includes(s)).concat(subdirs.filter((s) => !meta.subdirs.includes(s)))
    : subdirs;

  let md = `# ${meta.title}\n\n`;
  if (meta.intro) md += `${meta.intro}\n\n`;

  if (orderedSubdirs.length) {
    md += `## Sections\n\n`;
    for (const sub of orderedSubdirs) {
      const subMeta = readDirMeta(path.join(srcDir, sub));
      md += `- [${subMeta.title}](/${relBase}${sub}/) — ${subMeta.intro || ""}`.trimEnd() + "\n";
    }
    md += "\n";
  }

  if (conceptFiles.length) {
    md += `## Concepts\n\n`;
    md += `| Concept | What it covers |\n| --- | --- |\n`;
    for (const f of conceptFiles) {
      const { data } = parseFrontmatter(fs.readFileSync(path.join(srcDir, f), "utf8"));
      const id = `/${relBase}${f.replace(/\.md$/, "")}`;
      const title = data.title || f.replace(/\.md$/, "");
      const desc = (data.description || "").replace(/\|/g, "\\|");
      md += `| [${title}](${id}) | ${desc} |\n`;
    }
    md += "\n";
  } else if (!orderedSubdirs.length) {
    md += `_Concept files land in the authoring campaign._\n`;
  }

  fs.writeFileSync(path.join(outDir, "index.md"), md);

  // Copy concept files verbatim (frontmatter preserved), recurse into subdirs.
  for (const f of conceptFiles) {
    fs.copyFileSync(path.join(srcDir, f), path.join(outDir, f));
  }
  for (const sub of orderedSubdirs) {
    buildIndex(path.join(srcDir, sub), path.join(outDir, sub), `${relBase}${sub}/`);
  }
  return { concepts: conceptFiles.length, subdirs: orderedSubdirs.length };
}

fs.mkdirSync(OUT, { recursive: true });
buildIndex(SRC, OUT, "");

// log.md is a reserved OKF file (no frontmatter); copy it into the bundle root.
const logSrc = path.join(SRC, "log.md");
if (fs.existsSync(logSrc)) fs.copyFileSync(logSrc, path.join(OUT, "log.md"));

// Count what we emitted for the console summary.
let conceptCount = 0;
(function count(dir) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) count(p);
    else if (isConcept(f)) conceptCount++;
  }
})(OUT);

// ---------------------------------------------------------------------------
// Implementation layer: the CEM-verified component cards (tag-level API)
// ---------------------------------------------------------------------------
fs.mkdirSync(path.join(IMPL, "components"), { recursive: true });
const cardFiles = fs.existsSync(CARDS) ? fs.readdirSync(CARDS).filter((f) => f.endsWith(".md")).sort() : [];
for (const f of cardFiles) {
  fs.copyFileSync(path.join(CARDS, f), path.join(IMPL, "components", f));
}

// index.md for the implementation root — clearly labels this as the tech-specific,
// CEM-verified layer and points back to the neutral bundle. No frontmatter (OKF rule).
let implIndex = `# @m3e/web — verified implementation layer\n\n`;
implIndex += `Technology-specific, **CEM-verified** component API for the \`@m3e/web\` custom-element\n`;
implIndex += `library (\`matraic/m3e\`). These cards are tag-level API — real \`<m3e-*>\` tags,\n`;
implIndex += `attributes, slots, events, and CSS tokens — generated from the library's build-time\n`;
implIndex += `Custom Elements Manifest. For technology-neutral design guidance (anatomy, usage,\n`;
implIndex += `accessibility), see the [knowledge bundle](/index).\n\n`;
implIndex += `## Components (${cardFiles.length})\n\n`;
implIndex += cardFiles
  .map((f) => `- [${f.replace(/\.md$/, "")}](/implementations/m3e-web/components/${f.replace(/\.md$/, "")})`)
  .join("\n") + "\n";
fs.writeFileSync(path.join(IMPL, "index.md"), implIndex);

console.log(
  `okf: ${conceptCount} concept files across the bundle; ${cardFiles.length} CEM-verified cards under implementations/m3e-web/`
);
