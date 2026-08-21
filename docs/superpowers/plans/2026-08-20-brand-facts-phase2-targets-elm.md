# Brand Facts — Phase 2: enrich the model + unified `brand-facts.json` producer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Emit **one** comprehensive `brand-facts.json` (`schemaVersion: 2`) **alongside** the existing `cem-facts.json`/`elm-api-facts.json` bundles — its language-neutral canonical core derived from an enriched resolved Elm model (a true structural superset), and its `targets.elm` bindings **derived, not authored** (reusing the Face C identifier derivation + a `packages.json` bucket join), with a fail-loud totality backstop over every generated module — and prove the emitted file validates against the phase-1 `#/definitions/brandFacts` schema.

**Architecture:** The producer is a **new Elm emitter** (`Generate.Phantom.Emit.BrandFacts`) that runs inside the single `elm-codegen` pass, exactly mirroring how `Generate.Phantom.Emit.FactsBundle` (Face C) already emits `elm-api-facts.generated.json` today (`pipeline/elm-cem/codegen/Generate/Phantom/Emit/FactsBundle.elm:37-42`). It writes an intermediate `brand-facts.generated.json` (canonical core + `targets`, but **no** `provenance` — Elm cannot know versions/commits); the CLI wrapper (`pipeline/elm-cem/bin/elm-cem.js`) reads it back, stamps the `provenance` block, and writes the final `brand-facts.json` — the identical read-back-and-stamp pattern the CLI already runs for Face C (`elm-cem.js:715-745`). Two prerequisites feed the emitter: (a) `Comp` is enriched to retain `source : Cem.Declaration` (spec §4.6), so the raw CEM structural facts the resolved model currently drops (`cssProperties`/`cssParts`/`cssStates`/`superclass`/`deprecated`) survive into the canonical core; (b) the `packages.json` partition config is plumbed into Elm flags (the identical mechanism G1 used for `_families`/`_iconModule`), so `targets.elm.packages` and the module→package join are computed from the model + config natively — **never by re-parsing rendered `.elm` text** (the fragility class G3 eliminated). Because the derivation reads the *model*, not the committed `src/` bytes, it is unaffected by any in-flight golden-tree drift.

**Tech Stack:** Elm (`elm-codegen`; the new emitter builds `Elm.File` from `Json.Encode` — matching `FactsBundle.elm`, not the `Elm` AST DSL), Node.js CLI wrapper (`bin/elm-cem.js`), the hand-rolled draft-07 validator (`bin/validate-facts-bundle.js` — **no `ajv`**), plain-`node` `.mjs` test harnesses (`pipeline/elm-cem/tests/lib/harness.mjs`), `pnpm`.

**Spec:** `pipeline/elm-cem/specs/2026-08-19-brand-facts-design.md` (§3.1 model losses, §4.1 shape, §4.3 slots, §4.4 packages, §4.5 provenance, §4.6 producer, §4.7 `targets.elm` derivation, §5 locked decisions, §6 open questions, §7 phase 2). Companion: `core/elm-cem/research/2026-08-19-generator-consolidation.md`. Predecessor plan (landed): `docs/superpowers/plans/2026-08-19-brand-facts-phase1-schema.md`.

---

## ⚠️ Blocking design decisions (NEEDS HUMAN DECISION before Tasks 5–8)

These are **not** resolvable from the existing specs — the specs contradict the committed reality. Resolve before starting Task 5; Tasks 1–4 can proceed in parallel regardless.

### DECISION 1 — the phase-1 schema's six package keys do not match the shipped five-package reality (HARD BLOCKER)

The phase-1 schema (already landed) **hard-requires** exactly six `targets.elm.packages` keys and rejects any others:

```
docs/facts-bundle/schema.json  brandFactsTargets.elm.packages:
  "required": ["core", "elements", "build", "components", "icons", "facts"]
  "additionalProperties": false
```

and per-component `brandFactsElmComponentTargets` allows only `core`/`elements`/`build`/`components`/`facts`/`icons`, with `elements.module` illustrated as `M3e.Element.ListItem`.

The **committed, shipped** `brands/m3e/generated/package/elm-m3e/packages.json` has **five** packages with **different** names, and the generated `src/` tree uses the **pre-rename** module namespaces:

| Phase-1 schema assumes (spec §3.4 "post-rework") | Committed reality (this branch) |
|---|---|
| `core` → `jackhp95/elm-m3e-core` | `jackhp95/elm-m3e-html` (foundation; `packages.json` bucket set) |
| `elements` → `M3e.Element.*` (per-element) | `jackhp95/elm-m3e-components` owns `M3e.Component.*` (per-element) |
| `components` → `M3e.Component.*` (families) | families live as `M3e.Family.*` in a separate `elm-m3e-families/` staging tree **with no entry in `packages.json`** |
| `build` → `jackhp95/elm-m3e-build`, `M3e.Build.*` | `jackhp95/elm-m3e-builder`, `M3e.Build`/`M3e.Build.*` |
| `icons` → `jackhp95/elm-m3e-icons` | `jackhp95/elm-m3e-icons` ✅ (matches) |
| `facts` → `jackhp95/elm-m3e-facts` | `jackhp95/elm-m3e-facts` ✅ (matches) |

Grounding: `packages.json` (5 packages, names above); `FactsBundle.elm:135,138,276` derive `<Lib>.Component.<Member>` and `<Lib>.Build.<Member>` for the per-element surfaces; `tools/check-m3e-5pkg.mjs:8,14` **asserts** `p.length === 5` with names `elm-m3e-{html,components,builder,icons,facts}` and exits non-zero otherwise — i.e. the CI gate actively *enforces* the five-package reality. The spec §3.4/§6 text that calls this five-package shape "stale" is itself out of date: the spec's aspirational six-package `M3e.Element.*` rework (§8 "Coordination dependency (not owned here): the elm-m3e package rework") **has not landed**, and §8 explicitly sequences the consumer-facing pieces "after the rework's package names + repo reorg land."

A phase-2 producer run against the current tree would emit `targets.elm.packages` with the five current keys → **fails the landed schema's `required` + `additionalProperties:false`**. There is no way to satisfy both the schema and reality simultaneously. Options for the human:

