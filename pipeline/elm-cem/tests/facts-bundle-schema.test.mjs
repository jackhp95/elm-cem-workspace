// facts-bundle-schema.test.mjs — M1.c. TDD for the facts-bundle validator
// (bin/validate-facts-bundle.js): a malformed bundle must be REJECTED (missing
// required field, wrong type, absent provenance stamp) and a valid one must
// be ACCEPTED, against the real docs/facts-bundle/schema.json. Run standalone:
// `node tests/facts-bundle-schema.test.mjs`. Wired into `npm test`.

import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { repo, makePlainCheck } from "./lib/harness.mjs";

const workspaceRoot = path.resolve(repo, "..", "..");
const require = createRequire(import.meta.url);
const { validate, validateBrandFacts } = require(path.join(repo, "bin", "validate-facts-bundle.js"));

const schemaPath = path.join(workspaceRoot, "docs", "facts-bundle", "schema.json");
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));

const { check, failureCount } = makePlainCheck();

// --- a minimal, VALID Face B and Face C, hand-built to the schema's own shape ---

function validFaceB() {
  return {
    schemaVersion: 1,
    provenance: {
      generator: { name: "elm-cem", version: "0.3.1", commit: null },
      source: {
        package: "@m3e/web",
        version: "2.7.3",
        sha: null,
        manifestPath: "docs/node_modules/@m3e/web/dist/custom-elements.json",
      },
    },
    components: [
      {
        tag: "m3e-button",
        declarationName: "M3eButtonElement",
        modulePath: "src/button/ButtonElement.ts",
        attributes: [
          {
            name: "variant",
            kind: "enum",
            type: { raw: "ButtonVariant", resolved: "\"filled\" | \"tonal\"", source: "dts-alias" },
            enum: { values: ["filled", "tonal"], open: false },
          },
        ],
        slots: [{ name: "" }],
        events: [],
        cssProperties: [],
      },
    ],
  };
}

function validFaceC() {
  return {
    schemaVersion: 1,
    provenance: {
      producer: { elmCem: { version: "0.3.1", commit: null } },
      brand: { name: "elm-m3e", commit: null },
      source: { package: "@m3e/web", version: "2.7.3", sha: null },
    },
    lib: "M3e",
    surfaceKeys: ["top", "build"],
    defaultSurface: "top",
    facets: [
      { key: "top", facet: "Standard", form: "double-list" },
      { key: "build", facet: "Build", form: "pipeline", finalizer: "toElement" },
    ],
    components: {
      "m3e-button": {
        cemTag: "m3e-button",
        component: "button",
        module: "M3e.Button",
        rootNamespace: "M3e",
        setters: { variant: "variant" },
        enums: { variant: { values: [{ elm: "filled", key: "filled", token: "M3e.Values.filled", raw: "filled" }] } },
        surfaces: { top: { facet: "Standard", module: "M3e.Button", entry: "view", form: "double-list" } },
      },
    },
  };
}

// --- schemaVersion 2: brand-facts.json (canonical core + targets.elm) ---
// No producer exists yet (phase 1 of the Brand Facts design is schema-only),
// so this fixture — not a generated file — is the spec for the shape.

