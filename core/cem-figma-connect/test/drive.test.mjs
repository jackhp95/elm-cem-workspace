import { test } from "node:test";
import assert from "node:assert/strict";

import { driveState, buildDefaultState, toHarnessUrlParams } from "../src/visual/drive.mjs";

// RC1 (boolean axes): a Figma VARIANT axis bound to a boolean CEM attr
// (kind:"boolean") must drive the code side with HTML boolean-attribute
// PRESENCE semantics — the attr is present (value "") when the axis is at its
// true pole, and ABSENT when at its false pole. It must NEVER render
// `checked="false"`, because in HTML any present boolean attribute (even
// ="false") is truthy, which would render the wrong (on) state.
//
// Minimal synthetic export standing in for the real switch: one COMPONENT_SET
// with a single 2-option `Selected` axis and its two variant children.
const figmaExport = {
  data: {
    components: [
      { id: "SET1", name: "Switch", type: "COMPONENT_SET" },
      { id: "V_on", name: "Selected=True", type: "COMPONENT" },
      { id: "V_off", name: "Selected=False", type: "COMPONENT" },
    ],
    setProperties: {
      SET1: [{ type: "VARIANT", name: "Selected", defaultValue: "False" }],
    },
  },
};

const switchEntry = {
  cemTag: "m3e-switch",
  matcherKind: "set",
  figmaSets: [{ nodeId: "SET1", setName: "Switch", fixedAttrs: {} }],
  axes: [
    {
      figmaProp: "Selected",
      attr: "checked",
      kind: "boolean",
      valueMap: { True: "true", False: "false" },
    },
  ],
  props: [],
};

test("drive (RC1): a boolean axis at its TRUE pole renders the attr present (value \"\")", () => {
  const { harnessParams } = driveState(switchEntry, figmaExport, {
    axisValues: { Selected: "True" },
  });
  assert.equal(harnessParams.attrs.checked, "", "checked present, empty-string value (HTML boolean on)");
});

test("drive (RC1): a boolean axis at its FALSE pole OMITS the attr entirely (never checked=\"false\")", () => {
  const { harnessParams } = driveState(switchEntry, figmaExport, {
    axisValues: { Selected: "False" },
  });
  assert.equal(
    "checked" in harnessParams.attrs,
    false,
    "checked ABSENT — an HTML boolean attr must not be present-with-'false' (that is still ON)"
  );
});

test("drive (RC1): the FALSE pole flattens to NO attr.checked url param", () => {
  const { harnessParams } = driveState(switchEntry, figmaExport, {
    axisValues: { Selected: "False" },
  });
  const params = toHarnessUrlParams(harnessParams);
  assert.equal("attr.checked" in params, false);
});

test("drive (RC1): the boolean axis still resolves the correct Figma variant node per pole", () => {
  const on = driveState(switchEntry, figmaExport, { axisValues: { Selected: "True" } });
  const off = driveState(switchEntry, figmaExport, { axisValues: { Selected: "False" } });
  assert.equal(on.figmaNodeQuery.nodeId, "V_on");
  assert.equal(off.figmaNodeQuery.nodeId, "V_off");
});

// -- RC6: null valueMap value → omit attribute (m3e-fab Size=Default) ---------
//
// A valueMap entry of `null` means "this Figma option should produce NO CEM
// attribute at all" — the component renders at its own intrinsic default.
// The canonical case is fab Size=Default: the component has no "default" size
// enum value; not writing `size` at all uses the component's built-in default.
//
// Minimal synthetic export: one COMPONENT_SET with a Size axis that includes
// Default (null), Medium, and Large; and three variant children.
const fabFigmaExport = {
  data: {
    components: [
      { id: "FAB_SET", name: "FAB", type: "COMPONENT_SET" },
      { id: "FAB_DEFAULT_PRIMARY", name: "Size=Default, Color=Primary container, State=Enabled", type: "COMPONENT" },
      { id: "FAB_MEDIUM_PRIMARY", name: "Size=Medium, Color=Primary container, State=Enabled", type: "COMPONENT" },
      { id: "FAB_LARGE_PRIMARY", name: "Size=Large, Color=Primary container, State=Enabled", type: "COMPONENT" },
    ],
    setProperties: {
      FAB_SET: [
        { type: "VARIANT", name: "Size", defaultValue: "Default" },
        { type: "VARIANT", name: "Color", defaultValue: "Primary container" },
        { type: "VARIANT", name: "State", defaultValue: "Enabled" },
        {
          type: "BOOLEAN",
          name: "Show focus indicator#58687:2812",
          defaultValue: false,
        },
        {
          type: "INSTANCE_SWAP",
          name: "Icon#69457:42",
          defaultValue: "54616:25409",
          preferredValues: [],
        },
      ],
    },
  },
};

