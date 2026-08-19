import { test } from "node:test";
import assert from "node:assert/strict";
import {
  extractPageFromHtml,
  dedent,
  stripOrphanRootSlots,
} from "./extract-matraic-examples.mjs";

// A heading section with a .showcase (complete markup) followed by a trimmed
// .example (the brevity oracle). Mirrors the matraic app-bar "Sizes" shape.
const SHOWCASE_SECTION = `
<m3e-heading level="1">App Bar</m3e-heading>
<m3e-heading level="3">Sizes</m3e-heading>
<p>Use the size attribute.</p>
<m3e-card class="showcase"><div slot="content">
  <m3e-app-bar size="medium">
    <span slot="title">Trails</span>
  </m3e-app-bar>
</div></m3e-card>
<m3e-card class="example"><pre slot="content">
&lt;m3e-app-bar size="medium"&gt;
  &lt;!-- Content omitted for brevity --&gt;
&lt;/m3e-app-bar&gt;</pre></m3e-card>
`;

test("showcase section sources COMPLETE markup, not the trimmed pre", () => {
  const { examples } = extractPageFromHtml("appbar", SHOWCASE_SECTION);
  assert.equal(examples.length, 1);
  const ex = examples[0];
  assert.equal(ex.title, "Sizes");
  // Complete: the title span survived; nothing was "omitted for brevity".
  assert.match(ex.code, /<span slot="title">Trails<\/span>/);
  assert.doesNotMatch(ex.code, /omitted for brevity/);
  // The trimmed pre is captured as the brevity oracle for B2.
  assert.match(ex.brevitySource, /omitted for brevity/);
});

// A pure-code section: an .example with NO preceding .showcase (install/native).
const PURE_CODE_SECTION = `
<m3e-heading level="3">Native module support</m3e-heading>
<m3e-card class="example"><pre slot="content">
&lt;m3e-app-bar&gt;&lt;/m3e-app-bar&gt;
&lt;script type="module"&gt;&lt;/script&gt;</pre></m3e-card>
`;

test("example-only section falls back to the pre source", () => {
  const { examples } = extractPageFromHtml("appbar", PURE_CODE_SECTION);
  assert.equal(examples.length, 1);
  assert.match(examples[0].code, /<m3e-app-bar><\/m3e-app-bar>/);
  assert.equal(examples[0].brevitySource, undefined);
});

test("dedent strips common leading indentation and blank edges", () => {
  assert.equal(dedent("\n    <a>\n      <b/>\n    </a>\n"), "<a>\n  <b/>\n</a>");
});

// #199 Task B: an orphan `slot` on a ROOT element (a slot child shown standalone,
// with no host to route it) is stripped — it would otherwise be silently dropped
// on the round trip as a `removed-attr slot` deviation. Mirrors drawer-container
// "Toggle", whose `<m3e-icon-button slot="leading-icon">` has no `m3e-app-bar`.
test("stripOrphanRootSlots drops slot on a root element", () => {
  const out = stripOrphanRootSlots(
    `<m3e-icon-button slot="leading-icon" aria-label="Menu"><m3e-icon name="menu"></m3e-icon></m3e-icon-button>`,
  );
  assert.doesNotMatch(out, /slot="leading-icon"/);
  // The element's other attributes and its children are preserved.
  assert.match(out, /aria-label="Menu"/);
  assert.match(out, /<m3e-icon name="menu">/);
});

// Interior (non-root) slots are legitimate slot children of a host present in the
// same fragment — they must NOT be touched.
test("stripOrphanRootSlots keeps interior (non-root) slots", () => {
  const out = stripOrphanRootSlots(
    `<m3e-app-bar><m3e-icon-button slot="leading-icon"><m3e-icon slot="selected" name="x"></m3e-icon></m3e-icon-button></m3e-app-bar>`,
  );
  // Both the child's slot and the grandchild's slot survive (only ROOTs strip).
  assert.match(out, /slot="leading-icon"/);
  assert.match(out, /slot="selected"/);
});

// A fragment with no orphan root slot is returned unchanged.
test("stripOrphanRootSlots is a no-op when no root carries a slot", () => {
  const code = `<m3e-button>Go</m3e-button>`;
  assert.equal(stripOrphanRootSlots(code), code);
});
