# Value ↔ Primitive Codegen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Emit `toString`, `<enum>FromString`, and `<enum>Values` into the generated `<Lib>.Values` module so application code can round-trip an opaque `Value` through a `String` without importing `HtmlIr`.

**Architecture:** One purely-additive change to `valuesModule` in `codegen/Generate/Phantom/Emit.elm`. `toString` is a single re-export of the already-existing `HtmlIr.Value.toString`. The two per-union emissions iterate `brand.unions` (`List EnumSpec`), casing on each token's **wire string** (`tokenValueOf`) rather than its Elm identifier, deduped by wire string.

**Tech Stack:** Elm (elm-codegen host, `codegen/` is compiled Elm), Node test harness (`tests/phantom/gate.mjs` golden + acid probes, `tests/*.test.mjs` behavioural gates), `elm-test-rs`.

**Spec:** `specs/2026-08-05-value-primitives-codegen-design.md`

## Global Constraints

- Purely additive. No existing declaration changes shape or name. No consumer may break.
- `Value` stays opaque. Do not expose its constructor; do not add anything to `HtmlIr.Internal`'s fence.
- Per-union emissions case on **`tokenValueOf brand t`** (the wire string), never `tokenIdentResolved brand t` (the Elm identifier). They differ under a config `attrTypes` MAP override (`{"always": "true"}` mints `always = Ir.token "true"`).
- Per-union emissions **dedup by wire string** after `List.sort`. Two distinct tokens in one union may share a wire string; they evaluate to the same `Value`, so the winner is unobservable but must be deterministic.
- New identifiers go into **both** `exposeBlock` and `docsBlock`, and through `guardValuesModule`'s collision detection, and into `enumPortmanteaus`' `taken` set.
- K6 holds: when `brand.unions` is empty the whole `Values` module is omitted. New emissions live inside that existing conditional.
- Both downstream repos (`elm-m3e`, `elm-typed-html`) have a `check:drift` gate that fails until regenerated. Regen is Task 5, in this same change set.

---

### Task 1: `toString` re-export

**Files:**
- Modify: `codegen/Generate/Phantom/Emit.elm` — `valuesModule` (`:4095`)
- Test: `tests/phantom/acid/src/Good.elm`
- Golden: `tests/phantom/expected/Mini/Values.elm` (regenerated, not hand-edited)

**Interfaces:**
- Consumes: nothing.
- Produces: `<Lib>.Values.toString : Value tags -> String`. Task 2 and Task 3 rely on it existing in the exposing list ahead of the union aliases.

- [ ] **Step 1: Write the failing acid probe**

Append to `tests/phantom/acid/src/Good.elm`. This is a compile probe — it must typecheck against the emitted `Mini.Values`.

```elm
{-| Spec A: the out-bound direction is reachable without importing HtmlIr.Value.
-}
valueRoundTripOut : String
valueRoundTripOut =
    Mini.Values.toString Mini.Values.ltr
```

Check the file's existing import style first: if it imports `Mini.Values exposing (..)` or aliases it, match that rather than adding a duplicate import.

- [ ] **Step 2: Run the gate to verify it fails**

Run: `node tests/phantom/gate.mjs`
Expected: FAIL with `[mini] acid Good does not compile` and an Elm error naming `toString` as not exposed by `Mini.Values`.

- [ ] **Step 3: Implement the re-export**

In `valuesModule`, the module header list currently ends with the `Value` alias declaration. Add `toString` to the exposing and docs groups, and emit the declaration.

Change both group lists (they must stay in sync — `exposeBlock` and `docsBlock` are fed the same structure):

```elm
                  , exposeBlock
                        [ [ "Value" ]
                        , [ "toString" ]
                        , brand.unions |> List.map .aliasName |> List.sort
                        , tokens |> List.map (tokenIdentResolved brand)
                        , portmanteaus |> List.map .name
                        ]
```

and the matching `docsBlock` call, then append after the `Value` alias declaration:

```elm
                  , ""
                  , ""
                  , doc "The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly."
                  , "toString : Value tags -> String"
                  , "toString ="
                  , "    HtmlIr.Value.toString"
```

`import HtmlIr.Value` is already emitted, so no import change is needed.

- [ ] **Step 4: Run the gate; expect golden mismatch, then bless**

