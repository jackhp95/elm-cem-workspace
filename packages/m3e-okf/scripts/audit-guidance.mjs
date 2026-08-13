// audit-guidance.mjs — audit the rendered skill's two-source discipline.
//
// Reports (a) how much of the m3.material.io foundations/styles topic tree the
// concept pages cover, and (b) per-page citation counts (m3.material.io / upstream
// / other) with a guidance-claim-density heuristic to spot uncited guidance. The
// M3 topic tree is embedded (M3_TOPICS) and refreshable with --fetch, which diffs
// it against the live sitemap. --max-uncited <n> turns the density heuristic into
// a CI ratchet (exit 1 if the uncited-guidance page count exceeds n).
//
//   node scripts/audit-guidance.mjs                 # print the report
//   node scripts/audit-guidance.mjs --fetch         # + live sitemap drift section
//   node scripts/audit-guidance.mjs --max-uncited N # + exit 1 if over the ratchet

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import {
  classifyLinks,
  countGuidanceClaims,
  hasLibraryTag,
  parseSitemapTopics,
  coverageGaps,
} from "./lib/audit-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SKILL = path.join(ROOT, "skills/m3e");

// The M3 foundations/styles topics that carry per-component consequences for an
// agent building UI. Value = canonical m3.material.io page (used by --fetch and
// as the citation an authored concept page should point at). Refresh with --fetch.
// Keys are live foundations/styles second-level segments (verified against the
// sitemap 2026-07 via --fetch). NOTE: M3 retired `foundations/accessibility`; its
// accessibility guidance now lives under `foundations/designing` (+ usability +
// overview/assistive-technology). The accessibility concept page maps here.
export const M3_TOPICS = {
  "foundations/designing": "https://m3.material.io/foundations/designing/overview",
  "foundations/layout": "https://m3.material.io/foundations/layout/layout-overview/overview",
  "foundations/interaction": "https://m3.material.io/foundations/interaction/states/overview",
  "foundations/design-tokens": "https://m3.material.io/foundations/design-tokens/overview",
  "foundations/content-design": "https://m3.material.io/foundations/content-design/overview",
  "foundations/customization": "https://m3.material.io/foundations/customization",
  "styles/color": "https://m3.material.io/styles/color/system/overview",
  "styles/typography": "https://m3.material.io/styles/typography/overview",
  "styles/motion": "https://m3.material.io/styles/motion/overview/how-it-works",
  "styles/elevation": "https://m3.material.io/styles/elevation/overview",
  "styles/shape": "https://m3.material.io/styles/shape/overview-principles",
  "styles/icons": "https://m3.material.io/styles/icons/overview",
};

// Which embedded topic each concept page covers. A concept slug absent here maps
// to no M3 topic (it's a library/framework page: density, forms, frameworks-*,
// getting-started, installation, choosing-components). C4 extends this as the 8
// authored concept pages land.
export const CONCEPT_CLAIMS = {
  color: ["styles/color"],
  typography: ["styles/typography"],
  motion: ["styles/motion"],
  // C4 authored concepts. accessibility maps to `foundations/designing` — where M3
  // relocated its accessibility guidance (color-contrast/structure/flow).
  accessibility: ["foundations/designing"],
  layout: ["foundations/layout"],
  "interaction-states": ["foundations/interaction"],
  "design-tokens": ["foundations/design-tokens"],
  "content-design": ["foundations/content-design"],
  elevation: ["styles/elevation"],
  shape: ["styles/shape"],
  icons: ["styles/icons"],
};

const readMd = (p) => fs.readFileSync(p, "utf8");
const listMd = (dir) =>
  fs.existsSync(dir) ? fs.readdirSync(dir).filter((f) => f.endsWith(".md")).sort() : [];

function auditPages() {
  const cards = listMd(path.join(SKILL, "components")).map((f) => {
    const md = readMd(path.join(SKILL, "components", f));
    return { file: `components/${f}`, ...classifyLinks(md), claims: countGuidanceClaims(md), tagged: hasLibraryTag(md) };
  });
  const concepts = listMd(path.join(SKILL, "concepts")).map((f) => {
    const md = readMd(path.join(SKILL, "concepts", f));
    return { file: `concepts/${f}`, slug: f.replace(/\.md$/, ""), ...classifyLinks(md), claims: countGuidanceClaims(md), tagged: hasLibraryTag(md) };
  });
  return { cards, concepts };
}

