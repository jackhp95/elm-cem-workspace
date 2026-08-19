// Task C2: the correspondence-driven state driver — the PARITY CONTRACT of
// the visual gate. Turns one correspondence entry (Plan A schema, task A6)
// plus one chosen *state* into BOTH a code-render spec (harnessParams, for
// C1's src/visual/harness/page.mjs mount contract) and a Figma-node query
// (figmaNodeQuery), so both sides are driven to the SAME state.
//
// Evidence this module is answerable to (plans/00-mission-and-decisions.md):
//   #2  axis value maps (Figma option -> CEM enum value, e.g. XSmall ->
//       extra-small) — entry.axes[].valueMap, Step 1 below.
//   #9  set-fusion: one CEM component <-> N Figma SETS, each contributing a
//       FIXED attribute value from the set binding, not a variant axis —
//       entry.figmaSets[].fixedAttrs, Step 1 below.
//   #12 icons: m3e-icon's `name` attr is the kit's Material-Symbols-derived
//       symbolName from the iconTable entry (see profiles/*/correspondence
//       .json's kind:"iconTable" entry), never the raw Figma node-id — Step 2.
//   #14 parity requires driving componentProperties (TEXT/BOOLEAN/
//       INSTANCE_SWAP), not just variant axes — Step 2 (the critical rule:
//       a kit default `Show icon=true` must render an icon on BOTH sides,
//       never icon-on-one-side/icon-off-the-other).
//
// Reuses rather than reimplements:
//   - src/ingest/figma.mjs: isVariantName/parseVariantName/displayNameOf (the
//     SAME variant-name parser the loader itself uses).
//   - src/match/normalize.mjs: valueMatch (the SAME fuzz/synonym normalizer
//     the matcher uses) for the figmaNodeQuery fuzzy tier (kit typos like
//     "Presssed").
//   - src/lib/order.mjs: byString, for deterministic key ordering wherever
//     this module produces something order-sensitive (determinism gate).
//   - src/correspond/merge.mjs: readCorrespondence, to load the iconTable
//     entry from a profile's correspondence.json (loadIconTable below) —
//     does not re-run matching or re-parse correspondence.json itself.
//
// Zero new deps. Pure logic: the only fs use is loadIconTable() reading an
// already-ingested correspondence.json; no browser, no rendering.

import { isVariantName, parseVariantName, displayNameOf } from "../ingest/figma.mjs";
import { valueMatch } from "../match/normalize.mjs";
import { byString } from "../lib/order.mjs";
import { readCorrespondence } from "../correspond/merge.mjs";

const SLOT_PREFIX = "slot:";

// -- figma-set -> child-variant grouping --------------------------------------
//
// figma-export.json's `components` array has NO explicit "belongs to set"
// field on variant COMPONENTs (schema: id/name/type/key/description/page
// only). The relationship is positional: Figma's own export order is
// depth-first, so every COMPONENT_SET is immediately followed by its own
// variant children until the next COMPONENT_SET starts (measured: e.g.
// 'Button' 57994:2227 at components[518] is followed by its 50 variants,
// then 'Button - text' 58650:8094 begins at components[569]). This is the
// same structural fact src/ingest/figma.mjs's loader relies on implicitly
// via variantsByPage — but page alone doesn't disambiguate SIBLING fused
// sets that share one page (all 5 button sets are on page "Buttons"), so a
// set-scoped grouping is needed here and doesn't already exist upstream.
//
// variantsBySet(data) -> Map<setNodeId, Array<{ id, name, props }>>
export function variantsBySet(data) {
  const bySet = new Map();
  let currentSetId = null;
  for (const component of data.components) {
    if (component.type === "COMPONENT_SET") {
      currentSetId = component.id;
      if (!bySet.has(currentSetId)) bySet.set(currentSetId, []);
      continue;
    }
    if (currentSetId !== null && component.type === "COMPONENT" && isVariantName(component.name)) {
      bySet.get(currentSetId).push({
        id: component.id,
        name: component.name,
        props: parseVariantName(component.name),
      });
    }
  }
  return bySet;
}

