# Brand Facts — Phase 1: canonical schema + validator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Define the `brand-facts.json` canonical shape (`schemaVersion: 2`) in
`docs/facts-bundle/schema.json` and prove it with a hand-rolled validator +
hand-authored fixtures, with **zero** producer/codegen behavior change — no
`brand-facts.json` file is emitted by anything yet. This phase exists purely to
lock the shape and its validator before phase 2 (the producer) exists.

**Architecture:** Add a new, self-contained family of `#/definitions/brandFacts*`
schema nodes to the existing `docs/facts-bundle/schema.json` — **additively**,
alongside (not replacing) the current `faceB`/`faceC` (`schemaVersion: 1`)
definitions, which `tools/check-drift.mjs:90-99` and `tools/gate-all.mjs:287`
still validate real committed bundles against today. The v2 shape needs no new
JSON-Schema keywords: every construct it uses (`type`, `const`, `enum`,
`required`, `properties`, `additionalProperties` as bool-or-schema, `items`,
`$ref`) is already in `validate-facts-bundle.js`'s supported subset (see its
header comment, `core/elm-cem/bin/validate-facts-bundle.js:6-12`). The one code
change to the validator is additive ergonomics: a `validateBrandFacts(schema,
data)` wrapper so phase-2/3 callers (the future producer, `check-drift.mjs`)
don't repeat the string `"brandFacts"` everywhere `validate(schema, data,
"faceB")` is repeated today (`tools/check-drift.mjs:98`,
`tools/gate-all.mjs:287`). Since there is no producer yet, the spec (fixtures)
IS the test: `core/elm-cem/tests/facts-bundle-schema.test.mjs` grows a second
family of hand-built fixture functions (`validBrandFacts()` +
`invalid*BrandFacts()`) mirroring its existing `validFaceB()`/`validFaceC()`
pattern (`core/elm-cem/tests/facts-bundle-schema.test.mjs:19-71`), run through
the same `makePlainCheck()` harness (`core/elm-cem/tests/lib/harness.mjs:44-60`).

**Tech Stack:** Plain Node.js (`node --test`-free; this test file is a plain
script run via `node`, per its own file header), no new dependencies. `pnpm` to
invoke the workspace script.

**Spec:** `core/elm-cem/specs/2026-08-19-brand-facts-design.md` (§4 shape, §5
decisions, §6 open questions, §7 phase 1).

## Global Constraints

Copied verbatim (in substance) from the spec — every task below implicitly
inherits these:

- **Presence/absence is the whole shape's encoding rule** (spec §4.2, §5.3):
  present = authored, absent = default.
  - `admits` **absent** → slot accepts **any** kind (open); `admits: []` →
    **sealed** (accepts nothing); `admits: [...]` → exactly those kinds.
  - `multi` absent → `false`; `required` absent → `false`.
  - `admittedBy` absent on a component → open (any parent may hold it).
  - Consumers must treat **absent ≠ empty**: `admits === undefined` is not
    `admits.length === 0`. The schema must make the distinction possible (never
    require `admits`), and a fixture must exercise both.
- **Package keys are the delivered package family** (spec §3.4, §6): exactly
  `core` / `elements` / `build` / `facts` / `components` / `icons`. Not the
  vestigial construction forms `top`/`build`/`record`/`html` from
  `FactsBundle.elm:73-76`, and not the earlier invented
  `strict`/`loose`/`general`/`escape` — both retired for good (spec §6).
- **Facts is language-neutral** (spec §5.8): the canonical per-component core
  (`attributes`, `cssProperties`, `events`, `slots`, `admittedBy`) carries no
  Elm identifier. Every Elm-specific name (module, ctor, setter) lives under
  `targets.elm`, never smeared into a canonical field.
- **`schemaVersion` is `2`** for this new shape (spec §6), literal-checked via
  `const`, independent of the existing `schemaVersion: 1` faceB/faceC bundle
  which keeps validating unchanged.
- **No `ajv` dependency.** Extend the existing hand-rolled draft-07 subset
  validator (`core/elm-cem/bin/validate-facts-bundle.js`) — it already covers
  every keyword the v2 shape needs (confirmed above); do not add a schema
  library.
- **No producer/codegen changes in this phase** (spec §7 phase 1: "*No
  behavior change yet*"). Nothing generates `brand-facts.json` yet; every
  fixture in this phase is hand-written JS, not machine output.
- **Retire the `top`/`build`/`record`/`html` construction-form vocabulary**
  (spec §7 phase 1, §6): the new schema must not resurrect it. `targets.elm`'s
  per-component keys are the six package names above; there is no `facets`/
  `surfaceKeys`/`defaultSurface` in the v2 shape (those are Face C's, staying
  untouched under the `faceC` definition for the v1 bundle).

---

### Task 1: Author the `brandFacts` (schemaVersion 2) canonical schema definitions

**Files:**
- Modify: `docs/facts-bundle/schema.json:581-582` (insert new definitions
  between the closing `}` of `faceCSurface` and the closing `}` of the
  `definitions` object)
- Test: `core/elm-cem/tests/facts-bundle-schema.test.mjs`

**Interfaces:**
- Consumes: nothing new (pure JSON Schema; `$ref`-resolved by the existing
  `resolveRef`/`validateAgainst` in `core/elm-cem/bin/validate-facts-bundle.js:14-88`,
  unmodified in this task).
- Produces: `#/definitions/brandFacts` (root shape) and its dependents
  `brandFactsProvenance`, `brandFactsComponent`, `brandFactsAttribute`,
  `brandFactsCssProperty`, `brandFactsEvent`, `brandFactsSlot`,
  `brandFactsElmComponentTargets`, `brandFactsTargets`, `brandFactsElmPackage`
  — names Task 2 and Task 3 reuse verbatim, and that a future phase-2 producer
  will validate its output against.

