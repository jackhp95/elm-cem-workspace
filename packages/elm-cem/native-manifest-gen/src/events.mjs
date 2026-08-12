// events.mjs — the HTML event-handler CONTENT attributes (onclick, oninput, …).
//
// Source: WHATWG "List of event handler content attributes" table on
//   https://html.spec.whatwg.org/multipage/indices.html
// (cached raw at data/whatwg-indices.html; re-fetchable, see fetchIndicesHtml()).
//
// Contract: export `eventAttributes()` -> [{ name, type:{text}, description }].
// All event handlers are typed "string" — they hold an event-handler content
// attribute (script source), which is not an enumerable value set.
//
// Parsing mirrors src/whatwg.mjs: locate the table by its <caption>, split on
// <tr>, take the <th> (attribute name) + the Description column (3rd <td>).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { typeText } from './typing.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const INDICES_HTML = path.resolve(__dirname, '..', 'data', 'whatwg-indices.html');
const INDICES_URL = 'https://html.spec.whatwg.org/multipage/indices.html';

const strip = s => s.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

// Re-fetch + cache the raw indices page (offline-repeatable build).
export async function fetchIndicesHtml() {
  const html = await (await fetch(INDICES_URL)).text();
  fs.writeFileSync(INDICES_HTML, html);
  return html;
}

function loadIndicesHtml() {
  if (fs.existsSync(INDICES_HTML)) return fs.readFileSync(INDICES_HTML, 'utf8');
  throw new Error(`missing ${INDICES_HTML} — run fetchIndicesHtml() first`);
}

// Slice out the <table>…</table> whose <caption> matches `captionText`.
export function sliceTableByCaption(html, captionText) {
  const cap = html.indexOf(`>${captionText}<`);
  if (cap < 0) throw new Error(`caption not found: ${captionText}`);
  const start = html.lastIndexOf('<table', cap);
  const end = html.indexOf('</table>', cap);
  return html.slice(start, end);
}

export function parseEventHandlerTable(html) {
  const tbl = sliceTableByCaption(html, 'List of event handler content attributes');
  const rows = tbl.split('<tr>').slice(1); // drop the header <tr>
  const out = [];
  for (const r of rows) {
    // Attribute name lives in <th … ><code>onfoo</code>.
    const th = r.match(/<th[^>]*>\s*<code>([a-zA-Z]+)<\/code>/);
    if (!th) continue;
    const name = th[1];
    if (!/^on/.test(name)) continue;
    // Columns: <td> Element(s) | <td> Description | <td> Value
    const tds = r.split('<td>').slice(1).map(strip);
    const description = tds[1] || '';
    out.push({ name, description });
  }
  return out;
}

// Public API: typed event-handler content attributes.
export function eventAttributes() {
  const html = loadIndicesHtml();
  const rows = parseEventHandlerTable(html);
  const type = { text: typeText({ kind: 'string' }) }; // "string"
  return rows.map(({ name, description }) => ({
    name,
    type,
    description: description || `${name} event handler content attribute.`,
  }));
}

// ---- self-test ---------------------------------------------------------------
if (import.meta.url === `file://${process.argv[1]}`) {
  const attrs = eventAttributes();
  console.log(`events: ${attrs.length} event-handler content attributes (expect ~70-90)`);
  const distinctTypes = [...new Set(attrs.map(a => a.type.text))];
  console.log('distinct type.text:', JSON.stringify(distinctTypes));
  console.log('samples:');
  for (const a of attrs.slice(0, 4)) console.log(`  ${a.name} :: ${a.type.text} — ${a.description}`);
  const onclick = attrs.find(a => a.name === 'onclick');
  console.log('onclick present:', !!onclick, onclick ? `— ${onclick.description}` : '');
  const noDesc = attrs.filter(a => !a.description).length;
  console.log('missing descriptions:', noDesc);
}
