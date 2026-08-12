import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const bcd = require('@mdn/browser-compat-data');
const { listAll } = await import('@webref/elements');
const all = await listAll();

// webref: html-spec elements only, split obsolete
const webrefHtml = [];
for (const k of Object.keys(all)) if (k==='html') for (const el of all[k].elements) webrefHtml.push(el);
const webrefLive = webrefHtml.filter(e=>!e.obsolete).map(e=>e.name);
const webrefObs = webrefHtml.filter(e=>e.obsolete).map(e=>e.name);

// BCD elements + deprecation
const bels = bcd.html.elements;
const bcdNames = Object.keys(bels).filter(n=>n!=='__compat');
const bcdDep = bcdNames.filter(n=>bels[n].__compat?.status?.deprecated);
const bcdLive = bcdNames.filter(n=>!bels[n].__compat?.status?.deprecated);

console.log('webref html live:', webrefLive.length, '| obsolete:', webrefObs.length);
console.log('BCD html total:', bcdNames.length, '| live:', bcdLive.length, '| deprecated:', bcdDep.length);

const inWebrefNotBcd = webrefLive.filter(n=>!bcdNames.includes(n));
const inBcdNotWebref = bcdLive.filter(n=>!webrefHtml.map(e=>e.name).includes(n));
console.log('\nwebref-live NOT in BCD:', inWebrefNotBcd.join(', ')||'(none)');
console.log('BCD-live NOT in webref:', inBcdNotWebref.join(', ')||'(none)');
console.log('webref obsolete list:', webrefObs.join(', '));

// input type enum recovery from BCD
const inputAttrs = Object.keys(bels.input).filter(k=>k!=='__compat');
const typeKw = inputAttrs.filter(k=>k.startsWith('type_')).map(k=>k.slice(5));
console.log('\ninput[type] keywords from BCD type_*:', typeKw.join(', '));
console.log('count:', typeKw.length);
