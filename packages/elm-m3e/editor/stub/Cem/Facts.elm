module Cem.Facts exposing (Facet(..), Fact)

{-| Minimal facts types used by the generated `M3e.Review.Facts` module.

This is an EDITOR-ONLY stub: it lets Elm LSP / VS Code type-check `src/`
(specifically the generated `M3e.Review.Facts`, which `import Cem.Facts`)
without requiring `packages/elm-cem/facts/` (published as `jackhp95/elm-cem-facts`)
in `editor/elm.json`'s `source-directories`, which carries the canonical
`Cem.Facts`.

It is deliberately NOT under `src/`:

  - `src/` is a generated artifact — the `elm-cem` regen-drift gate diffs the
    whole `src/` tree against a fresh regen, which emits neither this stub nor a
    `src/elm.json`. Keeping the stub here (out of `src/`) keeps that gate green.
  - The `elm-review` config's `source-directories` include `../src` alongside
    `../../elm-cem/facts/src`, which ALSO defines `Cem.Facts`; a copy under
    `src/` would make `Cem.Facts` an AMBIGUOUS IMPORT on the review path.

This mirrors the canonical `Cem.Facts` (five facets: Raw, Html, Standard,
Record, Build). `M3e.Review.Facts` uses only Standard/Record/Build, so it binds
identically against this stub (editor) or the real `elm-cem-facts` module
(review).

-}


type Facet
    = Raw
    | Html
    | Standard
    | Record
    | Build


type alias Fact =
    { component : String
    , module_ : String
    , enums : List ( String, List String )
    , requiredSlots : List String
    , multiSlots : List String
    , attrRewrites : List ( String, String )
    , slotRewrites : List ( String, String )
    , slotKinds : List ( String, List String )
    , slotUpgrades : List ( String, String )
    , groupConstructors : List String
    , facets : List Facet
    , requiredAttrs : List String
    , actionMap : List ( String, String )
    , usesAction : Bool
    }