- **(1a) Retarget the phase-1 schema to the shipped five-package shape** (`html`/`components`/`builder`/`icons`/`facts`, per-element = `M3e.Component.*`, families = `M3e.Family.*`). Lowest risk; produces a *true* fact of the *current* library; revisit when/if the six-package rework lands. **Recommended** — Facts should describe what exists, and the spec's own §2.1 stance is "complete a migration the codebase already started," not encode a not-yet-real target.
- **(1b) Block phase 2 on the package rework landing** (make the six-package `M3e.Element.*` shape real first, then produce against it). Correct per the schema-as-written, but couples phase 2 to a concurrent, unowned track (§8) of unknown timing.
- **(1c) Producer emits a translation layer** (derive current names, map to the six aspirational keys). Rejected on its face — it would make Facts *lie* about module names that don't exist, defeating the "single source of truth" goal; listed only for completeness.

**Every package-shape reference in Tasks 5, 6, and 8 below is written parametrically ("the package keys and module namespaces per DECISION 1") so the plan is executable under either (1a) or (1b) once chosen. Do not start Task 5 until this is answered.**

**RESOLVED 2026-08-20 (human decision):** **(1a)** — retarget the phase-1 schema to the shipped
five-package shape. Executors: update `docs/facts-bundle/schema.json`'s `brandFactsTargets`/
`brandFactsElmComponentTargets` (and its test fixtures/validator) to the five current keys
(`html`/`components`/`builder`/`icons`/`facts`, per-element = `M3e.Component.*`, families =
`M3e.Family.*`) as a small phase-1-amendment task BEFORE starting Task 5 of this plan — this is now
in scope, not a separate blocked track. Revisit if/when the six-package rework (§8) ever lands.

### DECISION 2 — `cssProperties.syntax` source (MINOR)

The schema's `brandFactsCssProperty` is `{ syntax?, default? }`. `Cem.CssProperty` (`Cem.elm:81-85`) carries `{ name, description, default }` — **no `syntax`**. Face B (`facts-bundle.js`) reportedly retains a `syntax`; confirm during Task 3 Step 1 where Face B sources it (likely a `.d.ts`/CEM `type` field). If `syntax` is not recoverable in the Elm model, emit `syntax` **absent** (schema allows it) and note the gap; do **not** invent a value. Flagged so the executor doesn't silently fabricate it.

### DECISION 3 — slot inventory source: CEM-closed vs config-sourced (already spec-answered, restated)

Spec §4.3 / §6: the JSON slot inventory should be **CEM-closed** (from `decl.slots`), not the config-only `Comp.slots` (which drops CEM-declared-but-unconfigured slots — §3.2). Phase 2 sources the slot **inventory** from `source.slots` (the enriched `Cem.Declaration`, Task 1), and the per-slot `admits`/`multi`/`required` from the resolved `Comp.slots` where present, absent otherwise. This is **not** the codegen slot-default flip (spec §6 defers that to phase 3 — do **not** touch `resolveSlot`/`Comp.slots` generation here). Restated as a constraint, not an open decision.

---

## Global Constraints

Every task implicitly inherits these (from the spec + phase-1 plan):

- **Additive only — no removal, no behavior change to existing bundles.** `brand-facts.json` is emitted *alongside* `cem-facts.json` (Face B) and `elm-api-facts.json` (Face C); those keep their `schemaVersion: 1` shapes and byte output unchanged (spec §7 phase 2: "Emit one `brand-facts.json` **alongside** the existing bundles"; retiring Face B/C is phase 5). Every task ends with the existing `elm-api-facts.json`/`cem-facts.json` still byte-identical.
- **Presence/absence is the whole encoding** (spec §4.2, §5.3): present = authored, absent = default. `admits` absent → open (any kind); `[]` → sealed; `[…]` → listed. `multi`/`required` absent → `false`. `admittedBy` absent → open (any parent). The encoder must **omit** absent keys, never emit `null`/`[]` as a stand-in — and a spot-check must exercise all three `admits` states.
- **Facts is language-neutral** (spec §5.8): the canonical per-component core (`declarationName`, `attributes`, `cssProperties`, `events`, `slots`, `admittedBy`) carries **no** Elm identifier. Every Elm name (module/ctor/setter) lives under `targets.elm`, never smeared into a canonical field.
- **Bindings are derived, not authored** (spec §5.10, §4.7): reuse the resolved model's naming (`componentModuleName`, `SharedAttrs.elm:62`) + Face C's identifier derivation (`FactsBundle.elm:262-380`); join module→package via `packages.json` buckets **in file order, first `prefix`/`exact` match wins** (replicate `split.js:103-124`); **fail loud** on any generated module no bucket covers (mirror `split.js` totality, §4.7 step 4). Never re-parse rendered `.elm` text.
- **`schemaVersion` is `2`**, literal-checked. The existing Face C emitter stamps `1` (`FactsBundle.elm:90`); the new emitter stamps `2` and must not perturb Face C.
- **No `ajv`.** Validate with the existing `validateBrandFacts` wrapper (`validate-facts-bundle.js:103-113`, landed in phase 1).
- **Acceptance = schema-validity + targeted spot-checks, not a byte-golden.** No committed `brand-facts.json` exists yet, so there is nothing to byte-compare against. Each task's gate is (a) `validateBrandFacts` passes and (b) named, known-true facts appear at the exact JSON paths asserted. This also side-steps the in-flight `src/` golden-tree drift (a sibling task is refreshing it) — the derivation reads the model, not `src/` bytes.
- **The elm toolchain may be absent in this worktree.** Steps marked "Run (elm):" require `pipeline/elm-cem/node_modules/.bin/elm-codegen` + `elm`; run `pnpm install` at the repo root first (`postinstall` → `tools/install-toolchains.mjs`). If install is impossible, still make every edit; do **not** claim an elm-run step passed without observing its output.
- **Paths use the current reorg'd layout** (`pipeline/elm-cem/…`, `brands/m3e/generated/package/elm-m3e/…`) — spec/§ and the phase-1 plan cite the pre-reorg `core/`/`brands/m3e/outputs/`; those are stale, translate per this workspace.

---

### Task 1: Plumb `packages.json` into Elm flags

