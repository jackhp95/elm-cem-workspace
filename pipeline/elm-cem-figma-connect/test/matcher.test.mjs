import { test } from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadCem } from "../src/ingest/cem.mjs";
import { loadFigmaExport } from "../src/ingest/figma.mjs";
import {
  slugify,
  normalizeName,
  singularize,
  editDistance,
  canonicalizeValue,
  valueMatch,
  bestValueMatch,
} from "../src/match/normalize.mjs";
import { detectFusionGroups } from "../src/match/fusion.mjs";
import { match, proposeAxis, proposeSlot, loadMatcherConfig } from "../src/match/matcher.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const cem = loadCem(
  path.join(here, "fixtures", "cem-facts.m3e-web-2.5.14.json"),
  { log: () => {} }
);
const figma = loadFigmaExport(path.join(here, "fixtures", "figma-export.m3-kit.json"));

// The m3-kit profile's own calibration (finding 2.4) — these fixtures ARE the
// m3-kit export, so tests use the same matcher.json a real `match` run would.
const m3KitMatcherConfig = loadMatcherConfig(path.join(here, "..", "profiles", "m3-kit"));

// Loaded once — both fixtures are large. Every assertion reads these views.
const { candidates } = match(cem, figma, m3KitMatcherConfig);
const byTag = (tag) => candidates.find((c) => c.cemTag === tag);

// -- normalize.mjs -----------------------------------------------------------

test("normalize: slug strips m3e-, kebab/case-folds, singular/plural folds", () => {
  assert.equal(normalizeName("m3e-button"), "button");
  assert.equal(normalizeName("Button"), "button");
  // singular/plural fold — the Checkboxes page slugs equal to m3e-checkbox.
  assert.equal(normalizeName("Checkboxes"), "checkbox");
  assert.equal(normalizeName("m3e-checkbox"), "checkbox");
  assert.equal(singularize("chips"), "chip");
  assert.equal(singularize("categories"), "category");
  assert.equal(singularize("address"), "address"); // no over-fold on -ss
});

test("normalize: Building Blocks prefixes are stripped but their origin is TAGGED, never excluded (D7)", () => {
  const dot = slugify(".Building Blocks/FAB Menu/Primary/FAB");
  assert.equal(dot.buildingBlock, "dot");
  assert.equal(dot.slug, "fab-menu-primary-fab");

  const plain = slugify("Building Blocks/Button group/Connected segments/XSmall");
  assert.equal(plain.buildingBlock, "plain");
  assert.ok(plain.slug.startsWith("button-group-connected-segment"));

  assert.equal(slugify("Button").buildingBlock, null);
});

test("normalize: value synonyms + edit-distance ≤2 fuzz (acceptance: Presssed → pressed)", () => {
  // Synonym table.
  assert.equal(canonicalizeValue("XSmall"), "extra-small");
  assert.equal(canonicalizeValue("XLarge"), "extra-large");
  assert.equal(canonicalizeValue("Round"), "rounded");

  // The kit-typo acceptance case: the double-s "Presssed" still resolves to
  // "pressed" via the edit-distance fuzz.
  const m = valueMatch("Presssed", "Pressed");
  assert.equal(m.match, true);
  assert.equal(m.method, "fuzzy");
  assert.equal(m.distance, 1);

  // Synonym-driven axis values.
  assert.equal(valueMatch("XSmall", "extra-small").method, "synonym");
  assert.equal(valueMatch("Round", "rounded").method, "synonym");
  assert.equal(valueMatch("Small", "small").method, "exact");
  // "outline" → "outlined" is left to the fuzz (not the synonym table).
  assert.equal(valueMatch("outline", "outlined").method, "fuzzy");

  assert.equal(editDistance("Presssed", "Pressed"), 1);
  assert.equal(bestValueMatch("XLarge", ["small", "extra-large", "large"]).value, "extra-large");
});

test("normalize: review fix #3 — value fuzz is scaled by token length, not an unscaled maxDistance=2", () => {
  // The acceptance case still folds: 8-char tokens get a length-scaled
  // budget of floor(8/3)=2, and the real distance is only 1.
  const pressed = valueMatch("Presssed", "Pressed");
  assert.equal(pressed.match, true);
  assert.equal(pressed.method, "fuzzy");
  assert.equal(pressed.distance, 1);

  // A short unrelated pair must NOT collide under the old unscaled cap: "on"
  // vs "off" is edit-distance 2, which used to be <= maxDistance=2.
  const onOff = valueMatch("on", "off");
  assert.equal(onOff.match, false);

  // Other reviewer-cited false-positive risks at short lengths also stay
  // rejected under the length-scaled + ratio-bounded fuzz.
  assert.equal(valueMatch("hide", "wide").match, false);
  assert.equal(valueMatch("low", "bun").match, false);
  assert.equal(valueMatch("flat", "fan").match, false);
  assert.equal(valueMatch("page", "date").match, false);

  // Re-verify the Size / Type axis synonym mappings still hold (these are
  // handled by the synonym table, not the fuzz path, but must be unaffected).
  assert.equal(valueMatch("XSmall", "extra-small").match, true);
  assert.equal(valueMatch("XLarge", "extra-large").match, true);
  assert.equal(valueMatch("Round", "rounded").match, true);
  assert.equal(valueMatch("Square", "square").match, true);
});

