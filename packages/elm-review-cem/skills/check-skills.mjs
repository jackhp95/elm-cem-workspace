#!/usr/bin/env node
// check-skills.mjs — dep-free mechanical guard for the skills/ directory.
//
// Lints each skills/<name>/SKILL.md frontmatter and resolves every intra-repo
// (relative) markdown link in SKILL.md and its reference/ files. Exits non-zero
// on any problem so CI can gate on it. Generic and repo-agnostic on purpose —
// other repos copy this file verbatim.
//
// Checks per SKILL.md:
//   - frontmatter present, parseable, with `name` and `description`
//   - name: lowercase-hyphen, <=64 chars, and gerund-ish (ends in "ing" on its
//     first word) — the convention for skill names
//   - description: present, <=1024 chars, third-person-ish (not starting with
//     "Use " / an imperative "you"/"I"), and mentions a trigger/when signal
//   - dir name matches the frontmatter `name`
// Plus, across SKILL.md and reference/*.md:
//   - every relative link target resolves on disk
//
// Usage: node skills/check-skills.mjs   (run from repo root or anywhere)

import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve, relative } from "node:path";

const SKILLS_DIR = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(SKILLS_DIR, "..");

const errors = [];
const err = (where, msg) => errors.push(`${where}: ${msg}`);

// --- minimal YAML frontmatter parser (dep-free) ---------------------------
// Handles the subset we emit: `key: value`, `key: >-` folded block scalars,
// and quoted scalars. Not a general YAML parser.
function parseFrontmatter(raw, where) {
  if (!raw.startsWith("---")) {
    err(where, "missing frontmatter (file must start with '---')");
    return null;
  }
  const end = raw.indexOf("\n---", 3);
  if (end === -1) {
    err(where, "unterminated frontmatter (no closing '---')");
    return null;
  }
  const block = raw.slice(3, end).replace(/^\n/, "");
  const lines = block.split("\n");
  const out = {};
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (line.trim() === "" || line.trimStart().startsWith("#")) {
      i++;
      continue;
    }
    const m = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!m) {
      i++;
      continue;
    }
    const key = m[1];
    let val = m[2];
    if (val === ">-" || val === ">" || val === "|" || val === "|-") {
      // Folded/literal block scalar: gather more-indented following lines.
      const fold = val.startsWith(">");
      const collected = [];
      i++;
      while (i < lines.length && (lines[i].startsWith("  ") || lines[i].trim() === "")) {
        collected.push(lines[i].replace(/^ {2}/, ""));
        i++;
      }
      out[key] = fold
        ? collected.map((l) => l.trim()).filter(Boolean).join(" ")
        : collected.join("\n").trim();
      continue;
    }
    // strip surrounding quotes
    val = val.replace(/^["'](.*)["']$/, "$1");
    out[key] = val;
    i++;
  }
  return out;
}

// --- frontmatter lints -----------------------------------------------------
function lintFrontmatter(fm, dirName, where) {
  if (!fm) return;

  const name = fm.name;
  if (!name) {
    err(where, "frontmatter missing `name`");
  } else {
    if (name.length > 64) err(where, `name >64 chars (${name.length})`);
    if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(name))
      err(where, `name must be lowercase-hyphen: "${name}"`);
    const firstWord = name.split("-")[0];
    if (!firstWord.endsWith("ing"))
      err(where, `name should be a gerund (first word ends in "ing"): "${name}"`);
    if (name !== dirName)
      err(where, `frontmatter name "${name}" != directory name "${dirName}"`);
  }

  const desc = fm.description;
  if (!desc) {
    err(where, "frontmatter missing `description`");
  } else {
    if (desc.length > 1024) err(where, `description >1024 chars (${desc.length})`);
    // third-person-ish: should not open with an imperative/second-person verb.
    if (/^\s*(use\b|you\b|i\b)/i.test(desc))
      err(where, "description should be third-person (state what it does + when), not open with Use/You/I");
    // must encode a WHEN/trigger routing signal
    if (!/\b(use when|when |trigger|triggers)\b/i.test(desc))
      err(where, "description should state WHEN to use it (a 'when'/'trigger' signal)");
  }
}

// --- link resolution -------------------------------------------------------
function checkLinks(filePath, where) {
  const raw = readFileSync(filePath, "utf8");
  const base = dirname(filePath);
  const linkRe = /\[[^\]]*\]\(([^)]+)\)/g;
  let m;
  while ((m = linkRe.exec(raw)) !== null) {
    let target = m[1].trim();
    // ignore external links, anchors, mailto
    if (/^(https?:|mailto:|#)/.test(target)) continue;
    // strip a trailing #anchor
    target = target.split("#")[0];
    if (target === "") continue;
    const resolved = resolve(base, target);
    if (!existsSync(resolved))
      err(where, `broken relative link -> "${m[1]}" (resolved: ${relative(REPO_ROOT, resolved)})`);
  }
}

// --- walk skills/ ----------------------------------------------------------
function isDir(p) {
  try {
    return statSync(p).isDirectory();
  } catch {
    return false;
  }
}

const skillDirs = readdirSync(SKILLS_DIR).filter((d) => isDir(join(SKILLS_DIR, d)));

let skillCount = 0;
for (const dirName of skillDirs) {
  const dir = join(SKILLS_DIR, dirName);
  const skillMd = join(dir, "SKILL.md");
  if (!existsSync(skillMd)) continue; // a dir without SKILL.md isn't a skill
  skillCount++;
  const where = relative(REPO_ROOT, skillMd);
  const raw = readFileSync(skillMd, "utf8");
  const fm = parseFrontmatter(raw, where);
  lintFrontmatter(fm, dirName, where);
  checkLinks(skillMd, where);

  // reference files
  const refDir = join(dir, "reference");
  if (isDir(refDir)) {
    for (const f of readdirSync(refDir)) {
      if (f.endsWith(".md")) {
        const fp = join(refDir, f);
        checkLinks(fp, relative(REPO_ROOT, fp));
      }
    }
  }
}

if (skillCount === 0) {
  console.error("check-skills: no skills found under skills/");
  process.exit(1);
}

if (errors.length > 0) {
  console.error(`check-skills: FAIL — ${errors.length} problem(s) across ${skillCount} skill(s):`);
  for (const e of errors) console.error(`  ${e}`);
  process.exit(1);
}

console.log(`check-skills: OK — ${skillCount} skill(s) lint clean, all links resolve.`);
