// Tiered matcher (task A5; plans/01-architecture.md §3). Consumes loadCem() +
// loadFigmaExport() views, emits one match candidate per Figma component
// concept (fusion group, singleton set, or the icon page) with:
//
//   { cemTag, figmaSetIds, tier, score, rationale }        (brief output shape)
//
// plus the axis/property/value proposals Plan A's correspondence file needs.
//
// Tiers, in order:
//   exact — normalized name equal (fusion base slug or set slug == CEM tag slug)
//   fuzzy — best of three auditable signals: name edit-distance, description
//           token overlap, shared m3.material.io/components/… doc URLs (present
//           on BOTH sides). Accepted above a threshold.
//   gap   — no CEM counterpart (emitted with cemTag=null; Plan A's gap report
//           consumes these).
//
// Every proposal carries an auditable rationale string. Zero deps beyond the
// two sibling normalize/fusion modules.

import fs from "node:fs";
import path from "node:path";

import {
  slugify,
  normalizeName,
  editDistance,
  bestValueMatch,
  foldIdentity,
} from "./normalize.mjs";
import { detectFusionGroups } from "./fusion.mjs";
import { detectQualifierGroups } from "./qualifier.mjs";
import { byKey } from "../lib/order.mjs";

// finding 2.4 (2026-08-17 thermonuclear review): this matcher is meant to be
// design-kit-generic — every brand-calibrated number/word-list below (which
// tags' descriptions to distrust, the fuzzy-accept threshold, which English
// words a given kit's authors use for boolean variant options) used to be
// hardcoded here as M3E/m3-kit constants, contradicting the spine-design
// doc's promise that kit-specificity stays in profiles/<kit>/. They now live
// in profiles/<kit>/matcher.json (see profiles/m3-kit/matcher.json for the
// m3-kit calibration + task-A5-report.md's evidence) and are loaded via
// `loadMatcherConfig()` below, then threaded through as the `matcherConfig`
// parameter — this module holds no kit-specific defaults of its own.
//
// Shape (post-load, see loadMatcherConfig): {
//   descriptionUntrusted: Set<cemTag>,     // never let description feed the fuzzy scorer
//   fuzzyAcceptThreshold: number,
//   booleanOptionPolarity: Map<word, bool>,
//   booleanAxisSynonyms: Map<axisWord, cemAttrWord>,
//   multiBooleanAffinity: [word, cemAttrName][],
// }

// Load + validate a design-kit's matcher calibration from
// <profileDir>/matcher.json. Required — there is no brand-neutral fallback
// for "which words mean true" or "how strict is fuzzy matching", so a
// profile missing this file fails loud rather than silently borrowing
// another kit's calibration.
export function loadMatcherConfig(profileDir) {
  const file = path.join(profileDir, "matcher.json");
  let raw;
  try {
    raw = JSON.parse(fs.readFileSync(file, "utf8"));
  } catch (e) {
    throw new Error(`matcher: could not read required ${file}: ${e.message}`);
  }
  const required = [
    "descriptionUntrusted",
    "fuzzyAcceptThreshold",
    "booleanOptionPolarity",
    "booleanAxisSynonyms",
    "multiBooleanAffinity",
  ];
  for (const field of required) {
    if (raw[field] === undefined) {
      throw new Error(`matcher: ${file} is missing required field "${field}"`);
    }
  }
  return {
    descriptionUntrusted: new Set(raw.descriptionUntrusted),
    fuzzyAcceptThreshold: raw.fuzzyAcceptThreshold,
    booleanOptionPolarity: new Map(raw.booleanOptionPolarity),
    booleanAxisSynonyms: new Map(raw.booleanAxisSynonyms),
    multiBooleanAffinity: raw.multiBooleanAffinity,
  };
}

const DOC_URL_RE = /m3\.material\.io\/components\/[a-z0-9-]+/gi;
const STOPWORDS = new Set([
  "a", "an", "the", "and", "or", "of", "to", "for", "with", "that", "this",
  "can", "on", "in", "is", "are", "be", "as", "use", "used", "users", "user",
  "take", "takes", "help", "helps", "people", "an", "it", "its",
]);

// -- small helpers -----------------------------------------------------------

function docUrls(text) {
  return new Set((String(text ?? "").match(DOC_URL_RE) ?? []).map((u) => u.toLowerCase()));
}

function descriptionTokens(text) {
  return new Set(
    String(text ?? "")
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .filter((t) => t.length > 2 && !STOPWORDS.has(t))
  );
}

function jaccard(a, b) {
  if (a.size === 0 || b.size === 0) return 0;
  let inter = 0;
  for (const t of a) if (b.has(t)) inter++;
  return inter / (a.size + b.size - inter);
}

// -- CEM index ---------------------------------------------------------------

function indexCem(cem) {
  const bySlug = new Map(); // slug -> [component]
  const enriched = cem.components.map((component) => {
    const slug = normalizeName(component.tag);
    if (!bySlug.has(slug)) bySlug.set(slug, []);
    bySlug.get(slug).push(component);
    return { component, slug };
  });
  const cems = enriched.map(({ component, slug }) => ({ tag: component.tag, slug, attributes: component.attributes }));
  return { bySlug, enriched, cems };
}

