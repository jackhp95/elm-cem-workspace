// Task C5: the sampling policy — decides WHICH states of a correspondence
// entry get visually gated. Full cartesian is intractable (5,354 drawn
// variants in the kit; the CEM space is larger still), so the DEFAULT plan
// is one-factor-at-a-time; `--audit`-style sampling trades that tractability
// for exhaustiveness bounded to what Figma actually drew (Figma is the
// bound — only materialized variants have a Figma side to diff against).
//
// ⚑ RECONCILIATION vs the brief's example count (task-C5-brief.md Step 1:
// "≈ 1 + 4 (sizes) + 1 (shape) + 1 (icon off) + 4 (sibling color sets) ≈ 11"):
// that arithmetic double-counts an "icon off" state that has NO Figma side
// to compare against. C2's driver (see the long scope-boundary comment
// above figmaNodeQuery in ./drive.mjs) established the reason: a Figma
// variant NODE materializes only the DEFAULT render of its
// componentProperties (Show icon defaults to true) — there is no sibling
// node anywhere in the kit export for a "Show icon=false" state, so the
// visual gate has nothing on the Figma side to diff a driven icon-off code
// render against. The plan itself says (C2 brief Step 2): "never compare
// icon-vs-no-icon." Therefore the default sample below varies ONLY:
//   (a) each MAPPED axis's non-default values, one axis at a time, every
//       other axis pinned to its Figma-measured default (each such state
//       has a distinct Figma variant node to compare against), and
//   (b) each sibling figmaSet's own default-axis state (fused entries
//       only — each sibling set IS a distinct Figma component tree, so its
//       default state is comparably real).
// It NEVER emits a non-default componentProperty (boolean/text/
// instanceSwap) state — those are code-side-only variations (still worth
// exercising, just not through this visual gate; see the module-end note
// on a possible future code-only audit mode).
//
// MEASURED on the button fixture (profiles/m3-kit/correspondence.json +
// test/fixtures/figma-export.m3-kit.json): 1 (all-defaults) + 4 (Size:
// XSmall/Medium/Large/XLarge — default is Small) + 1 (Type: Square —
// default Round) + 4 (sibling sets Button-text/elevated/outline/tonal, each
// at default axis values) = **10** states, not ≈11 — the delta is exactly
// the excluded icon-off state. sample.test.mjs asserts this measured count,
// not the brief's estimate.
//
// -- Exclusions (asserted in code, not just by convention) ------------------
//
//   - The `State` axis (interaction states — a Plan C non-goal, see
//     plans/00-mission-and-decisions.md) is NEVER sampled, default or audit.
//     Enforced generically (any axis marked `unmapped` is skipped — State
//     is unmapped on every measured entry today) AND specifically
//     (assertNonGoalExclusions below throws if a future correspondence.json
//     edit ever maps State to a CEM attribute instead of marking it
//     unmapped — interaction states must not silently become sampleable).
//   - Any other axis marked `unmapped` is skipped the same way (defensive;
//     none exist on the button fixture besides State today).
//   - `kind: "iconTable"` entries (A6 schema) are gate-exempt in v1 — the
//     141 glyph renders are font-identical by construction (same Material
//     Symbols glyph both sides). sampleDefault/sampleAudit both return []
//     for an iconTable entry; auditIconSpotCheck below is the audit-mode
//     substitute (spot-checks 5 icons instead of skipping entirely).
//   - figmaSets carrying an inline `example`/`slugSuffix` (the appendSets
//     "2nd-set" mechanism) are representative-example renders of a SEPARATE
//     Figma component set, NOT axis-grid variants of THIS entry — excluded
//     from both plans (see axisGridSets). They have their own example render;
//     the axis gate has no meaningful state to drive them through (driving a
//     toggle-button set through the base button's Type×Size grid resolves no
//     variant). Their base entry's own axis-grid sets sample as usual.
//   - An entry whose axis-grid figmaSets NONE of which captured
//     setProperties in this export (e.g. m3e-nav-menu: its one figmaSet
//     points at a standalone Figma COMPONENT, not a COMPONENT_SET —
//     extraction (extract/README.md) only calls `get_component_properties`
//     on COMPONENT_SET node ids, so a correspondence entry whose only
//     figmaSet(s) resolve to standalone COMPONENTs will NEVER have captured
//     setProperties, by design, not by data-quality gap) is gate-exempt the
//     same way — see hasNoCapturedSetProperties below. There is no axis grid
//     to derive defaults from or drive through, so (like iconTable/code-only
//     entries) the axis gate has no meaningful state to sample at all. This
//     is a per-entry structural fact (checked BEFORE calling drive.mjs's
//     buildDefaultState/definitionsFor, which would otherwise throw), not a
//     generic error handler — an entry with a MIX of a captured
//     COMPONENT_SET sibling and an uncaptured standalone-COMPONENT sibling
//     is NOT exempt; it still drives normally off the captured sibling
//     (definitionsFor's existing loop-with-continue). Entries whose
//     matcherKind IS "standalone" are excluded from this check entirely —
//     drive.mjs's own isStandaloneEntry fast-path already handles those (no
//     axes/props to derive; the intrinsic-default single state is real and
//     still gated), so they are never mistaken for this exemption just
//     because their one figmaSet also happens to lack setProperties.
//
// -- Contract with C2's driver -----------------------------------------------
//
// Each sampled `state` is exactly C2's driver contract shape
// ({setNodeId?, axisValues, propValues} — see drive.mjs's driveState /
// validateStateKeys) — nothing extra is mixed INTO it. Every sampled item
// additionally carries a `stateId` (deterministic, human-readable,
// filename-safe) ALONGSIDE that state, because C4's diff.mjs
// (comparePngFiles/writeResultRecord) takes stateId as an opaque cache-key/
// filename component, and C3's exporter brief describes its input as "a
// list of {entry, state}" — this module supplies the `state` and a stable
// `stateId` for that list; wiring entry+state+stateId together into a run
// is the caller's job (C3/C6/a future orchestrator).
//
// Determinism is a GATE here (sampled states feed cache keys downstream):
// every iteration order below is explicitly sorted with ../lib/order.mjs's
// ordinal byString/byKey (never object/Map insertion order, never
// localeCompare) so re-runs on any machine/locale produce a byte-identical
// state list.
//
// Zero new deps; pure logic. The only "impurity" is buildDefaultState's
// figmaExport parameter (an already-loaded ../ingest/figma.mjs object) — no
// direct fs/network use in this module itself.

