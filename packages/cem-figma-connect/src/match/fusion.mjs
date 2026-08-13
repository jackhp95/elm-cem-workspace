// Set-fusion detection (task A5; evidence #9, plans/01-architecture.md §3
// item 1). The single structural fact the vision brief did not anticipate:
// one CEM component often corresponds to SEVERAL Figma sets, each contributing
// a *fixed* attribute value. The button's colour "variant" is not a variant
// axis — it is five sibling SETS on the Buttons page:
//
//     Button                (bare  → the enum value no sibling claims)
//     Button - text         (→ variant="text")
//     Button - elevated     (→ variant="elevated")
//     Button - outline      (→ variant="outlined", via fuzzy fold)
//     Button - tonal        (→ variant="tonal")
//
// This module does the *structural* half: group `<Base> - <value>` siblings
// (plus the bare `<Base>`) that live on ONE page and whose captured variant-
// axis signatures are compatible. Binding each fixed `<value>` to a concrete
// CEM enum attribute happens later, in matcher.mjs, once the base name has
// been matched to a component (only then do we know which enum to fuzz
// against).
//
// Zero deps beyond normalize.mjs + the shared ordinal comparator in
// ../lib/order.mjs.

import { slugify, mergedVariantAxes, mergedNonVariantProps } from "./normalize.mjs";
import { byString } from "../lib/order.mjs";

// Split a set name into { base, value } on the FIRST " - " separator.
// `Icon button togglable - tonal` → base "Icon button togglable", value
// "tonal". A name with no " - " is a bare candidate (value null).
function splitBaseValue(name) {
  const idx = name.indexOf(" - ");
  if (idx === -1) return { base: name, value: null };
  return { base: name.slice(0, idx), value: name.slice(idx + 3).trim() };
}

// The sorted list of VARIANT axis names a set exposes, or null if this set has
// no captured `setProperties` (only SOME sets do — the loader attaches
// `.properties` selectively; the un-captured siblings still fuse, contributing
// only their fixed value).
function variantAxisSignature(set) {
  if (!set.properties) return null;
  return set.properties
    .filter((p) => p.type === "VARIANT")
    .map((p) => p.displayName)
    .sort();
}

// Review fix (Minor #4): joining sorted axis-name arrays with "" let
// ["A","BC"] and ["AB","C"] collide (both join to "ABC"). Join with a
// delimiter that cannot appear inside an axis display name. NOT " " or NUL —
// this file just had NUL bytes stripped and git flagged it binary; a plain
// space is also a legitimate axis-name character (e.g. "Show icon"). Use the
// ASCII unit separator (0x1F), which never appears in a Figma property name.
const AXIS_JOIN_DELIMITER = "\x1f";

// Two axis signatures are compatible when the captured ones are identical.
// (Un-captured members contribute `null` and are ignored for the check — we do
// NOT hard-require setProperties on every fused set; only 2 of the 5 button
// sets have them.)
function signaturesCompatible(signatures) {
  const present = signatures.filter((s) => s !== null);
  if (present.length === 0) return true;
  const first = present[0].join(AXIS_JOIN_DELIMITER);
  return present.every((s) => s.join(AXIS_JOIN_DELIMITER) === first);
}

// detectFusionGroups(sets) -> FusionGroup[]
//
// A FusionGroup is emitted only when a base name has at least one
// `<Base> - <value>` sibling (a lone bare set is not a fusion). Members are the
// bare `<Base>` (if present) plus every `<Base> - <value>` on the SAME page
// with a compatible axis signature.
//
// FusionGroup = {
//   base,           // raw base name, e.g. "Button"
//   baseSlug,       // slugify(base).slug, e.g. "button"
//   buildingBlock,  // "dot"|"plain"|null, from the base name
//   page,
//   setIds,         // every member set id
//   members: [{ id, name, set, value }]   // value=null for the bare member
//   variantAxes,    // merged [{name, options, defaultValue}]
//   nonVariantProps // merged [{name, type, defaultValue}]
// }
export function detectFusionGroups(sets) {
  // Group candidate sets by "page  baseSlug" so siblings only fuse within
  // one page, and so that e.g. "Button" and "Toggle button" never collide.
  const buckets = new Map();
  for (const set of sets) {
    const { base, value } = splitBaseValue(set.name);
    const { slug: baseSlug, buildingBlock } = slugify(base);
    const key = `${set.page}${baseSlug}`;
    if (!buckets.has(key)) {
      buckets.set(key, { base, baseSlug, buildingBlock, page: set.page, members: [] });
    }
    buckets.get(key).members.push({ id: set.id, name: set.name, set, value });
  }

  const groups = [];
  for (const bucket of buckets.values()) {
    const hasSibling = bucket.members.some((m) => m.value !== null);
    const memberCount = bucket.members.length;
    // A fusion needs a `<Base> - <value>` sibling AND more than one set (a
    // single "Foo - bar" set with no bare `Foo` and no other sibling is just a
    // normally-named set, not a fusion).
    if (!hasSibling || memberCount < 2) continue;

    const signatures = bucket.members.map((m) => variantAxisSignature(m.set));
    if (!signaturesCompatible(signatures)) continue;

    groups.push({
      base: bucket.base,
      baseSlug: bucket.baseSlug,
      buildingBlock: bucket.buildingBlock,
      page: bucket.page,
      setIds: bucket.members.map((m) => m.id),
      members: bucket.members,
      variantAxes: mergedVariantAxes(bucket.members),
      nonVariantProps: mergedNonVariantProps(bucket.members),
    });
  }

  // Deterministic order: by page then base slug. Ordinal (code-unit)
  // compare — deliberately NOT localeCompare, which is ICU/locale-sensitive
  // and would threaten byte-stability (determinism is a hard gate in this
  // project; shared comparator in ../lib/order.mjs).
  groups.sort((a, b) => (a.page === b.page ? byString(a.baseSlug, b.baseSlug) : byString(a.page, b.page)));
  return groups;
}
