const t = await (await fetch('https://html.spec.whatwg.org/multipage/indices.html')).text();
const anchor = t.indexOf('Boolean attribute');
const tbl = t.slice(t.lastIndexOf('<table', anchor), t.indexOf('</table>', anchor));
const strip = s => s.replace(/<[^>]+>/g,'').replace(/\s+/g,' ').trim();
const rows = tbl.split('<tr>').slice(1);
const parsed = [];
for (const r of rows) {
  const th = r.match(/<th>([\s\S]*?)(?=<td>)/);
  const tds = r.split('<td>').slice(1).map(strip);
  if (!th || tds.length < 3) continue;
  parsed.push({ attr: strip(th[1]), elements: tds[0].split(';').map(s=>s.trim()), value: tds[2] });
}
// classify each value cell
function classify(v){
  const vv = v.replace(/\*+/g,'').trim();
  const quoted = [...vv.matchAll(/"([^"]*)"/g)].map(m=>m[1]);
  if (/^Boolean attribute/i.test(vv)) return 'Bool';
  if (quoted.length >= 1 && /^\s*"/.test(vv)) return 'Enum('+quoted.map(q=>q===''?'empty':q).join('|')+')';
  if (/floating-point number/i.test(vv)) return 'Float';
  if (/non-negative integer|Valid integer|integer greater/i.test(vv)) return 'Int';
  if (/URL/i.test(vv)) return 'Url';
  if (/^ID\b|hash-name reference/i.test(vv)) return 'IdRef';
  if (/tokens/i.test(vv)) return 'Tokens';
  if (/^Text/i.test(vv)) return 'String';
  return 'Other:'+vv.slice(0,40);
}
const byKind = {};
for (const p of parsed){ const k = classify(p.value).replace(/\(.*\)/,'(…)'); byKind[k]=(byKind[k]||0)+1; }
console.log('=== classify yield (WHATWG value col) ===');
for (const [k,c] of Object.entries(byKind).sort((a,b)=>b[1]-a[1])) console.log(String(c).padStart(3),k);
const typed = parsed.filter(p=>!classify(p.value).startsWith('Other')).length;
console.log(`\nTYPED: ${typed}/${parsed.length} = ${(100*typed/parsed.length).toFixed(0)}%  (String-fallback/Other: ${parsed.length-typed})`);
console.log('\n=== "Other" (needs hand-review or richer rule) ===');
for (const p of parsed.filter(p=>classify(p.value).startsWith('Other'))) console.log(' ', p.attr,'=',p.value.slice(0,55));
console.log('\n=== enum samples ===');
for (const p of parsed.filter(p=>classify(p.value).startsWith('Enum')).slice(0,12)) console.log(' ', p.attr,'on',p.elements.join(','),'=>',classify(p.value));