**Files:**
- Modify: `pipeline/elm-cem/bin/elm-cem.js` (add a `--packages-from` inject step near `injectIconCatalog`, ~`elm-cem.js:152-156` pipeline)
- Modify: `pipeline/elm-cem/codegen/Generate/Types.elm` (add `PackagesConfig`/`ElmPackage`/`Bucket` type aliases; extend `ConfigResult`)
- Modify: `pipeline/elm-cem/codegen/Generate/Config.elm` (decode `_packages` into `ConfigResult`)
- Test: `pipeline/elm-cem/tests/config-packages-flags.test.mjs` (new)

**Interfaces:**
- Consumes: the committed `packages.json` (`brands/m3e/generated/package/elm-m3e/packages.json`) — top-level `{ family, devRepo, packages: [{ name, summary, version, deps, buckets: [{prefix?|exact?}], exposeInternal? }] }`.
- Produces: `Generate.Config` decodes a new optional `packages : Maybe PackagesConfig` on `ConfigResult`, where
  ```elm
  type alias PackagesConfig = { family : String, packages : List ElmPackage }
  type alias ElmPackage = { name : String, generator : String, deps : List String, buckets : List Bucket }
  type alias Bucket = { prefix : Maybe String, exact : Maybe String }
  ```
  Consumed by `Generate.Phantom.Emit.BrandFacts` (Task 5/6). `generator` is **not** in `packages.json` today — derive it in the JS inject step from the package name per DECISION 1 (e.g. `icons`→`gen-icon-module`, `components`/family owner→`gen-family-package`, rest→`split`), OR add an explicit `"generator"` field to `packages.json`; **decide in Step 1** and document.

- [ ] **Step 1: Confirm the `packages.json` shape + decide the `generator` source**

Run: `cat brands/m3e/generated/package/elm-m3e/packages.json`
Expected: the five-package array documented in DECISION 1. Confirm no `"generator"` field exists per package. Decide: add a `"generator"` string to each package entry in `packages.json` (explicit, self-documenting — **recommended**) or derive it in JS. Record the choice in a comment at the top of the new inject function. The rest of this task assumes the field is present after this step (add it to `packages.json` if you chose explicit).

- [ ] **Step 2: Write the failing flags-merge test**

Create `pipeline/elm-cem/tests/config-packages-flags.test.mjs`, mirroring `config-icon-families-flags.test.mjs`'s structure (spawn `elm-cem.js` with a throwaway empty-manifest brand + a `--packages-from`, capture the merged `elm-cem-cfg-*` temp file from `os.tmpdir()`, assert `_config._packages` survives):

```js
#!/usr/bin/env node
// Proves --packages-from reaches Elm's decoded _config (Brand Facts phase 2).
// Mirrors config-icon-families-flags.test.mjs's temp-file capture technique.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo, makeCheck } from "./lib/harness.mjs";

const cli = path.join(repo, "bin", "elm-cem.js");
const { check, finish } = makeCheck("config-packages-flags");

const brand = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-packages-flags-"));
fs.writeFileSync(path.join(brand, "custom-elements.json"), JSON.stringify({ schemaVersion: "1.0.0", modules: [] }));
fs.writeFileSync(path.join(brand, "packages.json"), JSON.stringify({
  family: "wc", packages: [{ name: "wc-html", generator: "split", deps: [], buckets: [{ exact: "Wc.Html" }] }],
}));

const before = fs.readdirSync(os.tmpdir()).filter((f) => f.startsWith("elm-cem-cfg"));
const gen = spawnSync("node", [cli,
  `--flags-from=${path.join(brand, "custom-elements.json")}`,
  `--packages-from=${path.join(brand, "packages.json")}`,
  `--output=${path.join(brand, "src")}`,
], { cwd: brand, encoding: "utf8" });
const after = fs.readdirSync(os.tmpdir()).filter((f) => f.startsWith("elm-cem-cfg"));
const newTemp = after.find((f) => !before.includes(f));
check(Boolean(newTemp), "elm-cem.js wrote a merged flags temp file", gen.stdout + gen.stderr);
if (newTemp) {
  const merged = JSON.parse(fs.readFileSync(path.join(os.tmpdir(), newTemp), "utf8"));
  check(merged._config && Array.isArray(merged._config._packages?.packages) && merged._config._packages.packages[0].name === "wc-html",
    "_packages survives the flags merge", JSON.stringify(merged._config));
  fs.rmSync(path.join(os.tmpdir(), newTemp), { force: true });
}
finish("config-packages-flags: all checks passed");
```

- [ ] **Step 3: Run — confirm it fails**

Run: `node pipeline/elm-cem/tests/config-packages-flags.test.mjs`
Expected: FAIL — `merged._config._packages` is `undefined` (no `--packages-from` handling exists yet).

- [ ] **Step 4: Add the `--packages-from` inject step in `elm-cem.js`**

Add an `injectPackages(argv)` function near `injectIconCatalog` (read `packages.json` from the `--packages-from` path, attach it as `cem._config._packages` in a fresh flags temp via `writeTemp`, exactly as `injectIconCatalog` does for `_iconModule.names`). Insert the call into the pipeline chain (`elm-cem.js:152-156`), after `injectConfig`. If `--packages-from` is absent, pass `argv` through unchanged (optional flag).

- [ ] **Step 5: Decode `_packages` in `Generate/Config.elm` + `Generate/Types.elm`**

Add the `PackagesConfig`/`ElmPackage`/`Bucket` aliases (Interfaces block) to `Generate/Types.elm`; extend `ConfigResult` with `packages : Maybe PackagesConfig`. In `Generate/Config.elm`'s `decodeConfigResult`, decode `_packages` (a `bucketDecoder` with two `Json.Decode.maybe` fields; `deps` as `Json.Decode.list Json.Decode.string`), fold into the final `Result.mapN`, and default `Nothing` in the empty-config branch. (Same pattern G1 used for `_families`.)

- [ ] **Step 6: Run — confirm it passes; confirm existing config-merge suites still green**

Run: `node pipeline/elm-cem/tests/config-packages-flags.test.mjs`
Expected: PASS.
Run: `cd pipeline/elm-cem && node tests/config-icon-families-flags.test.mjs && node tests/gates.test.mjs`
Expected: PASS (additive-only change).
Run (elm): `cd pipeline/elm-cem && node_modules/.bin/elm-codegen run codegen/Generate.elm --flags-from=<any fixture manifest> --output=/tmp/pkgcheck`
Expected: compiles clean (decoder added, unused so far).

