// T1 + T2: appendSets mechanism — synthetic unit tests.
//
// Run with the file-arg form:
//   node --test test/append-sets.test.mjs
//
// T1 covers src/correspond/merge.mjs applyManualCorrespondence (appendSets
// path) and validateManualCorrespondence (appendSets nodeId/setName check).
// T2 covers html-label.mjs emitEntry (per-set inline example + slugSuffix)
// and elm.mjs emitEntry (same, -elm suffix).
//
// All fixtures are SYNTHETIC. Zero real components are banked here.

import { test } from "node:test";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  applyManualCorrespondence,
  applyManualToExisting,
  validateManualCorrespondence,
} from "../src/correspond/merge.mjs";
import { emitEntry } from "../src/emit/html-label.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// A minimal bound entry (5 figmaSets, like m3e-button).
function makeBoundEntry(cemTag = "m3e-synthetic", figmaSets = null) {
  return {
    cemTag,
    matcherKind: "fusion",
    figmaSets: figmaSets ?? [
      { nodeId: "100:1", setName: "Synthetic - filled", fixedAttrs: { variant: "filled" } },
      { nodeId: "100:2", setName: "Synthetic - outlined", fixedAttrs: { variant: "outlined" } },
    ],
    axes: [
      { figmaProp: "Type", attr: "variant", valueMap: { Filled: "filled", Outlined: "outlined" } },
    ],
    props: [],
    confidence: 0.95,
    provenance: "auto-exact",
    rationale: "synthetic",
    status: "confirmed",
  };
}

// ---------------------------------------------------------------------------
// T1: applyManualCorrespondence — appendSets path
// ---------------------------------------------------------------------------

test("T1: appendSets onto a bound entry appends the sets, keeps primary sets first", () => {
  const entries = [makeBoundEntry("m3e-synthetic")];
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        {
          nodeId: "200:1",
          setName: "Synthetic - toggle filled",
          fixedAttrs: { variant: "filled" },
          slugSuffix: "toggle",
          example: { children: [{ tag: "m3e-icon", text: "favorite" }] },
        },
      ],
    },
  };

  const result = applyManualCorrespondence(entries, manual);
  const entry = result.find((e) => e.cemTag === "m3e-synthetic");
  assert.ok(entry, "entry present");

  // Total figmaSets: 2 primary + 1 appended.
  assert.equal(entry.figmaSets.length, 3, "3 total figmaSets");

  // Primary sets are first (unchanged).
  assert.equal(entry.figmaSets[0].nodeId, "100:1", "first primary set preserved");
  assert.equal(entry.figmaSets[1].nodeId, "100:2", "second primary set preserved");

  // Appended set is at the end.
  const appended = entry.figmaSets[2];
  assert.equal(appended.nodeId, "200:1", "appended nodeId");
  assert.equal(appended.setName, "Synthetic - toggle filled", "appended setName");
  assert.deepEqual(appended.fixedAttrs, { variant: "filled" }, "appended fixedAttrs");
  assert.equal(appended.slugSuffix, "toggle", "appended slugSuffix");
  assert.deepEqual(appended.example, { children: [{ tag: "m3e-icon", text: "favorite" }] }, "appended inline example");

  // The entry's other fields (axes, props, status, provenance) are preserved.
  assert.equal(entry.status, "confirmed", "status preserved");
  assert.equal(entry.provenance, "auto-exact", "provenance preserved");
  assert.equal(entry.axes.length, 1, "axes preserved");
});

