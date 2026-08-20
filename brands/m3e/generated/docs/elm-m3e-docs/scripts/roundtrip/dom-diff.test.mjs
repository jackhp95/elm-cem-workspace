import { test } from "node:test";
import assert from "node:assert/strict";
import { diffHtml } from "./dom-diff.mjs";

test("identical markup matches", () => {
  const r = diffHtml("<m3e-button variant='filled'>Go</m3e-button>", "<m3e-button variant='filled'>Go</m3e-button>");
  assert.equal(r.matches, true);
  assert.deepEqual(r.deviations, []);
});

test("attribute order is normalized away", () => {
  const r = diffHtml('<m3e-button a="1" b="2"></m3e-button>', '<m3e-button b="2" a="1"></m3e-button>');
  assert.equal(r.matches, true);
});

test("insignificant whitespace is normalized away", () => {
  const r = diffHtml("<m3e-list>\n  <m3e-list-item></m3e-list-item>\n</m3e-list>", "<m3e-list><m3e-list-item></m3e-list-item></m3e-list>");
  assert.equal(r.matches, true);
});

test("boolean attribute forms are normalized (disabled vs disabled='')", () => {
  const r = diffHtml("<m3e-button disabled></m3e-button>", '<m3e-button disabled=""></m3e-button>');
  assert.equal(r.matches, true);
});

test("a changed attribute value is a structured deviation", () => {
  const r = diffHtml('<m3e-button variant="filled"></m3e-button>', '<m3e-button variant="tonal"></m3e-button>');
  assert.equal(r.matches, false);
  assert.equal(r.deviations[0].kind, "changed-attr");
  assert.equal(r.deviations[0].attr, "variant");
});

test("a missing element is a structured deviation", () => {
  const r = diffHtml("<m3e-app-bar><span slot='title'>T</span></m3e-app-bar>", "<m3e-app-bar></m3e-app-bar>");
  assert.equal(r.matches, false);
  assert.ok(r.deviations.some((d) => d.kind === "removed-element"));
});

test("identical multi-root fragments match", () => {
  const r = diffHtml("<button>A</button><button>B</button>", "<button>A</button><button>B</button>");
  assert.equal(r.matches, true);
  assert.deepEqual(r.deviations, []);
});

test("a deviation in the SECOND root is detected", () => {
  const r = diffHtml("<button>A</button><button>B</button>", "<button>A</button><button>C</button>");
  assert.equal(r.matches, false);
  assert.ok(r.deviations.some((d) => d.kind === "changed-text"));
});

test("a removed trailing root is detected", () => {
  const r = diffHtml("<a></a><b></b>", "<a></a>");
  assert.equal(r.matches, false);
  assert.ok(r.deviations.some((d) => d.kind === "removed-element"));
});

// --- cosmetic vs functional classification (WS4) ---

test("a class diff is cosmetic and functionalMatches stays true", () => {
  const r = diffHtml("<div>x</div>", '<div class="p-2 flex">x</div>');
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "class");
  assert.ok(dev, "expected a class deviation");
  assert.equal(dev.cosmetic, true);
  assert.equal(r.functionalMatches, true);
});

test("a style diff is cosmetic and functionalMatches stays true", () => {
  const r = diffHtml('<div style="color: red">x</div>', "<div>x</div>");
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "style");
  assert.ok(dev, "expected a style deviation");
  assert.equal(dev.cosmetic, true);
  assert.equal(r.functionalMatches, true);
});

test("an unreferenced id diff is cosmetic", () => {
  const r = diffHtml('<input id="bar">', "<input>");
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "id");
  assert.ok(dev, "expected an id deviation");
  assert.equal(dev.cosmetic, true);
  assert.equal(r.functionalMatches, true);
});

test("an id diff referenced by a `for` on the other side is functional", () => {
  const r = diffHtml('<input id="foo"><label for="foo">L</label>', '<input><label for="foo">L</label>');
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "id");
  assert.ok(dev, "expected an id deviation");
  assert.equal(dev.cosmetic, false);
  assert.equal(r.functionalMatches, false);
});

test("an added role is cosmetic (implied ARIA role made explicit)", () => {
  const r = diffHtml("<m3e-form-field></m3e-form-field>", '<m3e-form-field role="group"></m3e-form-field>');
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "role");
  assert.ok(dev, "expected a role deviation");
  assert.equal(dev.kind, "added-attr");
  assert.equal(dev.cosmetic, true);
  assert.equal(r.functionalMatches, true);
});

test("an added slot is cosmetic (slot placement made explicit)", () => {
  const r = diffHtml("<m3e-drawer-container><div>x</div></m3e-drawer-container>", '<m3e-drawer-container><div slot="end">x</div></m3e-drawer-container>');
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "slot");
  assert.ok(dev, "expected a slot deviation");
  assert.equal(dev.kind, "added-attr");
  assert.equal(dev.cosmetic, true);
  assert.equal(r.functionalMatches, true);
});

test("a changed component attr (variant) is functional", () => {
  const r = diffHtml('<m3e-button variant="filled"></m3e-button>', '<m3e-button variant="tonal"></m3e-button>');
  assert.equal(r.matches, false);
  const dev = r.deviations.find((d) => d.attr === "variant");
  assert.ok(dev, "expected a variant deviation");
  assert.equal(dev.cosmetic, false);
  assert.equal(r.functionalMatches, false);
});
