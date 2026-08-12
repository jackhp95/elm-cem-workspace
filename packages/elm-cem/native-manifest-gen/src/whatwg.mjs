// Fetch + parse the WHATWG "attributes" index table (Attribute | Element(s) | Description | Value).
// Caches to data/whatwg-attributes.json so the build is offline-repeatable and reviewable.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CACHE = path.resolve(__dirname, '..', 'data', 'whatwg-attributes.json');
const URL = 'https://html.spec.whatwg.org/multipage/indices.html';

const strip = s => s.replace(/<[^>]+>/g, '').replace(/\s+/g, ' ').trim();

export function parseAttributesTable(html) {
  const anchor = html.indexOf('Boolean attribute');
  const tbl = html.slice(html.lastIndexOf('<table', anchor), html.indexOf('</table>', anchor));
  const rows = tbl.split('<tr>').slice(1); // drop header row
  const out = [];
  for (const r of rows) {
    const th = r.match(/<th>([\s\S]*?)(?=<td>)/);
    const tds = r.split('<td>').slice(1).map(strip);
    if (!th || tds.length < 3) continue;
    const attr = strip(th[1]);
    if (!attr) continue;
    out.push({
      attr,
      elements: tds[0].split(';').map(s => s.trim()).filter(Boolean),
      description: tds[1],
      value: tds[2],
    });
  }
  return out;
}

export async function loadWhatwgAttributes({ refresh = false } = {}) {
  if (!refresh && fs.existsSync(CACHE)) {
    return JSON.parse(fs.readFileSync(CACHE, 'utf8'));
  }
  const html = await (await fetch(URL)).text();
  const rows = parseAttributesTable(html);
  const payload = { source: URL, fetchedFrom: 'multipage/indices.html', rowCount: rows.length, rows };
  fs.writeFileSync(CACHE, JSON.stringify(payload, null, 2));
  return payload;
}