Run: `node tests/phantom/gate.mjs`
Expected: acid Good now compiles; FAIL on golden mismatch for `Mini/Values.elm`, `TypedHtml/Values.elm`, `Hz/Values.elm`.

Run: `npm run bless`

Then **read the golden diff** (`git diff tests/phantom/expected`) and confirm it contains only the `toString` addition in the exposing block, the `@docs` block, and one new declaration per suite. Anything else is a bug — do not proceed past an unexplained golden change.

- [ ] **Step 5: Run the full gate**

Run: `npm run test:phantom`
Expected: PASS, all suites.

- [ ] **Step 6: Commit**

```bash
git add codegen/Generate/Phantom/Emit.elm tests/phantom/acid/src/Good.elm tests/phantom/expected
git commit -m "Re-export toString from the generated Values module"
```

---

### Task 2: Per-union `<enum>FromString`

**Files:**
- Modify: `codegen/Generate/Phantom/Emit.elm` — `valuesModule` (`:4095`)
- Test: `tests/phantom/acid/src/Good.elm`, `tests/phantom/acid/bad/FromStringWrongRow.elm` (create)
- Golden: `tests/phantom/expected/**/Values.elm` (blessed)

**Interfaces:**
- Consumes: Task 1's exposing-group structure.
- Produces: `<elmName>FromString : String -> Maybe (Value <AliasName>)` per `EnumSpec`. For the `mini` fixture that is `dirFromString`, `sizeFromString`, `variantFromString`. Task 3 adds `<elmName>Values` beside these and shares the dedup helper built here.

- [ ] **Step 1: Write the failing positive acid probe**

Append to `tests/phantom/acid/src/Good.elm`:

```elm
{-| Spec A: the in-bound direction returns the CLOSED union row, so it feeds a
setter that admits exactly that enum.
-}
valueRoundTripIn : Maybe (Mini.Values.Value Mini.Values.Dir)
valueRoundTripIn =
    Mini.Values.dirFromString "ltr"
```

- [ ] **Step 2: Write the failing negative acid probe**

Create `tests/phantom/acid/bad/FromStringWrongRow.elm`. This must **fail** to compile — it proves the returned row is genuinely closed to `Dir` and cannot be smuggled into a `Variant` slot.

```elm
module FromStringWrongRow exposing (bad)

{-| `dirFromString` returns `Maybe (Value Dir)`. `Dir` has no `filled` field, so
this must NOT unify with a `Variant` annotation. If it compiles, `fromString` is
handing back an open row and the closure is a lie.
-}

import Mini.Values


bad : Maybe (Mini.Values.Value Mini.Values.Variant)
bad =
    Mini.Values.dirFromString "ltr"
```

- [ ] **Step 3: Run the gate to verify both fail correctly**

Run: `node tests/phantom/gate.mjs`
Expected: FAIL with `[mini] acid Good does not compile` (naming `dirFromString`). The `bad/` probe also "passes" trivially at this point because it fails for the wrong reason — that is expected until Step 5, when it must still fail.

- [ ] **Step 4: Implement `fromString`**

Add inside `valuesModule`'s `let`, beside the existing `tokenDecl` / `unionDecl` helpers. `unionTokens` is the shared, deduped, wire-string-keyed token list that Task 3 will also use.

```elm
        -- The union's tokens paired with the string they actually write, deduped
        -- on that WIRE STRING. Two distinct tokens in one union may render the
        -- same string (an `attrTypes` MAP override permits it: `tokenValues`
        -- guards token→one-string, not string→one-token). They evaluate to the
        -- SAME `Ir.token`, so keeping one is lossless — but keeping both would
        -- emit a duplicate `case` branch and a duplicate list entry. Sort first
        -- so the survivor is deterministic.
        unionTokens e =
            e.tokens
                |> List.sort
                |> List.foldl
                    (\t acc ->
                        let
                            wire =
                                tokenValueOf brand t
                        in
                        if List.any (\( _, w ) -> w == wire) acc then
                            acc

                        else
                            acc ++ [ ( tokenIdentResolved brand t, wire ) ]
                    )
                    []

        fromStringDecl e =
            [ ""
            , ""
            , doc
                ("Parse a `"
                    ++ e.elmName
                    ++ "` value from the string it writes to the DOM. The inverse of `toString`."
                )
            , e.elmName ++ "FromString : String -> Maybe (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "FromString s ="
            , "    case s of"
            ]
                ++ List.concatMap
                    (\( ident, wire ) ->
                        [ "        \"" ++ wire ++ "\" ->"
                        , "            Just " ++ ident
                        , ""
                        ]
                    )
                    (unionTokens e)
                ++ [ "        _ ->"
                   , "            Nothing"
                   ]
