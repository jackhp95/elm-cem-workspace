#!/usr/bin/env node
// phantom-native.mjs — generate native.cem.json + config.json for the TypedHtml brand.
//
// Emits TWO files into the given --out directory:
//   native.cem.json  — CEM-shaped manifest, one "class" declaration per element ctor
//   config.json      — phantom config: _phantom, _brand, _atoms, _globals, _sets, _aria, per-element entries
//
// Usage:
//   node native-manifest-gen/phantom-native.mjs --out=<dir>
//
// The WHATWG/ARIA data is already cached in data/; no network needed.
// Do NOT modify codegen/** or bin/elm-cem.js — this is a DATA script only.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadWhatwgAttributes } from './src/whatwg.mjs';
import { classifyValue, typeText, INJECTED_ENUMS } from './src/typing.mjs';
import { recover as recoverEnum } from './src/enums.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CONTENT_MODEL = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'data', 'whatwg-content-model.json'), 'utf8')
);

// ─── helpers ───────────────────────────────────────────────────────────────────

const pascal = tag => {
  if (tag === 'pictureSource') return 'PictureSource'; // synthetic
  return tag.split('-').map(s => s[0].toUpperCase() + s.slice(1)).join('');
};

// camelCase: first word lowercase, rest title-case
const camel = name => {
  const parts = name.split('-');
  return parts[0] + parts.slice(1).map(p => p[0].toUpperCase() + p.slice(1)).join('');
};

// ─── TAXONOMY TABLE ──────────────────────────────────────────────────────────
// Per research doc Part 3: each element → module home.
// "own" = has its own module; "grouped" = co-located with category siblings.
// Deprecated elements EXCLUDED from pass 1.
//
// This is the full 113-element assignment (live elements minus obsolete/MathML/SVG).
// Elements in content-model.json marked as "MathML math" and "SVG svg" are foreign namespace — EXCLUDED.
// Elements not in WHATWG HTML (selectedcontent = experimental) — included with note.

const HOME = {
  // ── Html.A ─────────────────────────────────────────────────────────────────
  a: 'A',

  // ── Html.Button ────────────────────────────────────────────────────────────
  button: 'Button',

  // ── Html.Input ─────────────────────────────────────────────────────────────
  input: 'Input',

  // ── Html.Textarea ──────────────────────────────────────────────────────────
  textarea: 'Textarea',

  // ── Html.Img ───────────────────────────────────────────────────────────────
  img: 'Img',

  // ── Html.Select (family: select + option + optgroup + datalist) ────────────
  select: 'Select',
  option: 'Select',
  optgroup: 'Select',
  datalist: 'Select',

  // ── Html.Form (family: form + fieldset + legend + label + output) ──────────
  form: 'Form',
  fieldset: 'Form',
  legend: 'Form',
  label: 'Form',
  output: 'Form',

  // ── Html.Table (family) ────────────────────────────────────────────────────
  table: 'Table',
  caption: 'Table',
  colgroup: 'Table',
  col: 'Table',
  thead: 'Table',
  tbody: 'Table',
  tfoot: 'Table',
  tr: 'Table',
  td: 'Table',
  th: 'Table',

  // ── Html.Media (family: audio + video + picture + source(s) + track) ───────
  audio: 'Media',
  video: 'Media',
  picture: 'Media',
  source: 'Media',          // audio/video context; pictureSource = R2 split below
  track: 'Media',

  // ── Html.Details (family: details + summary) ───────────────────────────────
  details: 'Details',
  summary: 'Details',

  // ── Html.Sectioning (grouped: body + sectioning + heading) ─────────────────
  body: 'Sectioning',
  article: 'Sectioning',
  section: 'Sectioning',
  nav: 'Sectioning',
  aside: 'Sectioning',
  header: 'Sectioning',
  footer: 'Sectioning',
  main: 'Sectioning',
  search: 'Sectioning',
  address: 'Sectioning',
  h1: 'Sectioning',
  h2: 'Sectioning',
  h3: 'Sectioning',
  h4: 'Sectioning',
  h5: 'Sectioning',
  h6: 'Sectioning',
  hgroup: 'Sectioning',

  // ── Html.Grouping (grouped: grouping content) ──────────────────────────────
  div: 'Grouping',
  p: 'Grouping',
  hr: 'Grouping',
  pre: 'Grouping',
  blockquote: 'Grouping',
  ol: 'Grouping',
  ul: 'Grouping',
  menu: 'Grouping',
  li: 'Grouping',
  dl: 'Grouping',
  dt: 'Grouping',
  dd: 'Grouping',
  figure: 'Grouping',
  figcaption: 'Grouping',
  dialog: 'Grouping',

  // ── Html.Text (grouped: phrasing/text-level) ───────────────────────────────
  span: 'Text',
  em: 'Text',
  strong: 'Text',
  small: 'Text',
  s: 'Text',
  cite: 'Text',
  q: 'Text',
  dfn: 'Text',
  abbr: 'Text',
  ruby: 'Text',
  rt: 'Text',
  rp: 'Text',
  data: 'Text',
  time: 'Text',
  code: 'Text',
  var: 'Text',
  samp: 'Text',
  kbd: 'Text',
  sub: 'Text',
  sup: 'Text',
  i: 'Text',
  b: 'Text',
  u: 'Text',
  mark: 'Text',
  bdi: 'Text',
  bdo: 'Text',
  br: 'Text',
  wbr: 'Text',
  ins: 'Text',
  del: 'Text',
  meter: 'Text',
  progress: 'Text',

  // ── Html.Embedded (grouped: embedded content) ───────────────────────────────
  iframe: 'Embedded',
  embed: 'Embedded',
  object: 'Embedded',
  map: 'Embedded',
  area: 'Embedded',
  canvas: 'Embedded',

  // ── Html.Metadata (grouped: metadata content) ──────────────────────────────
  head: 'Metadata',
  title: 'Metadata',
  base: 'Metadata',
  link: 'Metadata',
  meta: 'Metadata',
  style: 'Metadata',

  // ── Html.Scripting (grouped: scripting) ────────────────────────────────────
  script: 'Scripting',
  noscript: 'Scripting',
  template: 'Scripting',
  slot: 'Scripting',

  // ── Special: pictureSource is the R2 split of source ───────────────────────
  // Handled separately in EXTRA_CTORS below; home: 'Media'
};