// -- Step 3: figmaNodeQuery ----------------------------------------------------
//
// Resolves the variant node within ONE set by exact `Prop=Value, ...` match
// first (parsed-object comparison, not string comparison — parseVariantName
// already did the parsing, ../ingest/figma.mjs), falling back to a fuzzy tier
// that tolerates kit typos (evidence: kit data has `State=Presssed`) via
// normalize.mjs's valueMatch on each axis value independently. Throws if
// neither tier finds a unique-enough candidate — an unresolvable node is a
// correspondence/fixture bug, not a soft failure.
//
// findVariantNode(figmaExport, setNodeId, expectedProps) -> {
//   setNodeId, nodeId, name, tier: "exact"|"fuzzy"
// }
export function findVariantNode(figmaExport, setNodeId, expectedProps) {
  const bySet = variantsBySet(figmaExport.data);
  const candidates = bySet.get(setNodeId);
  if (!candidates || candidates.length === 0) {
    throw new Error(
      `drive: figma set '${setNodeId}' has no variant children in this export (or does not exist)`
    );
  }

  const expectedKeys = Object.keys(expectedProps).sort(byString);
  const sameKeys = (candidate) => {
    const keys = Object.keys(candidate.props).sort(byString);
    return keys.length === expectedKeys.length && keys.every((k, i) => k === expectedKeys[i]);
  };
  const keyMatched = candidates.filter(sameKeys);

  const exact = keyMatched.find((c) => expectedKeys.every((k) => c.props[k] === expectedProps[k]));
  if (exact) return { setNodeId, nodeId: exact.id, name: exact.name, tier: "exact" };

  const fuzzy = keyMatched.find((c) =>
    expectedKeys.every((k) => valueMatch(c.props[k], expectedProps[k]).match)
  );
  if (fuzzy) return { setNodeId, nodeId: fuzzy.id, name: fuzzy.name, tier: "fuzzy" };

  throw new Error(
    `drive: no variant under set '${setNodeId}' matches ${JSON.stringify(expectedProps)} ` +
      `(checked ${keyMatched.length} same-axis candidates of ${candidates.length}, exact and fuzzy tiers both failed)`
  );
}

// -- shared axis/prop definitions (for defaults + the "never silent" gate) ----
//
// A fusion group's sibling sets share one axis signature and, per
// src/match/fusion.mjs, only SOME members actually capture setProperties
// (measured on the button fixture: 2 of 5). Mirrors fusion.mjs's own rule —
// "merged ... axes/props: taken from the first member that actually
// captured its properties" — rather than inventing a second convention.
function definitionsFor(entry, figmaExport) {
  for (const set of entry.figmaSets) {
    const raw = figmaExport.data.setProperties[set.nodeId];
    if (!raw) continue;
    return {
      sourceSetNodeId: set.nodeId,
      axes: raw
        .filter((p) => p.type === "VARIANT")
        .map((p) => ({ figmaProp: p.name, defaultValue: p.defaultValue })),
      // SLOT-typed properties are their own dimension (correspondence
      // entry.slots[], task 3 "matcher — populate the slots dimension") —
      // relocated out of props[] at the matcher/merge layer, so they're
      // split out here too rather than expecting them in entry.props[].
      props: raw
        .filter((p) => p.type !== "VARIANT" && p.type !== "SLOT")
        .map((p) => ({ figmaProp: displayNameOf(p.name), type: p.type, defaultValue: p.defaultValue })),
      slots: raw
        .filter((p) => p.type === "SLOT")
        .map((p) => ({ figmaProp: displayNameOf(p.name), type: p.type, defaultValue: p.defaultValue })),
    };
  }
  throw new Error(
    `drive: entry '${entry.cemTag}' has no figmaSet with captured setProperties in this export — ` +
      `cannot derive axis/property defaults or validate unmapped coverage`
  );
}

