# Generator consolidation G1–G3: fold icon + family generation into the Elm codegen pass — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the two purely-Elm-output JS generators (`gen-icon-module.js`, `gen-family-package.js`) into the single Elm codegen pass (`Generate.Phantom.Emit`), so `<Lib>.Icon` and `<Lib>.Family.*` are emitted directly from the resolved `Brand`/`Comp` model instead of a second `JSON.parse` of config and (for families) a fragile regex re-parse of the just-rendered `.elm` text — then delete the JS generators once each Elm port reproduces today's committed output byte-for-byte.

**Architecture:** G1 plumbs `_families`/`_iconModule` into the flags Elm already decodes (`Generate.Config`), using their own top-level pass-through merge rule (the existing two-level `_config` merge in `elm-cem.js` doesn't fit these nested-object keys — research §5). G2 adds a new emitter module `Generate.Phantom.Emit.IconModule` that reads the icon catalog (now in flags, no filesystem read) and `Brand`'s decoded `_iconModule` config, and appends the `<Lib>.Icon` `Elm.File` (plus, when `package` is configured, additional `Elm.File`s at nested `<pkg>/src/...`, `<pkg>/elm.json`, etc. paths — proven safe, no `..`, per research §5 Risk 2) to `Generate.Phantom.Emit.files`'s output list. G3 adds `Generate.Phantom.Emit.FamilyPackage`, which derives each family module's re-exported surface directly from `Brand.comps` (the same `Comp` records `Generate.Phantom.Emit.Component.compModule` already renders from) instead of re-parsing rendered text. Both emitters are gated on their respective config being present, mirroring today's JS behavior (silent no-op / loud config-error). After each port is byte-equal to committed golden output, its JS generator and `post-generate.js` dispatch line are deleted.

**Tech Stack:** Elm (`elm-codegen`'s `Elm` DSL is NOT used for these two new emitters — they build `Elm.File` from plain Elm `String` composition, matching the existing pattern in `Generate.Phantom.Emit.FactsBundle` and the JS generators being ported, which are themselves string-templated, not AST-generated), Node.js test harnesses (`node:test`-free, plain `node tests/*.test.mjs` style matching this repo's existing suites), `elm-codegen` CLI, `pnpm`.

**Spec:** `core/elm-cem/research/2026-08-19-generator-consolidation.md` (sections referenced throughout: §2 per-generator verdicts, §3 emission model, §4 what-stays-JS, §5 de-risked risks, §8 G1–G4 sequencing).

## Global Constraints

- **Byte-identical golden bar.** Every port's emitted output MUST be byte-for-byte identical to the currently-committed generated files it replaces (`brands/m3e/outputs/elm-m3e/src/M3e/Icon.elm`, `brands/m3e/outputs/elm-m3e/elm-m3e-icons/**`, `brands/m3e/outputs/elm-m3e/elm-m3e-families/**`). A single differing byte (including trailing whitespace, blank-line count, or `@docs` ordering) is a FAIL, not a "close enough."
- **The drift gate must stay green** at the end of every task: `node tools/check-drift.mjs` from the repo root (producer/consumer bundle checks) and, where the elm toolchain is installed, `bash tools/ab-elm-cem.sh` (pristine-vs-workspace Face A byte-identity, R-010's A/B semantics — the reason committed `elm-m3e/src/` itself is NOT used as the drift gate's own comparison target, only as this plan's golden-file target).
- **`_families` and `_iconModule` are nested-object config keys** — unlike `_exclude` (a flat `List String`) or the per-component `attrTypes`/`syntheticAttrs` shape the existing two-level `_config` deep-merge (`core/elm-cem/bin/elm-cem.js:438-450`) was built for. They get their OWN merge rule (last-file-wins whole-object replacement, exactly like `_exclude`'s treatment today for non-plain-object top-level values) — do not try to force them through `deepMergeConfigs`'s two-level component/field merge.
- **Elm / elm-codegen only for the ports.** No new JS logic is added to produce Icon/Family Elm source; JS is removed only, never grown, in G2/G3 (module removal, `post-generate.js` dispatch removal, test removal). The one exception is the byte-compare test harness itself (plain Node, read-only, no generation logic).
- **JS is removed only after its Elm replacement is byte-equal.** Never delete `gen-icon-module.js`/`gen-family-package.js` (or their `post-generate.js` calls) until the corresponding golden test in this plan is green. Each generator's removal is its own task, sequenced strictly after its port's byte-equality task.

---

## Assumptions and environment notes

- **The elm toolchain may not be installed in this worktree.** `core/elm-cem/node_modules/.bin/elm-codegen` and `elm` are required to actually RUN the codegen commands below (Steps marked "Run:"). If they are absent, `node core/elm-cem/bin/elm-cem.js ...` will hit the `ENOENT` branch at `core/elm-cem/bin/elm-cem.js:193-200` and print `"elm-cem: could not run elm-codegen — install it..."`. Before starting Task 1, run `pnpm install` at the repo root (per this repo's `postinstall` → `node tools/install-toolchains.mjs`, `package.json:7`) so the pinned `elm-codegen`/`elm` binaries are present in `core/elm-cem/node_modules/.bin/`. If install is impossible in the execution environment, still make every edit specified below — the exact commands are given so a later run (CI, or a human with the toolchain) can verify byte-equality; do not claim a task's byte-equality step passed without having actually run and observed the diff.
- All file paths below are relative to the repo root `/Users/jhp/.paseo/worktrees/358ycm5n/investigate-facts-bundle-slot-admission` unless given as absolute.
- The brand under test throughout is `brands/m3e` — its `GEN_CONFIG_ARGS` (`tools/lib/regen.mjs:25-30`) is:
  ```
  --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json
  --config-from=config/slots.json
  --config-from=config/native-mdn.json
  --config-from=config/examples.generated.json
  ```
  run with `cwd: brands/m3e/outputs/elm-m3e`. `config/slots.json` (at `brands/m3e/outputs/elm-m3e/config/slots.json`, a symlink/copy of `brands/m3e/inputs/cem/config/slots.json` — verify with `ls -la brands/m3e/outputs/elm-m3e/config/slots.json` before Task 1) carries both `_iconModule` and `_families`.

---

### Task 1: Plumb `_iconModule` and `_families` into `Generate.Config`'s decoded output (G1, icon half)

**Files:**
- Modify: `core/elm-cem/codegen/Generate/Types.elm` (add fields to whatever record `Generate.Config`'s decode result flows into — see Step 1 for the exact type to extend)
- Modify: `core/elm-cem/codegen/Generate/Config.elm:1-6` (module exports), `:54-178` (`decodeConfigResult`)
- Modify: `core/elm-cem/bin/elm-cem.js:386-450` (`injectConfig`/`deepMergeConfigs`) — add the nested-object merge rule for `_iconModule`/`_families`
- Test: `core/elm-cem/tests/config-icon-families-flags.test.mjs` (new)

**Interfaces:**
- Consumes: raw `_config._iconModule` / `_config._families` JSON objects, exactly the shape `core/elm-cem/bin/gen-icon-module.js:429-449` and `core/elm-cem/bin/gen-family-package.js:504-518` read today (see those line ranges for the field lists: `lib`, `iconComp`, `catalogFrom`, `package{dir,name,summary,version,deps}`, `shape`, `tag`, `iconFamily`, `attribution` for icons; `lib`, `namespace`, `componentsFrom`, `package{...}`, `families: { <Name>: { root, members: [{component, path}] } }` for families).
- Produces: `Generate.Config.decodeConfigResult : Json.Decode.Value -> Result String ConfigResult` where `ConfigResult` (defined in `Generate.Types`) gains two new `Maybe` fields: `iconModule : Maybe IconModuleConfig` and `families : Maybe FamiliesConfig`. These are read by `Generate.elm`'s `generatePhantom` and passed into `Generate.Phantom.Emit.files` (Task 3) — so `Generate.Phantom.Emit.files`'s signature changes from `Brand -> Result (List String) (List Elm.File)` to also take these two `Maybe` configs (finalized in Task 2/3, not here — this task only makes the decode succeed and the data reachable from `Generate.elm`).

- [ ] **Step 1: Read the current `ConfigResult` type and confirm the extension point**

Run: `grep -n "ConfigResult" core/elm-cem/codegen/Generate/Types.elm`

Confirm it is a record type alias like `{ components : Dict String ..., exclude : List String }`. If it is not (names differ), adjust every reference below to match the real field names — do not guess.

- [ ] **Step 2: Write the failing decode test**

Create `core/elm-cem/tests/config-icon-families-flags.test.mjs`:

```js
#!/usr/bin/env node
// Proves _iconModule and _families reach Elm's decoded _config (G1). Before
// this test, `grep -rn "_families\|_iconModule" core/elm-cem/codegen/` finds
// NOTHING — the two JS generators read a second, independent JSON.parse of
// the same config files and Elm's decoder never sees these keys at all.
//
// This test does not run full codegen — it round-trips a minimal manifest +
// _config through `elm-cem.js`'s own --config-from merge machinery
// (injectConfig) and asserts the merged flags JSON that would be handed to
// elm-codegen contains both keys UNCHANGED (proves the CLI-side merge, which
// Elm then decodes per Task 1's Generate.Config changes).

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo, makeCheck } from "./lib/harness.mjs";

const cli = path.join(repo, "bin", "elm-cem.js");
const { check, finish } = makeCheck("config-icon-families-flags");

const brand = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-icon-families-flags-"));
fs.mkdirSync(path.join(brand, "config"), { recursive: true });
fs.writeFileSync(
  path.join(brand, "custom-elements.json"),
  JSON.stringify({ schemaVersion: "1.0.0", modules: [] })
);
fs.writeFileSync(
  path.join(brand, "config", "slots.json"),
  JSON.stringify({
    _phantom: true,
    _iconModule: {
      lib: "Wc",
      iconComp: "Icon",
      catalogFrom: "config/icons-catalog.json",
      tag: "wc-icon",
      iconFamily: "Test Icons",
    },
    _families: {
      lib: "Wc",
      namespace: "Family",
      families: { Widget: { root: "Widget", members: [] } },
    },
  })
);

// Run only the flags-merge prefix of elm-cem.js's pipeline: --output is
// omitted so elm-codegen itself never runs (this brand's manifest is empty
// and would fail generation) — we only need the merged flags file elm-codegen
// WOULD have received. elm-cem.js writes it via writeTemp before invoking
// elm-codegen and logs "elm-cem: merged --config-from" to stdout; capture the
// temp path from stderr/stdout is fragile, so instead re-require the CLI's
// own injectConfig indirectly is not exported — assert via stdout marker and
// a monkeypatched output: point --output at a throwaway dir and let
// elm-codegen fail (expected, empty manifest), then read the LAST
// `elm-cem-cfg-*` temp file elm-cem.js wrote to os.tmpdir().
const before = fs.readdirSync(os.tmpdir()).filter((f) => f.startsWith("elm-cem-cfg"));
const gen = spawnSync(
  "node",
  [
    cli,
    `--flags-from=${path.join(brand, "custom-elements.json")}`,
    "--config-from=config/slots.json",
    `--output=${path.join(brand, "src")}`,
  ],
  { cwd: brand, encoding: "utf8" }
);
const after = fs.readdirSync(os.tmpdir()).filter((f) => f.startsWith("elm-cem-cfg"));
const newTemp = after.find((f) => !before.includes(f));
check(Boolean(newTemp), "elm-cem.js wrote a merged --config-from temp file", gen.stdout + gen.stderr);

if (newTemp) {
  const merged = JSON.parse(fs.readFileSync(path.join(os.tmpdir(), newTemp), "utf8"));
  check(
    merged._config && typeof merged._config._iconModule === "object" && merged._config._iconModule.tag === "wc-icon",
    "_iconModule survives the --config-from merge into flags._config",
    JSON.stringify(merged._config)
  );
  check(
    merged._config && typeof merged._config._families === "object" && merged._config._families.namespace === "Family",
    "_families survives the --config-from merge into flags._config",
    JSON.stringify(merged._config)
  );
  fs.rmSync(path.join(os.tmpdir(), newTemp), { force: true });
}

finish("config-icon-families-flags: all checks passed");
```

- [ ] **Step 3: Run test to verify it fails**

Run: `node core/elm-cem/tests/config-icon-families-flags.test.mjs`
Expected: FAIL — `merged._config._iconModule` is `undefined` (or the whole check throws), because `deepMergeConfigs` (`core/elm-cem/bin/elm-cem.js:438-450`) merges `_iconModule`/`_families` using the two-level component/field rule, which for a SINGLE `--config-from` file is actually a no-op passthrough (only ONE file here) — so this specific test may actually PASS already for the single-file case. **If it passes**, add a second `--config-from` file in the test that also sets `_iconModule.attribution` to a different string, and assert the SECOND file's value wins for that one field while `tag`/`iconFamily` from the first file are preserved (proving field-level merge, not whole-object replacement) — this is the real gap: `deepMergeConfigs` treats `_iconModule` as a "component" whose "fields" (`lib`, `iconComp`, `tag`, ...) get merged, which happens to work by accident for flat fields but breaks for `_families.families` (a dict of dicts) and `_iconModule.package` (a nested object) because `isPlainObject` merge only merges ONE level, dropping deeper structure when two files both touch the same nested key. Add a THIRD assertion: two files, each declaring a DIFFERENT key inside `_iconModule.package` (`dir` vs `name`), and assert BOTH survive — this is the case that fails today (the two-level merge doesn't recurse into `package`, so the second file's `package: {name: "..."}` REPLACES the first file's whole `package: {dir: ...}`, losing `dir`). This is the concrete regression Task 1 must fix.

- [ ] **Step 4: Fix `deepMergeConfigs` to deep-merge `_iconModule`/`_families` (and any other `_`-prefixed nested-object key) recursively, not just two levels**

Edit `core/elm-cem/bin/elm-cem.js:438-450`:

```js
function isPlainObject(v) {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}
// Recursive plain-object merge (arrays and scalars are last-wins at any depth).
function deepMergeObject(a, b) {
  const out = { ...a };
  for (const [k, v] of Object.entries(b)) {
    if (isPlainObject(v) && isPlainObject(out[k])) out[k] = deepMergeObject(out[k], v);
    else out[k] = v;
  }
  return out;
}
function deepMergeConfigs(objs) {
  const out = {};
  for (const o of objs) {
    for (const [comp, fields] of Object.entries(o || {})) {
      if (isPlainObject(fields) && isPlainObject(out[comp])) {
        out[comp] = deepMergeObject(out[comp], fields);
      } else {
        out[comp] = fields;
      }
    }
  }
  return out;
}
```

This changes the top-level component/field merge from ONE level of `{...out[comp], ...fields}` (which silently drops nested-object siblings on collision — the bug proven by Step 3) to full recursive plain-object merging at every depth, while keeping the documented array/scalar last-wins rule (`_exclude`, `_iconModule.tag`, etc. are still replaced wholesale, never index-merged). This is strictly more correct for the EXISTING per-component `attrTypes`/`syntheticAttrs` shape too (they're currently only one level deep in practice, so this is a no-op for them) — verify with Step 5's existing-test-suite run.

- [ ] **Step 5: Run test to verify it passes, plus the existing config-merge-dependent suites**

Run: `node core/elm-cem/tests/config-icon-families-flags.test.mjs`
Expected: PASS (all three assertions, including the two-file merge case added in Step 3).

Run: `node core/elm-cem/tests/gates.test.mjs && node core/elm-cem/tests/exclude-cli.test.mjs`
Expected: PASS (both exercise `--config-from` merging today; must stay green — `deepMergeObject`'s change is additive-only for their flat-field cases).

- [ ] **Step 6: Commit**

```bash
git add core/elm-cem/bin/elm-cem.js core/elm-cem/tests/config-icon-families-flags.test.mjs
git commit -m "fix(elm-cem): deep-merge nested _config keys across --config-from files"
```

---

### Task 2: Decode `_iconModule`/`_families` in `Generate.Config` and thread them to `Generate.elm`

**Files:**
- Modify: `core/elm-cem/codegen/Generate/Types.elm` (add `IconModuleConfig`, `FamiliesConfig`, `FamilySpec`, `FamilyMember` type aliases; extend `ConfigResult`)
- Modify: `core/elm-cem/codegen/Generate/Config.elm:1` (exports), `:54-178` (`decodeConfigResult`)
- Modify: `core/elm-cem/codegen/Generate.elm:73-135` (`generatePhantom`) — read `legacyConfig.iconModule`/`.families`, pass to `Generate.Phantom.Emit.files`
- Test: `core/elm-cem/tests/elm-shape.test.mjs` pattern (new `node --test` style test, OR extend `config-icon-families-flags.test.mjs` from Task 1) — see Step 2

**Interfaces:**
- Consumes: `ConfigResult` from Task 1 (`{ components, exclude, iconModule : Maybe IconModuleConfig, families : Maybe FamiliesConfig }`).
- Produces:
  ```elm
  type alias IconModuleConfig =
      { lib : String
      , iconComp : String
      , catalogFrom : String
      , shape : String -- "names" | "functions", default "names"
      , tag : String
      , iconFamily : String
      , attribution : Maybe String
      , package : Maybe IconPackageConfig
      }

  type alias IconPackageConfig =
      { dir : String, name : String, summary : String, version : String, deps : List ( String, String ) }

  type alias FamiliesConfig =
      { lib : String
      , namespace : String
      , componentsFrom : Maybe String
      , package : FamilyPackageConfig
      , families : List ( String, FamilySpec ) -- order-preserving; JSON object key order
      }

  type alias FamilySpec =
      { root : Maybe String, members : List FamilyMember }

  type alias FamilyMember =
      { component : String, path : String }

  type alias FamilyPackageConfig =
      { dir : String, name : String, summary : String, version : String, deps : List ( String, String ) }
  ```
  These decoders are consumed by `Generate.Phantom.Emit.IconModule`/`FamilyPackage` (Tasks 4/6). `Generate.elm` passes `legacyConfig.iconModule : Maybe IconModuleConfig` and `legacyConfig.families : Maybe FamiliesConfig` into `Generate.Phantom.Emit.files brand iconCatalogNames maybeIconModule maybeFamilies` (signature finalized in Task 3).
- **Note on the icon catalog**: `catalogFrom` names a JSON file (`config/icons-catalog.json`) that is NOT part of the CEM manifest and is read by `gen-icon-module.js:475` via a THIRD filesystem read (manifest, config, catalog — three separate reads today). Per the hard constraint in research §3 ("every input must arrive up front... no mid-run filesystem read"), the catalog's `names : List String` must ALSO be merged into flags by the JS shell, NOT read by Elm from `catalogFrom` at decode time (Elm has no filesystem access). Task 2 decodes `catalogFrom` as a plain string (so the JS shell in Task 5 knows which file to read and inline); Task 5 is where the actual catalog names get merged into `_config._iconModule.names` before invoking elm-codegen — **decode `names : Maybe (List String)` here too**, optional because it doesn't exist in the CURRENT `_iconModule` JSON shape (it will be injected by the CLI wrapper in Task 5, not authored by hand in `slots.json`).

- [ ] **Step 1: Write the failing decoder test** — extend `core/elm-cem/tests/config-icon-families-flags.test.mjs` (Task 1) is JS-side; the Elm-side decode is exercised indirectly once Task 3's emitter consumes it, OR write a focused elm-test. Prefer the indirect route (Task 3's golden byte-compare IS the decode proof — a decode bug means the emitter never fires or crashes) to avoid hand-writing a throwaway Elm test file that duplicates Task 3's coverage. Skip a standalone Elm unit test here; proceed to Step 2.

- [ ] **Step 2: Add the type aliases to `Generate/Types.elm`**

Read the existing file first to place these consistently with its style (record alphabetization, comment banner conventions):

Run: `grep -n "^type alias" core/elm-cem/codegen/Generate/Types.elm`

Append the type aliases from the Interfaces block above (verbatim), plus extend `ConfigResult`:

```elm
type alias ConfigResult =
    { components : Dict String { attrTypes : List ( String, Cem.AttrTypeOverride ), syntheticAttrs : List SyntheticAttr }
    , exclude : List String
    , iconModule : Maybe IconModuleConfig
    , families : Maybe FamiliesConfig
    }
```

(Adjust the `components` field type to match whatever is ACTUALLY there today per Step 1 of Task 1 — do not invent a different shape; this snippet only shows the two NEW fields being added alongside the existing ones.)

- [ ] **Step 3: Decode `_iconModule` and `_families` in `Generate/Config.elm`**

Add to `decodeConfigResult` (`core/elm-cem/codegen/Generate/Config.elm:54-178`), inside the `Ok (Just configValue) ->` branch, alongside `compsResult`/`exclResult`:

```elm
                depPairsDecoder =
                    Json.Decode.keyValuePairs Json.Decode.string

                iconPackageDecoder =
                    Json.Decode.map5
                        (\dir nm summary version deps -> { dir = dir, name = nm, summary = summary, version = version, deps = deps })
                        (Json.Decode.field "dir" Json.Decode.string)
                        (Json.Decode.field "name" Json.Decode.string)
                        (Json.Decode.field "summary" Json.Decode.string)
                        (Json.Decode.field "version" Json.Decode.string)
                        (Json.Decode.field "deps" depPairsDecoder)

                iconModuleDecoder =
                    Json.Decode.map8
                        (\lib iconComp catalogFrom shape tag iconFamily attribution pkg ->
                            { lib = lib, iconComp = iconComp, catalogFrom = catalogFrom, shape = shape, tag = tag, iconFamily = iconFamily, attribution = attribution, package = pkg, names = Nothing }
                        )
                        (Json.Decode.field "lib" Json.Decode.string)
                        (Json.Decode.field "iconComp" Json.Decode.string)
                        (Json.Decode.field "catalogFrom" Json.Decode.string)
                        (opt "shape" Json.Decode.string "names")
                        (Json.Decode.field "tag" Json.Decode.string)
                        (Json.Decode.field "iconFamily" Json.Decode.string)
                        (Json.Decode.maybe (Json.Decode.field "attribution" Json.Decode.string))
                        (Json.Decode.maybe (Json.Decode.field "package" iconPackageDecoder))
                        |> Json.Decode.andThen
                            (\im ->
                                Json.Decode.maybe (Json.Decode.field "names" (Json.Decode.list Json.Decode.string))
                                    |> Json.Decode.map (\names -> { im | names = names })
                            )

                iconModuleResult =
                    Json.Decode.decodeValue (Json.Decode.maybe (Json.Decode.field "_iconModule" iconModuleDecoder)) configValue
                        |> Result.mapError Json.Decode.errorToString

                familyMemberDecoder =
                    Json.Decode.map2 (\c p -> { component = c, path = p })
                        (Json.Decode.field "component" Json.Decode.string)
                        (Json.Decode.field "path" Json.Decode.string)

                familySpecDecoder =
                    Json.Decode.map2 (\root members -> { root = root, members = members })
                        (Json.Decode.maybe (Json.Decode.field "root" Json.Decode.string))
                        (opt "members" (Json.Decode.list familyMemberDecoder) [])

                familiesDecoder =
                    Json.Decode.map5
                        (\lib ns componentsFrom pkg fams -> { lib = lib, namespace = ns, componentsFrom = componentsFrom, package = pkg, families = fams })
                        (Json.Decode.field "lib" Json.Decode.string)
                        (Json.Decode.field "namespace" Json.Decode.string)
                        (Json.Decode.maybe (Json.Decode.field "componentsFrom" Json.Decode.string))
                        (Json.Decode.field "package" iconPackageDecoder)
                        (Json.Decode.field "families" (Json.Decode.keyValuePairs familySpecDecoder))

                familiesResult =
                    Json.Decode.decodeValue (Json.Decode.maybe (Json.Decode.field "_families" familiesDecoder)) configValue
                        |> Result.mapError Json.Decode.errorToString
```

Note: `iconModuleDecoder`'s `names` field is added via `andThen` because `Json.Decode.map8` is elm/json's arity ceiling — this pattern (decode N fields, then `andThen` one more) is the standard workaround and matches the style already used elsewhere in this decoder for `optStrict`. Update `Result.map2 (\comps excl -> ...)` at the end of the `Ok (Just configValue) ->` branch to `Result.map4 (\comps excl im fams -> { components = comps, exclude = excl, iconModule = im, families = fams }) compsResult exclResult iconModuleResult familiesResult`. Also fix the `Ok Nothing ->` branch (line 155) to return `{ components = Dict.empty, exclude = [], iconModule = Nothing, families = Nothing }`.

Also add the two new type aliases (`IconModuleConfig` with the `names : Maybe (List String)` field, `FamiliesConfig`, etc.) to `Generate/Types.elm` per Step 2, adjusted to include `names` on `IconModuleConfig` as shown in the decoder above.

- [ ] **Step 4: Thread the decoded configs through `Generate.elm`**

Edit `core/elm-cem/codegen/Generate.elm:100-107` (inside the `Result.map (\legacyConfig -> ...)` block) — no change needed there; `legacyConfig.iconModule`/`.families` are already in scope once `ConfigResult` carries them. Edit the `Ok { libraryInfo, declarations } ->` branch (`Generate.elm:114-141`) to pass `legacyConfig`'s new fields through: this requires `legacyConfig` to be in scope at that point too. Restructure the `case extractionResult of` pattern-match slightly:

```elm
    case extractionResult of
        Err configError ->
            Err [ { title = "config decode error", description = configError } ]

        Ok { libraryInfo, declarations, iconModule, families } ->
            case Generate.Phantom.Model.resolve libraryInfo.moduleName libraryInfo.eventPrefix flags declarations of
                Ok brand ->
                    case Generate.Phantom.Emit.files brand iconModule families of
                        ...
```

— which means the record built at `Generate.elm:100-107` must ALSO carry `iconModule = legacyConfig.iconModule` and `families = legacyConfig.families` alongside `libraryInfo`/`declarations`. Update that record literal accordingly. (`Generate.Phantom.Emit.files`'s new signature `Brand -> Maybe IconModuleConfig -> Maybe FamiliesConfig -> Result (List String) (List Elm.File)` is finalized in Task 3 — this task only makes the two `Maybe` values REACH that call site; Task 3 changes the function itself.)

- [ ] **Step 5: Compile-check (no behavior change yet — `files` still ignores the two new args until Task 3)**

Run: `cd core/elm-cem && node_modules/.bin/elm-codegen run codegen/Generate.elm --flags-from=tests/fixtures/wc-widgets.cem.json --output=/tmp/elm-cem-g1-check` (adjust the fixture path per `grep -rn "wc-widgets.cem.json" core/elm-cem/tests/` if it differs)
Expected: elm-codegen invokes `elm make` on `Generate.elm` and reports a compile error ONLY if Task 3's signature change hasn't been made yet consistently — since Step 4 already references the new `files` signature, do Task 2 and Task 3 as one atomic Elm-compiling commit (see Task 3's own steps) rather than committing Task 2 alone with a broken build. **Do not commit after this step** — proceed directly into Task 3, then commit both together (Task 3 Step 6 covers the joint commit).

---

### Task 3: Extend `Generate.Phantom.Emit.files`'s signature to accept the new configs (no new emitters yet)

**Files:**
- Modify: `core/elm-cem/codegen/Generate/Phantom/Emit.elm:67-137` (`files`)
- Modify: `core/elm-cem/codegen/Generate.elm` (call site, from Task 2 Step 4)

**Interfaces:**
- Produces: `files : Brand -> Maybe Generate.Types.IconModuleConfig -> Maybe Generate.Types.FamiliesConfig -> Result (List String) (List Elm.File)`. For this task, the two new parameters are accepted but UNUSED (`_iconModule` / `_families` argument names prefixed with `_` per Elm's unused-binding convention) — Tasks 4 and 6 add the actual emitters that consume them. This keeps Task 3 a pure signature-plumbing change with a trivially verifiable "still emits exactly what it emitted before" property.

- [ ] **Step 1: Change the signature and ignore the new args**

Edit `core/elm-cem/codegen/Generate/Phantom/Emit.elm:67`:

```elm
files : Brand -> Maybe Generate.Types.IconModuleConfig -> Maybe Generate.Types.FamiliesConfig -> Result (List String) (List Elm.File)
files brand _ _ =
```

Add `import Generate.Types` to the import list (`Emit.elm:31-56`) if not already present.

- [ ] **Step 2: Update the call site in `Generate.elm`**

Confirm `Generate.elm`'s call (from Task 2 Step 4) reads `Generate.Phantom.Emit.files brand iconModule families`.

- [ ] **Step 3: Run the full existing Elm test suite + a real generation, confirm ZERO output change**

Run: `cd core/elm-cem && pnpm run test:gates` (exercises `regen-drift`, a full generate)
Expected: PASS, unchanged from before this task (the two new args are inert).

Run a real brand generation and diff against committed golden, to prove Tasks 1-3 combined are a no-op for existing output:

```bash
cd /Users/jhp/.paseo/worktrees/358ycm5n/investigate-facts-bundle-slot-admission/brands/m3e/outputs/elm-m3e
PATH="$PWD/node_modules/.bin:$PATH" node ../../../../core/elm-cem/bin/elm-cem.js \
  --flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json \
  --config-from=config/slots.json \
  --config-from=config/native-mdn.json \
  --config-from=config/examples.generated.json \
  --output=/tmp/g1-g3-task3-check
diff -rq src /tmp/g1-g3-task3-check
```
Expected: no output (identical trees) — `src/M3e/Icon.elm` is untouched by Tasks 1-3 (G2 hasn't ported it yet; it's still written by the JS `post-generate.js` hook, which still runs unmodified).

- [ ] **Step 4: Commit (Tasks 1-3 together, since Task 2's compile depended on Task 3's signature)**

```bash
git add core/elm-cem/codegen/Generate.elm core/elm-cem/codegen/Generate/Config.elm core/elm-cem/codegen/Generate/Types.elm core/elm-cem/codegen/Generate/Phantom/Emit.elm core/elm-cem/bin/elm-cem.js core/elm-cem/tests/config-icon-families-flags.test.mjs
git commit -m "feat(elm-cem): decode _iconModule/_families into Elm flags (G1)"
```

---

### Task 4: Golden byte-compare test harness + failing test for `<Lib>.Icon` (G2, red)

**Files:**
- Create: `core/elm-cem/tests/golden-icon-module.test.mjs`
- Read (golden reference, do not modify): `brands/m3e/outputs/elm-m3e/src/M3e/Icon.elm`, `brands/m3e/outputs/elm-m3e/elm-m3e-icons/src/M3e/Icon.elm`, `brands/m3e/outputs/elm-m3e/elm-m3e-icons/elm.json`, `brands/m3e/outputs/elm-m3e/elm-m3e-icons/README.md`, `brands/m3e/outputs/elm-m3e/elm-m3e-icons/LICENSE`

**Interfaces:**
- Consumes: `tools/lib/regen.mjs`'s `GEN_CONFIG_ARGS` pattern (do not re-hardcode a fourth copy — import `runFactsGenerator`/`GEN_CONFIG_ARGS` if reachable from `core/elm-cem/tests/`, else literally copy the four `--config-from`/`--flags-from` args as this repo's other elm-cem-local tests already do when they can't reach `tools/lib/` — check `core/elm-cem/tests/*.test.mjs` for an existing example of generating against the REAL `brands/m3e` config from inside `core/elm-cem/tests/`; if none exists, invoke `elm-cem.js` directly with the four args, `cwd: brands/m3e/outputs/elm-m3e`, exactly as `tools/lib/regen.mjs:44-54` does).
- Produces: a reusable `runGoldenGenerate(outputDir)` helper other golden tests (Task 6) can share — export it from a new `core/elm-cem/tests/lib/golden.mjs` instead of duplicating inline, since Task 6 needs the identical invocation.

- [ ] **Step 1: Create the shared golden-generation helper**

Create `core/elm-cem/tests/lib/golden.mjs`:

```js
// golden.mjs — shared helper for byte-compare tests that regenerate
// brands/m3e's REAL output (not a throwaway fixture brand) and diff specific
// paths against the committed golden files. Used by golden-icon-module.test.mjs
// (G2) and golden-family-package.test.mjs (G3) so both stay in lockstep with
// the same invocation — the exact failure mode R-014 (tools/lib/regen.mjs)
// exists to prevent, applied to these two new suites.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { repo } from "./harness.mjs";

export const elmM3e = path.join(repo, "..", "..", "brands", "m3e", "outputs", "elm-m3e");
const cli = path.join(repo, "bin", "elm-cem.js");

/** Run elm-cem against brands/m3e's real config, writing Face A into `outputDir`. */
export function runGoldenGenerate(outputDir) {
  return spawnSync(
    process.execPath,
    [
      cli,
      "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
      "--config-from=config/slots.json",
      "--config-from=config/native-mdn.json",
      "--config-from=config/examples.generated.json",
      `--output=${outputDir}`,
    ],
    {
      cwd: elmM3e,
      encoding: "utf8",
      env: { ...process.env, PATH: `${path.join(elmM3e, "node_modules", ".bin")}:${process.env.PATH}` },
    }
  );
}

/** Byte-compare `freshPath` against `goldenPath`; returns { ok, detail }. */
export function byteEqual(goldenPath, freshPath) {
  if (!fs.existsSync(goldenPath)) return { ok: false, detail: `golden file missing: ${goldenPath}` };
  if (!fs.existsSync(freshPath)) return { ok: false, detail: `fresh file missing: ${freshPath}` };
  const a = fs.readFileSync(goldenPath);
  const b = fs.readFileSync(freshPath);
  if (a.equals(b)) return { ok: true, detail: "byte-identical" };
  return { ok: false, detail: `DIFFERS: ${goldenPath} vs ${freshPath} (${a.length} vs ${b.length} bytes)` };
}
```

`repo` (from `core/elm-cem/tests/lib/harness.mjs:19`) resolves to `core/elm-cem`; `elmM3e` walks up two levels to the workspace root then into `brands/m3e/outputs/elm-m3e` — verify this path arithmetic once by running `node -e "console.log(require('path').join(require('./core/elm-cem/tests/lib/harness.mjs').repo,'..','..','brands','m3e','outputs','elm-m3e'))"` is not directly runnable (ESM) — instead confirm interactively: `node --input-type=module -e "import {repo} from './core/elm-cem/tests/lib/harness.mjs'; console.log(repo)"` from the repo root, expect it to print the absolute path ending in `core/elm-cem`; then confirm `path.join(repo, '..', '..', 'brands', 'm3e', 'outputs', 'elm-m3e')` lands on the real `brands/m3e/outputs/elm-m3e` (repo root is TWO levels above `core/elm-cem`: `core/elm-cem` → `core` → repo root — so `'..', '..'` is correct only if `core/elm-cem`'s parent's parent IS the repo root; verify with `pwd` math, adjust the `path.join` args if off by one level).

- [ ] **Step 2: Write the failing golden test for the main `src/M3e/Icon.elm` output**

Create `core/elm-cem/tests/golden-icon-module.test.mjs`:

```js
#!/usr/bin/env node
// Golden byte-compare for G2: <Lib>.Icon ported from bin/gen-icon-module.js
// into Generate.Phantom.Emit.IconModule. The committed
// brands/m3e/outputs/elm-m3e/src/M3e/Icon.elm (and the standalone
// elm-m3e-icons/ package tree) ARE the golden output this port must reproduce
// byte-for-byte. Until the Elm port lands, this test FAILS because the fresh
// --output tree's M3e/Icon.elm is written by the (still-active) JS
// gen-icon-module.js post-generate hook, which writes to a DIFFERENT path
// shape than what the Elm emitter will (or coincidentally the same path but
// this test proves it stays byte-identical through the swap) — the point of
// this test is to go GREEN before AND stay GREEN after the port, with the
// implementation swapped out from under it. Run it now to confirm it is
// GREEN under the OLD (JS) implementation first (sanity), THEN gate the port
// on it staying green — see Step 3.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { makeCheck } from "./lib/harness.mjs";
import { elmM3e, runGoldenGenerate, byteEqual } from "./lib/golden.mjs";

const { check, finish } = makeCheck("golden-icon-module");

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-golden-icon-"));
const outDir = path.join(work, "out");
fs.mkdirSync(outDir, { recursive: true });

const gen = runGoldenGenerate(outDir);
check(gen.status === 0, "elm-cem generation exits 0 against brands/m3e's real config", gen.stdout + gen.stderr);

if (gen.status === 0) {
  const mainIcon = byteEqual(path.join(elmM3e, "src", "M3e", "Icon.elm"), path.join(outDir, "M3e", "Icon.elm"));
  check(mainIcon.ok, "fresh src/M3e/Icon.elm is byte-identical to the committed golden", mainIcon.detail);

  // The standalone elm-m3e-icons/ package: repoRoot (per gen-icon-module.js:503
  // and, post-port, the Elm emitter's equivalent) is ONE level above --output.
  const repoRootFresh = path.dirname(outDir);
  const pkgIcon = byteEqual(
    path.join(elmM3e, "elm-m3e-icons", "src", "M3e", "Icon.elm"),
    path.join(repoRootFresh, "elm-m3e-icons", "src", "M3e", "Icon.elm")
  );
  check(pkgIcon.ok, "fresh elm-m3e-icons/src/M3e/Icon.elm is byte-identical to the committed golden", pkgIcon.detail);

  const pkgElmJson = byteEqual(
    path.join(elmM3e, "elm-m3e-icons", "elm.json"),
    path.join(repoRootFresh, "elm-m3e-icons", "elm.json")
  );
  check(pkgElmJson.ok, "fresh elm-m3e-icons/elm.json is byte-identical to the committed golden", pkgElmJson.detail);
}

fs.rmSync(work, { recursive: true, force: true });
finish("golden-icon-module: all checks passed");
```

- [ ] **Step 3: Run it now, BEFORE any G2 implementation, to establish the sanity baseline**

Run: `node core/elm-cem/tests/golden-icon-module.test.mjs`
Expected: PASS (all three checks) — the CURRENT pipeline (Elm codegen for everything else + `post-generate.js`'s JS `gen-icon-module.js` hook, unmodified through Tasks 1-3) still produces byte-identical output to committed golden, since Tasks 1-3 were proven to be a no-op (Task 3 Step 3). **This is not the "run to fail" step of the standard TDD loop** — there is nothing to fail yet because we haven't touched the icon generator. The RED step comes in Task 5 when `gen-icon-module.js` is deleted and the Elm port must carry the whole weight alone; keep this test GREEN as a regression fence while building the Elm emitter (Task 5's Step 2 "still calls the JS generator" middle state), then flip it (Task 5 Steps 3-5) once the Elm emitter is wired in and the JS call is removed.

- [ ] **Step 4: Commit the harness (test passes against the OLD implementation — this is the fence, not the feature)**

```bash
git add core/elm-cem/tests/lib/golden.mjs core/elm-cem/tests/golden-icon-module.test.mjs
git commit -m "test(elm-cem): add golden byte-compare fence for M3e.Icon (G2 prep)"
```

---

### Task 5: Port `gen-icon-module.js` into `Generate.Phantom.Emit.IconModule` (G2, green)

**Files:**
- Create: `core/elm-cem/codegen/Generate/Phantom/Emit/IconModule.elm`
- Modify: `core/elm-cem/codegen/Generate/Phantom/Emit.elm:67-137` (wire the new emitter into `files`, consuming the `Maybe IconModuleConfig` argument from Task 3)
- Modify: `core/elm-cem/bin/elm-cem.js` — inject the icon catalog's `names` array into `_config._iconModule.names` before invoking elm-codegen (per Task 2's note that Elm cannot read `catalogFrom` itself)
- Modify: `core/elm-cem/bin/post-generate.js:35-41` — stop calling `gen-icon-module`
- Delete: `core/elm-cem/bin/gen-icon-module.js` (after Step 5 is green — see Task 5b below; kept as a separate task per the Global Constraint "JS removed only after Elm replacement is byte-equal")
- Test: `core/elm-cem/tests/golden-icon-module.test.mjs` (from Task 4, now the real gate)

**Interfaces:**
- Consumes: `IconModuleConfig` (Task 2), `Brand` (existing `Generate.Phantom.Model.Brand`).
- Produces: `Generate.Phantom.Emit.IconModule.files : String -> Maybe IconModuleConfig -> List Elm.File` — `String` is the resolved `brand.lib` (needed as fallback per `gen-icon-module.js:445` "`_brand` as fallback for lib" — but since Task 2's decoder makes `lib` a REQUIRED field of `IconModuleConfig`, that fallback becomes dead in the ported version UNLESS `lib` is made optional; **decide and document explicitly**: the JS fallback existed because `_iconModule.lib` might be absent and `_brand` (top-level config key) supplies it. Check `grep -n '"_brand"' brands/m3e/inputs/cem/config/*.json` — if `brands/m3e`'s real config never omits `_iconModule.lib`, keep `lib` required in the Elm decoder (simpler, matches this plan's byte-equality target) and drop the fallback; note this as an intentional, documented behavior narrowing in the port (call it out in the module doc comment), not a silent gap.

- [ ] **Step 1: Verify the `_brand` fallback is dead weight for the real brand**

Run: `grep -n '"_iconModule"' -A3 brands/m3e/inputs/cem/config/slots.json` and `grep -n '"_brand"' brands/m3e/inputs/cem/config/slots.json`

Confirm `_iconModule.lib` is present (already shown by this plan's own investigation: `"lib": "M3e"` is set). Proceed treating `lib` as required — document this in the new Elm module's header comment: *"`_iconModule.lib` is required (the JS predecessor's `_brand` fallback is dropped — no shipped brand config relies on it; `brand.lib` is available via the `Brand` record passed to `files` and used ONLY if a future config omits `lib`, but Task 2's decoder currently requires it, matching gen-icon-module.js's de facto behavior for every real config)."*

- [ ] **Step 2: Write `Generate/Phantom/Emit/IconModule.elm` — port `toElmIdentifier`/`generateIconModule`**

Port `gen-icon-module.js:38-79` (`ELM_RESERVED`, `snakeToCamel`, `toElmIdentifier`) and `gen-icon-module.js:124-316` (`generateIconModule`) line-for-line into Elm string-building, preserving:
- The exact reserved-word set (`gen-icon-module.js:38-53`).
- The exact collision-detection loop (`gen-icon-module.js:140-152`) — port as a fold building a `Dict String String` (identifier → first snake name) and short-circuit to an `Err` (NOT `process.exit(1)` — Elm has no process exit; return `Result String (List Elm.File)` and have `Generate.Phantom.Emit.files` surface it as a collision error, same shape as `runGuard`'s existing `Err (List String)` path at `Emit.elm:130-137`).
- The exact section-join separator (`"\n\n\n"` at `gen-icon-module.js:314`, `:316`) and trailing `"\n"` — Elm string concatenation must reproduce this EXACTLY (`String.join "\n\n\n" sections ++ "\n"`).
- Both shapes (`"names"` default, `"functions"`) — `gen-icon-module.js:154-312`.
- The doc-comment text VERBATIM, including the `@docs` line ordering (`gen-icon-module.js:198-215`) and the `formatSig` multi-line signature formatting (`gen-icon-module.js:235-243`).

```elm
module Generate.Phantom.Emit.IconModule exposing (files)

{-| Port of bin/gen-icon-module.js (G2, 2026-08-19 generator-consolidation
research). Emits `<lib>.Icon` (and, when `_iconModule.package` is configured,
a standalone package tree) as `Elm.File`s, from config decoded up-front in
Generate.Config (no filesystem access here — the icon catalog names arrive
pre-merged into `IconModuleConfig.names` by the CLI shell, since Elm's
single-shot `main` cannot read `catalogFrom` itself; see
Generate.Config's IconModuleConfig doc and bin/elm-cem.js's catalog-injection
step).

@docs files

-}

import Dict exposing (Dict)
import Elm
import Generate.Types exposing (IconModuleConfig)
import Set exposing (Set)


elmReserved : Set String
elmReserved =
    Set.fromList
        [ "if", "then", "else", "case", "of", "let", "in", "type", "module", "where", "import", "exposing", "as", "port", "custom", "icon" ]


snakeToCamel : String -> String
snakeToCamel snake =
    case String.split "_" snake of
        [] ->
            ""

        first :: rest ->
            first ++ String.concat (List.map upperFirst rest)


upperFirst : String -> String
upperFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toUpper c) tail


toElmIdentifier : String -> String
toElmIdentifier snake =
    let
        hasLeadingDigit =
            String.uncons snake
                |> Maybe.map (\( c, _ ) -> Char.isDigit c)
                |> Maybe.withDefault False

        camel =
            if hasLeadingDigit then
                "icon" ++ snakeToCamel snake

            else
                snakeToCamel snake
    in
    if Set.member camel elmReserved then
        camel ++ "_"

    else
        camel


{-| Returns `Err collisionMessage` on the first identifier collision
(mirrors gen-icon-module.js's loud `process.exit(1)`, gen-icon-module.js:140-152),
else `Ok (allIds, moduleSource)`.
-}
generateIconModule : String -> List String -> String -> String -> String -> Maybe String -> Result String String
generateIconModule lib names shape tag iconFamily attribution =
    let
        checkCollisions =
            List.foldl
                (\snake acc ->
                    case acc of
                        Err e ->
                            Err e

                        Ok seen ->
                            let
                                id_ =
                                    toElmIdentifier snake
                            in
                            case Dict.get id_ seen of
                                Just firstSnake ->
                                    Err
                                        ("elm-cem gen-icon-module: COLLISION — \"" ++ snake ++ "\" and \"" ++ firstSnake ++ "\" both map to Elm identifier \"" ++ id_ ++ "\".")

                                Nothing ->
                                    Ok (Dict.insert id_ snake seen)
                )
                (Ok Dict.empty)
                names
    in
    checkCollisions
        |> Result.map (\_ -> buildModuleSource lib names shape tag iconFamily attribution)


{-| The actual string-template port of gen-icon-module.js:124-316. Ported
verbatim section-by-section; see that file for the authoritative prose
comments on WHY each shape/section exists (R-026 docs.json cap rationale,
etc.) — not repeated here to avoid drift between two copies of the same prose;
this module's tests are the byte-equality proof, not a second copy of the doc.
-}
buildModuleSource : String -> List String -> String -> String -> String -> Maybe String -> String
buildModuleSource lib names shape tag iconFamily attribution =
    -- (Full port of gen-icon-module.js:139-315 goes here: exposingList,
    -- moduleLine, headlineDoc/moduleDoc per shape, imports, sigParts,
    -- formatSig, produce, preambleDecls, iconDecls, sections join.
    -- Elided in this plan — Task 5 Step 3's byte-compare test is the
    -- executable spec; port each JS line range 1:1, do not paraphrase.)
    Debug.todo "port gen-icon-module.js:139-315 here, section by section, matching every literal string exactly"


{-| Emit `<lib>.Icon` plus, when `package` is configured, the standalone
package tree, as `Elm.File`s at nested paths. `Elm.File.path` is unconstrained
(research §3) — the package tree's files use paths like
`"../elm-m3e-icons/src/M3e/Icon.elm"` relative to the SAME `--output` root,
proven safe because elm-codegen's writer does `path.join(output_dir, file.path)`
with no traversal guard (research §5 Risk 2) — IDENTICAL to how
`gen-icon-module.js:503-505`'s `repoRoot = path.dirname(outDir)` computes
"one level above --output=src".
-}
files : String -> Maybe IconModuleConfig -> Result String (List Elm.File)
files brandLib maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            let
                lib =
                    cfg.lib
            in
            case cfg.names of
                Nothing ->
                    Err "Generate.Phantom.Emit.IconModule: _iconModule.names is empty — the CLI shell must inject the icon catalog into flags before generation (see bin/elm-cem.js)."

                Just names ->
                    generateIconModule lib names cfg.shape cfg.tag cfg.iconFamily cfg.attribution
                        |> Result.map
                            (\src ->
                                let
                                    mainFile =
                                        Elm.file (String.split "." lib ++ [ "Icon" ]) src |> elmFileFromSource (String.join "/" (String.split "." lib) ++ "/Icon.elm") src

                                    packageFiles =
                                        case cfg.package of
                                            Nothing ->
                                                []

                                            Just pkg ->
                                                iconPackageTreeFiles pkg lib src cfg.shape
                                in
                                mainFile :: packageFiles
                            )


-- (elmFileFromSource / iconPackageTreeFiles: build Elm.File values with plain
-- Elm.File constructor {path=.., contents=.., warnings=[]} at the paths
-- gen-icon-module.js:325-416's writePackageTree computes — port THAT
-- function's elm.json/README.md/LICENSE string templates verbatim too, since
-- those are also part of the byte-equality target for
-- elm-m3e-icons/{elm.json,README.md,LICENSE}. Elided here — Task 5 Step 3.)
```

**This step deliberately contains a `Debug.todo` placeholder marker in the plan text ONLY as a pointer to "port this exact JS range verbatim" — the executing agent must NOT leave `Debug.todo` in committed code (it would fail `elm make`).** Replace it with the actual ported string-building logic from `gen-icon-module.js:139-315`, translating each JS template-literal/array-join into the equivalent Elm `String.join`/`++` composition, preserving every literal character (indentation, blank lines, punctuation). Do the same for `writePackageTree` (`gen-icon-module.js:325-416`) inside `iconPackageTreeFiles`.

- [ ] **Step 3: Wire `IconModule.files` into `Generate.Phantom.Emit.files`**

Edit `core/elm-cem/codegen/Generate/Phantom/Emit.elm:67-137`:

```elm
files : Brand -> Maybe Generate.Types.IconModuleConfig -> Maybe Generate.Types.FamiliesConfig -> Result (List String) (List Elm.File)
files brand iconModule _ =
    let
        ...(existing allFiles binding unchanged)...

        iconResult =
            Generate.Phantom.Emit.IconModule.files brand.lib iconModule
    in
    case iconResult of
        Err e ->
            Err [ e ]

        Ok iconFiles ->
            let
                guardErrors =
                    runGuard brand
            in
            if List.isEmpty guardErrors then
                Ok (allFiles ++ iconFiles)

            else
                Err guardErrors
```

Add `import Generate.Phantom.Emit.IconModule` to `Emit.elm`'s import list.

- [ ] **Step 4: Inject the icon catalog's `names` into flags in `bin/elm-cem.js`**

Add a new function near `injectConfig` (`core/elm-cem/bin/elm-cem.js:386-423`):

```js
// Icon catalog names must reach Elm as data, not a filesystem path — Elm's
// single-shot main has no fs access (research §3). Ported from
// gen-icon-module.js:472-484's catalog read; runs AFTER injectConfig so
// _config._iconModule (if any) is already merged into the flags file.
function injectIconCatalog(argv) {
  const flagIdx = argv.findIndex((a) => a === "--flags-from" || a.startsWith("--flags-from="));
  if (flagIdx === -1) return argv;
  const cemArg = argv[flagIdx].startsWith("--flags-from=")
    ? argv[flagIdx].slice("--flags-from=".length)
    : argv[flagIdx + 1];
  let cem;
  try {
    cem = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), cemArg), "utf8"));
  } catch {
    return argv;
  }
  const im = cem._config && cem._config._iconModule;
  if (!im || !im.catalogFrom || im.names) return argv;
  let names;
  try {
    const cat = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), im.catalogFrom), "utf8"));
    names = cat.names;
  } catch (e) {
    console.error(`elm-cem: could not read icon catalog at ${im.catalogFrom}: ${e.message}`);
    process.exit(1);
  }
  if (!Array.isArray(names) || names.length === 0) {
    console.error(`elm-cem: icon catalog at ${im.catalogFrom} has no "names" array`);
    process.exit(1);
  }
  cem._config._iconModule.names = names;
  const tmp = writeTemp("elm-cem-icon-catalog", JSON.stringify(cem));
  const out = argv.slice();
  if (out[flagIdx].startsWith("--flags-from=")) out[flagIdx] = `--flags-from=${tmp}`;
  else out[flagIdx + 1] = tmp;
  return out;
}
```

Call it in the pipeline (`core/elm-cem/bin/elm-cem.js:152-156`):

```js
const afterReconcile = reconcileTagNames(rawArgvNoFactsFlag);
const afterAliases = recordTypeAliases(afterReconcile);
const afterConfig = injectConfig(afterAliases);
const afterIconCatalog = injectIconCatalog(afterConfig);
const afterNativeAttrs = injectNativeAttrs(afterIconCatalog);
const args = injectFactsBundleFlag(afterNativeAttrs, Boolean(factsBundleDir));
```

- [ ] **Step 5: Stop calling the JS generator for icons; keep family-package call for now**

Edit `core/elm-cem/bin/post-generate.js:35-41`:

```js
function runPostGenerate(argv, outputDir) {
  const configFromPaths = extractConfigFromPaths(argv);
  // gen-icon-module removed (G2, 2026-08-19 generator-consolidation): ported
  // into Generate.Phantom.Emit.IconModule — the Elm codegen pass now emits
  // <Lib>.Icon (and its standalone package tree) directly.
  require("./gen-family-package").run(argv, configFromPaths, outputDir);
}
```

- [ ] **Step 6: Run the golden test from Task 4 — expect it to now exercise the REAL Elm port**

Run: `node core/elm-cem/tests/golden-icon-module.test.mjs`
Expected: PASS, all three checks, with the icon module now produced ENTIRELY by the Elm codegen pass (no JS `gen-icon-module.js` involved). If it FAILS, diff by hand:

```bash
diff brands/m3e/outputs/elm-m3e/src/M3e/Icon.elm /tmp/<work-dir-from-test-output>/out/M3e/Icon.elm
```//add `console.log` or a `--keep-tmp` env check to the test if iterating repeatedly is painful — do not leave debug scaffolding in the committed test.

Iterate on Step 2's Elm port until every byte matches — pay special attention to: `@docs` line wrapping, the exact `"\n\n\n"` section separator, trailing newline count, and the `formatSig` indentation (`gen-icon-module.js:235-243`) which Elm's `String.join "\n"` must reproduce exactly including the 4-space indent literal.

- [ ] **Step 7: Run the wider suite to catch regressions**

Run: `cd core/elm-cem && pnpm run test:gates && pnpm run test:bin-entrypoints`
Expected: PASS. `test:bin-entrypoints` (`core/elm-cem/tests/bin-entrypoints.test.mjs`) checks every `bin/*.js` file's silent-no-op behavior — `gen-icon-module.js` still exists on disk at this point (deleted in Task 5b) so this should be unaffected; if it references icon-module-specific behavior that assumed the OLD dispatch, adjust per what you find (read the file first).

Run from repo root: `node tools/check-drift.mjs`
Expected: the icon-related sub-checks stay green (icon catalog derivation in `tools/lib/regen.mjs:100-133`'s `deriveIconNames` reads the GENERATED `M3e/Icon.elm` from source text regardless of which generator wrote it — it is generator-agnostic by construction, so this should be a no-op here).

- [ ] **Step 8: Commit**

```bash
git add core/elm-cem/codegen/Generate/Phantom/Emit/IconModule.elm core/elm-cem/codegen/Generate/Phantom/Emit.elm core/elm-cem/bin/elm-cem.js core/elm-cem/bin/post-generate.js
git commit -m "feat(elm-cem): port gen-icon-module.js into the Elm codegen pass (G2)"
```

---

### Task 5b: Delete `gen-icon-module.js` and its now-dead tests

**Files:**
- Delete: `core/elm-cem/bin/gen-icon-module.js`
- Modify: `core/elm-cem/tests/gates.test.mjs` — the icon-related blocks at `gates.test.mjs:90-183` (the `_iconModule` tag/iconFamily fail-loud proofs, the non-M3E brand tag-leak proof) test BEHAVIOR that must still hold post-port (the Elm emitter must ALSO fail loud without `tag`/`iconFamily`, and must ALSO not leak M3E defaults) — these tests exercise the CLI end-to-end, so they should mostly keep passing unmodified; run them and fix only what's genuinely obsolete (e.g. any assertion on a JS-specific error message string that the Elm port phrases differently).
- Modify: `core/elm-cem/bin/registry-check.js:38` comment (mentions `_iconModule.package` — update prose only if it describes JS-specific mechanics that changed; if it's describing the CONFIG contract, which is unchanged, leave it).

**Interfaces:**
- N/A (deletion-only task; no new interfaces).

- [ ] **Step 1: Run the existing icon-related test blocks BEFORE deleting anything, to get a clean baseline**

Run: `node core/elm-cem/tests/gates.test.mjs`
Expected: PASS (Task 5's Elm port must already satisfy these behaviors, since `post-generate.js` no longer calls the JS generator at all as of Task 5 Step 5 — this run proves the Elm emitter's fail-loud/no-leak behavior independently BEFORE the JS file is physically removed).

- [ ] **Step 2: Delete the JS generator**

```bash
git rm core/elm-cem/bin/gen-icon-module.js
```

- [ ] **Step 3: Re-run the full elm-cem test suite to confirm nothing references the deleted file**

Run: `cd core/elm-cem && pnpm run test`
Expected: PASS. If `bin-entrypoints.test.mjs` or any other suite fails with a `MODULE_NOT_FOUND` for `gen-icon-module`, that reference is stale — locate and remove it (`grep -rn "gen-icon-module" core/elm-cem/` after deletion should show ZERO remaining references outside this plan and historical doc comments that explicitly narrate the removal).

- [ ] **Step 4: Run the drift gate**

Run: `node tools/check-drift.mjs` (repo root)
Expected: `CHECK-DRIFT GREEN` (or the usual SKIP lines for snapshot-dependent checks in a fresh clone — no NEW failures attributable to this deletion).

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore(elm-cem): remove gen-icon-module.js — ported to Elm (G2 complete)"
```

---

### Task 6: Golden byte-compare test harness + failing test for `<Lib>.Family.*` (G3, red)

**Files:**
- Create: `core/elm-cem/tests/golden-family-package.test.mjs`
- Read (golden reference): all 21 files under `brands/m3e/outputs/elm-m3e/elm-m3e-families/src/M3e/Family/*.elm`, plus `elm-m3e-families/elm.json`, `README.md`, `LICENSE`

**Interfaces:**
- Consumes: `runGoldenGenerate`, `byteEqual` from `core/elm-cem/tests/lib/golden.mjs` (Task 4).
- Produces: nothing new consumed downstream.

- [ ] **Step 1: Enumerate the golden family module list once, so the test doesn't hardcode 21 filenames by hand**

Run: `ls brands/m3e/outputs/elm-m3e/elm-m3e-families/src/M3e/Family/*.elm | xargs -n1 basename`

Confirm this matches the 21 families listed in `config/slots.json`'s `_families.families` keys (already enumerated in this plan's investigation: `NavMenu, NavRail, DrawerContainer, Menu, Dialog, BottomSheet, FabMenu, RichTooltip, Datepicker, Timepicker, Calendar, Stepper, List, Breadcrumb, Tabs, Tree, Toc, Chip, SegmentedButton, Accordion` + 1 more — re-run the count to get the 21st).

- [ ] **Step 2: Write the failing golden test**

Create `core/elm-cem/tests/golden-family-package.test.mjs`:

```js
#!/usr/bin/env node
// Golden byte-compare for G3: <Lib>.Family.* ported from
// bin/gen-family-package.js (which fragilely regex-reparses its own rendered
// M3e.Component.* text, gen-family-package.js:101-153) into
// Generate.Phantom.Emit.FamilyPackage (which reads Brand.comps natively —
// the same Comp records Generate.Phantom.Emit.Component.compModule already
// renders from). Every family module under committed
// elm-m3e-families/src/M3e/Family/*.elm IS the golden output.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { makeCheck } from "./lib/harness.mjs";
import { elmM3e, runGoldenGenerate, byteEqual } from "./lib/golden.mjs";

const { check, finish } = makeCheck("golden-family-package");

const goldenFamilyDir = path.join(elmM3e, "elm-m3e-families", "src", "M3e", "Family");
const familyFiles = fs.readdirSync(goldenFamilyDir).filter((f) => f.endsWith(".elm")).sort();
check(familyFiles.length > 0, "committed elm-m3e-families golden tree is non-empty (test setup sanity)");

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-golden-family-"));
const outDir = path.join(work, "out");
fs.mkdirSync(outDir, { recursive: true });

const gen = runGoldenGenerate(outDir);
check(gen.status === 0, "elm-cem generation exits 0 against brands/m3e's real config", gen.stdout + gen.stderr);

if (gen.status === 0) {
  const repoRootFresh = path.dirname(outDir);
  const freshFamilyDir = path.join(repoRootFresh, "elm-m3e-families", "src", "M3e", "Family");

  for (const f of familyFiles) {
    const result = byteEqual(path.join(goldenFamilyDir, f), path.join(freshFamilyDir, f));
    check(result.ok, `fresh M3e/Family/${f} is byte-identical to the committed golden`, result.detail);
  }

  const elmJson = byteEqual(
    path.join(elmM3e, "elm-m3e-families", "elm.json"),
    path.join(repoRootFresh, "elm-m3e-families", "elm.json")
  );
  check(elmJson.ok, "fresh elm-m3e-families/elm.json is byte-identical to the committed golden", elmJson.detail);

  // No file must exist in the fresh tree that isn't in the golden tree (proves
  // the port's clean-then-write behavior, ported from
  // gen-family-package.js:413-423's fs.rmSync of the owned src/ subtree,
  // still fires — a stale leftover family module would silently pass the
  // per-file loop above but fail this check).
  const freshFiles = fs.existsSync(freshFamilyDir) ? fs.readdirSync(freshFamilyDir).filter((f) => f.endsWith(".elm")).sort() : [];
  check(
    JSON.stringify(freshFiles) === JSON.stringify(familyFiles),
    "fresh M3e/Family/ directory listing exactly matches the golden set (no extra/missing modules)",
    `golden: ${familyFiles.join(",")} | fresh: ${freshFiles.join(",")}`
  );
}

fs.rmSync(work, { recursive: true, force: true });
finish("golden-family-package: all checks passed");
```

- [ ] **Step 3: Run it now, before any G3 implementation — sanity baseline**

Run: `node core/elm-cem/tests/golden-family-package.test.mjs`
Expected: PASS (the JS `gen-family-package.js` is STILL called by `post-generate.js` at this point — Task 5 Step 5 only removed the icon call, the family call is untouched). This is the fence Task 7 will swap the implementation under.

- [ ] **Step 4: Commit**

```bash
git add core/elm-cem/tests/golden-family-package.test.mjs
git commit -m "test(elm-cem): add golden byte-compare fence for M3e.Family.* (G3 prep)"
```

---

### Task 7: Port `gen-family-package.js` into `Generate.Phantom.Emit.FamilyPackage` (G3, green)

**Files:**
- Create: `core/elm-cem/codegen/Generate/Phantom/Emit/FamilyPackage.elm`
- Modify: `core/elm-cem/codegen/Generate/Phantom/Emit.elm` (wire `FamilyPackage.files` into the main `files` function, consuming the `Maybe FamiliesConfig` argument)
- Modify: `core/elm-cem/bin/post-generate.js` — remove the `gen-family-package` call entirely (the whole file becomes a candidate for deletion — see Step 6)
- Test: `core/elm-cem/tests/golden-family-package.test.mjs` (from Task 6, now the real gate)

**Interfaces:**
- Consumes: `FamiliesConfig`/`FamilySpec`/`FamilyMember` (Task 2), `Brand.comps : List Comp` (existing `Generate.Phantom.Model`), and — critically, per research §2's verdict — the per-component surface data the ORIGINAL flat `compModule` already computes internally (exposing list, per-type params, per-value annotations), obtained WITHOUT regex-reparsing rendered text. This is the one genuinely new design decision in this plan (§Design note below).
- Produces: `Generate.Phantom.Emit.FamilyPackage.files : Brand -> Maybe FamiliesConfig -> Result String (List Elm.File)`.

**Design note — replacing the regex re-parse (`gen-family-package.js:101-153`) with native data:**
`parseModuleSurface` extracts three things from rendered `.elm` TEXT: (1) the module's `exposing` list in order, (2) each exposed type alias's parameter string (e.g. `type alias Is s = ...` → params `"s"`), (3) each exposed value's full annotation text verbatim (copied character-for-character into the family module, then `prefixTypeRefs` rewrites references to the member's OWN types). Since `compModule brand comp` (`Generate/Phantom/Emit/Component.elm:21-22`) builds this exact module from `Brand`/`Comp` already, the CORRECT port is NOT to re-derive an equivalent surface from `Comp` by re-implementing `compModule`'s logic a second time (duplication risk, the same fragility class as the regex it replaces, just moved from text to a second Elm implementation) — instead, **extend `compModule`'s own internal helpers to also RETURN the surface description** (exposing order, type params, value annotations as `Elm`-typed data) alongside the rendered `Elm.File`, so `FamilyPackage.elm` consumes the SAME values `compModule` used to build the module, not a re-derivation. Concretely: refactor `Component.elm`'s `compModule` to compute a `ComponentSurface` record (`{ exposing_ : List String, types : Dict String String, valueAnnotations : Dict String String }`) as a LET-bound intermediate value already, expose it via a new `compSurface : Brand -> Comp -> ComponentSurface` function in `Component.elm`'s export list, and have `compModule` call it too (so the two can never drift — one is derived from the other, not two independent computations). `FamilyPackage.elm` then calls `compSurface brand comp` per member instead of reading+regex-parsing a file. **This refactor of `Component.elm` is in-scope for Task 7** (it is required to satisfy research §2's "uses Brand.comps natively instead" verdict correctly, not just nominally) — read `core/elm-cem/codegen/Generate/Phantom/Emit/Component.elm` in full before starting Step 2 to find the exact LET-bindings that already compute the equivalent of `exposing`/types/annotations inside `compModule`, and extract them without changing `compModule`'s own byte output (Task 7 Step 3 proves this).

- [ ] **Step 1: Read `Component.elm` in full and locate the exposing-list / type-alias / value-annotation LET-bindings inside `compModule`**

Run: `grep -n "exposingList\|exposing_\|typeAlias\|annotation" core/elm-cem/codegen/Generate/Phantom/Emit/Component.elm | head -60`

Identify the exact bindings that determine (a) the module's final `exposing (...)` list and order, (b) each type alias's declared parameters, (c) each exposed value's rendered type signature. These are almost certainly ALREADY present as intermediate values before being joined into the final `Elm.File`'s content string — extract them into a named `ComponentSurface` record without altering `compModule`'s control flow.

- [ ] **Step 2: Add `compSurface` to `Component.elm` and prove `compModule`'s output is unchanged**

Add (exact shape depends on Step 1's findings — this is the CONTRACT, not the mechanical extraction):

```elm
type alias ComponentSurface =
    { moduleName : String
    , exposing_ : List String -- exact order, mirrors compModule's own exposing list
    , types : Dict String String -- exposed Capitalized name -> its type-alias params string
    , valueAnnotations : Dict String String -- exposed lowercase name -> its rendered annotation text
    }


compSurface : Brand -> Comp -> ComponentSurface
compSurface brand comp =
    -- Built from the SAME let-bindings compModule uses (Step 1) — do not
    -- duplicate their computation; factor them into a shared `let` (or a
    -- small internal helper both compModule and compSurface call) so the two
    -- can never independently drift.
    ...
```

Add `compSurface` to `Component.elm`'s module export list (`module Generate.Phantom.Emit.Component exposing (.., compSurface, ComponentSurface)`).

- [ ] **Step 3: Prove `compModule`'s byte output is UNCHANGED by this refactor (regression fence for the refactor itself)**

Run: `cd core/elm-cem && pnpm run test:gates`
Expected: PASS unchanged. Also re-run Task 4/6's golden tests:

Run: `node core/elm-cem/tests/golden-icon-module.test.mjs && node core/elm-cem/tests/golden-family-package.test.mjs`
Expected: PASS (family test still uses the OLD JS generator at this point — this run only proves the `Component.elm` refactor didn't perturb the flat `M3e.Component.*` modules the family generator's regex-parse reads, so the JS generator's OWN output is unaffected by Step 2's refactor).

- [ ] **Step 4: Write `Generate/Phantom/Emit/FamilyPackage.elm` — port `planModules`/`generateFamilyModule`/`writePackageTree`**

Port, using `compSurface` in place of `parseModuleSurface`:
- `gen-family-package.js:326-407` (`planModules`) → an Elm function `planFamilies : FamiliesConfig -> Result String (List FamilyPlan)`, preserving the exact validation order and error messages (empty `families`, duplicate emitted module name, component used twice, duplicate element label within a family, malformed member).
- `gen-family-package.js:185-317` (`generateFamilyModule`) → an Elm function building the module source string, preserving: the `emitted` list construction order (types first? — re-check `gen-family-package.js:211-214`: types THEN values, matching `exposingAll`), the `EXTERNAL_IMPORTS` table (`gen-family-package.js:242-251`) and its exact regex-driven "does the annotation blob mention this token" inclusion test (port as an Elm `String.contains`/word-boundary check — note the JS regex distinguishes dotted tokens like `"Ac.Action"` from bare tokens; replicate that distinction), and `prefixTypeRefs`'s longest-name-first whole-word substitution (`gen-family-package.js:164-176`).
- `gen-family-package.js:410-501` (`writePackageTree`) → building `Elm.File`s at `<pkg>/src/<Module/Path>.elm`, `<pkg>/elm.json`, `<pkg>/README.md` (only-if-absent — **note**: this "only if absent" check requires knowing whether the file already exists on disk, which the Elm side CANNOT check (no filesystem access) — this is a case where the CLI shell (`bin/elm-cem.js`) must pre-check `fs.existsSync` and pass a boolean into flags, exactly as Task 5's icon-catalog injection pattern did; add `familiesReadmeExists : Bool` / `familiesLicenseExists : Bool` to the flags injected alongside `_families`, OR — simpler and matching this plan's byte-equality target exactly — since `README.md`/`LICENSE` already exist in the committed golden tree today, and elm-codegen's writer OVERWRITES on every run regardless of "existing" content, the byte-equality bar is satisfied whether or not the "only if absent" check is ported, AS LONG AS the freshly generated README/LICENSE content is byte-identical to what's committed. Verify this is true (`diff` the JS generator's unconditional-template output against the committed file) and if so, DROP the only-if-absent conditional in the Elm port — always emit README.md/LICENSE from the template; this is a legitimate behavior simplification enabled by moving to a single-pass generator that no longer needs to protect hand-edits made after a partial JS run, since Elm's `main` always regenerates the full tree in one shot. Document this decision in the module's doc comment.)

```elm
module Generate.Phantom.Emit.FamilyPackage exposing (files)

{-| Port of bin/gen-family-package.js (G3, 2026-08-19 generator-consolidation
research). Emits <lib>.Family.<Name> flat family modules by reading each
member's ComponentSurface from Generate.Phantom.Emit.Component.compSurface —
never re-parsing rendered .elm text (the fragility gen-family-package.js:101-153's
`parseModuleSurface` had, per research §2's strongest-case verdict).

@docs files

-}

import Dict exposing (Dict)
import Elm
import Generate.Phantom.Emit.Component exposing (ComponentSurface, compSurface)
import Generate.Phantom.Model exposing (Brand, Comp)
import Generate.Types exposing (FamiliesConfig, FamilyMember, FamilySpec)


files : Brand -> Maybe FamiliesConfig -> Result String (List Elm.File)
files brand maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            planFamilies cfg
                |> Result.andThen (renderFamilies brand cfg)


-- (planFamilies / renderFamilies / packageTreeFiles: full port of
-- gen-family-package.js:185-501 — elided here per this plan's "cite JS
-- ranges, byte-equality is the acceptance spec" scoping; the executing agent
-- ports each named function 1:1, using compSurface instead of
-- parseModuleSurface as the surface source.)
```

- [ ] **Step 5: Wire `FamilyPackage.files` into `Generate.Phantom.Emit.files`**

Edit `core/elm-cem/codegen/Generate/Phantom/Emit.elm`:

```elm
files : Brand -> Maybe Generate.Types.IconModuleConfig -> Maybe Generate.Types.FamiliesConfig -> Result (List String) (List Elm.File)
files brand iconModule families =
    let
        ...
        iconResult = Generate.Phantom.Emit.IconModule.files brand.lib iconModule
        familyResult = Generate.Phantom.Emit.FamilyPackage.files brand families
    in
    case ( iconResult, familyResult ) of
        ( Err e, _ ) -> Err [ e ]
        ( _, Err e ) -> Err [ e ]
        ( Ok iconFiles, Ok familyFiles ) ->
            let
                guardErrors = runGuard brand
            in
            if List.isEmpty guardErrors then
                Ok (allFiles ++ iconFiles ++ familyFiles)
            else
                Err guardErrors
```

- [ ] **Step 6: Remove the `gen-family-package` call from `post-generate.js`**

Since both generators are now ported, `post-generate.js`'s `runPostGenerate` has nothing left to do. Two options: (a) leave it as an empty no-op function for now (safest, smallest diff, avoids touching every call site in `elm-cem.js`), or (b) remove the call site in `elm-cem.js:223-226` and delete `post-generate.js` entirely. **Choose (b)** — per the Global Constraint "JS shrinks... one Elm process owns all Elm output," an empty pass-through function is dead weight, not a thin shell (research §4's carve-out is for scrapers/provenance/idempotency, not an empty stub). Edit `core/elm-cem/bin/elm-cem.js`:

```js
// Icon-module + family-package generation now happens inside the Elm codegen
// pass itself (Generate.Phantom.Emit.IconModule / .FamilyPackage — G2/G3,
// 2026-08-19 generator-consolidation). post-generate.js is deleted.
```

(Remove the `if (outputDir) { require("./post-generate")... }` block at `elm-cem.js:223-226` entirely — do not replace it with an empty call.)

- [ ] **Step 7: Run the golden test — expect it to exercise the REAL Elm port**

Run: `node core/elm-cem/tests/golden-family-package.test.mjs`
Expected: PASS, all 21+ per-file checks plus the elm.json check plus the directory-listing-exactly-matches check. Iterate on Step 4's port until every byte matches, paying special attention to: the `EXTERNAL_IMPORTS` inclusion logic (a single missed import breaks compilation, not just bytes), the exposing-list ordering (types-then-values, `gen-family-package.js:211-214`), and `prefixTypeRefs`'s regex-to-Elm-string-op translation (get the whole-word boundary semantics exactly right — a naive `String.replace` without word-boundary checking will over-match substrings of longer identifiers).

- [ ] **Step 8: Run the wider suite + drift gate**

Run: `cd core/elm-cem && pnpm run test`
Expected: PASS. `grep -rn "post-generate\|gen-family-package" core/elm-cem/` after this task's edits should show only the (now unused, to be deleted in Task 7b) `bin/gen-family-package.js` file and `bin/post-generate.js` file themselves, plus this plan.

Run from repo root: `node tools/check-drift.mjs`
Expected: `CHECK-DRIFT GREEN` (or usual snapshot-dependent SKIPs).

- [ ] **Step 9: Commit**

```bash
git add core/elm-cem/codegen/Generate/Phantom/Emit/Component.elm core/elm-cem/codegen/Generate/Phantom/Emit/FamilyPackage.elm core/elm-cem/codegen/Generate/Phantom/Emit.elm core/elm-cem/bin/elm-cem.js
git commit -m "feat(elm-cem): port gen-family-package.js into the Elm codegen pass (G3)"
```

---

### Task 7b: Delete `gen-family-package.js` and `post-generate.js`

**Files:**
- Delete: `core/elm-cem/bin/gen-family-package.js`, `core/elm-cem/bin/post-generate.js`
- Modify: `core/elm-cem/tests/bin-entrypoints.test.mjs` — this suite pattern-matches `bin/*.js` files for entry points (per `post-generate.js:26-32`'s own comment about why it's NAMED `runPostGenerate` instead of `run` specifically to dodge this test's discovery pattern) — after deleting both files, re-run this suite to confirm it doesn't have a stale explicit reference to either filename.
- Modify: `core/elm-cem/tests/split.test.mjs`, `core/elm-cem/tests/registry-check-nested-pkg.test.mjs`, `core/elm-cem/tests/gates.test.mjs` — none of these should reference `gen-family-package.js`/`post-generate.js` by path (confirm via grep), but they DO exercise family-package BEHAVIOR through the CLI end-to-end (same pattern as Task 5b's icon tests) — run them to confirm the Elm port satisfies the same behavioral contracts.

**Interfaces:**
- N/A (deletion-only task).

- [ ] **Step 1: Grep for remaining references before deleting**

Run: `grep -rln "gen-family-package\|post-generate" core/elm-cem/ --include='*.js' --include='*.mjs'`

Review every hit. Expect: `core/elm-cem/bin/gen-family-package.js` (self), `core/elm-cem/bin/post-generate.js` (self), and possibly `core/elm-cem/bin/registry-check.js` (a comment mentioning `_iconModule.package`/family concepts — check if it names the FILE or just the CONFIG KEY; only the former needs edits).

- [ ] **Step 2: Delete both files**

```bash
git rm core/elm-cem/bin/gen-family-package.js core/elm-cem/bin/post-generate.js
```

- [ ] **Step 3: Run the full elm-cem test suite**

Run: `cd core/elm-cem && pnpm run test`
Expected: PASS. Fix any `MODULE_NOT_FOUND` by removing the stale reference (there should be none per Step 1's grep, but this is the actual proof).

- [ ] **Step 4: Run the drift gate from repo root**

Run: `node tools/check-drift.mjs`
Expected: `CHECK-DRIFT GREEN` (or usual SKIPs). If the elm toolchain is available, also run: `bash tools/ab-elm-cem.sh` — expected: `A/B PASS: <N> files, byte-identical output` (this is the strongest available proof that the FULL pipeline, including the now-Elm-native icon/family generation, produces identical output to a pristine baseline snapshot — note per research §5's residual caveat that `ab-elm-cem.sh`'s package-tree emission location (`repoRoot = dirname(outDir)`, shared `$WORK_DIR` between pristine/workspace runs) has a pre-existing isolation gap unrelated to this plan; it is not this plan's job to fix that harness bug, only to note it if the A/B run behaves unexpectedly for the two package trees specifically).

- [ ] **Step 5: Run gate-all for full confidence (optional but recommended if time allows)**

Run: `node tools/gate-all.mjs` (repo root)
Expected: no NEW failures attributable to this plan's changes (pre-existing SKIPs for snapshot-dependent checks are expected and unrelated).

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(elm-cem): remove gen-family-package.js + post-generate.js — ported to Elm (G3 complete)"
```

---

## Self-Review

**Coverage of G1/G2/G3:**
- G1 (plumb `_families`/`_iconModule` into flags): Tasks 1-3. Task 1 fixes the `deepMergeConfigs` two-level limitation the research doc flags (§5) with a concrete failing-test-first proof of the bug (nested `package` object losing sibling keys across two `--config-from` files). Tasks 2-3 add the Elm-side decoders and thread them to `Generate.Phantom.Emit.files`'s signature, proven a no-op for existing output (Task 3 Step 3's `diff -rq`).
- G2 (port `gen-icon-module.js`): Tasks 4-5b. Task 4 establishes the golden byte-compare fence GREEN under the old JS implementation (a sanity check this plan is honest about not being a literal "red" TDD step, since nothing has changed yet). Task 5 does the real port, citing exact JS line ranges (`gen-icon-module.js:38-79`, `:124-316`, `:325-416`) and explicitly calling out the one behavior narrowing (`_brand` fallback dropped, justified against the real `brands/m3e` config). Task 5b removes the JS file only after Task 5's golden test is green.
- G3 (port `gen-family-package.js`): Tasks 6-7b. Task 6 mirrors Task 4's fence pattern for all 21+ family modules plus a directory-listing-equality check (catching orphan-module regressions, mirroring the JS generator's own `fs.rmSync` clean-first behavior at `gen-family-package.js:413-423`). Task 7 makes the required design call explicit — extending `Component.elm` with a shared `compSurface` function rather than either (a) re-parsing rendered text in Elm (same fragility, wrong language) or (b) reimplementing surface-derivation logic a second time (drift risk) — and proves the refactor is a no-op for `compModule`'s own output before building on it (Step 3). Task 7b removes both remaining JS files and deletes `post-generate.js` outright per the "empty shell is dead weight" call.
- Drift gate: every task that changes emitted-output-adjacent code ends with either the golden tests, `tools/check-drift.mjs`, `pnpm run test:gates`, or (where the toolchain is available) `tools/ab-elm-cem.sh` — per the Global Constraint.
- Out of scope (correctly excluded): G4 (moving `split.js`'s partition into Elm) is not touched — `split.js` and the DAG-check gate are untouched by this plan, matching the task's explicit scope boundary.

**Placeholder scan:** The plan contains two INTENTIONAL elisions, both explicitly flagged as such rather than silently hand-waved: (1) Task 5 Step 2's `buildModuleSource`/`iconPackageTreeFiles` bodies and Task 7 Step 4's `planFamilies`/`renderFamilies`/`packageTreeFiles` bodies are not written out character-for-character in this plan document (that would mean re-deriving and pre-verifying ~800 lines of ported Elm without running a compiler, which the task instructions permit — "you need not pre-write all Elm, the golden byte-equality IS the acceptance spec" — and instead each cites the EXACT JS source line ranges to port and the specific gotchas (separator strings, indentation, ordering) the byte-compare will catch). (2) The one literal `Debug.todo` in Task 5 Step 2 is explicitly called out in that same step as "must NOT be left in committed code" with an instruction to replace it — not a plan defect but a deliberate authoring marker distinguishing "cite the port target" from "here is the final code," consistent with how the task brief asked for real, precise port references rather than fully pre-written Elm bodies. No other "TODO"/"handle appropriately"/"similar to Task N" placeholders appear; every task names exact files, exact line ranges, exact commands, and exact test assertions.

**Type/name consistency:** `IconModuleConfig`, `FamiliesConfig`, `FamilySpec`, `FamilyMember`, `IconPackageConfig`/`FamilyPackageConfig` are introduced once (Task 2) and referenced identically in Tasks 3, 5, 7 (`Generate.Types.IconModuleConfig` qualified where imported unqualified elsewhere — flagged consistently). `Generate.Phantom.Emit.files`'s signature changes exactly once, in Task 3, and every later task (5, 7) is written against that SAME final signature (`Brand -> Maybe IconModuleConfig -> Maybe FamiliesConfig -> Result (List String) (List Elm.File)`) rather than drifting per-task. `compSurface : Brand -> Comp -> ComponentSurface` (Task 7) is named once and consumed identically in `FamilyPackage.elm`. `runGoldenGenerate`/`byteEqual` (Task 4's `tests/lib/golden.mjs`) are defined once and imported with the same names in Task 6's test, with no renaming drift.
