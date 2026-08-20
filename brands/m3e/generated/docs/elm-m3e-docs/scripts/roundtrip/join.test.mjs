import { test } from "node:test";
import assert from "node:assert/strict";
import { buildMatrix } from "./join.mjs";

test("buildMatrix produces one cell per (module, index, surface) with raw html", () => {
  const rich = {
    AppBar: [{ title: "Anatomy", html: "<m3e-app-bar></m3e-app-bar>", top: "M3e.AppBar.view [] []" }],
  };
  const surfaces = { AppBar: [{ record: "M3e.appBar [] []", build: null }] };
  const barrel = { AppBar: ["M3e.appBar [] []"] };

  const cells = buildMatrix({ rich, surfaces, barrel });

  const appbar0 = cells.filter((c) => c.module === "AppBar" && c.index === 0);
  assert.equal(appbar0.length, 4);
  const bySurface = Object.fromEntries(appbar0.map((c) => [c.surface, c]));
  assert.equal(bySurface.top.converted, true);
  assert.equal(bySurface.record.converted, true);
  assert.equal(bySurface.build.converted, false);
  assert.equal(bySurface.top.raw, "<m3e-app-bar></m3e-app-bar>");
  assert.equal(bySurface.top.title, "Anatomy");
});