import { byString, byKey } from "../lib/order.mjs";
import { buildDefaultState, variantsBySet } from "./drive.mjs";

const STATE_AXIS_NAME = "State";
const ICON_SPOT_CHECK_COUNT = 5;

// slug(s) -> lowercase, filename-safe token. Used to build stateId; not
// used to compare/sort values (byString still does that on the raw
// strings, so ordering is unaffected by slugging).
function slug(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function cloneState(state) {
  return {
    setNodeId: state.setNodeId,
    axisValues: { ...state.axisValues },
    propValues: { ...state.propValues },
  };
}

// assertNonGoalExclusions(entry) -> void, throws
//
// Defense-in-depth for the State-axis exclusion: today every measured entry
// marks State `unmapped` (so the generic unmapped-axis filter already
// excludes it), but that's a correspondence.json fact, not a structural
// guarantee. If a future edit ever gave State a real attr+valueMap, the
// generic filter would silently start sampling interaction states — a
// Plan C non-goal. Fail loudly instead.
export function assertNonGoalExclusions(entry) {
  const stateAxis = (entry.axes ?? []).find((a) => a.figmaProp === STATE_AXIS_NAME);
  if (stateAxis && !stateAxis.unmapped) {
    throw new Error(
      `sample: entry '${entry.cemTag}' maps its '${STATE_AXIS_NAME}' axis to a CEM attribute — ` +
        `sampling interaction states is a Plan C non-goal; mark '${STATE_AXIS_NAME}' unmapped in ` +
        `correspondence.json instead of letting the sampler vary it`
    );
  }
}

// sampleableAxes(entry) -> entry.axes[] with unmapped axes removed, sorted
// by figmaProp (ordinal) for deterministic iteration order.
function sampleableAxes(entry) {
  return (entry.axes ?? []).filter((a) => !a.unmapped).sort(byKey((a) => a.figmaProp));
}

// isIconTableEntry / hasNoFigmaPresence — the two ways an entry legitimately
// yields zero sampled states.
function isIconTableEntry(entry) {
  return entry.kind === "iconTable";
}

function hasNoFigmaPresence(entry) {
  return !entry.figmaSets || entry.figmaSets.length === 0;
}

// isStandaloneMatcherKind(entry) -> true for matcherKind:"standalone" —
// drive.mjs's own isStandaloneEntry fast-path (a single COMPONENT node, no
// variant children, no setProperties to read at all — the intrinsic-default
// render IS the one real state). Never route these through
// hasNoCapturedSetProperties below — they always lack captured
// setProperties by design, but that's not this new exemption; it's the
// pre-existing standalone path, which still produces a real, gated "default"
// state.
function isStandaloneMatcherKind(entry) {
  return entry.matcherKind === "standalone";
}

// hasNoCapturedSetProperties(entry, figmaExport) -> true when NONE of this
// entry's axis-grid figmaSets (axisGridSets — representative-example 2nd-sets
// don't count either way) have a captured setProperties entry in this
// export. See the module docstring's exclusions list for the full rationale
// (extraction only captures setProperties for COMPONENT_SET nodes; a
// figmaSet pointing at a standalone COMPONENT never will). A MIXED entry
// (some siblings captured, some not) returns false here — it still has a
// real axis grid to derive defaults from and drive through, via whichever
// sibling DID capture its properties (drive.mjs's definitionsFor already
// handles picking that one).
function hasNoCapturedSetProperties(entry, figmaExport) {
  const gridSets = axisGridSets(entry);
  return gridSets.length > 0 && gridSets.every((set) => !figmaExport.data.setProperties[set.nodeId]);
}

// isRepresentativeExampleSet(set) -> true for an appendSets "2nd-set" (carries
// an inline `example` and/or a `slugSuffix`): a standalone representative
// render of a SEPARATE component set, not an axis-grid variant of this entry.
function isRepresentativeExampleSet(set) {
  return set.slugSuffix !== undefined || set.example !== undefined;
}

// axisGridSets(entry) -> the entry's figmaSets that ARE axis-grid variants
// (i.e. the primary matcher-fused sets), excluding appended representative-
// example 2nd-sets. Both sampling plans operate only on these — the visual
// gate drives the entry's axis grid, which the appended sets do not belong to.
function axisGridSets(entry) {
  return (entry.figmaSets ?? []).filter((set) => !isRepresentativeExampleSet(set));
}

// sampleDefault(entry, figmaExport) -> Array<{ stateId, state }>
//
// The default (non-audit) sampling plan: one-factor-at-a-time. See the
// module docstring for the full reconciliation and the measured button
// count. Returns [] for iconTable entries (gate-exempt in v1), for entries
// with no Figma presence (figmaSets:[], e.g. matcherKind:"code-only" —
// nothing to visually gate), and for non-standalone entries whose figmaSets
// have no captured setProperties anywhere (e.g. m3e-nav-menu — see the
// module docstring's exclusions list and hasNoCapturedSetProperties).
export function sampleDefault(entry, figmaExport) {
  assertNonGoalExclusions(entry);
  if (isIconTableEntry(entry) || hasNoFigmaPresence(entry)) return [];
  if (!isStandaloneMatcherKind(entry) && hasNoCapturedSetProperties(entry, figmaExport)) return [];

  const gridSets = axisGridSets(entry);
  if (gridSets.length === 0) return [];

  const baseSetNodeId = gridSets[0].nodeId;
  const defaultState = buildDefaultState(entry, figmaExport, { setNodeId: baseSetNodeId });
  const axes = sampleableAxes(entry);

  const states = [{ stateId: "default", state: cloneState(defaultState) }];

  // (a) one non-default value per mapped axis, defaults elsewhere.
  for (const axisDef of axes) {
    const defaultValue = defaultState.axisValues[axisDef.figmaProp];
    const values = Object.keys(axisDef.valueMap ?? {}).sort(byString);
    for (const value of values) {
      if (value === defaultValue) continue;
      const state = cloneState(defaultState);
      state.axisValues[axisDef.figmaProp] = value;
      states.push({
        stateId: `axis-${slug(axisDef.figmaProp)}-${slug(value)}`,
        state,
      });
    }
  }

  // (b) each sibling figmaSet's own default-axis state (fused entries
  // only — entry.figmaSets.slice(1) is empty for a non-fused entry).
  // definitionsFor (drive.mjs) draws axis/prop defaults from ONE shared
  // source across the whole fusion group, so every sibling's "default
  // state" carries the SAME axisValues/propValues as the base — only
  // setNodeId differs — which is exactly why re-calling buildDefaultState
  // per sibling (rather than reusing defaultState with setNodeId swapped)
  // is still correct and keeps this loop honest about what it's asserting.
  for (const set of gridSets.slice(1)) {
    const siblingDefault = buildDefaultState(entry, figmaExport, { setNodeId: set.nodeId });
    states.push({
      stateId: `set-${slug(set.setName)}`,
      state: cloneState(siblingDefault),
    });
  }

  return states;
}

// sampleAudit(entry, figmaExport) -> Array<{ stateId, state }>
//
// --audit: full cartesian of *drawn* variants. Figma is the bound — this
// enumerates every variant node actually materialized under every one of
// the entry's figmaSets (via drive.mjs's variantsBySet), not a hypothetical
// full cartesian of the CEM attribute space.
//
// The State axis is still excluded (Plan C non-goal, same as the default
// plan): variants are filtered to the one State value the default plan
// pins (typically "Enabled"), not all 5 interaction states. Auditing every
// State value would be pure waste besides — driveState always pins an
// unmapped axis (State) to its default when resolving figmaNodeQuery
// (drive.mjs's Step 4), so passing a non-default State value here would
// silently resolve to the SAME node as the pinned-default variant, i.e.
// duplicate comparisons, not additional coverage.
export function sampleAudit(entry, figmaExport) {
  assertNonGoalExclusions(entry);
  if (isIconTableEntry(entry) || hasNoFigmaPresence(entry)) return [];
  if (!isStandaloneMatcherKind(entry) && hasNoCapturedSetProperties(entry, figmaExport)) return [];

  const gridSets = axisGridSets(entry);
  if (gridSets.length === 0) return [];

  const baseDefault = buildDefaultState(entry, figmaExport, { setNodeId: gridSets[0].nodeId });
  const stateAxis = (entry.axes ?? []).find((a) => a.figmaProp === STATE_AXIS_NAME);
  const pinnedStateValue = stateAxis ? baseDefault.axisValues[STATE_AXIS_NAME] : undefined;

  const bySet = variantsBySet(figmaExport.data);
  const states = [];
  for (const set of gridSets) {
    const variants = (bySet.get(set.nodeId) ?? [])
      .filter((v) => pinnedStateValue === undefined || v.props[STATE_AXIS_NAME] === pinnedStateValue)
      .sort(byKey((v) => v.name));
    for (const variant of variants) {
      states.push({
        stateId: `audit-${slug(set.setName)}-${slug(variant.name)}`,
        state: {
          setNodeId: set.nodeId,
          axisValues: { ...variant.props },
          propValues: { ...baseDefault.propValues },
        },
      });
    }
  }
  return states;
}

// auditIconSpotCheck(iconTable, count=5) -> Array<{ stateId, figmaNodeId, symbolName }>
//
// The --audit substitute for iconTable entries' gate-exemption: rather than
// skipping the 141 glyphs entirely, spot-check a small deterministic sample
// (sorted by symbolName, ordinal — NOT insertion order, so the sample is
// stable across re-ingests that reorder the source table). This is not a
// driver `state` (an iconTable entry has no figmaSets/axes to drive — each
// icon IS a Figma node directly) — callers compare figmaNodeId's render
// against the code-side m3e-icon(name=symbolName) render directly.
export function auditIconSpotCheck(iconTable, count = ICON_SPOT_CHECK_COUNT) {
  return [...iconTable]
    .sort(byKey((icon) => icon.symbolName))
    .slice(0, count)
    .map((icon) => ({
      stateId: `audit-icon-${slug(icon.symbolName)}`,
      figmaNodeId: icon.figmaNodeId,
      symbolName: icon.symbolName,
    }));
}

// Forward flag (not implemented here — out of C5's scope, which is the
// VISUAL gate's sampling policy): the componentProperty states excluded
// above (Show icon=false, arbitrary Label text, etc.) are still real code
// paths worth exercising. If a future task wants that coverage, it belongs
// in a separate CODE-ONLY audit mode (rendering the harness and asserting
// against the component's own contract/snapshot, never against a Figma
// export) — keep it out of this module's default/--audit sampling, which
// exists specifically to feed the visual (code vs Figma) gate.
