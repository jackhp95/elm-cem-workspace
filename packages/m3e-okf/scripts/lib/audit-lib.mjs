// audit-lib.mjs — pure helpers behind audit-guidance.mjs.
//
// Kept separate from the CLI/report (scripts/audit-guidance.mjs) so the citation
// counting, guidance-claim density heuristic, sitemap parsing, and coverage-gap
// logic are unit-testable without touching the filesystem or the network.

/** Strip fenced ```…``` code blocks so example markup isn't scanned for prose. */
export function stripCode(md) {
  return md.replace(/```[\s\S]*?```/g, "");
}

/**
 * Classify every link/URL in `md` into { m3, upstream, other }:
 *   - m3       — cites m3.material.io (the Material spec: the citation we want)
 *   - upstream — cites the matraic/m3e repo (library provenance)
 *   - other    — everything else (MDN, etc.)
 * Counts both markdown links and bare URLs.
 */
export function classifyLinks(md) {
  const urls = md.match(/https?:\/\/[^\s)"'<>]+/g) || [];
  let m3 = 0, upstream = 0, other = 0;
  for (const u of urls) {
    if (/(^|\/\/)([a-z0-9-]+\.)?m3\.material\.io\b/.test(u)) m3++;
    else if (/github\.com\/matraic\/m3e\b/.test(u)) upstream++;
    else other++;
  }
  return { m3, upstream, other };
}

/**
 * Count guidance claims (should/prefer/avoid/never/always/must-style directives)
 * in the prose of `md`. Fenced code blocks are excluded so example markup can't
 * inflate the count. This is a heuristic to spot uncited guidance, not a parser.
 */
export function countGuidanceClaims(md) {
  const prose = stripCode(md);
  const re = /\b(should|prefer|avoid|never|always|must|don['’]t|do not)\b/gi;
  return (prose.match(re) || []).length;
}

/** True if `md` carries an explicit "(m3e behavior)" library-behavior tag. */
export function hasLibraryTag(md) {
  return /\(m3e behavior\)/i.test(md);
}

/**
 * From a sitemap.xml string, return the Set of `foundations/<x>` and
 * `styles/<x>` second-level topic segments present on the live M3 site.
 */
export function parseSitemapTopics(xml) {
  const topics = new Set();
  for (const m of xml.matchAll(/<loc>\s*([^<]+?)\s*<\/loc>/g)) {
    const path = m[1].replace(/^https?:\/\/[^/]+/, "").replace(/^\/+/, "");
    const seg = path.match(/^(foundations|styles)\/([^/]+)/);
    if (seg) topics.add(`${seg[1]}/${seg[2]}`);
  }
  return topics;
}

/**
 * Given the list of live/embedded topic keys and the CONCEPT_CLAIMS map
 * (concept slug -> [topic keys it covers]), return the topics no concept claims.
 */
export function coverageGaps(topics, claims) {
  const covered = new Set(Object.values(claims).flat());
  return [...topics].filter((t) => !covered.has(t));
}
