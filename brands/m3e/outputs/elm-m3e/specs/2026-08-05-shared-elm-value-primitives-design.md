# Spec B — Retire the shadow vocabulary in docs `Shared.elm`

Date: 2026-08-05
Repo: `elm-m3e`
Status: approved design, not yet planned
Depends on: Spec A (`elm-cem/specs/2026-08-05-value-primitives-codegen-design.md`)

## Problem

`docs/app/Shared.elm` carries a shadow copy of vocabulary the generator already owns:

- Three local unions — `Scheme` (`Auto | Light | Dark`), `Contrast`
  (`Standard | Medium | High`), `Direction` (`Ltr | Rtl`).
- Three adapters that exist only to map them back onto tokens — `schemeAttr`,
  `contrastAttr`, `directionAttr`.
- A hand-written `schemeToString` / `schemeFromString` pair for `localStorage`.

Every one of these exists because a `Value` could not round-trip through a `String`. Adding
a value to the CEM does not add it here; the two vocabularies drift silently.

## Design

With Spec A landed and `npm run gen:src` re-run, the model holds generated tokens directly.

### Model and Msg

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

`Msg` must carry the **token**, not the row:

```elm
| SetScheme (Value.Value Value.Scheme)
| SetContrast (Value.Value Value.Contrast)
| SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
```

`Value.Scheme` alone is the phantom row *record* (`{ auto : Supported, … }`), not a value —
writing `SetScheme Value.Scheme` is a type error.

### Deletions

- `type Scheme`, `type Contrast`, `type Direction`
- `schemeAttr`, `contrastAttr`, `directionAttr`
- `schemeToString`, `schemeFromString`

`M3e.Theme.scheme model.scheme` and `M3e.Theme.contrast model.contrast` now take the model
field directly — their signatures are already `Value Scheme -> Attr …` and
`Value Contrast -> Attr …`. `TypedHtml.Attributes.dir model.dir` likewise.

### Persistence

`schemeToString scheme` → `Value.toString scheme` (feeding `Ports.storeScheme`).
`schemeFromString` → the generated `Value.schemeFromString`, used unchanged in
`schemeFromFlags`:

```elm
Decode.decodeValue (Decode.field "scheme" Decode.string) raw
    |> Result.toMaybe
    |> Maybe.andThen Value.schemeFromString
    |> Maybe.withDefault Value.auto
```

Behaviour is preserved exactly: the persisted strings were already `"auto"` / `"light"` /
`"dark"`, which are the tokens' wire strings, so existing `localStorage` values keep
working with no migration.

### Segmented controls, and why they do NOT just map over `<enum>Values`

The naive move is `List.map … Value.schemeValues`. Two things break:

1. **Order.** `schemeValues` is alphabetical (`auto, dark, light`). The existing control is
   deliberately `Light, System, Dark` — the neutral option sits in the middle. Mapping the
   generated list reorders the UI.
2. **Labels.** `auto` displays as "System". That is editorial and not derivable from the
   manifest.

An earlier draft of this spec proposed an explicit ordered `List ( Value, String )` plus an
`elm-test` permutation assertion against `<enum>Values`. That is worse, and the reason is
worth recording: there is **no Elm test runner wired for the docs app**. `tests/elm.json`'s
source directories are `../src` and the two substrate packages — not `docs/app` — and the
docs' only Elm test (`docs/tests/FoldTest.elm`) runs through a bespoke `Platform.worker`
runner (`docs/scripts/run-elm-worker-test.cjs`). A permutation test would mean standing up a whole
test harness to protect three lists, or falling back to text-parsing Elm from a `.mjs` check,
which is brittle.

**Instead, make coverage structural.** Render the control *from* `<enum>Values`, so coverage
holds by construction and cannot drift:

```elm
schemeSegmented : Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
schemeSegmented model =
    segmented
        (Value.schemeValues
            |> List.sortBy schemeOrder
            |> List.map (\v -> ( schemeLabel v, model.scheme == v, SetScheme v ))
        )


{-| Display order — the neutral option sits between the two poles. An unrecognised
value sorts last rather than disappearing.
-}
schemeOrder : Value.Value Value.Scheme -> Int
schemeOrder v =
    case Value.toString v of
        "light" -> 0
        "auto" -> 1
        "dark" -> 2
        _ -> 3


{-| Editorial labels. `auto` reads as "System"; anything the manifest gains that we
have not named yet falls back to its wire string, so a new value shows up VISIBLY
mislabelled rather than silently missing.
-}
schemeLabel : Value.Value Value.Scheme -> String
schemeLabel v =
    case Value.toString v of
        "auto" -> "System"
        other -> capitalize other
```

This is strictly better than a test: coverage cannot drift because the list *is* the source,
order and wording stay editorial, and a new CEM value degrades to a visible raw label instead
of a missing control. No new test harness.

`contrastSegmented` follows the same shape. Its labels happen to match capitalized wire
strings (`standard`/`medium`/`high`), so it needs only `contrastOrder` and `capitalize`.

**Direction needs a documented exclusion.** `TypedHtml.Values.Dir` has three values
(`auto, ltr, rtl`); the control offers only `ltr`/`rtl`. Filter explicitly, with the reason
in the code, so the omission is legible and a *fourth* value still appears automatically:

```elm
directionSegmented : Model -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
directionSegmented model =
    segmented
        (TypedHtml.Values.dirValues
            -- `auto` defers to the document/OS, which is what the shell already does
            -- when this control is untouched — offering it as a third button would be
            -- an option that visibly does nothing. LTR/RTL are the demonstrable ones.
            |> List.filter (\v -> TypedHtml.Values.toString v /= "auto")
            |> List.map (\v -> ( String.toUpper (TypedHtml.Values.toString v), model.dir == v, SetDirection v ))
        )
```

### Equality

`model.scheme == Value.light` compiles and behaves correctly, but the comparison is on the
opaque token's underlying string. Two tokens from *different* enums that share a wire
string therefore compare equal. Harmless for these controls, since each is compared only
against its own enum's tokens. Worth a code comment, not a workaround — there is no `Eq`
constraint to lean on, and introducing one is out of scope.

## Explicitly out of scope

The **view restructure** — collapsing the `themed` helper and hoisting
`grid h-dvh grid-rows-[auto_1fr] overflow-hidden` plus `dir` onto `m3e-theme` itself —
rides along in the same working diff but is an unrelated change with a different risk
profile. It deletes the `<div>` that owns the single scroll region, which this file's own
comments identify as what keeps the mobile URL bar from collapsing. It is specified
separately in `specs/2026-08-05-theme-host-view-restructure-design.md` and must not be
bundled into this change.

## Verification

- `npm run gen:src` produces a `src/M3e/Values.elm` containing `toString`,
  `schemeFromString`, `schemeValues`, `contrastFromString`, `contrastValues`;
  `check:drift` green.
- `elm-make` clean; `check:format`, `check:review` green.
- Coverage is structural (controls render from `<enum>Values`), so there is nothing to
  assert in a test — instead confirm by inspection that no control hand-lists tokens:
  `rg -n 'Value\.(light|dark|auto|standard|medium|high)' docs/app/Shared.elm` should match
  only `init`'s defaults and the label/order functions, never a segmented-control list.
- Manual: toggle each of scheme / contrast / direction in the settings drawer; reload and
  confirm the scheme persisted. Confirm a pre-existing `localStorage` `scheme` value from
  before the change still restores.
- `npm run test:browser` green (the docs browser suite exercises the shell).
