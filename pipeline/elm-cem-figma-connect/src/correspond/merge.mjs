// Correspondence schema + human-preserving merge (task A6;
// plans/01-architecture.md §3, "the heart"). Maps src/match/matcher.mjs's
// candidate shape onto src/correspond/schema.json's entry shape, then merges
// fresh auto-proposals with whatever is already checked in — never
// overwriting a human decision.
//
// RECONCILIATION (brief vs. the real matcher, see task-A6-report.md):
//   - matcher.mjs's candidate.kind values are "fusion" | "set" | "standalone"
//     | "icon" | "code-only" — not the brief's "set-fusion"/"iconTable". The
//     schema's own `kind` field is reserved for the iconTable discriminator
//     (verbatim from the brief); the matcher's real kind is preserved as
//     `matcherKind` for traceability so standalone/code-only are never lost.
//   - matcher.mjs never produces axisProposals/propertyProposals for
//     kind:"standalone" (only "fusion" and "set" get them — see matcher.mjs
//     ~line 528). Standalone entries therefore land with axes:[] / props:[].
//     This is a real gap in the matcher's coverage, not a mapping bug here;
//     flagged in the report rather than silently working around it.
//   - "gap" tier normally means a Figma-side entity with no CEM tag
//     (cemTag:null) — those are Figma-only gaps and belong in the gap report
//     (Plan A7), not correspondence.json (whose primary key IS cemTag).
//     matcher.mjs's one documented exception is kind:"code-only": a real CEM
//     tag, tier:"gap", cemTag non-null (it lost a slug collision or simply
//     has zero Figma presence). Per the brief ("accommodate ... code-only ...
//     don't lose them") these DO get a correspondence entry — with
//     figmaSets:[] and a new provenance value, "auto-gap" (not in the
//     brief's literal enum; documented in schema.json).
//
// Zero deps beyond the sibling matcher + the ingest loaders' output shapes
// (this module does not re-run matching logic, per the task brief).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { match, loadMatcherConfig } from "../match/matcher.mjs";
import { validate } from "../lib/validate.mjs";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");
const SCHEMA_PATH = path.join(here, "schema.json");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

// Ordinal (code-unit) comparison — deliberately NOT localeCompare, which is
// ICU/locale-sensitive and would threaten the byte-stability guarantee
// (determinism is a hard gate in this project; see task-A6-report.md).
// Shared comparator lives in ../lib/order.mjs.
const byCemTag = byKey((e) => e.cemTag);

function loadSchema() {
  return readJson(SCHEMA_PATH);
}

// -- candidate -> entry mapping ----------------------------------------------

const PROP_KIND = { TEXT: "text", BOOLEAN: "boolean", INSTANCE_SWAP: "instanceSwap" };

function propKind(type) {
  return PROP_KIND[type] ?? type.toLowerCase();
}

// tier "exact"/"fuzzy" mean a real bind; the one non-obvious case is
// kind:"code-only", which is ALSO tier:"gap" but carries a real cemTag (see
// module-doc reconciliation above) — this gets its own provenance value
// rather than a misrepresenting auto-exact/auto-fuzzy.
function provenanceFor(candidate) {
  if (candidate.tier === "exact") return "auto-exact";
  if (candidate.tier === "fuzzy") return "auto-fuzzy";
  if (candidate.tier === "contains") return "auto-contains";
  return "auto-gap";
}

// Builds a nodeId -> name lookup covering every set and standalone the
// figma-export loader produced, so fusion members (whose sibling names
// aren't otherwise carried on the candidate) can be labeled.
function buildNodeIndex(figma) {
  const index = new Map();
  for (const set of figma.sets) index.set(set.id, set.name);
  for (const standalone of figma.standalones) index.set(standalone.id, standalone.name);
  return index;
}

// Per-set fixed attr map from a fusion candidate's resolved values, e.g.
// { "58651:11237": { variant: "tonal" } }. Sets whose value the matcher could
// NOT resolve to a CEM enum member (cemValue: null) contribute {} rather than
// a half-formed binding.
function fixedAttrsBySetId(candidate) {
  const bySetId = new Map();
  if (candidate.fusion) {
    for (const fv of candidate.fusion.fixedValues) {
      bySetId.set(fv.setId, fv.cemValue != null ? { [fv.attribute]: fv.cemValue } : {});
    }
  }
  return bySetId;
}

function buildFigmaSets(candidate, nodeIndex) {
  const fixedBySetId = fixedAttrsBySetId(candidate);
  return candidate.figmaSetIds.map((nodeId) => ({
    nodeId,
    setName: nodeIndex.get(nodeId) ?? candidate.figmaName,
    fixedAttrs: fixedBySetId.get(nodeId) ?? {},
  }));
}