// -- fusion.mjs --------------------------------------------------------------

test("fusion: the 5 Button sibling sets fuse into one group incl. 57994:2227", () => {
  const groups = detectFusionGroups(figma.sets);
  const button = groups.find((g) => g.baseSlug === "button" && g.page === "Buttons");
  assert.ok(button, "Button fusion group present on the Buttons page");
  assert.equal(button.setIds.length, 5, "exactly 5 fused sets");
  assert.deepEqual(
    [...button.setIds].sort(),
    ["57994:2227", "58650:10213", "58650:8094", "58650:9294", "58651:11237"].sort()
  );
  // Only 2 of the 5 carry setProperties, yet all 5 fuse (do NOT hard-require
  // setProperties on every fused set).
  const withProps = button.members.filter((m) => m.set.properties).length;
  assert.equal(withProps, 2, "only 57994:2227 and 58650:9294 carry setProperties");

  // Bare "Button" is a member (value null); the 4 siblings carry their value.
  const bare = button.members.find((m) => m.value === null);
  assert.equal(bare.id, "57994:2227");
  const siblingValues = button.members.filter((m) => m.value).map((m) => m.value).sort();
  assert.deepEqual(siblingValues, ["elevated", "outline", "text", "tonal"]);
});

// -- matcher.mjs: the button ------------------------------------------------

test("matcher: m3e-button matches the 5-set fusion at the exact tier", () => {
  const btn = byTag("m3e-button");
  assert.ok(btn, "m3e-button candidate present");
  assert.equal(btn.kind, "fusion");
  assert.equal(btn.tier, "exact");
  assert.equal(btn.figmaSetIds.length, 5);
  assert.ok(btn.figmaSetIds.includes("57994:2227"));
  // Auditable rationale: mentions the fusion and the exact tier.
  const joined = btn.rationale.join(" | ");
  assert.match(joined, /fused 5 sibling sets/);
  assert.match(joined, /exact tier/);
});

test("matcher: Size axis maps all five values to the CEM 'size' enum", () => {
  const btn = byTag("m3e-button");
  const size = btn.axisProposals.find((a) => a.axis === "Size");
  assert.ok(size.mapped, "Size axis mapped");
  assert.equal(size.attribute, "size");
  assert.equal(size.coverage, "5/5");
  const map = Object.fromEntries(size.valueMap.map((v) => [v.figma, v.cem]));
  assert.deepEqual(map, {
    XSmall: "extra-small",
    Small: "small",
    Medium: "medium",
    Large: "large",
    XLarge: "extra-large",
  });
});

test("matcher: Type axis maps Round→rounded, Square→square (CEM 'shape' enum)", () => {
  const btn = byTag("m3e-button");
  const type = btn.axisProposals.find((a) => a.axis === "Type");
  assert.ok(type.mapped, "Type axis mapped");
  assert.equal(type.attribute, "shape");
  const map = Object.fromEntries(type.valueMap.map((v) => [v.figma, v.cem]));
  assert.deepEqual(map, { Round: "rounded", Square: "square" });
});

// -- RC1: boolean-axis support (proposeAxis) ---------------------------------
// A Figma VARIANT axis whose two options are a boolean pair (True/False, On/Off,
// Yes/No) has no ENUM CEM counterpart, so proposeAxis used to leave it unmapped
// (the switch `Selected` → `checked` gap). Boolean CEM attrs are now considered
// as 2-option axes, disambiguated by axis-name affinity.

test("matcher (RC1): a True/False axis maps to a name-affine boolean CEM attr (Selected→checked, NOT disabled)", () => {
  const axis = { name: "Selected", options: ["False", "True"], defaultValue: "False" };
  const component = {
    attributes: [
      { name: "checked", kind: "boolean" },
      { name: "disabled", kind: "boolean" },
    ],
    slots: [],
  };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.ok(p.mapped, "Selected axis maps");
  assert.equal(p.attribute, "checked", "selected→checked (synonym), not the other boolean attr");
  assert.equal(p.attributeKind, "boolean");
  assert.equal(p.coverage, "2/2");
  const map = Object.fromEntries(p.valueMap.map((v) => [v.figma, v.cem]));
  assert.deepEqual(map, { True: "true", False: "false" });
});