const fabEntry = {
  cemTag: "m3e-fab",
  matcherKind: "set",
  figmaSets: [{ nodeId: "FAB_SET", setName: "FAB", fixedAttrs: {} }],
  axes: [
    {
      figmaProp: "Size",
      attr: "size",
      valueMap: { Default: null, Medium: "medium", Large: "large" },
    },
    {
      figmaProp: "Color",
      attr: "variant",
      valueMap: { "Primary container": "primary-container" },
    },
    {
      figmaProp: "State",
      unmapped: "no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed)",
    },
  ],
  props: [
    {
      figmaProp: "Show focus indicator",
      kind: "boolean",
      unmapped: "no CEM counterpart (Figma-only property)",
    },
    {
      figmaProp: "Icon",
      kind: "instanceSwap",
      binding: "slot:",
    },
  ],
};

test("drive (RC6): valueMap null → attribute OMITTED (fab Size=Default produces no size attr)", () => {
  // The iconTable entry for "54616:25409" — referenced by Icon's defaultValue.
  const iconTable = [{ figmaNodeId: "54616:25409", figmaName: "stars_filled", symbolName: "stars", filled: true }];
  const { harnessParams, figmaNodeQuery } = driveState(fabEntry, fabFigmaExport, {
    axisValues: { Size: "Default", Color: "Primary container" },
  }, iconTable);

  // Size=Default produces null cemValue → attr is NOT emitted.
  assert.equal("size" in harnessParams.attrs, false, "size attr must be absent for Size=Default");
  // Other mapped attr is still emitted.
  assert.equal(harnessParams.attrs.variant, "primary-container");
  // The Figma node query resolves the Default variant.
  assert.equal(figmaNodeQuery.nodeId, "FAB_DEFAULT_PRIMARY");
});

test("drive (RC6): valueMap null → no attr.size url param for the null-mapped value", () => {
  const iconTable = [{ figmaNodeId: "54616:25409", figmaName: "stars_filled", symbolName: "stars", filled: true }];
  const { harnessParams } = driveState(fabEntry, fabFigmaExport, {
    axisValues: { Size: "Default", Color: "Primary container" },
  }, iconTable);
  const params = toHarnessUrlParams(harnessParams);
  assert.equal("attr.size" in params, false, "attr.size param absent when Size=Default (null valueMap)");
});

test("drive (RC6): non-null valueMap values still emit their attribute (Medium and Large)", () => {
  const iconTable = [{ figmaNodeId: "54616:25409", figmaName: "stars_filled", symbolName: "stars", filled: true }];
  const medResult = driveState(fabEntry, fabFigmaExport, {
    axisValues: { Size: "Medium", Color: "Primary container" },
  }, iconTable);
  assert.equal(medResult.harnessParams.attrs.size, "medium");
  assert.equal(medResult.figmaNodeQuery.nodeId, "FAB_MEDIUM_PRIMARY");

  const lgResult = driveState(fabEntry, fabFigmaExport, {
    axisValues: { Size: "Large", Color: "Primary container" },
  }, iconTable);
  assert.equal(lgResult.harnessParams.attrs.size, "large");
  assert.equal(lgResult.figmaNodeQuery.nodeId, "FAB_LARGE_PRIMARY");
});

test("drive (RC6): buildDefaultState for fab returns Size=Default (the figma defaultValue), no size attr driven", () => {
  const iconTable = [{ figmaNodeId: "54616:25409", figmaName: "stars_filled", symbolName: "stars", filled: true }];
  const defaultState = buildDefaultState(fabEntry, fabFigmaExport);
  assert.equal(defaultState.axisValues.Size, "Default", "defaultValue from setProperties is 'Default'");
  // Driving the default state also produces no size attr.
  const { harnessParams } = driveState(fabEntry, fabFigmaExport, defaultState, iconTable);
  assert.equal("size" in harnessParams.attrs, false, "default state produces no size attr");
});

