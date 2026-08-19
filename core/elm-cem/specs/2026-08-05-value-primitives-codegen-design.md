# Spec A — `Value` ↔ primitive in the generated `<Lib>.Values`

Date: 2026-08-05
Repo: `elm-cem`
Status: approved design, not yet planned

## Problem

A `Value tags` is opaque (`HtmlIr.Internal`: `type Value tags = Value String`). Application
code that must persist or restore an enum value — a colour scheme in `localStorage`, a
`dir` from a flag, a query param — has no supported way to cross the boundary.

The consumer that surfaced this is `elm-m3e`'s docs `Shared.elm`, which held three local
unions (`Scheme`, `Contrast`, `Direction`) purely as a shadow vocabulary, plus three
adapter functions mapping them onto tokens, plus a hand-written `schemeToString` /
`schemeFromString` pair. All of that exists only because the generated vocabulary cannot
round-trip through a `String`.

An author who tries the obvious thing writes:

```elm
case scheme of
    Value.auto -> "auto"
```

which cannot work and never will: `Value` is opaque and `Value.auto` is a value, not a
constructor. Pattern matching is permanently unavailable. This spec provides the three
operations that *are* expressible.

## Non-goal

Making `Value` pattern-matchable, or exposing its constructor. The opacity is the point:
minting a `Value` asserts its phantom row, so it stays fenced to the generator and to
`HtmlIr.Internal`.

## What already exists

`HtmlIr.Value.toString : Value tags -> String` is already implemented and is already
described in its own docs as "the safe out-bound direction". The emitter already calls it
(`Emit.elm:3888`, `:5463`, `:5517`). It is simply never re-exported from `<Lib>.Values`,
so reaching it from application code requires importing `HtmlIr` directly — which the
`<Lib>.Values` docs explicitly promise you never have to do:

> `Value` is re-exported here so annotating a token never requires an `HtmlIr.Value` import.

So the out-bound direction is a missing re-export, not a missing capability. The in-bound
direction genuinely does not exist, and the generator is the only honest place for it:
only the generator knows a union's closed token set, so only it can produce
`String -> Maybe (Value Scheme)` without a row-asserting escape in userland.

## Design

One site: `codegen/Generate/Phantom/Emit.elm` → `valuesModule` (`:4095`). Three additions.

### 1. Generic `toString` re-export

```elm
toString : Value tags -> String
toString =
    HtmlIr.Value.toString
```

One declaration per brand, not one per union. The row is irrelevant to the operation, so
38 per-union `<enum>ToString` wrappers would be 38 ways to spell one function. Callers
write `Value.toString model.scheme`.

### 2. Per-union `<elmName>FromString`

For each `EnumSpec` in `brand.unions`:

```elm
schemeFromString : String -> Maybe (Value Scheme)
schemeFromString s =
    case s of
        "auto" ->
            Just auto

        "dark" ->
            Just dark

        "light" ->
            Just light

        _ ->
            Nothing
```

The return row is the union alias — closed to exactly what the attribute admits — so the
result feeds `M3e.Theme.scheme` directly. Each `Just <ident>` reuses the already-emitted
bare token, whose open row (`Value { v | auto : Supported }`) unifies with the closed
union row.

### 3. Per-union `<elmName>Values`

```elm
schemeValues : List (Value Scheme)
schemeValues =
    [ auto, dark, light ]
```

The enumeration. Its purpose is that adding a value to the CEM cannot silently miss a UI
built from it — the consuming segmented-button/radio-group control gains the new option on
regen. Display labels stay in userland: `auto` renders as "System" in `elm-m3e`'s docs, and
that is editorial, not derivable from the manifest.

## The correctness detail that must not be lost

Both new per-union emissions **must case on the wire string, not the Elm identifier**, and
**must dedup by wire string**.

`tokenValueOf brand t` (`Emit.elm:1353`) is the string that reaches the DOM.
`tokenIdentResolved brand t` is the Elm name. They differ whenever a config `attrTypes`
MAP override asks for a token whose Elm name differs from its HTML value — the documented
example is `{"always": "true"}`, which mints `Values.always = Ir.token "true"`. Casing on
the identifier would make `fromString` disagree with `toString` for exactly those tokens,
silently.

Two existing guards are adjacent to this but **do not** cover it:

- `Model.elm:1867` (`tokenValues`) rejects one token rendering **two** strings.
- `Emit.guardValuesModule` (`:495`) rejects two distinct raw tokens resolving to the same
  **identifier**.

Neither rejects the reverse fan-in: two *distinct* tokens in one union rendering the *same*
wire string, which a map override permits
(`{"attr": {"always": "true", "yes": "true"}}` — forward-unique, so `tokenValues` accepts).
Left alone, that emits duplicate `case "true" ->` branches and a duplicated
`<elmName>Values` entry.

Dedup by wire string is correct and lossless, not a workaround: in that scenario `always`
and `yes` both evaluate to `Ir.token "true"`, i.e. the **same** `Value`. Which one
`fromString` returns is unobservable, and the duplicate list entry is pure noise. Dedup
after `List.sort` so the winner is deterministic.

## Naming and guards

- New identifiers are `<elmName>FromString` and `<elmName>Values`, derived from
  `EnumSpec.elmName` (the same base the portmanteaus use).
- They must be added to both `exposeBlock` and `docsBlock` in `valuesModule`, or the module
  fails `elm-review`/docs validation.
- They must flow through the existing collision detection so a clash with a bare token,
  union alias, or portmanteau fails loudly with the `_renames` snippet, exactly like every
  other identifier in this module. `guardValuesModule` is the site.
- `enumPortmanteaus`' `taken` set must include the new names so a portmanteau can never
  shadow them.
- K6 still holds: when `brand.unions` is empty the `Values` module is omitted entirely, so
  the new emissions are inside that same conditional and never produce `exposing ()`.

## Blast radius

`valuesModule` is brand-agnostic, and both downstream libraries invoke the same binary:

- `elm-m3e` — `npm run gen:src` → `src/M3e/Values.elm` (38 unions, incl. `Scheme`,
  `Contrast`).
- `elm-typed-html` — `scripts/regen.sh` shells out to `../elm-cem/bin/elm-cem.js` → 
  `src/TypedHtml/Values.elm`, which gains `dirFromString` / `dirValues` for free.

Both have a `check:drift` gate that will fail until each is regenerated, so both must be
regenerated in the same change set as this one lands.

The change is purely additive — no existing declaration changes shape — so no consumer
breaks.

## Verification

- A `tests/phantom/` fixture pair exercising: a plain union (idents == wire strings), a
  union with an `attrTypes` map override (ident ≠ wire string), and a union with two
  tokens sharing one wire string (the dedup path).
- A generated-output assertion that `fromString` round-trips `toString` for every token of
  every union in the fixture — the property that the wire-string detail above protects.
- A collision fixture: a CEM whose token is literally named so that `<elmName>Values`
  collides, asserting the loud failure and the `_renames` snippet.
- `check:drift` green in `elm-m3e` and `elm-typed-html` after regen.

## Consumers

Spec B (`elm-m3e/specs/2026-08-05-shared-elm-value-primitives-design.md`) is the first
consumer and should not start until this lands and `src/` is regenerated.