```

Wire it into the emitted body beside `unionDecl`, and into both group lists:

```elm
                , brand.unions |> List.sortBy .aliasName |> List.concatMap unionDecl
                , brand.unions |> List.sortBy .aliasName |> List.concatMap fromStringDecl
```

```elm
                        , brand.unions |> List.map (\e -> e.elmName ++ "FromString") |> List.sort
```

added as a group to **both** `exposeBlock` and `docsBlock`, positioned after the union aliases group.

- [ ] **Step 5: Run the gate; bless; verify the negative probe still fails**

Run: `node tests/phantom/gate.mjs`
Expected: golden mismatch. Run `npm run bless`, read `git diff tests/phantom/expected`, confirm each `Values.elm` gained exactly one `fromString` per union and that the `case` branches use wire strings.

Run: `node tests/phantom/gate.mjs`
Expected: PASS — including `[mini] acid bad/FromStringWrongRow.elm rejected`. If that probe now *compiles*, the emitted row is open and the implementation is wrong.

- [ ] **Step 6: Commit**

```bash
git add codegen/Generate/Phantom/Emit.elm tests/phantom/acid tests/phantom/expected
git commit -m "Emit per-union fromString on the generated Values module"
```

---

### Task 3: Per-union `<enum>Values`

**Files:**
- Modify: `codegen/Generate/Phantom/Emit.elm` — `valuesModule` (`:4095`)
- Test: `tests/phantom/acid/src/Good.elm`
- Golden: `tests/phantom/expected/**/Values.elm` (blessed)

**Interfaces:**
- Consumes: `unionTokens` from Task 2 — the same deduped wire-string-keyed list.
- Produces: `<elmName>Values : List (Value <AliasName>)` per `EnumSpec`. Spec B's consumer uses this as a coverage gate for its settings controls.

- [ ] **Step 1: Write the failing acid probe**

Append to `tests/phantom/acid/src/Good.elm`:

```elm
{-| Spec A: the enumeration, so a UI built from an enum cannot silently miss a
value added to the manifest.
-}
valueEnumeration : List (Mini.Values.Value Mini.Values.Dir)
valueEnumeration =
    Mini.Values.dirValues
```

- [ ] **Step 2: Run the gate to verify it fails**

Run: `node tests/phantom/gate.mjs`
Expected: FAIL, `[mini] acid Good does not compile`, naming `dirValues`.

- [ ] **Step 3: Implement `values`**

Add beside `fromStringDecl`:

```elm
        valuesDecl e =
            [ ""
            , ""
            , doc
                ("Every `"
                    ++ e.elmName
                    ++ "` value. Map a UI over this and adding a value to the manifest cannot silently miss it."
                )
            , e.elmName ++ "Values : List (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "Values ="
            , "    [ " ++ (unionTokens e |> List.map Tuple.first |> String.join ", ") ++ " ]"
            ]
```

Wire into the body and into both group lists:

```elm
                , brand.unions |> List.sortBy .aliasName |> List.concatMap valuesDecl
```

```elm
                        , brand.unions |> List.map (\e -> e.elmName ++ "Values") |> List.sort
