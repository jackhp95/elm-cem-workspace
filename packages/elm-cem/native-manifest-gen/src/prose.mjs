// prose.mjs — build data/prose.json: real element summaries + attribute
// descriptions for the FULL HTML surface, eliminating generic fallbacks.
//
// Shape:
//   { "_license": "...", "elements": {tag: summary}, "attributes": {name: desc} }
//
// Sources (in preference order):
//   1. MDN (optional, via the NATIVE_MDN_JSON env var pointing at a captured
//      native-mdn.json) — richer prose for the 16 v1 elements + 24 v1 attrs;
//      preferred where present.
//   2. WHATWG indices tables (data/whatwg-indices.html — cached raw HTML):
//        • "List of elements"      -> element Description column (all 113)
//        • "List of attributes …"  -> attribute Description column
//      Column order for both attribute-ish tables:
//        Attribute | Element(s) | Description | Value.
//      The elements table is: Element | Description | Categories | … .
//   3. WHATWG event-handler table -> on* descriptions (via events.mjs).
//   4. A small hand-written map for names with no spec Description cell
//      (globals & new attrs whose Description column is empty), grounded in the
//      spec — no "The X attribute." placeholders.
//
// Contract: export `buildProse()` -> the object; self-test writes data/prose.json
// and prints coverage (elements N/113, attrs M/M) against out/reports.json's
// surface.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { eventAttributes, sliceTableByCaption } from './events.mjs';
import { ariaAttributes } from './aria.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const DATA = path.resolve(__dirname, '..', 'data');
const INDICES_HTML = path.resolve(DATA, 'whatwg-indices.html');
const PROSE_OUT = path.resolve(DATA, 'prose.json');

const WHATWG_LICENSE =
  'Element and attribute descriptions are adapted from the WHATWG HTML Standard ' +
  '(https://html.spec.whatwg.org/multipage/indices.html), used under the WHATWG ' +
  'license (permissive; see https://whatwg.org/ipr-policy). 16 element summaries ' +
  'and 24 attribute descriptions are sourced from MDN Web Docs (CC-BY-SA 2.5). ' +
  'ARIA and event-handler prose are hand-authored / WHATWG-sourced respectively.';

const strip = s => s.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

// MDN prose already captured for the v1 surface. Optional: point NATIVE_MDN_JSON
// at a captured native-mdn.json to enrich; absent/unreadable → empty (falls back
// to WHATWG prose below).
const MDN = (() => {
  try {
    const mdnPath = process.env.NATIVE_MDN_JSON;
    if (!mdnPath) return { elements: {}, attributes: {} };
    const n = require(path.resolve(mdnPath));
    return n._native?.summaries || { elements: {}, attributes: {} };
  } catch {
    return { elements: {}, attributes: {} };
  }
})();

function loadIndicesHtml() {
  if (!fs.existsSync(INDICES_HTML)) {
    throw new Error(`missing ${INDICES_HTML} — run events.fetchIndicesHtml() first`);
  }
  return fs.readFileSync(INDICES_HTML, 'utf8');
}

// ---- WHATWG "List of elements" -> {tag: description} -------------------------
// Row: <tr><th><code>tag</code>…</th><td>Description<td>Categories… .
// One row can name multiple tags (h1–h6); apply its description to each.
export function parseElementsTable(html) {
  const tbl = sliceTableByCaption(html, 'List of elements');
  const body = tbl.slice(tbl.indexOf('<tbody'));
  const rows = body.split('<tr>').slice(1);
  const out = {};
  for (const r of rows) {
    const parts = r.split('<td>');
    if (parts.length < 2) continue;
    const th = parts[0];
    const desc = strip(parts[1]); // first <td> after the <th> = Description
    const tags = [...th.matchAll(/>([a-zA-Z0-9]+)<\/a><\/code>/g)].map(m => m[1]);
    for (const t of tags) if (t) out[t] = desc;
  }
  return out;
}

