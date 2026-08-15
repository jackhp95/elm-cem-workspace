// gen-compose-attrs.mjs — `npm run gen:compose-attrs`.
//
// WHY THIS EXISTS
//   The compose editor needs to know, for every attribute name a component's
//   Fact actually reaches, whether it is boolean/string/float/int-shaped (so
//   `Cem.Compose` can offer the right menu) and how to turn a configured
//   value into a real HTML attribute and a real Elm code line. That mapping
//   is derivable — `M3e.Attributes.elm` already says each setter's shape, and
//   `M3e.Review.Facts.elm` already says which setter names are reachable —
//   so it is generated here rather than hand-maintained, per spec §9.5. A
//   hand-written table goes stale exactly when `M3e.Attributes` gains,
//   renames, or retires a setter (spec §11.1 notes an upstream regen adds 204
//   portmanteau enum attributes); a generated one cannot.
//
// INPUTS (read-only)
//   ../../src/M3e/Attributes.elm       top-level setter signatures — the
//                                       FIRST argument type classifies the
//                                       setter as Bool/String/Float/Int, or
//                                       leaves it unclassifiable (a phantom
//                                       `Value`, an `Attribute msg`, a list —
//                                       this is how event setters and enum
//                                       setters are excluded from `kinds`).
//   ../../src/M3e/Review/Facts.elm     `facts` — every component's
//                                       `attrRewrites` (barrel setter name ->
//                                       per-component setter name) and
//                                       `enums` (attribute name -> its legal
//                                       tokens). Only names BOTH classified
//                                       AND reachable through some
//                                       component's `attrRewrites` get a row
//                                       — this is how the table ends up with
//                                       no dead entries.
//
// OUTPUT (generated; committed; never hand-edited)
//   app/Compose/Attrs.elm
//     kinds       : Dict String Cem.Compose.AttrKind
//     toAttribute : ( String, Cem.Compose.AttrValue ) -> List (Html.Attribute msg)
//     witness     : List ()                    (compile-time only, never called)
//     codeLineFor : String -> Cem.Compose.AttrValue -> Maybe String
//
// `npm run check:compose-attrs` re-runs this to a temp file and byte-compares
// against the committed output, so drift between `M3e.Attributes`/
// `M3e.Review.Facts` and the generated table is a CI-visible failure rather
// than a silent staleness.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(HERE, "..");
const M3E_ROOT = path.resolve(DOCS, "..");

const ATTRIBUTES_PATH = path.join(M3E_ROOT, "src", "M3e", "Attributes.elm");
const FACTS_PATH = path.join(M3E_ROOT, "src", "M3e", "Review", "Facts.elm");
const OUTPUT_PATH = path.join(DOCS, "app", "Compose", "Attrs.elm");
const ELM_FORMAT = path.join(DOCS, "node_modules", ".bin", "elm-format");

// The whole docs/app tree is elm-format-validated by `elm-m3e`'s check:format,
// so the generated table must itself be format-compliant. Formatting the raw
// output makes the canonical generator output = the formatted output, so
// check:compose-attrs (which regenerates + formats the same way) still holds.
function formatElm(filePath) {
  execFileSync(ELM_FORMAT, ["--yes", filePath], { stdio: "ignore" });
}

const NAME_RE = "[a-zA-Z_][a-zA-Z0-9_]*";

// ---------------------------------------------------------------------------
// Input A: M3e/Attributes.elm — classify every top-level setter by its first
// argument type. Anything not bare Bool/String/Float/Int is unclassifiable.
// ---------------------------------------------------------------------------

function classifyFirstArg(typeAfterColon) {
  const t = typeAfterColon.trim();
  if (/^Bool\s*->/.test(t)) return "BoolAttr";
  if (/^String\s*->/.test(t)) return "StringAttr";
  if (/^Float\s*->/.test(t)) return "FloatAttr";
  if (/^Int\s*->/.test(t)) return "IntAttr";
  return null;
}

function parseAttributeKinds(src) {
  const sigRe = new RegExp(`^(${NAME_RE})\\s*:\\s*(.+)$`);
  const kinds = new Map();
  const allNames = new Set();
  for (const line of src.split("\n")) {
    const m = sigRe.exec(line);
    if (!m) continue;
    allNames.add(m[1]);
    const kind = classifyFirstArg(m[2]);
    if (kind) kinds.set(m[1], kind);
  }
  return { kinds, allNames };
}

