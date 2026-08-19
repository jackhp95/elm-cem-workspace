// Normalization primitives shared by fusion.mjs and matcher.mjs — the "slug
// both sides so exact-tier comparison is meaningful, and fuzz the value
// tokens so kit typos still bind" layer (task A5; plans/01-architecture.md §3
// items 2 + 4).
//
// Two independent normalizations live here:
//
//   1. NAME slugging — for component identity. Strips the `m3e-` tag prefix,
//      strips the two `Building Blocks/` path prefixes (tagging their origin,
//      never excluding them — D7), kebab/space/case-folds, and singular/plural
//      folds so the `Checkboxes` page slugs equal to `m3e-checkbox`. The fold
//      is applied symmetrically to BOTH sides, so it only has to be
//      *consistent*, not linguistically perfect (`focus`→`focu` on both sides
//      still matches itself).
//
//   2. VALUE canonicalization + fuzzy match — for axis/enum value binding. A
//      tiny synonym table (the three the kit actually needs: XSmall/XLarge/
//      Round) plus a Levenshtein edit-distance ≤ 2 fuzz that absorbs kit typos
//      — the acceptance case being `Presssed → pressed` (evidence ledger 6a).
//
// Zero deps (architecture rule): pure string/array work.

// -- name slugging -----------------------------------------------------------

// The two Building-Blocks path prefixes the kit uses on nested set names, in
// longest-first order so the dotted form is tried before the bare form.
// `.Building Blocks/` (dotted) hides the page from Figma's UI; `Building
// Blocks/` (plain) does not — both are matched, the origin is only *tagged*.
const BUILDING_BLOCK_PREFIXES = [
  { prefix: ".Building Blocks/", origin: "dot" },
  { prefix: "Building Blocks/", origin: "plain" },
];

// Singularize a single slug token. Deliberately conservative: only the endings
// the fixture actually exercises (`Checkboxes`→checkbox, `chips`→chip,
// `groups`→group, `categories`→category). Applied to BOTH sides, so symmetry —
// not linguistic correctness — is what matters.
export function singularize(token) {
  if (token.length <= 3) return token;
  if (/[^aeiou]ies$/.test(token)) return token.slice(0, -3) + "y"; // categories→category
  if (/(ses|xes|zes|ches|shes)$/.test(token)) return token.slice(0, -2); // checkboxes→checkbox
  if (/[^s]s$/.test(token)) return token.slice(0, -1); // chips→chip (but not ss: address→address)
  return token;
}

// Lowercase, split on every run of non-alphanumerics, singularize each token,
// join with '-'. Empty tokens dropped.
function kebabFold(text) {
  return text
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter(Boolean)
    .map(singularize)
    .join("-");
}

// slugify(rawName) -> { slug, buildingBlock }
//   slug          — the folded, matchable identity string
//   buildingBlock — "dot" | "plain" | null, the stripped prefix's origin
//
// Works for both a CEM tag ("m3e-checkbox") and a Figma set/page name
// ("Checkboxes", "Building Blocks/Button group/Connected segments/XSmall").
export function slugify(rawName) {
  let name = String(rawName ?? "").trim();
  let buildingBlock = null;

  for (const { prefix, origin } of BUILDING_BLOCK_PREFIXES) {
    if (name.startsWith(prefix)) {
      name = name.slice(prefix.length);
      buildingBlock = origin;
      break;
    }
  }

  // Strip the custom-element `m3e-` tag prefix (CEM side only ever carries it).
  name = name.replace(/^m3e-/i, "");

  return { slug: kebabFold(name), buildingBlock };
}

// Convenience: just the slug string.
export function normalizeName(rawName) {
  return slugify(rawName).slug;
}

// -- token-subset containment (qualifier tier) -------------------------------

// The slug's tokens as a Set. slug is already lowercase-kebab-singularized.
export function slugTokenSet(slug) {
  return new Set(String(slug ?? "").split("-").filter(Boolean));
}