// -- RC4: standalone entry path (m3e-rich-tooltip) ----------------------------
//
// A standalone entry (matcherKind:"standalone") wraps a single COMPONENT node
// (not a COMPONENT_SET). There are no variant children, no setProperties, and
// no axes to drive. driveState must:
//   1. Return bare harnessParams: the tag only, no attrs/text/slots.
//   2. Return figmaNodeQuery pointing directly at the standalone node.
//   3. Not call definitionsFor (which would throw — no setProperties exists).
//
// Minimal synthetic export: a standalone COMPONENT (no set wrapper, no variants).
const richTooltipFigmaExport = {
  data: {
    components: [
      { id: "RT_NODE", name: "Rich Tooltip", type: "COMPONENT" },
    ],
    setProperties: {},
  },
};

const richTooltipEntry = {
  cemTag: "m3e-rich-tooltip",
  matcherKind: "standalone",
  figmaSets: [{ nodeId: "RT_NODE", setName: "Rich Tooltip", fixedAttrs: {} }],
  axes: [],
  props: [],
};

test("drive (RC4): standalone entry produces bare harnessParams (tag only, no attrs/text/slots)", () => {
  const { harnessParams } = driveState(richTooltipEntry, richTooltipFigmaExport, {
    axisValues: {},
    propValues: {},
  });
  assert.equal(harnessParams.tag, "m3e-rich-tooltip");
  assert.deepEqual(harnessParams.attrs, {});
  assert.equal(harnessParams.text, undefined);
  assert.deepEqual(harnessParams.slots, {});
});

test("drive (RC4): standalone entry figmaNodeQuery points directly at the standalone node (not a set/variant)", () => {
  const { figmaNodeQuery } = driveState(richTooltipEntry, richTooltipFigmaExport, {
    axisValues: {},
    propValues: {},
  });
  assert.equal(figmaNodeQuery.nodeId, "RT_NODE");
  assert.equal(figmaNodeQuery.setNodeId, null, "no setNodeId — not a variant of any set");
  assert.equal(figmaNodeQuery.tier, "exact");
});

test("drive (RC4): buildDefaultState for standalone returns the minimal state (empty axisValues/propValues)", () => {
  const state = buildDefaultState(richTooltipEntry, richTooltipFigmaExport);
  assert.deepEqual(state.axisValues, {});
  assert.deepEqual(state.propValues, {});
  assert.equal(state.setNodeId, "RT_NODE");
});

test("drive (RC4): standalone state flattens to just the tag url param (no attr.* or slot.* params)", () => {
  const { harnessParams } = driveState(richTooltipEntry, richTooltipFigmaExport, {
    axisValues: {},
    propValues: {},
  });
  const params = toHarnessUrlParams(harnessParams);
  assert.equal(params.tag, "m3e-rich-tooltip");
  assert.equal(Object.keys(params).length, 1, "only 'tag' key — no attr.* or slot.* params");
});

// -- RC6 (snackbar): fully-unmapped axes are named consistently ----------------
//
// The snackbar has an axis "# of lines" (with a literal `#` character in the
// name). The `displayNameOf` function in src/ingest/figma.mjs must NOT strip
// it as a Figma node-id suffix (only `#digits:digits` suffixes are stripped).
// This test exercises drive.mjs indirectly (via the entry shape the real
// matcher now generates) but the core contract tested here is the axis-naming
// consistency: assertFullyMapped must accept an entry that names the axis
// exactly as `# of lines` (matching what the figma export calls it in
// setProperties), and the driver must pin it to its default without confusion.
const snackbarFigmaExport = {
  data: {
    components: [
      { id: "SNACK_SET", name: "Snackbar", type: "COMPONENT_SET" },
      { id: "SNACK_V1", name: "Configuration=Text only, # of lines=One line, Show close affordance=False", type: "COMPONENT" },
      { id: "SNACK_V2", name: "Configuration=Text only, # of lines=Two lines, Show close affordance=False", type: "COMPONENT" },
    ],
    setProperties: {
      SNACK_SET: [
        { type: "VARIANT", name: "Configuration", defaultValue: "Text only" },
        { type: "VARIANT", name: "# of lines", defaultValue: "One line" },
        { type: "VARIANT", name: "Show close affordance", defaultValue: "False" },
        { type: "TEXT", name: "Supporting text#53937:0", defaultValue: "Snackbar supporting text" },
      ],
    },
  },
};

