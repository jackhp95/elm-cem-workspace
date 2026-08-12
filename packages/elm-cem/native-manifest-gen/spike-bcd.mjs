import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const bcd = require('@mdn/browser-compat-data');
const els = bcd.html.elements;
console.log('=== BCD html.elements ===');
console.log('total elements:', Object.keys(els).length);
for (const name of ['a','input','td','img','div']) {
  const el = els[name];
  if (!el) { console.log('\n---', name, '--- MISSING'); continue; }
  const attrKeys = Object.keys(el).filter(k => k !== '__compat');
  const status = el.__compat?.status || {};
  console.log('\n---', name, '--- status:', JSON.stringify(status), '| attr keys:', attrKeys.length);
  console.log('  attrs:', attrKeys.join(', '));
  for (const ak of attrKeys.slice(0,4)) {
    const st = el[ak].__compat?.status || {};
    console.log('    -', ak, JSON.stringify(st));
  }
}
console.log('\n=== global_attributes ===');
const g = bcd.html.global_attributes;
const gk = g? Object.keys(g).filter(k=>k!=='__compat') : [];
console.log('count:', gk.length);
console.log(gk.slice(0,50).join(', '));
