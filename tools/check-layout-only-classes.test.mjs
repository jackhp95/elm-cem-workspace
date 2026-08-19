// tools/check-layout-only-classes.test.mjs — picked up automatically by
// gate-all's tools/*.test.mjs discovery (see tools/gate-all.mjs).
//
// Pins two things:
//   1. the JS mirror classifies exactly like NoProprietaryDsClasses.elm on a
//      representative token matrix (taxonomy parsed from the Elm source, so a
//      parse regression fails loudly here);
//   2. the scanner finds class literals in real call shapes and does NOT
//      false-positive on comments or class-calls quoted inside other strings
//      (markdown samples) — the near-zero-false-positive bar a blocking hook
//      needs.

import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import {
  classify,
  checkFile,
  collectClassStrings,
  loadTaxonomy,
} from "./check-layout-only-classes.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const script = path.join(here, "check-layout-only-classes.mjs");
const taxonomy = loadTaxonomy();

test("taxonomy parses non-empty lists from the Elm rule source", () => {
  assert.ok(taxonomy.layoutKeywords.has("flex"));
  assert.ok(taxonomy.layoutPrefixes.includes("text-left"));
  assert.ok(taxonomy.stylingKeywords.has("italic"));
  assert.ok(taxonomy.stylingPrefixes.includes("font-"));
  assert.ok(taxonomy.m3eNameSet.size > 1000);
  // Specimen exemptions parsed from ReviewConfig.elm's materialDiscipline.
  assert.ok(taxonomy.exemptions.includes("docs/app/Route/Styles/"));
  assert.ok(taxonomy.exemptions.includes("docs/app/Theme/Sections/Typography.elm"));
});

test("classification matrix mirrors the Elm rule", () => {
  const cases = [
    // typography — the violation class this whole effort is about
    ["text-sm", "Styling"],
    ["text-[13px]", "Styling"],
    ["font-bold", "Styling"],
    ["md:text-lg", "Styling"],
    ["leading-tight", "Styling"],
    // paint
    ["bg-red-500", "Styling"],
    ["!bg-red-500", "Styling"],
    ["rounded-lg", "Styling"],
    ["inset-shadow-lg", "Styling"], // shadowed styling under a layout prefix
    ["[color:red]", "Styling"], // arbitrary property
    // proprietary dead tokens
    ["ds-card", "Proprietary"],
    ["t-heading", "Proprietary"],
    // fake m3e utility
    ["m3e-totally-not-real-utility", "DeadM3eUtility"],
    // layout — allowed
    ["flex", "Allowed"],
    ["gap-4", "Allowed"],
    ["md:grid-cols-2", "Allowed"],
    ["text-left", "Allowed"], // alignment lives under text- but is layout
    ["-mx-4", "Allowed"],
    ["inset-2", "Allowed"],
    ["truncate", "Allowed"],
    // sanctioned bridges
    ["[--m3e-nav-rail-icon-button-inset:auto]", "Allowed"],
    // variant prefixes with arbitrary values keep their depth-0 utility
    ["hover:bg-[url(https://x)]", "Styling"],
  ];
  for (const [token, expected] of cases) {
    assert.equal(classify(token, taxonomy), expected, `token: ${token}`);
  }
  // A real manifest utility (exact and with a -* suffix value).
  const [realName] = taxonomy.m3eNames;
  assert.equal(classify(realName, taxonomy), "Allowed");
  assert.equal(classify(`${realName}-4`, taxonomy), "Allowed");
});

test("scanner finds class literals in real call shapes only", () => {
  const source = [
    "module Page exposing (view)",
    "",
    "view =",
    '    div [ TA.class "flex text-sm", Attr.class "gap-4" ]',
    '        [ span [ class "font-bold" ] []',
    '        , btn |> Button.withClass "bg-red-500"',
    '        , div [ classList [ ( "rounded-lg", True ), ( "flex", False ) ] ] []',
    "        ]",
    "",
    "-- a comment mentioning class \"text-sm\" must not count",
    "",
    "{-| doc comment with `TA.class \"text-9xl\"` must not count -}",
    "sample =",
    '    "markdown sample: `TA.class \\"text-sm\\"` inside a plain string"',
  ].join("\n");
  const found = collectClassStrings(source).map((s) => s.text);
  assert.deepEqual(found, [
    "flex text-sm",
    "gap-4",
    "font-bold",
    "bg-red-500",
    "rounded-lg",
    "flex",
  ]);
});

function writeTemp(name, content) {
  const dir = mkdtempSync(path.join(tmpdir(), "layout-only-"));
  const file = path.join(dir, name);
  writeFileSync(file, content);
  return file;
}

test("checkFile reports violations with line numbers, skips Seam modules", () => {
  const bad = writeTemp(
    "Bad.elm",
    'module Bad exposing (v)\n\nv =\n    div [ class "flex text-sm font-bold" ] []\n',
  );
  const violations = checkFile(bad, taxonomy);
  assert.deepEqual(
    violations.map((v) => [v.line, v.token, v.verdict]),
    [
      [4, "text-sm", "Styling"],
      [4, "font-bold", "Styling"],
    ],
  );

  const seam = writeTemp(
    "Seam.elm",
    'module Seam exposing (v)\n\nv =\n    div [ class "text-sm" ] []\n',
  );
  assert.deepEqual(checkFile(seam, taxonomy), []);

  const nonElm = writeTemp("notes.md", 'class "text-sm"');
  assert.deepEqual(checkFile(nonElm, taxonomy), []);
});

test("hook mode blocks violations (exit 2) and passes clean files (exit 0)", () => {
  const bad = writeTemp(
    "Bad.elm",
    'module Bad exposing (v)\n\nv =\n    div [ class "text-[13px]" ] []\n',
  );
  const blocked = spawnSync(process.execPath, [script, "--hook"], {
    input: JSON.stringify({ tool_input: { file_path: bad } }),
    encoding: "utf8",
  });
  assert.equal(blocked.status, 2);
  assert.match(blocked.stderr, /text-\[13px\]/);
  assert.match(blocked.stderr, /typography\.md/);

  const good = writeTemp(
    "Good.elm",
    'module Good exposing (v)\n\nv =\n    div [ class "flex gap-4 m3e-card-padding-4" ] []\n',
  );
  const passed = spawnSync(process.execPath, [script, "--hook"], {
    input: JSON.stringify({ tool_input: { file_path: good } }),
    encoding: "utf8",
  });
  assert.equal(passed.status, 0, passed.stderr);

  // Garbage stdin never blocks.
  const garbage = spawnSync(process.execPath, [script, "--hook"], {
    input: "not json",
    encoding: "utf8",
  });
  assert.equal(garbage.status, 0);
});

test("--all over the real reviewed sources is clean (regression pin)", () => {
  const result = spawnSync(process.execPath, [script, "--all"], {
    encoding: "utf8",
  });
  assert.equal(result.status, 0, result.stderr);
});
