#!/usr/bin/env node
// gen-figma-config.test.mjs — TDD for tools/gen-figma-config.mjs's pure
// deriveFigmaConfig(). Run with: node --test tools/gen-figma-config.test.mjs

import assert from "node:assert/strict";
import test from "node:test";

import { deriveFigmaConfig } from "./gen-figma-config.mjs";

test("deriveFigmaConfig: keys by the module's constructor-name suffix, not Face C's lowercase `component` field", () => {
  const config = deriveFigmaConfig({
    figmaLinks: {
      links: [
        { cemTag: "m3e-app-bar", status: "confirmed", gate: "approved", sets: [{ nodeId: "1:1", setName: "App bar", url: "https://figma.example/1-1" }] },
      ],
    },
    faceC: { components: { "m3e-app-bar": { module: "M3e.Component.AppBar", component: "appBar" } } },
  });
  assert.deepEqual(Object.keys(config), ["AppBar"]);
  assert.equal(config.AppBar.docMeta.figmaUrl, "https://figma.example/1-1");
  assert.equal(config.AppBar.docMeta.figmaStatus, "approved");
});

test("deriveFigmaConfig: falls back to correspondence status when no gate override exists", () => {
  const config = deriveFigmaConfig({
    figmaLinks: {
      links: [{ cemTag: "m3e-avatar", status: "confirmed", gate: null, sets: [{ nodeId: "2:2", setName: "Avatar", url: "https://figma.example/2-2" }] }],
    },
    faceC: { components: { "m3e-avatar": { module: "M3e.Component.Avatar", component: "avatar" } } },
  });
  assert.equal(config.Avatar.docMeta.figmaStatus, "confirmed");
});

test("deriveFigmaConfig: a link with no matching Face C component is skipped (Web-Components-only binding)", () => {
  const config = deriveFigmaConfig({
    figmaLinks: {
      links: [{ cemTag: "m3e-no-elm", status: "confirmed", gate: "approved", sets: [{ nodeId: "3:3", setName: "X", url: "https://figma.example/3-3" }] }],
    },
    faceC: { components: {} },
  });
  assert.deepEqual(config, {});
});

test("deriveFigmaConfig: a link with no sets (should not occur post-derive.mjs filtering, but defensive) is skipped, not a crash", () => {
  const config = deriveFigmaConfig({
    figmaLinks: {
      links: [{ cemTag: "m3e-empty", status: "confirmed", gate: null, sets: [] }],
    },
    faceC: { components: { "m3e-empty": { module: "M3e.Component.Empty", component: "empty" } } },
  });
  assert.deepEqual(config, {});
});

test("deriveFigmaConfig: a multi-set fusion (e.g. m3e-button) uses the FIRST set as the representative link", () => {
  const config = deriveFigmaConfig({
    figmaLinks: {
      links: [
        {
          cemTag: "m3e-button",
          status: "confirmed",
          gate: "approved",
          sets: [
            { nodeId: "1:1", setName: "Button", url: "https://figma.example/1-1" },
            { nodeId: "1:2", setName: "Button - tonal", url: "https://figma.example/1-2" },
          ],
        },
      ],
    },
    faceC: { components: { "m3e-button": { module: "M3e.Component.Button", component: "button" } } },
  });
  assert.equal(config.Button.docMeta.figmaUrl, "https://figma.example/1-1");
});
