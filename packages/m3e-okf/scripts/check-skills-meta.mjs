// check-skills-meta.mjs — mechanical guard for the skills/ frontmatter + links.
//
// Every skills/<name>/SKILL.md must carry valid Anthropic/agentskills.io metadata:
//   - frontmatter present, with `name` and `description`
//   - `name` lowercase-hyphen, <=64 chars, and equal to the skill directory name
//   - `description` non-empty and <=1024 chars
//   - SKILL.md body under 500 lines (progressive-disclosure budget)
//   - relative links inside the skill dir (e.g. reference/foo.md) resolve on disk;
//     bundle-absolute links (/knowledge/..., /implementations/...) are treated as
//     cross-bundle references and only checked when they point into this repo's
//     knowledge/ or implementations/ trees.
//
// Exits non-zero on any violation. This does NOT re-fetch anything; it runs on the
// committed tree, matching the repo's committed-inputs-only CI contract.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter, extractLinks } from "./lib/okf-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SKILLS = path.join(ROOT, "skills");
const KNOW = path.join(ROOT, "knowledge");
const IMPL = path.join(ROOT, "implementations");

const NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const errors = [];

const skillDirs = fs
  .readdirSync(SKILLS)
  .filter((d) => fs.statSync(path.join(SKILLS, d)).isDirectory());

let count = 0;
for (const dir of skillDirs.sort()) {
  const skillMd = path.join(SKILLS, dir, "SKILL.md");
  if (!fs.existsSync(skillMd)) { errors.push(`${dir}/: no SKILL.md`); continue; }
  count++;
  const raw = fs.readFileSync(skillMd, "utf8");
  const { data, body, hasFrontmatter } = parseFrontmatter(raw);

  if (!hasFrontmatter) { errors.push(`${dir}/SKILL.md: missing YAML frontmatter`); continue; }

  // name
  if (!data.name) errors.push(`${dir}/SKILL.md: frontmatter missing 'name'`);
  else {
    if (!NAME_RE.test(data.name)) errors.push(`${dir}/SKILL.md: name '${data.name}' is not lowercase-hyphen`);
    if (data.name.length > 64) errors.push(`${dir}/SKILL.md: name '${data.name}' exceeds 64 chars`);
    if (data.name !== dir) errors.push(`${dir}/SKILL.md: name '${data.name}' != directory '${dir}'`);
  }

  // description
  if (!data.description) errors.push(`${dir}/SKILL.md: frontmatter missing 'description'`);
  else if (data.description.length > 1024) errors.push(`${dir}/SKILL.md: description ${data.description.length} chars > 1024`);

  // body length budget
  const bodyLines = body.split("\n").length;
  if (bodyLines > 500) errors.push(`${dir}/SKILL.md: body ${bodyLines} lines > 500`);

  // link resolution (relative + into-repo bundle-absolute)
  const walkMd = (d, acc = []) => {
    for (const f of fs.readdirSync(d)) {
      const p = path.join(d, f);
      if (fs.statSync(p).isDirectory()) walkMd(p, acc);
      else if (f.endsWith(".md")) acc.push(p);
    }
    return acc;
  };
  for (const md of walkMd(path.join(SKILLS, dir))) {
    const text = fs.readFileSync(md, "utf8");
    for (const href of extractLinks(text)) {
      const [target] = href.split("#");
      if (!target || /^(https?:|mailto:)/.test(target)) continue;
      const rel = path.relative(SKILLS, md);
      if (target.startsWith("/knowledge/") || target === "/knowledge/index.md") {
        const p = path.join(ROOT, target.replace(/^\//, ""));
        const asMd = p.endsWith(".md") ? p : p.replace(/\/$/, "") + ".md";
        const asIndex = path.join(p.replace(/\/$/, ""), "index.md");
        if (!fs.existsSync(asMd) && !fs.existsSync(asIndex) && !fs.existsSync(p)) errors.push(`${rel}: unresolved bundle link -> ${href}`);
      } else if (target.startsWith("/implementations/")) {
        const p = path.join(ROOT, target.replace(/^\//, ""));
        const asMd = p.endsWith(".md") ? p : p + ".md";
        if (!fs.existsSync(asMd) && !fs.existsSync(p)) errors.push(`${rel}: unresolved implementation link -> ${href}`);
      } else if (!target.startsWith("/")) {
        // relative to this file's dir
        const p = path.resolve(path.dirname(md), target);
        if (!fs.existsSync(p)) errors.push(`${rel}: unresolved relative link -> ${href}`);
      }
    }
  }
}

if (errors.length) {
  console.error(`✗ skills metadata check failed (${errors.length} problem(s)):`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`✓ ${count} skill(s) — frontmatter valid, bodies within budget, links resolve.`);
