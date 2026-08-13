# Shared.elm Value Primitives Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete the shadow vocabulary in `docs/app/Shared.elm` — three local unions and three adapter functions — by holding generated `Value` tokens in the model directly.

**Architecture:** The model's `scheme`, `contrast` and `dir` fields become `Value` tokens. Persistence uses the generated `toString` / `schemeFromString`. The settings controls render *from* the generated `<enum>Values` lists, so coverage of the enum holds by construction rather than by a hand-maintained list.

**Tech Stack:** Elm 0.19, elm-pages 3.5, `elm-review`, `elm-format`, Playwright (`npm run test:browser`).

**Spec:** `specs/2026-08-05-shared-elm-value-primitives-design.md`

## Global Constraints

- **Blocked on elm-cem Plan Task 5.** `src/M3e/Values.elm` and `src/TypedHtml/Values.elm` must already expose `toString`, `schemeFromString`, `schemeValues`, `contrastFromString`, `contrastValues`, `dirFromString`, `dirValues`. Verify with `rg -n "^toString|^schemeValues" src/M3e/Values.elm` before starting.
- **Do not touch `view`.** The view restructure is a separate plan (`plans/2026-08-05-theme-host-view-restructure.md`) and must land *after* this one. Both change `view`; running them together makes a layout regression look like a type-refactor bug.
- `Msg` payloads carry the **token**, not the row: `SetScheme (Value.Value Value.Scheme)`. `Value.Scheme` alone is the phantom row *record* (`{ auto : Supported, … }`) and is a type error in that position.
- Persisted `localStorage` strings must keep working with no migration. They are already `"auto"` / `"light"` / `"dark"`, which are the tokens' wire strings.
- No control may hand-list tokens. Every segmented control renders from `<enum>Values`.
- There is **no Elm test runner for `docs/app`**. Do not invent one; verification is compile + `elm-review` + browser suite + inspection.

---

### Task 1: Model, Msg, and the token-typed fields

**Files:**
- Modify: `docs/app/Shared.elm` — `type alias Model` (`:69`), `type Msg` (`:108`), `init` (`:121`), `update` (`:230-245`)

**Interfaces:**
- Consumes: `M3e.Values` (aliased `Value` in this file) exposing `Value`, `Scheme`, `Contrast`, `auto`, `standard`, `toString`, `schemeFromString`; `TypedHtml.Values` exposing `Value`, `Dir`, `ltr`, `toString`, `dirValues`.
- Produces: `Model.scheme : Value.Value Value.Scheme`, `Model.contrast : Value.Value Value.Contrast`, `Model.dir : TypedHtml.Values.Value TypedHtml.Values.Dir`. Tasks 2 and 3 read these.

- [ ] **Step 1: Confirm the generated surface exists**

```bash
rg -n "^toString|^schemeFromString|^schemeValues|^contrastFromString|^contrastValues" src/M3e/Values.elm
rg -n "^toString|^dirFromString|^dirValues" src/TypedHtml/Values.elm
```

Expected: five matches in the first, three in the second. If any are missing, **stop** — the elm-cem plan has not landed and this plan cannot proceed.

- [ ] **Step 2: Retype the model fields**

Replace the `Model` alias:

```elm
type alias Model =
    { showMenu : Bool
    , viewportWidth : Int
    , scheme : Value.Value Value.Scheme
    , seed : String
    , contrast : Value.Value Value.Contrast
    , density : Float
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , settingsOpen : Bool
    }
```

- [ ] **Step 3: Retype the Msg payloads**

In `type Msg`, replace the three constructors:

```elm
    | SetScheme (Value.Value Value.Scheme)
    | SetSeed String
    | SetContrast (Value.Value Value.Contrast)
    | SetDensity Float
    | SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
```

The parentheses matter. `SetScheme Value.Value Value.Scheme` is two arguments; `SetScheme Value.Scheme` is the row record.

