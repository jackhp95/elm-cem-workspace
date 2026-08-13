import { test } from "node:test";
import assert from "node:assert/strict";
import { scanEscapes } from "./escape-scan.mjs";

test("fully typed conversion scores zero", () => {
  const r = scanEscapes("M3e.AppBar.view [] [ M3e.IconButton.view [] [] ]");
  assert.equal(r.seam.count, 0);
  assert.equal(r.native.count, 0);
  assert.equal(r.charsInside, 0);
  assert.equal(r.benign, true);
});

test("counts Native.* and Seam.* call sites and inner char span", () => {
  const r = scanEscapes('M3e.card [] [ Seam.asElement (Html.div [] [ Html.text "x" ]) ]');
  assert.equal(r.seam.count, 1);
  assert.ok(r.seam.charsInside > 0);
  assert.equal(r.native.count, 0);
});

test("lone Native.span wrapping text is flagged benign", () => {
  const r = scanEscapes('M3e.appBar [] [ Native.span [] [ Kit.text "Title" ] ]');
  assert.equal(r.native.count, 1);
  assert.equal(r.benign, true);
});

test("Native wrapping real structure is NOT benign", () => {
  const r = scanEscapes("M3e.appBar [] [ Native.div [] [ M3e.icon [] [], M3e.icon [] [] ] ]");
  assert.equal(r.benign, false);
});

test("null / non-string input is inert", () => {
  const r = scanEscapes(null);
  assert.equal(r.converted, false);
  assert.equal(r.seam.count, 0);
});

test("nested Seam inside Native is not double-counted in charsInside", () => {
  // The standard Layout idiom: a Native.* wrapper carrying a Seam.* attribute.
  // The nested Seam span must NOT be added to both native and seam totals.
  const code = 'Native.div [ Seam.asAttribute (Attr.class "x") ] [ Html.text "hi" ]';
  const r = scanEscapes(code);
  // Counts still see every site (benign relies on seam.count catching the Seam).
  assert.equal(r.seam.count, 1);
  assert.equal(r.native.count, 1);
  assert.equal(r.benign, false);
  // Only the OUTERMOST (Native) span is charged; the contained Seam contributes 0.
  assert.equal(r.seam.charsInside, 0);
  assert.equal(r.charsInside, r.native.charsInside);
  // No double counting => total can never exceed the whole string length.
  assert.ok(r.charsInside <= code.length);
});

test("bracket inside a string literal does not desync capture", () => {
  // The "[" living inside "arr [oops" must not extend Native.span's capture
  // to swallow the sibling Native.div that follows it.
  const code = 'M3e.card [] [ Native.span [] [ Kit.text "arr [oops" ], Native.div [] [] ]';
  const r = scanEscapes(code);
  assert.equal(r.native.count, 2);
  // Both Native sites wrap only text / nothing => benign; a desync would have
  // pulled "Native." into span's inner region and flipped this to false.
  assert.equal(r.benign, true);
});
