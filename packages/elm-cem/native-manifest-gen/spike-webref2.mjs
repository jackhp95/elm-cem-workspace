import { listAll } from '@webref/elements';
const all = await listAll();
let withAttrs = 0, total = 0;
const sample = [];
for (const specKey of Object.keys(all)) {
  for (const el of (all[specKey].elements || [])) {
    total++;
    if (el.attributes && el.attributes.length) { withAttrs++; if (sample.length<3) sample.push({spec:specKey, name:el.name, attributes:el.attributes}); }
  }
}
console.log('elements with attributes field:', withAttrs, '/', total);
console.log('sample:', JSON.stringify(sample, null, 2).slice(0,1500));
// keys present on element entries
const keyset = new Set();
for (const specKey of Object.keys(all)) for (const el of (all[specKey].elements||[])) Object.keys(el).forEach(k=>keyset.add(k));
console.log('element entry keys seen:', [...keyset]);