// -- axis / property / value proposals ---------------------------------------

function enumAttributes(component) {
  return component.attributes.filter((a) => a.kind === "enum" && Array.isArray(a.values));
}

function booleanAttributes(component) {
  return component.attributes.filter((a) => a.kind === "boolean");
}

// The boolean option vocabulary (which folded Figma option words read as the
// TRUE vs FALSE pole) and the axis-name→attr synonym table are both loaded
// from the profile's matcher.json — see loadMatcherConfig() above.

// A Figma VARIANT axis with exactly two options forming a boolean pair (True/
// False, On/Off, Yes/No) has no ENUM CEM counterpart, so proposeAxis()'s enum
// scan leaves it unmapped — yet a BOOLEAN CEM attr represents it exactly. Bind
// such an axis to the boolean attr picked by NAME affinity: name-identical
// after folding, or via `matcherConfig.booleanAxisSynonyms`. We never guess
// when no name matches (switch's second `Icon` True/False axis has no boolean
// attr named for it → stays unmapped) — binding an arbitrary boolean would
// silently mis-drive.
function proposeBooleanAxis(axis, component, matcherConfig) {
  if (!Array.isArray(axis.options) || axis.options.length !== 2) return null;
  const polarities = axis.options.map((o) => matcherConfig.booleanOptionPolarity.get(foldIdentity(o)));
  if (polarities.some((p) => p === undefined)) return null; // not boolean-shaped words
  if (polarities[0] === polarities[1]) return null; // both same pole → not a real pair

  const bools = booleanAttributes(component);
  if (bools.length === 0) return null;

  // Name-affinity: prefer a boolean attr named identically to the axis (chip
  // `Selected`→`selected`, `Modal`→`modal`); only if none matches fall back to
  // the synonym table (switch `Selected`→`checked`). Synonym must never
  // OVERRIDE a name-exact hit.
  const axisFold = foldIdentity(axis.name);
  let attr = bools.find((a) => foldIdentity(a.name) === axisFold);
  if (!attr && matcherConfig.booleanAxisSynonyms.has(axisFold)) {
    const syn = matcherConfig.booleanAxisSynonyms.get(axisFold);
    attr = bools.find((a) => foldIdentity(a.name) === syn);
  }
  if (!attr) return null;
  const viaSynonym = foldIdentity(attr.name) !== axisFold;

  const valueMap = axis.options.map((option, i) => ({
    figma: option,
    cem: polarities[i] ? "true" : "false",
    method: "boolean",
  }));
  return {
    axis: axis.name,
    mapped: true,
    attribute: attr.name,
    attributeKind: "boolean",
    coverage: `${valueMap.length}/${axis.options.length}`,
    valueMap,
    rationale: `axis '${axis.name}' → boolean attr '${attr.name}' (2-option boolean axis${
      viaSynonym ? ` via '${axisFold}'→'${foldIdentity(attr.name)}'` : ""
    }; ${valueMap.map((v) => `${v.figma}→${v.cem}`).join(", ")})`,
  };
}

// The multi-boolean affinity vocabulary ([wordThatImpliesTrue, cemAttrName]
// pairs, matched by folded whole-word match — see affinityMatch below) is
// loaded from the profile's matcher.json (`multiBooleanAffinity`).
//
// Returns true when `word` is a "positive" match in the folded option token:
// the token is exactly `word`, or it ends with `word` without the "un" prefix
// (e.g. "errorselected" ends with "selected" and has no "un" before it).
function affinityMatch(foldedOption, word) {
  if (foldedOption === word) return true;
  if (!foldedOption.endsWith(word)) return false;
  // Ensure the immediately preceding chars (if any) are not the "un" negator.
  const prefix = foldedOption.slice(0, foldedOption.length - word.length);
  return !prefix.endsWith("un");
}

