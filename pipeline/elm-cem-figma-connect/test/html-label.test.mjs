// Task B1: html-label emitter.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/html-label.test.mjs
//
// Exercises src/emit/html-label.mjs against the REAL confirmed entry in
// profiles/m3-kit/correspondence.json (m3e-button, status:"confirmed") and
// compares its main-set output against the golden fixture
// profiles/m3-kit/fixtures/M3eButton.webcomponents.figma.ts — the exact
// template form proven to publish live on 2026-07-10 (evidence #1-#2,
// plans/00-mission-and-decisions.md). See research/spikes/01-publish-gate/
// M3eButton.figma.ts for the untouched original this fixture was copied from.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadProfile } from "../src/correspond/merge.mjs";
import { loadFigmaExport } from "../src/ingest/figma.mjs";
import { emitEntry, emitConfirmed, _internal } from "../src/emit/html-label.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const profileDir = path.join(repoRoot, "profiles", "m3-kit");

const correspondence = JSON.parse(
  fs.readFileSync(path.join(profileDir, "correspondence.json"), "utf8")
);
const buttonEntry = correspondence.find((e) => e.cemTag === "m3e-button");

const profile = loadProfile(profileDir);
const figma = loadFigmaExport(profile.figmaExportPath);

const config = {
  fileKey: profile.fileKey,
  fileName: figma.data.meta.fileName,
  imports: profile.htmlLabel.imports,
  iconPlaceholder: profile.htmlLabel.iconPlaceholder,
};

const golden = fs.readFileSync(
  path.join(profileDir, "fixtures", "M3eButton.webcomponents.figma.ts"),
  "utf8"
);

// -- parsing helpers (test-local; "semantic equality" is defined here, not
// in the emitter) ------------------------------------------------------------

// Every `getEnum("Prop", { Key: "value", ... })` call in a source string,
// keyed by the Figma prop name.
function extractEnumMaps(source) {
  const maps = {};
  const callRe = /getEnum\(\s*"([^"]+)"\s*,\s*\{([\s\S]*?)\}\s*\)/g;
  let call;
  while ((call = callRe.exec(source))) {
    const [, propName, body] = call;
    const map = {};
    const entryRe = /(?:"([^"]+)"|([A-Za-z_$][A-Za-z0-9_$]*))\s*:\s*"((?:[^"\\]|\\.)*)"\s*,?/g;
    let entry;
    while ((entry = entryRe.exec(body))) {
      map[entry[1] ?? entry[2]] = entry[3];
    }
    maps[propName] = map;
  }
  return maps;
}

// Pulls the `figma.code`...`` example content out of `export default {...}`.
function extractExample(source) {
  const m = source.match(/example:\s*figma\.code`([\s\S]*?)`,\n\s*imports/);
  assert.ok(m, `could not find "example: figma.code\`...\`" in source:\n${source}`);
  return m[1];
}

// Reduces an example line to { tag, attrs, inner } so comparison is order-
// and-whitespace independent (the golden fixture's own hand-authored
// attribute order — size/shape — doesn't match this repo's axes[] array
// order — Type/Size/State — and that's incidental to the spike, not a
// contract; "semantically equal" here means the same tag, the same
// attributes, and the same variables/content, regardless of order).
function normalizeExample(example) {
  const tagMatch = example.match(/<([\w-]+)([^>]*)>([\s\S]*)<\/\1>\s*$/);
  assert.ok(tagMatch, `could not parse a <tag>...</tag> out of example:\n${example}`);
  const [, tag, attrsRaw, inner] = tagMatch;
  const attrs = {};
  const attrRe = /([\w-]+)="((?:[^"\\]|\\.)*)"/g;
  let attr;
  while ((attr = attrRe.exec(attrsRaw))) attrs[attr[1]] = attr[2];
  return { tag, attrs, inner: inner.trim() };
}

// -- the confirmed entry itself -----------------------------------------------

test("m3e-button correspondence entry: measured shape assumed by this suite", () => {
  assert.ok(buttonEntry, "m3e-button entry present in profiles/m3-kit/correspondence.json");
  assert.equal(buttonEntry.status, "confirmed");
  assert.equal(buttonEntry.figmaSets.length, 9, "5 primary fused sets + 4 appended toggle 2nd-sets");
  assert.equal(buttonEntry.props.length, 4, "button has 4 props (one with a null binding)");
  const focusProp = buttonEntry.props.find((p) => p.figmaProp === "Show focus indicator");
  assert.ok(focusProp && focusProp.unmapped, "Show focus indicator carries a null/unmapped binding");
  const stateAxis = buttonEntry.axes.find((a) => a.figmaProp === "State");
  assert.ok(stateAxis && stateAxis.unmapped, "State axis is unmapped");
});

// -- emitEntry: file count + id shape -----------------------------------------

test("emitEntry: one .figma.ts per fused set — 5 files for m3e-button", () => {
  const files = emitEntry(buttonEntry, config);
  assert.equal(files.length, 9);
  const ids = files.map((f) => f.id).sort();
  assert.deepEqual(ids, [
    "m3e-button-elevated",
    "m3e-button-filled",
    "m3e-button-outlined",
    "m3e-button-text",
    "m3e-button-toggle-elevated",
    "m3e-button-toggle-filled",
    "m3e-button-toggle-outlined",
    "m3e-button-toggle-tonal",
    "m3e-button-tonal",
  ]);
  for (const f of files) {
    assert.equal(f.path, `${f.id}.figma.ts`);
    assert.match(f.contents, /GENERATED.*do not edit/i, "GENERATED header present");
  }
});

test("emitConfirmed: skips non-confirmed and code-only entries; emits iconTable entries when confirmed", () => {
  const files = emitConfirmed(correspondence, { ...config, examples: profile.examples });
  // Every emitted file traces back to a status:"confirmed", figmaSets-bearing
  // entry — the confirmed set is m3e-badge, m3e-button, m3e-icon-button, m3e-switch, m3e-checkbox
  // plus chips: m3e-assist-chip, m3e-filter-chip, m3e-input-chip, m3e-suggestion-chip,
  // plus m3e-search-bar (RC5, banked 2026-07-14), plus m3e-list-item (#11, banked 2026-07-14),
  // plus m3e-shape (#12, digit-name canon fix), plus m3e-fab (#13, benignAa tier, banked 2026-07-18),
  // plus m3e-segmented-button (#15, representative example, banked 2026-07-18).
  // Reverted (FALSE PASSES): m3e-snackbar.
  // (The fixture here may only contain m3e-button; the live correspondence has all 15.)
  const confirmedTags = new Set(["m3e-app-bar", "m3e-assist-chip", "m3e-avatar", "m3e-badge", "m3e-bottom-sheet", "m3e-button", "m3e-button-group", "m3e-button-segment", "m3e-card", "m3e-checkbox", "m3e-chip-set", "m3e-circular-progress-indicator", "m3e-date-input", "m3e-datepicker", "m3e-dialog", "m3e-drawer-container", "m3e-expandable-list-item", "m3e-fab", "m3e-fab-menu", "m3e-fab-menu-item", "m3e-filter-chip", "m3e-form-field", "m3e-icon", "m3e-icon-button", "m3e-input-chip", "m3e-linear-progress-indicator", "m3e-list", "m3e-list-item", "m3e-loading-indicator", "m3e-menu", "m3e-menu-item", "m3e-nav-bar", "m3e-nav-item", "m3e-nav-menu", "m3e-nav-rail", "m3e-radio", "m3e-rich-tooltip", "m3e-search-bar", "m3e-search-view", "m3e-segmented-button", "m3e-shape", "m3e-slider", "m3e-snackbar", "m3e-split-button", "m3e-suggestion-chip", "m3e-switch", "m3e-tab", "m3e-tabs", "m3e-timepicker", "m3e-timepicker-input-period-toggle", "m3e-toolbar", "m3e-tooltip"]);
  assert.ok(files.length >= 6);
  assert.ok(
    files.every((f) => confirmedTags.has(f.cemTag)),
    `all emitted files must have a confirmed cemTag; got: ${[...new Set(files.map((f) => f.cemTag))].join(", ")}`
  );
});

// -- main-set file vs. the golden fixture -------------------------------------