const snackbarEntry = {
  cemTag: "m3e-snackbar",
  matcherKind: "set",
  figmaSets: [{ nodeId: "SNACK_SET", setName: "Snackbar", fixedAttrs: {} }],
  axes: [
    { figmaProp: "Configuration", unmapped: "no CEM enum attribute shares its value set (options: Text only, Text & action, Text & longer action)" },
    { figmaProp: "# of lines", unmapped: "no CEM enum attribute shares its value set (options: One line, Two lines)" },
    { figmaProp: "Show close affordance", unmapped: "no CEM enum attribute shares its value set (options: False, True)" },
  ],
  props: [
    { figmaProp: "Supporting text", kind: "text", binding: "content" },
  ],
};

test("drive (RC6 snackbar): '# of lines' axis is named consistently — assertFullyMapped accepts it without error", () => {
  // driveState calls assertFullyMapped internally. If the figmaProp in the entry
  // doesn't match the axis name from setProperties, it throws. This test verifies
  // they match now that displayNameOf no longer strips the leading '#'.
  assert.doesNotThrow(() => {
    driveState(snackbarEntry, snackbarFigmaExport, {
      axisValues: {},
      propValues: { "Supporting text": "Test" },
    });
  });
});

// -- Multi-boolean axis: checkbox Type → {checked, indeterminate} -------------
//
// A multi-boolean axis (kind:"multi-boolean", attrs:[{attr,valueMap}]) drives
// ALL sub-attrs per the selected Figma option using HTML boolean-attribute
// presence semantics: attr present (value "") when "true", absent when "false".
// Single-attr axes and existing boolean axes must be unaffected.

const checkboxFigmaExport = {
  data: {
    components: [
      { id: "CB_SET", name: "Checkboxes", type: "COMPONENT_SET" },
      { id: "CB_SELECTED", name: "Type=Selected, State=Enabled", type: "COMPONENT" },
      { id: "CB_UNSELECTED", name: "Type=Unselected, State=Enabled", type: "COMPONENT" },
      { id: "CB_INDET", name: "Type=Indeterminate, State=Enabled", type: "COMPONENT" },
      { id: "CB_ERR_SEL", name: "Type=Error selected, State=Enabled", type: "COMPONENT" },
      { id: "CB_ERR_INDET", name: "Type=Error indeterminate, State=Enabled", type: "COMPONENT" },
      { id: "CB_ERR_UNSEL", name: "Type=Error unselected, State=Enabled", type: "COMPONENT" },
    ],
    setProperties: {
      CB_SET: [
        { type: "VARIANT", name: "Type", defaultValue: "Unselected" },
        { type: "VARIANT", name: "State", defaultValue: "Enabled" },
        { type: "BOOLEAN", name: "Show focus indicator#123:0", defaultValue: false },
      ],
    },
  },
};

const checkboxEntry = {
  cemTag: "m3e-checkbox",
  matcherKind: "set",
  figmaSets: [{ nodeId: "CB_SET", setName: "Checkboxes", fixedAttrs: {} }],
  axes: [
    {
      figmaProp: "Type",
      kind: "multi-boolean",
      attrs: [
        {
          attr: "checked",
          valueMap: {
            Selected: "true",
            Unselected: "false",
            Indeterminate: "false",
            "Error unselected": "false",
            "Error indeterminate": "false",
            "Error selected": "true",
          },
        },
        {
          attr: "indeterminate",
          valueMap: {
            Selected: "false",
            Unselected: "false",
            Indeterminate: "true",
            "Error unselected": "false",
            "Error indeterminate": "true",
            "Error selected": "false",
          },
        },
      ],
    },
    {
      figmaProp: "State",
      unmapped: "no CEM enum attribute shares its value set (options: Enabled, Hovered, Focused, Pressed, Disabled)",
    },
  ],
  props: [
    {
      figmaProp: "Show focus indicator",
      kind: "boolean",
      unmapped: "no CEM counterpart (Figma-only property)",
    },
  ],
};

test("drive (multi-boolean): Selected → checked present, indeterminate absent", () => {
  const { harnessParams, figmaNodeQuery } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Selected" },
  });
  assert.equal(harnessParams.attrs.checked, "", "checked present (empty string = boolean on)");
  assert.equal("indeterminate" in harnessParams.attrs, false, "indeterminate absent");
  assert.equal(figmaNodeQuery.nodeId, "CB_SELECTED");
});