// Step 4 (axes) + the analogous prop-side check: every VARIANT axis / every
// non-variant property Figma actually exposes must be accounted for in the
// entry — either mapped (attr+valueMap / kind+binding) or explicitly marked
// unmapped with a reason. A Figma property present in the kit but absent
// from BOTH lists is a silent correspondence bug (the exact failure mode
// evidence #14 warns about: an un-driven BOOLEAN gate produces icon-on-
// one-side / icon-off-the-other) — never proceed past it quietly.
function assertFullyMapped(entry, defs) {
  for (const axisDef of defs.axes) {
    const found = entry.axes.find((a) => a.figmaProp === axisDef.figmaProp);
    if (!found) {
      throw new Error(
        `drive: figma VARIANT axis '${axisDef.figmaProp}' on entry '${entry.cemTag}' is not present in ` +
          `correspondence axes[] at all (neither mapped nor marked unmapped) — a silent unmapped axis ` +
          `is a correspondence bug`
      );
    }
    // A well-formed mapped axis is one of:
    //   (a) single-attr: attr + valueMap
    //   (b) multi-attr:  kind:"multi-boolean" + attrs[]
    //   (c) unmapped:    unmapped reason string
    const isSingleAttr = found.attr && found.valueMap;
    const isMultiAttr = found.kind === "multi-boolean" && Array.isArray(found.attrs);
    if (!found.unmapped && !isSingleAttr && !isMultiAttr) {
      throw new Error(
        `drive: axis '${axisDef.figmaProp}' on entry '${entry.cemTag}' is malformed — needs attr+valueMap, ` +
          `kind:"multi-boolean"+attrs[], or unmapped`
      );
    }
  }
  for (const propDef of defs.props) {
    const found = entry.props.find((p) => p.figmaProp === propDef.figmaProp);
    if (!found) {
      throw new Error(
        `drive: figma property '${propDef.figmaProp}' on entry '${entry.cemTag}' is not present in ` +
          `correspondence props[] at all (neither mapped nor marked unmapped) — a silent unmapped ` +
          `componentProperty is exactly the icon-mismatch bug evidence #14 warns about`
      );
    }
    if (!found.unmapped && !(found.kind && found.binding)) {
      throw new Error(
        `drive: prop '${propDef.figmaProp}' on entry '${entry.cemTag}' is malformed — needs kind+binding ` +
          `or unmapped`
      );
    }
    // Extra check for literalIcon: iconName is required when bound.
    if (found.kind === "literalIcon" && found.binding && !found.iconName) {
      throw new Error(
        `drive: literalIcon prop '${propDef.figmaProp}' on entry '${entry.cemTag}' must carry an ` +
          `'iconName' field (the literal Material Symbols ligature name)`
      );
    }
  }
  // Same "never silent" coverage check, for the SLOT dimension (task 3):
  // every SLOT-typed Figma property must show up in entry.slots[], mapped
  // (mappedTo) or unmapped (unmapped reason) — never absent. entry.slots is
  // omitted (not []) on entries with zero SLOT properties (merge.mjs), so
  // default to [] here rather than treating a missing array as a bug.
  //
  // MIGRATION TOLERANCE: real, already-confirmed correspondence entries
  // predate the slots[] relocation and were never re-matched (that requires
  // a human `runReview`/`runConfirm` pass, out of this gate's remit) — their
  // SLOT properties are still covered the OLD way, as a legacy `kind:"slot"`
  // item inside props[] (the exact shape proposeProperty's catch-all used to
  // emit before this task). Accept EITHER shape as coverage so this gate
  // doesn't strand real mid-migration data while still catching a genuinely
  // silent drop (present in neither list).
  for (const slotDef of defs.slots) {
    const foundInSlots = (entry.slots ?? []).find((s) => s.figmaSlotName === slotDef.figmaProp);
    // Final-review finding #3: a MAPPED slots[] item passes this coverage
    // check today, but nothing downstream in this file actually DRIVES
    // content from it (the per-prop loop below only reads entry.props[];
    // Task 4 wired the html-label EMITTER, not this visual-drive harness).
    // Letting a mapped slots[] item satisfy "coverage" here would make the
    // gate lie — content silently never gets driven for the visual check,
    // exactly the kind of silent gap this "never silent" gate exists to
    // catch. An UNMAPPED slots[] item is fine as-is (no counterpart, nothing
    // to drive) — only a MAPPED one is the known, tracked gap, so only that
    // case throws.
    if (foundInSlots && foundInSlots.mappedTo !== undefined) {
      throw new Error(
        `drive: entry '${entry.cemTag}' slot '${slotDef.figmaProp}' is mapped in correspondence slots[] ` +
          `(-> '${foundInSlots.mappedTo}') but driving content from slots[] is not yet implemented in the ` +
          `visual-drive harness (Task 4 wired the html-label emitter only, not this harness) — this is a ` +
          `known, tracked gap, not a silent no-op; do not treat this slot as covered until drive.mjs can ` +
          `actually render slots[] content`
      );
    }
    const foundLegacyInProps = entry.props.find((p) => p.kind === "slot" && p.figmaProp === slotDef.figmaProp);
    const found = foundInSlots ?? foundLegacyInProps;
    if (!found) {
      throw new Error(
        `drive: figma SLOT property '${slotDef.figmaProp}' on entry '${entry.cemTag}' is not present in ` +
          `correspondence slots[] (or, pre-migration, props[]) at all (neither mapped nor marked unmapped) — ` +
          `a silent unmapped SLOT property is exactly the icon-mismatch bug evidence #14 warns about`
      );
    }
    const mapped = foundInSlots ? found.mappedTo : found.binding;
    if (!found.unmapped && !mapped) {
      throw new Error(
        `drive: slot '${slotDef.figmaProp}' on entry '${entry.cemTag}' is malformed — needs mappedTo/binding or unmapped`
      );
    }
  }
}

