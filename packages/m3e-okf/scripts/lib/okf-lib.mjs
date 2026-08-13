// okf-lib.mjs — dependency-free helpers for the Open Knowledge Format bundle.
//
// A minimal YAML-frontmatter reader (the repo is intentionally dep-free) plus
// link extraction, kept separate from the build/validate CLIs so they're
// unit-testable without the filesystem. The parser handles the shapes THIS bundle
// uses — scalars, inline `[a, b]` lists, block `- ` lists, and a block list of
// `{key: value}` maps (the `sources:` shape) — not arbitrary YAML.

/**
 * Split a markdown string into its leading `---`-fenced frontmatter and body.
 * Returns { data, body, raw, hasFrontmatter }. `data` is {} when absent.
 */
export function parseFrontmatter(md) {
  const m = md.match(/^---\n([\s\S]*?)\n---\n?/);
  if (!m) return { data: {}, body: md, raw: null, hasFrontmatter: false };
  return { data: parseYaml(m[1]), body: md.slice(m[0].length), raw: m[1], hasFrontmatter: true };
}

/** Parse the restricted YAML subset the bundle's frontmatter uses. */
export function parseYaml(src) {
  const lines = src.split("\n");
  const data = {};
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim() || line.trim().startsWith("#")) { i++; continue; }
    const kv = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!kv) { i++; continue; }
    const key = kv[1];
    const rest = kv[2].trim();

    if (rest === "" ) {
      // Block value: either a `- ` list or nested — collect indented lines.
      const block = [];
      i++;
      while (i < lines.length && (lines[i].startsWith("  ") || lines[i].trim() === "")) {
        if (lines[i].trim() !== "") block.push(lines[i]);
        i++;
      }
      data[key] = parseBlock(block);
    } else if (rest.startsWith("[") && rest.endsWith("]")) {
      data[key] = rest.slice(1, -1).split(",").map((s) => unquote(s.trim())).filter((s) => s !== "");
      i++;
    } else {
      data[key] = unquote(rest);
      i++;
    }
  }
  return data;
}

// A block is a list of `- ` items. Each item is either a scalar or, when the
// item carries `key: value` pairs (possibly across following indented lines), a map.
function parseBlock(lines) {
  const items = [];
  let cur = null;
  for (const raw of lines) {
    const item = raw.match(/^\s*-\s+(.*)$/);
    if (item) {
      if (cur) items.push(cur);
      const inner = item[1];
      const kv = inner.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
      if (kv) { cur = { [kv[1]]: unquote(kv[2].trim()) }; }
      else { if (cur) items.push(cur); cur = unquote(inner); items.push(cur); cur = null; }
    } else if (cur && typeof cur === "object") {
      const kv = raw.trim().match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
      if (kv) cur[kv[1]] = unquote(kv[2].trim());
    }
  }
  if (cur) items.push(cur);
  return items;
}

function unquote(s) {
  if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
    return s.slice(1, -1);
  }
  return s;
}

/**
 * Extract markdown link targets from body prose (fenced code excluded), returning
 * an array of raw hrefs. Anchors/mailto/external are included; the caller decides
 * which to resolve.
 */
export function extractLinks(body) {
  const prose = body.replace(/```[\s\S]*?```/g, "");
  const links = [];
  for (const m of prose.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) links.push(m[1].trim());
  return links;
}

/** True if a design-claim heuristic fires on the prose (reuses the guidance rule). */
export function makesDesignClaim(body) {
  const prose = body.replace(/```[\s\S]*?```/g, "");
  return /\b(should|prefer|avoid|never|always|must|don['’]t|do not|use\b.*\bwhen)\b/i.test(prose);
}

// ---------------------------------------------------------------------------
// Paraphrase / verbatim-run check (D6 licensing).
//
// The curation discipline forbids pasting source prose: no run of N+ consecutive
// words may be identical to a cited source. These helpers implement that as a word
// shingle comparison so the curation skill (and, where a local source snapshot is
// available, the validator) can flag copy-paste deterministically. The default
// window is 15 words. Source text is normalized to lowercase word tokens so
// punctuation/whitespace/case differences don't hide a lift.
// ---------------------------------------------------------------------------

/** Normalize prose to a flat array of lowercase word tokens (code fences stripped). */
export function words(text) {
  return (text || "")
    .replace(/```[\s\S]*?```/g, " ")
    .toLowerCase()
    .replace(/[^a-z0-9'’]+/g, " ")
    .trim()
    .split(/\s+/)
    .filter(Boolean);
}

/** Set of N-word shingles (as space-joined strings) over a token array. */
export function shingles(tokens, n = 15) {
  const out = new Set();
  for (let i = 0; i + n <= tokens.length; i++) out.add(tokens.slice(i, i + n).join(" "));
  return out;
}

/**
 * Find every N-word run that appears verbatim in BOTH `text` and `source`.
 * Returns an array of the offending shingles (empty = clean paraphrase). N=15 by
 * default — a run that long is a copy-paste signal, not incidental phrasing.
 */
export function verbatimRuns(text, source, n = 15) {
  const src = shingles(words(source), n);
  if (!src.size) return [];
  const hits = [];
  for (const s of shingles(words(text), n)) if (src.has(s)) hits.push(s);
  return hits;
}