// ─── INTERACTIVE ELEMENTS (get a "click" event) ──────────────────────────────
const INTERACTIVE = new Set(['a', 'button', 'input', 'select', 'textarea', 'audio', 'video', 'details', 'label']);

// ─── VOID ELEMENTS (no slots) ─────────────────────────────────────────────────
const VOID = new Set(['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'source', 'track', 'wbr']);

// pictureSource is also void (it's <source> in picture context)
const VOID_EXTRA = new Set(['pictureSource', 'selectedcontent']);

// ─── TRANSPARENT ELEMENTS ────────────────────────────────────────────────────
const TRANSPARENT = new Set(['a', 'ins', 'del', 'canvas', 'map', 'slot', 'object']);

// ─── ELEMENTS TO SKIP (deprecated, MathML, SVG, or truly experimental) ───────
const SKIP = new Set([
  'MathML math',
  'SVG svg',
  'autonomous custom elements',
  // Deprecated (WHATWG §16): excluded pass 1
  'acronym', 'big', 'center', 'dir', 'font', 'frame', 'frameset',
  'marquee', 'tt', 'strike', 'xmp', 'nobr', 'listing', 'plaintext',
  // selectedcontent is very experimental (no browser support yet)
  'selectedcontent',
]);

// ─── HEADINGS — treated as 6 separate constructors ───────────────────────────
// Content model has "h1, h2, h3, h4, h5, h6" as one entry; we split them.
const HEADING_ENTRIES = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

// ─── R1/R2 PARENTS MAP ────────────────────────────────────────────────────────
// parents: absent = open (valid anywhere in flow/phrasing).
// present = CLOSED (only valid as direct child of listed elements).
// R1: slot-mates sharing a container must share identical parents sets.
// R2: when parent sets diverge, split into separate ctors (source → source + pictureSource).
//
// Design decisions:
// - option.parents = [select, optgroup]  (widened: datalist would create R1 conflict)
// - optgroup.parents = [select, optgroup] (R1 shared alias with option)
// - li.parents = [ul, ol, menu]
// - dt.parents = [dl]   (div inside dl also can contain dt, but we simplify)
// - dd.parents = [dl]   (same simplification)
// - figcaption.parents = [figure]
// - summary.parents = [details]
// - legend.parents = [fieldset]
// - caption.parents = [table]
// - colgroup.parents = [table]
// - col.parents = [colgroup]
// - thead.parents = [table]
// - tbody.parents = [table]
// - tfoot.parents = [table]
// - tr.parents = [table, thead, tbody, tfoot]
// - td.parents = [tr]
// - th.parents = [tr]
// - source.parents = [audio, video]        (audio/video context)
// - pictureSource.parents = [picture]      (R2 split)
// - track.parents = [audio, video]
// - rp.parents = [ruby]
// - rt.parents = [ruby]
// Note: body, head, html have structural parents but we leave them OPEN to avoid noise.

const PARENTS = {
  option:      ['select', 'optgroup'],
  optgroup:    ['select', 'optgroup'],   // R1 group: same as option (widened)
  li:          ['ul', 'ol', 'menu'],
  dt:          ['dl'],
  dd:          ['dl'],
  figcaption:  ['figure'],
  summary:     ['details'],
  legend:      ['fieldset'],
  // Table family: R1 requires all slot-mates of table.unnamed share the same parents.
  // caption/colgroup/thead/tbody/tfoot can only appear in table.
  // We do NOT put tr directly inside table.admits to avoid R1 conflict.
  // tr goes into thead/tbody/tfoot.admits.
  caption:     ['table'],
  colgroup:    ['table'],
  col:         ['colgroup'],
  thead:       ['table'],
  tbody:       ['table'],
  tfoot:       ['table'],
  // tr: valid in table directly (implied tbody) + explicit row groups.
  // R1 fix: table.admits = [caption, colgroup, thead, tbody, tfoot] (no tr directly).
  // Then tr's parents = [thead, tbody, tfoot, table] — but table is NOT in table.admits for tr.
  // So we keep tr.parents = [thead, tbody, tfoot] (common case; table direct is implicit).
  tr:          ['thead', 'tbody', 'tfoot'],
  td:          ['tr'],
  th:          ['tr'],
  source:      ['audio', 'video'],       // audio/video context only
  track:       ['audio', 'video'],
  rp:          ['ruby'],
  rt:          ['ruby'],
};
// pictureSource (R2 split of <source>) has its own entry below

// ─── ARIA ROLES PER ELEMENT ──────────────────────────────────────────────────
// Only gate elements where it earns its keep (generic containers + interactive/landmark).
// Other elements get role:Supported (open String) automatically.
// Small, defensible legal sets per ARIA-in-HTML spec.
const ARIA_ROLES_PER_ELEMENT = {
  div:     ['banner', 'complementary', 'contentinfo', 'form', 'group', 'list', 'listbox', 'log', 'marquee', 'navigation', 'none', 'note', 'presentation', 'region', 'search', 'separator', 'status', 'switch', 'tab', 'tabpanel', 'timer', 'toolbar', 'tooltip'],
  // Note: 'main' excluded from all role sets (Elm treats top-level `main` as entry point)
  span:    ['generic', 'group', 'listitem', 'none', 'note', 'presentation', 'tooltip'],
  a:       ['button', 'checkbox', 'link', 'menuitem', 'menuitemcheckbox', 'menuitemradio', 'none', 'option', 'presentation', 'radio', 'switch', 'tab', 'treeitem'],
  button:  ['checkbox', 'combobox', 'link', 'menuitem', 'menuitemcheckbox', 'menuitemradio', 'none', 'option', 'presentation', 'radio', 'switch', 'tab'],
  // nav gets landmark roles
  nav:     ['menu', 'menubar', 'navigation', 'none', 'presentation', 'tablist'],
  // section gets region roles (main excluded from vocab)
  section: ['alert', 'alertdialog', 'application', 'banner', 'complementary', 'contentinfo', 'dialog', 'document', 'feed', 'group', 'log', 'marquee', 'navigation', 'none', 'note', 'presentation', 'region', 'search', 'status', 'timer', 'toolbar', 'tooltip'],
};

// Brand-wide ARIA config (_aria in config.json)
// roles = the full token vocabulary we expose (superset of all per-element sets + checked tokens)
const ARIA_VOCAB_ROLES = [
  // Excludes 'main': Elm treats top-level `main` as the program entry point → BAD MAIN TYPE.
  // The WAI-ARIA `main` landmark role is still expressible via roleString "main".
  'alert', 'alertdialog', 'application', 'banner', 'button', 'cell', 'checkbox',
  'columnheader', 'combobox', 'complementary', 'contentinfo', 'definition', 'dialog',
  'directory', 'document', 'feed', 'figure', 'form', 'generic', 'grid', 'gridcell',
  'group', 'heading', 'img', 'link', 'list', 'listbox', 'listitem', 'log',
  'marquee', 'math', 'menu', 'menubar', 'menuitem', 'menuitemcheckbox', 'menuitemradio',
  'meter', 'navigation', 'none', 'note', 'option', 'presentation', 'progressbar',
  'radio', 'radiogroup', 'region', 'row', 'rowgroup', 'rowheader', 'scrollbar',
  'search', 'searchbox', 'separator', 'slider', 'spinbutton', 'status', 'switch',
  'tab', 'table', 'tablist', 'tabpanel', 'term', 'textbox', 'timer', 'toolbar',
  'tooltip', 'tree', 'treegrid', 'treeitem',
];

// ─── WHATWG ATTRIBUTE INDEX ───────────────────────────────────────────────────
let _attrIndex = null;
async function getAttrIndex() {
  if (_attrIndex) return _attrIndex;
  const { rows } = await loadWhatwgAttributes();
  const byAttr = new Map();
  for (const r of rows) {
    if (!byAttr.has(r.attr)) byAttr.set(r.attr, []);
    byAttr.get(r.attr).push(r);
  }
  _attrIndex = {
    lookup(attr, element) {
      const cands = byAttr.get(attr);
      if (!cands) return null;
      const scoped = cands.find(c => c.elements.includes(element));
      const chosen = scoped || cands[0];
      return { value: chosen.value, description: chosen.description, scoped: !!scoped };
    },
    allAttrsForElement(tag) {
      // Returns all attr names that list this element (or 'HTML elements')
      const attrs = [];
      for (const [attr, cands] of byAttr.entries()) {
        const match = cands.find(c => c.elements.includes(tag) || c.elements.includes('HTML elements'));
        if (match) attrs.push({ attr, value: match.value, description: match.description });
      }
      return attrs;
    },
  };
  return _attrIndex;
}

// ─── ELEMENT-SPECIFIC ATTRS (from WHATWG attrs index) ────────────────────────
// Build: tag → [{ name, type:{text}, description }]
// Skips globals (class, id, style, slot, title, lang, dir, etc.) — those go on the universal rail.
// Keeps element-specific AND shared (disabled, href, src, etc.).
// For the CEM manifest we ONLY include genuinely element-specific attrs — not globals.

// Elm reserved keywords (from Naming.elm:elmKeywords + "main") that cannot be Elm function names.
// Attrs whose camelCase name hits these must be excluded from the CEM (generator emits them verbatim).
const ELM_KEYWORDS = new Set([
  'type', 'module', 'where', 'import', 'as', 'exposing', 'port', 'let', 'in',
  'if', 'then', 'else', 'case', 'of', 'infix', 'alias', 'effect', 'command',
  'subscription', 'main',
]);

// The camelCase version of an attr name (to match what the generator will emit)
function attrCamel(name) {
  return name.split('-').map((s, i) => i === 0 ? s : s[0].toUpperCase() + s.slice(1)).join('');
}

// These are the attrs that appear on "HTML elements" — pure globals, excluded from per-element.
const GLOBAL_ATTR_NAMES = new Set([
  'accesskey', 'autocapitalize', 'autocorrect', 'autofocus', 'class', 'contenteditable',
  'dir', 'draggable', 'enterkeyhint', 'headingoffset', 'headingreset', 'hidden', 'id',
  'inert', 'inputmode', 'is', 'itemid', 'itemprop', 'itemref', 'itemscope', 'itemtype',
  'lang', 'nonce', 'popover', 'slot', 'spellcheck', 'style', 'tabindex', 'title',
  'translate', 'writingsuggestions',
]);

// Attrs shared across multiple elements but NOT globals — canonical in Attributes module.
// These still appear per-element in the CEM manifest's attribute list (for typing),
// but in config they become shared canonical setters.
const SHARED_ATTRS = new Set([
  'disabled', 'href', 'src', 'srcset', 'value', 'name', 'type',
  'alt', 'width', 'height', 'crossorigin', 'media', 'sizes', 'rel',
  'target', 'download', 'ping', 'hreflang', 'referrerpolicy',
  'colspan', 'rowspan', 'headers', 'scope', 'abbr',
  'for', 'form', 'action', 'method', 'enctype', 'novalidate', 'accept',
  'autocomplete', 'checked', 'selected', 'multiple', 'required', 'readonly',
  'placeholder', 'maxlength', 'minlength', 'pattern', 'rows', 'cols', 'wrap',
  'min', 'max', 'step', 'size', 'list', 'dirname',
  'autoplay', 'controls', 'loop', 'muted', 'preload',
  'sandbox', 'srcdoc', 'allow', 'allowfullscreen', 'loading',
  'start', 'reversed', 'open', 'cite',
  'datetime', 'decoding', 'ismap', 'usemap', 'fetchpriority',
  'label', 'kind', 'srclang', 'default',
  'span', 'colspan',
  'data', 'formaction', 'formenctype', 'formmethod', 'formnovalidate', 'formtarget',
  'popovertarget', 'popovertargetaction', 'command', 'commandfor',
  'high', 'low', 'optimum', 'content', 'charset', 'async', 'defer',
  'integrity', 'nomodule', 'blocking', 'imagesizes', 'imagesrcset',
  'shadowrootmode', 'shadowrootclonable', 'shadowrootdelegatesfocus',
  'shadowrootserializable', 'shadowrootcustomelementregistry', 'shadowrootslotassignment',
  'closedby',
  'http-equiv', 'as',
  'colorspace', 'alpha', 'accept-charset', 'coords', 'shape',
  'poster', 'playsinline',
  'scope', 'reversed',
  'ping', 'color',
]);

// Attrs with conflicting types across elements — force a uniform type to avoid
// duplicate shared-setter generation in the Phantom emitter.
const FORCE_STRING_ATTRS = new Set([
  'autocomplete',  // 'on'|'off' on form vs Autofill string on input/select/textarea
  'min', 'max',    // varies (number vs date string)
  'value',         // varies (text, number, etc.)
  'list',          // ID ref
]);

function classifyAttr(attrName, tag, value) {
  if (FORCE_STRING_ATTRS.has(attrName)) return 'string';
  const recovered = recoverEnum(attrName, value || '', tag);
  if (recovered) return typeText(recovered);
  if (value) {
    const cls = classifyValue(value, { attr: attrName, element: tag });
    return typeText(cls);
  }
  const inj = INJECTED_ENUMS[`${attrName}@${tag}`];
  if (inj) return typeText({ kind: 'enum', keywords: inj });
  return 'string';
}

// Build attrs for a given tag using the WHATWG index
// Returns [{name, type:{text}, description}] — only element-specific (non-global) attrs
async function elementAttrs(tag) {
  const idx = await getAttrIndex();
  const { rows } = await loadWhatwgAttributes();

  const out = [];
  const seen = new Set();

  for (const row of rows) {
    const { attr, elements, value, description } = row;
    if (GLOBAL_ATTR_NAMES.has(attr)) continue;
    const appliesToThis = elements.some(e =>
      e === tag ||
      e === `source (in video or audio)` && tag === 'source' ||
      e === `source (in picture)` && tag === 'pictureSource' ||
      e === 'form-associated custom elements' && ['button','fieldset','input','output','select','textarea'].includes(tag)
    );
    if (!appliesToThis) continue;
    if (seen.has(attr)) continue;
    seen.add(attr);
    const typeStr = classifyAttr(attr, tag, value);
    out.push({ name: attr, type: { text: typeStr }, description: description || `The ${attr} attribute.` });
  }

  // Sort alphabetically
  out.sort((a, b) => a.name.localeCompare(b.name));
  return out;
}

// ─── CONTENT MODEL → admits.unnamed.kinds ────────────────────────────────────
// Map element content models to the kinds list for config.json.
// "flow" → "@flow", "phrasing" → "@phrasing", specific elements → ctor names.
// "any" ONLY for div/section-like generic containers.
// "empty" → slot: [] (void)
// "transparent" → transparent: true in config

// Elements that get "any" as their content (truly permissive structural containers)
const ANY_CONTAINERS = new Set(['div', 'article', 'section', 'aside', 'nav', 'header', 'footer',
  'main', 'search', 'address', 'dialog', 'form', 'fieldset', 'blockquote', 'figure',
  'body', 'hgroup', 'details',
]);

// Map from content-model key to config admits kinds
function contentModelKinds(tag) {
  const cm = CONTENT_MODEL[tag] || CONTENT_MODEL['h1, h2, h3, h4, h5, h6'];
  if (!cm) return { kinds: ['@flow'], multi: true };

  const raw = cm.childrenRaw || '';

  if (raw === 'empty') return null; // void

  // Transparent → will be handled by transparent:true in config
  if (raw.startsWith('transparent') && !cm.elementChildren.length) {
    return 'transparent';
  }

  if (ANY_CONTAINERS.has(tag)) {
    return { kinds: ['any'], multi: true };
  }

  // Build from elementChildren + categoryChildren
  const kinds = [];
  const multi = true;

  // Category children
  for (const c of (cm.categoryChildren || [])) {
    if (c.name === 'flow') kinds.push('@flow');
    else if (c.name === 'phrasing') kinds.push('@phrasing');
    else if (c.name === 'metadata content') kinds.push('@metadata');
    else if (c.name === 'transparent') {
      // transparent mixed: handled specially
    }
    // Others (script-supporting, script data, etc.) ignored for now
  }

  // Element children
  for (const c of (cm.elementChildren || [])) {
    if (c.name === 'col') kinds.push('col');
    else if (c.name === 'template') { /* skip */ }
    else kinds.push(c.name);
  }

  // Special cases
  if (tag === 'audio' || tag === 'video') {
    return { kinds: ['source', 'track', 'shared:text'], multi: true };
  }
  if (tag === 'picture') {
    return { kinds: ['pictureSource', 'img'], multi: true };
  }
  if (tag === 'select') {
    return { kinds: ['option', 'optgroup'], multi: true };
  }
  if (tag === 'optgroup') {
    // Simplified: only option (WHATWG also allows div/noscript/legend but these create R1 conflicts)
    return { kinds: ['option'], multi: true };
  }
  if (tag === 'dl') {
    return { kinds: ['dt', 'dd', 'div'], multi: true };
  }
  if (tag === 'table') {
    // Do NOT include tr directly (R1: caption/colgroup/thead/tbody/tfoot all have parents:[table],
    // but if tr were here it would have parents:[thead,tbody,tfoot] — R1 conflict).
    return { kinds: ['caption', 'colgroup', 'thead', 'tbody', 'tfoot'], multi: true };
  }
  if (tag === 'thead' || tag === 'tbody' || tag === 'tfoot') {
    return { kinds: ['tr'], multi: true };
  }
  if (tag === 'tr') {
    return { kinds: ['td', 'th'], multi: true };
  }
  if (tag === 'colgroup') {
    return { kinds: ['col'], multi: true };
  }
  if (tag === 'ruby') {
    return { kinds: ['@phrasing', 'rt', 'rp'], multi: true };
  }
  if (tag === 'datalist') {
    return { kinds: ['option', 'shared:text'], multi: true };
  }
  if (tag === 'figure') {
    return { kinds: ['figcaption', '@flow'], multi: true };
  }
  if (tag === 'ol' || tag === 'ul' || tag === 'menu') {
    return { kinds: ['li'], multi: true };
  }
  if (tag === 'head') {
    return { kinds: ['@metadata'], multi: true };
  }
  if (tag === 'legend' || tag === 'summary') {
    return { kinds: ['@phrasing'], multi: true };
  }
  if (tag === 'html') {
    return { kinds: ['head', 'body'], multi: true };
  }

  // Script-related: text content only
  if (tag === 'script' || tag === 'style' || tag === 'title' || tag === 'textarea') {
    return { kinds: ['shared:text'], multi: true };
  }

  // Noscript content varies; treat as flow
  if (tag === 'noscript') {
    return { kinds: ['@flow'], multi: true };
  }

  // Template: any content (used as inert fragment)
  if (tag === 'template') {
    return { kinds: ['any'], multi: true };
  }

  // Headings: phrasing content → use 'any' to avoid the @phrasing import bug
  // (generator uses Phrasing alias for large sets but doesn't import it)
  if (HEADING_ENTRIES.includes(tag)) {
    return { kinds: ['any'], multi: true };
  }

  if (kinds.length === 0) {
    // fallback for phrasing-only content: use 'any' to avoid large-set import bug
    if (raw.includes('phrasing')) return { kinds: ['any'], multi: true };
    if (raw.includes('flow')) return { kinds: ['@flow'], multi: true };
    return { kinds: ['shared:text'], multi: true };
  }

  // If the only category child is 'phrasing', upgrade to 'any' to avoid import bug
  if (kinds.length > 0 && kinds.every(k => k === '@phrasing')) {
    return { kinds: ['any'], multi: true };
  }

  return { kinds, multi };
}

// ─── ELEMENT DESCRIPTION ─────────────────────────────────────────────────────
const ELEM_DESCRIPTIONS = {
  a: 'Anchor link. Transparent content model.',
  abbr: 'Abbreviation or acronym.',
  address: 'Contact information for the nearest article or body.',
  area: 'Image map area. Void element.',
  article: 'Self-contained content composition.',
  aside: 'Content tangentially related to surrounding content.',
  audio: 'Audio playback.',
  b: 'Bold text with no extra importance.',
  base: 'Base URL and/or default target. Void element.',
  bdi: 'Text isolated from surrounding bidirectional formatting.',
  bdo: 'Override text directionality.',
  blockquote: 'Extended quotation.',
  body: 'Document body.',
  br: 'Line break. Void element.',
  button: 'Interactive button control.',
  canvas: 'Scriptable bitmap canvas.',
  caption: 'Table caption. Only valid under table.',
  cite: 'Reference to a cited work.',
  code: 'Fragment of computer code.',
  col: 'Column in a colgroup. Void element.',
  colgroup: 'Group of columns. Only valid under table.',
  data: 'Machine-readable value with human-readable label.',
  datalist: 'Pre-defined options for input controls.',
  dd: 'Description in a description list.',
  del: 'Deleted text. Transparent content model.',
  details: 'Disclosure widget.',
  dfn: 'Term being defined.',
  dialog: 'Dialog box or other interactive component.',
  div: 'Generic flow container.',
  dl: 'Description list.',
  dt: 'Term in a description list.',
  em: 'Emphasis.',
  embed: 'External application or interactive content. Void element.',
  fieldset: 'Form field grouping.',
  figcaption: 'Caption for a figure.',
  figure: 'Self-contained content with optional caption.',
  footer: 'Footer for its nearest sectioning content.',
  form: 'Form for user input.',
  h1: 'Heading level 1.',
  h2: 'Heading level 2.',
  h3: 'Heading level 3.',
  h4: 'Heading level 4.',
  h5: 'Heading level 5.',
  h6: 'Heading level 6.',
  head: 'Document metadata container.',
  header: 'Introductory content for its nearest sectioning content.',
  hgroup: 'Heading with optional subtitle.',
  hr: 'Thematic break (paragraph-level). Void element.',
  html: 'Root element.',
  i: 'Alternate voice or mood (italics).',
  iframe: 'Nested browsing context.',
  img: 'Image. Void element.',
  input: 'Interactive form control. Void element.',
  ins: 'Inserted text. Transparent content model.',
  kbd: 'User keyboard input.',
  label: 'Label for a form control.',
  legend: 'Caption for a fieldset.',
  li: 'List item.',
  link: 'Relationship between document and external resource. Void element.',
  main: 'Primary content of the document.',
  map: 'Image map.',
  mark: 'Highlighted/marked text.',
  menu: 'Unordered list of commands.',
  meta: 'Machine-readable metadata. Void element.',
  meter: 'Scalar measurement within a known range.',
  nav: 'Navigation links.',
  noscript: 'Fallback for no-script environments.',
  object: 'Embedded object.',
  ol: 'Ordered list.',
  optgroup: 'Group of options in a select.',
  option: 'Option in a select or datalist.',
  output: 'Result of a calculation.',
  p: 'Paragraph.',
  picture: 'Responsive image container.',
  pre: 'Preformatted text.',
  progress: 'Task progress indicator.',
  q: 'Inline quotation.',
  rp: 'Parentheses for ruby fallback.',
  rt: 'Ruby annotation.',
  ruby: 'Ruby annotation base.',
  s: 'Strikethrough text.',
  samp: 'Sample computer output.',
  script: 'Embedded script.',
  search: 'Search-related content.',
  section: 'Generic section of a document.',
  select: 'Option list control.',
  slot: 'Web component slot placeholder.',
  small: 'Side comments (small print).',
  source: 'Media source (audio/video context). Void element.',
  span: 'Generic phrasing container.',
  strong: 'Strong importance, seriousness, or urgency.',
  style: 'Embedded CSS styles.',
  sub: 'Subscript text.',
  summary: 'Visible heading for a details element.',
  sup: 'Superscript text.',
  table: 'Table.',
  tbody: 'Body rows of a table.',
  td: 'Data cell in a table. Only valid under tr.',
  template: 'Inert content template.',
  textarea: 'Multiline text input.',
  tfoot: 'Footer rows of a table.',
  th: 'Header cell in a table. Only valid under tr.',
  thead: 'Header rows of a table.',
  time: 'Machine-readable date or time.',
  title: 'Document title.',
  tr: 'Table row.',
  track: 'Timed text track. Void element.',
  u: 'Unarticulated annotation (underline).',
  ul: 'Unordered list.',
  var: 'Variable in math or programming.',
  video: 'Video playback.',
  wbr: 'Line-break opportunity. Void element.',
  pictureSource: 'Media source (picture context) — R2 split of <source>. Void element.',
};

// ─── EXTRA CONSTRUCTORS (R2 splits + synthetic) ──────────────────────────────
// pictureSource = R2 split of <source> for the picture context
const EXTRA_CTORS = [
  {
    name: 'PictureSource',
    tagName: 'source',
    description: ELEM_DESCRIPTIONS.pictureSource,
    home: 'Media',
    parents: ['picture'],
    transparent: false,
    isVoid: true,
    attrs: [
      { name: 'height', type: { text: 'number' }, description: 'Height of the source.' },
      { name: 'media', type: { text: 'string' }, description: 'Media condition for this source.' },
      { name: 'sizes', type: { text: 'string' }, description: 'Sizes attribute for responsive images.' },
      { name: 'srcset', type: { text: 'string' }, description: 'Image candidates.' },
      // 'type' excluded: Elm keyword
      { name: 'width', type: { text: 'number' }, description: 'Width of the source.' },
    ],
  },
];

// ─── SETS (WHATWG content categories) ────────────────────────────────────────
// Membership in camelCase ctor names (lowercase = same as tag for single-word tags).
// These become the @flow / @phrasing etc. references in admits.unnamed.kinds.
function buildSets() {
  const flow = [];
  const phrasing = [];
  const interactive = [];
  const heading = [];
  const sectioning = [];
  const metadata = [];
  const embedded = [];

  for (const [key, cm] of Object.entries(CONTENT_MODEL)) {
    if (SKIP.has(key) || key === 'h1, h2, h3, h4, h5, h6') continue;
    const cats = (cm.categories || '').split(';').map(s => s.trim().replace(/\*/g, ''));
    const tag = key;
    if (!HOME[tag]) continue;

    if (cats.includes('flow')) flow.push(tag);
    if (cats.includes('phrasing')) phrasing.push(tag);
    if (cats.includes('interactive')) interactive.push(tag);
    if (cats.includes('heading')) heading.push(tag);
    if (cats.includes('sectioning')) sectioning.push(tag);
    if (cats.includes('metadata')) metadata.push(tag);
    if (cats.includes('embedded')) embedded.push(tag);
  }

  // Add headings individually
  for (const h of HEADING_ENTRIES) {
    if (!flow.includes(h)) flow.push(h);
    if (!heading.includes(h)) heading.push(h);
  }

  const toCtors = tags => tags.sort().map(t => t); // use tag names directly as ctor names

  return {
    flow: toCtors(flow),
    phrasing: toCtors(phrasing),
    interactive: toCtors(interactive),
    heading: toCtors(heading),
    sectioning: toCtors(sectioning),
    metadata: toCtors(metadata),
    embedded: toCtors(embedded),
  };
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────

async function main() {
  const outArg = process.argv.find(a => a.startsWith('--out='));
  const outDir = outArg ? outArg.slice(6) : path.join(__dirname, 'out', 'phantom-native');
  fs.mkdirSync(outDir, { recursive: true });

  const { rows: attrRows } = await loadWhatwgAttributes();

  // ── Build per-element attrs map ──────────────────────────────────────────
  // For each element in our taxonomy, collect its element-specific attrs.
  // We use the cached WHATWG attrs index.
  const idx = await getAttrIndex();

  const elementAttrMap = new Map();
  const allTags = [...new Set([...Object.keys(HOME), ...EXTRA_CTORS.map(e => e.name)])];

  for (const tag of Object.keys(HOME)) {
    const tagAttrs = [];
    const seen = new Set();

    for (const row of attrRows) {
      if (GLOBAL_ATTR_NAMES.has(row.attr)) continue;
      // Skip attrs whose camelCase name is an Elm keyword (generator can't handle them)
      if (ELM_KEYWORDS.has(attrCamel(row.attr))) continue;
      const applies = row.elements.some(e => {
        if (e === tag) return true;
        if (e === 'source (in video or audio)' && tag === 'source') return true;
        if (e === 'form-associated custom elements' && ['button','fieldset','input','output','select','textarea'].includes(tag)) return true;
        // h1-h6 don't have specific attrs
        return false;
      });
      if (!applies) continue;
      if (seen.has(row.attr)) continue;
      seen.add(row.attr);
      const typeStr = classifyAttr(row.attr, tag, row.value);
      tagAttrs.push({
        name: row.attr,
        type: { text: typeStr },
        description: row.description || `The ${row.attr} attribute.`,
      });
    }
    tagAttrs.sort((a, b) => a.name.localeCompare(b.name));
    elementAttrMap.set(tag, tagAttrs);
  }

  // ── Collect all elements to emit ─────────────────────────────────────────
  // Tags from HOME (minus 'h1,h2,...' aggregate entry) + heading entries + EXTRA_CTORS
  const allElements = [];

  for (const [key, cm] of Object.entries(CONTENT_MODEL)) {
    if (SKIP.has(key)) continue;
    if (key === 'h1, h2, h3, h4, h5, h6') continue;
    if (!HOME[key]) continue;
    allElements.push(key);
  }

  // Add headings
  for (const h of HEADING_ENTRIES) allElements.push(h);

  // Sort for determinism
  allElements.sort();

  // ── Build CEM declarations ────────────────────────────────────────────────
  const declarations = [];

  for (const tag of allElements) {
    const ctorName = pascal(tag);
    const isVoid = VOID.has(tag);
    const isInteractive = INTERACTIVE.has(tag);
    const attrs = elementAttrMap.get(tag) || [];

    declarations.push({
      kind: 'class',
      name: ctorName,
      tagName: tag,
      customElement: true,
      description: ELEM_DESCRIPTIONS[tag] || `The <${tag}> HTML element.`,
      members: [],
      events: isInteractive ? [{ name: 'click', description: 'User activated the element.' }] : [],
      cssProperties: [],
      cssParts: [],
      cssStates: [],
      slots: isVoid ? [] : [{ name: 'unnamed' }],
      attributes: attrs,
    });
  }

  // Add EXTRA_CTORS (pictureSource)
  for (const extra of EXTRA_CTORS) {
    declarations.push({
      kind: 'class',
      name: extra.name,
      tagName: extra.tagName,
      customElement: true,
      description: extra.description,
      members: [],
      events: [],
      cssProperties: [],
      cssParts: [],
      cssStates: [],
      slots: extra.isVoid ? [] : [{ name: 'unnamed' }],
      attributes: extra.attrs,
    });
  }

  // ── Write native.cem.json ─────────────────────────────────────────────────
  const cem = {
    schemaVersion: '1.0.0',
    package: { name: 'jackhp95/elm-typed-html', version: '1.0.0' },
    modules: [
      {
        kind: 'javascript-module',
        path: 'native.js',
        declarations,
      },
    ],
  };

  const cemPath = path.join(outDir, 'native.cem.json');
  fs.writeFileSync(cemPath, JSON.stringify(cem, null, 2));
  console.log(`Wrote ${cemPath} (${declarations.length} declarations)`);

  // ── Build _sets ───────────────────────────────────────────────────────────
  const sets = buildSets();

  // ── Build per-element config entries ──────────────────────────────────────
  const configEntries = {};

  for (const tag of allElements) {
    const ctorName = pascal(tag);
    const isVoid = VOID.has(tag);
    const entry = {};

    // home
    const home = HOME[tag];
    if (home) entry.home = home;

    // parents (closed admittedBy)
    const parents = PARENTS[tag];
    if (parents) entry.parents = parents;

    // transparent
    if (TRANSPARENT.has(tag)) {
      entry.transparent = true;
    }

    // roles (ARIA gate for high-value elements)
    const roles = ARIA_ROLES_PER_ELEMENT[tag];
    if (roles) entry.roles = roles;

    // admits (content model)
    if (!isVoid) {
      const cm = contentModelKinds(tag);
      if (cm === 'transparent') {
        entry.transparent = true;
        // transparent elements don't need explicit admits — generator handles it
      } else if (cm) {
        entry.admits = { unnamed: { ...cm } };
      }
    }
    // void elements: no admits, no slots

    configEntries[ctorName] = entry;
  }

  // Add EXTRA_CTORS config entries
  for (const extra of EXTRA_CTORS) {
    const entry = {
      home: extra.home,
      parents: extra.parents,
    };
    if (extra.transparent) entry.transparent = true;
    configEntries[extra.name] = entry;
  }

  // ── Build config.json ─────────────────────────────────────────────────────
  const config = {
    _phantom: true,
    _brand: 'TypedHtml',
    _atoms: { text: {} },
    _sets: sets,
    _aria: {
      roles: ARIA_VOCAB_ROLES,
      states: {
        // Value-typed ARIA states. Chosen to avoid name clashes with role tokens.
        // - haspopup EXCLUDED: its values (menu/listbox/tree/grid/dialog) clash with role tokens.
        // - autocomplete.none + invalid values overlap with role token `none` — excluded.
        // - sort.none also clashes with `none` role.
        checked: ['true', 'false', 'mixed'],
        pressed: ['true', 'false', 'mixed'],
        current: ['page', 'step', 'location', 'date', 'time'],
        expanded: ['true', 'false'],
        live: ['assertive', 'off', 'polite'],
        relevant: ['additions', 'all', 'removals', 'text'],
      },
      universal: ['label', 'labelledby', 'describedby', 'description'],
    },
    ...configEntries,
  };

  const configPath = path.join(outDir, 'config.json');
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`Wrote ${configPath} (${Object.keys(configEntries).length} element entries)`);

  // Summary
  const homes = {};
  for (const [ctor, entry] of Object.entries(configEntries)) {
    const h = entry.home || 'unknown';
    homes[h] = (homes[h] || 0) + 1;
  }
  console.log('\nElement counts by home module:');
  for (const [home, count] of Object.entries(homes).sort()) {
    console.log(`  ${home}: ${count}`);
  }
  console.log(`\nTotal declarations: ${declarations.length} (${allElements.length} standard + ${EXTRA_CTORS.length} R2-split)`);
}

main().catch(err => { console.error(err); process.exit(1); });