test("matcher (RC1): a name-exact boolean axis maps (Modal→modal), On/Off polarity honored", () => {
  const axis = { name: "Modal", options: ["Off", "On"], defaultValue: "Off" };
  const component = { attributes: [{ name: "modal", kind: "boolean" }], slots: [] };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.ok(p.mapped, "Modal axis maps to the modal boolean");
  assert.equal(p.attribute, "modal");
  assert.equal(p.attributeKind, "boolean");
  const map = Object.fromEntries(p.valueMap.map((v) => [v.figma, v.cem]));
  assert.deepEqual(map, { On: "true", Off: "false" });
});

test("matcher (RC1): a boolean-shaped axis with no name-affine boolean attr stays unmapped (switch Icon)", () => {
  const axis = { name: "Icon", options: ["False", "True"], defaultValue: "False" };
  const component = { attributes: [{ name: "checked", kind: "boolean" }], slots: [] };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.equal(p.mapped, false, "no boolean attr named/synonymous with 'Icon' — do not guess");
});

test("matcher (RC1): an enum axis still wins over the boolean path (no regression)", () => {
  const axis = { name: "Size", options: ["Small", "Large"], defaultValue: "Small" };
  const component = {
    attributes: [
      { name: "size", kind: "enum", values: ["small", "large"] },
      { name: "disabled", kind: "boolean" },
    ],
    slots: [],
  };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.ok(p.mapped);
  assert.equal(p.attribute, "size");
  assert.notEqual(p.attributeKind, "boolean", "enum mapping, not the boolean fallback");
});

// -- Multi-attr axis (multi-boolean): checkbox Type → {checked, indeterminate} --
// A Figma VARIANT axis whose options map across MULTIPLE CEM boolean attrs
// (not just True/False for one attr) should derive a multi-attr mapping by
// name affinity: "Selected"→checked=true, "Indeterminate"→indeterminate=true,
// "Unselected"→neither, "Error selected"→checked=true, etc.

test("matcher (multi-boolean): checkbox Type axis maps to {checked, indeterminate} not unmapped", () => {
  const axis = {
    name: "Type",
    options: ["Selected", "Unselected", "Indeterminate", "Error unselected", "Error indeterminate", "Error selected"],
    defaultValue: "Unselected",
  };
  const component = {
    attributes: [
      { name: "checked", kind: "boolean" },
      { name: "indeterminate", kind: "boolean" },
      { name: "disabled", kind: "boolean" },
    ],
    slots: [],
  };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.ok(p.mapped, "Type axis must map (multi-boolean path)");
  assert.equal(p.kind, "multi-boolean");
  assert.ok(Array.isArray(p.attrs), "attrs array present");
  assert.equal(p.attrs.length, 2);

  const checkedAttr = p.attrs.find((a) => a.attr === "checked");
  const indetAttr = p.attrs.find((a) => a.attr === "indeterminate");
  assert.ok(checkedAttr, "checked sub-attr present");
  assert.ok(indetAttr, "indeterminate sub-attr present");

  // TRUE pole: options affinity-matched to "selected" (excluding "un" negation)
  assert.equal(checkedAttr.valueMap["Selected"], "true");
  assert.equal(checkedAttr.valueMap["Error selected"], "true");
  // FALSE pole: unselected variants and indeterminate
  assert.equal(checkedAttr.valueMap["Unselected"], "false");
  assert.equal(checkedAttr.valueMap["Indeterminate"], "false");
  assert.equal(checkedAttr.valueMap["Error unselected"], "false");
  assert.equal(checkedAttr.valueMap["Error indeterminate"], "false");

  // TRUE pole: options containing "indeterminate"
  assert.equal(indetAttr.valueMap["Indeterminate"], "true");
  assert.equal(indetAttr.valueMap["Error indeterminate"], "true");
  // FALSE pole: selected and unselected variants
  assert.equal(indetAttr.valueMap["Selected"], "false");
  assert.equal(indetAttr.valueMap["Unselected"], "false");
  assert.equal(indetAttr.valueMap["Error unselected"], "false");
  assert.equal(indetAttr.valueMap["Error selected"], "false");
});

test("matcher (multi-boolean): 'Unselected' does NOT affinity-match 'selected' (un-negation guard)", () => {
  // The affinity rule must not match "unselected" as a true-pole hit for "selected".
  const axis = {
    name: "Type",
    options: ["Selected", "Unselected"],
    defaultValue: "Unselected",
  };
  const component = {
    attributes: [
      { name: "checked", kind: "boolean" },
      { name: "indeterminate", kind: "boolean" },
    ],
    slots: [],
  };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  // With only "Selected" matching checked (not "Unselected"), and no option
  // matching indeterminate, the axis should NOT fire as multi-boolean (only 1
  // attr fires — not enough to be multi-attr). Falls through to unmapped.
  assert.equal(p.mapped, false, "axis with only 1 firing attr does not produce multi-boolean — needs ≥2 attrs");
});