test("drive (multi-boolean): Unselected → neither checked nor indeterminate present", () => {
  const { harnessParams, figmaNodeQuery } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Unselected" },
  });
  assert.equal("checked" in harnessParams.attrs, false, "checked absent");
  assert.equal("indeterminate" in harnessParams.attrs, false, "indeterminate absent");
  assert.equal(figmaNodeQuery.nodeId, "CB_UNSELECTED");
});

test("drive (multi-boolean): Indeterminate → indeterminate present, checked absent", () => {
  const { harnessParams, figmaNodeQuery } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Indeterminate" },
  });
  assert.equal("checked" in harnessParams.attrs, false, "checked absent");
  assert.equal(harnessParams.attrs.indeterminate, "", "indeterminate present");
  assert.equal(figmaNodeQuery.nodeId, "CB_INDET");
});

test("drive (multi-boolean): Error selected → checked present, indeterminate absent", () => {
  const { harnessParams, figmaNodeQuery } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Error selected" },
  });
  assert.equal(harnessParams.attrs.checked, "", "checked present");
  assert.equal("indeterminate" in harnessParams.attrs, false, "indeterminate absent");
  assert.equal(figmaNodeQuery.nodeId, "CB_ERR_SEL");
});

test("drive (multi-boolean): Error indeterminate → indeterminate present, checked absent", () => {
  const { harnessParams } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Error indeterminate" },
  });
  assert.equal("checked" in harnessParams.attrs, false, "checked absent");
  assert.equal(harnessParams.attrs.indeterminate, "", "indeterminate present");
});

test("drive (multi-boolean): toHarnessUrlParams reflects presence/absence correctly", () => {
  const { harnessParams: sel } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Selected" },
  });
  const selParams = toHarnessUrlParams(sel);
  assert.ok("attr.checked" in selParams, "Selected → attr.checked param present");
  assert.equal("attr.indeterminate" in selParams, false, "Selected → attr.indeterminate absent");

  const { harnessParams: unsel } = driveState(checkboxEntry, checkboxFigmaExport, {
    axisValues: { Type: "Unselected" },
  });
  const unselParams = toHarnessUrlParams(unsel);
  assert.equal("attr.checked" in unselParams, false, "Unselected → attr.checked absent");
  assert.equal("attr.indeterminate" in unselParams, false, "Unselected → attr.indeterminate absent");
});

test("drive (multi-boolean): single-attr boolean axis (switch) still works after multi-boolean change (regression)", () => {
  // Re-use the switchEntry fixture from above: single-attr boolean axis,
  // must remain unaffected by the multi-boolean path.
  const { harnessParams: on } = driveState(switchEntry, figmaExport, { axisValues: { Selected: "True" } });
  assert.equal(on.attrs.checked, "", "switch Selected=True still sets checked");
  const { harnessParams: off } = driveState(switchEntry, figmaExport, { axisValues: { Selected: "False" } });
  assert.equal("checked" in off.attrs, false, "switch Selected=False still omits checked");
});

test("drive (RC6 snackbar): default state resolves the '# of lines=One line' variant without error", () => {
  const { harnessParams, figmaNodeQuery } = driveState(snackbarEntry, snackbarFigmaExport, {
    axisValues: {},
    propValues: { "Supporting text": "Hello" },
  });
  assert.equal(harnessParams.tag, "m3e-snackbar");
  assert.equal(harnessParams.text, "Hello");
  // All axes are unmapped — no CEM attrs are emitted.
  assert.deepEqual(harnessParams.attrs, {});
  // The variant node with the default axis values is resolved.
  assert.equal(figmaNodeQuery.nodeId, "SNACK_V1", "default '# of lines=One line' variant resolved");
});

// -- RC5 literalIcon: boolean-gated fixed icon in a named slot (search-bar) ---
//
// A Figma BOOLEAN prop (e.g. "Show leading icon") gates a FIXED icon whose
// name is hardcoded in the correspondence entry (not an instanceSwap — the
// icon is not user-configurable in Figma, it's locked to the component's
// design). When true, emit "m3e-icon:<iconName>" in the named slot. When
// false, the slot stays absent. This is RC5 from the triage plan.

