import { test } from "node:test";
import assert from "node:assert/strict";
import { extractEntries } from "./build-search-index.mjs";

test("a page with no #main-content indexes only its title", () => {
  const html = `<html><head><title>Shop · elm-m3e</title></head><body><h1>Shop</h1></body></html>`;
  const entries = extractEntries(html, "/examples/shop");
  assert.deepEqual(entries, [
    { url: "/examples/shop", title: "Shop · elm-m3e", heading: null, anchor: null },
  ]);
});

test("a page with headings inside #main-content indexes the page plus each heading", () => {
  const html = `<html><head><title>Button · elm-m3e</title></head><body>
    <nav><h2>Should not appear (outside main-content)</h2></nav>
    <main id="main-content">
      <h1>Button</h1>
      <h2 id="api">API</h2>
      <h2>No id here</h2>
    </main>
  </body></html>`;
  const entries = extractEntries(html, "/components/button");
  assert.deepEqual(entries, [
    { url: "/components/button", title: "Button · elm-m3e", heading: null, anchor: null },
    { url: "/components/button", title: "Button · elm-m3e", heading: "Button", anchor: null },
    { url: "/components/button", title: "Button · elm-m3e", heading: "API", anchor: "api" },
    { url: "/components/button", title: "Button · elm-m3e", heading: "No id here", anchor: null },
  ]);
});

test("a heading with only whitespace text is skipped", () => {
  const html = `<html><head><title>X</title></head><body>
    <main id="main-content"><h1>   </h1><h2>Real heading</h2></main>
  </body></html>`;
  const entries = extractEntries(html, "/x");
  assert.deepEqual(entries, [
    { url: "/x", title: "X", heading: null, anchor: null },
    { url: "/x", title: "X", heading: "Real heading", anchor: null },
  ]);
});

test("a page with no <title> is skipped entirely (returns no entries)", () => {
  const html = `<html><head></head><body><main id="main-content"><h1>Orphan</h1></main></body></html>`;
  const entries = extractEntries(html, "/orphan");
  assert.deepEqual(entries, []);
});

test("an <m3e-heading> (this app's custom heading element, not a native h1-h6) is indexed the same as a native heading", () => {
  const html = `<html><head><title>X</title></head><body>
    <main id="main-content"><m3e-heading id="api" level="2">API</m3e-heading></main>
  </body></html>`;
  const entries = extractEntries(html, "/x");
  assert.deepEqual(entries, [
    { url: "/x", title: "X", heading: null, anchor: null },
    { url: "/x", title: "X", heading: "API", anchor: "api" },
  ]);
});