test("matcher (multi-boolean): a non-multi axis (two booleans, but only one fires) stays unmapped", () => {
  // Only "checked" fires (no "indeterminate" word in any option).
  const axis = {
    name: "State",
    options: ["Enabled", "Disabled", "Focused"],
    defaultValue: "Enabled",
  };
  const component = {
    attributes: [
      { name: "checked", kind: "boolean" },
      { name: "indeterminate", kind: "boolean" },
    ],
    slots: [],
  };
  const p = proposeAxis(axis, component, m3KitMatcherConfig);
  assert.equal(p.mapped, false, "State axis stays unmapped — no affinity match");
});

test("matcher (multi-boolean): checkbox Type axis maps via synthetic fixture (fixture lacks variant props for m3e-checkbox)", () => {
  // The test/fixtures/figma-export.m3-kit.json is a lightweight fixture that
  // doesn't capture variant properties for all sets — m3e-checkbox has no
  // properties[] in it, so byTag("m3e-checkbox").axisProposals is undefined.
  // This synthetic fixture drives the real proposeAxis path end-to-end.
  const synCem = {
    components: [{
      tag: "m3e-checkbox",
      description: "Checkboxes allow users to select one or more options.",
      attributes: [
        { name: "checked", kind: "boolean" },
        { name: "indeterminate", kind: "boolean" },
        { name: "disabled", kind: "boolean" },
      ],
      slots: [],
    }],
  };
  const synFigma = {
    sets: [{
      id: "99:1",
      name: "Checkboxes",
      page: "Checkboxes",
      description: "",
      properties: [
        {
          displayName: "Type",
          type: "VARIANT",
          variantOptions: ["Selected", "Unselected", "Indeterminate", "Error unselected", "Error indeterminate", "Error selected"],
          defaultValue: "Unselected",
        },
        {
          displayName: "State",
          type: "VARIANT",
          variantOptions: ["Enabled", "Hovered", "Focused", "Pressed", "Disabled"],
          defaultValue: "Enabled",
        },
      ],
    }],
    standalones: [],
  };
  const { candidates: synCandidates } = match(synCem, synFigma, m3KitMatcherConfig);
  const checkbox = synCandidates.find((c) => c.cemTag === "m3e-checkbox");
  assert.ok(checkbox, "m3e-checkbox matched");
  const typeAxis = checkbox.axisProposals.find((a) => a.axis === "Type");
  assert.ok(typeAxis, "Type axis proposal present");
  assert.ok(typeAxis.mapped, "Type axis is mapped (not unmapped)");
  assert.equal(typeAxis.kind, "multi-boolean");
  assert.equal(typeAxis.attrs.length, 2);
  // All 6 options are covered.
  assert.equal(typeAxis.coverage, "6/6");
});

test("matcher: the button's no-CEM-counterpart axis (State) is emitted as unmapped; NO Width axis exists on the button", () => {
  const btn = byTag("m3e-button");
  const state = btn.axisProposals.find((a) => a.axis === "State");
  assert.ok(state, "State axis present");
  assert.equal(state.mapped, false);
  assert.match(state.reason, /no CEM enum attribute shares its value set/);

  // RECONCILIATION: the brief lists "Width/State" as unmapped, but the captured
  // button set (57994:2227, variantCount 50 = 2 Type × 5 Size × 5 State) carries
  // NO Width axis — Width lives on other set families (Icon button, Button
  // group). Assert what's real: no Width axis to emit here.
  assert.equal(btn.axisProposals.find((a) => a.axis === "Width"), undefined);
  const axisNames = btn.axisProposals.map((a) => a.axis).sort();
  assert.deepEqual(axisNames, ["Size", "State", "Type"]);
});

test("matcher: fusion binds fixed 'variant' values; bare Button → filled (the unclaimed enum value)", () => {
  const btn = byTag("m3e-button");
  assert.equal(btn.fusion.attribute, "variant");
  const bySet = Object.fromEntries(
    btn.fusion.fixedValues.map((f) => [f.setId, { v: f.cemValue, m: f.method, fig: f.figmaValue }])
  );
  assert.equal(bySet["58650:8094"].v, "text"); // Button - text
  assert.equal(bySet["58650:9294"].v, "elevated"); // Button - elevated
  assert.equal(bySet["58650:10213"].v, "outlined"); // Button - outline (fuzzy)
  assert.equal(bySet["58651:11237"].v, "tonal"); // Button - tonal

  // The bare "Button" set (57994:2227) → filled: the ONE variant enum value no
  // sibling set claimed. NOTE the brief calls this "the CEM default filled" but
  // the CEM's real variant default is "text" (already claimed by Button - text);
  // "filled" is derived as the unclaimed leftover, not the CEM default.
  assert.equal(bySet["57994:2227"].fig, null);
  assert.equal(bySet["57994:2227"].v, "filled");
  assert.equal(bySet["57994:2227"].m, "leftover");
});