// True when EVERY cem token is present in the set's token Set (order-
// independent subset). An empty cem token list never matches (would match
// everything). Handles infixed qualifiers (circular-DETERMINATE-progress-…).
export function containsSubset(cemTokens, setTokenSet) {
  if (!Array.isArray(cemTokens) || cemTokens.length === 0) return false;
  return cemTokens.every((t) => setTokenSet.has(t));
}

// Recognised "this is the unqualified/base variant" qualifier words. A set
// whose sole qualifier is one of these is the canonical member of its group
// (Basic dialog, Standard slider) — see the design's mode 3.
export const BASE_MARKERS = new Set(["basic", "standard", "plain", "generic", "default"]);

// pickHeadComponent(setSlug, cems) -> { component, qualifier: Set } | null
//   cems: [{ tag, slug }, ...] (slug = normalizeName(tag))
// Returns the MOST-SPECIFIC contain-match: the cem whose slug has the most
// tokens all present in the set slug. Ties (equal token count) break by
// ordinal tag order for determinism. `qualifier` = the set tokens NOT in the
// winning cem slug. Returns null when no cem contain-matches.
export function pickHeadComponent(setSlug, cems) {
  const setTokens = slugTokenSet(setSlug);
  let best = null; // { component, cemTokens }
  for (const c of cems) {
    const cemTokens = String(c.slug ?? "").split("-").filter(Boolean);
    if (!containsSubset(cemTokens, setTokens)) continue;
    if (
      best === null ||
      cemTokens.length > best.cemTokens.length ||
      (cemTokens.length === best.cemTokens.length && c.tag < best.component.tag)
    ) {
      best = { component: c, cemTokens };
    }
  }
  if (!best) return null;
  const winning = new Set(best.cemTokens);
  const qualifier = new Set([...setTokens].filter((t) => !winning.has(t)));
  return { component: best.component, qualifier };
}

// -- fusion-shape helpers (shared by fusion.mjs and qualifier.mjs) -----------

// The merged variant axes for a group: taken from the first member that
// actually captured its properties. Each axis: { name, options, defaultValue }.
export function mergedVariantAxes(members) {
  const withProps = members.find((m) => m.set.properties);
  if (!withProps) return [];
  return withProps.set.properties
    .filter((p) => p.type === "VARIANT")
    .map((p) => ({ name: p.displayName, options: p.variantOptions ?? [], defaultValue: p.defaultValue }));
}

// The union of non-variant properties (TEXT / BOOLEAN / INSTANCE_SWAP) across
// all captured members, keyed by displayName (first occurrence wins).
export function mergedNonVariantProps(members) {
  const byName = new Map();
  for (const m of members) {
    if (!m.set.properties) continue;
    for (const p of m.set.properties) {
      if (p.type === "VARIANT") continue;
      if (!byName.has(p.displayName))
        byName.set(p.displayName, { name: p.displayName, type: p.type, defaultValue: p.defaultValue });
    }
  }
  return [...byName.values()];
}

// Fold an identifier token for identity comparison: lowercase, drop every
// non-alphanumeric. Used for axis/attribute NAMES and boolean option words
// (distinct from canonicalizeValue, which applies the XSmall/Round value
// synonym table).
export function foldIdentity(s) {
  return String(s ?? "").toLowerCase().replace(/[^a-z0-9]+/g, "");
}

// -- value canonicalization + fuzzy match ------------------------------------

// The minimal synonym table the kit requires (task brief). Keys are the folded
// Figma spelling; values are the CEM-canonical spelling. `outline→outlined`
// and typos like `Presssed` are intentionally NOT here — the edit-distance
// fuzz covers those, and keeping the table tiny keeps it auditable.
const VALUE_SYNONYMS = new Map([
  ["xsmall", "extra-small"],
  ["x-small", "extra-small"],
  ["extrasmall", "extra-small"],
  ["xlarge", "extra-large"],
  ["x-large", "extra-large"],
  ["extralarge", "extra-large"],
  ["round", "rounded"],
]);

// Fold a raw value token: lowercase, kebab, then apply the synonym table.
export function canonicalizeValue(value) {
  const folded = String(value ?? "")
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter(Boolean)
    .join("-");
  return VALUE_SYNONYMS.get(folded) ?? folded;
}

