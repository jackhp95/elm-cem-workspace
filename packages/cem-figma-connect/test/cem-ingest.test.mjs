// Verifies src/ingest/cem.mjs against elm-cem's canonical facts bundle Face B
// (docs/facts-bundle/schema.json), and src/ingest/dts-inline.mjs (still
// tracked, no longer wired into loadCem's pipeline — M3.a) against small
// inline fixtures.
//
// Run with the file-arg form — `node --test` bare-dir discovery is broken
// on this repo's Node (v24.11.0): `node --test test/cem-ingest.test.mjs`.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadCem, classifyAttribute } from "../src/ingest/cem.mjs";
import { collectLiteralAliases, resolveAlias } from "../src/ingest/dts-inline.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
// A real Face B, built by elm-cem's own bin/facts-bundle.js from the
// vendored @m3e/web 2.5.14 manifest (test/fixtures/m3e-web-2.5.14/) — see
// docs/copy-fidelity-notes.md#cem-figma-connect's authorized-extra note
// (tools/family.json's cem-figma-connect.copyFidelity.authorizedExtra entry
// for test/fixtures/cem-facts.m3e-web-2.5.14.json). Face B is
// emitted POST tag-reconciliation, which is why its counts (123 components,
// 505 attributes, 0 duplicates) differ from the pre-M3.a numbers this file
// used to assert (121/500/2): the old loader's own naive
// dedupe-by-declared-tagName was silently merging two pairs of genuinely
// DIFFERENT components (m3e-menu-item/m3e-fab-menu-item,
// m3e-stepper-previous/m3e-stepper-next) that only collided because of an
// upstream analyzer tagName bug — elm-cem's tag reconciliation (against the
// authoritative `custom-element-definition` export) fixes exactly that bug
// upstream, so nothing is left to drop here.
const bundlePath = path.join(here, "fixtures", "cem-facts.m3e-web-2.5.14.json");

const dupeLog = [];
const loaded = loadCem(bundlePath, { log: (msg) => dupeLog.push(msg) });

test("loadCem: projects Face B's 123 components / 505 attributes with zero duplicates", () => {
  assert.equal(loaded.stats.totalDeclarations, 123);
  assert.equal(loaded.stats.uniqueTags, 123);
  assert.equal(loaded.components.length, 123);
  assert.deepEqual(loaded.dupes, []);
  assert.equal(dupeLog.length, 0);

  assert.equal(loaded.stats.totalAttributesRaw, 505);
  assert.equal(loaded.stats.totalAttributes, 505);
  const summed = loaded.components.reduce((sum, c) => sum + c.attributes.length, 0);
  assert.equal(summed, 505);
});

test("loadCem: the tagName-reconciliation fix is visible — both real components exist", () => {
  // Pre-M3.a, the OLD loader saw a WRONGLY-declared tagName collide with a
  // real, distinct component's tag and dropped one as a "duplicate". Face
  // B's reconciliation corrects the wrong declared tagName against the
  // authoritative `custom-element-definition` registration BEFORE
  // deduping, so both real, distinct components are present: the genuine
  // m3e-stepper-previous (M3eStepperPreviousElement) alongside the
  // corrected m3e-stepper-next (was wrongly self-tagged
  // "m3e-stepper-previous"); likewise m3e-menu-item alongside the corrected
  // m3e-fab-menu-item.
  assert.ok(loaded.components.find((c) => c.tag === "m3e-menu-item"));
  assert.ok(loaded.components.find((c) => c.tag === "m3e-fab-menu-item"));
  assert.ok(loaded.components.find((c) => c.tag === "m3e-stepper-previous"));
  assert.ok(loaded.components.find((c) => c.tag === "m3e-stepper-next"));
});

test("known-good fallback: LinkTarget stays unresolved and classifies as string (CORRECT — not a bug, 06b §3)", () => {
  // LinkTarget's .d.ts union is `"_self" | "_blank" | "_parent" | "_top" |
  // (string & {})` — deliberately open (any frame name is a legal target).
  // Face B classifies an OPEN union as kind:"string" (docs/facts-bundle/
  // schema.json's faceBAttribute.kind) — the same verdict this loader
  // always gave it — but (unlike the old loader, which left an
  // irresolvable alias name as bare `"LinkTarget"`) it DOES resolve and
  // document the union's known members in `type.resolved`, since Face B's
  // producer inlines an alias's body regardless of whether the union is
  // open or closed; `kind` (not the presence of a resolved union) is what
  // tells a consumer it isn't a closed enum axis.
  const linkTargetResolved = '"_self" | "_blank" | "_parent" | "_top" | (string & {})';
  const button = loaded.components.find((c) => c.tag === "m3e-button");
  assert.ok(button, "m3e-button present");
  const target = button.attributes.find((a) => a.name === "target");
  assert.ok(target, "m3e-button has a target attribute");
  assert.equal(target.type, linkTargetResolved);
  assert.equal(target.kind, "string");
  assert.equal(target.values, undefined);

  let linkTargetRows = 0;
  for (const c of loaded.components) {
    for (const a of c.attributes) {
      if (a.type === linkTargetResolved) {
        linkTargetRows++;
        assert.equal(a.kind, "string", `${c.tag}.${a.name} should classify as string`);
        assert.equal(a.values, undefined);
      }
    }
  }
  assert.ok(linkTargetRows > 0);
});

