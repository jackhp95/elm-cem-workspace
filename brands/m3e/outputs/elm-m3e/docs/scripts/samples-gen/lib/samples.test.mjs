// Unit tests for the sample extractor's parsing half. The chunker is the subtle
// part: guide blocks stack several top-level things (a `-- GOOD` expression next
// to a `-- WRONG` one, a declaration under its own annotation, a stray `import`),
// and getting that split wrong produces a module that fails to compile for a
// reason that has nothing to do with the sample.

import assert from "node:assert/strict";
import { test } from "node:test";

import {
  boundNames,
  buildSampleModule,
  codeBlockCalls,
  escapeTripleQuoted,
  isDeclarationItem,
  isImportItem,
  parseMarker,
  referencedModules,
  sampleSources,
  splitItems,
  stringDeclarations,
  unescapeTripleQuoted,
} from "./samples.mjs";

const alwaysResolves = () => true;

test("splitItems keeps a comment block with the item beneath it", () => {
  const items = splitItems(`-- one
expr1

-- two
expr2`);
  assert.equal(items.length, 2);
  assert.deepEqual(items[0].comments, ["-- one"]);
  assert.deepEqual(items[0].body, ["expr1"]);
  assert.deepEqual(items[1].comments, ["-- two"]);
});

test("splitItems separates consecutive column-0 expressions", () => {
  // /guide/theming lists three role examples with no blank line between them.
  const items = splitItems(`a [] rows
b [] rows
c [] rows`);
  assert.equal(items.length, 3);
});

test("splitItems keeps a type annotation with its definition", () => {
  const items = splitItems(`snackbar : Toast -> Element k a msg
snackbar t =
    body t`);
  assert.equal(items.length, 1);
  assert.equal(items[0].body.length, 3);
});

test("splitItems treats an indented line as a continuation", () => {
  const items = splitItems(`f =
    g
        [ h ]`);
  assert.equal(items.length, 1);
});

test("isImportItem / isDeclarationItem classify the three item shapes", () => {
  const [imp] = splitItems("import M3e.Theme as Theme");
  const [decl] = splitItems("emailField =\n    M3e.formField [] []");
  const [expr] = splitItems("M3e.button [] []");
  assert.equal(isImportItem(imp), true);
  assert.equal(isImportItem(decl), false);
  assert.equal(isDeclarationItem(decl), true);
  assert.equal(isDeclarationItem(expr), false);
});

test("boundNames collects declaration names and their parameters", () => {
  const items = splitItems("view model =\n    M3e.toNode saveButton");
  const bound = boundNames(items);
  assert.equal(bound.has("view"), true);
  assert.equal(bound.has("model"), true);
});

test("referencedModules ignores comments and string contents", () => {
  const mods = referencedModules(`M3e.button [ TA.name "Not.A.module" ] [] -- Nor.This.one`);
  assert.deepEqual([...mods].sort(), ["M3e", "TA"]);
});

test("referencedModules picks up qualified TYPE references", () => {
  const mods = referencedModules("f : Element (TypedHtml.Grouping.DivIs s) a msg");
  assert.equal(mods.has("TypedHtml.Grouping"), true);
});

test("buildSampleModule resolves the default aliases the guide writes", () => {
  const src = buildSampleModule({
    moduleName: "Sample.X.Y",
    code: 'M3e.icon [ TA.name "star" ] []',
    provenance: "`Route.Guide.X.y`",
    resolves: alwaysResolves,
  });
  assert.match(src, /^import M3e$/m);
  assert.match(src, /^import TypedHtml\.Attributes as TA$/m);
  assert.match(src, /^shown0_ =$/m);
});

test("buildSampleModule lets the sample's own alias win", () => {
  const src = buildSampleModule({
    moduleName: "Sample.X.Y",
    code: "import M3e.Values as Value\n\nValue.filled",
    provenance: "`Route.Guide.X.y`",
    resolves: alwaysResolves,
  });
  assert.match(src, /^import M3e\.Values as Value$/m);
  assert.equal((src.match(/^import /gm) || []).length, 1);
});