function validBrandFacts() {
  return {
    schemaVersion: 2,
    provenance: {
      generator: { name: "elm-cem", version: "0.3.1", commit: null },
      source: {
        package: "@m3e/web",
        version: "2.7.3",
        sha: null,
        manifestPath: "docs/node_modules/@m3e/web/dist/custom-elements.json",
      },
      dts: { dir: "docs/node_modules/@m3e/web/dist", fileCount: 42, aliasCount: 17 },
      configFiles: [
        { path: "brands/m3e/inputs/cem/config/slots.json", hash: "sha256-abc123" },
      ],
    },
    lib: "M3e",
    components: {
      "m3e-list-item": {
        declarationName: "M3eListItemElement",
        attributes: {
          disabled: { kind: "boolean", type: "boolean" },
          variant: {
            kind: "enum",
            type: "ListItemVariant",
            enum: ["one-line", "two-line", "three-line"],
            default: "\"one-line\"",
          },
        },
        cssProperties: {
          "--m3e-list-item-container-color": { syntax: "<color>", default: null },
        },
        events: {
          "m3e-list-item-click": { type: "CustomEvent<void>", description: "Fired on activation." },
        },
        slots: {
          leading: { admits: ["avatar", "icon", "text"] },
          trailing: { admits: ["avatar", "icon", "switch"], multi: true },
          overline: {},
        },
        admittedBy: ["m3e-list"],
        targets: {
          elm: {
            core: { barrel: "listItem" },
            elements: {
              module: "M3e.Element.ListItem",
              ctor: "listItem",
              slotSetters: { leading: "leading", trailing: "trailing" },
            },
            build: { module: "M3e.Build.ListItem", seed: "build", finalizer: "toElement" },
            components: { module: "M3e.Component.List", member: "listItem" },
          },
        },
      },
    },
    targets: {
      elm: {
        packages: {
          core: { package: "jackhp95/elm-m3e-core", generator: "split", deps: [], contract: { composition: "none" } },
          elements: {
            package: "jackhp95/elm-m3e-elements",
            generator: "split",
            deps: ["core"],
            contract: { slotSetterChild: "compiler", rawContentChild: "elm-review" },
          },
          build: {
            package: "jackhp95/elm-m3e-build",
            generator: "split",
            deps: ["elements", "core"],
            contract: { composition: "compiler" },
          },
          components: {
            package: "jackhp95/elm-m3e-components",
            generator: "gen-family-package",
            deps: ["elements", "core"],
            contract: { composition: "compiler" },
          },
          icons: { package: "jackhp95/elm-m3e-icons", generator: "gen-icon-module", deps: [], contract: {} },
          facts: { package: "jackhp95/elm-m3e-facts", generator: "split", deps: [], contract: {} },
        },
      },
    },
  };
}

// --- valid bundle: accepted ---

{
  const bundle = { schemaVersion: 1, faceB: validFaceB(), faceC: validFaceC() };
  const result = validate(schema, bundle);
  check(result.valid, `valid bundle accepted (errors: ${JSON.stringify(result.errors)})`);
}

{
  const result = validate(schema, validFaceB(), "faceB");
  check(result.valid, `valid faceB alone accepted (errors: ${JSON.stringify(result.errors)})`);
}

{
  const result = validate(schema, validFaceC(), "faceC");
  check(result.valid, `valid faceC alone accepted (errors: ${JSON.stringify(result.errors)})`);
}

// --- schemaVersion 2: valid brand-facts.json accepted ---

{
  const result = validate(schema, validBrandFacts(), "brandFacts");
  check(result.valid, `valid brand-facts.json accepted (errors: ${JSON.stringify(result.errors)})`);
}

{
  // validateBrandFacts is sugar for validate(schema, data, "brandFacts") —
  // must agree with it exactly.
  const direct = validate(schema, validBrandFacts(), "brandFacts");
  const sugar = validateBrandFacts(schema, validBrandFacts());
  check(sugar.valid === direct.valid, "validateBrandFacts agrees with validate(..., \"brandFacts\") on a valid bundle");
}

// --- malformed bundles: rejected ---

{
  // missing required top-level field (`faceC`)
  const bundle = { schemaVersion: 1, faceB: validFaceB() };
  const result = validate(schema, bundle);
  check(!result.valid, "bundle missing faceC is rejected");
}

{
  // wrong type: schemaVersion as a string instead of an integer
  const bundle = { schemaVersion: "1", faceB: validFaceB(), faceC: validFaceC() };
  const result = validate(schema, bundle);
  check(!result.valid, "bundle with schemaVersion as a string is rejected");
}

{
  // absent provenance stamp on Face B
  const faceB = validFaceB();
  delete faceB.provenance;
  const result = validate(schema, { schemaVersion: 1, faceB, faceC: validFaceC() });
  check(!result.valid, "bundle with no faceB.provenance is rejected");
}