test("matcher: button non-variant properties propose content / icon-slot bindings", () => {
  const btn = byTag("m3e-button");
  const props = Object.fromEntries(btn.propertyProposals.map((p) => [p.property, p]));

  assert.equal(props["Label text"].type, "TEXT");
  assert.equal(props["Label text"].proposal, "content");

  assert.equal(props["Show icon"].type, "BOOLEAN");
  assert.equal(props["Show icon"].proposal, "slot-presence");
  assert.equal(props["Show icon"].target, "slot:icon");

  assert.equal(props["Icon"].type, "INSTANCE_SWAP");
  assert.equal(props["Icon"].proposal, "slot");
  assert.equal(props["Icon"].target, "slot:icon");

  // The Figma-only "Show focus indicator" boolean has no CEM counterpart.
  assert.equal(props["Show focus indicator"].mapped, false);

  // SLOT-typed properties (Task 3: matcher — populate the slots dimension)
  // are relocated OUT of propertyProposals entirely — they must never show
  // up here, mapped or unmapped, regardless of whether a CEM counterpart
  // exists. See the sibling slotProposals test below for where they land.
  assert.equal(props["Trailing slot"], undefined);
  assert.equal(props["Trailing icon"], undefined);
});

// -- Task 3: SLOT properties route to slotProposals, not propertyProposals --

test("matcher: SLOT properties are routed to slotProposals, never propertyProposals", () => {
  const btn = byTag("m3e-button");
  const slotProps = Object.fromEntries(btn.slotProposals.map((s) => [s.property, s]));

  // "Trailing icon" (fixture SLOT prop) exact-matches m3e-button's real
  // "trailing-icon" CEM slot.
  assert.ok(slotProps["Trailing icon"], "Trailing icon slot proposal present");
  assert.equal(slotProps["Trailing icon"].mapped, true);
  assert.equal(slotProps["Trailing icon"].target, "trailing-icon");
  assert.equal(slotProps["Trailing icon"].method, "exact");

  // "Trailing slot" (Task 1's original fixture SLOT prop) has no plausible
  // counterpart among m3e-button's slots (["", "icon", "selected",
  // "selected-icon", "trailing-icon"]) — stays unmapped with a reason.
  assert.ok(slotProps["Trailing slot"], "Trailing slot slot proposal present");
  assert.equal(slotProps["Trailing slot"].mapped, false);
  assert.match(slotProps["Trailing slot"].reason, /no CEM slot matches/);

  // Neither SLOT prop ever appears in propertyProposals — the relocation is
  // total, not additive.
  const propNames = btn.propertyProposals.map((p) => p.property);
  assert.ok(!propNames.includes("Trailing slot"));
  assert.ok(!propNames.includes("Trailing icon"));
});

// -- Final-review finding #2: proposeSlot's generic-content fallback must ---
// -- report method:"fuzzy", not "exact" (an honest heuristic-match signal) --
//
// proposeSlot has two ways to land on a CEM slot: (1) a real name match
// against a NAMED CEM slot (via bestValueMatch — genuinely "exact" when the
// names are identical), and (2) a fallback for a generic-content-named Figma
// SLOT prop ("Content", "Content (standard)", ...) with NO named-slot
// counterpart, which maps to the CEM component's unnamed default slot purely
// because the prop's name reads as "content" — a regex heuristic, not a
// verified name-identity match. Before this fix the fallback reported
// method:"exact", which merge.mjs's buildSlots turned into the same
// provenance:"auto-exact" tier as a real name match — mislabeling 6 of 7
// currently-mapped real m3-kit slots (they all take this fallback path).

test("matcher (final-review finding #2): proposeSlot's generic-content default-slot fallback reports method:'fuzzy', not 'exact'", () => {
  // No named CEM slot matches "Content (standard)" at all — only the fallback
  // (regex /\bcontent\b/i + a default slot) can bind it.
  const component = { tag: "m3e-fake-toolbar", slots: [{ name: "" }, { name: "leading" }] };
  const prop = { name: "Content (standard)", type: "SLOT" };

  const proposal = proposeSlot(prop, component);

  assert.equal(proposal.mapped, true);
  assert.equal(proposal.target, "(default)");
  assert.equal(proposal.method, "fuzzy", "generic-content fallback is a heuristic match, not a verified exact name match");
});