// proposeMultiAttrAxis(axis, component, matcherConfig) -> proposal | null
//
// Detects when one Figma axis drives MULTIPLE CEM boolean attrs, e.g.
// checkbox's Type axis: "Selected"→checked=true, "Indeterminate"→
// indeterminate=true, everything else→neither. General rule:
//
//   1. For each `matcherConfig.multiBooleanAffinity` [word, cemAttr]:
//      a. The component must have a boolean attr named `cemAttr`.
//      b. At least one Figma axis option must affinity-match `word` (after
//         folding) — excluding "un…" negations.
//      c. Those matched options map to "true" for that attr; all others → "false".
//   2. If ≥2 distinct CEM attrs fire AND collectively at least one option maps
//      something to "true" for each attr, the axis is a multi-attr axis.
//   3. Only options that are affinity-matched to at least ONE attr contribute
//      a true-pole mapping; all other options contribute no attribute (the
//      "neither" case — neither checked nor indeterminate for Unselected).
//
// The result carries `attrs: [{attr, valueMap}]` (one entry per firing CEM
// attr) and `kind: "multi-boolean"`.
function proposeMultiAttrAxis(axis, component, matcherConfig) {
  const bools = booleanAttributes(component);
  if (bools.length < 2) return null; // need at least 2 boolean attrs to fire

  const firings = []; // { attr: name, matchingOptions: [figmaOption, ...] }
  for (const [word, cemAttrName] of matcherConfig.multiBooleanAffinity) {
    const boolAttr = bools.find((a) => foldIdentity(a.name) === cemAttrName);
    if (!boolAttr) continue;
    const matching = axis.options.filter((opt) => affinityMatch(foldIdentity(opt), word));
    if (matching.length === 0) continue;
    firings.push({ attr: cemAttrName, matchingOptions: matching });
  }

  if (firings.length < 2) return null; // must drive at least 2 attrs to be multi-attr

  // Build per-attr valueMaps: matched options → "true", all others → "false".
  const attrEntries = firings.map(({ attr, matchingOptions }) => {
    const matchSet = new Set(matchingOptions);
    const valueMap = Object.fromEntries(
      axis.options.map((opt) => [opt, matchSet.has(opt) ? "true" : "false"])
    );
    return { attr, valueMap };
  });

  const attrNames = attrEntries.map((e) => e.attr).join(", ");
  const rationale = `axis '${axis.name}' → multi-boolean attrs [${attrNames}] (` +
    firings
      .map(
        ({ attr, matchingOptions }) =>
          `${attr}: ${matchingOptions.join("|")}=true`
      )
      .join("; ") +
    `)`;

  return {
    axis: axis.name,
    mapped: true,
    kind: "multi-boolean",
    attrs: attrEntries,
    coverage: `${axis.options.length}/${axis.options.length}`,
    rationale,
  };
}

// Map ONE Figma VARIANT axis to the best-overlapping CEM enum attribute. An
// axis maps when some enum attribute's value set covers a majority of the
// axis's options (each option value-matched, tolerant of synonyms + typos).
// Axes with no CEM counterpart return { mapped:false, reason }.
export function proposeAxis(axis, component, matcherConfig) {
  const enums = enumAttributes(component);
  let best = null;
  for (const attr of enums) {
    const valueMap = [];
    for (const option of axis.options) {
      const m = bestValueMatch(option, attr.values);
      if (m) valueMap.push({ figma: option, cem: m.value, method: m.method });
    }
    const coverage = axis.options.length ? valueMap.length / axis.options.length : 0;
    if (best === null || coverage > best.coverage) best = { attr, valueMap, coverage };
  }

  // Review fix (Minor #5): 0.6 = a clear "more than half" majority-vote gate —
  // deliberately looser than requiring every option to value-match (a Figma
  // axis may carry an option the CEM enum genuinely has no counterpart for,
  // yet still clearly BE that attribute), but strict enough to reject an
  // attribute that only coincidentally overlaps on one or two values. On this
  // fixture the real cases sit at the extremes, not near the boundary — the
  // button's Size/Type axes cover 5/5 and 2/2 (1.0) while its State axis
  // covers 0/5 (0.0), so 0.6 cleanly separates "this axis clearly IS this
  // attribute" (Size→size, Type→shape) from "no CEM attribute represents this
  // axis at all" (State→unmapped) without landing on a case that actually
  // tests the boundary.
  if (!best || best.coverage < 0.6) {
    // No ENUM attribute represents this axis — try the BOOLEAN path (a 2-option
    // boolean-shaped axis → a name-affine boolean attr) before giving up.
    const boolProposal = proposeBooleanAxis(axis, component, matcherConfig);
    if (boolProposal) return boolProposal;
    // Try the MULTI-ATTR boolean path (axis drives 2+ boolean attrs by name
    // affinity, e.g. checkbox Type → {checked, indeterminate}).
    const multiProposal = proposeMultiAttrAxis(axis, component, matcherConfig);
    if (multiProposal) return multiProposal;
    return {
      axis: axis.name,
      mapped: false,
      reason: `no CEM enum attribute shares its value set (options: ${axis.options.join(", ")})`,
    };
  }

  const covered = best.valueMap.length;
  const total = axis.options.length;
  const detail = best.valueMap
    .map((v) => `${v.figma}→${v.cem}${v.method === "exact" ? "" : ` (${v.method})`}`)
    .join(", ");
  return {
    axis: axis.name,
    mapped: true,
    attribute: best.attr.name,
    coverage: `${covered}/${total}`,
    valueMap: best.valueMap,
    rationale: `axis '${axis.name}' → attr '${best.attr.name}' via ${covered}/${total} value overlap (${detail})`,
  };
}