// Minimal synthetic export for a search-bar-like component:
//   - BOOLEAN prop "Show leading icon" (default true) → literalIcon "search"
//   - BOOLEAN prop "Show 1st trailing icon" (default true) → literalIcon "menu"
//   - TEXT prop "Placeholder text" → slot:input with slotTag:"input"
//   - BOOLEAN prop "Show 2nd trailing icon" (default false) → unmapped
//   - Two VARIANT axes (State, Show avatar) → both unmapped
const searchBarFigmaExport = {
  data: {
    components: [
      { id: "SB_SET", name: "Search bar", type: "COMPONENT_SET" },
      { id: "SB_V1", name: "State=Enabled, Show avatar=False", type: "COMPONENT" },
      { id: "SB_V2", name: "State=Hovered, Show avatar=False", type: "COMPONENT" },
    ],
    setProperties: {
      SB_SET: [
        { name: "Show 2nd trailing icon#3294:13", type: "BOOLEAN", defaultValue: false },
        { name: "Show 1st trailing icon#3294:26", type: "BOOLEAN", defaultValue: true },
        { name: "Placeholder text#52999:1337", type: "TEXT", defaultValue: "Hinted search text" },
        { name: "Show leading icon#58115:0", type: "BOOLEAN", defaultValue: true },
        { name: "State", type: "VARIANT", defaultValue: "Enabled", variantOptions: ["Enabled", "Hovered"] },
        { name: "Show avatar", type: "VARIANT", defaultValue: "False", variantOptions: ["False", "True"] },
      ],
    },
  },
};

const searchBarEntry = {
  cemTag: "m3e-search-bar",
  matcherKind: "set",
  figmaSets: [{ nodeId: "SB_SET", setName: "Search bar", fixedAttrs: {} }],
  axes: [
    { figmaProp: "State", unmapped: "no CEM enum attribute shares its value set" },
    { figmaProp: "Show avatar", unmapped: "no CEM enum attribute shares its value set" },
  ],
  props: [
    { figmaProp: "Show 2nd trailing icon", kind: "boolean", unmapped: "no CEM counterpart (Figma-only property)" },
    { figmaProp: "Show 1st trailing icon", kind: "literalIcon", binding: "slot:trailing", iconName: "menu" },
    { figmaProp: "Placeholder text", kind: "text", binding: "slot:input", slotTag: "input" },
    { figmaProp: "Show leading icon", kind: "literalIcon", binding: "slot:leading", iconName: "search" },
  ],
};

test("drive (RC5 literalIcon): true value emits 'm3e-icon:<iconName>' in the named slot", () => {
  const { harnessParams } = driveState(searchBarEntry, searchBarFigmaExport, {
    axisValues: {},
    propValues: {
      "Show 2nd trailing icon": false,
      "Show 1st trailing icon": true,
      "Placeholder text": "Hinted search text",
      "Show leading icon": true,
    },
  });
  assert.equal(harnessParams.slots["leading"], "m3e-icon:search", "leading slot gets the search icon");
  assert.equal(harnessParams.slots["trailing"], "m3e-icon:menu", "trailing slot gets the menu icon");
});

test("drive (RC5 literalIcon): false value omits the slot entirely", () => {
  const { harnessParams } = driveState(searchBarEntry, searchBarFigmaExport, {
    axisValues: {},
    propValues: {
      "Show 2nd trailing icon": false,
      "Show 1st trailing icon": false,   // menu icon suppressed
      "Placeholder text": "Search",
      "Show leading icon": false,         // search icon suppressed
    },
  });
  assert.equal("leading" in harnessParams.slots, false, "leading slot absent when Show leading icon=false");
  assert.equal("trailing" in harnessParams.slots, false, "trailing slot absent when Show 1st trailing icon=false");
});

test("drive (RC5 literalIcon): toHarnessUrlParams encodes the icon correctly as slot.<name>=m3e-icon:<iconName>", () => {
  const { harnessParams } = driveState(searchBarEntry, searchBarFigmaExport, {
    axisValues: {},
    propValues: {
      "Show 2nd trailing icon": false,
      "Show 1st trailing icon": true,
      "Placeholder text": "Hinted search text",
      "Show leading icon": true,
    },
  });
  const params = toHarnessUrlParams(harnessParams);
  assert.equal(params["slot.leading"], "m3e-icon:search");
  assert.equal(params["slot.trailing"], "m3e-icon:menu");
});