// A page offends the uncited-guidance rule if it carries substantial guidance
// (>=5 claims) but neither cites the Material spec nor tags itself library behavior.
const UNCITED_CLAIM_FLOOR = 5;
const isUncited = (p) => p.claims >= UNCITED_CLAIM_FLOOR && p.m3 === 0 && !p.tagged;

async function fetchDrift() {
  const url = "https://m3.material.io/sitemap.xml";
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const live = parseSitemapTopics(await res.text());
    const embedded = new Set(Object.keys(M3_TOPICS));
    const missingFromEmbedded = [...live].filter((t) => !embedded.has(t)).sort();
    const goneFromLive = [...embedded].filter((t) => !live.has(t)).sort();
    let out = `\n## Embedded-tree drift (live sitemap: ${live.size} foundations/styles topics)\n\n`;
    out += missingFromEmbedded.length
      ? `**Missing from embedded M3_TOPICS** (live but not tracked):\n${missingFromEmbedded.map((t) => `- ${t}`).join("\n")}\n\n`
      : "No live topics missing from the embedded tree.\n\n";
    out += goneFromLive.length
      ? `**Gone from live** (embedded but not on the live site — verify/re-point):\n${goneFromLive.map((t) => `- ${t}`).join("\n")}\n`
      : "No embedded topics have gone from the live site.\n";
    return out;
  } catch (e) {
    return `\n## Embedded-tree drift\n\n_Skipped: could not fetch ${url} (${e.message}). Run again online to refresh._\n`;
  }
}

async function main() {
  const argv = process.argv.slice(2);
  const doFetch = argv.includes("--fetch");
  const maxIdx = argv.indexOf("--max-uncited");
  const maxUncited = maxIdx >= 0 ? Number(argv[maxIdx + 1]) : null;

  const { cards, concepts } = auditPages();
  const cardsCiting = cards.filter((c) => c.m3 > 0).length;
  const conceptsCiting = concepts.filter((c) => c.m3 > 0).length;

  const embedded = Object.keys(M3_TOPICS);
  const gaps = coverageGaps(embedded, CONCEPT_CLAIMS);
  const covered = embedded.filter((t) => !gaps.includes(t));

  let out = `# Guidance audit\n\n`;
  out += `## Citation counts\n\n`;
  out += `- Component cards citing m3.material.io: **${cardsCiting} of ${cards.length}**\n`;
  out += `- Concept pages citing m3.material.io: **${conceptsCiting} of ${concepts.length}**\n\n`;

  out += `## Coverage vs the M3 topic tree (${embedded.length} foundations/styles topics)\n\n`;
  out += `Covered by a concept page (${covered.length}): ${covered.join(", ") || "none"}\n\n`;
  out += `**Gap** (${gaps.length}): ${gaps.join(", ") || "none"}\n\n`;

  const offenders = [...concepts, ...cards].filter(isUncited);
  out += `## Uncited guidance (>=${UNCITED_CLAIM_FLOOR} claims, no m3 citation, no "(m3e behavior)" tag)\n\n`;
  out += `Offending pages: **${offenders.length}**\n\n`;
  if (offenders.length) {
    for (const p of offenders.sort((a, b) => b.claims - a.claims))
      out += `- ${p.file} — ${p.claims} claims, ${p.m3} m3 citations\n`;
    out += "\n";
  }

  if (doFetch) out += await fetchDrift();

  console.log(out);

  if (maxUncited != null && Number.isFinite(maxUncited) && offenders.length > maxUncited) {
    console.error(`✗ uncited-guidance pages ${offenders.length} exceeds --max-uncited ${maxUncited}`);
    process.exit(1);
  }
}

// Only run the report when executed directly (not when imported by a test).
if (import.meta.url === `file://${process.argv[1]}`) {
  await main();
}