// Non-variant Figma property → CEM binding proposal. The four shapes evidence
// #10 documents: TEXT default→content (default slot), BOOLEAN `Show icon`→icon
// slot presence, INSTANCE_SWAP `Icon`→icon slot (named), INSTANCE_SWAP
// `Icon`→default slot (unnamed, RC2 icon-button). Anything else with no CEM
// counterpart is surfaced as `unmapped` (never silently dropped — §3 item 4).
function proposeProperty(prop, component) {
  const slotNames = new Set(component.slots.map((s) => s.name));
  const nameLower = prop.name.toLowerCase();

  if (prop.type === "TEXT") {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      proposal: "content",
      target: "slot:(default)",
      default: prop.defaultValue,
      rationale: `TEXT '${prop.name}' (default ${JSON.stringify(prop.defaultValue)}) → default content slot`,
    };
  }

  if (prop.type === "INSTANCE_SWAP" && nameLower.includes("icon") && slotNames.has("icon")) {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      proposal: "slot",
      target: "slot:icon",
      rationale: `INSTANCE_SWAP '${prop.name}' → 'icon' slot (Material Symbols name pass-through)`,
    };
  }

  // RC2: INSTANCE_SWAP icon → DEFAULT (unnamed) slot. The component has a
  // default slot ("" in the CEM slots array) but NO named "icon" slot — the
  // icon-button case. Binding is "slot:" (slot: prefix + empty name), which
  // the html-label emitter renders unconditionally as
  // `<m3e-icon ${glyph}></m3e-icon>` (no slot attr needed; empty-name slot
  // IS the default slot per the Web Components spec, confirmed in RC5).
  if (prop.type === "INSTANCE_SWAP" && nameLower.includes("icon") && slotNames.has("") && !slotNames.has("icon")) {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      proposal: "slot",
      target: "slot:",
      rationale: `INSTANCE_SWAP '${prop.name}' → default (unnamed) slot (Material Symbols name pass-through)`,
    };
  }

  if (prop.type === "BOOLEAN" && nameLower.includes("icon") && slotNames.has("icon")) {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      proposal: "slot-presence",
      target: "slot:icon",
      rationale: `BOOLEAN '${prop.name}' → presence of the 'icon' slot`,
    };
  }

  return {
    property: prop.name,
    type: prop.type,
    mapped: false,
    reason: "no CEM counterpart (Figma-only property)",
    rationale: `${prop.type} '${prop.name}' unmapped: no CEM counterpart`,
  };
}

// SLOT-typed Figma property → CEM slot binding proposal. SLOT is its own
// first-class dimension (component-property.slots.json), not a `props[]`
// catch-all case — see the two `match()` call sites below, which filter SLOT
// out of the non-VARIANT property list before it ever reaches
// proposeProperty(). Matching is a straight fuzzy value match of the Figma
// slot name against the bound CEM component's NAMED slots (same
// bestValueMatch() used for fusion/axis value matching elsewhere in this
// file — no separate fuzzy-matching scheme), falling back to the CEM
// component's unnamed DEFAULT slot (name:"") for a generic-content Figma
// SLOT prop when no named slot matches — mirrors proposeProperty's own
// TEXT→default-content-slot convention (evidence #10) for the analogous
// SLOT case, e.g. a Dialog's "Content" SLOT prop has no CEM slot literally
// named "content" but plainly belongs in the default slot.
export function proposeSlot(prop, component) {
  const cemSlotNames = component.slots.map((s) => s.name);
  const namedSlotNames = cemSlotNames.filter((n) => n !== "");
  const best = bestValueMatch(prop.name, namedSlotNames);
  if (best) {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      target: best.value,
      method: best.method, // "exact" | "synonym" | "fuzzy" — threaded through for merge.mjs provenance
      rationale: `SLOT '${prop.name}' → CEM slot '${best.value}' (${best.method} match)`,
    };
  }

  // Generic-content fallback: a Figma SLOT prop whose name reads as
  // general/default content (e.g. "Content", "Content (standard)") maps to
  // the CEM component's unnamed default slot, when it has one — never
  // silently left unmapped just because no NAMED slot happens to share the
  // word "content".
  if (/\bcontent\b/i.test(prop.name) && cemSlotNames.includes("")) {
    return {
      property: prop.name,
      type: prop.type,
      mapped: true,
      target: "(default)",
      // "fuzzy", not "exact": this is a regex-based generic-content heuristic
      // (the Figma prop's name merely READS as generic content), not a
      // verified name-identity match against a real CEM slot name — merge.mjs
      // (buildSlots/slotProvenance) turns this into provenance:"auto-fuzzy",
      // an honest "matched via heuristic" signal for the human reviewer
      // (final-review finding #2 — 6 of 7 real m3-kit slot matches take this
      // path and were previously mislabeled "auto-exact").
      method: "fuzzy",
      rationale: `SLOT '${prop.name}' → CEM default (unnamed) slot (generic-content name, no named slot counterpart)`,
    };
  }

  return {
    property: prop.name,
    type: prop.type,
    mapped: false,
    reason: `no CEM slot matches Figma SLOT property '${prop.name}'`,
    rationale: `SLOT '${prop.name}' unmapped: no CEM slot counterpart`,
  };
}

