// facts-bundle-schema.test.mjs — M1.c. TDD for the facts-bundle validator
// (bin/validate-facts-bundle.js): a malformed bundle must be REJECTED (missing
// required field, wrong type, absent provenance stamp) and a valid one must
// be ACCEPTED, against the real docs/facts-bundle/schema.json. Run standalone:
// `node tests/facts-bundle-schema.test.mjs`. Wired into `npm test`.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { createRequire } from "node:module";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const workspaceRoot = path.resolve(repo, "..", "..");
const require = createRequire(import.meta.url);
const { validate } = require(path.join(repo, "bin", "validate-facts-bundle.js"));

const schemaPath = path.join(workspaceRoot, "docs", "facts-bundle", "schema.json");
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));

let failures = 0;
const check = (ok, msg) => {
  if (ok) console.log(`  PASS  ${msg}`);
  else {
    console.error(`  FAIL  ${msg}`);
    failures += 1;
  }
};

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

if (failures > 0) {
  console.error(`facts-bundle-schema: ${failures} check(s) failed`);
  process.exit(1);
}
console.log("facts-bundle-schema: all checks passed");