test("T1: appendSets carries slugSuffix and example correctly through", () => {
  const entries = [makeBoundEntry("m3e-btn")];
  const manual = {
    "m3e-btn": {
      appendSets: [
        {
          nodeId: "300:1",
          setName: "Toggle button",
          fixedAttrs: { variant: "tonal" },
          slugSuffix: "toggle",
        },
        {
          nodeId: "300:2",
          setName: "Toggle button filled",
          fixedAttrs: { variant: "filled" },
          // no slugSuffix — undefined expected
        },
      ],
    },
  };

  const result = applyManualCorrespondence(entries, manual);
  const entry = result.find((e) => e.cemTag === "m3e-btn");
  assert.equal(entry.figmaSets.length, 4, "2 primary + 2 appended");

  const app1 = entry.figmaSets[2];
  const app2 = entry.figmaSets[3];

  assert.equal(app1.slugSuffix, "toggle", "slugSuffix on first appended");
  assert.equal(app2.slugSuffix, undefined, "slugSuffix absent when not given");
});

test("T1: appendSets onto an ABSENT cemTag THROWS", () => {
  const entries = [makeBoundEntry("m3e-something-else")];
  const manual = {
    "m3e-does-not-exist": {
      appendSets: [
        { nodeId: "999:1", setName: "Ghost", fixedAttrs: {} },
      ],
    },
  };

  assert.throws(
    () => applyManualCorrespondence(entries, manual),
    (err) =>
      err instanceof Error &&
      err.message.includes("appendSets") &&
      err.message.includes("m3e-does-not-exist") &&
      err.message.includes("not an existing bound entry"),
    "must throw with appendSets key and tag name"
  );
});

test("T1: appendSets onto an UNBOUND (figmaSets:[]) entry THROWS", () => {
  const unboundEntry = {
    cemTag: "m3e-unbound",
    matcherKind: "code-only",
    figmaSets: [],
    axes: [],
    props: [],
    confidence: 0,
    provenance: "auto-gap",
    rationale: "code-only",
    status: "proposed",
  };
  const entries = [unboundEntry];
  const manual = {
    "m3e-unbound": {
      appendSets: [
        { nodeId: "999:1", setName: "Ghost", fixedAttrs: {} },
      ],
    },
  };

  assert.throws(
    () => applyManualCorrespondence(entries, manual),
    (err) =>
      err instanceof Error &&
      err.message.includes("appendSets") &&
      err.message.includes("m3e-unbound") &&
      err.message.includes("not an existing bound entry"),
    "must throw for an unbound entry"
  );
});

test("T1: appendSets with a duplicate nodeId already in figmaSets THROWS", () => {
  const entries = [makeBoundEntry("m3e-synthetic")];
  // "100:1" is already in the primary figmaSets of makeBoundEntry.
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "100:1", setName: "Synthetic - filled", fixedAttrs: {} },
      ],
    },
  };

  assert.throws(
    () => applyManualCorrespondence(entries, manual),
    (err) =>
      err instanceof Error &&
      err.message.includes("appendSets") &&
      err.message.includes("100:1") &&
      err.message.includes("already present"),
    "must throw naming the duplicate nodeId"
  );
});

test("T1: appendSets with a duplicate nodeId across two appended sets THROWS", () => {
  const entries = [makeBoundEntry("m3e-synthetic")];
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "200:9", setName: "New set A", fixedAttrs: {} },
        { nodeId: "200:9", setName: "New set A again", fixedAttrs: {} }, // dup within appendSets
      ],
    },
  };

  assert.throws(
    () => applyManualCorrespondence(entries, manual),
    (err) =>
      err instanceof Error &&
      err.message.includes("appendSets") &&
      err.message.includes("200:9") &&
      err.message.includes("already present"),
    "must throw for a nodeId repeated within appendSets"
  );
});

test("T1: existing figmaSets path (no appendSets) is byte-identical to before", () => {
  // An unbound code-only entry replaced by a manual figmaSets entry — the
  // original synthesize/replace path must be completely unaffected.
  const codeOnlyEntry = {
    cemTag: "m3e-gap-tag",
    matcherKind: "code-only",
    figmaSets: [],
    axes: [],
    props: [],
    confidence: 0,
    provenance: "auto-gap",
    rationale: "code-only",
    status: "proposed",
  };
  const manual = {
    "m3e-gap-tag": {
      figmaSets: [{ nodeId: "500:1", setName: "Gap set", fixedAttrs: {} }],
      note: "gap fill",
    },
  };

  const result = applyManualCorrespondence([codeOnlyEntry], manual);
  const entry = result.find((e) => e.cemTag === "m3e-gap-tag");

  assert.equal(entry.provenance, "manual", "synthesized entry has provenance:manual");
  assert.equal(entry.figmaSets[0].nodeId, "500:1", "figmaSet applied");
  assert.equal(entry.status, "proposed", "status:proposed");
});