// Bind each fused set's fixed `<value>` to a CEM enum attribute. Every sibling
// value is fuzzed against every enum; the attribute the majority of siblings
// agree on is the fusion axis. The bare `<Base>` set (value=null) takes the
// single enum value NO sibling claimed (the button's "filled" — the value not
// drawn as its own sibling set), falling back to the CEM attribute default if
// the leftover is not unique.
function proposeFusionValues(group, component) {
  const enums = enumAttributes(component);
  const siblingValues = group.members.filter((m) => m.value !== null).map((m) => m.value);

  // Which enum attribute do the sibling values collectively map into? Score
  // each enum by how many siblings it can value-match.
  let chosen = null;
  for (const attr of enums) {
    const hits = siblingValues.filter((v) => bestValueMatch(v, attr.values)).length;
    if (chosen === null || hits > chosen.hits) chosen = { attr, hits };
  }
  if (!chosen || chosen.hits === 0) {
    return { attribute: null, fixedValues: [], rationale: "no CEM enum matched the fused set values" };
  }

  const attr = chosen.attr;
  const claimed = new Set();
  const fixedValues = [];
  for (const member of group.members) {
    if (member.value === null) continue;
    const m = bestValueMatch(member.value, attr.values);
    if (m) {
      claimed.add(m.value);
      fixedValues.push({
        setId: member.id,
        figmaValue: member.value,
        attribute: attr.name,
        cemValue: m.value,
        method: m.method,
      });
    } else {
      fixedValues.push({
        setId: member.id,
        figmaValue: member.value,
        attribute: attr.name,
        cemValue: null,
        method: null,
      });
    }
  }

  // Resolve the bare member to the single unclaimed enum value.
  const bare = group.members.find((m) => m.value === null);
  if (bare) {
    const leftovers = attr.values.filter((v) => !claimed.has(v));
    let cemValue;
    let method;
    if (leftovers.length === 1) {
      cemValue = leftovers[0];
      method = "leftover";
    } else {
      // Fall back to the enum's declared default (the CEM stores defaults with
      // surrounding quotes, e.g. "\"filled\"" — strip them).
      const defAttr = component.attributes.find((a) => a.name === attr.name);
      cemValue = defAttr && typeof defAttr.default === "string" ? defAttr.default.replace(/^"|"$/g, "") : null;
      method = "cem-default";
    }
    fixedValues.push({
      setId: bare.id,
      figmaValue: null,
      attribute: attr.name,
      cemValue,
      method,
    });
  }

  return {
    attribute: attr.name,
    fixedValues,
    rationale: `fused sets bind attr '${attr.name}'; bare '${group.base}' → '${
      fixedValues.find((f) => f.figmaValue === null)?.cemValue ?? "?"
    }' (${fixedValues.find((f) => f.figmaValue === null)?.method ?? "n/a"})`,
  };
}

// -- fuzzy scoring -----------------------------------------------------------

// Score a candidate (Figma side) against a CEM component. Three normalized
// signals, weighted; returns { score, signals } for auditable rationale.
function fuzzyScore(candidate, component, matcherConfig) {
  const slugDist = editDistance(candidate.slug, normalizeName(component.tag));
  const maxLen = Math.max(candidate.slug.length, normalizeName(component.tag).length, 1);
  const nameSignal = Math.max(0, 1 - slugDist / maxLen);

  let descSignal = 0;
  if (!matcherConfig.descriptionUntrusted.has(component.tag)) {
    descSignal = jaccard(candidate.descTokens, descriptionTokens(component.description));
  }

  const sharedUrls = [...candidate.docUrls].filter((u) => docUrls(component.description).has(u));
  const urlSignal = sharedUrls.length > 0 ? 1 : 0;

  const score = 0.6 * nameSignal + 0.25 * descSignal + 0.15 * urlSignal;
  return { score, nameSignal, descSignal, urlSignal, sharedUrls };
}

// -- candidate assembly ------------------------------------------------------