- [ ] **Step 7: Commit**

```bash
git add pipeline/elm-cem/bin/elm-cem.js pipeline/elm-cem/codegen/Generate/Types.elm pipeline/elm-cem/codegen/Generate/Config.elm pipeline/elm-cem/tests/config-packages-flags.test.mjs brands/m3e/generated/package/elm-m3e/packages.json
git commit -m "feat(elm-cem): plumb packages.json into Elm flags (brand-facts phase 2)"
```

---

### Task 2: Enrich `Comp` with `source : Cem.Declaration` (model superset, spec §4.6)

**Files:**
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Model.elm:324-363` (`Comp` record + the `Comp` constructor in `resolve`)
- Test: `pipeline/elm-cem/tests/model-source-retained.test.mjs` (new) — an end-to-end generation check, since the field is only observable once an encoder reads it

**Interfaces:**
- Consumes: the raw `Cem.Declaration` already in scope during `Model.resolve` (`Model.elm:1494` `resolve : String -> String -> D.Value -> List Cem.Declaration -> Result (List String) Brand`; the per-comp declaration is `ctx.ctorIndex`/`comps0`, `Model.elm:1525-1526`).
- Produces: `Comp.source : Cem.Declaration` — a new field carrying the reconciled source declaration verbatim (`cssProperties`/`cssParts`/`cssStates`/`slots`/`members`/`events`/`attributes`/`superclass`/`status`/`since`/`dependencies`, per `Cem.elm:57-76`). Read by `Generate.Phantom.Emit.BrandFacts` (Task 3). **No other emitter reads it** — Face A/B/C output is unchanged.

- [ ] **Step 1: Locate where each `Comp` is built in `resolve` and confirm the source decl is in scope**

Run: `grep -n "resolvedCtor =\|{ name =\|Comp\b\|controlsElement\|Cem.Declaration" pipeline/elm-cem/codegen/Generate/Phantom/Model.elm | head -40`
Confirm the `Comp` record literal(s) are constructed from a `Cem.Declaration` value that is in scope at that point (it must be — `admittedBy`/`slots`/`events` are already derived from it). Name that binding for Step 3.

- [ ] **Step 2: Write the failing observation test**

Create `pipeline/elm-cem/tests/model-source-retained.test.mjs`. It generates against `brands/m3e`'s real config with `--facts-bundle` pointed at a temp dir, then (once Task 3 exists) asserts a known component's `cssProperties` are non-empty in `brand-facts.json`. **Until Task 3 exists there is no observable output**, so for THIS task assert the weaker, immediately-checkable property: generation still exits 0 and Face C output is byte-unchanged (proving the enrichment is a no-op for existing outputs). Use `pipeline/elm-cem/tests/lib/golden.mjs`'s `runGoldenGenerate` if reachable, else invoke `elm-cem.js` with the four real `--config-from`/`--flags-from` args + `--facts-bundle` (cwd `brands/m3e/generated/package/elm-m3e`), and `byteEqual` the fresh `elm-api-facts.json` against the committed one.

```js
// Enriching Comp with `source` must NOT perturb Face C (elm-api-facts.json).
// The positive assertion (cssProperties survive into brand-facts.json) is
// added in Task 3 Step 5, once the BrandFacts encoder can read `source`.
```

- [ ] **Step 3: Add `source : Cem.Declaration` to `Comp` and populate it**

Add `, source : Cem.Declaration` to the `Comp` alias (`Model.elm:324-363`). In every `Comp` record literal inside `resolve`, set `source = <the in-scope declaration from Step 1>`. Add `import Cem` if not already present (it is — `Cem.Declaration` is used at `Model.elm:919`).

- [ ] **Step 4: Run — confirm generation still exits 0 and Face C is byte-unchanged**

Run (elm): the generation from Step 2.
Expected: exit 0; `byteEqual(committed elm-api-facts.json, fresh)` → `{ ok: true }`. (`Comp.source` is populated but read by nothing yet.)
Run (elm): `cd pipeline/elm-cem && pnpm run test:gates`
Expected: PASS unchanged.

- [ ] **Step 5: Commit**

```bash
git add pipeline/elm-cem/codegen/Generate/Phantom/Model.elm pipeline/elm-cem/tests/model-source-retained.test.mjs
git commit -m "feat(elm-cem): retain source Cem.Declaration on Comp (brand-facts superset)"
```

---

### Task 3: New emitter `Generate.Phantom.Emit.BrandFacts` — canonical core only

**Files:**
- Create: `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm`
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm:70-71` (`files` — append the intermediate file when a `brand-facts` flag is set; see Step 3)
- Test: `pipeline/elm-cem/tests/brand-facts-canonical.test.mjs` (new)

**Interfaces:**
- Consumes: `Brand`/`Comp` (`Model.elm:324,392`), `Comp.source` (Task 2), `Comp.admittedBy` (`Model.elm:334`, already present), `Comp.slots : List ResolvedSlot`. Reuses helpers from `FactsBundle.elm` where they are language-neutral (`attrTypeKind` at `:198`, `slotKindsOf` derivation at `:314-336` — but re-expressed as `admits`, see Step 2).
- Produces: `Generate.Phantom.Emit.BrandFacts.file : Brand -> Elm.File` emitting `brand-facts.generated.json` with keys `{ schemaVersion: 2, lib, components }` — **no `provenance`** (CLI stamps it, Task 7) and **no `targets`** yet (Tasks 4–6 add them). Each `components[tag]` carries the canonical core only: `declarationName`, `attributes`, `cssProperties`, `events`, `slots`, `admittedBy?`.

- [ ] **Step 1: Confirm the canonical-core field sources (resolve DECISION 2 here)**