- [ ] **Step 1: Write the failing test — a minimal valid `brand-facts.json` fixture**

Append to `core/elm-cem/tests/facts-bundle-schema.test.mjs`, directly after the
existing `validFaceC()` function (after line 71, before the `// --- valid
bundle: accepted ---` comment):

```js
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
```

Then add the check itself, next to the existing `// --- valid bundle: accepted
---` block (after it, before `// --- malformed bundles: rejected ---`):

```js
// --- schemaVersion 2: valid brand-facts.json accepted ---

{
  const result = validate(schema, validBrandFacts(), "brandFacts");
  check(result.valid, `valid brand-facts.json accepted (errors: ${JSON.stringify(result.errors)})`);
}
```

- [ ] **Step 2: Run it and confirm it fails**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected: the process throws and exits non-zero, before printing the new
check's `PASS`/`FAIL` line — `resolveRef` in
`core/elm-cem/bin/validate-facts-bundle.js:14-21` throws
`validate-facts-bundle: $ref #/definitions/brandFacts does not resolve`
because the definition doesn't exist yet. (All ten prior checks that ran
before this new one still print their `PASS` lines — the crash happens only
once execution reaches the new block, since the file runs top-to-bottom.)

- [ ] **Step 3: Add the schema definitions**

In `docs/facts-bundle/schema.json`, change line 581 from:

```json
      }
    }
  }
}
```

(the four closing lines: `faceCSurface`'s `properties`, `faceCSurface` itself,
`definitions`, and the root object) to insert the new definitions between
`faceCSurface`'s closing `}` and `definitions`'s closing `}`. Concretely,
replace:

```json
        "finalizer": { "type": ["string", "null"], "description": "The function that closes the pipeline form. For the current emitter this is `toElement` (re-exported per component from `M3e.Build`) — NOT `build`, which is the seed." }
      }
    }
  }
}
```

with:

```json
        "finalizer": { "type": ["string", "null"], "description": "The function that closes the pipeline form. For the current emitter this is `toElement` (re-exported per component from `M3e.Build`) — NOT `build`, which is the seed." }
      }
    },

    "brandFacts": {
      "type": "object",
      "title": "brand-facts.json — the single canonical facts interface (schemaVersion 2)",
      "description": "The one comprehensive, language-neutral facts interface (Brand Facts design, core/elm-cem/specs/2026-08-19-brand-facts-design.md §4). Supersedes the Face B / Face C split for every NEW consumer once a producer exists (phase 2); faceB/faceC (schemaVersion 1) remain valid and unchanged for the current bundle in the meantime.",
      "required": ["schemaVersion", "provenance", "lib", "components", "targets"],
      "additionalProperties": false,
      "properties": {
        "schemaVersion": { "type": "integer", "const": 2 },
        "provenance": { "$ref": "#/definitions/brandFactsProvenance" },
        "lib": { "type": "string", "description": "The brand's root Elm namespace (`M3e`)." },
        "components": {
          "type": "object",
          "description": "Keyed by the authoritative CEM tag (e.g. `m3e-list-item`).",
          "additionalProperties": { "$ref": "#/definitions/brandFactsComponent" }
        },
        "targets": { "$ref": "#/definitions/brandFactsTargets" }
      }
    },

    "brandFactsProvenance": {
      "type": "object",
      "description": "Which inputs fed this build (spec §4.5): the CEM package/version/sha, the dts dir, each --config-from file + hash, generator version/commit. Subsumes faceBProvenance + faceCProvenance's two ad-hoc stamps into one block.",
      "required": ["generator", "source"],
      "additionalProperties": false,
      "properties": {
        "generator": {
          "type": "object",
          "required": ["name", "version"],
          "additionalProperties": false,
          "properties": {
            "name": { "type": "string", "description": "e.g. `elm-cem`." },
            "version": { "type": "string" },
            "commit": { "type": ["string", "null"] }
          }
        },
        "source": {
          "type": "object",
          "required": ["package", "version", "sha"],
          "additionalProperties": false,
          "properties": {
            "package": { "type": "string", "description": "e.g. `@m3e/web`." },
            "version": { "type": "string", "description": "The RESOLVED installed version, never a range." },
            "sha": { "type": ["string", "null"] },
            "manifestPath": { "type": ["string", "null"] }
          }
        },
        "dts": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "dir": { "type": ["string", "null"] },
            "fileCount": { "type": "integer" },
            "aliasCount": { "type": "integer" }
          }
        },
        "configFiles": {
          "type": "array",
          "description": "Every --config-from input, in merge order, with a content hash — so a Facts consumer can tell which config shaped a fact without re-reading it.",
          "items": {
            "type": "object",
            "required": ["path", "hash"],
            "additionalProperties": false,
            "properties": {
              "path": { "type": "string" },
              "hash": { "type": "string" }
            }
          }
        }
      }
    },

    "brandFactsSlot": {
      "type": "object",
      "description": "Presence/absence encoding (spec §4.2): `admits` absent -> open (any kind), `[]` -> sealed, `[...]` -> exactly those kinds. `multi`/`required` absent -> false. All three keys are optional; `{}` is a valid, fully-open, single-occupancy, optional slot.",
      "additionalProperties": false,
      "properties": {
        "admits": { "type": "array", "items": { "type": "string" } },
        "multi": { "type": "boolean" },
        "required": { "type": "boolean" }
      }
    },

    "brandFactsAttribute": {
      "type": "object",
      "required": ["kind", "type"],
      "additionalProperties": false,
      "properties": {
        "kind": {
          "type": "string",
          "enum": ["boolean", "enum", "enumNumeric", "number", "string", "none", "other"]
        },
        "type": { "type": "string", "description": "The resolved type name, e.g. `ListItemVariant` or `boolean`." },
        "enum": {
          "type": "array",
          "items": { "type": ["string", "number"] },
          "description": "Present only when `kind` is `enum`/`enumNumeric` (or an open string union with known members). Absent means no enumerable member list."
        },
        "default": { "type": ["string", "null"] },
        "deprecated": { "type": ["boolean", "string", "null"] }
      }
    },

    "brandFactsCssProperty": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "syntax": { "type": ["string", "null"] },
        "default": { "type": ["string", "null"] }
      }
    },

    "brandFactsEvent": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "type": { "type": ["string", "null"] },
        "description": { "type": ["string", "null"] }
      }
    },

    "brandFactsElmComponentTargets": {
      "type": "object",
      "description": "Per-component Elm bindings, keyed by DESTINATION PACKAGE (spec §3.4, §4.1) — not the retired top/build/record/html construction forms. Every key is optional: a component need not have a binding in every package (e.g. `facts`/`icons` normally carry no per-component entry).",
      "additionalProperties": false,
      "properties": {
        "core": {
          "type": "object",
          "required": ["barrel"],
          "additionalProperties": false,
          "properties": { "barrel": { "type": "string" } }
        },
        "elements": {
          "type": "object",
          "required": ["module", "ctor"],
          "additionalProperties": false,
          "properties": {
            "module": { "type": "string" },
            "ctor": { "type": "string" },
            "slotSetters": { "type": "object", "additionalProperties": { "type": "string" } }
          }
        },
        "build": {
          "type": "object",
          "required": ["module", "seed", "finalizer"],
          "additionalProperties": false,
          "properties": {
            "module": { "type": "string" },
            "seed": { "type": "string" },
            "finalizer": { "type": "string" }
          }
        },
        "components": {
          "type": "object",
          "required": ["module", "member"],
          "additionalProperties": false,
          "properties": {
            "module": { "type": "string" },
            "member": { "type": "string" }
          }
        },
        "facts": { "type": "object", "additionalProperties": false, "properties": {} },
        "icons": { "type": "object", "additionalProperties": false, "properties": {} }
      }
    },

    "brandFactsComponent": {
      "type": "object",
      "title": "the canonical, language-neutral per-component core, plus its Elm target bindings",
      "required": ["declarationName", "attributes", "cssProperties", "events", "slots"],
      "additionalProperties": false,
      "properties": {
        "declarationName": { "type": "string", "description": "The class declaration name, e.g. `M3eListItemElement`." },
        "attributes": {
          "type": "object",
          "description": "Keyed by content-attribute name.",
          "additionalProperties": { "$ref": "#/definitions/brandFactsAttribute" }
        },
        "cssProperties": {
          "type": "object",
          "description": "Keyed by custom-property name including the leading `--`.",
          "additionalProperties": { "$ref": "#/definitions/brandFactsCssProperty" }
        },
        "events": {
          "type": "object",
          "additionalProperties": { "$ref": "#/definitions/brandFactsEvent" }
        },
        "slots": {
          "type": "object",
          "description": "Keyed by slot name (empty string for the default/unnamed slot). The KEY SET is CEM-closed (spec §4.3 table): a slot absent from this object does not exist on the component, full stop — that is a different absence than `admits` being absent on a slot that IS present.",
          "additionalProperties": { "$ref": "#/definitions/brandFactsSlot" }
        },
        "admittedBy": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Which parent tags this component may be placed under (spec §4.3, the P4 `parents` primitive). ABSENT means open (any parent). A separate authored fact from `admits` — not derivable from it."
        },
        "targets": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "elm": { "$ref": "#/definitions/brandFactsElmComponentTargets" }
          }
        }
      }
    },

    "brandFactsElmPackage": {
      "type": "object",
      "description": "One entry in targets.elm.packages (spec §4.4): package identity + enforcement contract, once per package (not repeated per component).",
      "required": ["package", "generator"],
      "additionalProperties": false,
      "properties": {
        "package": { "type": "string", "description": "e.g. `jackhp95/elm-m3e-core`." },
        "generator": { "type": "string", "enum": ["split", "gen-family-package", "gen-icon-module"] },
        "deps": { "type": "array", "items": { "type": "string" }, "description": "Sibling package keys this package depends on." },
        "contract": {
          "type": "object",
          "description": "Enforcement contract, e.g. `{\"composition\": \"compiler\"}` or `{\"slotSetterChild\": \"compiler\", \"rawContentChild\": \"elm-review\"}`. Keys vary per package; each value names WHO enforces validity for that concern.",
          "additionalProperties": { "type": "string", "enum": ["compiler", "elm-review", "none"] }
        }
      }
    },

    "brandFactsTargets": {
      "type": "object",
      "required": ["elm"],
      "additionalProperties": false,
      "properties": {
        "elm": {
          "type": "object",
          "required": ["packages"],
          "additionalProperties": false,
          "properties": {
            "packages": {
              "type": "object",
              "description": "Exactly the six destination-package keys (spec §3.4). Not the retired top/build/record/html construction forms.",
              "required": ["core", "elements", "build", "components", "icons", "facts"],
              "additionalProperties": false,
              "properties": {
                "core": { "$ref": "#/definitions/brandFactsElmPackage" },
                "elements": { "$ref": "#/definitions/brandFactsElmPackage" },
                "build": { "$ref": "#/definitions/brandFactsElmPackage" },
                "components": { "$ref": "#/definitions/brandFactsElmPackage" },
                "icons": { "$ref": "#/definitions/brandFactsElmPackage" },
                "facts": { "$ref": "#/definitions/brandFactsElmPackage" }
              }
            }
          }
        }
      }
    }
  }
}
```

(Note the trailing structure: the last `brandFactsTargets` block's three
closing `}` close its own object, then `definitions`, then the root schema
object — same nesting the file already ends with, just with the ten new
definitions spliced in before the final two closing braces.)

- [ ] **Step 4: Run it and confirm it passes**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected output ends with:

```
  PASS  valid brand-facts.json accepted (errors: [])
