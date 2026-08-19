// src/links/derive.mjs — figma-links.json derivation + drift gate (Phase 2,
// plans/2026-08-17-figma-elm-config-integration-design.md).

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { deriveFigmaLinks, serializeFigmaLinks, writeFigmaLinks, checkFigmaLinks } from "../src/links/derive.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const pkgDir = path.dirname(here);

function makeProfile(dir, { profile, correspondence, overrides }) {
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "profile.json"), JSON.stringify(profile), "utf8");
  fs.writeFileSync(path.join(dir, "correspondence.json"), JSON.stringify(correspondence), "utf8");
  if (overrides) fs.writeFileSync(path.join(dir, "overrides.json"), JSON.stringify(overrides), "utf8");
  const exportPath = path.join(dir, "figma-export.json");
  fs.writeFileSync(
    exportPath,
    JSON.stringify({ meta: { fileKey: profile.fileKey, fileName: "Test Kit" } }),
    "utf8",
  );
}

function withTmpProfile(fixture, fn) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "links-test-"));
  try {
    makeProfile(dir, {
      profile: {
        fileKey: "FAKE123",
        kitVersionTag: "test-tag",
        figmaExportPath: path.relative(pkgDir, path.join(dir, "figma-export.json")),
        emitters: ["html-label", "profiles/m3-kit/emitters/elm.mjs"],
        ...fixture.profile,
      },
      correspondence: fixture.correspondence,
      overrides: fixture.overrides,
    });
    return fn(dir);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

test("deriveFigmaLinks: only status:confirmed entries produce a row", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
        { cemTag: "m3e-chip", status: "proposed", figmaSets: [{ nodeId: "2:2", setName: "Chip", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.equal(data.links.length, 1);
      assert.equal(data.links[0].cemTag, "m3e-button");
    },
  );
});

test("deriveFigmaLinks: a confirmed code-only entry (no figmaSets) is dropped, not a bare row", () => {
  withTmpProfile(
    {
      correspondence: [{ cemTag: "m3e-orphan", status: "confirmed", figmaSets: [] }],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.equal(data.links.length, 0);
    },
  );
});

test("deriveFigmaLinks: URL is built from the profile's fileKey + the export's fileName, node-id dashed", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "57994:2227", setName: "Button", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.equal(
        data.links[0].sets[0].url,
        "https://www.figma.com/design/FAKE123/Test-Kit?node-id=57994-2227",
      );
    },
  );
});

test("deriveFigmaLinks: gate is joined in from overrides.json by cemTag; absent -> null", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
        { cemTag: "m3e-chip", status: "confirmed", figmaSets: [{ nodeId: "2:2", setName: "Chip", fixedAttrs: {} }] },
      ],
      overrides: [{ cemTag: "m3e-button", status: "confirmed", gate: "approved" }],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      const byTag = Object.fromEntries(data.links.map((l) => [l.cemTag, l]));
      assert.equal(byTag["m3e-button"].gate, "approved");
      assert.equal(byTag["m3e-chip"].gate, null);
    },
  );
});

test("deriveFigmaLinks: labels come from profile.json's emitters[], constant per row", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.deepEqual(data.links[0].labels, ["Web Components", "Elm"]);
    },
  );
});

test("deriveFigmaLinks: iconTable collapses to ONE row with a representative node + true iconCount", () => {
  withTmpProfile(
    {
      correspondence: [
        {
          kind: "iconTable",
          cemTag: "m3e-icon",
          status: "confirmed",
          icons: [
            { figmaNodeId: "1:1", figmaName: "wifi", symbolName: "wifi", filled: false },
            { figmaNodeId: "1:2", figmaName: "alarm", symbolName: "alarm", filled: false },
          ],
        },
      ],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.equal(data.links.length, 1);
      assert.equal(data.links[0].iconCount, 2);
      assert.equal(data.links[0].sets.length, 1);
      assert.equal(data.links[0].sets[0].representative, true);
      assert.equal(data.links[0].sets[0].nodeId, "1:1");
    },
  );
});

test("deriveFigmaLinks: rows are sorted ascending by cemTag (ordinal, byKey)", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-tab", status: "confirmed", figmaSets: [{ nodeId: "3:3", setName: "Tab", fixedAttrs: {} }] },
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      const data = deriveFigmaLinks(dir);
      assert.deepEqual(data.links.map((l) => l.cemTag), ["m3e-button", "m3e-tab"]);
    },
  );
});

test("checkFigmaLinks: missing file is reported, not thrown", () => {
  withTmpProfile(
    { correspondence: [] },
    (dir) => {
      const result = checkFigmaLinks(dir);
      assert.equal(result.ok, false);
      assert.match(result.reason, /missing/);
    },
  );
});

test("checkFigmaLinks: matches immediately after writeFigmaLinks (byte-stable)", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      writeFigmaLinks(dir);
      assert.equal(checkFigmaLinks(dir).ok, true);
    },
  );
});

test("checkFigmaLinks: a hand-edited committed file is reported STALE", () => {
  withTmpProfile(
    {
      correspondence: [
        { cemTag: "m3e-button", status: "confirmed", figmaSets: [{ nodeId: "1:1", setName: "Button", fixedAttrs: {} }] },
      ],
    },
    (dir) => {
      writeFigmaLinks(dir);
      fs.writeFileSync(path.join(dir, "figma-links.json"), serializeFigmaLinks({ fileKey: "x", kitVersionTag: "y", links: [] }), "utf8");
      const result = checkFigmaLinks(dir);
      assert.equal(result.ok, false);
      assert.match(result.reason, /STALE/);
    },
  );
});

test("figma-links.json: the REAL committed m3-kit profile is byte-stable today", () => {
  const realProfileDir = path.join(pkgDir, "profiles", "m3-kit");
  const result = checkFigmaLinks(realProfileDir);
  assert.equal(result.ok, true, result.reason);
});