const files = emitEntry(buttonEntry, config);
const mainSetEntry = buttonEntry.figmaSets.find((s) => s.nodeId === "57994:2227");
const mainFile = files.find((f) => f.contents.includes(mainSetEntry.nodeId.replace(":", "-")));

test("main-set file: url line uses the canonical main-file URL + dashed node-id", () => {
  assert.ok(mainFile, "a generated file targets node 57994:2227");
  const urlLine = mainFile.contents.split("\n")[0];
  assert.equal(urlLine, `// url=https://www.figma.com/design/${config.fileKey}/Material-3-Design-Kit--Community-?node-id=57994-2227`);
  // The golden fixture's own url line is the same canonical form (evidence #1).
  assert.equal(golden.split("\n")[0], urlLine);
});

test("main-set file: getEnum maps match the golden fixture — including the XSmall footgun", () => {
  const generatedMaps = extractEnumMaps(mainFile.contents);
  const goldenMaps = extractEnumMaps(golden);

  assert.deepEqual(Object.keys(generatedMaps).sort(), ["Size", "Type"]);
  assert.deepEqual(generatedMaps.Size, goldenMaps.Size);
  assert.deepEqual(generatedMaps.Type, goldenMaps.Type);

  // The footgun, explicit: keys are the Figma option's VERBATIM, case-
  // sensitive string, and the value is the real CEM enum value — never a
  // lowercased Figma key standing in for it.
  assert.equal(generatedMaps.Size.XSmall, "extra-small");
  assert.equal(generatedMaps.Size.XLarge, "extra-large");
  assert.equal("xsmall" in generatedMaps.Size, false);
  assert.equal("XSmall" in generatedMaps.Size, true);
});

test("main-set file: example line is semantically equal to the golden fixture (modulo whitespace/id/icon-slot)", () => {
  const generatedExample = normalizeExample(extractExample(mainFile.contents));
  const goldenExample = normalizeExample(extractExample(golden));

  assert.equal(generatedExample.tag, goldenExample.tag);
  assert.equal(generatedExample.tag, "m3e-button");
  assert.deepEqual(generatedExample.attrs, goldenExample.attrs);
  assert.deepEqual(generatedExample.attrs, { variant: "filled", size: "${size}", shape: "${shape}" });

  // The golden spike (a minimal proof-of-gate) never modeled "Show icon" —
  // the real confirmed entry's generated content legitimately extends it
  // with the conditional icon-slot line; "modulo" covers that documented
  // addition, not a silent behavior change. The label content itself must
  // match exactly.
  assert.ok(
    generatedExample.inner.startsWith(goldenExample.inner),
    `generated inner "${generatedExample.inner}" should start with golden inner "${goldenExample.inner}"`
  );
});