facts-bundle-schema: all checks passed
```

and all ten pre-existing `PASS` lines still print (v1 faceB/faceC checks
untouched).

Also run the JSON itself through Node's parser as a fast syntax sanity check:
`node -e "JSON.parse(require('fs').readFileSync('docs/facts-bundle/schema.json','utf8'))"`
— expect no output (no thrown `SyntaxError`).

- [ ] **Step 5: Commit**

```bash
git add docs/facts-bundle/schema.json core/elm-cem/tests/facts-bundle-schema.test.mjs
git commit -m "feat(brand-facts): add schemaVersion 2 canonical schema definitions"
```

---

### Task 2: Add a `validateBrandFacts` convenience wrapper to the validator

**Files:**
- Modify: `core/elm-cem/bin/validate-facts-bundle.js:90-102`
- Test: `core/elm-cem/tests/facts-bundle-schema.test.mjs`

**Interfaces:**
- Consumes: `validate(schema, data, definition)` from Task 1 (unchanged
  signature, `core/elm-cem/bin/validate-facts-bundle.js:96-100`); the
  `"brandFacts"` definition name from Task 1.
- Produces: `validateBrandFacts(schema, data) -> { valid: boolean, errors:
  string[] }`, exported alongside `validate` from the same module. Later
  phases (the phase-2 producer, `tools/check-drift.mjs`, `tools/gate-all.mjs`)
  are expected to call this instead of `validate(schema, data, "brandFacts")`
  once a real `brand-facts.json` exists to check — same ergonomic pattern this
  file could have offered for faceB/faceC but didn't; not fixing that here
  (out of scope, no behavior change to the v1 path).

- [ ] **Step 1: Write the failing test**

Add to `core/elm-cem/tests/facts-bundle-schema.test.mjs`, right after the
`validBrandFacts()` valid-bundle check added in Task 1:

```js
{
  // validateBrandFacts is sugar for validate(schema, data, "brandFacts") —
  // must agree with it exactly.
  const direct = validate(schema, validBrandFacts(), "brandFacts");
  const sugar = validateBrandFacts(schema, validBrandFacts());
  check(sugar.valid === direct.valid, "validateBrandFacts agrees with validate(..., \"brandFacts\") on a valid bundle");
}
```

And update the top-of-file import to pull in the new export:

```js
const { validate, validateBrandFacts } = require(path.join(repo, "bin", "validate-facts-bundle.js"));
```

(replacing the existing `const { validate } = require(...)` line at
`core/elm-cem/tests/facts-bundle-schema.test.mjs:11`.)

- [ ] **Step 2: Run it and confirm it fails**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected: `TypeError: validateBrandFacts is not a function` (destructured as
`undefined` from the require, since `validate-facts-bundle.js` does not export
it yet).

- [ ] **Step 3: Add the wrapper**

In `core/elm-cem/bin/validate-facts-bundle.js`, replace lines 90-102:

```js
/**
 * Validate a full bundle `{ schemaVersion, faceB, faceC }` against
 * `schema` (the parsed docs/facts-bundle/schema.json). Pass `definition` to
 * validate a single face's own object (e.g. "faceB") against its
 * `#/definitions/<definition>` instead of the whole bundle.
 */