function buildAxes(candidate) {
  return (candidate.axisProposals ?? []).map((axis) => {
    if (!axis.mapped) return { figmaProp: axis.axis, unmapped: axis.reason };
    // MULTI-ATTR axis (kind:"multi-boolean"): attrs[] carries per-attr {attr, valueMap}.
    if (axis.kind === "multi-boolean") {
      return {
        figmaProp: axis.axis,
        kind: "multi-boolean",
        attrs: axis.attrs.map(({ attr, valueMap }) => ({
          attr,
          valueMap,
        })),
      };
    }
    // Single-attr axis (enum or boolean):
    return {
      figmaProp: axis.axis,
      attr: axis.attribute,
      // A boolean axis (RC1) carries kind:"boolean" so drive.mjs applies HTML
      // boolean-attribute presence semantics (present=on / absent=off) rather
      // than writing the literal string value. Enum axes omit kind.
      ...(axis.attributeKind ? { kind: axis.attributeKind } : {}),
      valueMap: Object.fromEntries(axis.valueMap.map((v) => [v.figma, v.cem])),
    };
  });
}

function buildProps(candidate) {
  return (candidate.propertyProposals ?? []).map((prop) =>
    prop.mapped
      ? {
          figmaProp: prop.property,
          kind: propKind(prop.type),
          binding: prop.target === "slot:(default)" ? "content" : prop.target,
        }
      : { figmaProp: prop.property, kind: propKind(prop.type), unmapped: prop.reason }
  );
}

// method ("exact"|"synonym"|"fuzzy") -> per-slot provenance tier. Same
// three-way subset of the entry-level provenance enum (see schema.json's
// slots[].provenance $comment) — "synonym" folds into "auto-exact" since
// bestValueMatch ranks it alongside exact for tie-breaking purposes.
// proposeSlot's own default-slot fallback (matcher.mjs, generic-content
// heuristic — "Content"/"Content (standard)" etc. with no named-slot match)
// reports method:"fuzzy" (final-review finding #2: it's a regex-based name
// heuristic, not a verified name-identity match, so it must NOT fold into
// "auto-exact" the way a real name match does) — every method value
// proposeSlot can produce is listed; an unrecognized one is a real bug
// upstream, never silently mis-tiered.
const SLOT_PROVENANCE = { exact: "auto-exact", synonym: "auto-exact", fuzzy: "auto-fuzzy" };

function slotProvenance(method) {
  const provenance = SLOT_PROVENANCE[method];
  if (!provenance) {
    throw new Error(
      `buildSlots: unrecognized slot-match method '${method}' — expected one of ${Object.keys(SLOT_PROVENANCE).join(", ")} (proposeSlot/bestValueMatch contract violation)`
    );
  }
  return provenance;
}

function buildSlots(candidate) {
  return (candidate.slotProposals ?? []).map((slot) =>
    slot.mapped
      ? {
          figmaSlotName: slot.property,
          kind: "slot",
          // Slot multiplicity is a documented gap, not an oversight: this
          // package's CEM-facts input carries no slot-multiplicity data, so
          // every slot is conservatively reported single (multi:false) until
          // that data exists upstream.
          multi: false,
          mappedTo: slot.target,
          provenance: slotProvenance(slot.method),
        }
      : { figmaSlotName: slot.property, kind: "slot", multi: false, unmapped: slot.reason, provenance: "auto-gap" }
  );
}

function joinedRationale(candidate) {
  const parts = [...candidate.rationale];
  if (candidate.fusion?.rationale) parts.push(candidate.fusion.rationale);
  return parts.join(" | ");
}

function buildComponentEntry(candidate, nodeIndex) {
  const slots = buildSlots(candidate);
  return {
    cemTag: candidate.cemTag,
    matcherKind: candidate.kind,
    figmaSets: buildFigmaSets(candidate, nodeIndex),
    axes: buildAxes(candidate),
    props: buildProps(candidate),
    // `slots` is omitted entirely (rather than emitted as `[]`) when a
    // candidate has no SLOT-typed Figma properties at all — unlike
    // axes/props, which predate this field and are always arrays on every
    // stored entry. The real m3-kit profile's checked-in correspondence.json
    // was written before SLOT support existed and has ZERO `slots` fields;
    // always emitting `slots: []` here would inject a new key into every
    // confirmed/drifted entry's `proposedUpdate` (and non-protected
    // entries' own top-level shape), breaking byte-stability against that
    // committed file for a change that adds no real slot data (see A8
    // tracer acceptance test). Schema.json's `slots` field is optional for
    // exactly this reason.
    ...(slots.length > 0 ? { slots } : {}),
    confidence: candidate.score,
    provenance: provenanceFor(candidate),
    rationale: joinedRationale(candidate),
    status: "proposed",
  };
}

function buildIconEntry(candidate) {
  return {
    kind: "iconTable",
    cemTag: candidate.cemTag,
    icons: candidate.valueTable.map((row) => ({
      figmaNodeId: row.figmaComponentId,
      figmaName: row.figmaName,
      symbolName: row.value,
      filled: row.filled ?? false,
    })),
    confidence: candidate.score,
    provenance: provenanceFor(candidate),
    rationale: joinedRationale(candidate),
    status: "proposed",
  };
}

