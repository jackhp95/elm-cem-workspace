#!/usr/bin/env node
// Mechanical guard for skills/ — dep-free frontmatter lint + intra-repo link
// resolution. Does NOT compile Elm snippets (that is out of scope; the golden
// suite already gates the generator). Exits non-zero on any violation.
//
// Checks, per skills/<name>/SKILL.md:
//   • YAML frontmatter present, delimited by --- / ---
//   • name: gerund-ish, lowercase-hyphen only, <= 64 chars, matches its dir
//   • description: present, <= 1024 chars
//   • disable-model-invocation (if present) is a boolean
//   • body under 500 lines (progressive-disclosure budget)
//   • every intra-repo markdown/link reference (reference/*.md, ../, ./)
//     resolves to a file that exists
//   • evals.json (if present) parses as JSON
//
// Run standalone: `node skills/check-skills.mjs`. Wired into .github/workflows/ci.yml.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const problems = [];
const rel = (p) => path.relative(path.resolve(here, ".."), p);

function fail(file, msg) {
  problems.push(`${rel(file)}: ${msg}`);
}

// Parse the minimal subset of YAML frontmatter we emit: `key: value` lines,
// no nesting. Returns { data, bodyStartLine, body } or null if no frontmatter.
function parseFrontmatter(text) {
  const lines = text.split("\n");
  if (lines[0].trim() !== "---") return null;
  let end = -1;
  for (let i = 1; i < lines.length; i++) {
    if (lines[i].trim() === "---") {
      end = i;
      break;
    }
  }
  if (end === -1) return null;
  const data = {};
  for (let i = 1; i < end; i++) {
    const line = lines[i];
    if (!line.trim() || line.trimStart().startsWith("#")) continue;
    const idx = line.indexOf(":");
    if (idx === -1) continue;
    const key = line.slice(0, idx).trim();
    let val = line.slice(idx + 1).trim();
    if (
      (val.startsWith('"') && val.endsWith('"')) ||
      (val.startsWith("'") && val.endsWith("'"))
    ) {
      val = val.slice(1, -1);
    }
    data[key] = val;
  }
  return { data, bodyStartLine: end + 1, body: lines.slice(end + 1) };
}

// Collect intra-repo link targets from a markdown body: []() links and bare
// reference/ paths. Skips absolute URLs, mailto, and anchors.
function linkTargets(body) {
  const targets = [];
  const linkRe = /\]\(([^)]+)\)/g;
  for (const line of body) {
    let m;
    while ((m = linkRe.exec(line)) !== null) {
      let t = m[1].trim();
      t = t.split("#")[0].split(" ")[0];
      if (!t) continue;
      if (/^[a-z]+:\/\//i.test(t) || t.startsWith("mailto:")) continue;
      if (t.startsWith("http")) continue;
      targets.push(t);
    }
  }
  return targets;
}

const skillsDir = here;
const entries = fs
  .readdirSync(skillsDir, { withFileTypes: true })
  .filter((e) => e.isDirectory());

if (entries.length === 0) fail(skillsDir, "no skill directories found");

let checked = 0;
for (const dirEnt of entries) {
  const dir = path.join(skillsDir, dirEnt.name);
  const skillPath = path.join(dir, "SKILL.md");
  if (!fs.existsSync(skillPath)) {
    fail(dir, "missing SKILL.md");
    continue;
  }
  checked++;
  const text = fs.readFileSync(skillPath, "utf8");
  const fm = parseFrontmatter(text);
  if (!fm) {
    fail(skillPath, "missing or unterminated YAML frontmatter (--- ... ---)");
    continue;
  }
  const { data, body } = fm;

  // name
  const name = data.name;
  if (!name) {
    fail(skillPath, "frontmatter missing `name`");
  } else {
    if (name.length > 64) fail(skillPath, `name > 64 chars (${name.length})`);
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(name))
      fail(skillPath, `name must be lowercase-hyphen only: "${name}"`);
    if (name !== dirEnt.name)
      fail(skillPath, `name "${name}" does not match directory "${dirEnt.name}"`);
  }

  // description
  const desc = data.description;
  if (!desc) {
    fail(skillPath, "frontmatter missing `description`");
  } else if (desc.length > 1024) {
    fail(skillPath, `description > 1024 chars (${desc.length})`);
  }

  // disable-model-invocation, if present, must be boolean-ish
  if ("disable-model-invocation" in data) {
    const v = data["disable-model-invocation"];
    if (v !== "true" && v !== "false")
      fail(skillPath, `disable-model-invocation must be true|false, got "${v}"`);
  }

  // body budget
  if (body.length > 500)
    fail(skillPath, `body > 500 lines (${body.length}); split into reference/`);

  // intra-repo links resolve
  for (const t of linkTargets(body)) {
    const resolved = path.resolve(dir, t);
    if (!fs.existsSync(resolved))
      fail(skillPath, `broken intra-repo link: ${t}`);
  }

  // evals.json parses
  const evalsPath = path.join(dir, "evals.json");
  if (fs.existsSync(evalsPath)) {
    try {
      JSON.parse(fs.readFileSync(evalsPath, "utf8"));
    } catch (e) {
      fail(evalsPath, `invalid JSON: ${e.message}`);
    }
  }
}

if (problems.length > 0) {
  console.error("check-skills: FAIL\n");
  for (const p of problems) console.error(`  ${p}`);
  console.error(`\n${problems.length} problem(s) across ${checked} skill(s).`);
  process.exit(1);
}

console.log(`check-skills: OK — ${checked} skill(s), frontmatter + links clean.`);