function validate(schema, data, definition) {
  const rootSchema = definition ? resolveRef(`#/definitions/${definition}`, schema) : schema;
  const errors = validateAgainst(rootSchema, data, schema, "$");
  return { valid: errors.length === 0, errors };
}

module.exports = { validate };
```

with:

```js
/**
 * Validate a full bundle `{ schemaVersion, faceB, faceC }` against
 * `schema` (the parsed docs/facts-bundle/schema.json). Pass `definition` to
 * validate a single face's own object (e.g. "faceB") against its
 * `#/definitions/<definition>` instead of the whole bundle.
 */
function validate(schema, data, definition) {
  const rootSchema = definition ? resolveRef(`#/definitions/${definition}`, schema) : schema;
  const errors = validateAgainst(rootSchema, data, schema, "$");
  return { valid: errors.length === 0, errors };
}

/**
 * Validate a `brand-facts.json` document (schemaVersion 2) against
 * `#/definitions/brandFacts`. Sugar for `validate(schema, data,
 * "brandFacts")` — the spelling every schemaVersion-2 caller (the future
 * producer, check-drift, gate-all) should use instead of repeating the
 * definition-name string.
 */
function validateBrandFacts(schema, data) {
  return validate(schema, data, "brandFacts");
}

module.exports = { validate, validateBrandFacts };
```

- [ ] **Step 4: Run it and confirm it passes**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected: the new check prints
`  PASS  validateBrandFacts agrees with validate(..., "brandFacts") on a valid bundle`
and the file still ends with `facts-bundle-schema: all checks passed`.

- [ ] **Step 5: Commit**

```bash
git add core/elm-cem/bin/validate-facts-bundle.js core/elm-cem/tests/facts-bundle-schema.test.mjs
git commit -m "feat(brand-facts): add validateBrandFacts convenience wrapper"
```

---

### Task 3: Hand-authored invalid fixtures — prove the schema actually rejects malformed shapes

**Files:**
- Test: `core/elm-cem/tests/facts-bundle-schema.test.mjs`
- (No production code changes expected — see the note in Step 1 about what a
  failure here would mean.)

**Interfaces:**
- Consumes: `validBrandFacts()` (Task 1) and `validateBrandFacts` (Task 2).
- Produces: six `invalid*BrandFacts()` fixture functions, each a mutated clone
  of `validBrandFacts()` with exactly one defect, documenting by example what
  the schema is supposed to reject. These fixtures are the closest thing phase
  1 has to a spec for "what does malformed brand-facts.json look like" — a
  future phase-2 producer's own tests may want to mirror them.

- [ ] **Step 1: Write the six failing-shape tests**

Since Task 1 already authored the complete, strict `brandFacts` schema (all
objects `additionalProperties: false`, all the required-key lists filled in),
these checks are expected to go **green immediately** — there is no
"red" implementation step here the way Tasks 1-2 had one. That is fine: the
point of this task is coverage, not driving new schema code. If any check
below unexpectedly reports `FAIL` (meaning the malformed data was wrongly
**accepted**), that is a real schema gap discovered by the fixture — tighten
the corresponding `additionalProperties`/`required` in
`docs/facts-bundle/schema.json` and rerun before moving on.

Append to `core/elm-cem/tests/facts-bundle-schema.test.mjs`, after the
`validateBrandFacts` agreement check from Task 2, and before the final
`if (failureCount() > 0) { ... }` block:

```js
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
```

- [ ] **Step 2: Run and confirm all six pass**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected: all six new `PASS` lines appear, e.g.:

```
  PASS  slot with `kinds` instead of `admits` is rejected (additionalProperties: false)
  PASS  `admits` as an object instead of an array is rejected
  PASS  component missing required `declarationName` is rejected
  PASS  an Elm module name smeared onto the canonical core (outside targets.elm) is rejected
  PASS  brand-facts.json with schemaVersion 1 (not 2) is rejected
  PASS  targets.elm.packages missing a required package key (`icons`) is rejected