test("drive (RC5 text slotTag): text prop with slotTag encodes as '<tag>:<text>' in slot content", () => {
  const { harnessParams } = driveState(searchBarEntry, searchBarFigmaExport, {
    axisValues: {},
    propValues: {
      "Show 2nd trailing icon": false,
      "Show 1st trailing icon": false,
      "Placeholder text": "Hinted search text",
      "Show leading icon": false,
    },
  });
  assert.equal(harnessParams.slots["input"], "input:Hinted search text", "input slot uses slotTag prefix");
  const params = toHarnessUrlParams(harnessParams);
  assert.equal(params["slot.input"], "input:Hinted search text");
});

test("drive (RC5): buildDefaultState for search-bar produces correct default propValues (Show leading icon=true)", () => {
  const state = buildDefaultState(searchBarEntry, searchBarFigmaExport);
  assert.equal(state.propValues["Show leading icon"], true, "Show leading icon defaults to true");
  assert.equal(state.propValues["Show 1st trailing icon"], true, "Show 1st trailing icon defaults to true");
  assert.equal(state.propValues["Placeholder text"], "Hinted search text");
});

test("drive (RC5): default state drives all three slots (leading icon + input + trailing icon)", () => {
  const state = buildDefaultState(searchBarEntry, searchBarFigmaExport);
  const { harnessParams } = driveState(searchBarEntry, searchBarFigmaExport, state);
  assert.equal(harnessParams.slots["leading"], "m3e-icon:search");
  assert.equal(harnessParams.slots["input"], "input:Hinted search text");
  assert.equal(harnessParams.slots["trailing"], "m3e-icon:menu");
  assert.deepEqual(harnessParams.attrs, {}, "no CEM attrs driven (all axes unmapped)");
  assert.equal(harnessParams.text, undefined, "no default-slot text (Placeholder text is in slot:input)");
});

test("drive (RC5 literalIcon): missing iconName field throws a helpful error at assertFullyMapped time", () => {
  const brokenEntry = {
    ...searchBarEntry,
    props: searchBarEntry.props.map((p) =>
      p.figmaProp === "Show leading icon"
        ? { figmaProp: p.figmaProp, kind: "literalIcon", binding: "slot:leading" } // iconName missing
        : p
    ),
  };
  assert.throws(
    () => driveState(brokenEntry, searchBarFigmaExport, { axisValues: {}, propValues: {} }),
    /literalIcon prop 'Show leading icon'.*must carry an 'iconName' field/
  );
});

test("drive (RC5 literalIcon): literalIcon bound to a non-slot binding throws", () => {
  // An ill-formed entry where literalIcon doesn't bind to a slot must throw,
  // not silently corrupt attrs.
  const brokenEntry = {
    ...searchBarEntry,
    props: searchBarEntry.props.map((p) =>
      p.figmaProp === "Show leading icon"
        ? { figmaProp: p.figmaProp, kind: "literalIcon", binding: "some-attr", iconName: "search" }
        : p
    ),
  };
  assert.throws(
    () => driveState(brokenEntry, searchBarFigmaExport, {
      axisValues: {},
      propValues: { "Show 2nd trailing icon": false, "Show 1st trailing icon": false, "Placeholder text": "x", "Show leading icon": true },
    }),
    /literalIcon prop 'Show leading icon'.*must bind to a slot/
  );
});

test("driveState attaches boundsPx to harnessParams when a capture bound is supplied", () => {
  const entry = { cemTag: "m3e-shape", matcherKind: "standalone", figmaSets: [{ nodeId: "1:1", setName: "S" }], axes: [], props: [] };
  const { harnessParams } = driveState(entry, { data: { meta: {} } }, { setNodeId: "1:1", axisValues: {}, propValues: {}, boundsPx: { w: 640, h: 640 } });
  assert.deepEqual(harnessParams.boundsPx, { w: 640, h: 640 });
});

test("toHarnessUrlParams serializes boundsPx as dotted string keys (boundsPx.w / boundsPx.h)", () => {
  const params = toHarnessUrlParams({
    tag: "m3e-button",
    attrs: {},
    slots: {},
    boundsPx: { w: 800, h: 400 },
  });
  assert.equal(params["boundsPx.w"], "800", "boundsPx.w must be the string '800'");
  assert.equal(params["boundsPx.h"], "400", "boundsPx.h must be the string '400'");
});