// ---------------------------------------------------------------------------
// T1: applyManualToExisting — mirror manual onto stored (confirmed) entries
// ---------------------------------------------------------------------------

test("existing-mirror: appendSets onto a CONFIRMED bound entry appends missing sets, no throw", () => {
  const existing = [makeBoundEntry("m3e-button")]; // status:confirmed, 2 primary sets
  const manual = {
    "m3e-button": {
      appendSets: [
        { nodeId: "900:1", setName: "Toggle", fixedAttrs: { toggle: "true" }, slugSuffix: "toggle" },
      ],
    },
  };
  const out = applyManualToExisting(existing, manual);
  const e = out.find((x) => x.cemTag === "m3e-button");
  assert.equal(e.figmaSets.length, 3, "appended onto confirmed without throwing");
  assert.equal(e.figmaSets[2].slugSuffix, "toggle", "appended set carries slugSuffix");
  assert.equal(e.status, "confirmed", "status untouched");
});

test("existing-mirror: re-applying is idempotent (no duplicate sets, no throw)", () => {
  const existing = [makeBoundEntry("m3e-button")];
  const manual = {
    "m3e-button": { appendSets: [{ nodeId: "900:1", setName: "Toggle", fixedAttrs: {} }] },
  };
  const once = applyManualToExisting(existing, manual);
  const twice = applyManualToExisting(once, manual);
  assert.equal(JSON.stringify(once), JSON.stringify(twice), "second application is a no-op");
});

test("existing-mirror: figmaSets list is adopted on a confirmed manual entry (tab-style extend)", () => {
  const existing = [
    {
      ...makeBoundEntry("m3e-tab"),
      matcherKind: "manual",
      figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }],
    },
  ];
  const manual = {
    "m3e-tab": {
      figmaSets: [
        { nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} },
        { nodeId: "54563:40209", setName: "Primary tabs/Icon only", fixedAttrs: {}, slugSuffix: "primary-icon-only" },
      ],
    },
  };
  const out = applyManualToExisting(existing, manual);
  assert.equal(out[0].figmaSets.length, 2, "adopted the full 2-set manual list");
  assert.equal(out[0].figmaSets[1].slugSuffix, "primary-icon-only");
});

test("existing-mirror: a tag not named in manual is byte-identical", () => {
  const existing = [makeBoundEntry("m3e-badge")];
  const out = applyManualToExisting(existing, { "m3e-tab": { figmaSets: [] } });
  assert.equal(JSON.stringify(out), JSON.stringify(existing), "untouched entry is byte-identical");
});

// ---------------------------------------------------------------------------
// T1: validateManualCorrespondence — appendSets nodeId/setName checks
// ---------------------------------------------------------------------------

// Synthetic figma data fixture for validate tests.
const syntheticFigma = {
  data: {
    components: [
      { id: "100:1", type: "COMPONENT_SET", name: "Synthetic - filled" },
      { id: "200:1", type: "COMPONENT_SET", name: "Toggle button" },
      { id: "200:2", type: "FRAME", name: "A Frame (not bindable)" }, // non-bindable type
    ],
  },
};
const syntheticCem = { tags: new Set(["m3e-synthetic", "m3e-other"]) };

test("T1 validate: valid appendSets nodeId/setName passes without throwing", () => {
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "200:1", setName: "Toggle button" },
      ],
    },
  };
  assert.doesNotThrow(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    "valid appendSets should not throw"
  );
});

