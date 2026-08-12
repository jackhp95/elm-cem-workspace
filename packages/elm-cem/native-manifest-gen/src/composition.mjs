// Extract the per-element content model (Children column) from the WHATWG
// "List of elements" index table -> closed structural child sets for the Build facet.
//
// Two layers:
//   loadContentModel()   — raw per-element parse of the Children column.
//   structuralFamilies() — productionized: keeps ONLY the closed structural
//                          parent/child families (element-name children), drops
//                          content-category tokens (flow/phrasing/...) and the
//                          scripting-support noise (script/template/noscript),
//                          and records per-child multiplicity (multi/required).

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Content-category tokens that appear in the Children column but are NOT
// specific element names. These are the deliberate editorial boundary
// (flow vs phrasing enforcement) we do NOT model here.
const CATEGORIES = new Set([
  'flow', 'phrasing', 'transparent', 'metadata', 'sectioning',
  'heading', 'interactive', 'embedded', 'palpable', 'text',
  'script-supporting elements', 'script-supporting', 'empty', 'none',
  'metadata content', 'heading content', 'sectioning content',
  'flow content', 'phrasing content', 'varies',
]);

// Scripting-support / SVG / MathML noise that shows up as element names in the
// Children column but is not part of a meaningful closed *structural* family.
// (WHATWG lets script/template/noscript appear almost anywhere as
// "script-supporting elements"; they are not authored as real structural slots.)
const NOISE_CHILDREN = new Set(['script', 'template', 'noscript']);

const strip = s => s.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

// Parse one child token from the Children column into { name, multi, required }.
//   "option*"    -> zero-or-more   (multi:true,  required:false)
//   "one img"    -> exactly one    (multi:false, required:true)
//   "li"         -> zero-or-more   (list contexts; repeatable)  (multi:true, required:false)
function parseChildToken(rawTok) {
  const tok = rawTok.trim();
  if (!tok) return null;
  const star = tok.endsWith('*');
  let name = tok.replace(/\*$/, '').trim();
  let required = false;
  let multi = true;
  const oneMatch = name.match(/^one\s+(.+)$/);
  const zeroOrMore = name.match(/^zero or more\s+(.+)$/);
  if (oneMatch) {
    name = oneMatch[1].trim();
    // "one X" without a star = exactly one required child.
    required = true;
    multi = false;
  } else if (zeroOrMore) {
    name = zeroOrMore[1].trim();
    multi = true;
    required = false;
  } else if (star) {
    // "X*" = zero or more.
    multi = true;
    required = false;
  } else {
    // Bare element name in a list content model (e.g. ul::li, tbody::tr):
    // WHATWG treats these as zero-or-more repeatable children.
    multi = true;
    required = false;
  }
  return { name, multi, required };
}

export async function loadContentModel() {
  const t = await (await fetch('https://html.spec.whatwg.org/multipage/indices.html')).text();
  const cS = t.indexOf('<caption>List of elements');
  const tbl = t.slice(t.lastIndexOf('<table', cS), t.indexOf('</table>', cS));
  const rows = tbl.split('<tr>').slice(2);
  const byEl = {};
  for (const r of rows) {
    const th = r.match(/<th[^>]*>([\s\S]*?)(?=<td)/);
    const tds = r.split(/<td[^>]*>/).slice(1).map(strip);
    if (!th || tds.length < 6) continue;
    const name = strip(th[1]);
    const childrenRaw = tds[3];
    const rawTokens = childrenRaw.split(';').map(s => s.trim()).filter(Boolean);
    const parsed = rawTokens.map(parseChildToken).filter(Boolean);
    const elementChildren = parsed.filter(c => !CATEGORIES.has(c.name) && !CATEGORIES.has(c.name.replace(/s$/, '')));
    const categoryChildren = parsed.filter(c => CATEGORIES.has(c.name) || CATEGORIES.has(c.name.replace(/s$/, '')));
    byEl[name] = { categories: tds[1], parents: tds[2], childrenRaw, elementChildren, categoryChildren };
  }
  return byEl;
}

// Productionized structural view. Returns { parent -> [ {name, multi, required} ] }
// for elements that own a CLOSED structural child set (specific element-name
// children, after dropping SVG/MathML/scripting noise). Single-token element
// names like "MathML math" / "SVG svg" are excluded (space in name = not HTML).
export async function structuralFamilies(byEl) {
  byEl = byEl || (await loadContentModel());
  const families = {};
  for (const [name, e] of Object.entries(byEl)) {
    if (name.includes(' ')) continue; // "MathML math", "SVG svg"
    const kids = e.elementChildren.filter(c => !NOISE_CHILDREN.has(c.name) && !c.name.includes(' '));
    if (kids.length === 0) continue;
    families[name] = kids;
  }
  return families;
}

// Offline cache helpers so a self-test can run without network access.
const CACHE = path.join(__dirname, '..', 'data', 'whatwg-content-model.json');

export async function loadContentModelCached() {
  if (fs.existsSync(CACHE)) {
    return JSON.parse(fs.readFileSync(CACHE, 'utf8'));
  }
  const byEl = await loadContentModel();
  fs.mkdirSync(path.dirname(CACHE), { recursive: true });
  fs.writeFileSync(CACHE, JSON.stringify(byEl, null, 2));
  return byEl;
}