// Step 4.5 (C2b, "never silent"): before translating state into attrs/
// figmaNodeQuery, verify every key the caller supplied in state.axisValues /
// state.propValues actually names a Figma axis/prop this entry exposes
// (defs.axes[].figmaProp / defs.props[].figmaProp). Without this, a mistyped
// or unknown key (e.g. a C5 sampler typo'ing 'Sizee' for 'Size') silently
// falls through the `?? defaultValue` below to the DEFAULT value instead of
// erroring — the caller believes it drove one state but got a different one,
// with no signal anything went wrong. Mirrors setNodeId's existing strict
// validation above (an unknown setNodeId already throws) rather than
// introducing a second, looser convention for axis/prop keys.
function validateStateKeys(entry, defs, state) {
  const knownAxisProps = new Set(defs.axes.map((a) => a.figmaProp));
  for (const key of Object.keys(state.axisValues ?? {})) {
    if (!knownAxisProps.has(key)) {
      throw new Error(
        `drive: state.axisValues key '${key}' on entry '${entry.cemTag}' is not a known Figma VARIANT ` +
          `axis (known: ${[...knownAxisProps].sort(byString).join(", ")}) — refusing to silently fall ` +
          `back to the default instead of the (mistyped) value you asked for`
      );
    }
  }
  const knownPropProps = new Set(defs.props.map((p) => p.figmaProp));
  for (const key of Object.keys(state.propValues ?? {})) {
    if (!knownPropProps.has(key)) {
      throw new Error(
        `drive: state.propValues key '${key}' on entry '${entry.cemTag}' is not a known Figma ` +
          `componentProperty (known: ${[...knownPropProps].sort(byString).join(", ")}) — refusing to ` +
          `silently fall back to the default instead of the (mistyped) value you asked for`
      );
    }
  }
}

function requireFigmaSets(entry) {
  if (!entry.figmaSets || entry.figmaSets.length === 0) {
    throw new Error(
      `drive: entry '${entry.cemTag}' has no figmaSets (matcherKind:'${entry.matcherKind}') — ` +
        `a code-only entry has nothing to drive visually`
    );
  }
}

// RC4: standalone entries (matcherKind:"standalone") are a single COMPONENT
// node — not a COMPONENT_SET, so they have no variant children and no
// setProperties to read axis/prop defaults from. The driver's only job here
// is to render the component at its own intrinsic default state (no axes to
// drive, no props to override) and query that one node directly.
function isStandaloneEntry(entry) {
  return entry.matcherKind === "standalone";
}

// buildDefaultState(entry, figmaExport, { setNodeId? }) -> state
//
// The Figma-measured default for every axis and every componentProperty
// (Step 2's rule: "Default state = Figma's defaultValue from the
// componentPropertyDefinitions"), for one figmaSet (defaults to
// entry.figmaSets[0] — for a fusion entry this is the bare set, e.g.
// 'Button' -> variant=filled). Callers building a specific test scenario
// (e.g. a particular Size) copy this object and override individual axis/
// prop values — see drive.test.mjs's default-state test, which starts here
// and overrides Size to reach a concrete measured fixture node.
export function buildDefaultState(entry, figmaExport, { setNodeId } = {}) {
  requireFigmaSets(entry);
  // RC4: standalone — no setProperties, no axes, no props; the only state is
  // the component's intrinsic default. Return the minimal valid state object
  // that driveState will accept via the same standalone fast-path.
  if (isStandaloneEntry(entry)) {
    return {
      setNodeId: entry.figmaSets[0].nodeId,
      axisValues: {},
      propValues: {},
    };
  }
  const chosenSetNodeId = setNodeId ?? entry.figmaSets[0].nodeId;
  const defs = definitionsFor(entry, figmaExport);

  const axisValues = {};
  for (const axis of defs.axes) axisValues[axis.figmaProp] = axis.defaultValue;

  // A figmaSet's `fixedAttrs` may pin a Figma variant AXIS to a specific value
  // for gating — needed when the distinguishing axis is UNMAPPED (no CEM attr),
  // so the default-variant the axis's own defaultValue selects would NOT match
  // what the code renders. E.g. m3e-avatar's `Style` axis is unmapped; the code
  // (Letter text) renders a MONOGRAM, so `fixedAttrs:{Style:"Monogram"}` pins the
  // Figma side to the monogram variant instead of the person-icon default. Only
  // keys that name a real Figma axis are overlaid — fusion's fixedAttrs keys are
  // CODE attribute names (e.g. `variant`), which never match a Figma axis name,
  // so fusion/mapped-axis behavior is untouched.
  const chosenSet = entry.figmaSets.find((s) => s.nodeId === chosenSetNodeId) ?? entry.figmaSets[0];
  for (const [key, value] of Object.entries(chosenSet.fixedAttrs ?? {})) {
    if (defs.axes.some((a) => a.figmaProp === key)) axisValues[key] = value;
  }

  const propValues = {};
  for (const prop of defs.props) propValues[prop.figmaProp] = prop.defaultValue;

  return { setNodeId: chosenSetNodeId, axisValues, propValues };
}