// ---------------------------------------------------------------------------
// Input B: M3e/Review/Facts.elm — every component's `attrRewrites` (barrel ->
// per-component setter name) and `enums` (attribute -> legal tokens). Extracted
// with bracket-depth counting rather than a single non-greedy regex, because
// `enums` bodies nest a `[ tokens ]` list inside each `( attr, [ ... ] )` pair.
// ---------------------------------------------------------------------------

function extractBalancedLists(src, keyword) {
  const results = [];
  const re = new RegExp(`${keyword}\\s*=\\s*\\[`, "g");
  let m;
  while ((m = re.exec(src))) {
    let depth = 1;
    let i = m.index + m[0].length;
    const start = i;
    while (depth > 0 && i < src.length) {
      if (src[i] === "[") depth++;
      else if (src[i] === "]") depth--;
      i++;
    }
    results.push(src.slice(start, i - 1));
  }
  return results;
}

function parseFacts(src) {
  const rewriteBodies = extractBalancedLists(src, "attrRewrites");
  const enumBodies = extractBalancedLists(src, "enums");

  const rewritePairRe = new RegExp(`\\(\\s*"(${NAME_RE})"\\s*,\\s*"(${NAME_RE})"\\s*\\)`, "g");
  const rewritePairs = new Set();
  for (const body of rewriteBodies) {
    rewritePairRe.lastIndex = 0;
    let mm;
    while ((mm = rewritePairRe.exec(body))) rewritePairs.add(`${mm[1]}|${mm[2]}`);
  }

  const enumEntryRe = new RegExp(`\\(\\s*"(${NAME_RE})"\\s*,\\s*\\[([^\\]]*)\\]\\s*\\)`, "g");
  const tokenRe = new RegExp(`"(${NAME_RE})"`, "g");
  const enumPairs = new Set();
  for (const body of enumBodies) {
    enumEntryRe.lastIndex = 0;
    let mm;
    while ((mm = enumEntryRe.exec(body))) {
      const attr = mm[1];
      tokenRe.lastIndex = 0;
      let tm;
      while ((tm = tokenRe.exec(mm[2]))) enumPairs.add(`${attr}|${tm[1]}`);
    }
  }

  return { rewritePairs, enumPairs };
}

// ---------------------------------------------------------------------------
// Build the generated module's data from both inputs.
// ---------------------------------------------------------------------------

function build() {
  const { kinds: attrKinds, allNames } = parseAttributeKinds(fs.readFileSync(ATTRIBUTES_PATH, "utf8"));
  const { rewritePairs, enumPairs } = parseFacts(fs.readFileSync(FACTS_PATH, "utf8"));

  // barrel setter name -> per-component setter name (the key the compose
  // editor actually stores attrs under, per Cem.Compose's own `attrChips`,
  // which keys on `attrRewrites`'s SECOND element). Almost every pair is an
  // identity (barrel == per-component); `nameToBarrel` records the real
  // barrel name to look up for classification and code generation either way.
  const nameToBarrel = new Map();
  for (const pair of rewritePairs) {
    const [barrel, componentName] = pair.split("|");
    if (!nameToBarrel.has(componentName)) nameToBarrel.set(componentName, barrel);
  }

  // kinds: keyed by the per-component (reachable) name, valued by the
  // classification of its real M3e.Attributes barrel setter.
  const kindsRows = [];
  for (const [componentName, barrel] of nameToBarrel) {
    const kind = attrKinds.get(barrel);
    if (kind) kindsRows.push([componentName, barrel, kind]);
  }
  kindsRows.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));

  // witness (non-enum): one row per DISTINCT barrel name actually reachable
  // and classified — proves the shared M3e.Attributes setter still exists
  // and still has the shape `kinds` claims.
  const witnessBarrels = [...new Set(kindsRows.map((r) => r[1]))].sort();

  // witness (enum): one row per distinct (attribute, token) pair, proving
  // both the M3e.Attributes setter and the M3e.Values token still exist.
  // Every enum attribute name found in `facts` must itself be a real
  // top-level name in M3e.Attributes.elm, or the generated witness would not
  // compile — that failure is deliberately left uncaught here (Step 4 of
  // Task 9 catches it as a real elm make error, not a silently dropped row).
  const enumRows = [...enumPairs]
    .map((p) => p.split("|"))
    .filter(([attr]) => allNames.has(attr))
    .sort((a, b) => (a[0] === b[0] ? (a[1] < b[1] ? -1 : a[1] > b[1] ? 1 : 0) : a[0] < b[0] ? -1 : 1));

  const droppedEnumAttrs = [...enumPairs].map((p) => p.split("|")[0]).filter((attr) => !allNames.has(attr));
  if (droppedEnumAttrs.length > 0) {
    console.error(
      `gen-compose-attrs: WARNING — ${new Set(droppedEnumAttrs).size} enum attribute name(s) in Facts are absent from M3e.Attributes.elm and were dropped from witness: ${[...new Set(droppedEnumAttrs)].join(", ")}`
    );
  }

  return { kindsRows, witnessBarrels, enumRows, nameToBarrel };
}