facts-bundle-schema: all checks passed
```

If instead any prints `FAIL`, go back to `docs/facts-bundle/schema.json` and
tighten the relevant definition (most likely a missing `additionalProperties:
false` or a missing `required` entry), then rerun this step until all six
pass.

- [ ] **Step 3: Commit**

```bash
git add core/elm-cem/tests/facts-bundle-schema.test.mjs
git commit -m "test(brand-facts): cover malformed brand-facts.json shapes"
```

---

### Task 4: Full-suite sanity check — confirm nothing else regressed

**Files:** none (verification only)

**Interfaces:**
- Consumes: everything from Tasks 1-3.
- Produces: nothing new; this task only gates the previous three.

- [ ] **Step 1: Run the single test file directly**

Run: `cd core/elm-cem && node tests/facts-bundle-schema.test.mjs`

Expected: `facts-bundle-schema: all checks passed`, exit code `0`.

- [ ] **Step 2: Run it through the package script**

Run: `pnpm --filter elm-cem run test:facts-bundle-schema`

Expected: same output as Step 1 (the script is
`"test:facts-bundle-schema": "node tests/facts-bundle-schema.test.mjs"`,
`core/elm-cem/package.json`), exit code `0`.

- [ ] **Step 3: Confirm `docs/facts-bundle/schema.json` is still valid JSON and the v1 bundle still validates**

Run:

```bash
node -e "
const { validate } = require('./core/elm-cem/bin/validate-facts-bundle.js');
const schema = JSON.parse(require('fs').readFileSync('docs/facts-bundle/schema.json', 'utf8'));
const cemFacts = JSON.parse(require('fs').readFileSync('core/cem-figma-connect/profiles/m3-kit/facts/cem-facts.json', 'utf8'));
const elmApiFacts = JSON.parse(require('fs').readFileSync('core/cem-figma-connect/profiles/m3-kit/facts/elm-api-facts.json', 'utf8'));
const b = validate(schema, cemFacts, 'faceB');
const c = validate(schema, elmApiFacts, 'faceC');
console.log('faceB valid:', b.valid, b.valid ? '' : JSON.stringify(b.errors.slice(0, 5)));
console.log('faceC valid:', c.valid, c.valid ? '' : JSON.stringify(c.errors.slice(0, 5)));
"
```

Expected: `faceB valid: true` and `faceC valid: true` — the real, committed
`schemaVersion: 1` bundle files are completely unaffected by this phase's
additive schema changes. (This directly checks the claim in the Global
Constraints section that `faceB`/`faceC` stay valid and unchanged.)

- [ ] **Step 4: Run the broader elm-cem gate, expect it unaffected**

Run: `pnpm --filter elm-cem run test`

Expected: every `test:*` script still passes (this is `run-p "test:*"` per
`core/elm-cem/package.json`); none of Tasks 1-3 touched any file outside
`docs/facts-bundle/schema.json`, `core/elm-cem/bin/validate-facts-bundle.js`,
and `core/elm-cem/tests/facts-bundle-schema.test.mjs`, so no other suite should
be affected. If some unrelated suite in this parallel run is already flaky/red
on `main`, note that in the PR rather than treating it as caused by this work.

- [ ] **Step 5: Commit (only if Step 4 required any fix; otherwise this task has nothing new to commit)**

If Step 4 surfaced a genuine regression caused by Tasks 1-3, fix it and:

```bash
git add -A
git commit -m "fix(brand-facts): address regression found in full gate run"
```

---

## Self-Review

**1. Spec coverage** — walking spec §4/§5/§7 phase 1 against the tasks above:

- §4.1 one comprehensive file, canonical core + `targets.<lang>` → `brandFacts`
  + `brandFactsComponent.targets.elm` (Task 1).
- §4.2 presence/absence encoding → `brandFactsSlot` has zero required keys;
  fixtures exercise absent-`admits` (`overline: {}`), listed-`admits`
  (`leading`), and `multi: true` (`trailing`) (Task 1); `admits` wrong-type
  fixture (Task 3).
- §4.3 slot inventory CEM-closed / `admittedBy` separate from `admits` →
  `brandFactsComponent.slots` keys are the closed inventory,
  `admittedBy` is its own optional array field, independently absent (Task 1).
- §4.4 packages first-class with contract, once at top level → `targets.elm.packages`
  requires all six keys, each with `package`/`generator`/`contract`
  (Task 1); missing-package-key fixture (Task 3).
- §4.5 provenance as one separate block → `brandFactsProvenance` (Task 1).
- §5.8 language-neutral core, Elm never smeared in → `brandFactsComponent`
  `additionalProperties: false` at the canonical level, Elm only under
  `targets.elm`; smeared-id fixture directly tests this (Task 3).
- §6 `schemaVersion` bump to 2, hand-rolled validator extended (not replaced)
  → `const: 2` (Task 1); `validateBrandFacts` added, no new keywords, no ajv
  (Task 2, and the Architecture section's keyword-coverage argument).
- §6 package keys are the six named above, not `top/build/record/html`/
  `strict/loose/general/escape` → enumerated exactly in
  `brandFactsTargets.elm.packages` (Task 1), called out in Global Constraints.
- §7 phase 1 "retire the vestigial construction-form vocabulary" → the new
  schema contains no `facets`/`surfaceKeys`/`defaultSurface`/`top`/`record`/
  `html` keys anywhere; the old `faceC` definition (which still has them) is
  left untouched for the v1 bundle only, not extended or reused (Task 1,
  Global Constraints).
- §7 phase 1 "no behavior change yet" → Task 4 Step 3 explicitly proves the
  real committed v1 bundle files still validate unchanged; no producer file is
  touched anywhere in this plan.

**2. Placeholder scan** — every step above carries either literal JSON Schema,
literal JS fixture/test code, or an exact shell command with its expected
output; no "TBD"/"add validation"/"similar to Task N" remain.

**3. Type/name consistency** — `validate`/`validateBrandFacts` signatures match
between Task 2's Step 1 (test call) and Step 3 (implementation). The
`"brandFacts"` definition name and all nine dependent definition names
(`brandFactsProvenance`, `brandFactsComponent`, `brandFactsAttribute`,
`brandFactsCssProperty`, `brandFactsEvent`, `brandFactsSlot`,
`brandFactsElmComponentTargets`, `brandFactsElmPackage`, `brandFactsTargets`)
are introduced once in Task 1 and referenced by exactly those spellings in
Tasks 2-4 and in the fixtures. The six package keys
(`core`/`elements`/`build`/`components`/`icons`/`facts`) are spelled
identically in `brandFactsElmComponentTargets`, `brandFactsTargets`, and the
`validBrandFacts()` fixture.