Map each schema field to a model source, verifying against `Cem.elm:57-101` and `Model.elm:324-363`:
- `declarationName` ← `comp.source.name` (the class name, e.g. `M3eListItemElement`).
- `attributes[name]` ← `comp.attrs` → `{ kind, type, enum?, default?, deprecated? }`; `kind` via a mapping like `attrTypeKind` (`FactsBundle.elm:198-224`) but to the schema's `kind` enum (`boolean`/`enum`/`enumNumeric`/`number`/`string`/`none`/`other`), `enum` from `comp.enums`.
- `cssProperties[name]` ← `comp.source.cssProperties` → `{ syntax?, default? }`. **DECISION 2:** `Cem.CssProperty` has `{name, description, default}` but no `syntax` — run `grep -n "syntax" pipeline/elm-cem/bin/facts-bundle.js` to see if Face B recovers it; if not, omit `syntax` and note it.
- `events[name]` ← `comp.source.events` (or `comp.events`) → `{ type?, description? }`.
- `slots` — inventory from `comp.source.slots` (CEM-closed, DECISION 3); per-slot `admits`/`multi`/`required` from `comp.slots` (`ResolvedSlot`) where present. Emit `admits` only when a kind constraint is authored (`SetContent`/`Fields` → list; `Permissive` → omit `admits` = open); emit `multi`/`required` only when `true`.
- `admittedBy` ← `comp.admittedBy` (`Maybe (List String)`); emit only when `Just`.

- [ ] **Step 2: Write `BrandFacts.elm` (canonical core), presence/absence-correct**

Build with `Json.Encode`. Provide an `objectOmittingAbsent : List (String, Maybe Encode.Value) -> Encode.Value` helper so absent keys are **dropped**, never `null`/`[]` (Global Constraint). Mirror `factsBundleFile` (`FactsBundle.elm:37-42`) for the `Elm.File` wrapper; set `path = "brand-facts.generated.json"`.

- [ ] **Step 3: Wire into `Generate.Phantom.Emit.files`, gated on a flag**

`files` currently returns `Ok (allFiles ++ iconFiles ++ familyFiles)` (`Emit.elm:70-71`, after G3). Append `BrandFacts.file brand` to that list **only when brand-facts emission is requested** — thread a `Bool` (or reuse the facts-bundle flag path). Simplest: always emit the intermediate `brand-facts.generated.json` (harmless extra file, like `elm-api-facts.generated.json` already is), and let the CLI decide whether to promote it. Confirm the extra file does not break `split.js`/drift (it lives at the output root, is consumed+removed by the CLI, exactly like `elm-api-facts.generated.json`).

- [ ] **Step 4: Write the failing canonical-core test**

Create `pipeline/elm-cem/tests/brand-facts-canonical.test.mjs`: generate against `brands/m3e` real config into a temp dir, read the emitted `brand-facts.generated.json`, and assert with `makeCheck`:
- `data.schemaVersion === 2`, `data.lib === "M3e"`.
- `data.components["m3e-list-item"].declarationName` is a non-empty string.
- The three `admits` states are all exercised somewhere: at least one slot with `admits` an array, at least one present slot with **no** `admits` key (open), and `multi`/`required` appear only as `true`.
- **No** Elm identifier leaks into the canonical core: assert `!("module" in comp)` and `!("targets" in comp)` for now (targets added in Task 4).
- Validate the canonical-only object against a **relaxed** check: since `targets`/`provenance` are required by the full `brandFacts` schema, do **not** run `validateBrandFacts` yet (it will fail on missing `targets`/`provenance`) — assert structural properties directly. Full-schema validation is Task 8.

- [ ] **Step 5: Run — confirm pass; add the Task 2 positive assertion**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-canonical.test.mjs`
Expected: PASS. Also extend `model-source-retained.test.mjs` (Task 2) with the now-observable assertion: `data.components[<a component with CSS custom props, e.g. m3e-list-item>].cssProperties` is a non-empty object — proving `Comp.source` survived.
Run (elm): `cd pipeline/elm-cem && pnpm run test:gates`
Expected: PASS; Face B/C byte-unchanged.

- [ ] **Step 6: Commit**

```bash
git add pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm pipeline/elm-cem/tests/brand-facts-canonical.test.mjs pipeline/elm-cem/tests/model-source-retained.test.mjs
git commit -m "feat(elm-cem): emit brand-facts.json canonical core (phase 2)"
```

---

### Task 4: Add per-component `targets.elm` bindings to the encoder

**Files:**
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm`
- Test: `pipeline/elm-cem/tests/brand-facts-targets-component.test.mjs` (new)

**Interfaces:**
- Consumes: the per-component derivation already in `FactsBundle.elm:262-380` (`encodeComponent`): `moduleName` (`FactsBundle.elm:275-276` → `<Lib>.Component.<Member>` under the current shape), the build surface (`FactsBundle.elm:137-138` → `<Lib>.Build.<Member>`, seed `build`, finalizer `toElement`), `slotSetterMap` (`:371`), family/home membership (`group`, `:338-347`), `resolvedCtor` (`:351`). Extract the language-neutral naming into a shared helper if it avoids duplication, else re-derive identically.
- Produces: `components[tag].targets.elm` per DECISION 1's package keys. Under **(1a)** (current shape): `components` (per-element surface) `{ module: "M3e.Component.<Member>", ctor, slotSetters }`, `build` `{ module: "M3e.Build.<Member>", seed: "build", finalizer: "toElement" }`, and family membership under the families binding (`M3e.Family.<Family>`, `member: <ctor>`). The `core`/barrel binding `{ barrel: <ctor> }` if the barrel re-exports it. **Emit only the package keys that DECISION 1 fixes**, and only bindings that actually exist for that component (absent = no binding, per §4.4).

- [ ] **Step 1: Confirm the binding module names against the model (not `src/` bytes)**

Cross-check `FactsBundle.elm`'s derived names against the committed tree once (`ls brands/m3e/generated/package/elm-m3e/src/M3e/Component/ | head`, `ls .../M3e/Build/ | head`, `ls .../elm-m3e-families/src/M3e/Family/ | head`) purely to confirm the *shape* of the names the derivation produces — but the encoder must compute them from `Brand`/`Comp` + `componentModuleName` (`SharedAttrs.elm:62`), never read the tree. Map each binding to its DECISION-1 package key.

- [ ] **Step 2: Add a `targetsElm : Brand -> Comp -> Encode.Value` helper to `BrandFacts.elm`**