test("T1 validate: appendSets with non-existent nodeId THROWS", () => {
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "999:9", setName: "Ghost set" },
      ],
    },
  };
  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) =>
      err instanceof Error &&
      err.message.includes("999:9") &&
      err.message.includes("appendSets") &&
      err.message.includes("does not exist"),
    "must throw for a missing nodeId"
  );
});

test("T1 validate: appendSets nodeId of a non-bindable type (FRAME) THROWS", () => {
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "200:2", setName: "A Frame (not bindable)" }, // type:"FRAME"
      ],
    },
  };
  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) =>
      err instanceof Error &&
      err.message.includes("200:2") &&
      err.message.includes("appendSets") &&
      err.message.includes("COMPONENT_SET"),
    "must throw when nodeId is a non-bindable type"
  );
});

test("T1 validate: appendSets setName mismatch THROWS", () => {
  const manual = {
    "m3e-synthetic": {
      appendSets: [
        { nodeId: "200:1", setName: "Wrong name" }, // actual name is "Toggle button"
      ],
    },
  };
  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) =>
      err instanceof Error &&
      err.message.includes("Wrong name") &&
      err.message.includes("appendSets"),
    "must throw for a setName mismatch"
  );
});

// ---------------------------------------------------------------------------
// T2: html-label emitEntry — per-set inline example + slugSuffix
// ---------------------------------------------------------------------------

const baseConfig = {
  fileKey: "SYNTHETIC_FILE_KEY",
  fileName: "Synthetic Design File",
  imports: ["@synthetic/web/all"],
};

// A synthetic entry with two primary figmaSets and one appended set that has
// both an inline example and a slugSuffix.
const syntheticEntry = {
  cemTag: "m3e-synthetic",
  axes: [
    { figmaProp: "Type", attr: "variant", valueMap: { Filled: "filled", Outlined: "outlined" } },
  ],
  props: [],
  figmaSets: [
    { nodeId: "100:1", setName: "Synthetic - filled", fixedAttrs: { variant: "filled" } },
    { nodeId: "100:2", setName: "Synthetic - outlined", fixedAttrs: { variant: "outlined" } },
    {
      nodeId: "200:1",
      setName: "Toggle button - filled",
      fixedAttrs: { variant: "filled" },
      slugSuffix: "toggle",
      example: {
        children: [
          { tag: "m3e-icon", text: "favorite" },
        ],
      },
    },
  ],
};

test("T2 (html-label): figmaSet with inline example.children emits THOSE children, not examples.json", () => {
  // The cemTag-level examples.json entry has DIFFERENT children — the per-set
  // inline example must take precedence.
  const cfg = {
    ...baseConfig,
    examples: {
      "m3e-synthetic": {
        children: [{ tag: "m3e-other-child", text: "Should NOT appear in toggle file" }],
      },
    },
  };

  const files = emitEntry(syntheticEntry, cfg);
  assert.equal(files.length, 3, "three files (2 primary + 1 appended)");

  // The appended set with inline example should use the inline children.
  const toggleFile = files.find((f) => f.id.includes("toggle"));
  assert.ok(toggleFile, "toggle file found");
  assert.match(toggleFile.contents, /<m3e-icon>favorite<\/m3e-icon>/, "inline example child emitted");
  assert.doesNotMatch(toggleFile.contents, /Should NOT appear/, "cemTag-level example NOT used");
  assert.doesNotMatch(toggleFile.contents, /m3e-other-child/, "cemTag-level example children NOT used");
});

test("T2 (html-label): figmaSet with slugSuffix — filename/id ends with the suffix", () => {
  const files = emitEntry(syntheticEntry, baseConfig);
  const toggleFile = files.find((f) => f.id.includes("toggle"));
  assert.ok(toggleFile, "toggle file found");

  // slugSuffix REPLACES the fixedAttrs slug entirely: id is m3e-synthetic-toggle.
  assert.equal(toggleFile.id, "m3e-synthetic-toggle", "slugSuffix replaces the slug");
  assert.equal(toggleFile.path, "m3e-synthetic-toggle.figma.ts", "path matches id");
});