- [ ] **Step 4: Retype `init`'s defaults**

In `init`'s record:

```elm
      , contrast = Value.standard
      , density = 0
      , dir = TypedHtml.Values.ltr
```

`scheme = schemeFromFlags flags` is unchanged at the call site; its signature changes in Task 2.

- [ ] **Step 5: Update the persistence branch of `update`**

```elm
        SetScheme scheme ->
            ( { model | scheme = scheme }
            , Effect.fromCmd (Ports.storeScheme (Value.toString scheme))
            )
```

`SetContrast`, `SetDensity` and `SetDirection` branches need no change — they only assign.

- [ ] **Step 6: Compile and expect failures only in the places Tasks 2–3 will fix**

Run: `npm --prefix docs run build:site 2>&1 | head -40`
Expected: FAIL, with errors confined to `schemeFromFlags`, `schemeToString`, `schemeFromString`, `schemeAttr`, `contrastAttr`, `directionAttr`, and the three `*Segmented` functions. Errors anywhere else mean a field or constructor was missed.

- [ ] **Step 7: Do not commit yet**

This task leaves the file uncompilable by design; Tasks 2 and 3 close it. Commit at the end of Task 3.

---

### Task 2: Persistence via generated `toString` / `fromString`

**Files:**
- Modify: `docs/app/Shared.elm` — `schemeFromFlags` (`:165`), delete `schemeToString` (`:178`), delete `schemeFromString` (`:191`)

**Interfaces:**
- Consumes: `Model` from Task 1; `Value.toString`, `Value.schemeFromString`, `Value.auto`.
- Produces: `schemeFromFlags : Pages.Flags.Flags -> Value.Value Value.Scheme`. Nothing else consumes it beyond `init`.

- [ ] **Step 1: Retype `schemeFromFlags` and swap in the generated parser**

```elm
{-| The initial color scheme: the value persisted in `localStorage` (passed by
`index.ts` as `flags.scheme`), else **auto** — follow the OS light/dark setting.

The string↔token conversion is generated (`M3e.Values.schemeFromString`), so the
persisted strings and the DOM attribute values cannot drift apart.
-}
schemeFromFlags : Pages.Flags.Flags -> Value.Value Value.Scheme
schemeFromFlags flags =
    case flags of
        Pages.Flags.BrowserFlags raw ->
            Decode.decodeValue (Decode.field "scheme" Decode.string) raw
                |> Result.toMaybe
                |> Maybe.andThen Value.schemeFromString
                |> Maybe.withDefault Value.auto

        Pages.Flags.PreRenderFlags ->
            Value.auto
```

- [ ] **Step 2: Delete the hand-written converters**

Delete the whole `schemeToString` declaration (signature, body, doc comment) and the whole `schemeFromString` declaration. Both are now supplied by the generated module — `schemeFromString` in particular would *shadow* the generated one if `M3e.Values` were imported unqualified, so leaving it is not harmless.

- [ ] **Step 3: Verify the wire strings are unchanged**

```bash
rg -n "schemeFromString" src/M3e/Values.elm -A 14
```

Expected: `case s of` branches on `"auto"`, `"dark"`, `"light"` — the same three strings the deleted function used, so existing `localStorage` values still restore. If they differ, **stop**: the persisted format changed and this needs a migration, which is out of this plan's scope.

- [ ] **Step 4: Do not commit yet**

Task 3 finishes the compile.

---

### Task 3: Controls rendered from the generated value lists

**Files:**
- Modify: `docs/app/Shared.elm` — delete `schemeAttr` (`:278`), `contrastAttr` (`:291`), `directionAttr` (`:354`), `type Scheme`, `type Contrast`, `type Direction`; rewrite `schemeSegmented` (`:515`), `contrastSegmented` (`:523`), `directionSegmented` (`:582`)

