const t = await (await fetch('https://html.spec.whatwg.org/multipage/indices.html')).text();
// isolate the attributes table (the one right after the attributes-3 anchor / with header Attribute|Element|Description|Value)
const anchor = t.indexOf('Boolean attribute');
const tblStart = t.lastIndexOf('<table', anchor);
const tblEnd = t.indexOf('</table>', anchor);
const tbl = t.slice(tblStart, tblEnd);
const strip = s => s.replace(/<[^>]+>/g,'').replace(/\s+/g,' ').trim();
const rows = tbl.split('<tr>').slice(1); // first is header
const parsed = [];
for (const r of rows) {
  // cells: first is <th>, rest <td>
  const th = r.match(/<th>([\s\S]*?)(?=<td>)/);
  const tds = r.split('<td>').slice(1).map(strip);
  if (!th || tds.length < 3) continue;
  const attr = strip(th[1]);
  parsed.push({ attr, elements: tds[0], description: tds[1], value: tds[2] });
}
console.log('parsed rows:', parsed.length);
// bucket the value column by leading token
const buckets = {};
for (const p of parsed) {
  let key = p.value.replace(/\*+$/,'').trim();
  // normalize: take first ~4 words as the "type kind"
  const short = key.split(';')[0].split(' consisting')[0].slice(0,60);
  buckets[short] = (buckets[short]||0)+1;
}
const sorted = Object.entries(buckets).sort((a,b)=>b[1]-a[1]);
console.log('\n=== VALUE-COLUMN TAXONOMY (distinct kind -> count) ===');
for (const [k,c] of sorted) console.log(String(c).padStart(3), k);
console.log('\ndistinct value-kinds:', sorted.length);
// sample the sample-5 attrs of interest
console.log('\n=== sample rows for a/input/td/img attrs ===');
for (const p of parsed.filter(p=>['href','target','type','scope','loading','decoding','crossorigin','download'].includes(p.attr)).slice(0,20))
  console.log(p.attr, '|', p.elements, '|', 'VALUE=', p.value.slice(0,90));