// Identifies a candidate's Figma-side origin for a collision error message —
// the figmaSetIds it bound (component/set/fusion) or, for an icon table, the
// page name (icon tables have no figmaSetIds of their own).
function figmaIdentity(candidate) {
  if (candidate.kind === "icon") return `icon page '${candidate.page}' (${candidate.figmaName})`;
  const ids = candidate.figmaSetIds.length > 0 ? candidate.figmaSetIds.join(",") : "(no sets)";
  return `${candidate.kind} '${candidate.figmaName}' [${ids}]`;
}

// entriesFromCandidates(candidates, figma) -> entries[]
//
// The candidates -> entries assembly buildProposals() runs on a live match()
// call, factored out so it can be exercised directly with synthetic
// candidates (see test/correspond.test.mjs's collision test) without
// fabricating a whole cem/figma fixture pair that reproduces a collision.
//
// Fail-loud on collision: if the matcher ever emits two candidates bound to
// the SAME non-null cemTag (e.g. a fuzzy hit landing on a tag already
// exact-bound, or two distinct Figma concepts folding to one tag), silently
// keying them into a Map by cemTag would keep only the last and drop the
// other's figmaSets with no error. That is a matcher/merge contract
// violation, not a mergeable ambiguity — surfaced here as a thrown error
// naming the colliding tag and both candidates' Figma identities, never
// swallowed. (Not observed on the current m3-kit fixture: 27 distinct tags,
// 0 collisions.)
export function entriesFromCandidates(candidates, figma) {
  const nodeIndex = buildNodeIndex(figma);

  const entries = [];
  const seenBy = new Map(); // cemTag -> source candidate, for collision reporting
  for (const candidate of candidates) {
    if (candidate.cemTag === null) continue;

    const prior = seenBy.get(candidate.cemTag);
    if (prior) {
      throw new Error(
        `buildProposals: two candidates bound the same cemTag '${candidate.cemTag}' — ` +
          `${figmaIdentity(prior)} and ${figmaIdentity(candidate)}. This is a matcher/merge ` +
          `contract violation (candidates must partition cemTags 1:1); refusing to silently ` +
          `collapse one into the other.`
      );
    }
    seenBy.set(candidate.cemTag, candidate);

    entries.push(
      candidate.kind === "icon" ? buildIconEntry(candidate) : buildComponentEntry(candidate, nodeIndex)
    );
  }

  entries.sort(byCemTag);
  return entries;
}

// buildProposals(cem, figma, matcherConfig) -> entries[]
//
// Runs the matcher fresh and maps every candidate that carries a real cemTag
// onto a correspondence entry. Candidates with cemTag:null are Figma-side
// gaps (a drawn component with no CEM counterpart) — they belong in the gap
// report (Plan A7), never in correspondence.json, whose primary key is
// cemTag. Deterministic: sorted by cemTag so re-runs diff cleanly. See
// entriesFromCandidates() above for the fail-loud collision contract.
// `matcherConfig` is required (see matcher.mjs's loadMatcherConfig) — this
// function does not default it, so a caller forgetting to load a profile's
// matcher.json fails loud instead of silently reusing whatever kit happened
// to run last.
export function buildProposals(cem, figma, matcherConfig) {
  const { candidates } = match(cem, figma, matcherConfig);
  return entriesFromCandidates(candidates, figma);
}

// -- human-preserving merge ---------------------------------------------------

// Fields compared to decide whether a fresh proposal actually differs from
// what's on disk — deliberately excludes status/provenance/proposedUpdate,
// which always differ between a stored human/confirmed entry and a freshly
// generated proposal (every fresh proposal is status:"proposed").
const SUBSTANTIVE_FIELDS = [
  "cemTag",
  "kind",
  "matcherKind",
  "figmaSets",
  "axes",
  "props",
  "slots",
  "icons",
  "confidence",
  "rationale",
];

// Human-annotation fields on prop items that the auto-matcher never generates.
// Excluded from drift detection so a protected entry with these annotations
// does not get a spurious proposedUpdate when the fresh proposal lacks them.
// (RC2 chip Configuration→slot-visibility: visibilityAxis / visibleWhen are
// authored here by the lead after confirmation, not auto-generated.)
const PROP_ANNOTATION_FIELDS = new Set(["visibilityAxis", "visibleWhen"]);

function substantiveView(entry) {
  const view = {};
  for (const key of SUBSTANTIVE_FIELDS) {
    if (!(key in entry)) continue;
    if (key === "props" && Array.isArray(entry.props)) {
      // Strip human-annotation fields from each prop item before comparing,
      // so a protected entry's visibilityAxis/visibleWhen additions don't
      // register as "drift" vs. a fresh auto-proposal that lacks them.
      view.props = entry.props.map((p) => {
        const stripped = {};
        for (const [k, v] of Object.entries(p)) {
          if (!PROP_ANNOTATION_FIELDS.has(k)) stripped[k] = v;
        }
        return stripped;
      });
    } else {
      view[key] = entry[key];
    }
  }
  return view;
}

function isProtected(entry) {
  return entry.provenance === "human" || entry.status === "confirmed";
}