// Build the Figma-side candidate list: fusion groups first (they consume their
// member set ids), then every remaining singleton set, then the icon page.
function buildFigmaCandidates(figma, cems) {
  const groups = detectFusionGroups(figma.sets);
  const consumed = new Set(groups.flatMap((g) => g.setIds));

  const candidates = [];

  for (const group of groups) {
    candidates.push({
      kind: "fusion",
      name: group.base,
      slug: group.baseSlug,
      buildingBlock: group.buildingBlock,
      page: group.page,
      setIds: group.setIds,
      group,
      descTokens: descriptionTokens(pickGroupDescription(group)),
      docUrls: docUrls(pickGroupDescription(group)),
    });
  }

  // Contains tier: group remaining sets by head-noun (design 2.x).
  // Exclude Building Blocks sets (dot or plain prefix) — they're structural
  // helpers, not design-facing components; the singleton loop handles them
  // (marking buildingBlock so they flow through fuzzy/gap rather than exact).
  const remainingSets = figma.sets.filter((s) => !consumed.has(s.id) && !slugify(s.name).buildingBlock);
  // Pre-compute the set of slugs in remainingSets that will exact-match a CEM
  // tag in the singleton loop. The exact tier requires !leadingDot AND a slug
  // in bySlug (i.e. in cems). A qualifier group whose boundTag slug appears
  // here would create a cemTag collision (bound twice: once exact, once
  // contains), so skip it. Leading-dot sets are excluded because they can't
  // win exact tier even if their slug matches a CEM tag — they pass through to
  // fuzzy/gap and therefore do NOT block a qualifier group.
  const exactMatchSlugs = new Set(
    remainingSets
      .filter((s) => !s.name.startsWith("."))
      .map((s) => slugify(s.name).slug)
      .filter((sl) => cems.some((c) => c.slug === sl))
  );
  const qualGroups = detectQualifierGroups(remainingSets, cems).filter(
    (g) => !exactMatchSlugs.has(normalizeName(g.boundTag))
  );
  for (const g of qualGroups) {
    for (const id of g.setIds) consumed.add(id);
    candidates.push({
      kind: "contains", name: g.base, slug: g.baseSlug, buildingBlock: g.buildingBlock,
      page: g.page, setIds: g.setIds, boundTag: g.boundTag, group: g,
      descTokens: new Set(), docUrls: new Set(),
    });
  }

  for (const set of figma.sets) {
    if (consumed.has(set.id)) continue;
    const { slug, buildingBlock } = slugify(set.name);
    // Leading-dot (.) COMPONENT_SET names are Figma internal building-block
    // utilities (e.g. ".Shape" is a corner-radius token helper, NOT the real
    // shape component). They must NOT win an exact-tier match over the real
    // component (e.g. ".Shape" slug "shape" would beat "Shape Set" slug
    // "shape-set" for m3e-shape if allowed at exact tier). Exclude them from
    // exact tier by flagging them leadingDot:true; they still flow through
    // the fuzzy tier so they can surface in the gap report rather than being
    // silently dropped. No hardcoded node ids — the rule is purely name-based.
    const leadingDot = set.name.startsWith(".");
    candidates.push({
      kind: "set",
      name: set.name,
      slug,
      buildingBlock,
      leadingDot,
      page: set.page,
      setIds: [set.id],
      set,
      descTokens: descriptionTokens(set.description),
      docUrls: docUrls(set.description),
    });
  }

  // Review fix (Important #1): every non-icon standalone COMPONENT is its own
  // singleton candidate, flowing through the same exact→fuzzy→gap tiers as an
  // unconsumed set — architecture §3.4 requires they're never silently
  // dropped, and must appear in the gap report when they have no CEM
  // counterpart. Only the icon-page special case below is exempted (141
  // icons collapse to ONE m3e-icon entry with a per-icon value table, D7).
  for (const standalone of figma.standalones) {
    if (/icon/i.test(standalone.page ?? "")) continue;
    const { slug, buildingBlock } = slugify(standalone.name);
    candidates.push({
      kind: "standalone",
      name: standalone.name,
      slug,
      buildingBlock,
      page: standalone.page,
      setIds: [standalone.id],
      standalone,
      descTokens: descriptionTokens(standalone.description),
      docUrls: docUrls(standalone.description),
    });
  }

  // The icon page: 141 standalone COMPONENTs → ONE logical m3e-icon entry with
  // a per-icon value table, not 141 candidates (D7, evidence #12).
  const iconMembers = figma.standalones.filter((c) => /icon/i.test(c.page ?? ""));
  if (iconMembers.length > 0) {
    const page = iconMembers[0].page;
    candidates.push({
      kind: "icon",
      name: page,
      slug: slugify(page).slug,
      buildingBlock: null,
      page,
      setIds: [],
      iconMembers,
      descTokens: new Set(),
      docUrls: new Set(),
    });
  }

  return candidates;
}

function pickGroupDescription(group) {
  const withDesc = group.members.find((m) => m.set.description);
  return withDesc ? withDesc.set.description : "";
}

// Review fix (Important #2): normalizeName's singular/plural fold can collapse
// two distinct CEM tags onto one slug (m3e-tab / m3e-tabs both fold to "tab").
// Previously the exact tier took `exactHits[0]` — an arbitrary pick driven
// entirely by custom-elements.json declaration order — and the losing tag
// vanished from output entirely. Fix: never tie-break on declaration order.
//   - Structural signal: a Figma COMPONENT_SET (this module's "fusion" and
//     "set" candidate kinds both originate from figma.sets, i.e. a set of
//     variants) structurally IS the plural/container concept; a bare
//     "standalone" COMPONENT has no variant structure and IS the singular/
//     item concept. When the colliding tags form a clean singular/plural
//     pair (one tag === the other + "s" — the same fold singularize() itself
//     performs), prefer the container tag for a set/fusion candidate and the
//     item tag for a standalone candidate.
//   - When no such structural pair exists among the colliding tags, don't
//     guess: downgrade tier/score and emit a rationale that forces human
//     review (D6).
// Returns { component, extraRationale[], downgraded, losers[] } — `losers`
// are the colliding CEM components NOT bound here; the caller must ensure
// they still surface in match() output rather than silently disappearing.
function resolveAmbiguousExact(exactHits, candidate) {
  if (exactHits.length === 1) {
    return { component: exactHits[0], extraRationale: [], downgraded: false, losers: [] };
  }

  const isContainerShaped = candidate.kind === "fusion" || candidate.kind === "set";

  let plural = null;
  let singular = null;
  for (const a of exactHits) {
    for (const b of exactHits) {
      if (a !== b && a.tag === b.tag + "s") {
        plural = a;
        singular = b;
      }
    }
  }

  if (plural && singular) {
    const chosen = isContainerShaped ? plural : singular;
    const loser = isContainerShaped ? singular : plural;
    return {
      component: chosen,
      extraRationale: [
        `structural tiebreak: slug '${candidate.slug}' collides between '${plural.tag}' (plural/container) and ` +
          `'${singular.tag}' (singular/item); Figma entity is a ${
            candidate.kind === "fusion" ? "fusion of COMPONENT_SET siblings" : "COMPONENT_SET"
          } → bound to '${chosen.tag}', leaving '${loser.tag}' as a code-only candidate (not silently dropped)`,
      ],
      downgraded: true, // resolved, but never present as a naive clean score:1 bind
      losers: [loser],
    };
  }

  // No structural signal disambiguates — do not guess; force human review.
  // Ordinal (code-unit) compare — deliberately NOT localeCompare, which is
  // ICU/locale-sensitive and would threaten byte-stability (determinism is
  // a hard gate in this project; shared comparator in ../lib/order.mjs).
  const sorted = [...exactHits].sort(byKey((c) => c.tag));
  return {
    component: sorted[0],
    extraRationale: [
      `ambiguous: ${exactHits.length} CEM tags share slug '${candidate.slug}' (${sorted
        .map((c) => c.tag)
        .join(", ")}) with no structural tiebreak — downgraded for human review (D6)`,
    ],
    downgraded: true,
    losers: sorted.slice(1),
  };
}