**Interfaces:**
- Consumes: `Model` from Task 1; `Value.schemeValues`, `Value.contrastValues`, `TypedHtml.Values.dirValues`, `Value.toString`, `TypedHtml.Values.toString`.
- Produces: `capitalize : String -> String`, `schemeOrder`, `schemeLabel`, `contrastOrder`. Nothing outside this file consumes them.

- [ ] **Step 1: Delete the three local unions and the three adapters**

Delete these declarations entirely, including their doc comments:

- `type Scheme = Auto | Light | Dark`
- `type Contrast = Standard | Medium | High`
- `type Direction = Ltr | Rtl`
- `schemeAttr : Scheme -> M3e.Attr { c | scheme : M3e.Kind.Supported } msg`
- `contrastAttr : Contrast -> M3e.Attr { c | contrast : M3e.Kind.Supported } msg`
- `directionAttr : Direction -> TypedHtml.Values.Value TypedHtml.Values.Dir`

The `view` function currently calls `schemeAttr model.scheme` / `contrastAttr model.contrast` / `directionAttr model.dir`. Replace those three call sites — and **only** those three — with the field directly:

```elm
                , M3e.Theme.scheme model.scheme
                , M3e.Theme.contrast model.contrast
```

and

```elm
                    , TypedHtml.Attributes.dir model.dir
```

`M3e.Theme.scheme` is already `Value Scheme -> Attr { c | scheme : Supported } msg` (`src/M3e/Theme.elm:135`) and `M3e.Theme.contrast` is already `Value Contrast -> …` (`:121`), so the adapters were pure indirection. Leave the surrounding `view` structure alone.

- [ ] **Step 2: Add the shared label helper**

```elm
{-| Upper-case the first character. Enum wire strings are lower-case; the settings
controls display them title-cased.
-}
capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s
```

Add `import Char` if the file does not already have it.

- [ ] **Step 3: Rewrite `schemeSegmented` to render from the generated list**

```elm
schemeSegmented : Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
schemeSegmented model =
    segmented
        (Value.schemeValues
            |> List.sortBy schemeOrder
            |> List.map (\v -> ( schemeLabel v, model.scheme == v, SetScheme v ))
        )


{-| Display order — the neutral option sits between the two poles, which is why this
is not the generated list's alphabetical order. A value we have not placed sorts last
rather than disappearing.
-}
schemeOrder : Value.Value Value.Scheme -> Int
schemeOrder v =
    case Value.toString v of
        "light" ->
            0

        "auto" ->
            1

        "dark" ->
            2

        _ ->
            3


{-| Editorial labels: `auto` reads as "System". Anything the manifest gains that we
have not named falls back to its wire string, so a new value shows up VISIBLY
mislabelled rather than silently missing from the drawer.
-}
schemeLabel : Value.Value Value.Scheme -> String
schemeLabel v =
    case Value.toString v of
        "auto" ->
            "System"

        other ->
            capitalize other
```

- [ ] **Step 4: Rewrite `contrastSegmented`**

Its three labels are exactly the capitalized wire strings, so it needs no label function.

```elm
contrastSegmented : Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
contrastSegmented model =
    segmented
        (Value.contrastValues
            |> List.sortBy contrastOrder
            |> List.map (\v -> ( capitalize (Value.toString v), model.contrast == v, SetContrast v ))
        )


{-| Display order — ascending intensity, which alphabetical order does not give.
-}
contrastOrder : Value.Value Value.Contrast -> Int
contrastOrder v =
    case Value.toString v of
        "standard" ->
            0

        "medium" ->
            1

        "high" ->
            2

        _ ->
            3
```

- [ ] **Step 5: Rewrite `directionSegmented` with its documented exclusion**