// mergeCorrespondence(existingEntries, proposedEntries) -> entries[]
//
// - No existing entry for a cemTag: the fresh proposal is added as-is.
// - Existing entry NOT protected (auto provenance, not confirmed): replaced
//   by the fresh proposal outright — nothing to preserve.
// - Existing entry protected (provenance:"human" OR status:"confirmed"):
//   NEVER modified. If the fresh proposal's substantive data differs, it
//   lands alongside as `proposedUpdate`; if it doesn't differ, the entry is
//   returned untouched (no-op `proposedUpdate` churn on repeat runs).
// - Proposed has no matching cemTag anymore (the matcher stopped producing
//   it — e.g. a Figma set was deleted upstream): the existing entry is kept
//   as-is. Deletion is a human action, never an automatic side effect of
//   re-running match.
//
// Deterministic: sorted by cemTag.
export function mergeCorrespondence(existingEntries, proposedEntries) {
  const existingByTag = new Map(existingEntries.map((e) => [e.cemTag, e]));
  const proposedByTag = new Map(proposedEntries.map((e) => [e.cemTag, e]));
  const tags = new Set([...existingByTag.keys(), ...proposedByTag.keys()]);

  const merged = [];
  for (const tag of tags) {
    const existing = existingByTag.get(tag);
    const proposed = proposedByTag.get(tag);

    if (!existing) {
      merged.push(proposed);
      continue;
    }
    if (!proposed) {
      merged.push(existing);
      continue;
    }

    if (!isProtected(existing)) {
      merged.push(proposed);
      continue;
    }

    const changed = JSON.stringify(substantiveView(proposed)) !== JSON.stringify(substantiveView(existing));
    if (!changed) {
      merged.push(existing);
      continue;
    }
    const { proposedUpdate: _ignored, ...proposedCore } = proposed;
    merged.push({ ...existing, proposedUpdate: proposedCore });
  }

  merged.sort(byCemTag);
  return merged;
}

// -- delta overlay (add | override | suppress) --------------------------------
//
// Consumer profiles (Plan F) overlay the base correspondence with deltas per
// cemTag WITHOUT mutating the stored entries — suppression removes a tag
// from the *emit set* only; the entry stays in correspondence.json so a
// later un-suppress doesn't need to regenerate anything.
//
// delta shape: { cemTag, action: "add"|"override"|"suppress", entry? }
//   - add:      entry (a whole new correspondence-shaped entry) is appended,
//               unless also suppressed.
//   - override: shallow-merges `entry`'s fields onto the base entry, for
//               emission only.
//   - suppress: the cemTag is dropped from the returned emit set.
export function computeEmitSet(entries, deltas = []) {
  const suppressed = new Set(deltas.filter((d) => d.action === "suppress").map((d) => d.cemTag));
  const overrides = new Map(
    deltas.filter((d) => d.action === "override").map((d) => [d.cemTag, d.entry])
  );
  const additions = deltas.filter((d) => d.action === "add").map((d) => d.entry);

  const emit = [];
  for (const entry of entries) {
    if (suppressed.has(entry.cemTag)) continue;
    const override = overrides.get(entry.cemTag);
    emit.push(override ? { ...entry, ...override } : entry);
  }
  for (const add of additions) {
    if (!suppressed.has(add.cemTag)) emit.push(add);
  }

  emit.sort(byCemTag);
  return emit;
}

// -- manual-correspondence: validate + apply ----------------------------------
//
// A LOCAL escape hatch for cemTags the matcher structurally cannot reach
// (e.g. m3e-tab: the "tab" slug is an exactMatchSlug, consumed by m3e-tabs).
// Only affects named cemTags; all other entries remain byte-identical.
//
// Design constraints:
//   - ONLY applies to UNBOUND entries (matcherKind:"code-only" or
//     provenance:"auto-gap" — i.e. no real figma match from the matcher).
//   - THROWS (fail-loud) if the target entry is already real-matched
//     (status:"confirmed" OR figmaSets non-empty from a real matcher tier).
//     Manual entries must NEVER mask a real match.
//   - Find-and-replace IN PLACE: sort position in the array is preserved.
//   - Deterministic: the output is the same for the same inputs.