// Levenshtein edit distance (iterative two-row). No cap — value tokens are
// short, so the full DP is cheap and keeps the code obvious.
export function editDistance(a, b) {
  a = String(a);
  b = String(b);
  if (a === b) return 0;
  if (a.length === 0) return b.length;
  if (b.length === 0) return a.length;

  let prev = Array.from({ length: b.length + 1 }, (_, i) => i);
  let curr = new Array(b.length + 1);
  for (let i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      curr[j] = Math.min(curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost);
    }
    [prev, curr] = [curr, prev];
  }
  return prev[b.length];
}

// Review fix (Important #3): an absolute edit-distance cap is unscaled for
// short tokens — at maxDistance=2, arbitrary 2-4 char enum values collide
// (on/off dist 2, hide/wide dist 1, low/bun dist 3, flat/fan dist 2,
// page/date dist 2). The cap must shrink for short tokens. Two conditions
// must BOTH hold:
//   1. distance <= maxDistance AND distance <= floor(longerLen / 3) — an
//      absolute, length-scaled ceiling (short tokens get a tiny or zero
//      budget; the 8-char Presssed/pressed pair still gets floor(8/3)=2).
//   2. distance / longerLen <= FUZZY_RATIO_THRESHOLD — a proportional bound,
//      because condition 1 alone still lets e.g. "hide"/"wide" (len 4,
//      cap 1, distance 1) through. 0.2 keeps the two real acceptance cases
//      (Presssed→pressed, outline→outlined: both 1/8 = 0.125) comfortably
//      under, while every unrelated short pair above (ratios 0.25-1.0) sits
//      above it and is rejected.
const FUZZY_RATIO_THRESHOLD = 0.2;

// valueMatch(figmaValue, cemValue, {maxDistance=2}) -> {
//   match: boolean, method: "exact"|"synonym"|"fuzzy"|null, distance: number
// }
//   - exact:   folded spellings equal, no synonym rewrite needed
//   - synonym: equal only after the synonym table rewrote one side
//   - fuzzy:   canonical forms within a length-scaled edit-distance budget
//     (see FUZZY_RATIO_THRESHOLD above) — absorbs kit typos without letting
//     short unrelated tokens collide.
export function valueMatch(figmaValue, cemValue, { maxDistance = 2 } = {}) {
  const fFold = String(figmaValue ?? "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  const cFold = String(cemValue ?? "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  if (fFold === cFold) return { match: true, method: "exact", distance: 0 };

  const fCanon = canonicalizeValue(figmaValue);
  const cCanon = canonicalizeValue(cemValue);
  if (fCanon === cCanon) return { match: true, method: "synonym", distance: 0 };

  const distance = editDistance(fCanon, cCanon);
  const longerLen = Math.max(fCanon.length, cCanon.length, 1);
  const scaledCap = Math.min(maxDistance, Math.floor(longerLen / 3));
  const ratio = distance / longerLen;
  if (distance <= scaledCap && ratio <= FUZZY_RATIO_THRESHOLD) {
    return { match: true, method: "fuzzy", distance };
  }

  return { match: false, method: null, distance };
}

// bestValueMatch(value, candidates, opts) -> {
//   value: <winning candidate>, method, distance
// } | null   (candidates = array of CEM value strings)
//
// Ties broken by (a) method precedence exact > synonym > fuzzy, then (b)
// smallest edit distance, then (c) candidate order — fully deterministic.
export function bestValueMatch(value, candidates, opts = {}) {
  const rank = { exact: 0, synonym: 1, fuzzy: 2 };
  let best = null;
  for (const candidate of candidates) {
    const m = valueMatch(value, candidate, opts);
    if (!m.match) continue;
    if (
      best === null ||
      rank[m.method] < rank[best.method] ||
      (rank[m.method] === rank[best.method] && m.distance < best.distance)
    ) {
      best = { value: candidate, method: m.method, distance: m.distance };
    }
  }
  return best;
}