// ---------------------------------------------------------------------------
// Render the Elm module.
// ---------------------------------------------------------------------------

function elmString(s) {
  return (
    '"' +
    s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n") +
    '"'
  );
}

function literalFor(kind) {
  switch (kind) {
    case "BoolAttr":
      return "True";
    case "StringAttr":
      return '""';
    case "FloatAttr":
      return "0";
    case "IntAttr":
      return "0";
    default:
      throw new Error(`unreachable kind ${kind}`);
  }
}

function render({ kindsRows, witnessBarrels, enumRows, nameToBarrel }) {
  const kindsList = kindsRows
    .map(([name, , kind], i) => `        ${i === 0 ? "[" : ","} ( ${elmString(name)}, Cem.Compose.${kind} )`)
    .join("\n");

  const setterWitnessList = witnessBarrels
    .map((barrel) => `M3e.Attributes.${barrel} ${literalFor(kindsRows.find((r) => r[1] === barrel)[2])}`)
    .map((expr, i) => `    ${i === 0 ? "[" : ","} always () (${expr})`)
    .join("\n");

  const enumWitnessList = enumRows
    .map(([attr, token]) => `always () (M3e.Attributes.${attr} M3e.Values.${token})`)
    .map((expr) => `    , ${expr}`)
    .join("\n");

  // Every reachable name gets a `setterFor` branch, not just the classified
  // (non-enum) subset in `kindsRows` — `codeLineFor` must also emit a line
  // for an `AttrEnum` value, whose setter is enum-typed and therefore never
  // appears in `kinds`.
  const nameToBarrelEntries = [...nameToBarrel.entries()].sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));

  const codeLineBranches = nameToBarrelEntries
    .map(([componentName, barrel]) => `        ${elmString(componentName)} ->\n            Just "M3e.Attributes.${barrel}"`)
    .join("\n\n");

  return `module Compose.Attrs exposing (kinds, toAttribute, witness, codeLineFor)

{- GENERATED by scripts/gen-compose-attrs.mjs — do not edit.

Derives, from \`M3e.Attributes\` (setter shapes) and \`M3e.Review.Facts\`
(reachable setter names), the attribute kind table the compose editor needs.
Regenerate with \`npm run gen:compose-attrs\`; \`npm run check:compose-attrs\`
fails the gate on drift.
-}

import Cem.Compose
import Dict exposing (Dict)
import Html
import Html.Attributes
import M3e.Attributes
import M3e.Values


{-| Every reachable, classified attribute name, and its shape. Keyed by the
per-component setter name (the same name \`Cem.Compose.attrChips\` reports),
because that is what the editor's \`Model.attrKinds\` is looked up by.
-}
kinds : Dict String Cem.Compose.AttrKind
kinds =
    Dict.fromList
${kindsList}
        ]


{-| Plain \`Html.Attributes.attribute\`, stringified per kind. The preview
renders through \`Html.node\` because which component is on screen is only
known at runtime, so this never touches a typed setter — \`witness\` below is
what keeps this table honest against \`M3e.Attributes\` instead.

A half-typed number (\`String.toFloat\`/\`String.toInt\` failing) contributes no
attribute at all, rather than a garbage one.
-}
toAttribute : ( String, Cem.Compose.AttrValue ) -> List (Html.Attribute msg)
toAttribute ( name, value ) =
    case value of
        Cem.Compose.AttrBool True ->
            [ Html.Attributes.attribute name "" ]

        Cem.Compose.AttrBool False ->
            []

        Cem.Compose.AttrString s ->
            [ Html.Attributes.attribute name s ]

        Cem.Compose.AttrEnum token ->
            [ Html.Attributes.attribute name (kebab token) ]

        Cem.Compose.AttrFloat raw ->
            String.toFloat raw
                |> Maybe.map (\\f -> [ Html.Attributes.attribute name (String.fromFloat f) ])
                |> Maybe.withDefault []

        Cem.Compose.AttrInt raw ->
            String.toInt raw
                |> Maybe.map (\\i -> [ Html.Attributes.attribute name (String.fromInt i) ])
                |> Maybe.withDefault []


{-| A camelCase enum token (\`"softBoom"\`) to the kebab-case string the real
custom element expects on the wire (\`"soft-boom"\`).
-}
kebab : String -> String
kebab token =
    let
        step char acc =
            if Char.isUpper char then
                acc ++ "-" ++ String.fromChar (Char.toLower char)

            else
                acc ++ String.fromChar char
    in
    String.foldl step "" token


{-| Compile-time only. Every entry references a real \`M3e.Attributes\` setter
and, for enum rows, a real \`M3e.Values\` token, so a renamed setter or a
retired token is a compile error HERE rather than a silent no-op at runtime.
Never called.
-}
witness : List ()
witness =
${setterWitnessList}
${enumWitnessList}
    ]


{-| The Elm code snippet for one configured attribute (e.g.
\`Just "M3e.Attributes.variant M3e.Values.filled"\`), or \`Nothing\` for an
attribute this table does not carry or a number that does not parse. Task 13
assembles these into the generated code preview.
-}
codeLineFor : String -> Cem.Compose.AttrValue -> Maybe String
codeLineFor name value =
    setterFor name
        |> Maybe.andThen (\\setter -> literalFor value |> Maybe.map (\\lit -> setter ++ " " ++ lit))


setterFor : String -> Maybe String
setterFor name =
    case name of
${codeLineBranches}

        _ ->
            Nothing


literalFor : Cem.Compose.AttrValue -> Maybe String
literalFor value =
    case value of
        Cem.Compose.AttrBool True ->
            Just "True"

        Cem.Compose.AttrBool False ->
            Just "False"

        Cem.Compose.AttrString s ->
            Just (codeStringLiteral s)

        Cem.Compose.AttrEnum token ->
            Just ("M3e.Values." ++ token)

        Cem.Compose.AttrFloat raw ->
            String.toFloat raw |> Maybe.map String.fromFloat

        Cem.Compose.AttrInt raw ->
            String.toInt raw |> Maybe.map String.fromInt


codeStringLiteral : String -> String
codeStringLiteral s =
    "\\"" ++ s ++ "\\""
`;
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function main() {
  const checkMode = process.argv.includes("--check");
  const generated = render(build());

  if (!checkMode) {
    fs.mkdirSync(path.dirname(OUTPUT_PATH), { recursive: true });
    fs.writeFileSync(OUTPUT_PATH, generated);
    formatElm(OUTPUT_PATH);
    console.log(`gen-compose-attrs: wrote ${path.relative(DOCS, OUTPUT_PATH)}`);
    return;
  }

  const tmp = path.join(os.tmpdir(), `gen-compose-attrs-check-${process.pid}.elm`);
  fs.writeFileSync(tmp, generated);
  formatElm(tmp);
  const committed = fs.existsSync(OUTPUT_PATH) ? fs.readFileSync(OUTPUT_PATH, "utf8") : null;
  const fresh = fs.readFileSync(tmp, "utf8");
  fs.rmSync(tmp, { force: true });

  if (committed === fresh) {
    console.log("check-compose-attrs: OK — committed table matches the generator's current output.");
    return;
  }

  console.error(
    "check-compose-attrs: FAIL — committed app/Compose/Attrs.elm has drifted from " +
      "M3e.Attributes.elm / M3e.Review.Facts.elm (or was hand-edited). Run `npm run gen:compose-attrs` and commit the result."
  );
  process.exit(1);
}

main();