// loadIconTable(correspondencePath) -> icons[] ({figmaNodeId,figmaName,symbolName})
//
// Reuses readCorrespondence (src/correspond/merge.mjs) rather than
// re-parsing correspondence.json; finds the ONE kind:"iconTable" entry
// (D7/evidence #12 — 141 icon rows on a single m3e-icon entry, not 141
// separate entries).
export function loadIconTable(correspondencePath) {
  const entries = readCorrespondence(correspondencePath);
  const iconEntry = entries.find((e) => e.kind === "iconTable");
  if (!iconEntry) {
    throw new Error(`drive: no kind:"iconTable" entry found in ${correspondencePath}`);
  }
  return iconEntry.icons;
}

// driveState(entry, figmaExport, state, iconTable=[]) -> { harnessParams, figmaNodeQuery }
//
// state = {
//   setNodeId?,             // one of entry.figmaSets[].nodeId; defaults to figmaSets[0]
//   axisValues: { [figmaProp]: rawFigmaValue },  // MAPPED axes only need entries;
//                                                 // unmapped axes are pinned to their
//                                                 // Figma default regardless (Step 4)
//   propValues: { [figmaProp]: rawFigmaValue },  // TEXT: string; BOOLEAN: boolean;
//                                                 // INSTANCE_SWAP: a Figma node-id string
// }
export function driveState(entry, figmaExport, state, iconTable = []) {
  requireFigmaSets(entry);

  // RC4: standalone — a single COMPONENT node (not a COMPONENT_SET) with no
  // variant children and no setProperties. There is exactly one possible render:
  // the component's own intrinsic default. Emit the bare tag with no attrs,
  // no text, no slots; query the node directly (no variant resolution needed).
  if (isStandaloneEntry(entry)) {
    const standaloneNodeId = entry.figmaSets[0].nodeId;
    const harnessParams = { tag: entry.cemTag, attrs: {}, text: undefined, slots: {} };
    if (state.boundsPx) harnessParams.boundsPx = state.boundsPx;
    const figmaNodeQuery = {
      setNodeId: null,
      nodeId: standaloneNodeId,
      name: entry.figmaSets[0].setName,
      tier: "exact",
    };
    return { harnessParams, figmaNodeQuery };
  }

  const setNodeId = state.setNodeId ?? entry.figmaSets[0].nodeId;
  const chosenSet = entry.figmaSets.find((s) => s.nodeId === setNodeId);
  if (!chosenSet) {
    throw new Error(
      `drive: setNodeId '${setNodeId}' is not one of entry '${entry.cemTag}''s figmaSets ` +
        `(${entry.figmaSets.map((s) => s.nodeId).join(", ")})`
    );
  }

  const defs = definitionsFor(entry, figmaExport);
  assertFullyMapped(entry, defs);
  validateStateKeys(entry, defs, state);

  // -- Step 1 + Step 4: axis translation ---------------------------------
  const attrs = {};
  const expectedProps = {}; // raw Figma values for EVERY axis, feeds figmaNodeQuery

  for (const axisDef of defs.axes) {
    const entryAxis = entry.axes.find((a) => a.figmaProp === axisDef.figmaProp);

    if (entryAxis.unmapped) {
      // Step 4: unmapped Figma axes pin to their default value in EVERY
      // generated state — a per-state override is deliberately ignored; there
      // is no CEM attribute to represent varying it, so wandering into e.g.
      // State=Pressed would compare non-comparable renders.
      //
      // EXCEPTION: an entry-level `fixedAttrs` pin on the chosen figmaSet
      // deliberately selects a specific variant of THIS unmapped axis for the
      // Figma query. Needed when the code's intrinsic render matches a
      // non-default variant of an unmapped axis — e.g. m3e-avatar's `Style`
      // axis is unmapped and the code (Letter text) renders a MONOGRAM, so
      // `fixedAttrs:{Style:"Monogram"}` compares against the monogram variant
      // instead of the person-icon default. This is a fixed entry choice, not
      // the arbitrary per-state wandering the default-pin guards against.
      expectedProps[axisDef.figmaProp] = chosenSet.fixedAttrs?.[axisDef.figmaProp] ?? axisDef.defaultValue;
      continue;
    }

    const rawValue = state.axisValues?.[axisDef.figmaProp] ?? axisDef.defaultValue;
    expectedProps[axisDef.figmaProp] = rawValue;

    // MULTI-ATTR axis (kind:"multi-boolean"): apply each sub-attr independently.
    if (entryAxis.kind === "multi-boolean") {
      for (const subAttr of entryAxis.attrs) {
        const cemValue = subAttr.valueMap[rawValue];
        if (cemValue === undefined) {
          throw new Error(
            `drive: multi-boolean axis '${axisDef.figmaProp}' attr '${subAttr.attr}' value '${rawValue}' ` +
              `has no valueMap entry on entry '${entry.cemTag}' ` +
              `(known values: ${Object.keys(subAttr.valueMap).join(", ")})`
          );
        }
        if (cemValue === null) continue;
        if (attrs[subAttr.attr] !== undefined) {
          throw new Error(
            `drive: attribute '${subAttr.attr}' would be driven twice (multi-boolean axis collision) on '${entry.cemTag}'`
          );
        }
        // Boolean presence semantics: "true" → attr present (value ""); "false" → absent.
        if (cemValue === "true" || cemValue === true) attrs[subAttr.attr] = "";
        // "false" → omit the attr (boolean-absent = off in HTML)
      }
      continue;
    }

    const cemValue = entryAxis.valueMap[rawValue];
    if (cemValue === undefined) {
      throw new Error(
        `drive: axis '${axisDef.figmaProp}' value '${rawValue}' has no valueMap entry on entry ` +
          `'${entry.cemTag}' (known values: ${Object.keys(entryAxis.valueMap).join(", ")})`
      );
    }
    // null in the valueMap means "omit this attribute for this Figma value" —
    // the component's own default applies (e.g. fab Size=Default has no `size`
    // attr; the component renders at its inherent default size). No collision
    // check is needed either — there is nothing to collide with.
    if (cemValue === null) continue;
    if (attrs[entryAxis.attr] !== undefined) {
      throw new Error(
        `drive: attribute '${entryAxis.attr}' would be driven twice (axis collision) on '${entry.cemTag}'`
      );
    }
    if (entryAxis.kind === "boolean") {
      // HTML boolean-attribute presence semantics (RC1), mirroring the boolean
      // PROP path below: the true pole ("true") renders the attr present with an
      // empty value; the false pole leaves it ABSENT. Never write checked="false"
      // — any present boolean attribute (even ="false") is ON in HTML.
      if (cemValue === "true" || cemValue === true) attrs[entryAxis.attr] = "";
    } else {
      attrs[entryAxis.attr] = cemValue;
    }
  }

  // Set-fusion (evidence #9): the chosen set's FIXED attribute(s), from the
  // set binding — never from an axis.
  for (const [attrName, value] of Object.entries(chosenSet.fixedAttrs ?? {})) {
    if (attrs[attrName] !== undefined) {
      throw new Error(
        `drive: fixed attr '${attrName}'='${value}' from set '${chosenSet.setName}' collides with an ` +
          `axis-derived attribute on '${entry.cemTag}'`
      );
    }
    attrs[attrName] = value;
  }

  // -- Step 2: componentProperty translation (the critical rule, #14) ---
  let text;
  const slotContent = {}; // slotName -> "m3e-icon:<name>" | raw string content
  const slotGates = {}; // slotName -> boolean, from a BOOLEAN prop bound to that slot

  for (const propDef of defs.props) {
    const entryProp = entry.props.find((p) => p.figmaProp === propDef.figmaProp);
    if (entryProp.unmapped) continue; // Figma-only property — never driven on either side

    const rawValue = state.propValues?.[propDef.figmaProp] ?? propDef.defaultValue;
    const binding = entryProp.binding;

    if (entryProp.kind === "text") {
      if (binding === "content") {
        text = rawValue;
      } else if (binding.startsWith(SLOT_PREFIX)) {
        const slotName = binding.slice(SLOT_PREFIX.length);
        if (entryProp.slotTag) {
          // RC5 text-to-slot with explicit element type: encode as "<tag>:<text>"
          // so page.mjs's buildSlotElement can create the right element (e.g.
          // slotTag:"input" → <input slot="input" placeholder="<text>">).
          slotContent[slotName] = `${entryProp.slotTag}:${String(rawValue)}`;
        } else {
          slotContent[slotName] = String(rawValue);
        }
      } else {
        attrs[binding] = rawValue;
      }
    } else if (entryProp.kind === "literalIcon") {
      // RC5 literalIcon: a BOOLEAN Figma property that gates a FIXED (non-swappable)
      // icon in a named slot. When the boolean is true, inject "m3e-icon:<iconName>".
      // When false, the slot stays absent. Unlike instanceSwap, the icon name is
      // hardcoded in the correspondence entry — it does not come from the iconTable.
      // The rawValue from a BOOLEAN Figma prop is already a JS boolean.
      if (!binding.startsWith(SLOT_PREFIX)) {
        throw new Error(
          `drive: literalIcon prop '${propDef.figmaProp}' on '${entry.cemTag}' must bind to a slot ` +
            `(got binding '${binding}')`
        );
      }
      if (!entryProp.iconName) {
        throw new Error(
          `drive: literalIcon prop '${propDef.figmaProp}' on '${entry.cemTag}' is missing required ` +
            `'iconName' field (the literal Material Symbols ligature name to emit)`
        );
      }
      if (rawValue) {
        const slotName = binding.slice(SLOT_PREFIX.length);
        slotContent[slotName] = `m3e-icon:${entryProp.iconName}`;
      }
      // false → slot stays absent (no entry in slotContent)
    } else if (entryProp.kind === "boolean") {
      if (binding.startsWith(SLOT_PREFIX)) {
        // Gates slot presence/absence — resolved after the loop, once every
        // prop (including the INSTANCE_SWAP that supplies the content) has
        // been seen. THIS is the guarantee that Show icon=true/false never
        // produces icon-on-one-side/icon-off-the-other: presence is decided
        // once, from this single boolean, and applied to whatever content
        // the paired INSTANCE_SWAP prop resolved.
        slotGates[binding.slice(SLOT_PREFIX.length)] = Boolean(rawValue);
      } else if (rawValue) {
        attrs[binding] = "";
      }
    } else if (entryProp.kind === "instanceSwap") {
      if (!binding.startsWith(SLOT_PREFIX)) {
        throw new Error(
          `drive: instanceSwap prop '${propDef.figmaProp}' on '${entry.cemTag}' must bind to a slot ` +
            `(got binding '${binding}')`
        );
      }
      // RC2 chip Configuration→slot-visibility: a visibilityAxis on an
      // instanceSwap prop gates whether the slot is injected at all. The axis
      // value is read from expectedProps (already resolved by the axis loop
      // above — unmapped axes are pinned to their Figma default there, so the
      // lookup is always valid). If the current value is not in visibleWhen,
      // skip this prop entirely — the slot gets no content and stays absent.
      if (entryProp.visibilityAxis) {
        const axisValue = expectedProps[entryProp.visibilityAxis];
        if (!Array.isArray(entryProp.visibleWhen) || !entryProp.visibleWhen.includes(axisValue)) {
          continue; // slot hidden for this Configuration/axis value
        }
      }
      const slotName = binding.slice(SLOT_PREFIX.length);
      const icon = iconTable.find((i) => i.figmaNodeId === rawValue);
      if (!icon) {
        // An instanceSwap prop whose default value is not in the iconTable
        // (e.g. assist-chip's Branded icon = brand logo, not a Material Symbol)
        // is silently skipped — the slot stays absent. This is the correct
        // behaviour for the "OMIT" decision on brand/favicon icons; it is NOT
        // a signal of a broken correspondence entry.
        continue;
      }
      // Encode the Material Symbols FILL axis as a "!filled" suffix the harness
      // mount contract parses (MS ligature names never contain "!"). m3e-icon
      // renders it via its `filled` attribute (font-variation-settings FILL 1).
      slotContent[slotName] = `m3e-icon:${icon.symbolName}${icon.filled ? "!filled" : ""}`;
    } else {
      throw new Error(
        `drive: unknown property kind '${entryProp.kind}' for '${propDef.figmaProp}' on '${entry.cemTag}'`
      );
    }
  }

  // A slot renders only if it has content AND no boolean gate for it is
  // false. A slot with no registered gate at all defaults to shown (nothing
  // on this entry suppresses it).
  const slots = {};
  for (const [slotName, content] of Object.entries(slotContent)) {
    if (slotGates[slotName] === false) continue;
    slots[slotName] = content;
  }

  const harnessParams = { tag: entry.cemTag, attrs, text, slots };
  if (state.boundsPx) harnessParams.boundsPx = state.boundsPx;

  // -- Step 3: figmaNodeQuery ------------------------------------------------
  //
  // SCOPE BOUNDARY (componentProperty parity — read before touching this):
  // figmaNodeQuery is resolved from expectedProps, which is built ONLY from
  // AXIS state above (Step 1 + Step 4) — it never varies by componentProperty
  // state (propValues, and therefore never by slots/text/slotGates either).
  // This is deliberate, not a gap to close:
  //
  //   - A Figma COMPONENT_SET's variant CHILDREN are keyed by VARIANT axes
  //     only (variantsBySet/parseVariantName parse `Prop=Value` names off of
  //     axes). There is no per-variant-node axis for componentProperties.
  //   - Each variant node materializes exactly ONE render of its
  //     componentProperties: the DEFAULTS from componentPropertyDefinitions
  //     (buildDefaultState's whole premise). E.g. 'Show icon' defaults to
  //     true, so the exported node already has the icon baked in — there is
  //     no sibling node anywhere in the export for 'Show icon=false' to
  //     query; that state simply has no Figma-side render to compare against.
  //
  // Consequence: the visual gate (diffing this figmaNodeQuery's rendered
  // node against harnessParams' code-side render) is only valid when EVERY
  // entry in state.propValues is at its Figma-measured default. Driving a
  // non-default prop (e.g. the 'Show icon=false' scenario covered by the
  // test below) still produces a correct harnessParams — the CODE side
  // genuinely suppresses the slot — but figmaNodeQuery resolves the exact
  // SAME node as the all-defaults state, because no axis changed. That is
  // NOT a bug to fix here: do not add Figma-side property-override
  // machinery (there is no such thing as a variant node for a non-default
  // componentProperty state), and do not make figmaNodeQuery vary by
  // propValues. The plan is explicit on this (C2 brief Step 2): "never
  // compare icon-vs-no-icon."
  //
  // Forward flags for later tasks:
  //   - C5 (sampling): must not generate a non-default-prop state and then
  //     expect a visual-gate comparison for it — there is nothing on the
  //     Figma side to compare against.
  //   - C3 (export): only the materialized (default-componentProperty)
  //     variant nodes are ever exportable; do not attempt to synthesize
  //     prop-variation renders.
  const figmaNodeQuery = findVariantNode(figmaExport, setNodeId, expectedProps);

  return { harnessParams, figmaNodeQuery };
}

