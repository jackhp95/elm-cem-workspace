// build-okf.mjs -- assemble the implementations/m3e-web/ layer: the
// CEM-verified, tech-specific counterpart to the (separately-generated,
// separately-packaged) knowledge/ bundle in brands/m3e/inputs/material-okf.
//
// Its component cards are the SAME cards build-skill.mjs renders (tag-level
// API), re-emitted here under a clearly-labeled implementation root.
// build-skill.mjs stays the source of those cards; this build copies them so
// the OKF layout is complete.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const IMPL = path.join(ROOT, "implementations/m3e-web");
const CARDS = path.join(ROOT, "skills/m3e/components");

function rmrf(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}
rmrf(IMPL);

fs.mkdirSync(path.join(IMPL, "components"), { recursive: true });
const cardFiles = fs.existsSync(CARDS) ? fs.readdirSync(CARDS).filter((f) => f.endsWith(".md")).sort() : [];
for (const f of cardFiles) {
  fs.copyFileSync(path.join(CARDS, f), path.join(IMPL, "components", f));
}

let implIndex = `# @m3e/web -- verified implementation layer\n\n`;
implIndex += `Technology-specific, **CEM-verified** component API for the \`@m3e/web\` custom-element\n`;
implIndex += `library (\`matraic/m3e\`). These cards are tag-level API -- real \`<m3e-*>\` tags,\n`;
implIndex += `attributes, slots, events, and CSS tokens -- generated from the library's build-time\n`;
implIndex += `Custom Elements Manifest. For technology-neutral design guidance (anatomy, usage,\n`;
implIndex += `accessibility), see the [knowledge bundle](/index).\n\n`;
implIndex += `## Components (${cardFiles.length})\n\n`;
implIndex += cardFiles
  .map((f) => `- [${f.replace(/\.md$/, "")}](/implementations/m3e-web/components/${f.replace(/\.md$/, "")})`)
  .join("\n") + "\n";
fs.writeFileSync(path.join(IMPL, "index.md"), implIndex);

console.log(`build-okf: ${cardFiles.length} CEM-verified cards under implementations/m3e-web/`);