```elm
directionSegmented : Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
directionSegmented model =
    segmented
        (TypedHtml.Values.dirValues
            -- `dir` admits auto|ltr|rtl. `auto` defers to the document/OS, which is
            -- already what the shell does when this control is untouched, so offering
            -- it would be a button that visibly does nothing. Filtered explicitly
            -- rather than hand-listing ltr/rtl, so a FOURTH value would still appear.
            |> List.filter (\v -> TypedHtml.Values.toString v /= "auto")
            |> List.map
                (\v ->
                    ( String.toUpper (TypedHtml.Values.toString v)
                    , model.dir == v
                    , SetDirection v
                    )
                )
        )
```

- [ ] **Step 6: Add the equality note**

Above `schemeSegmented`, record why `==` is acceptable here:

```elm
{-| These controls compare tokens with `==`. A `Value` is opaque over a `String`, so
the comparison is on the underlying wire string — meaning tokens from DIFFERENT enums
that share a string would compare equal. Safe here because each control only ever
compares a field against its own enum's values.
-}
```

- [ ] **Step 7: Compile**

Run: `npm --prefix docs run build:site`
Expected: PASS. Any remaining error naming `Scheme`, `Contrast`, `Direction`, `Auto`, `Light`, `Dark`, `Ltr` or `Rtl` means a reference to a deleted type survived.

- [ ] **Step 8: Format, review, and confirm nothing hand-lists tokens**

```bash
npm run check:format
npm --prefix docs run check:review
rg -n 'Value\.(light|dark|auto|standard|medium|high)' docs/app/Shared.elm
```

Expected: first two PASS. The `rg` should match **only** `init`'s defaults (`Value.standard`), `schemeFromFlags`' `Value.auto` fallback, and the `schemeOrder`/`schemeLabel`/`contrastOrder` string cases — never a segmented-control list.

- [ ] **Step 9: Browser suite**

Run: `npm run test:browser`
Expected: PASS.

- [ ] **Step 10: Manual check of the settings drawer**

```bash
npm run dev
```

Confirm, in the settings drawer: scheme shows **Light / System / Dark in that order** and each applies; contrast shows **Standard / Medium / High** and each applies; direction shows **LTR / RTL** and flips the shell. Then set a non-default scheme, **reload**, and confirm it persisted. Finally, in devtools set `localStorage.scheme = "dark"` by hand, reload, and confirm it restores — this is the backwards-compatibility check.

- [ ] **Step 11: Commit**

```bash
git add docs/app/Shared.elm
git commit -m "Hold generated Value tokens in Shared, retiring the shadow vocabulary"
```

---

## Self-Review

**Spec coverage.** Model/Msg retyping → Task 1. `schemeToString`/`schemeFromString` deletion and generated replacements → Task 2. Local union + adapter deletion → Task 3 Step 1. Controls rendered from `<enum>Values` with editorial order/labels → Task 3 Steps 3–5. Direction exclusion → Task 3 Step 5. Equality note → Task 3 Step 6. Persistence backwards-compatibility → Task 2 Step 3 (static) and Task 3 Step 10 (runtime). View restructure exclusion → Global Constraints.

**Placeholder scan.** No TBDs. Every code step carries the actual Elm. Task 3 Step 1's `view` edit is specified as three named call-site substitutions with the target signatures quoted, not "update view accordingly".

**Type consistency.** `Value.Value Value.Scheme` used identically in `Model`, `Msg`, `schemeFromFlags`, `schemeOrder`, `schemeLabel`. `capitalize : String -> String` is defined in Step 2 before its uses in Steps 3–4. `schemeOrder`/`contrastOrder` both return `Int` for `List.sortBy`. `segmented`'s existing signature is `List ( String, Bool, Msg ) -> Element …`, and all three rewrites produce exactly that triple.

**Known deviation from the spec, deliberate.** The spec's `capitalize` is referenced but not defined there; this plan defines it in Task 3 Step 2. Task 1 intentionally leaves the file uncompilable across two task boundaries rather than splitting into artificially compilable slices — a retype of this shape cannot be made incremental without temporary adapter functions that Task 3 would then delete. Commits happen once at the end of Task 3.