// validateManualCorrespondence(manual, { cem, figma }) -> void | throws.
//
// Checks: (a) every cemTag is a real CEM tag; (b) every nodeId exists as a
// COMPONENT_SET in figma.data.components; (c) each setName matches that
// node's actual name. For appendSets entries, validates in the same way
// (nodeId/setName). Throws clear messages on the first violation found.
//
// `cem` accepts EITHER the real loadCem() output shape ({ components: [...] })
// OR a test-synthetic shape ({ tags: Set<string> }) — both are handled.
export function validateManualCorrespondence(manual, { cem, figma }) {
  // Derive a Set<string> of CEM tags regardless of input shape.
  const cemTags =
    cem.tags instanceof Set
      ? cem.tags
      : new Set((cem.components ?? []).map((c) => c.tag));

  const componentById = new Map(
    (figma.data.components ?? []).map((c) => [c.id, c])
  );

  for (const [cemTag, entry] of Object.entries(manual)) {
    if (!cemTags.has(cemTag)) {
      throw new Error(
        `manual-correspondence.json: '${cemTag}' is not a CEM tag (not found in the CEM manifest)`
      );
    }
    for (const { nodeId, setName } of entry.figmaSets ?? []) {
      const node = componentById.get(nodeId);
      if (!node) {
        throw new Error(
          `manual-correspondence.json: nodeId '${nodeId}' (in figmaSets for '${cemTag}') does not exist in the figma export`
        );
      }
      if (node.type !== "COMPONENT_SET" && node.type !== "COMPONENT") {
        throw new Error(
          `manual-correspondence.json: nodeId '${nodeId}' (for '${cemTag}') is type '${node.type}', not a COMPONENT_SET or COMPONENT`
        );
      }
      if (node.name !== setName) {
        throw new Error(
          `manual-correspondence.json: setName '${setName}' does not match figma export name '${node.name}' for nodeId '${nodeId}' (cemTag '${cemTag}')`
        );
      }
    }
    // setExamples: content-only overlay onto an ALREADY-BOUND entry's EXISTING
    // sets (Phase 3.1, plans/2026-08-17-figma-elm-config-integration-design.md).
    // Unlike figmaSets/appendSets, this never touches matcherKind/provenance/
    // fixedAttrs/axes/props — it exists for exactly the case appendSets and
    // the figmaSets-replace path both refuse: a component the matcher ALREADY
    // bound correctly (real auto candidate, e.g. contains-tier), where only
    // the per-set representative EXAMPLE needs authoring (the single
    // cemTag-level examples.json entry can't fit two structurally different
    // nodes — see m3e-card). Only nodeId is validated here (existence +
    // COMPONENT/COMPONENT_SET type); the entry-bound / nodeId-belongs-to-entry
    // checks happen at merge time (applySetExamples), where the entry set is
    // known.
    for (const { nodeId } of entry.setExamples ?? []) {
      const node = componentById.get(nodeId);
      if (!node) {
        throw new Error(
          `manual-correspondence.json: setExamples nodeId '${nodeId}' (for '${cemTag}') does not exist in the figma export`
        );
      }
      if (node.type !== "COMPONENT_SET" && node.type !== "COMPONENT") {
        throw new Error(
          `manual-correspondence.json: setExamples nodeId '${nodeId}' (for '${cemTag}') is type '${node.type}', not a COMPONENT_SET or COMPONENT`
        );
      }
    }
    // appendSets: validate each appended set's nodeId/setName against the
    // figma export, exactly as with figmaSets above.
    for (const { nodeId, setName } of entry.appendSets ?? []) {
      const node = componentById.get(nodeId);
      if (!node) {
        throw new Error(
          `manual-correspondence.json: appendSets nodeId '${nodeId}' (for '${cemTag}') does not exist in the figma export`
        );
      }
      if (node.type !== "COMPONENT_SET" && node.type !== "COMPONENT") {
        throw new Error(
          `manual-correspondence.json: appendSets nodeId '${nodeId}' (for '${cemTag}') is type '${node.type}', not a COMPONENT_SET or COMPONENT`
        );
      }
      if (node.name !== setName) {
        throw new Error(
          `manual-correspondence.json: appendSets setName '${setName}' does not match figma export name '${node.name}' for nodeId '${nodeId}' (cemTag '${cemTag}')`
        );
      }
    }
  }
}

// isUnbound(entry) -> true if the entry has no real figma match from the
// matcher — i.e. it is safe for a manual entry to replace it.
function isUnbound(entry) {
  // code-only + auto-gap are the two forms of "no real figma match"
  if (entry.matcherKind === "code-only") return true;
  if (entry.provenance === "auto-gap") return true;
  // A confirmed/human entry is always bound (isProtected covers this too)
  if (entry.status === "confirmed" || entry.provenance === "human") return false;
  // A proposed entry with non-empty figmaSets from the real matcher is bound
  if (Array.isArray(entry.figmaSets) && entry.figmaSets.length > 0) return false;
  return true;
}

// toAppendedFigmaSet(appendSet) -> figmaSet object.
// Shared by applyManualCorrespondence (proposed side) and applyManualToExisting
// (stored side) so both build byte-identical objects — key order matters for the
// JSON.stringify byte-stability comparison in mergeCorrespondence.
// applySetExamplesToEntry(entry, setExamples, cemTag) -> entry with `.example`
// attached to each named figmaSet, by nodeId. Phase 3.1
// (plans/2026-08-17-figma-elm-config-integration-design.md §"core question"
// verdict, extended per the m3e-card case it flagged): content-only overlay
// onto sets the entry ALREADY has (whatever bound them — auto match or
// manual) — never touches matcherKind/provenance/fixedAttrs/axes/props, so a
// real auto-matched entry (e.g. m3e-card's contains-tier fusion) can gain
// per-set representative examples without losing its matcher-derived
// axes/props or being relabeled "manual".
//
// `cemTag` (used only for the error message) selects strict vs. lenient
// behavior: non-null -> throws if any setExamples nodeId isn't among the
// entry's actual figmaSets (proposed/strict side, applyManualCorrespondence
// — a typo'd nodeId should fail loud, not silently no-op forever); `null` ->
// never throws (existing-side, applyManualToExisting — same
// idempotent-on-a-stale-tree discipline as appendSets there).
function applySetExamplesToEntry(entry, setExamples, cemTag) {
  if (!setExamples?.length || !Array.isArray(entry.figmaSets) || entry.figmaSets.length === 0) {
    return entry;
  }
  const byNodeId = new Map(setExamples.map((s) => [s.nodeId, s.example]));
  let changed = false;
  const figmaSets = entry.figmaSets.map((set) => {
    if (!byNodeId.has(set.nodeId)) return set;
    changed = true;
    return { ...set, example: byNodeId.get(set.nodeId) };
  });
  if (cemTag !== null) {
    for (const { nodeId } of setExamples) {
      if (!entry.figmaSets.some((s) => s.nodeId === nodeId)) {
        throw new Error(
          `setExamples: nodeId '${nodeId}' (for '${cemTag}') is not among '${cemTag}'s existing figmaSets — bind it first via figmaSets/appendSets`
        );
      }
    }
  }
  return changed ? { ...entry, figmaSets } : entry;
}

