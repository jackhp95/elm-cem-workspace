// Brand-agnostic derivation of the docs "family" surface from a brand's
// `_families.families` config (the same block elm-cem's gen-family-package.js
// reads to emit the family package). Pure: takes the parsed config object,
// returns the docs data — no fs, no brand knowledge.
//
// Faithful to gen-family-package.js's labelling so the docs names match the real
// generated `<Ns>.Family.<F>` constructors 1:1:
//   - the ROOT member's element label is the FAMILY name (lowerFirst),
//   - every other member's is its `path` field (lowerFirst),
//   - order is root-first, then config order.
//
// This is the reusable core of each brand's `gen-family-data` wrapper: the brand
// supplies the config path + output path; this supplies the algorithm.

const lowerFirst = (s) => (s.length ? s[0].toLowerCase() + s.slice(1) : s);

/**
 * @param {Record<string, {root: string|null, members?: {component: string, path: string}[]}>} families
 *   The `_families.families` block (object keyed by family name).
 * @param {{ sort?: boolean }} [opts] `sort` (default true) sorts families
 *   alphabetically for the docs listing; pass false to keep config order.
 * @returns {{ family: string, members: { component: string, label: string }[] }[]}
 */
export function deriveFamilies(families, opts = {}) {
  const { sort = true } = opts;
  if (!families || typeof families !== "object") {
    throw new Error("deriveFamilies: expected the `_families.families` object");
  }
  const out = [];
  for (const [family, spec] of Object.entries(families)) {
    const members = [];
    if (spec.root) members.push({ component: spec.root, label: lowerFirst(family) });
    for (const mem of spec.members || []) {
      if (!mem.component || !mem.path) {
        throw new Error(`deriveFamilies: family "${family}" has a malformed member ${JSON.stringify(mem)}`);
      }
      members.push({ component: mem.component, label: lowerFirst(mem.path) });
    }
    if (members.length === 0) {
      throw new Error(`deriveFamilies: family "${family}" has no root and no members`);
    }
    out.push({ family, members });
  }
  if (sort) out.sort((a, b) => a.family.localeCompare(b.family, "en"));
  return out;
}