```

Merge this into the same group as the `FromString` names so the exposing block gets one round-trip-helpers group rather than two:

```elm
                        , (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                            ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                            |> List.sort
```

Apply the identical change to `docsBlock`.

- [ ] **Step 4: Feed the new names to the portmanteau `taken` set**

`enumPortmanteaus` drops any portmanteau whose name is already claimed. Without this, an enum could mint a portmanteau that shadows `<enum>Values`.

```elm
        portmanteaus =
            enumPortmanteaus brand
                ((brand.unions |> List.map .aliasName)
                    ++ (tokens |> List.map (tokenIdentResolved brand))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                    ++ [ "toString" ]
                )
```

- [ ] **Step 5: Run the gate; bless; verify**

Run: `node tests/phantom/gate.mjs`, then `npm run bless`, then read `git diff tests/phantom/expected`.
Expected diff: one `<enum>Values` declaration per union, list entries in sorted-token order, no duplicates.

Run: `node tests/phantom/gate.mjs`
Expected: PASS, all suites.

- [ ] **Step 6: Commit**

```bash
git add codegen/Generate/Phantom/Emit.elm tests/phantom/acid tests/phantom/expected
git commit -m "Emit per-union values list on the generated Values module"
```

---

### Task 4: Pin the wire-string and dedup behaviour

**Files:**
- Create: `tests/from-string.test.mjs`
- Modify: `package.json` (add `test:from-string` to the scripts so `run-p "test:*"` picks it up)
- Modify: `tests/phantom/fixtures/` — add a map-override + shared-wire-string enum to an existing fixture config, or create `from-string-config.json` + reuse `mini.cem.json`

**Interfaces:**
- Consumes: `<enum>FromString` and `<enum>Values` from Tasks 2 and 3.
- Produces: nothing consumed downstream. This is the regression gate for the spec's central correctness claim.

Model this file on `tests/enum-override.test.mjs` — same imports, same generate-into-tmpdir-then-assert-on-emitted-text-then-compile shape. Read that file first; it already pins the map-override half of this behaviour and its header documents exactly this class of silent failure.

- [ ] **Step 1: Write the fixture config with both hazards**

Create `tests/phantom/fixtures/from-string-config.json`. Two enums on the same brand:

```json
{
  "attrTypes": {
    "presence": { "always": "true", "never": "false" },
    "fallback": { "always": "true", "yes": "true", "off": "false" }
  }
}
```

- `presence` is the MAP form where ident ≠ wire string — `alwaysFromString` must case on `"true"`, not `"always"`.
- `fallback` has **two** tokens (`always`, `yes`) sharing the wire string `"true"` — the dedup path.

Point it at whichever fixture CEM declares those attributes; if none does, add them to a copy of `mini.cem.json` as `from-string.cem.json`. Follow the shape of `attr-conflict.cem.json` for a minimal single-purpose CEM.

- [ ] **Step 2: Write the failing test**

```js
#!/usr/bin/env node
// `fromString` wire-string + dedup gate.
//
// `fromString` must case on the string the token WRITES, not its Elm identifier.
// They differ under an `attrTypes` MAP override: `{"always": "true"}` mints
// `always = Ir.token "true"`. Casing on the identifier makes `fromString`
// disagree with `toString` for exactly those tokens, silently and in one
// direction only.
//
// And two DISTINCT tokens in one union may share a wire string. `tokenValues`
// (Model.elm) guards token -> one string; `guardValuesModule` guards two raw
// tokens -> one identifier. NEITHER guards string -> one token, so the map form
// permits `{"always": "true", "yes": "true"}`. Both mint `Ir.token "true"` —
// the same `Value` — so dropping one is lossless, but emitting both produces a
// duplicate `case` branch and a duplicated `<enum>Values` entry.

import assert from "node:assert/strict";
// … generate into a tmpdir exactly as tests/enum-override.test.mjs does …

const values = fs.readFileSync(path.join(out, "Fx", "Values.elm"), "utf8");

// MAP form: the case branch is the WIRE string, and the identifier is preserved.
assert.match(values, /presenceFromString : String -> Maybe \(Value Presence\)/);
assert.match(values, /"true" ->\n\s+Just always/);
assert.doesNotMatch(values, /"always" ->/, "cased on the identifier, not the wire string");

// DEDUP: one branch per wire string, not one per token.
const trueBranches = (values.match(/"true" ->/g) || []).length;
assert.equal(trueBranches, 2, "expected exactly one 'true' branch per union (presence, fallback)");

// DEDUP: the values list carries no duplicate entry.
const fallbackList = values.match(/fallbackValues =\n\s+\[ ([^\]]*)\]/)[1];
const entries = fallbackList.split(",").map((s) => s.trim());
assert.equal(new Set(entries).size, entries.length, `duplicate entry in fallbackValues: ${fallbackList}`);