{
  // absent provenance stamp on Face C
  const faceC = validFaceC();
  delete faceC.provenance;
  const result = validate(schema, { schemaVersion: 1, faceB: validFaceB(), faceC });
  check(!result.valid, "bundle with no faceC.provenance is rejected");
}

{
  // a component missing a required field (`attributes`)
  const faceB = validFaceB();
  delete faceB.components[0].attributes;
  const result = validate(schema, faceB, "faceB");
  check(!result.valid, "faceB component missing `attributes` is rejected");
}

{
  // additionalProperties: false — an unknown top-level key
  const bundle = { schemaVersion: 1, faceB: validFaceB(), faceC: validFaceC(), extra: true };
  const result = validate(schema, bundle);
  check(!result.valid, "bundle with an unknown top-level property is rejected");
}

{
  // enum violation: an attribute `kind` outside the schema's enum
  const faceB = validFaceB();
  faceB.components[0].attributes[0].kind = "not-a-real-kind";
  const result = validate(schema, faceB, "faceB");
  check(!result.valid, "faceB attribute with an invalid `kind` enum value is rejected");
}

// --- schemaVersion 2: malformed brand-facts.json shapes are rejected ---

function invalidSlotWrongKeyBrandFacts() {
  const bf = validBrandFacts();
  // "kinds" is not a real key on a slot — the field is `admits` (spec §4.2).
  // additionalProperties: false on brandFactsSlot must catch this.
  bf.components["m3e-list-item"].slots.leading = { kinds: ["avatar", "icon", "text"] };
  return bf;
}

function invalidAdmitsWrongTypeBrandFacts() {
  const bf = validBrandFacts();
  // `admits` must be an array (the listed-kinds case); an object is never valid.
  bf.components["m3e-list-item"].slots.leading.admits = { any: true };
  return bf;
}

function invalidMissingDeclarationNameBrandFacts() {
  const bf = validBrandFacts();
  delete bf.components["m3e-list-item"].declarationName;
  return bf;
}

function invalidSmearedElmIdBrandFacts() {
  const bf = validBrandFacts();
  // An Elm module name leaked directly onto the canonical core instead of
  // living under targets.elm.elements.module (spec §5.8: language-neutral core).
  bf.components["m3e-list-item"].module = "M3e.Element.ListItem";
  return bf;
}

function invalidSchemaVersionBrandFacts() {
  const bf = validBrandFacts();
  bf.schemaVersion = 1; // this shape is schemaVersion 2, not the faceB/faceC bundle's 1
  return bf;
}

function invalidMissingPackageKeyBrandFacts() {
  const bf = validBrandFacts();
  // targets.elm.packages must enumerate all six destination packages (spec §3.4).
  delete bf.targets.elm.packages.icons;
  return bf;
}

{
  const result = validateBrandFacts(schema, invalidSlotWrongKeyBrandFacts());
  check(!result.valid, "slot with `kinds` instead of `admits` is rejected (additionalProperties: false)");
}

{
  const result = validateBrandFacts(schema, invalidAdmitsWrongTypeBrandFacts());
  check(!result.valid, "`admits` as an object instead of an array is rejected");
}

{
  const result = validateBrandFacts(schema, invalidMissingDeclarationNameBrandFacts());
  check(!result.valid, "component missing required `declarationName` is rejected");
}

{
  const result = validateBrandFacts(schema, invalidSmearedElmIdBrandFacts());
  check(!result.valid, "an Elm module name smeared onto the canonical core (outside targets.elm) is rejected");
}

{
  const result = validateBrandFacts(schema, invalidSchemaVersionBrandFacts());
  check(!result.valid, "brand-facts.json with schemaVersion 1 (not 2) is rejected");
}

{
  const result = validateBrandFacts(schema, invalidMissingPackageKeyBrandFacts());
  check(!result.valid, "targets.elm.packages missing a required package key (`icons`) is rejected");
}

if (failureCount() > 0) {
  console.error(`facts-bundle-schema: ${failureCount()} check(s) failed`);
  process.exit(1);
}
console.log("facts-bundle-schema: all checks passed");
