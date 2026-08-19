import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { renderChildrenHtml, validateExamples, validateSetAttrs } from "./example-content.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));

test("renderChildrenHtml: text child", () => {
  assert.equal(renderChildrenHtml([{ tag: "m3e-button-segment", text: "Label" }]),
    `<m3e-button-segment>Label</m3e-button-segment>`);
});

test("renderChildrenHtml: slot + attrs + nested children", () => {
  const out = renderChildrenHtml([
    { tag: "m3e-icon-button", slot: "trailing-button", children: [
      { tag: "m3e-icon", attrs: { name: "arrow_drop_down" } } ] },
  ]);
  assert.equal(out, `<m3e-icon-button slot="trailing-button"><m3e-icon name="arrow_drop_down"></m3e-icon></m3e-icon-button>`);
});

test("renderChildrenHtml: multiple children joined; empty/undefined -> empty string", () => {
  assert.equal(
    renderChildrenHtml([{ tag: "span", text: "A" }, { tag: "span", text: "B" }]),
    `<span>A</span><span>B</span>`);
  assert.equal(renderChildrenHtml([]), "");
  assert.equal(renderChildrenHtml(undefined), "");
});

test("validateExamples: every child tag is a real CEM tag (or plain HTML) and every slot is a real slot of its parent", () => {
  const cem = {
    tags: new Set(["m3e-segmented-button", "m3e-button-segment", "m3e-split-button", "m3e-button"]),
    slotsByTag: { "m3e-segmented-button": new Set([""]), "m3e-split-button": new Set(["leading-button", "trailing-button"]) },
  };
  validateExamples({ "m3e-segmented-button": { children: [{ tag: "m3e-button-segment", text: "L" }] } }, cem);
  validateExamples({ "m3e-split-button": { children: [{ tag: "m3e-button", slot: "leading-button", text: "L" }] } }, cem);
  assert.throws(() => validateExamples({ "m3e-segmented-button": { children: [{ tag: "m3e-nope" }] } }, cem), /unknown tag 'm3e-nope'/);
  assert.throws(() => validateExamples({ "m3e-split-button": { children: [{ tag: "m3e-button", slot: "middle", text: "x" }] } }, cem), /slot 'middle' is not a slot of 'm3e-split-button'/);
});

test("the committed examples.json validates against the real m3-kit CEM", () => {
  const prof = JSON.parse(fs.readFileSync("profiles/m3-kit/profile.json", "utf8"));
  // M3.a: prof.cem.manifestPath is now elm-cem's Face B (faceBComponent[]),
  // not a raw custom-elements.json — read its already-deduped component list
  // directly instead of walking modules[].declarations[].
  const faceB = JSON.parse(fs.readFileSync(prof.cem.manifestPath, "utf8"));
  const tags = new Set(); const slotsByTag = {};
  for (const c of faceB.components ?? []) {
    tags.add(c.tag);
    slotsByTag[c.tag] = new Set((c.slots ?? []).map((s) => s.name || ""));
  }
  const examples = JSON.parse(fs.readFileSync("profiles/m3-kit/examples.json", "utf8"));
  assert.doesNotThrow(() => validateExamples(examples, { tags, slotsByTag }));
});

// -- validateSetAttrs tests ---------------------------------------------------

test("validateSetAttrs: valid config passes without throwing", () => {
  const cem = {
    tags: new Set(["m3e-circular-progress-indicator", "m3e-linear-progress-indicator"]),
    attrsByTag: {
      "m3e-circular-progress-indicator": new Set(["indeterminate", "value", "max", "variant"]),
      "m3e-linear-progress-indicator": new Set(["mode", "value", "buffer-value", "max", "variant"]),
    },
  };
  const setAttrs = {
    "m3e-circular-progress-indicator": {
      "Circular-determinate progress indicator": { "value": "70" },
      "Circular-indeterminate progress indicator": { "indeterminate": "true" },
    },
    "m3e-linear-progress-indicator": {
      "Linear-determinate progress indicator": { "value": "70" },
    },
  };
  assert.doesNotThrow(() => validateSetAttrs(setAttrs, cem));
});

test("validateSetAttrs: unknown cemTag throws", () => {
  const cem = {
    tags: new Set(["m3e-button"]),
    attrsByTag: { "m3e-button": new Set(["variant", "type"]) },
  };
  const setAttrs = { "m3e-nope": { "Some set": { "variant": "filled" } } };
  assert.throws(() => validateSetAttrs(setAttrs, cem), /set-attrs\.json: unknown cemTag 'm3e-nope'/);
});

test("validateSetAttrs: unknown attr throws", () => {
  const cem = {
    tags: new Set(["m3e-button"]),
    attrsByTag: { "m3e-button": new Set(["variant", "type"]) },
  };
  const setAttrs = { "m3e-button": { "Button - filled": { "no-such-attr": "x" } } };
  assert.throws(() => validateSetAttrs(setAttrs, cem), /set-attrs\.json: unknown attr 'no-such-attr' on 'm3e-button'/);
});

test("the committed set-attrs.json validates against the real m3-kit CEM", () => {
  const prof = JSON.parse(fs.readFileSync("profiles/m3-kit/profile.json", "utf8"));
  // M3.a: Face B, not a raw manifest — see the examples.json test above.
  const faceB = JSON.parse(fs.readFileSync(prof.cem.manifestPath, "utf8"));
  const tags = new Set();
  const attrsByTag = {};
  for (const c of faceB.components ?? []) {
    tags.add(c.tag);
    attrsByTag[c.tag] = new Set((c.attributes ?? []).map((a) => a.name));
  }
  const setAttrsPath = path.join(here, "..", "..", "profiles", "m3-kit", "set-attrs.json");
  const setAttrs = JSON.parse(fs.readFileSync(setAttrsPath, "utf8"));
  assert.doesNotThrow(() => validateSetAttrs(setAttrs, { tags, attrsByTag }));
});