test("m3e-button: variant and size enums resolve to their exact .d.ts declaration-order value sets", () => {
  const button = loaded.components.find((c) => c.tag === "m3e-button");
  assert.ok(button, "m3e-button present");

  const variant = button.attributes.find((a) => a.name === "variant");
  assert.equal(variant.kind, "enum");
  assert.deepEqual(variant.values, ["elevated", "filled", "tonal", "outlined", "text"]);

  const size = button.attributes.find((a) => a.name === "size");
  assert.equal(size.kind, "enum");
  assert.deepEqual(size.values, ["extra-small", "small", "medium", "large", "extra-large"]);
});

test("loadCem: exposes tag/description/attributes/slots/events/cssProperties/module per component", () => {
  const button = loaded.components.find((c) => c.tag === "m3e-button");
  assert.equal(typeof button.module, "string");
  assert.ok(button.module.length > 0);
  assert.equal(typeof button.description, "string");
  assert.ok(button.description.length > 0);
  assert.ok(Array.isArray(button.attributes) && button.attributes.length > 0);
  assert.ok(Array.isArray(button.slots) && button.slots.length > 0);
  assert.ok(Array.isArray(button.events) && button.events.length > 0);
  assert.ok(Array.isArray(button.cssProperties) && button.cssProperties.length > 0);
});

test("loadCem: kind buckets partition the deduped attribute total (505)", () => {
  const buckets = {};
  for (const c of loaded.components) {
    for (const a of c.attributes) buckets[a.kind] = (buckets[a.kind] || 0) + 1;
  }
  const total = Object.values(buckets).reduce((sum, n) => sum + n, 0);
  assert.equal(total, 505);
});

test("loadCem: throws on a missing bundle file", () => {
  assert.throws(
    () => loadCem(path.join(here, "fixtures", "does-not-exist.json")),
    /ENOENT/
  );
});

// -- dts-inline.mjs / classifyAttribute: small, hermetic inline fixtures ----
// (no longer exercised via loadCem's pipeline — Face B ships already-resolved
// enum value sets — kept as direct unit coverage of the still-tracked module.)

test("classifyAttribute: boolean / number / none", () => {
  assert.deepEqual(classifyAttribute({ type: { text: "boolean" } }), { kind: "boolean" });
  assert.deepEqual(classifyAttribute({ type: { text: "number" } }), { kind: "number" });
  assert.deepEqual(classifyAttribute({ type: { text: "number | null" } }), { kind: "number" });
  assert.deepEqual(classifyAttribute({}), { kind: "none" });
  assert.deepEqual(classifyAttribute({ type: {} }), { kind: "none" });
});

test("classifyAttribute: enum covers string AND numeric literal unions, with/without nullish parts", () => {
  assert.deepEqual(classifyAttribute({ type: { text: '"a" | "b"' } }), {
    kind: "enum",
    values: ["a", "b"],
  });
  assert.deepEqual(classifyAttribute({ type: { text: "1 | -1" } }), {
    kind: "enum",
    values: [1, -1],
  });
  assert.deepEqual(classifyAttribute({ type: { text: '"round" | "square" | null' } }), {
    kind: "enum",
    values: ["round", "square"],
  });
});

test("classifyAttribute: other covers function-typed and array-shaped attributes", () => {
  assert.deepEqual(
    classifyAttribute({ type: { text: "string | ((count: number) => string)" } }),
    { kind: "other" }
  );
  assert.deepEqual(classifyAttribute({ type: { text: "string[]" } }), { kind: "other" });
});

test("classifyAttribute: opaque bare identifiers (unresolved aliases / global types) fall back to string", () => {
  assert.deepEqual(classifyAttribute({ type: { text: "Date" } }), { kind: "string" });
  assert.deepEqual(classifyAttribute({ type: { text: "Date | null" } }), { kind: "string" });
  assert.deepEqual(classifyAttribute({ type: { text: "LinkTarget" } }), { kind: "string" });
  assert.deepEqual(classifyAttribute({ type: { text: "string" } }), { kind: "string" });
});

test("dts-inline: collectLiteralAliases + resolveAlias resolve a small inline .d.ts fixture", (t) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "cfc-dts-inline-"));
  fs.writeFileSync(
    path.join(dir, "shape.d.ts"),
    `export type ShapeName = "round" | "square" | (string & {});\n` +
      `export type CornerValue = 0 | 4 | 8;\n`
  );
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));

  const aliases = collectLiteralAliases(dir);
  assert.equal(aliases.CornerValue, '0 | 4 | 8');
  assert.equal(aliases.ShapeName, undefined, "an open union (string & {}) is not a pure literal union");

  assert.equal(resolveAlias("CornerValue | null", aliases), '0 | 4 | 8 | null');
  assert.equal(resolveAlias("ShapeName", aliases), null);
});
