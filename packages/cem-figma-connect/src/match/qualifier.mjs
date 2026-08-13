// CEM-aware "contains" grouping (design: plans/2026-07-18-qualifier-aware-matcher-design.md).
// Groups not-exact-matched Figma sets under the most-specific CEM tag whose
// slug tokens are a subset of the set slug, then decides how the qualifier
// binds (sole / attr / canonical). Produces fusion-shaped groups so matcher.mjs
// reuses proposeFusionValues + the emitter's one-file-per-set path.
//
// Zero deps beyond the sibling normalize module + the ordinal comparator.

import { slugify, pickHeadComponent, BASE_MARKERS, bestValueMatch, mergedVariantAxes, mergedNonVariantProps, foldIdentity } from "./normalize.mjs";
import { byString } from "../lib/order.mjs";

function makeGroup(boundTag, comp, members, mode) {
  return {
    boundTag,
    base: comp.tag,
    baseSlug: comp.slug,
    buildingBlock: null,
    page: members[0].set.page,
    setIds: members.map((m) => m.id),
    members,
    variantAxes: mergedVariantAxes(members),
    nonVariantProps: mergedNonVariantProps(members),
    mode,
  };
}

// detectQualifierGroups(sets, cems) -> ContainsGroup[]
//   sets: Figma sets NOT consumed by exact match or fusion; each { id, name, page, properties? }
//   cems: [{ tag, slug, attributes:[{name,kind,values?}] }, ...]
export function detectQualifierGroups(sets, cems) {
  const cemSlugs = new Set(cems.map((c) => c.slug));
  // 1. Assign each eligible set to its most-specific head component.
  const assignments = new Map(); // tag -> { comp, members:[{id,name,set,qualifier}] }
  for (const set of sets) {
    if (set.name.startsWith(".")) continue; // leading-dot internal, parity with exact tier
    const { slug } = slugify(set.name);
    if (cemSlugs.has(slug)) continue; // slug IS an exact CEM tag -> belongs to the exact tier
    const hit = pickHeadComponent(slug, cems);
    if (!hit) continue;
    const tag = hit.component.tag;
    if (!assignments.has(tag)) assignments.set(tag, { comp: hit.component, members: [] });
    assignments.get(tag).members.push({ id: set.id, name: set.name, set, qualifier: [...hit.qualifier] });
  }

  // 2. Resolve each group by mode. (attr + canonical land in Tasks 3-4.)
  const groups = [];
  for (const { comp, members } of assignments.values()) {
    if (members.length === 1) {
      const m = members[0];
      groups.push(makeGroup(comp.tag, comp, [{ id: m.id, name: m.name, set: m.set, value: null }], "sole"));
      continue;
    }
    const resolved = resolveMulti(comp, members); // Tasks 3-4
    if (resolved) groups.push(resolved);
  }

  // 3. Deterministic order by page then boundTag.
  groups.sort((a, b) => (a.page === b.page ? byString(a.boundTag, b.boundTag) : byString(a.page, b.page)));
  return groups;
}

// Does a member's qualifier resolve against `attr`? Returns the resolving word
// (the raw qualifier token) or null. Enum: any qualifier token value-matches an
// attr value. Boolean: any qualifier token folds to the attr's own name.
function resolveMemberToAttr(member, attr) {
  for (const q of member.qualifier) {
    if (attr.kind === "enum" && Array.isArray(attr.values)) {
      if (bestValueMatch(q, attr.values)) return q;
    } else if (attr.kind === "boolean") {
      if (foldIdentity(q) === foldIdentity(attr.name)) return q;
    }
  }
  return null;
}

// Multi-member: bind on the attribute the qualifiers collectively resolve.
// Returns a ContainsGroup (mode "attr") or null (Task 4 adds canonical).
function resolveMulti(comp, members) {
  const attrs = (comp.attributes || []).filter((a) => a.kind === "enum" || a.kind === "boolean");
  let best = null; // { attr, resolved: Map<memberId, word>, unresolved: [member] }
  for (const attr of attrs) {
    const resolved = new Map();
    const unresolved = [];
    for (const m of members) {
      const w = resolveMemberToAttr(m, attr);
      if (w !== null) resolved.set(m.id, w);
      else unresolved.push(m);
    }
    if (resolved.size === 0) continue;
    if (
      best === null ||
      resolved.size > best.resolved.size ||
      (resolved.size === best.resolved.size && byString(attr.name, best.attr.name) < 0)
    ) best = { attr, resolved, unresolved };
  }

  if (best) {
    if (best.unresolved.length <= 1) {
      const outMembers = members.map((m) => ({
        id: m.id, name: m.name, set: m.set,
        value: best.resolved.has(m.id) ? best.resolved.get(m.id) : null,
      }));
      return makeGroup(comp.tag, comp, outMembers, "attr");
    }
  }
  return resolveCanonical(comp, members); // Task 4
}

function resolveCanonical(comp, members) {
  const canon = members.filter((m) => m.qualifier.length === 1 && BASE_MARKERS.has(m.qualifier[0].toLowerCase()));
  if (canon.length !== 1) return null; // 0 or >1 base markers -> no unambiguous canonical -> gap all
  const m = canon[0];
  return makeGroup(comp.tag, comp, [{ id: m.id, name: m.name, set: m.set, value: null }], "canonical");
}