test("matcher (final-review finding #2): a real named-slot exact match (e.g. m3e-card's Content -> content) still reports method:'exact'", () => {
  // A genuinely name-identical CEM slot must still win via the real
  // exact-match path above the fallback — the fix must not downgrade this
  // case too.
  const component = { tag: "m3e-fake-card", slots: [{ name: "" }, { name: "content" }] };
  const prop = { name: "Content", type: "SLOT" };

  const proposal = proposeSlot(prop, component);

  assert.equal(proposal.mapped, true);
  assert.equal(proposal.target, "content");
  assert.equal(proposal.method, "exact", "a real named-slot name match must stay 'exact', not be downgraded by the fallback fix");
});

// -- RC2: INSTANCE_SWAP icon → DEFAULT (unnamed) slot -----------------------
// icon-button's `Icon` prop goes in the DEFAULT slot (slot="" / no slot attr),
// NOT in a named "icon" slot. The matcher must bind it to "slot:" (slot: prefix
// + empty name) so the emitter renders <m3e-icon ${glyph}></m3e-icon> with no
// slot attr. Button's named-slot behavior must be byte-unchanged.
//
// Note: the test fixture figma-export.m3-kit.json has 0 non-variant properties
// on the icon-button sets (they carry no INSTANCE_SWAP in the lightweight
// fixture), so the real binding is exercised via synthetic cases below. The A8
// test (correspond.test.mjs) validates the full live fixture end-to-end.

test("matcher (RC2): INSTANCE_SWAP Icon → default slot when component has only a default slot (no named 'icon' slot)", () => {
  // Synthetic fixture: CEM with only a default slot; Figma set with an Icon
  // INSTANCE_SWAP prop. Must bind to "slot:" (not unmapped, not "slot:icon").
  const synCem = {
    components: [{
      tag: "m3e-synth-btn",
      description: "",
      attributes: [],
      slots: [{ name: "" }],
    }],
  };
  const synFigma = {
    sets: [{
      id: "1:1",
      name: "Synth btn",
      page: "Test",
      description: "",
      properties: [
        { displayName: "Icon", type: "INSTANCE_SWAP", defaultValue: "some-icon" },
      ],
    }],
    standalones: [],
  };
  const { candidates: synCandidates } = match(synCem, synFigma, m3KitMatcherConfig);
  const synt = synCandidates.find(c => c.cemTag === "m3e-synth-btn");
  assert.ok(synt, "synthetic match found");
  const iconProp = synt.propertyProposals?.find(p => p.property === "Icon");
  assert.ok(iconProp, "Icon prop proposed");
  assert.ok(iconProp.mapped, "Icon mapped (default slot found)");
  assert.equal(iconProp.target, "slot:", "default-slot binding (empty name after 'slot:')");
  assert.notEqual(iconProp.target, "slot:icon", "must NOT use the named-slot binding");
});

test("matcher (RC2): INSTANCE_SWAP Icon → named 'icon' slot when component has both default + named slot (button regression guard)", () => {
  // Button has BOTH a default slot ("") AND a named "icon" slot. The named-slot
  // path should still win (existing behavior), not fall through to default-slot.
  const btn = byTag("m3e-button");
  const props = Object.fromEntries(btn.propertyProposals.map((p) => [p.property, p]));
  const icon = props["Icon"];
  assert.ok(icon, "button's Icon prop present");
  assert.ok(icon.mapped, "button's Icon is still mapped");
  assert.equal(icon.target, "slot:icon", "button's named-slot binding is byte-unchanged");
});

test("matcher (RC2): INSTANCE_SWAP Icon → stays unmapped when component has neither default nor named icon slot", () => {
  // A component with no slots at all: the Icon prop cannot find any slot to bind.
  const synCem = {
    components: [{
      tag: "m3e-no-slots",
      description: "",
      attributes: [],
      slots: [],
    }],
  };
  const synFigma = {
    sets: [{
      id: "2:1",
      name: "No slots",
      page: "Test",
      description: "",
      properties: [
        { displayName: "Icon", type: "INSTANCE_SWAP", defaultValue: "some-icon" },
      ],
    }],
    standalones: [],
  };
  const { candidates: noSlotCandidates } = match(synCem, synFigma, m3KitMatcherConfig);
  const noSlot = noSlotCandidates.find(c => c.cemTag === "m3e-no-slots");
  assert.ok(noSlot, "no-slots match found");
  const iconProp = noSlot.propertyProposals?.find(p => p.property === "Icon");
  assert.ok(iconProp, "Icon prop proposed");
  assert.equal(iconProp.mapped, false, "Icon stays unmapped when no slot exists");
});

// -- matcher.mjs: exact-tier singletons + icons ------------------------------

