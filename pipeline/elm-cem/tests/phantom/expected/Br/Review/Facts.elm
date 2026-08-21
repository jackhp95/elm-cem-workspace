module Br.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "barren"
      , module_ = "Br.Element.Barren"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "count", "count" ), ( "label", "label" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| The document-wide attributes EVERY element of this brand admits — the
`_globals` roster.

Emitted for the escape-discipline rules, which may only suggest a typed
setter when the attribute's meaning is **element-independent**. A global
qualifies by definition; an element-specific attribute does not, because from
an escape call site `content` on a `<meta>` is indistinguishable from
`content` on a custom element that gives the name its own meaning.

-}
globalAttributes : List String
globalAttributes =
    [ "class", "id", "slot", "style" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