test("T2 (html-label): figmaSet WITHOUT inline example or slugSuffix is byte-identical to today", () => {
  // The primary sets (no inline example, no slugSuffix) must be byte-identical
  // to what would be emitted from a plain entry with the same figmaSets.
  const plainEntry = {
    cemTag: "m3e-synthetic",
    axes: [
      { figmaProp: "Type", attr: "variant", valueMap: { Filled: "filled", Outlined: "outlined" } },
    ],
    props: [],
    figmaSets: [
      { nodeId: "100:1", setName: "Synthetic - filled", fixedAttrs: { variant: "filled" } },
      { nodeId: "100:2", setName: "Synthetic - outlined", fixedAttrs: { variant: "outlined" } },
    ],
  };

  const filesFromPlain = emitEntry(plainEntry, baseConfig);
  const filesFromAppended = emitEntry(syntheticEntry, baseConfig);

  // Primary sets (first two) must be identical.
  const primaryFromPlain = filesFromPlain.filter((f) => !f.id.includes("toggle"));
  const primaryFromAppended = filesFromAppended.filter((f) => !f.id.includes("toggle"));

  assert.equal(primaryFromPlain.length, 2, "two primary files from plain entry");
  assert.equal(primaryFromAppended.length, 2, "two primary files from appended entry");

  for (let i = 0; i < 2; i++) {
    assert.equal(
      primaryFromAppended[i].contents,
      primaryFromPlain[i].contents,
      `primary set ${i} must be byte-identical`
    );
    assert.equal(primaryFromAppended[i].id, primaryFromPlain[i].id, `primary set ${i} id identical`);
  }
});

test("T2 (html-label): cemTag-level examples.json applies to primary sets that lack a per-set inline example", () => {
  // When the cemTag has an examples.json entry but a figmaSet has NO inline
  // example, the cemTag-level entry applies (existing behavior preserved).
  const entryWithCemExample = {
    cemTag: "m3e-synthetic",
    axes: [],
    props: [{ figmaProp: "Label", kind: "text", binding: "content" }],
    figmaSets: [
      { nodeId: "100:1", setName: "Synthetic - filled", fixedAttrs: {} },
    ],
  };
  const cfg = {
    ...baseConfig,
    examples: {
      "m3e-synthetic": {
        children: [{ tag: "span", text: "CEM-level example child" }],
      },
    },
  };

  const [file] = emitEntry(entryWithCemExample, cfg);
  assert.match(file.contents, /<span>CEM-level example child<\/span>/, "cemTag-level example child emitted");
  // No getString for the text prop (examples-mode skips it).
  assert.doesNotMatch(file.contents, /getString\("Label"\)/, "getString skipped in examples-mode");
});

test("T2 (html-label): slugSuffix with kebab-chars: camelCase suffix is kebabified correctly", () => {
  const entryWithCamelSuffix = {
    cemTag: "m3e-synthetic",
    axes: [],
    props: [],
    figmaSets: [
      {
        nodeId: "100:1",
        setName: "Primary",
        fixedAttrs: {},
        slugSuffix: "toggleSelected",
      },
    ],
  };

  const [file] = emitEntry(entryWithCamelSuffix, baseConfig);
  // kebab("toggleSelected") should be "toggleselected" (or similar — the
  // emitter's kebab function lowercases and replaces non-alphanum with "-").
  // The actual value depends on the kebab impl: it splits on non-alnum.
  // "toggleSelected" → no non-alnum → "toggleselected" (all lower).
  assert.match(file.id, /toggleselected/, "slugSuffix is kebabified in the id");
});

// ---------------------------------------------------------------------------
// T2: elm emitter — slugSuffix in -elm id
// ---------------------------------------------------------------------------
// We import the elm emitter dynamically since it requires the elm-cem facts
// bundle Face C to exist in the profile directory. A profile-local import
// path is used. The elm emitter's per-set slugSuffix test exercises only the
// id construction, not the full Elm token resolution, so a synthetic entry
// with a REAL cemTag (m3e-button) that exists in Face C is used.