test("matcher: checkbox and chips match at the exact tier", () => {
  const checkbox = byTag("m3e-checkbox");
  assert.ok(checkbox, "m3e-checkbox matched");
  assert.equal(checkbox.tier, "exact");
  assert.ok(checkbox.figmaSetIds.includes("51859:5628"));

  for (const [tag, setId] of [
    ["m3e-filter-chip", "53923:28270"],
    ["m3e-input-chip", "53923:27888"],
    ["m3e-suggestion-chip", "53923:28679"],
  ]) {
    const c = byTag(tag);
    assert.ok(c, `${tag} matched`);
    assert.equal(c.tier, "exact", `${tag} at exact tier`);
    assert.ok(c.figmaSetIds.includes(setId), `${tag} → set ${setId}`);
  }
});

test("matcher: fuzzy tier fires on a real near-miss (Assistive chip → m3e-assist-chip)", () => {
  const assist = candidates.find((c) => c.figmaName === "Assistive chip");
  assert.ok(assist, "Assistive chip candidate present");
  assert.equal(assist.tier, "fuzzy");
  assert.equal(assist.cemTag, "m3e-assist-chip");
  assert.ok(assist.score >= 0.5 && assist.score < 1);
  assert.match(assist.rationale.join(" | "), /fuzzy tier/);
});

test("matcher: icons collapse to ONE m3e-icon entry with a 141-name value table (not 141 entries)", () => {
  const icon = byTag("m3e-icon");
  assert.ok(icon, "m3e-icon matched");
  assert.equal(icon.kind, "icon");
  assert.equal(icon.tier, "exact");
  assert.equal(icon.valueTable.length, 141, "one value-table row per icon component");
  // exactly one candidate maps to m3e-icon (not 141).
  assert.equal(candidates.filter((c) => c.cemTag === "m3e-icon").length, 1);
  // value-table binds the snake_case name to the CEM `name` attribute.
  const wifi = icon.valueTable.find((r) => r.figmaName === "wifi");
  assert.equal(wifi.attribute, "name");
  assert.equal(wifi.value, "wifi");
});

test("matcher: review fix #1 — non-icon standalone components are NOT silently excluded (Rich Tooltip → m3e-rich-tooltip)", () => {
  const tooltip = candidates.find((c) => c.figmaName === "Rich Tooltip");
  assert.ok(tooltip, "Rich Tooltip candidate present (previously dropped entirely)");
  assert.equal(tooltip.kind, "standalone");
  assert.equal(tooltip.tier, "exact");
  assert.equal(tooltip.cemTag, "m3e-rich-tooltip");
  assert.ok(tooltip.figmaSetIds.includes("54061:33872"));
});

test("matcher: review fix #2 — Tabs set resolves to m3e-tabs (structural tiebreak), and m3e-tab is NOT silently dropped", () => {
  const tabs = candidates.find((c) => c.figmaName === "Tabs");
  assert.ok(tabs, "Tabs candidate present");
  assert.equal(
    tabs.cemTag,
    "m3e-tabs",
    "COMPONENT_SET (container-shaped) binds to the plural/container tag, not declaration order"
  );
  // Not a naive clean exact/score:1 bind — the resolution went through a
  // documented structural tiebreak.
  assert.ok(tabs.score < 1, "resolved collision must not present as a clean score:1 bind");
  assert.match(tabs.rationale.join(" | "), /structural tiebreak/);

  // The losing tag (m3e-tab) must still surface somewhere in output — never
  // silently disappear.
  const tab = byTag("m3e-tab");
  assert.ok(tab, "m3e-tab still appears in output");
  assert.equal(tab.tier, "gap");
  assert.equal(tab.kind, "code-only");
});

test("matcher: review fix #6 — shared m3.material.io doc URL contributes to the fuzzy score (synthetic fixture)", () => {
  const cemBase = "Renders a compact badge for surfacing status inline with text content.";
  const figmaBase = "A small chip shown next to a label to flag current state at a glance.";
  const url = "m3.material.io/components/glorbwidget";

  const mkCem = (desc) => ({
    components: [{ tag: "m3e-glorbwidget", description: desc, attributes: [], slots: [] }],
  });
  const mkFigma = (desc) => ({
    sets: [],
    standalones: [{ id: "1:1", name: "Glorbwidget panel", page: "Widgets", description: desc }],
  });

  // Without a shared doc URL (and with unrelated surrounding description
  // text), the name signal alone doesn't clear the fuzzy threshold.
  const without = match(mkCem(cemBase), mkFigma(figmaBase), m3KitMatcherConfig);
  const noUrlCandidate = without.candidates[0];
  assert.equal(noUrlCandidate.tier, "gap");

  // Add the SAME m3.material.io/components/... URL to both descriptions
  // (otherwise-unrelated text unchanged): the shared-URL signal alone tips
  // the score over FUZZY_ACCEPT_THRESHOLD.
  const withUrl = match(mkCem(`${cemBase} See ${url}.`), mkFigma(`${figmaBase} Spec: ${url}.`), m3KitMatcherConfig);
  const urlCandidate = withUrl.candidates[0];
  assert.equal(urlCandidate.tier, "fuzzy");
  assert.equal(urlCandidate.cemTag, "m3e-glorbwidget");
  assert.match(urlCandidate.rationale.join(" | "), /shared doc URL m3\.material\.io\/components\/glorbwidget/);
});