// -- top-level match ---------------------------------------------------------

// match(cem, figma, matcherConfig) -> { candidates }
//   candidates: array of { cemTag, figmaSetIds, tier, score, rationale, ... }
//   where the "..." carries kind-specific proposals (axes/properties/fusion/
//   valueTable). Gaps are included with cemTag=null and tier="gap".
//   `matcherConfig` (required, see loadMatcherConfig above) is the design
//   kit's calibration — this function has no brand-specific defaults.
export function match(cem, figma, matcherConfig) {
  if (!matcherConfig) {
    throw new Error(
      "match: matcherConfig is required (load it via loadMatcherConfig(profileDir) — " +
      "the generic matcher has no brand-neutral fallback for kit-specific calibration)"
    );
  }
  const { bySlug, enriched, cems } = indexCem(cem);
  const figmaCandidates = buildFigmaCandidates(figma, cems);
  const results = [];
  // Tags bound to a candidate at exact/fuzzy tier, and tags that lost a slug
  // collision — used after the main loop to guarantee a losing tag from a
  // resolved collision still surfaces (never silently disappears).
  const boundCemTags = new Set();
  const collisionLosers = new Map(); // tag -> component

  for (const candidate of figmaCandidates) {
    let component = null;
    let tier = "gap";
    let score = 0;
    const rationale = [];

    if (candidate.kind === "contains") {
      const hit = bySlug.get(normalizeName(candidate.boundTag));
      component = hit ? hit.find((c) => c.tag === candidate.boundTag) : null;
      if (component) {
        tier = "contains";
        score = 0.95;
        rationale.push(
          `contains tier: set(s) [${candidate.setIds.join(", ")}] contain-match CEM tag '${candidate.boundTag}' ` +
          `(mode ${candidate.group.mode}); qualifier bound as fixed value(s)`
        );
      }
    } else {
      // Tier 1: exact — normalized names equal.
      const exactHits = bySlug.get(candidate.slug);
      if (exactHits && exactHits.length > 0 && !candidate.leadingDot) {
        const resolved = resolveAmbiguousExact(exactHits, candidate);
        component = resolved.component;
        tier = "exact";
        // A clean, unambiguous slug match is score:1. A resolved collision
        // (structural tiebreak OR forced-downgrade) must NOT present as that
        // same clean bind (review fix #2) — score it just below.
        score = resolved.downgraded ? 0.9 : 1;
        rationale.push(`exact tier: normalized name '${candidate.slug}' == CEM tag slug`);
        rationale.push(...resolved.extraRationale);
        for (const loser of resolved.losers) collisionLosers.set(loser.tag, loser);
      } else {
        // Tier 2: fuzzy — best-scoring CEM component above threshold.
        // Skip CEM tags already bound at exact or contains tier — a fuzzy
        // re-bind of the same tag would create a 1:1 cemTag collision that
        // the merge contract prohibits (entriesFromCandidates throws).
        let best = null;
        for (const { component: c } of enriched) {
          if (boundCemTags.has(c.tag)) continue;
          const s = fuzzyScore(candidate, c, matcherConfig);
          if (best === null || s.score > best.s.score) best = { c, s };
        }
        if (best && best.s.score >= matcherConfig.fuzzyAcceptThreshold) {
          component = best.c;
          tier = "fuzzy";
          score = Number(best.s.score.toFixed(3));
          const bits = [`name~${best.s.nameSignal.toFixed(2)}`];
          if (best.s.descSignal > 0) bits.push(`desc-overlap~${best.s.descSignal.toFixed(2)}`);
          if (best.s.urlSignal > 0) bits.push(`shared doc URL ${[...best.s.sharedUrls][0]}`);
          rationale.push(`fuzzy tier: matched '${component.tag}' (score ${score}: ${bits.join(", ")})`);
        }
      }
    }

    if (!component) {
      rationale.push(`gap: no CEM tag matched slug '${candidate.slug}' at exact or fuzzy tier`);
    }

    if (candidate.kind === "fusion") {
      rationale.unshift(
        `page '${candidate.page}': fused ${candidate.setIds.length} sibling sets (bare '${candidate.name}' + ${
          candidate.setIds.length - 1
        } '<Base> - <value>') sharing variant axes [${candidate.group.variantAxes
          .map((a) => a.name)
          .join(", ")}]`
      );
    }

    const result = {
      cemTag: component ? component.tag : null,
      figmaSetIds: candidate.setIds,
      kind: candidate.kind,
      page: candidate.page,
      figmaName: candidate.name,
      buildingBlock: candidate.buildingBlock,
      tier,
      score,
      rationale,
    };

    if (component && (candidate.kind === "fusion" || candidate.kind === "contains")) {
      result.axisProposals = candidate.group.variantAxes.map((axis) => proposeAxis(axis, component, matcherConfig));
      result.fusion = proposeFusionValues(candidate.group, component);
      // SLOT is its own dimension (slots[]/slotProposals), not a props[]
      // catch-all — split it out before calling proposeProperty().
      const fusionSlotProps = candidate.group.nonVariantProps.filter((p) => p.type === "SLOT");
      const fusionOtherProps = candidate.group.nonVariantProps.filter((p) => p.type !== "SLOT");
      result.propertyProposals = fusionOtherProps.map((p) => proposeProperty(p, component));
      result.slotProposals = fusionSlotProps.map((p) => proposeSlot(p, component));
    } else if (component && candidate.kind === "set" && candidate.set.properties) {
      const variantAxes = candidate.set.properties
        .filter((p) => p.type === "VARIANT")
        .map((p) => ({ name: p.displayName, options: p.variantOptions ?? [], defaultValue: p.defaultValue }));
      result.axisProposals = variantAxes.map((axis) => proposeAxis(axis, component, matcherConfig));
      // Same SLOT/other split as the fusion branch above.
      const setNonVariantProps = candidate.set.properties.filter((p) => p.type !== "VARIANT");
      const setSlotProps = setNonVariantProps.filter((p) => p.type === "SLOT");
      const setOtherProps = setNonVariantProps.filter((p) => p.type !== "SLOT");
      result.propertyProposals = setOtherProps.map((p) =>
        proposeProperty({ name: p.displayName, type: p.type, defaultValue: p.defaultValue }, component)
      );
      result.slotProposals = setSlotProps.map((p) =>
        proposeSlot({ name: p.displayName, type: p.type, defaultValue: p.defaultValue }, component)
      );
    }

    if (component && candidate.kind === "icon") {
      result.valueTable = candidate.iconMembers.map((c) => {
        // A Material Symbols ligature IS the raw Figma name with underscores intact
        // — NOT normalizeName(c.name), which singularizes + hyphenates for tag
        // matching and corrupts ligatures (do_not_disturb_on -> do-not-disturb-on,
        // stars -> star). Only the "_filled" suffix is a fill-variant AXIS; _on /
        // _off / _up / _circle etc. are part of the ligature name itself.
        const filled = c.name.endsWith("_filled");
        const value = filled ? c.name.slice(0, -"_filled".length) : c.name;
        return { figmaComponentId: c.id, figmaName: c.name, attribute: "name", value, filled };
      });
      rationale.push(
        `icon page: ${candidate.iconMembers.length} standalone components → one '${component.tag}' entry with a per-icon 'name' value table`
      );
    }

    if (component) boundCemTags.add(component.tag);
    results.push(result);
  }

  // Review fix (Important #2), part 2: a CEM tag that lost a slug collision
  // (e.g. m3e-tab, when the Tabs set bound to m3e-tabs) must not silently
  // disappear from output just because it never won any Figma candidate.
  // Surface it as its own code-only gap candidate.
  for (const tag of collisionLosers.keys()) {
    if (boundCemTags.has(tag)) continue; // it won some OTHER candidate elsewhere
    results.push({
      cemTag: tag,
      figmaSetIds: [],
      kind: "code-only",
      page: null,
      figmaName: tag,
      buildingBlock: null,
      tier: "gap",
      score: 0,
      rationale: [
        `code-only: '${tag}' lost a slug collision to another CEM tag (see the winning candidate's rationale) ` +
          `and has no other Figma counterpart — surfaced here so it is never silently dropped`,
      ],
    });
  }

  // Deterministic order: matched (exact→fuzzy) before gaps, then by figma name.
  // Ordinal (code-unit) compare — deliberately NOT localeCompare, which is
  // ICU/locale-sensitive and would threaten byte-stability (determinism is
  // a hard gate in this project; shared comparator in ../lib/order.mjs).
  const tierRank = { exact: 0, contains: 1, fuzzy: 2, gap: 3 };
  const byFigmaName = byKey((r) => r.figmaName);
  results.sort((a, b) => (tierRank[a.tier] !== tierRank[b.tier] ? tierRank[a.tier] - tierRank[b.tier] : byFigmaName(a, b)));

  return { candidates: results };
}