// ---- WHATWG "List of attributes" -> {name: description} ----------------------
// Columns: Attribute | Element(s) | Description | Value. Description is the 2nd
// <td> (index 1 after splitting off the <th>). Keep the first non-empty.
export function parseAttributeDescriptions(html) {
  const tbl = sliceTableByCaption(html, 'List of attributes (excluding event handler content attributes)');
  const body = tbl.slice(tbl.indexOf('<tbody'));
  const rows = body.split('<tr>').slice(1);
  const out = {};
  for (const r of rows) {
    const th = r.match(/<th[^>]*>\s*<code>([a-zA-Z0-9:_-]+)<\/code>/);
    if (!th) continue;
    const name = th[1];
    const tds = r.split('<td>').slice(1).map(strip);
    const desc = tds[1] || ''; // [0]=Element(s), [1]=Description, [2]=Value
    if (!(name in out) || (!out[name] && desc)) out[name] = desc;
  }
  return out;
}

// ---- hand-written prose for names with an empty/absent WHATWG Description ----
// Grounded in the WHATWG/DOM/ARIA specs; used only when the tables yield nothing.
const HAND_ATTR = {
  // globals whose indices Description cell is empty in the current spec dump:
  role: 'The WAI-ARIA role token that overrides the implicit semantics of the element.',
  part: 'Names the element so it can be targeted by the ::part() pseudo-element from outside its shadow tree.',
  exportparts: 'Re-exports named shadow parts of a nested shadow tree to the outer tree for ::part() styling.',
  is: 'Instantiates the element as a customized built-in element defined by the given custom element name.',
  itemid: 'A global unique identifier for a microdata item.',
  itemprop: 'Adds one or more microdata properties to an item.',
  itemref: 'References additional microdata property elements by id.',
  itemscope: 'Creates a new microdata item associated with the element.',
  itemtype: 'The item types (as URLs) of a microdata item.',
  nonce: 'A cryptographic nonce used by Content-Security-Policy to allow this element.',
  // newer attrs that may lack an indices Description cell:
  privateToken: 'Configures Private State Token operations for the fetch (experimental).',
  attributionsrc: 'Registers the element as an attribution source/trigger for the Attribution Reporting API.',
  attributionsourceid: 'Legacy Attribution Reporting source id (experimental).',
  browsingtopics: 'Opts the request into the Topics API (experimental).',
  credentialless: 'Loads the iframe in a new, credentialless ephemeral context.',
  csp: 'A Content Security Policy to enforce on the framed document.',
  anchor: 'Associates the element with an anchor element for CSS anchor positioning.',
  virtualkeyboardpolicy: 'Controls whether the on-screen virtual keyboard shows automatically on focus.',
  autocorrect: 'Whether to enable automatic correction of editable text.',
  writingsuggestions: 'Whether to show browser-provided writing suggestions in editable fields.',
  headingoffset: 'Offsets the computed heading level of descendant headings (experimental hgroup/heading proposal).',
  headingreset: 'Resets the heading-level offset for descendant headings (experimental).',
  interestfor: 'Associates the element with a target it shows interest in (experimental invoker/interest proposal).',
  switch: 'Renders the checkbox as a switch control.',
  commandfor: 'The id of the element that the command button acts upon.',
  command: 'The action a command button performs on its commandfor target.',
  shadowrootclonable: 'Whether a declarative shadow root is clonable.',
  shadowrootserializable: 'Whether a declarative shadow root is serializable.',
  shadowrootdelegatesfocus: 'Whether a declarative shadow root delegates focus.',
  shadowrootcustomelementregistry: 'Associates a declarative shadow root with a scoped custom element registry (experimental).',
  shadowrootreferencetarget: 'The reference target id for a declarative shadow root (experimental).',
  shadowrootslotassignment: 'The slot assignment mode for a declarative shadow root.',
  webkitdirectory: 'Allows the file input to select entire directories (non-standard).',
  closedby: 'Which user actions can light-dismiss the dialog ("any", "closerequest" or "none").',

  // --- live attrs whose indices Description cell is empty in the dump ---
  capture: 'Which camera or microphone to use when capturing media for a file input.',
  controlslist: 'Hints which native media controls the user agent should hide (nodownload, nofullscreen, noremoteplayback).',
  disablepictureinpicture: 'Disables the Picture-in-Picture feature for the video element.',
  disableremoteplayback: 'Disables remote-playback (casting) for the media element.',
  hreftranslate: 'A BCP 47 language tag hinting the preferred translation language of the linked resource.',
  xmlns: 'The XML namespace of the root element (only meaningful in XML/XHTML serialization).',

  // --- deprecated / obsolete presentational attributes (real spec meaning) ---
  align: 'Deprecated presentational alignment of the element; use CSS instead.',
  alink: 'Deprecated color of active hyperlinks in the document; use CSS instead.',
  allowpaymentrequest: 'Obsolete: allowed the iframe to use the Payment Request API.',
  archive: 'Obsolete: space-separated list of archive URLs for an applet/object.',
  axis: 'Obsolete: named the category of a table cell for header association.',
  background: 'Deprecated URL of a background image for the element; use CSS instead.',
  bgcolor: 'Deprecated background color of the element; use CSS instead.',
  border: 'Deprecated width of the border around a table or image; use CSS instead.',
  bottommargin: 'Deprecated bottom margin of the document body; use CSS instead.',
  cellpadding: 'Deprecated padding inside table cells; use CSS instead.',
  cellspacing: 'Deprecated spacing between table cells; use CSS instead.',
  char: 'Obsolete: the alignment character for a table column.',
  charoff: 'Obsolete: offset of column data from the alignment character.',
  classid: 'Obsolete: URL identifying the implementation of an object.',
  clear: 'Deprecated: controlled float clearing on a line break; use CSS instead.',
  codebase: 'Obsolete: base URL for resolving an object/applet relative URLs.',
  codetype: 'Obsolete: expected MIME type of the object code identified by classid.',
  compact: 'Deprecated: requested a compact rendering of a list; use CSS instead.',
  declare: 'Obsolete: declared an object without instantiating it.',
  frame: 'Deprecated: which outer borders of a table are drawn; use CSS instead.',
  frameborder: 'Deprecated: whether to draw a border around a frame/iframe; use CSS instead.',
  hspace: 'Deprecated: horizontal whitespace around the element; use CSS instead.',
  leftmargin: 'Deprecated left margin of the document body; use CSS instead.',
  link: 'Deprecated color of unvisited hyperlinks in the document; use CSS instead.',
  longdesc: 'Obsolete: URL of a long description of an image or frame.',
  marginheight: 'Deprecated top/bottom margin of a frame; use CSS instead.',
  marginwidth: 'Deprecated left/right margin of a frame; use CSS instead.',
  nohref: 'Obsolete: marked an image-map area as having no associated hyperlink.',
  noshade: 'Deprecated: rendered a horizontal rule without shading; use CSS instead.',
  rev: 'Obsolete: reverse link relationship from the linked resource to the current document.',
  rightmargin: 'Deprecated right margin of the document body; use CSS instead.',
  rules: 'Deprecated: which inner borders of a table are drawn; use CSS instead.',
  scheme: 'Obsolete: named the profile/scheme used to interpret a meta value.',
  scrolling: 'Deprecated: whether a frame provides scrollbars; use CSS instead.',
  standby: 'Obsolete: message shown while an object loads.',
  summary: 'Obsolete on table: a text description of the table for accessibility; use a caption instead.',
  text: 'Deprecated foreground text color of the document body; use CSS instead.',
  topmargin: 'Deprecated top margin of the document body; use CSS instead.',
  valign: 'Deprecated vertical alignment of table cell content; use CSS instead.',
  version: 'Obsolete: the HTML DTD version of the document.',
  vlink: 'Deprecated color of visited hyperlinks in the document; use CSS instead.',
  vspace: 'Deprecated: vertical whitespace around the element; use CSS instead.',
};