// toHarnessUrlParams(harnessParams) -> Record<string,string>
//
// Flattens the structured harnessParams into the exact dotted-key scheme
// C1's src/visual/harness/page.mjs (and capture.mjs's renderOne, which
// takes this same Record<string,string> shape) expect:
//   { tag, "attr.<name>": value, text, "slot.<name>": "m3e-icon:<name>" }
// Keys sorted (byString, ../lib/order.mjs) for deterministic output —
// functionally page.mjs doesn't care about param order, but a stable
// ordering keeps this reproducible for anything keying a cache on the URL.
export function toHarnessUrlParams(harnessParams) {
  const params = { tag: harnessParams.tag };
  for (const key of Object.keys(harnessParams.attrs ?? {}).sort(byString)) {
    params[`attr.${key}`] = String(harnessParams.attrs[key]);
  }
  if (harnessParams.text !== undefined) params.text = String(harnessParams.text);
  for (const key of Object.keys(harnessParams.slots ?? {}).sort(byString)) {
    params[`slot.${key}`] = harnessParams.slots[key];
  }
  if (harnessParams.boundsPx) {
    params["boundsPx.w"] = String(harnessParams.boundsPx.w);
    params["boundsPx.h"] = String(harnessParams.boundsPx.h);
  }
  return params;
}