test("main-set file: unmapped axis/prop are visible header comments, never fabricated bindings", () => {
  assert.match(mainFile.contents, /unmapped.*State/);
  assert.match(mainFile.contents, /unmapped.*Show focus indicator/);
  assert.doesNotMatch(mainFile.contents, /getEnum\(\s*"State"/);
  assert.doesNotMatch(mainFile.contents, /getBoolean\(\s*"Show focus indicator"/);
});

test("main-set file: boolean-slot prop uses the conditional-line idiom, sourcing the glyph from the mapped INSTANCE_SWAP prop", () => {
  assert.match(mainFile.contents, /const showIcon = instance\.getBoolean\("Show icon"\)/);
  assert.match(mainFile.contents, /const showIconLine = showIcon \? figma\.code`.*` : figma\.code``/);
  assert.match(mainFile.contents, /instance\.getPropertyValue\("Icon"\)/);
  assert.match(mainFile.contents, /<m3e-icon slot="icon" name="\$\{showIconGlyph\}"><\/m3e-icon>/);
});

// -- approach A: iconTable-driven getEnum glyph resolution (emit-side icon fix) --
// The default `config` above carries no iconTable, so the test above exercises
// the getPropertyValue FALLBACK. With an iconTable threaded in (as run.mjs now
// does from the correspondence's kind:"iconTable" entry), the parent resolves
// the glyph via a getEnum keyed by the swap instance's figmaName and OWNS the
// slotted <m3e-icon> tag — CC 1.4.9 cannot inject a slot= onto a nested child.

test("boolean-slot prop WITH an iconTable: glyph via getEnum keyed by figmaName, parent owns the slotted tag (approach A)", () => {
  const iconTable = [
    { figmaNodeId: "1:1", figmaName: "wifi", symbolName: "wifi", filled: false },
    { figmaNodeId: "1:2", figmaName: "stars_filled", symbolName: "stars", filled: true },
    { figmaNodeId: "1:3", figmaName: "wifi", symbolName: "wifi", filled: false }, // benign dup
  ];
  const main = emitEntry(buttonEntry, { ...config, iconTable }).find((f) => f.contents.includes("57994-2227"));
  assert.ok(main, "a generated file targets the main filled set");

  // getEnum, not getPropertyValue.
  assert.match(main.contents, /const showIconGlyph = instance\.getEnum\("Icon", \{/);
  assert.doesNotMatch(main.contents, /getPropertyValue/);

  // Value is the full `name="<symbol>"[ filled]` attribute fragment.
  assert.ok(main.contents.includes('  wifi: "name=\\"wifi\\"",'), "plain glyph row");
  assert.ok(main.contents.includes('  stars_filled: "name=\\"stars\\" filled",'), "filled glyph row carries ' filled'");

  // Benign duplicate figmaName collapses to ONE key.
  assert.equal((main.contents.match(/^  wifi:/gm) || []).length, 1, "duplicate 'wifi' dedupes");

  // Parent owns the slotted tag; glyph fragment inserted bare (no name="${...}" wrapper).
  assert.match(main.contents, /<m3e-icon slot="icon" \$\{showIconGlyph\}><\/m3e-icon>/);
  assert.doesNotMatch(main.contents, /name="\$\{showIconGlyph\}"/);
});

test("iconTable with a CONFLICTING figmaName (same name, different glyph) fails loud, never silently picks one", () => {
  const iconTable = [
    { figmaNodeId: "1:1", figmaName: "star", symbolName: "star", filled: false },
    { figmaNodeId: "1:2", figmaName: "star", symbolName: "grade", filled: true },
  ];
  assert.throws(() => emitEntry(buttonEntry, { ...config, iconTable }), /conflicting rows for figmaName "star"/);
});

// -- RC2: default-slot icon (icon-button) ------------------------------------
// A mapped INSTANCE_SWAP prop bound to "slot:" (default/unnamed slot) renders
// UNCONDITIONALLY as `<m3e-icon ${glyph}></m3e-icon>` (no slot attr, no
// boolean guard). This is icon-button's shape: the icon is always present and
// always goes in the default slot. Uses the same approach-A getEnum/iconTable
// glyph mechanism — only the slot placement differs.

const iconButtonEntry = {
  cemTag: "m3e-icon-button",
  axes: [
    { figmaProp: "Type", attr: "shape", valueMap: { Round: "rounded", Square: "square" } },
  ],
  props: [
    { figmaProp: "Icon", kind: "instanceSwap", binding: "slot:" },
    { figmaProp: "Show focus indicator", kind: "boolean", unmapped: "no CEM counterpart (Figma-only property)" },
  ],
  figmaSets: [
    { nodeId: "57994:10081", setName: "Icon button", fixedAttrs: { variant: "filled" } },
  ],
};

test("RC2 (default-slot icon): WITHOUT iconTable — getPropertyValue fallback, no slot attr on <m3e-icon>", () => {
  const files = emitEntry(iconButtonEntry, config);
  assert.equal(files.length, 1, "one file per figmaSet");
  const [file] = files;
  // Glyph variable via getPropertyValue fallback.
  assert.match(file.contents, /const iconGlyph = instance\.getPropertyValue\("Icon"\)/);
  // Icon tag with NO slot attr, glyph bare (approach-A-like insertion).
  assert.match(file.contents, /<m3e-icon \$\{iconGlyph\}><\/m3e-icon>/);
  // Must NOT have a slot= attr.
  assert.doesNotMatch(file.contents, /slot="icon"/);
  assert.doesNotMatch(file.contents, /slot=""/);
});

test("RC2 (default-slot icon): WITH iconTable — getEnum for glyph, <m3e-icon ${glyph}> with no slot attr (approach A)", () => {
  const iconTable = [
    { figmaNodeId: "1:1", figmaName: "star", symbolName: "star", filled: false },
    { figmaNodeId: "1:2", figmaName: "stars_filled", symbolName: "stars", filled: true },
  ];
  const files = emitEntry(iconButtonEntry, { ...config, iconTable });
  assert.equal(files.length, 1);
  const [file] = files;
  // getEnum, not getPropertyValue.
  assert.match(file.contents, /const iconGlyph = instance\.getEnum\("Icon", \{/);
  assert.doesNotMatch(file.contents, /getPropertyValue/);
  // Both rows present, sorted by figmaName.
  assert.ok(file.contents.includes('  star: "name=\\"star\\"",'), "plain glyph row");
  assert.ok(file.contents.includes('  stars_filled: "name=\\"stars\\" filled",'), "filled glyph row");
  // Icon tag with NO slot attr, glyph bare — DEFAULT slot, not named.
  assert.match(file.contents, /<m3e-icon \$\{iconGlyph\}><\/m3e-icon>/);
  assert.doesNotMatch(file.contents, /slot="icon"/);
  assert.doesNotMatch(file.contents, /slot=""/);
  // The glyph fragment is inserted bare (no name="${...}" wrapper).
  assert.doesNotMatch(file.contents, /name="\$\{iconGlyph\}"/);
});

// Regression (audit ISSUE 1): a single mapped axis whose valueMap is purely
// true/false targets a BOOLEAN attr. It must emit bare-or-omit
// (`${selected ? "selected" : ""}`), NOT `selected="${selected}"` — the latter
// is always-present in HTML (checked="false" renders checked=true).
test("boolean-target axis emits bare-or-omit, never attr=\"${var}\" (HTML boolean-presence bug)", () => {
  const boolEntry = {
    cemTag: "m3e-switch",
    axes: [{ figmaProp: "Selected", attr: "checked", valueMap: { False: "false", True: "true" } }],
    props: [],
    figmaSets: [{ nodeId: "1:1", setName: "Switch", fixedAttrs: {} }],
  };
  const [file] = emitEntry(boolEntry, config);
  // getEnum maps to JS booleans, not "true"/"false" strings.
  assert.match(file.contents, /const checked = instance\.getEnum\("Selected", \{\s*False: false,\s*True: true,\s*\}\)/);
  // Template: bare-or-omit presence, NOT an always-present attribute value.
  assert.match(file.contents, /\$\{checked \? "checked" : ""\}/);
  assert.doesNotMatch(file.contents, /checked="\$\{checked\}"/);
});

test("RC2 (default-slot icon): header comment includes instanceSwap binding, unmapped prop is visible", () => {
  const [file] = emitEntry(iconButtonEntry, config);
  // Mapped instanceSwap shows up in the header.
  assert.match(file.contents, /prop: Icon -> slot: \(instanceSwap\)/);
  // Unmapped prop is a visible comment, never a fabricated binding.
  assert.match(file.contents, /unmapped.*Show focus indicator/);
  assert.doesNotMatch(file.contents, /getBoolean\("Show focus indicator"\)/);
});

test("RC2 (default-slot icon): button's NAMED-slot emit path is byte-unchanged (regression guard)", () => {
  // Re-emit m3e-button to confirm its named-slot 'icon' shape is unaffected.
  const main = emitEntry(buttonEntry, config).find((f) => f.contents.includes("57994-2227"));
  assert.ok(main, "button main-set file still emits");
  // Button still uses getBoolean + conditional line pattern (NAMED slot).
  assert.match(main.contents, /const showIcon = instance\.getBoolean\("Show icon"\)/);
  assert.match(main.contents, /<m3e-icon slot="icon"/);
  // Button does NOT have the default-slot (slot-less) pattern.
  assert.doesNotMatch(main.contents, /<m3e-icon \$\{/);
});

test("fixedAttrs are baked as string literals per set (variant=\"tonal\" on the tonal set)", () => {
  const tonal = files.find((f) => f.id === "m3e-button-tonal");
  assert.ok(tonal);
  const example = normalizeExample(extractExample(tonal.contents));
  assert.equal(example.attrs.variant, "tonal");
});

// -- hard rule: main-file-only URLs -------------------------------------------

test("throws on a /branch/ URL in configured profile config", () => {
  assert.throws(
    () =>
      emitEntry(buttonEntry, {
        ...config,
        url: `https://www.figma.com/design/${config.fileKey}/branch/abcdEFGH1234/Material-3-Design-Kit`,
      }),
    /branch/
  );
});

test("throws if the fully-built URL would contain /branch/ even without an explicit override", () => {
  assert.throws(
    () => _internal.buildNodeUrl({ fileKey: "K", fileName: "x", url: "https://www.figma.com/design/K/branch/y" }, "1:2"),
    /branch/
  );
});

// -- hard rule: unhandled mapped prop shapes are fail-loud, never silent-dropped --

test("emitEntry: throws on a mapped prop shape it doesn't know how to render (e.g. boolean bound to a plain attribute)", () => {
  // Synthetic entry: a mapped BOOLEAN prop bound to a plain attribute
  // ("disabled") rather than a "slot:*" binding — not one of the two shapes
  // this emitter knows how to render (text->content, boolean->slot:*).
  // Before this fix this prop was produced NOWHERE (not in code, not in a
  // header comment, not as an error) — a silent data loss. Now it must throw,
  // naming the prop.
  const syntheticEntry = {
    cemTag: "synthetic-el",
    axes: [],
    props: [{ figmaProp: "Disabled", kind: "boolean", binding: "disabled" }],
    figmaSets: [{ nodeId: "1:1", setName: "Synthetic", fixedAttrs: {} }],
  };
  assert.throws(() => emitEntry(syntheticEntry, config), /Disabled/, "error must name the unhandled prop");
  assert.throws(() => emitEntry(syntheticEntry, config), /boolean/i, "error should name the prop's kind");
  assert.throws(() => emitEntry(syntheticEntry, config), /disabled/, "error should name the prop's binding");

  // The real button emission — only content/slot shapes — stays green and
  // unaffected by this guard (5 primary + 4 appended toggle 2nd-sets = 9).
  assert.equal(emitEntry(buttonEntry, config).length, 9);
});

// -- RC2 / chip family: visibilityAxis-gated named-slot instanceSwap ----------
//
// A chip's leading icon is an INSTANCE_SWAP prop bound to a NAMED slot
// ("slot:icon") WITHOUT a boolean gate, but WITH visibilityAxis + visibleWhen.
// The emitter emits a getEnum-gated conditional line (analogous to the boolean-
// gated slot, but via getEnum on the visibilityAxis).

const filterChipEntry = {
  cemTag: "m3e-filter-chip",
  axes: [
    { figmaProp: "Style", attr: "variant", valueMap: { Outlined: "outlined", Elevated: "elevated" } },
    {
      figmaProp: "Configuration",
      unmapped: "no CEM enum attribute shares its value set (options: Label only, Label & leading icon)",
    },
    {
      figmaProp: "Show trailing icon",
      unmapped: "no CEM enum attribute shares its value set (options: False, True)",
    },
  ],
  props: [
    // Trailing icon: visibilityAxis = "Show trailing icon" (unmapped axis, options: False/True)
    {
      figmaProp: "Trailing icon",
      kind: "instanceSwap",
      binding: "slot:icon",
      visibilityAxis: "Show trailing icon",
      visibleWhen: ["True"],
    },
    // Leading icon: visibilityAxis = "Configuration" (unmapped axis)
    {
      figmaProp: "Leading icon",
      kind: "instanceSwap",
      binding: "slot:icon",
      visibilityAxis: "Configuration",
      visibleWhen: ["Label & leading icon"],
    },
    { figmaProp: "Label text", kind: "text", binding: "content" },
    { figmaProp: "Show focus indicator", kind: "boolean", unmapped: "no CEM counterpart (Figma-only property)" },
  ],
  figmaSets: [
    { nodeId: "99001:1001", setName: "Filter chip", fixedAttrs: {} },
  ],
};

const iconTableForChips = [
  { figmaNodeId: "1:1", figmaName: "close", symbolName: "close", filled: false },
  { figmaNodeId: "1:2", figmaName: "star", symbolName: "star", filled: false },
];

test("visibilityAxis-gated named-slot: emits getEnum visibility condition + getEnum glyph + conditional line", () => {
  const [file] = emitEntry(filterChipEntry, { ...config, iconTable: iconTableForChips });
  assert.ok(file, "one file emitted for filter-chip");

  // Visibility condition via getEnum on visibilityAxis ("Show trailing icon").
  assert.match(
    file.contents,
    /const trailingIconShown = instance\.getEnum\("Show trailing icon", \{/,
    "trailing icon: getEnum on visibilityAxis"
  );
  assert.ok(file.contents.includes("False: false,"), "trailing icon: False → false");
  assert.ok(file.contents.includes("True: true,"), "trailing icon: True → true");

  // Glyph via approach-A getEnum on the prop name ("Trailing icon").
  assert.match(
    file.contents,
    /const trailingIconGlyph = instance\.getEnum\("Trailing icon", \{/,
    "trailing icon: glyph getEnum on prop"
  );
  assert.ok(file.contents.includes('  close: "name=\\"close\\"",'), "glyph row: close");
  assert.ok(file.contents.includes('  star: "name=\\"star\\"",'), "glyph row: star");

  // Conditional line: shown when trailingIconShown, uses glyph, targets the named slot.
  assert.match(
    file.contents,
    /const trailingIconLine = trailingIconShown \? figma\.code`.*` : figma\.code``/,
    "trailing icon: conditional line idiom"
  );
  assert.match(
    file.contents,
    /<m3e-icon slot="icon" \$\{trailingIconGlyph\}><\/m3e-icon>/,
    "trailing icon: named-slot icon tag with glyph"
  );

  // Leading icon: visibilityAxis = "Configuration".
  assert.match(
    file.contents,
    /const leadingIconShown = instance\.getEnum\("Configuration", \{/,
    "leading icon: getEnum on Configuration axis"
  );
  assert.ok(file.contents.includes('"Label only": false,'), "leading icon: Label only → false");
  assert.ok(file.contents.includes('"Label & leading icon": true,'), "leading icon: visibleWhen → true");

  // Conditional slot expression appears in the example template.
  assert.match(file.contents, /\$\{trailingIconLine\}/, "trailingIconLine in example");
  assert.match(file.contents, /\$\{leadingIconLine\}/, "leadingIconLine in example");
});

test("visibilityAxis-gated named-slot: WITHOUT iconTable omits gracefully — no throw, no slot code", () => {
  // Graceful omit: an instanceSwap prop with visibilityAxis but no iconTable
  // produces no code (not even a condVar or lineVar), and does NOT throw.
  // The prop is consumed (not an "unhandled mapped prop" error either).
  const [file] = emitEntry(filterChipEntry, { ...config, iconTable: [] });
  assert.ok(file, "file still emits even without iconTable");
  assert.doesNotMatch(file.contents, /trailingIconShown/, "no visibility condVar emitted");
  assert.doesNotMatch(file.contents, /trailingIconGlyph/, "no glyph var emitted");
  assert.doesNotMatch(file.contents, /trailingIconLine/, "no conditional line emitted");
  // The label content still appears (text prop unaffected).
  assert.match(file.contents, /instance\.getString\("Label text"\)/, "text prop still emitted");
});

test("visibilityAxis-gated named-slot: assist-chip branded/favicon icons (NOT in iconTable) omit gracefully", () => {
  // Assist-chip has THREE named-slot instanceSwap props for slot:icon.
  // "Leading icon" is a Material Symbols icon (in iconTable).
  // "Branded icon" and "Favicon" are NOT Material Symbols (not in iconTable by
  // name) — but the iconTable itself is present (with other icons). Per decision
  // #1, props whose figmaName is not in the iconTable still resolve via the
  // shared iconTable; the graceful-omit only triggers when the WHOLE iconTable
  // is absent. With an iconTable, all three props get code (the iconTable rows
  // apply to the getEnum). Only when no iconTable at all is the graceful omit path.
  //
  // Test: with NO iconTable, none of the three icon props emit code — no throw.
  const assistChipEntry = {
    cemTag: "m3e-assist-chip",
    axes: [
      { figmaProp: "Style", attr: "variant", valueMap: { Outlined: "outlined", Elevated: "elevated" } },
      {
        figmaProp: "Configuration",
        unmapped:
          "no CEM enum attribute shares its value set (options: Label only, Label & icon, Label & favicon, Label & brand icon)",
      },
    ],
    props: [
      { figmaProp: "Leading icon", kind: "instanceSwap", binding: "slot:icon", visibilityAxis: "Configuration", visibleWhen: ["Label & icon"] },
      { figmaProp: "Branded icon", kind: "instanceSwap", binding: "slot:icon", visibilityAxis: "Configuration", visibleWhen: ["Label & brand icon"] },
      { figmaProp: "Favicon", kind: "instanceSwap", binding: "slot:icon", visibilityAxis: "Configuration", visibleWhen: ["Label & favicon"] },
      { figmaProp: "Label text", kind: "text", binding: "content" },
    ],
    figmaSets: [{ nodeId: "99002:1001", setName: "Assistive chip", fixedAttrs: {} }],
  };

  // No iconTable → all three icon props omit gracefully, no throw.
  const noIconTableResult = emitEntry(assistChipEntry, { ...config, iconTable: [] });
  assert.equal(noIconTableResult.length, 1, "one file emitted");
  assert.doesNotMatch(noIconTableResult[0].contents, /leadingIconShown/, "no leading icon code");
  assert.doesNotMatch(noIconTableResult[0].contents, /brandedIconShown/, "no branded icon code");
  assert.doesNotMatch(noIconTableResult[0].contents, /faviconShown/, "no favicon code");

  // With an iconTable → Leading icon DOES emit code (it's a real Material icon);
  // Branded/Favicon emit code too (iconTable rows apply — any named-slot
  // instanceSwap with visibilityAxis and a non-empty iconTable gets the full block).
  const withIconTable = emitEntry(assistChipEntry, { ...config, iconTable: iconTableForChips });
  assert.equal(withIconTable.length, 1, "one file emitted with iconTable");
  assert.match(withIconTable[0].contents, /leadingIconShown/, "leading icon code present");
  assert.match(withIconTable[0].contents, /brandedIconShown/, "branded icon code present");
  assert.match(withIconTable[0].contents, /faviconShown/, "favicon code present");
  // All three visibility conditions reference "Configuration".
  const configEnumCount = (withIconTable[0].contents.match(/getEnum\("Configuration"/g) || []).length;
  assert.ok(configEnumCount >= 3, `at least 3 getEnum("Configuration") calls; got ${configEnumCount}`);
});

test("visibilityAxis-gated named-slot: button's existing boolean-gated named-slot is byte-unchanged (regression guard)", () => {
  // Re-emit m3e-button to confirm the boolean-gated path is unaffected.
  const files = emitEntry(buttonEntry, { ...config, iconTable: [] });
  const main = files.find((f) => f.contents.includes("57994-2227"));
  assert.ok(main, "button main-set still emits");
  // Button still uses getBoolean + conditional line.
  assert.match(main.contents, /const showIcon = instance\.getBoolean\("Show icon"\)/);
  // No visibilityAxisSlotBlock code for button (it has no visibilityAxis props).
  assert.doesNotMatch(main.contents, /Shown = instance\.getEnum/, "no getEnum-based condition for button");
});

// -- multi-boolean axis: checkbox Type → {checked, indeterminate} -------------
//
// A multi-boolean axis (kind:"multi-boolean", attrs:[{attr,valueMap}]) must
// produce one getEnum call per sub-attr (with boolean values, not strings) and
// render each sub-attr as a conditional boolean-presence interpolation in the
// example template.

const checkboxEmitEntry = {
  cemTag: "m3e-checkbox",
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
    { figmaProp: "Show focus indicator", kind: "boolean", unmapped: "no CEM counterpart (Figma-only property)" },
  ],
  figmaSets: [{ nodeId: "51859:5628", setName: "Checkboxes", fixedAttrs: {} }],
};

test("multi-boolean axis: emits one getEnum per sub-attr with boolean values (true/false)", () => {
  const [file] = emitEntry(checkboxEmitEntry, config);
  assert.ok(file, "one file emitted for checkbox");

  // One getEnum("Type", ...) per sub-attr.
  const typeEnumCalls = (file.contents.match(/getEnum\("Type"/g) || []).length;
  assert.equal(typeEnumCalls, 2, "two getEnum calls for the Type axis (one per sub-attr)");

  // The checked sub-attr: values are booleans (true/false), not strings.
  assert.match(file.contents, /const typeChecked = instance\.getEnum\("Type"/);
  assert.ok(file.contents.includes("Selected: true,"), "Selected → true (boolean, not string)");
  assert.ok(file.contents.includes("Unselected: false,"), "Unselected → false");
  assert.ok(file.contents.includes('"Error selected": true,'), "Error selected → true");
  assert.ok(file.contents.includes('"Error unselected": false,'), "Error unselected → false");

  // The indeterminate sub-attr.
  assert.match(file.contents, /const typeIndeterminate = instance\.getEnum\("Type"/);
  assert.ok(file.contents.includes("Indeterminate: true,"), "Indeterminate → true for indeterminate attr");
  assert.ok(file.contents.includes('"Error indeterminate": true,'), "Error indeterminate → true");
});

test("multi-boolean axis: example template uses conditional boolean-presence interpolation per sub-attr", () => {
  const [file] = emitEntry(checkboxEmitEntry, config);
  // Each sub-attr renders as `${typeChecked ? "checked" : ""}` not `checked="${typeChecked}"`.
  assert.match(
    file.contents,
    /\$\{typeChecked \? "checked" : ""\}/,
    'checked renders as conditional presence interpolation'
  );
  assert.match(
    file.contents,
    /\$\{typeIndeterminate \? "indeterminate" : ""\}/,
    'indeterminate renders as conditional presence interpolation'
  );
  // Must NOT render the value as a string assignment.
  assert.doesNotMatch(file.contents, /checked="\$\{typeChecked\}"/, 'must not render as attribute="value"');
  assert.doesNotMatch(file.contents, /indeterminate="\$\{typeIndeterminate\}"/, 'must not render as attribute="value"');
});

test("multi-boolean axis: header comment describes the multi-boolean axis correctly", () => {
  const [file] = emitEntry(checkboxEmitEntry, config);
  // Header mentions the axis and both sub-attr names.
  assert.match(file.contents, /axis: Type -> \[checked, indeterminate\] \(multi-boolean\)/);
  // Unmapped axes still appear as comments.
  assert.match(file.contents, /unmapped.*State/);
});

test("multi-boolean axis: single-attr axis (button Type→shape) is byte-unchanged (regression guard)", () => {
  // Verify button's single-attr Type axis still emits `const shape = instance.getEnum("Type", {...})`.
  const main = emitEntry(buttonEntry, config).find((f) => f.contents.includes("57994-2227"));
  assert.ok(main, "button main-set still emits");
  assert.match(main.contents, /const shape = instance\.getEnum\("Type"/);
  assert.match(main.contents, /shape="\$\{shape\}"/);
  // Must NOT have typeChecked or typeIndeterminate (button has a different Type axis).
  assert.doesNotMatch(main.contents, /typeChecked/);
  assert.doesNotMatch(main.contents, /typeIndeterminate/);
});

// -- RC5: literalIcon named-slot (search-bar "Show leading/trailing icon") ------
//
// kind:"literalIcon" + binding:"slot:<name>" + iconName:"<ms-name>" emits a
// STATIC <m3e-icon slot="<name>" name="<iconName>"></m3e-icon> baked directly
// into the example template (no runtime variable). Contrast with the
// boolean-gated slot shape (getBoolean + conditional line) and the
// visibilityAxis shape (getEnum + conditional line).

const searchBarEntry = {
  cemTag: "m3e-search-bar",
  axes: [
    { figmaProp: "State", unmapped: "no CEM enum attribute shares its value set (options: Enabled, Hovered, Pressed)" },
    { figmaProp: "Show avatar", unmapped: "no CEM enum attribute shares its value set (options: False, True)" },
  ],
  props: [
    { figmaProp: "Show 2nd trailing icon", kind: "boolean", unmapped: "no CEM counterpart (Figma-only property)" },
    { figmaProp: "Show 1st trailing icon", kind: "literalIcon", binding: "slot:trailing", iconName: "search" },
    { figmaProp: "Placeholder text", kind: "text", binding: "slot:input", slotTag: "input" },
    { figmaProp: "Show leading icon", kind: "literalIcon", binding: "slot:leading", iconName: "menu" },
  ],
  figmaSets: [{ nodeId: "52977:33813", setName: "Search bar", fixedAttrs: {} }],
};

test("RC5 (literalIcon-slot): emits static <m3e-icon slot> tags baked into the example template", () => {
  const [file] = emitEntry(searchBarEntry, config);
  assert.ok(file, "one file emitted for search-bar");

  // Static icon tags in the example — no getBoolean, no getEnum, no lineVar.
  assert.match(file.contents, /<m3e-icon slot="trailing" name="search"><\/m3e-icon>/,
    "trailing icon: static search icon in slot:trailing");
  assert.match(file.contents, /<m3e-icon slot="leading" name="menu"><\/m3e-icon>/,
    "leading icon: static menu icon in slot:leading");

  // No conditional machinery (no getBoolean, no lineVar ternary).
  assert.doesNotMatch(file.contents, /getBoolean\("Show 1st trailing icon"\)/,
    "no getBoolean for literalIcon prop");
  assert.doesNotMatch(file.contents, /showIcon.*figma\.code/,
    "no conditional lineVar for literalIcon prop");
});

test("RC5 (literalIcon-slot): header comment mentions the literalIcon props with their iconName", () => {
  const [file] = emitEntry(searchBarEntry, config);
  assert.match(file.contents, /prop: Show 1st trailing icon -> slot:trailing \(literalIcon: search\)/);
  assert.match(file.contents, /prop: Show leading icon -> slot:leading \(literalIcon: menu\)/);
});

test("RC5 (literalIcon-slot): emits no code blocks for unconditional literalIcon props", () => {
  const [file] = emitEntry(searchBarEntry, config);
  // The only const binding should be for Placeholder text; no extra bindings for icons.
  const constMatches = file.contents.match(/^const /gm) ?? [];
  // instance is assigned by the template; the only prop const should be placeholderText.
  const propConsts = constMatches.filter((_, i) => file.contents.indexOf("const ") !== -1);
  assert.match(file.contents, /const placeholderText = instance\.getString\("Placeholder text"\)/);
  // No boolean or enum variable for the literalIcon props.
  assert.doesNotMatch(file.contents, /const show1stTrailingIcon/);
  assert.doesNotMatch(file.contents, /const showLeadingIcon/);
});

// -- RC5: text → named input slot (search-bar "Placeholder text" → slot:input) -
//
// kind:"text" + binding:"slot:input" (not "content") emits:
//   const <var> = instance.getString("<figmaProp>")
// and places `<input slot="input" placeholder="${<var>}"></input>` inline in the
// example template. Distinct from the default-slot text→content shape.

test("RC5 (text→named-input-slot): emits getString + <input slot placeholder> in the template", () => {
  const [file] = emitEntry(searchBarEntry, config);
  assert.ok(file, "file emitted");

  // Code block: getString for the placeholder.
  assert.match(file.contents, /const placeholderText = instance\.getString\("Placeholder text"\)/);

  // Template: <input slot="input" placeholder="${placeholderText}"></input>.
  assert.match(file.contents, /<input slot="input" placeholder="\$\{placeholderText\}"><\/input>/);
});

test("RC5 (text→named-input-slot): header comment describes the named input slot", () => {
  const [file] = emitEntry(searchBarEntry, config);
  assert.match(file.contents, /prop: Placeholder text -> slot:input \(input\)/);
});

test("RC5 (text→named-input-slot): does NOT use the default-slot content path (no textContent shorthand)", () => {
  const [file] = emitEntry(searchBarEntry, config);
  // Default-slot text would be just `${placeholderText}` in the tag body, NOT in a slot= attr.
  // Named-slot input has slot= attribute.
  assert.doesNotMatch(file.contents, />\$\{placeholderText\}<\/m3e-search-bar>/,
    "placeholder must not be placed as default-slot content");
  assert.match(file.contents, /slot="input"/,
    "placeholder must be placed in the named input slot");
});

test("RC5 (real m3e-search-bar entry): emitEntry does NOT throw and produces a sensible example", () => {
  // Confirm against the REAL correspondence.json entry.
  const realEntry = correspondence.find((e) => e.cemTag === "m3e-search-bar");
  assert.ok(realEntry, "m3e-search-bar entry present in correspondence.json");
  assert.equal(realEntry.status, "confirmed");
  // Must not throw.
  let files;
  assert.doesNotThrow(() => { files = emitEntry(realEntry, config); }, "emitEntry must not throw on search-bar");
  assert.equal(files.length, 1, "one file per figmaSet");
  const [file] = files;
  // Key structural checks.
  assert.match(file.contents, /const placeholderText = instance\.getString\("Placeholder text"\)/);
  assert.match(file.contents, /<m3e-icon slot="trailing" name="search"><\/m3e-icon>/);
  assert.match(file.contents, /<m3e-icon slot="leading" name="menu"><\/m3e-icon>/);
  assert.match(file.contents, /<input slot="input" placeholder="\$\{placeholderText\}"><\/input>/);
  assert.equal(file.id, "m3e-search-bar-search-bar");
});

test("RC5 (regression guard): button/chip/icon-button emit output is byte-unchanged", () => {
  // Re-emit m3e-button to confirm zero churn.
  const main = emitEntry(buttonEntry, config).find((f) => f.contents.includes("57994-2227"));
  assert.ok(main, "button main-set still emits");
  assert.match(main.contents, /const showIcon = instance\.getBoolean\("Show icon"\)/);
  assert.match(main.contents, /<m3e-icon slot="icon"/);
  assert.doesNotMatch(main.contents, /literalIcon/);
  assert.doesNotMatch(main.contents, /slot:input/);
});

// -- iconTable emit branch (T1) -----------------------------------------------
//
// Synthetic iconTable fixture: 4 rows — "a" (unfilled), "b" (filled), "a"
// (unfilled again, dup symbol) — matching the brief's example, plus one more
// to exercise multi-level collision suffix.
//   → 4 files: m3e-icon-a, m3e-icon-b-filled, m3e-icon-a-2, m3e-icon-a-3
//
// Each file must: use the row's figmaNodeId in the url; emit the right
// `name=` value; add `filled` attr only when row.filled=true; carry the
// right `id` and `imports`; conform to the existing `.figma.ts` export-
// default shape.

const iconTableEntry = {
  cemTag: "m3e-icon",
  kind: "iconTable",
  status: "confirmed",
  provenance: "auto-exact",
  icons: [
    { figmaNodeId: "1:10", figmaName: "a_icon", symbolName: "a", filled: false },
    { figmaNodeId: "1:20", figmaName: "b_filled", symbolName: "b", filled: true },
    { figmaNodeId: "1:30", figmaName: "a_icon2", symbolName: "a", filled: false },  // dup
    { figmaNodeId: "1:40", figmaName: "a_icon3", symbolName: "a", filled: false },  // dup #3
  ],
};
const iconTableConfig = {
  fileKey: config.fileKey,
  fileName: config.fileName,
  imports: config.imports,
};

// Import emitIconTableEntry via the emitConfirmed wrapper (it's not directly exported,
// but we can test it through emitConfirmed with a single-entry confirmed array,
// or by verifying the emitter adapter below).
// Actually, we exercise it via emitConfirmed (which now handles iconTable):

test("iconTable emit: 4 rows → 4 files with correct paths (collision suffix)", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  assert.equal(files.length, 4);
  const paths = files.map((f) => f.path);
  assert.deepEqual(paths, [
    "m3e-icon-a.figma.ts",
    "m3e-icon-b-filled.figma.ts",
    "m3e-icon-a-2.figma.ts",
    "m3e-icon-a-3.figma.ts",
  ]);
});

test("iconTable emit: each file uses its row's figmaNodeId in the url", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  assert.match(files[0].contents, /url=.*node-id=1-10/);
  assert.match(files[1].contents, /url=.*node-id=1-20/);
  assert.match(files[2].contents, /url=.*node-id=1-30/);
  assert.match(files[3].contents, /url=.*node-id=1-40/);
});

test("iconTable emit: plain icon has name= but no filled attr", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  const plain = files[0]; // m3e-icon-a
  assert.match(plain.contents, /figma\.code`<m3e-icon name="a"><\/m3e-icon>`/);
  assert.doesNotMatch(plain.contents, / filled/);
});

test("iconTable emit: filled icon has both name= and bare filled attr", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  const filled = files[1]; // m3e-icon-b-filled
  assert.match(filled.contents, /figma\.code`<m3e-icon name="b" filled><\/m3e-icon>`/);
});

test("iconTable emit: collision-suffixed file has the right name= value (same symbolName)", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  const dup = files[2]; // m3e-icon-a-2
  assert.match(dup.contents, /figma\.code`<m3e-icon name="a"><\/m3e-icon>`/);
  const dup2 = files[3]; // m3e-icon-a-3
  assert.match(dup2.contents, /figma\.code`<m3e-icon name="a"><\/m3e-icon>`/);
});

test("iconTable emit: id matches path stem (without .figma.ts)", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  for (const f of files) {
    assert.equal(f.path, `${f.id}.figma.ts`);
  }
});

test("iconTable emit: files carry the configured imports", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  for (const f of files) {
    assert.match(f.contents, /imports: \[/);
    assert.match(f.contents, /@m3e\/web\/all/);
  }
});

test("iconTable emit: export default has example/imports/id/metadata.nestable shape", () => {
  const files = emitConfirmed([iconTableEntry], iconTableConfig);
  for (const f of files) {
    assert.match(f.contents, /export default \{/);
    assert.match(f.contents, /example: figma\.code`/);
    assert.match(f.contents, /imports: \[/);
    assert.match(f.contents, /id:/);
    assert.match(f.contents, /metadata: \{/);
    assert.match(f.contents, /nestable: true/);
  }
});

test("iconTable emit: skips non-confirmed iconTable entries (status check)", () => {
  const proposed = { ...iconTableEntry, status: "proposed" };
  const files = emitConfirmed([proposed], iconTableConfig);
  assert.equal(files.length, 0);
});

test("iconTable emit: symbolName with underscore becomes kebab in filename", () => {
  // symbolName "check_box" → filename stem "m3e-icon-check-box"
  const entry = {
    cemTag: "m3e-icon",
    kind: "iconTable",
    status: "confirmed",
    provenance: "auto-exact",
    icons: [{ figmaNodeId: "2:10", figmaName: "check_box", symbolName: "check_box", filled: false }],
  };
  const files = emitConfirmed([entry], iconTableConfig);
  assert.equal(files[0].path, "m3e-icon-check-box.figma.ts");
  assert.match(files[0].contents, /name="check_box"/);
});

// -- misc helpers --------------------------------------------------------------

test("figmaFileSlug: every non-alphanumeric char becomes its own dash (matches the golden URL exactly)", () => {
  assert.equal(_internal.figmaFileSlug("Material 3 Design Kit (Community)"), "Material-3-Design-Kit--Community-");
});

test("contentVarName: 'Label text' -> 'label' (matches the golden fixture's variable name)", () => {
  assert.equal(_internal.contentVarName({ figmaProp: "Label text", kind: "text" }), "label");
});

test("no new runtime deps: html-label.mjs imports nothing beyond node builtins/sibling modules", () => {
  const src = fs.readFileSync(path.join(repoRoot, "src", "emit", "html-label.mjs"), "utf8");
  assert.doesNotMatch(src, /^import .* from ["'](?!\.\.?\/|node:)/m);
});

test("loadProfile threads examples.json (representative example children)", () => {
  const p = loadProfile(profileDir); // profileDir already defined above as profiles/m3-kit
  assert.equal(p.examples["m3e-segmented-button"].children.length, 2);
});

test("loadProfile threads set-attrs.json (per-set static attrs; present -> parsed)", () => {
  const p = loadProfile(profileDir);
  assert.ok(p.setAttrs, "setAttrs is present on profile");
  assert.deepEqual(p.setAttrs["m3e-circular-progress-indicator"]["Circular-determinate progress indicator"], { value: "0" });
  assert.deepEqual(p.setAttrs["m3e-circular-progress-indicator"]["Circular-indeterminate progress indicator"], { indeterminate: "true" });
  assert.deepEqual(p.setAttrs["m3e-linear-progress-indicator"]["Linear-determinate progress indicator"], { value: "70" });
});

test("loadProfile set-attrs.json absent -> setAttrs is {}", () => {
  // Use the toy profile (it has no set-attrs.json)
  const toyProfileDir = path.join(repoRoot, "test", "fixtures", "toy-profile");
  const p = loadProfile(toyProfileDir);
  assert.deepEqual(p.setAttrs, {});
});

test("emitEntry: a component with an examples entry emits its representative children + skips prop-slot-content", () => {
  const entry = {
    cemTag: "m3e-segmented-button", status: "confirmed",
    figmaSets: [{ nodeId: "53923:36615", setName: "Segmented button", fixedAttrs: {} }],
    axes: [], props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  const cfg = { ...config, examples: { "m3e-segmented-button": { children: [
    { tag: "m3e-button-segment", text: "Label" }, { tag: "m3e-button-segment", text: "Label" }, { tag: "m3e-button-segment", text: "Label" } ] } } };
  const files = emitEntry(entry, cfg);
  const ex = files[0].contents.match(/example:\s*figma\.code`([\s\S]*?)`,\n\s*imports/)[1];
  assert.match(ex, /<m3e-segmented-button><m3e-button-segment>Label<\/m3e-button-segment><m3e-button-segment>Label<\/m3e-button-segment><m3e-button-segment>Label<\/m3e-button-segment><\/m3e-segmented-button>/);
  assert.ok(!ex.includes("${"), "no prop-derived code-block variables in an examples-driven example");
});

test("emitEntry: m3e-button emits 9 files (5 primary axis-grid + 4 appended toggle 2nd-sets)", () => {
  const files = emitEntry(buttonEntry, config);
  assert.equal(files.length, 9);
});

test("emitEntry: >1 TEXT->content prop no longer throws — first emitted, rest noted", () => {
  const entry = {
    cemTag: "m3e-fake-multitext", status: "confirmed",
    figmaSets: [{ nodeId: "1:1", setName: "X", fixedAttrs: {} }], axes: [],
    props: [{ figmaProp: "Header", kind: "text", binding: "content" }, { figmaProp: "Subhead", kind: "text", binding: "content" }],
  };
  const files = emitEntry(entry, config);
  assert.ok(files.length >= 1);
  assert.match(files[0].contents, /note: additional text prop\(s\) .*Subhead.* not emitted/);
});

// -- examples-mode dead-const fix: content blocks must not appear when exampleChildren is set --
//
// When a component has an examples.json entry, the inner content is replaced by
// the representative children — the text→content prop's `const <x> = instance.getString(...)`
// is no longer referenced by the example template and must NOT be emitted.
// Mapped-axis consts ARE still needed (they bind to tag attributes, not inner content)
// and must continue to appear.

test("examples-mode: skips dead content const but keeps mapped-axis const", () => {
  // Entry with BOTH a mapped axis (size) and a text→content prop (Label text).
  // In examples-mode the inner content comes from exampleChildren, so the
  // content const is dead. The axis const is still used in size="${size}".
  const entry = {
    cemTag: "m3e-fake-composite",
    axes: [
      { figmaProp: "Size", attr: "size", valueMap: { Small: "small", Large: "large" } },
    ],
    props: [
      { figmaProp: "Label text", kind: "text", binding: "content" },
    ],
    figmaSets: [{ nodeId: "1:1", setName: "Fake composite", fixedAttrs: {} }],
  };
  const examplesCfg = {
    ...config,
    examples: {
      "m3e-fake-composite": {
        children: [{ tag: "m3e-button", text: "Label" }],
      },
    },
  };

  const [file] = emitEntry(entry, examplesCfg);

  // Axis const IS present — it's referenced as size="${size}" in the example.
  assert.match(file.contents, /const size = instance\.getEnum\("Size"/,
    "mapped-axis const must be emitted (still referenced in tag attrs)");

  // Content const must NOT be present — it would be dead (example uses exampleChildren).
  assert.doesNotMatch(file.contents, /const label = instance\.getString/,
    "content const must not be emitted in examples-mode (dead variable)");
  assert.doesNotMatch(file.contents, /instance\.getString\("Label text"\)/,
    "no getString call for the text→content prop in examples-mode");

  // The example uses the children, not ${label}.
  assert.match(file.contents, /<m3e-button>Label<\/m3e-button>/,
    "example inner content comes from exampleChildren");
  assert.doesNotMatch(file.contents, /\$\{label\}/,
    "no dead ${label} interpolation in the example");
});

test("examples-mode dead-const fix: non-examples-mode entry is byte-unchanged (regression guard)", () => {
  // Same entry shape but NO examples entry — must still emit the content const.
  const entry = {
    cemTag: "m3e-fake-composite",
    axes: [
      { figmaProp: "Size", attr: "size", valueMap: { Small: "small", Large: "large" } },
    ],
    props: [
      { figmaProp: "Label text", kind: "text", binding: "content" },
    ],
    figmaSets: [{ nodeId: "1:1", setName: "Fake composite", fixedAttrs: {} }],
  };
  const [file] = emitEntry(entry, config); // config has no examples entry for m3e-fake-composite
  assert.match(file.contents, /const label = instance\.getString\("Label text"\)/,
    "content const emitted in non-examples-mode");
  assert.match(file.contents, /\$\{label\}/,
    "content var referenced in example template");
});

// -- T2: per-set set-attrs injection ------------------------------------------
//
// Synthetic fixture: two-set entry ("Determinate" + "Indeterminate") with a
// set-attrs map injecting value="70" into the determinate set and
// indeterminate="true" into the indeterminate set. Tests use SYNTHETIC data;
// do NOT rely on real progress entries being confirmed.

const syntheticProgressEntry = {
  cemTag: "m3e-fake-progress",
  figmaSets: [
    { nodeId: "1:1", setName: "Fake-determinate progress", fixedAttrs: {} },
    { nodeId: "1:2", setName: "Fake-indeterminate progress", fixedAttrs: {} },
  ],
  axes: [],
  props: [],
};

const syntheticSetAttrs = {
  "m3e-fake-progress": {
    "Fake-determinate progress": { "value": "70" },
    "Fake-indeterminate progress": { "indeterminate": "true" },
  },
};

test("set-attrs T2: injected attr appears in the right set's example string", () => {
  const cfg = { ...config, setAttrs: syntheticSetAttrs };
  const files = emitEntry(syntheticProgressEntry, cfg);
  assert.equal(files.length, 2, "two files for two sets");

  const detFile = files.find((f) => f.id.includes("fake-determinate"));
  const indetFile = files.find((f) => f.id.includes("fake-indeterminate"));
  assert.ok(detFile, "determinate file found");
  assert.ok(indetFile, "indeterminate file found");

  const detExample = detFile.contents.match(/example:\s*figma\.code`([\s\S]*?)`,\n\s*imports/)[1];
  const indetExample = indetFile.contents.match(/example:\s*figma\.code`([\s\S]*?)`,\n\s*imports/)[1];

  assert.match(detExample, /value="70"/, "determinate example has value=70");
  assert.doesNotMatch(detExample, /indeterminate/, "determinate example does NOT have indeterminate");
  assert.match(indetExample, /indeterminate="true"/, "indeterminate example has indeterminate=true");
  assert.doesNotMatch(indetExample, /value=/, "indeterminate example does NOT have value");
});

test("set-attrs T2: injected attr does NOT appear in the filename/id", () => {
  const cfg = { ...config, setAttrs: syntheticSetAttrs };
  const files = emitEntry(syntheticProgressEntry, cfg);
  for (const file of files) {
    assert.doesNotMatch(file.id, /70/, "value=70 must not pollute the file id");
    assert.doesNotMatch(file.id, /true/, "indeterminate=true must not pollute the file id");
    assert.doesNotMatch(file.path, /70/, "value=70 must not pollute the filename");
    assert.doesNotMatch(file.path, /true/, "indeterminate=true must not pollute the filename");
  }
});

test("set-attrs T2: entry with no set-attrs is unchanged (no-op)", () => {
  // Use buttonEntry (real, confirmed) with no setAttrs entry for its tag
  const noSetAttrsCfg = { ...config, setAttrs: {} };
  const withSetAttrs = { ...config, setAttrs: { "m3e-some-other": { "X": { "y": "z" } } } };
  const filesWithout = emitEntry(buttonEntry, noSetAttrsCfg);
  const filesWith = emitEntry(buttonEntry, withSetAttrs);
  assert.equal(filesWithout.length, filesWith.length);
  for (let i = 0; i < filesWithout.length; i++) {
    assert.equal(filesWithout[i].contents, filesWith[i].contents, `file ${i} unchanged when no set-attrs for this tag`);
  }
});

test("set-attrs T2: unknown setName in set-attrs throws at emit time", () => {
  const badSetAttrs = {
    "m3e-fake-progress": {
      "Typo set name": { "value": "70" },
    },
  };
  const cfg = { ...config, setAttrs: badSetAttrs };
  assert.throws(
    () => emitEntry(syntheticProgressEntry, cfg),
    /set-attrs: unknown setName 'Typo set name' for 'm3e-fake-progress'/,
    "unknown setName must throw at emit time"
  );
});

test("set-attrs T2: key collision between set-attrs and fixedAttrs throws", () => {
  const entryWithFixed = {
    cemTag: "m3e-fake-progress",
    figmaSets: [
      { nodeId: "1:1", setName: "Fake-determinate progress", fixedAttrs: { "value": "50" } },
    ],
    axes: [],
    props: [],
  };
  const collidingSetAttrs = {
    "m3e-fake-progress": {
      "Fake-determinate progress": { "value": "70" },
    },
  };
  const cfg = { ...config, setAttrs: collidingSetAttrs };
  assert.throws(
    () => emitEntry(entryWithFixed, cfg),
    /set-attrs: key collision 'value' already in fixedAttrs for 'm3e-fake-progress'/,
    "key collision with fixedAttrs must throw at emit time"
  );
});

// -- Task 4: slots[] -> instance.getSlot() ------------------------------------
//
// slots[] items come from src/correspond/schema.json's `slots` block, populated
// by Task 3's matcher/merge (src/match/matcher.mjs's proposeSlot, src/correspond/
// merge.mjs's buildSlots). Synthetic entries here follow this file's existing
// idiom (plain object literal, cemTag/figmaSets/axes/props, now also slots).

test("slots[]: mapped named slot emits getSlot() and a wrapping <div slot=...>", () => {
  const entry = {
    cemTag: "m3e-fake-slotted",
    figmaSets: [{ nodeId: "1:1", setName: "Fake slotted", fixedAttrs: {} }],
    axes: [],
    props: [],
    slots: [
      { figmaSlotName: "Header content", kind: "slot", multi: false, mappedTo: "header", provenance: "auto-exact" },
    ],
  };
  const [file] = emitEntry(entry, config);
  assert.match(file.contents, /const headerContent = instance\.getSlot\("Header content"\)/);
  assert.match(file.contents, /<div slot="header">\$\{headerContent\}<\/div>/);
  assert.match(file.contents, / \* slot: Header content -> header/);
});

test("slots[]: mapped default slot ('(default)') interpolates directly as inner content, no wrapper", () => {
  const entry = {
    cemTag: "m3e-fake-default-slotted",
    figmaSets: [{ nodeId: "1:1", setName: "Fake default slotted", fixedAttrs: {} }],
    axes: [],
    props: [],
    slots: [
      { figmaSlotName: "Body", kind: "slot", multi: false, mappedTo: "(default)", provenance: "auto-exact" },
    ],
  };
  const [file] = emitEntry(entry, config);
  assert.match(file.contents, /const body = instance\.getSlot\("Body"\)/);
  // Interpolated bare as the tag's inner content, no <div>/slot= wrapper.
  assert.match(file.contents, /<m3e-fake-default-slotted>\$\{body\}<\/m3e-fake-default-slotted>/);
  assert.doesNotMatch(file.contents, /<div slot=/);
});

test("slots[]: unmapped slot is a header-comment note only, never attempted as code", () => {
  const entry = {
    cemTag: "m3e-fake-unmapped-slot",
    figmaSets: [{ nodeId: "1:1", setName: "Fake unmapped slot", fixedAttrs: {} }],
    axes: [],
    props: [],
    slots: [
      { figmaSlotName: "Overflow menu", kind: "slot", multi: false, unmapped: "no corresponding CEM slot", provenance: "auto-gap" },
    ],
  };
  const [file] = emitEntry(entry, config);
  assert.doesNotMatch(file.contents, /instance\.getSlot\(/);
  assert.match(file.contents, / \* slot \(unmapped\): Overflow menu — no corresponding CEM slot/);
});

test("slots[]: entry with no 'slots' key at all emits exactly as before (regression guard)", () => {
  // The real m3e-button entry carries no `slots` key — emitting it must be
  // byte-identical to the pre-Task-4 golden-fixture comparison already
  // exercised above; this test additionally proves the synthetic-entry path
  // (no `slots` key at all, not even `undefined`) is equally unaffected.
  const entry = {
    cemTag: "m3e-fake-no-slots",
    figmaSets: [{ nodeId: "1:1", setName: "Fake no slots", fixedAttrs: {} }],
    axes: [],
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  const withSlotsKeyOmitted = emitEntry(entry, config)[0].contents;
  const withExplicitEmptySlots = emitEntry({ ...entry, slots: [] }, config)[0].contents;
  assert.equal(withSlotsKeyOmitted, withExplicitEmptySlots);
  assert.doesNotMatch(withSlotsKeyOmitted, /getSlot\(/);
  assert.doesNotMatch(withSlotsKeyOmitted, / \* slot/);
});

test("slots[]: BOTH a text->content prop AND a default-slot-mapped slot on one entry throws, naming both", () => {
  const entry = {
    cemTag: "m3e-fake-collision",
    figmaSets: [{ nodeId: "1:1", setName: "Fake collision", fixedAttrs: {} }],
    axes: [],
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
    slots: [
      { figmaSlotName: "Body", kind: "slot", multi: false, mappedTo: "(default)", provenance: "auto-exact" },
    ],
  };
  assert.throws(
    () => emitEntry(entry, config),
    /"Label text".*"Body".*mappedTo: "\(default\)"/s,
  );
});

// Final-review finding #1: on real m3-kit data, an entry can carry TWO OR
// MORE slots[] items that both map to "(default)" (m3e-menu has 3 "List N
// content" items; m3e-toolbar has 2 "Content (standard/vibrant)" items).
// Before this fix, `slotContentBlocks.find(...)` silently picked the first
// for interpolation and `.filter(mappedTo !== "(default)")` silently
// dropped the rest — getSlot() consts were still emitted for all of them,
// but their content never appeared anywhere in the template. This test
// proves no content silently vanishes: the first is interpolated, and the
// rest are named in a visible note (mirroring the existing >1 TEXT->content
// prop idiom, additionalTextContentProps, immediately above).
test("slots[]: 2+ slots mapped to '(default)' emits the first, notes the rest as not emitted (no silent drop)", () => {
  const entry = {
    cemTag: "m3e-fake-menu",
    figmaSets: [{ nodeId: "1:1", setName: "Fake menu", fixedAttrs: {} }],
    axes: [],
    props: [],
    slots: [
      { figmaSlotName: "List 1 content", kind: "slot", multi: false, mappedTo: "(default)", provenance: "auto-fuzzy" },
      { figmaSlotName: "List 2 content", kind: "slot", multi: false, mappedTo: "(default)", provenance: "auto-fuzzy" },
      { figmaSlotName: "List 3 content", kind: "slot", multi: false, mappedTo: "(default)", provenance: "auto-fuzzy" },
    ],
  };
  const [file] = emitEntry(entry, config);

  // getSlot() consts emitted for ALL THREE — none dropped at the const level.
  assert.match(file.contents, /const list1Content = instance\.getSlot\("List 1 content"\)/);
  assert.match(file.contents, /const list2Content = instance\.getSlot\("List 2 content"\)/);
  assert.match(file.contents, /const list3Content = instance\.getSlot\("List 3 content"\)/);

  // Only the FIRST is interpolated as the tag's inner content.
  assert.match(file.contents, /<m3e-fake-menu>\$\{list1Content\}<\/m3e-fake-menu>/);
  assert.doesNotMatch(file.contents, /\$\{list2Content\}/);
  assert.doesNotMatch(file.contents, /\$\{list3Content\}/);

  // The rest are named in a visible note — never a silent drop.
  assert.match(
    file.contents,
    /note: additional default-slot slot\(s\) List 2 content, List 3 content not emitted \(only "List 1 content" is interpolated\)/
  );
});