function toAppendedFigmaSet(appendSet) {
  return {
    nodeId: appendSet.nodeId,
    setName: appendSet.setName,
    fixedAttrs: appendSet.fixedAttrs ?? {},
    ...(appendSet.slugSuffix !== undefined ? { slugSuffix: appendSet.slugSuffix } : {}),
    ...(appendSet.example !== undefined ? { example: appendSet.example } : {}),
  };
}

// applyManualCorrespondence(entries, manual) -> entries[]
//
// For each cemTag in `manual`:
//   - If the entry has `appendSets` (the 2nd-set mechanism):
//     - The cemTag MUST already exist in entries AND be bound (figmaSets.length >= 1).
//       Throws if absent or unbound — appendSets is not a gap-filling mechanism.
//     - Each appendSet's nodeId MUST NOT already be present in the entry's figmaSets.
//     - Appends each appendSet as a figmaSet object to the END of figmaSets.
//     - The entry's other fields (axes, props, status, provenance, etc.) are preserved.
//   - Otherwise (existing figmaSets/synthesize path):
//     - Finds the current entry in `entries` (by cemTag).
//     - Asserts it is UNBOUND (throws if already matched).
//     - Replaces it in-place with the manual shape, preserving sort position.
// Entries not named in `manual` are returned byte-identical.
// `manual` is the parsed manual-correspondence.json object.
export function applyManualCorrespondence(entries, manual) {
  if (!manual || Object.keys(manual).length === 0) return entries;

  const result = [...entries];
  for (const [cemTag, manualEntry] of Object.entries(manual)) {
    // -- appendSets path: add to an already-bound entry -----------------------
    if (manualEntry.appendSets && manualEntry.appendSets.length > 0) {
      const idx = result.findIndex((e) => e.cemTag === cemTag);
      if (idx === -1) {
        throw new Error(
          `appendSets: '${cemTag}' is not an existing bound entry — use figmaSets for a gap, appendSets adds to a confirmed component`
        );
      }
      const existing = result[idx];
      if (!Array.isArray(existing.figmaSets) || existing.figmaSets.length === 0) {
        throw new Error(
          `appendSets: '${cemTag}' is not an existing bound entry — use figmaSets for a gap, appendSets adds to a confirmed component`
        );
      }
      const existingNodeIds = new Set(existing.figmaSets.map((s) => s.nodeId));
      const appendedFigmaSets = [];
      for (const appendSet of manualEntry.appendSets) {
        if (existingNodeIds.has(appendSet.nodeId)) {
          throw new Error(
            `appendSets: nodeId '${appendSet.nodeId}' already present on '${cemTag}'`
          );
        }
        existingNodeIds.add(appendSet.nodeId);
        appendedFigmaSets.push(toAppendedFigmaSet(appendSet));
      }
      result[idx] = {
        ...existing,
        figmaSets: [...existing.figmaSets, ...appendedFigmaSets],
      };
      if (manualEntry.setExamples?.length) {
        result[idx] = applySetExamplesToEntry(result[idx], manualEntry.setExamples, cemTag);
      }
      continue;
    }

    // -- setExamples-only path: content overlay onto an ALREADY-BOUND entry
    // (whatever bound it — real auto match or a prior manual entry), no
    // rebinding. See applySetExamplesToEntry's header for the full rationale.
    if (manualEntry.setExamples?.length && !manualEntry.figmaSets) {
      const idx = result.findIndex((e) => e.cemTag === cemTag);
      if (idx === -1 || !Array.isArray(result[idx].figmaSets) || result[idx].figmaSets.length === 0) {
        throw new Error(
          `setExamples: '${cemTag}' is not an existing bound entry — setExamples overlays an already-matched component, use figmaSets for a gap`
        );
      }
      result[idx] = applySetExamplesToEntry(result[idx], manualEntry.setExamples, cemTag);
      continue;
    }

    // -- existing figmaSets / synthesize / replace path -----------------------
    const idx = result.findIndex((e) => e.cemTag === cemTag);
    if (idx === -1) {
      // cemTag from manual-correspondence.json has no candidate from the matcher
      // at all (not a collision-loser, not matched — truly absent). Synthesize a
      // new entry and append it; mergeCorrespondence will sort it into place.
      // validateManualCorrespondence has already confirmed the tag is a real CEM
      // tag and the nodeId is a real COMPONENT_SET.
      result.push({
        cemTag,
        matcherKind: "manual",
        figmaSets: manualEntry.figmaSets ?? [],
        // Path-1 (manual axis/prop authoring): a manual entry MAY carry explicit
        // axes/props (same shape the matcher produces) so a matcher-unreachable
        // component still emits variant-driven getEnum bindings, not just a
        // fixed representative snippet. Default [] (representative-only) when
        // the author didn't provide them.
        axes: manualEntry.axes ?? [],
        props: manualEntry.props ?? [],
        confidence: 0.9,
        provenance: "manual",
        rationale: `manual-correspondence: ${manualEntry.note ?? ""}`.trimEnd(),
        status: "proposed",
      });
      continue;
    }
    const existing = result[idx];
    if (!isUnbound(existing)) {
      throw new Error(
        `manual-correspondence: '${cemTag}' is already matched by the matcher — refusing to override a real match ` +
          `(status:'${existing.status}', matcherKind:'${existing.matcherKind}', provenance:'${existing.provenance}')`
      );
    }
    result[idx] = {
      cemTag,
      matcherKind: "manual",
      figmaSets: manualEntry.figmaSets ?? [],
      axes: manualEntry.axes ?? [], // path-1 manual axes (see synthesize path above)
      props: manualEntry.props ?? [],
      confidence: 0.9,
      provenance: "manual",
      rationale: `manual-correspondence: ${manualEntry.note ?? ""}`.trimEnd(),
      status: "proposed",
    };
  }
  return result;
}