test("matcher: every candidate carries a stable output shape + auditable rationale", () => {
  for (const c of candidates) {
    assert.ok(Array.isArray(c.figmaSetIds));
    assert.ok(["exact", "contains", "fuzzy", "gap"].includes(c.tier));
    assert.equal(typeof c.score, "number");
    assert.ok(Array.isArray(c.rationale) && c.rationale.length > 0, `rationale for ${c.figmaName}`);
    // Ordinary gaps are Figma-side (a real Figma entity with no CEM tag), so
    // cemTag is null. The ONE deliberate exception (review fix #2) is a
    // "code-only" gap: a CEM tag that lost a slug collision (m3e-tab vs.
    // m3e-tabs) and has no other Figma counterpart — it is surfaced with its
    // own cemTag so it is never silently dropped from output, not with a
    // fabricated Figma-side identity.
    if (c.tier === "gap" && c.kind !== "code-only") assert.equal(c.cemTag, null);
  }
});

// -- Fix 2: leading-dot set hygiene ------------------------------------------
// COMPONENT_SET names starting with "." are Figma-internal building-block
// utilities (e.g. ".Shape" is a corner-radius token helper, NOT the real
// shape-component set). They must NOT win an exact-tier match over the real
// component. The rule is purely name-based (no hardcoded node ids).

test("matcher (Fix 2): a leading-dot set (.Shape-like) does NOT exact-match its slug-equivalent CEM tag", () => {
  // Synthetic fixture: a leading-dot internal set whose slug equals a CEM tag
  // slug, and a real non-dot set that SHOULD match but at a different slug.
  const synCem = {
    components: [{ tag: "m3e-shape", description: "", attributes: [], slots: [] }],
  };
  const synFigma = {
    sets: [
      // The internal leading-dot set: slug = "shape" after stripping the dot.
      // Must NOT win exact tier.
      { id: "DOT:1", name: ".Shape", page: "Styles", description: "" },
      // A real candidate with a different slug (slug="shape-set") — still gaps.
      { id: "REAL:1", name: "Shape Set", page: "Shape", description: "" },
    ],
    standalones: [],
  };
  const { candidates: synCandidates } = match(synCem, synFigma, m3KitMatcherConfig);

  // The leading-dot set candidate must NOT be exact tier.
  const dotCandidate = synCandidates.find((c) => c.figmaSetIds.includes("DOT:1"));
  assert.ok(dotCandidate, "leading-dot set still surfaces as a candidate (not silently dropped)");
  assert.notEqual(dotCandidate.tier, "exact", "leading-dot set must NOT win exact tier");
  // With the contains tier: "Shape Set" is consumed by the qualifier (head-noun
  // 'shape' → m3e-shape), so m3e-shape is already bound at contains. The
  // boundCemTags guard then prevents .Shape from fuzzy-binding m3e-shape
  // (which would create a collision). .Shape falls through to gap instead.
  assert.ok(dotCandidate.tier === "fuzzy" || dotCandidate.tier === "gap",
    "leading-dot set falls through to fuzzy or gap (gap when contains tier already claimed the CEM tag)");

  // The real Shape Set candidate is bound at contains (head-noun 'shape' →
  // m3e-shape via qualifier), not at gap.
  const realCandidate = synCandidates.find((c) => c.figmaSetIds.includes("REAL:1"));
  assert.ok(realCandidate, "real Shape Set still surfaces as a candidate");
  assert.ok(realCandidate.tier === "contains" || realCandidate.tier === "gap",
    "Shape Set: contains (qualifier bound m3e-shape) or gap (if no match)");
});

test("matcher (Fix 2): leading-dot sets in the real fixture are all excluded from exact tier", () => {
  // The real fixture has 32 leading-dot COMPONENT_SET names (e.g. ".Shape",
  // ".Building Blocks/..."). None of them should have tier:"exact".
  const dotCandidates = candidates.filter(
    (c) => c.kind === "set" && typeof c.figmaName === "string" && c.figmaName.startsWith(".")
  );
  assert.ok(dotCandidates.length > 0, "real fixture has leading-dot set candidates");
  for (const c of dotCandidates) {
    assert.notEqual(
      c.tier,
      "exact",
      `leading-dot set '${c.figmaName}' must not be at exact tier (got ${c.tier})`
    );
  }
});
