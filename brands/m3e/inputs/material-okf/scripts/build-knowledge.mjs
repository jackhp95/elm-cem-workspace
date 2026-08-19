// build-knowledge.mjs -- generate knowledge/ from data/knowledge/**.
//
// DECISION (Phase 5b, carried over from the pre-split build-okf.mjs):
// knowledge/ is a GENERATED TARGET, not a hand-edited tree. The source of
// truth is data/knowledge/** (technology-neutral authored prose with OKF
// frontmatter) + data/knowledge/*/_dir.json (per-directory metadata). This
// build copies the concept files verbatim into knowledge/**, copies log.md,
// and DERIVES each directory's index.md deterministically from _dir.json +
// the frontmatter of the concept files present.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter } from "../../../../../tools/lib/okf-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SRC = path.join(ROOT, "data/knowledge");
const OUT = path.join(ROOT, "knowledge");

const isConcept = (f) => f.endsWith(".md") && f !== "index.md" && f !== "log.md";

function rmrf(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}
rmrf(OUT);

function readDirMeta(srcDir) {
  const p = path.join(srcDir, "_dir.json");
  return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : { title: path.basename(srcDir), intro: "" };
}

function buildIndex(srcDir, outDir, relBase) {
  fs.mkdirSync(outDir, { recursive: true });
  const meta = readDirMeta(srcDir);

  const entries = fs.readdirSync(srcDir).sort();
  const subdirs = entries.filter((e) => fs.statSync(path.join(srcDir, e)).isDirectory());
  const conceptFiles = entries.filter(isConcept);

  const orderedSubdirs = meta.subdirs
    ? meta.subdirs.filter((s) => subdirs.includes(s)).concat(subdirs.filter((s) => !meta.subdirs.includes(s)))
    : subdirs;

  let md = `# ${meta.title}\n\n`;
  if (meta.intro) md += `${meta.intro}\n\n`;

  if (orderedSubdirs.length) {
    md += `## Sections\n\n`;
    for (const sub of orderedSubdirs) {
      const subMeta = readDirMeta(path.join(srcDir, sub));
      md += `- [${subMeta.title}](/${relBase}${sub}/) -- ${subMeta.intro || ""}`.trimEnd() + "\n";
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

const logSrc = path.join(SRC, "log.md");
if (fs.existsSync(logSrc)) fs.copyFileSync(logSrc, path.join(OUT, "log.md"));

let conceptCount = 0;
(function count(dir) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) count(p);
    else if (isConcept(f)) conceptCount++;
  }
})(OUT);

console.log(`build-knowledge: ${conceptCount} concept files across the knowledge bundle`);