// applyManualToExisting(existing, manual) -> entries[]
//
// Mirror manual-correspondence onto the ALREADY-STORED entries so a manual
// change to a confirmed entry (a 2nd set via appendSets, or an extended manual
// figmaSets list) is applied to BOTH mergeCorrespondence inputs. Otherwise the
// merge sees it as auto-drift against the protected entry and parks it in
// `proposedUpdate` instead of landing it live. Manual config is an explicit
// human decision; symmetric application lands it live AND keeps re-match
// byte-stable (proposed and existing then agree, so the merge is a no-op).
//
// Idempotent + confirmed-safe: never throws (unlike applyManualCorrespondence,
// which authoritatively guards the proposed side). On a re-run the appended
// sets are already present, so it is a no-op.
export function applyManualToExisting(existing, manual) {
  if (!manual || Object.keys(manual).length === 0) return existing;
  return existing.map((entry) => {
    const manualEntry = manual[entry.cemTag];
    if (!manualEntry) return entry;

    // appendSets: add any sets not already on the (bound) entry.
    if (
      manualEntry.appendSets?.length &&
      Array.isArray(entry.figmaSets) &&
      entry.figmaSets.length > 0
    ) {
      const present = new Set(entry.figmaSets.map((s) => s.nodeId));
      const toAdd = manualEntry.appendSets
        .filter((s) => !present.has(s.nodeId))
        .map(toAppendedFigmaSet);
      const appended = toAdd.length > 0 ? { ...entry, figmaSets: [...entry.figmaSets, ...toAdd] } : entry;
      return applySetExamplesToEntry(appended, manualEntry.setExamples, null);
    }

    // setExamples-only: content overlay onto an already-bound entry, no
    // rebinding — the existing-side mirror of applyManualCorrespondence's
    // setExamples-only path above (see applySetExamplesToEntry's header).
    // Lenient (never throws) like the rest of this function.
    if (manualEntry.setExamples?.length && !manualEntry.figmaSets) {
      return applySetExamplesToEntry(entry, manualEntry.setExamples, null);
    }

    // figmaSets: a manual list is the full desired set for that tag; adopt it.
    // Path-1: also adopt explicit manual axes/props onto the confirmed entry so
    // they land LIVE (not parked in proposedUpdate) — mirrors the proposed side
    // in applyManualCorrespondence, keeping re-match byte-stable.
    if (manualEntry.figmaSets) {
      const replaced = {
        ...entry,
        figmaSets: manualEntry.figmaSets,
        ...(manualEntry.axes !== undefined ? { axes: manualEntry.axes } : {}),
        ...(manualEntry.props !== undefined ? { props: manualEntry.props } : {}),
      };
      return applySetExamplesToEntry(replaced, manualEntry.setExamples, null);
    }

    return entry;
  });
}

// -- schema-validated I/O ------------------------------------------------------

export function validateEntries(entries) {
  const schema = loadSchema();
  const { valid, errors } = validate(schema, entries);
  if (!valid) {
    throw new Error(`Invalid correspondence entries:\n${errors.join("\n")}`);
  }
}

export function readCorrespondence(correspondencePath) {
  if (!fs.existsSync(correspondencePath)) return [];
  return readJson(correspondencePath);
}