Port the relevant slices of `FactsBundle.elm`'s `encodeComponent` (module/ctor/slotSetterMap/build/family) into presence/absence-correct `targets.elm` bindings keyed per DECISION 1. Reuse `memberRef`/`homeOf` from `FactsBundle.elm` (import or lift to a shared module). Attach `targets.elm` to each component object from Task 3.

- [ ] **Step 3: Write the failing per-component-targets test**

Create `pipeline/elm-cem/tests/brand-facts-targets-component.test.mjs`: generate, then assert for `m3e-list-item` (adjust the exact expected strings to DECISION 1's shape):
- `comp.targets.elm.components.module === "M3e.Component.ListItem"` (under 1a) and `.ctor` is its resolved ctor.
- `comp.targets.elm.build.module === "M3e.Build.ListItem"`, `.seed === "build"`, `.finalizer === "toElement"`.
- `comp.targets.elm.components.slotSetters` maps each named slot to its setter (matches `FactsBundle.elm`'s `slotSetterMap`).
- Canonical core still carries **no** Elm identifier (re-assert `!("module" in comp)` at the top level; Elm names appear only under `comp.targets.elm`).

- [ ] **Step 4: Run — confirm pass; Face C unchanged**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-targets-component.test.mjs`
Expected: PASS.
Run (elm): `cd pipeline/elm-cem && pnpm run test:gates`
Expected: PASS; Face B/C byte-unchanged.

- [ ] **Step 5: Commit**

```bash
git add pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm pipeline/elm-cem/tests/brand-facts-targets-component.test.mjs
git commit -m "feat(elm-cem): derive per-component targets.elm bindings (phase 2)"
```

---

### Task 5: Add top-level `targets.elm.packages` derived from `packages.json` flags

> **Gated on DECISION 1.** Do not start until the package shape is chosen.

**Files:**
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm` (read `PackagesConfig` from Task 1)
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm` + `Generate.elm` (thread `Maybe PackagesConfig` into `BrandFacts.file`, mirroring how `iconModule`/`families` are threaded through `files`, `Emit.elm:70-71`)
- Test: `pipeline/elm-cem/tests/brand-facts-targets-packages.test.mjs` (new)

**Interfaces:**
- Consumes: `ConfigResult.packages : Maybe PackagesConfig` (Task 1). `BrandFacts.file`'s signature grows a `Maybe PackagesConfig` argument; `Generate.elm` passes `legacyConfig.packages` through, and `Emit.files` forwards it (same plumbing pattern as G1's `iconModule`/`families`).
- Produces: top-level `targets.elm.packages` keyed per DECISION 1, each `{ package, generator, deps, contract }`. `package`/`generator`/`deps` come straight from `PackagesConfig`; `contract` is the enforcement map (spec §4.4 — `compiler`/`elm-review`/`none`). **`contract` is not in `packages.json`** — source it per DECISION 1 (add a `"contract"` object to each `packages.json` entry, **recommended**, or a fixed table in the emitter). Decide in Step 1.

- [ ] **Step 1: Decide the `contract` source**

The spec §4.4 gives illustrative contracts (`core`→`{composition:none}`, `elements`→`{slotSetterChild:compiler, rawContentChild:elm-review}`, `build`/`components`→`{composition:compiler}`, `icons`/`facts`→`{}`). These are per-package enforcement facts, not derivable from the module list. **Recommend** adding a `"contract"` object per package to `packages.json` (self-documenting, versioned input) and decoding it in Task 1's decoder (extend `ElmPackage` with `contract : List (String, String)`). If instead a fixed table lives in the emitter, document why. Record the choice.

- [ ] **Step 2: Thread `Maybe PackagesConfig` to `BrandFacts.file` and emit `targets.elm.packages`**

Update the signature chain (`Generate.elm` → `Emit.files` → `BrandFacts.file`). Emit `targets.elm.packages` as an object keyed by DECISION 1's package keys, each value `{ package, generator, deps, contract }`. If `packages` is `Nothing`, omit `targets.elm.packages` (a brand generated without `--packages-from`) — but the full schema requires it, so Task 8's real run must pass `--packages-from`.

- [ ] **Step 3: Write the failing packages-targets test**

Create `pipeline/elm-cem/tests/brand-facts-targets-packages.test.mjs`: generate **with `--packages-from`**, then assert (per DECISION 1's keys) that every required package key is present under `data.targets.elm.packages`, each with a non-empty `package` string, a `generator` in the allowed set, an array `deps`, and a `contract` object. E.g. under (1a): `packages.html.package === "jackhp95/elm-m3e-html"`, `packages.builder.generator === "split"`, etc.

- [ ] **Step 4: Run — confirm pass**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-targets-packages.test.mjs`
Expected: PASS.
Run (elm): `cd pipeline/elm-cem && pnpm run test:gates` — Face B/C byte-unchanged.

- [ ] **Step 5: Commit**

```bash
git add pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm pipeline/elm-cem/codegen/Generate/Phantom/Emit.elm pipeline/elm-cem/codegen/Generate.elm pipeline/elm-cem/tests/brand-facts-targets-packages.test.mjs brands/m3e/generated/package/elm-m3e/packages.json
git commit -m "feat(elm-cem): derive top-level targets.elm.packages + contracts (phase 2)"
```

---

### Task 6: Module→package join + fail-loud totality backstop (spec §4.7 steps 3–4)

> **Gated on DECISION 1.**

**Files:**
- Modify: `pipeline/elm-cem/codegen/Generate/Phantom/Emit/BrandFacts.elm` (or a new `Generate/Phantom/Partition.elm` if the bucket logic is substantial)
- Test: `pipeline/elm-cem/tests/brand-facts-totality.test.mjs` (new)

**Interfaces:**
- Consumes: `PackagesConfig.packages[].buckets` (Task 1), and the **full list of generated module names** — derived from the model (every `<Lib>.Component.<Member>`, `<Lib>.Build.<Member>`, family module, plus the fixed foundation modules the split emits), **not** by reading `src/`. Cross-check the fixed-module list against `Emit.files`'s own output module names.
- Produces: a pure `assignModuleToPackage : List ElmPackage -> String -> Maybe String` replicating `split.js:103-124` (iterate packages in file order, then that package's buckets in order; first `prefix` (`String.startsWith`) or `exact` (`==`) hit wins), and a totality check that returns `Err [uncoveredModules]` when any generated module maps to no package (mirrors `split.js:125-128`). `Emit.files` surfaces the `Err` through its existing `Result (List String) (List Elm.File)` error path (`Emit.elm:70`, same as `runGuard`).

- [ ] **Step 1: Read `split.js`'s partition + totality exactly**

Run: `sed -n '100,140p' pipeline/elm-cem/bin/split.js`
Confirm the first-match-wins order (`split.js:113-124`) and the totality failure (`split.js:125-128`). Port the semantics **exactly** — declared bucket order is the contract.

- [ ] **Step 2: Implement `assignModuleToPackage` + `checkTotality`**

Pure Elm functions. `checkTotality : PackagesConfig -> List String -> Result (List String) ()` returns `Err` listing every module no bucket claims. Wire the `Result` into `BrandFacts.file`/`Emit.files` so a coverage gap is a **hard generation error**, never a silent omission (Global Constraint / §4.7 step 4).

- [ ] **Step 3: Write the totality test (positive + fail-loud)**

Create `pipeline/elm-cem/tests/brand-facts-totality.test.mjs`:
- **Positive:** generation against `brands/m3e` real config + real `packages.json` exits 0 (every generated module is claimed).
- **Fail-loud:** run generation with a mutated `packages.json` (a throwaway copy with one bucket removed, e.g. drop the `M3e.Build` bucket) and assert generation exits **non-zero** with an error naming the now-uncovered module(s). Use a temp brand dir + `--packages-from=<mutated copy>` so the committed file is untouched.

- [ ] **Step 4: Run — confirm both cases**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-totality.test.mjs`
Expected: PASS (positive exits 0; fail-loud exits non-zero with the uncovered-module message).

- [ ] **Step 5: Commit**

```bash
git add pipeline/elm-cem/codegen/Generate/Phantom/ pipeline/elm-cem/tests/brand-facts-totality.test.mjs
git commit -m "feat(elm-cem): fail-loud module→package totality backstop (phase 2, §4.7)"
```

---

### Task 7: CLI wiring — write `brand-facts.json`, stamp provenance

**Files:**
- Modify: `pipeline/elm-cem/bin/elm-cem.js:700-748` (the facts-bundle writer block)
- Test: `pipeline/elm-cem/tests/brand-facts-cli.test.mjs` (new)

**Interfaces:**
- Consumes: the intermediate `brand-facts.generated.json` emitted at the output root by Task 3–6, and the same provenance inputs the CLI already gathers for Face B/C (`faceBProvenance` at `elm-cem.js:~700`, `generatorVersion`/`generatorCommit`, `tryGitHead`, the `configFiles` scan at `elm-cem.js:725-730`).
- Produces: a final `brand-facts.json` written next to `cem-facts.json`/`elm-api-facts.json` under the `--facts-bundle=<dir>`, with a `provenance` block matching the schema's `brandFactsProvenance` shape (`{ generator: {name, version, commit}, source: {package, version, sha, manifestPath}, dts: {dir, fileCount, aliasCount}, configFiles: [{path, hash}] }`) — read the phase-1 fixture `validBrandFacts()` (`pipeline/elm-cem/tests/facts-bundle-schema.test.mjs`) for the exact expected shape. **Note the shape differs from Face C's `provenance`** (`elm-cem.js:732-741` uses `producer`/`brand`/`source`); do **not** reuse Face C's shape.

- [ ] **Step 1: Read the existing Face C read-back+stamp block**

Run: `sed -n '714,748p' pipeline/elm-cem/bin/elm-cem.js`
Confirm the pattern: read `elm-api-facts.generated.json`, `fs.rmSync` it, stamp `provenance`, write final. Task 7 adds the parallel block for `brand-facts.generated.json` → `brand-facts.json`.

- [ ] **Step 2: Add the brand-facts read-back + provenance stamp**

After the Face C block, add: read `brand-facts.generated.json` from the output root (if absent, warn + skip, like Face C); build the `brandFactsProvenance`-shaped block (compute each `configFiles[].hash` with `sha256` of the file contents — spec §4.5 wants a content hash; use `crypto.createHash("sha256")`); assign `data.provenance = <that block>`; write `brand-facts.json` + `\n`; `fs.rmSync` the intermediate. Log a line mirroring the Face C log.

- [ ] **Step 3: Write the failing CLI test**

Create `pipeline/elm-cem/tests/brand-facts-cli.test.mjs`: generate against `brands/m3e` real config with `--facts-bundle=<tmp>` **and** `--packages-from=<real packages.json>`; assert:
- `brand-facts.json` exists in the facts-bundle dir; `brand-facts.generated.json` does **not** (cleaned up).
- `cem-facts.json` and `elm-api-facts.json` still exist and are byte-identical to a generation run **without** the brand-facts changes (or to the committed copies) — proving additivity.
- `data.provenance.generator.name === "elm-cem"`, `data.provenance.source.package === "@m3e/web"`, `data.provenance.configFiles` is a non-empty array of `{path, hash}`.

- [ ] **Step 4: Run — confirm pass**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-cli.test.mjs`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add pipeline/elm-cem/bin/elm-cem.js pipeline/elm-cem/tests/brand-facts-cli.test.mjs
git commit -m "feat(elm-cem): write brand-facts.json + stamp provenance (phase 2)"
```

---

### Task 8: Full-schema validation gate + suite integration

> **Gated on DECISION 1** (the emitted package keys must match the schema, or the schema must have been retargeted per 1a).

**Files:**
- Test: `pipeline/elm-cem/tests/brand-facts-schema-valid.test.mjs` (new)
- Modify (only if DECISION 1 = 1a): `docs/facts-bundle/schema.json` (retarget the six package keys to the shipped five) + `pipeline/elm-cem/tests/facts-bundle-schema.test.mjs` (update `validBrandFacts()` fixture to match)
- Verify: `pipeline/elm-cem/package.json` (`test:*` scripts pick up the new test files)

**Interfaces:**
- Consumes: the emitted `brand-facts.json` (Task 7), `validateBrandFacts` (`validate-facts-bundle.js:103`), the parsed `docs/facts-bundle/schema.json`.
- Produces: an end-to-end proof that the **real** emitted file validates against the real schema, plus green integration in the elm-cem suite + drift gate.

- [ ] **Step 1: If DECISION 1 = 1a, retarget the schema first**

Edit `docs/facts-bundle/schema.json`'s `brandFactsTargets`/`brandFactsElmComponentTargets` to the shipped package keys/module namespaces, and update `validBrandFacts()` (`facts-bundle-schema.test.mjs`) + its `invalidMissingPackageKeyBrandFacts()` fixture accordingly. Run `node pipeline/elm-cem/tests/facts-bundle-schema.test.mjs` — expect all phase-1 checks still green against the retargeted shape. (If DECISION 1 = 1b, skip — the schema already matches the target shape and phase 2 blocks until that shape ships.)

- [ ] **Step 2: Write the end-to-end schema-validity test**

Create `pipeline/elm-cem/tests/brand-facts-schema-valid.test.mjs`: generate against `brands/m3e` real config with `--facts-bundle` + `--packages-from`, load the emitted `brand-facts.json` and the schema, run `validateBrandFacts(schema, data)`, and assert `result.valid === true` (printing `result.errors` on failure). This is the capstone gate — it proves canonical core + `targets` + `provenance` all satisfy the landed (or retargeted) schema simultaneously.

- [ ] **Step 3: Run — confirm pass**

Run (elm): `node pipeline/elm-cem/tests/brand-facts-schema-valid.test.mjs`
Expected: `PASS  emitted brand-facts.json validates against #/definitions/brandFacts (errors: [])`.

- [ ] **Step 4: Run the full elm-cem suite + drift gate**

Run (elm): `cd pipeline/elm-cem && pnpm run test`
Expected: every `test:*` passes, including all new `brand-facts-*` tests (confirm `run-p "test:*"` discovers them — new `tests/*.test.mjs` are picked up automatically if the script globs; if not, add explicit `test:brand-facts-*` scripts to `package.json`).
Run: `node tools/check-drift.mjs` (repo root)
Expected: `CHECK-DRIFT GREEN` (or usual snapshot SKIPs) — no NEW failure; the existing Face B/C drift checks (`check-drift.mjs:94-95`) are untouched because their bundles are byte-unchanged.

- [ ] **Step 5: Decide whether to commit a golden `brand-facts.json` + drift check (optional, note only)**

Emitting `brand-facts.json` as a *committed* artifact + adding it to `tools/check-drift.mjs`'s consumer list would give byte-level regression protection — but the spec sequences consumer wiring into **phase 4**, and committing a golden now re-introduces the untrustworthy-golden-tree risk this plan otherwise avoids. **Recommend deferring** the committed-golden + drift-consumer wiring to phase 4; phase 2's gate stays schema-validity + spot-checks. If the human wants byte protection now, that is a small addition — flag it, don't do it silently.

- [ ] **Step 6: Commit**

```bash
git add pipeline/elm-cem/tests/brand-facts-schema-valid.test.mjs docs/facts-bundle/schema.json pipeline/elm-cem/tests/facts-bundle-schema.test.mjs pipeline/elm-cem/package.json
git commit -m "test(brand-facts): end-to-end schema-validity gate for emitted brand-facts.json (phase 2)"
```

---

## Self-Review

**1. Spec coverage** (spec §4/§5/§7 phase 2 vs tasks):
- §4.1 one file, canonical core + `targets.<lang>` → Tasks 3 (core) + 4/5 (`targets.elm`).
- §4.2 presence/absence encoding → Task 3 Step 2 `objectOmittingAbsent`; Task 3 Step 4 asserts all three `admits` states + `multi`/`required` only-when-true.
- §4.3 store acceptance / CEM-closed inventory / `admittedBy` separate → Task 3 Step 1 (inventory from `source.slots`, `admits` from `Comp.slots`, `admittedBy` from `Comp.admittedBy`); DECISION 3 restates the CEM-closed rule and its phase-3 boundary.
- §4.4 packages first-class + contract, once at top level → Task 5.
- §4.5 provenance as one block → Task 7 (CLI stamp, `brandFactsProvenance` shape, sha256 config hashes).
- §4.6 enrich model to true superset → Task 2 (`Comp.source`).
- §4.7 derive bindings + module→package join + fail-loud totality → Tasks 4 (per-component), 5 (packages), 6 (join + totality replicating `split.js:103-128`).
- §5.8 language-neutral core → Tasks 3/4 assert no Elm id in canonical core.
- §5.10 derived not authored → Tasks 4–6 derive from model + `packages.json`, never re-parse text.
- §7 phase 2 "emit alongside existing bundles" → Global Constraint + every task re-checks Face B/C byte-identity; capstone Task 8.

**2. Contradictions surfaced, not silently resolved:** DECISION 1 (six-key schema vs five-package reality — hard blocker, three options, recommendation), DECISION 2 (`cssProperties.syntax` source), DECISION 3 (slot inventory source — spec-answered, restated with phase-3 boundary). None guessed past.

**3. Placeholder scan:** Elm encoder *bodies* are cited by reference to the exact `FactsBundle.elm`/`split.js`/`Cem.elm` line ranges they port (same convention as the landed G1–G3 plan, which the task cites as the style reference), because the acceptance gate is schema-validity + spot-checks (no byte-golden exists) and the exact JSON-encode spelling is only verifiable by running elm-codegen. Every task names exact files, exact test assertions, and an explicit Run/Expected. No "TBD"/"handle appropriately"/"similar to Task N".

**4. Type/name consistency:** `PackagesConfig`/`ElmPackage`/`Bucket` introduced in Task 1, consumed by that name in Tasks 5–6. `Comp.source : Cem.Declaration` introduced in Task 2, read in Task 3. `BrandFacts.file : Brand -> …` grows a `Maybe PackagesConfig` arg exactly once (Task 5) and every later reference uses that signature. `brand-facts.generated.json` (intermediate, Elm) vs `brand-facts.json` (final, CLI-stamped) named consistently. `assignModuleToPackage`/`checkTotality` named once (Task 6). Provenance shape is explicitly the `brandFactsProvenance` schema shape (Task 7), distinguished from Face C's differing `provenance`.