test("buildSampleModule does not import a stub the sample binds itself", () => {
  const src = buildSampleModule({
    moduleName: "Sample.X.Y",
    code: "view model =\n    M3e.toNode model",
    provenance: "`Route.Guide.X.y`",
    resolves: alwaysResolves,
  });
  assert.doesNotMatch(src, /Sample\.Support/);
});

test("buildSampleModule imports the stubs a fragment leans on", () => {
  const src = buildSampleModule({
    moduleName: "Sample.X.Y",
    code: "Theme.view [] [ appBody ]",
    provenance: "`Route.Guide.X.y`",
    resolves: alwaysResolves,
  });
  assert.match(src, /^import Sample\.Support exposing \(appBody\)$/m);
});

test("buildSampleModule leaves an unresolvable module un-imported", () => {
  // A bad `import` aborts the compile before type-checking and would hide every
  // real error; left alone, elm reports it at the one use site.
  const src = buildSampleModule({
    moduleName: "Sample.X.Y",
    code: "PagesMsg.fromMsg Close",
    provenance: "`Route.Guide.X.y`",
    resolves: (m) => m !== "PagesMsg",
  });
  assert.doesNotMatch(src, /import PagesMsg/);
});

test("stringDeclarations reads a marker across elm-format's blank lines", () => {
  const decls = stringDeclarations(`module R exposing (a)


-- @sample expect-compile-error: the point of the page


brokenCode : String
brokenCode =
    """M3e.button [] []"""
`);
  assert.equal(decls.get("brokenCode").marker.kind, "expect-compile-error");
  assert.equal(decls.get("brokenCode").marker.reason, "the point of the page");
});

test("stringDeclarations does not borrow the previous declaration's comment", () => {
  const decls = stringDeclarations(`-- @sample skip: not elm


first : String
first =
    """a"""


second : String
second =
    """b"""
`);
  assert.equal(decls.get("first").marker.kind, "skip");
  assert.equal(decls.get("second").marker, null);
});

test("parseMarker splits kind, rule and reason", () => {
  const m = parseMarker("-- @sample expect-review NoRedundantAttributeEscape: it is the lesson\n");
  assert.deepEqual(m, {
    kind: "expect-review",
    rule: "NoRedundantAttributeEscape",
    reason: "it is the lesson",
  });
});

test("parseMarker keeps a reason that wraps onto further comment lines", () => {
  const m = parseMarker("-- @sample skip: the first half\n-- and the second half\n");
  assert.equal(m.reason, "the first half and the second half");
});

test("parseMarker ignores a @sample-source marker", () => {
  assert.equal(parseMarker("-- @sample-source seamsTwoColumn\n"), null);
});

test("codeBlockCalls finds identifier, qualified and inline arguments", () => {
  const calls = codeBlockCalls(`
    [ Doc.codeBlock Doc.Elm seamCode
    , Doc.codeBlock Doc.Elm Samples.seamsTwoColumn
    , codeBlock Shell """
    ]`);
  assert.deepEqual(calls, [
    { lang: "Elm", arg: "seamCode" },
    { lang: "Elm", arg: "Samples.seamsTwoColumn" },
    { lang: "Shell", arg: '"""' },
  ]);
});

test("sampleSources lifts a whole declaration, dropping the annotation", () => {
  const [found] = sampleSources(`-- @sample-source seamsTwoColumn


twoColumn : Element (TypedHtml.Grouping.DivIs s) adm_ msg
twoColumn =
    TypedHtml.div []
        [ emailField ]


next : Int
next =
    1
`);
  assert.equal(found.exportName, "seamsTwoColumn");
  assert.equal(found.code, "twoColumn =\n    TypedHtml.div []\n        [ emailField ]");
});

test("sampleSources -body dedents and drops the binding name", () => {
  const [found] = sampleSources(`-- @sample-source-body guideSavedButton


savedButton : Element k a msg
savedButton =
    M3e.button []
        [ M3e.text "Save" ]
`);
  assert.equal(found.code, 'M3e.button []\n    [ M3e.text "Save" ]');
});

test("triple-quoted escapes round-trip", () => {
  const shown = "update = \\_ model -> model";
  assert.equal(unescapeTripleQuoted("update = \\\\_ model -> model"), shown);
  assert.equal(unescapeTripleQuoted(escapeTripleQuoted(shown)), shown);
});
