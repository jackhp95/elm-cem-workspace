import { listAll } from '@webref/elements';

const all = await listAll();
// all: { [spec]: { spec, elements: [{name, interface, attributes?}, ...] } }
const wanted = new Set(['a','input','td','img','div']);
const found = {};
for (const specKey of Object.keys(all)) {
  const spec = all[specKey];
  for (const el of (spec.elements || [])) {
    if (wanted.has(el.name)) {
      found[el.name] = found[el.name] || [];
      found[el.name].push({ spec: specKey, ...el });
    }
  }
}
console.log('=== @webref/elements ===');
console.log('total specs:', Object.keys(all).length);
let totalElements = 0;
for (const specKey of Object.keys(all)) totalElements += (all[specKey].elements||[]).length;
console.log('total element entries:', totalElements);
for (const name of ['a','input','td','img','div']) {
  console.log('\n---', name, '---');
  console.log(JSON.stringify(found[name], null, 2));
}