// ROUND TRIP: every wire string in every `values` list parses back.
// Compile a probe module that asserts it at the type level, then `elm make` it,
// following the compile step in tests/enum-override.test.mjs.
```

- [ ] **Step 3: Run it to verify it fails**

Run: `node tests/from-string.test.mjs`
Expected: FAIL. If Tasks 2–3 were implemented correctly it should already pass the wire-string assertions and the dedup assertions; if it fails, the implementation has the bug this gate exists to catch — fix `unionTokens`, not the test.

- [ ] **Step 4: Wire into `npm test`**

In `package.json` scripts:

```json
"test:from-string": "node tests/from-string.test.mjs",
```

`"test": "run-p \"test:*\""` picks it up automatically.

- [ ] **Step 5: Run the whole suite**

Run: `npm test`
Expected: PASS, including `test:from-string`, `test:phantom`, `test:enum-override`.

- [ ] **Step 6: Commit**

```bash
git add tests/from-string.test.mjs tests/phantom/fixtures package.json
git commit -m "Gate fromString wire-string casing and shared-wire-string dedup"
```

---

### Task 5: Regenerate both downstream consumers

**Files:**
- Modify (generated): `../elm-m3e/src/M3e/Values.elm`
- Modify (generated): `../elm-typed-html/src/TypedHtml/Values.elm`

**Interfaces:**
- Consumes: the emitter from Tasks 1–3.
- Produces: `M3e.Values.toString` / `schemeFromString` / `schemeValues` / `contrastFromString` / `contrastValues`, and `TypedHtml.Values.toString` / `dirFromString` / `dirValues`. Spec B consumes these directly.

Both repos gate on generated-output drift, so they fail until regenerated. Do this in the same change set.

- [ ] **Step 1: Regenerate elm-m3e**

```bash
cd ../elm-m3e && npm run gen:src
```

- [ ] **Step 2: Verify the new surface landed**

```bash
cd ../elm-m3e && rg -n "^toString|^schemeFromString|^schemeValues|^contrastFromString|^contrastValues" src/M3e/Values.elm
```

Expected: five matches. `schemeValues` should read `[ auto, dark, light ]` and `schemeFromString` should case on `"auto"` / `"dark"` / `"light"`.

- [ ] **Step 3: Confirm elm-m3e's own gate is green**

```bash
cd ../elm-m3e && npm run check:drift && npm run check:cem
```

Expected: PASS. `check:format` is handled by `gen:src`'s own `format:src` step.

- [ ] **Step 4: Regenerate elm-typed-html**

```bash
cd ../elm-typed-html && npm run gen && npm run check:drift
```

Expected: PASS; `src/TypedHtml/Values.elm` gains `toString`, `dirFromString`, `dirValues`.

- [ ] **Step 5: Commit each repo separately**

```bash
cd ../elm-m3e && git add src/M3e && git commit -m "Regenerate src for Values round-trip primitives"
cd ../elm-typed-html && git add src/TypedHtml && git commit -m "Regenerate src for Values round-trip primitives"
```

- [ ] **Step 6: Full gate in elm-cem**

Run: `cd ../elm-cem && npm run gate`
Expected: PASS.

---

## Self-Review

**Spec coverage.** `toString` re-export → Task 1. `<enum>FromString` → Task 2. `<enum>Values` → Task 3. Wire-string + dedup correctness → implemented in Task 2's `unionTokens`, gated in Task 4. Exposing/docs blocks → Tasks 1–3. Portmanteau `taken` set → Task 3 Step 4. Collision guard → covered by the existing `guardValuesModule`, which reads the exposing groups; the spec's dedicated collision fixture is folded into Task 4's fixture work rather than given its own task, since it shares the same harness. Downstream regen → Task 5. K6 empty-unions case → constraint, already structural (the new code is inside `valuesModule`, which is only called when unions exist; the `barren` fixture covers it and its golden must not change).

**Type consistency.** `unionTokens` returns `List ( String, String )` as `( ident, wire )` and is used that way in both Task 2 (`\( ident, wire ) ->`) and Task 3 (`List.map Tuple.first`). `EnumSpec` fields used — `elmName`, `aliasName`, `tokens` — match `Model.elm:207`. `tokenValueOf : Brand -> String -> String` and `tokenIdentResolved brand t` match their definitions at `Emit.elm:1353` and `:1329`.

**Open risk to surface at execution.** Task 4's fixture may need a new CEM rather than a config-only addition, depending on whether an existing fixture declares two attributes that can carry these overrides. That is a discovery step, not a placeholder — the fallback (copy `mini.cem.json`) is specified.
