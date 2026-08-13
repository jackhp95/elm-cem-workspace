// audit-lib.test.mjs — unit tests for the pure helpers behind audit-guidance.mjs.
import { test } from "node:test";
import assert from "node:assert/strict";
import { classifyLinks, countGuidanceClaims, parseSitemapTopics, coverageGaps } from "./audit-lib.mjs";

test("classifyLinks separates m3.material.io / upstream / other", () => {
  const md = `
See [spec](https://m3.material.io/components/buttons/overview) and
[source](https://github.com/matraic/m3e/blob/abc/README.md) plus
a bare https://m3.material.io/styles/color/overview link and
[MDN](https://developer.mozilla.org/en-US/docs/Web).`;
  const c = classifyLinks(md);
  assert.equal(c.m3, 2, "two m3.material.io references");
  assert.equal(c.upstream, 1, "one matraic/m3e reference");
  assert.equal(c.other, 1, "one other reference");
});

test("classifyLinks reports 0 m3 for a card with no spec citation", () => {
  const md = "# button\n\nGenerated from `matraic/m3e` @ [`abc`](https://github.com/matraic/m3e/blob/x).";
  assert.equal(classifyLinks(md).m3, 0);
});

test("countGuidanceClaims counts should/prefer/avoid/never/always/must sentences", () => {
  const md = `
You should wrap it. Prefer outlined here. Avoid nesting.
Never do this. Always label it. It must be present.
This is a neutral sentence with no directive.`;
  assert.equal(countGuidanceClaims(md), 6);
});

test("countGuidanceClaims ignores fenced code blocks", () => {
  const md = "You should label it.\n\n```html\n<!-- you should not count this -->\n<m3e-button>always</m3e-button>\n```\n";
  assert.equal(countGuidanceClaims(md), 1);
});

test("parseSitemapTopics extracts foundations/styles second-level segments", () => {
  const xml = `<?xml version="1.0"?><urlset>
    <url><loc>https://m3.material.io/foundations/accessibility/overview</loc></url>
    <url><loc>https://m3.material.io/foundations/layout/understanding-layout</loc></url>
    <url><loc>https://m3.material.io/styles/color/system/overview</loc></url>
    <url><loc>https://m3.material.io/components/buttons/overview</loc></url>
    <url><loc>https://m3.material.io/develop/web</loc></url>
  </urlset>`;
  const topics = parseSitemapTopics(xml);
  assert.ok(topics.has("foundations/accessibility"));
  assert.ok(topics.has("foundations/layout"));
  assert.ok(topics.has("styles/color"));
  assert.ok(!topics.has("components/buttons"), "components are out of scope");
  assert.ok(!topics.has("develop/web"), "non foundations/styles ignored");
});

test("coverageGaps returns topics not claimed by any concept page", () => {
  const topics = ["foundations/accessibility", "styles/color", "styles/shape"];
  const claims = { color: ["styles/color"] };
  const gaps = coverageGaps(topics, claims);
  assert.deepEqual(gaps.sort(), ["foundations/accessibility", "styles/shape"]);
});