// Load the elm emitter — it reads Face C at module init, so we need the real
// profiles/m3-kit directory to be present.
const elmEmitter = await import(
  path.join(here, "..", "profiles", "m3-kit", "emitters", "elm.mjs")
);

const elmConfig = {
  fileKey: "SYNTHETIC_FILE_KEY",
  fileName: "Synthetic Design File",
  surface: "top",
  examples: {},
  setAttrs: {},
};

test("T2 (elm): figmaSet with slugSuffix produces id ending <slug>-<suffix>-elm", () => {
  // Use a real cemTag (m3e-button) so elm-facts resolves correctly.
  // Give it a simple entry with one figmaSet with a slugSuffix.
  const entryWithSuffix = {
    cemTag: "m3e-button",
    axes: [
      { figmaProp: "Type", attr: "shape", valueMap: { Round: "rounded", Square: "square" } },
    ],
    props: [],
    figmaSets: [
      {
        nodeId: "100:1",
        setName: "Button - toggle filled",
        fixedAttrs: { variant: "filled" },
        slugSuffix: "toggle",
      },
    ],
  };

  let files;
  assert.doesNotThrow(() => {
    files = elmEmitter.emitEntry(entryWithSuffix, elmConfig);
  }, "emitEntry must not throw");

  assert.equal(files.length, 1, "one file emitted");
  const [file] = files;

  // slugSuffix REPLACES the slug: id is m3e-button-toggle-elm.
  assert.equal(file.id, "m3e-button-toggle-elm", "elm id: slugSuffix replaces the slug, before -elm");
  assert.equal(file.path, "m3e-button-toggle-elm.figma.ts", "path matches id");
});

test("T2 (elm): figmaSet WITHOUT slugSuffix produces the same id as before", () => {
  const entryNoSuffix = {
    cemTag: "m3e-button",
    axes: [
      { figmaProp: "Type", attr: "shape", valueMap: { Round: "rounded", Square: "square" } },
    ],
    props: [],
    figmaSets: [
      { nodeId: "100:1", setName: "Button - filled", fixedAttrs: { variant: "filled" } },
    ],
  };

  const files = elmEmitter.emitEntry(entryNoSuffix, elmConfig);
  assert.equal(files.length, 1);
  const [file] = files;

  // No slugSuffix → id is m3e-button-filled-elm.
  assert.equal(file.id, "m3e-button-filled-elm", "no slugSuffix → standard id");
});

test("T2 (elm): figmaSet with inline example skips content getString + renders the inline children (defect D)", () => {
  // An entry with a text->content prop + a figmaSet with an inline example.
  // In examples-mode, the getString const must not be emitted (dead variable),
  // and the inline-example ChildSpecs render as real Elm children (defect D).
  const entryWithTextProp = {
    cemTag: "m3e-button",
    axes: [],
    props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
    figmaSets: [
      {
        nodeId: "100:1",
        setName: "Button - inline-example set",
        fixedAttrs: { variant: "filled" },
        // Inline example: signals examples-mode for this set.
        example: { children: [{ tag: "span", text: "Toggle label" }] },
      },
    ],
  };

  const files = elmEmitter.emitEntry(entryWithTextProp, elmConfig);
  assert.equal(files.length, 1);
  const [file] = files;

  // The getString const must NOT appear (it would be dead).
  assert.doesNotMatch(file.contents, /getString\("Label text"\)/, "getString skipped in examples-mode (elm)");
  // Defect D: the inline-example span text renders as a real Kit.text child in
  // the view's child list, NOT the old empty [] shell.
  assert.match(file.contents, /\n    \[ Kit\.text "Toggle label"\n    \]/, "inline-example child rendered (defect D)");
  assert.match(file.contents, /"import Kit"/, "the Kit text seam is imported when used");
});