export function buildProse() {
  const html = loadIndicesHtml();

  // ---- elements: MDN preferred, else WHATWG Description ----
  const whatwgElems = parseElementsTable(html);
  const elements = {};
  for (const [tag, desc] of Object.entries(whatwgElems)) elements[tag] = desc;
  for (const [tag, desc] of Object.entries(MDN.elements || {})) elements[tag] = desc; // MDN wins

  // ---- attributes: WHATWG Description, then event handlers, then MDN, then hand ----
  const attributes = {};
  const whatwgAttrs = parseAttributeDescriptions(html);
  for (const [name, desc] of Object.entries(whatwgAttrs)) if (desc) attributes[name] = desc;
  for (const ev of eventAttributes()) if (ev.description) attributes[ev.name] = ev.description;
  for (const a of ariaAttributes()) if (a.description) attributes[a.name] = a.description; // role + aria-*
  for (const [name, desc] of Object.entries(HAND_ATTR)) if (!attributes[name]) attributes[name] = desc;
  // MDN wins for its 24 (richer, task-mandated preference):
  for (const [name, desc] of Object.entries(MDN.attributes || {})) attributes[name] = desc;

  return { _license: WHATWG_LICENSE, elements, attributes };
}

// ---- self-test ---------------------------------------------------------------
if (import.meta.url === `file://${process.argv[1]}`) {
  const prose = buildProse();
  fs.writeFileSync(PROSE_OUT, JSON.stringify(prose, null, 2));
  console.log(`wrote ${PROSE_OUT}`);

  // Coverage against the real surface (out/reports.json + manifest).
  let surfaceAttrs = [];
  let surfaceElems = [];
  try {
    const manifest = require('../out/manifest.json');
    const set = new Set();
    for (const mod of manifest.modules)
      for (const d of mod.declarations)
        for (const a of d.attributes || []) set.add(a.name);
    surfaceAttrs = [...set];
    surfaceElems = manifest.modules
      .flatMap(m => m.declarations)
      .filter(d => d.tagName && d.tagName.startsWith('markup-'))
      .map(d => d.tagName.replace('markup-', ''));
  } catch {
    console.log('(out/manifest.json not found — reporting internal coverage only)');
  }

  const elemKeys = Object.keys(prose.elements);
  const attrKeys = new Set(Object.keys(prose.attributes));
  console.log(`elements in prose.json: ${elemKeys.length}`);

  if (surfaceElems.length) {
    const missingE = surfaceElems.filter(t => !(t in prose.elements));
    console.log(`elements covered: ${surfaceElems.length - missingE.length}/${surfaceElems.length}` +
      (missingE.length ? ` — MISSING: ${missingE.join(', ')}` : ' (all)'));
  }
  console.log(`attributes in prose.json: ${attrKeys.size}`);
  if (surfaceAttrs.length) {
    const missingA = surfaceAttrs.filter(n => !attrKeys.has(n));
    console.log(`attributes covered: ${surfaceAttrs.length - missingA.length}/${surfaceAttrs.length}` +
      (missingA.length ? ` — MISSING: ${missingA.join(', ')}` : ' (all)'));
  }
  // Also confirm ARIA + event names have prose (they extend the surface).
  const ev = eventAttributes().map(e => e.name);
  const evMissing = ev.filter(n => !attrKeys.has(n));
  console.log(`event handlers with prose: ${ev.length - evMissing.length}/${ev.length}`);
  const ar = ariaAttributes().map(a => a.name);
  const arMissing = ar.filter(n => !attrKeys.has(n));
  console.log(`ARIA attrs with prose: ${ar.length - arMissing.length}/${ar.length}` +
    (arMissing.length ? ` — MISSING: ${arMissing.join(', ')}` : ''));
}
