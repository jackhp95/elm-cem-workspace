import fs from 'node:fs';
import { build } from './src/build.mjs';
const { manifest, reports, universal } = await build();
fs.mkdirSync('out', { recursive: true });
fs.writeFileSync('out/manifest.json', JSON.stringify(manifest, null, 2));
fs.writeFileSync('out/reports.json', JSON.stringify(reports, null, 2));
fs.writeFileSync('out/universal-attrs.json', JSON.stringify(universal, null, 2));
console.log('=== COVERAGE ===', JSON.stringify(reports.coverage));
console.log('=== TYPING ===', JSON.stringify(reports.typing));
console.log('=== PROSE ===', JSON.stringify(reports.prose));
console.log('typing-gap (String fallbacks):', reports.typingGap.length);
// why-histogram of the gap
const why = {};
for (const g of reports.typingGap) why[g.why] = (why[g.why]||0)+1;
console.log('gap reasons:', JSON.stringify(why, null, 0));
console.log('manifest element declarations:', manifest.modules[0].declarations.length);
console.log('universal attrs -> globals:', universal.globals.length, '| aria:', universal.aria.length, '(events omitted — elm strips on*)');