// Deterministic, schema-validated write: sorted by cemTag, 2-space indent,
// trailing newline (byte-stable across re-runs given unchanged inputs).
export function writeCorrespondence(correspondencePath, entries) {
  const sorted = [...entries].sort(byCemTag);
  validateEntries(sorted);
  fs.mkdirSync(path.dirname(correspondencePath), { recursive: true });
  fs.writeFileSync(correspondencePath, `${JSON.stringify(sorted, null, 2)}\n`, "utf8");
  return sorted;
}

// -- profile loading + the `match` command ------------------------------------

// loadProfile(profileDir) -> { fileKey, kitVersionTag, figmaExportPath,
//   cemManifestPath, cemDtsDir, cem: {package, version}, emitters, htmlLabel,
//   raw }
// `htmlLabel` (task B1) is the html-label emitter's own minimal config
// ({imports, iconPlaceholder}) — deliberately separate from `emitters`,
// which stays reserved for Task B2's run.mjs dispatch/registration shape.
//
// Paths in profile.json are relative to the REPO ROOT (not profileDir, not
// process.cwd()) — resolved here so the CLI works regardless of invocation
// directory.
export function loadProfile(profileDir) {
  const profilePath = path.join(profileDir, "profile.json");
  const raw = readJson(profilePath);
  const resolve = (p) => (p ? path.resolve(repoRoot, p) : p);
  // Optional per-component representative example content (by-example banking).
  // Missing file -> {} (backward-compatible; profiles without it are unaffected).
  const examplesPath = path.join(profileDir, "examples.json");
  const examples = fs.existsSync(examplesPath) ? JSON.parse(fs.readFileSync(examplesPath, "utf8")) : {};

  // Optional per-set static attribute injection (set-attrs.json).
  // Missing file -> {} (backward-compatible; profiles without it are unaffected).
  const setAttrsPath = path.join(profileDir, "set-attrs.json");
  const setAttrs = fs.existsSync(setAttrsPath) ? JSON.parse(fs.readFileSync(setAttrsPath, "utf8")) : {};

  // Optional manual-correspondence injection (manual-correspondence.json).
  // Missing file -> {} (backward-compatible; profiles without it are unaffected).
  const manualCorrespondencePath = path.join(profileDir, "manual-correspondence.json");
  const manualCorrespondence = fs.existsSync(manualCorrespondencePath)
    ? JSON.parse(fs.readFileSync(manualCorrespondencePath, "utf8"))
    : {};

  // Required — the generic matcher has no brand-neutral fallback for kit
  // calibration (finding 2.4), so a profile missing matcher.json fails loud
  // here rather than the matcher silently borrowing another kit's numbers.
  const matcherConfig = loadMatcherConfig(profileDir);

  return {
    fileKey: raw.fileKey,
    kitVersionTag: raw.kitVersionTag,
    figmaExportPath: resolve(raw.figmaExportPath),
    cemManifestPath: resolve(raw.cem?.manifestPath),
    cemDtsDir: resolve(raw.cem?.dtsDir),
    cem: raw.cem,
    emitters: raw.emitters ?? [],
    htmlLabel: raw.htmlLabel ?? {},
    matcherConfig,
    examples,
    setAttrs,
    manualCorrespondence,
    raw,
  };
}

// runMatch({ profileDir, correspondencePath, loadCem, loadFigmaExport }) ->
// entries[]. `correspondencePath` defaults to profileDir/correspondence.json
// but is overridable so tests never write into a checked-in profile dir.
// `loadCem`/`loadFigmaExport` are injected (rather than imported directly)
// so this stays a thin, testable orchestration layer over the real ingest
// loaders.
export function runMatch({ profileDir, correspondencePath, loadCem, loadFigmaExport }) {
  const profile = loadProfile(profileDir);
  const cem = loadCem(profile.cemManifestPath, { dtsDir: profile.cemDtsDir, log: () => {} });
  const figma = loadFigmaExport(profile.figmaExportPath);

  // Validate manual-correspondence against the live CEM + figma export before
  // any matching, so misconfigured manual entries fail loudly before changing
  // anything on disk.
  if (Object.keys(profile.manualCorrespondence).length > 0) {
    validateManualCorrespondence(profile.manualCorrespondence, { cem, figma });
  }

  const proposed = buildProposals(cem, figma, profile.matcherConfig);
  // Apply manual-correspondence AFTER matching but BEFORE the human-preserving
  // merge with what's already on disk. This means every manual entry lands as
  // provenance:"manual"/status:"proposed" in the proposals array, and the
  // downstream mergeCorrespondence pass respects any human confirmation already
  // on disk (same as any other entry).
  const proposedWithManual = applyManualCorrespondence(proposed, profile.manualCorrespondence);

  const outPath = correspondencePath ?? path.join(profileDir, "correspondence.json");
  const existing = readCorrespondence(outPath);
  // Mirror manual-correspondence onto the stored entries too, so a manual set
  // added to an already-confirmed entry is applied to BOTH merge inputs and
  // lands live instead of parking in proposedUpdate (see applyManualToExisting).
  const existingWithManual = applyManualToExisting(existing, profile.manualCorrespondence);
  const merged = mergeCorrespondence(existingWithManual, proposedWithManual);

  return writeCorrespondence(outPath, merged);
}
