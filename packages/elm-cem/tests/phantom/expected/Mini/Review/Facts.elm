module Mini.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "button"
      , module_ = "Mini.Button"
      , enums = [ ( "variant", [ "filled", "tonal" ] ) ]
      , requiredSlots = [ "unnamed" ]
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "disabled", "disabled" ), ( "variant", "variant" ), ( "weight", "weight" ), ( "weightAsNumber", "weightAsNumber" ), ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "icon", "icon" ) ]
      , slotKinds = [ ( "unnamed", [ "shared:icon", "shared:text" ] ), ( "icon", [ "shared:icon" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "chip"
      , module_ = "Mini.Chip"
      , enums = [ ( "size", [ "big", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "disabled", "disabled" ), ( "size", "size" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "icon"
      , module_ = "Mini.Icon"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "surface"
      , module_ = "Mini.Surface"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "grid", "grid" ), ( "gridAsInts", "gridAsInts" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tab"
      , module_ = "Mini.Tab"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tabs"
      , module_ = "Mini.Tabs"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "tab" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "toolbar"
      , module_ = "Mini.Toolbar"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "button", "chip" ] ) ]
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
    [ "class", "dir", "id", "inert", "slot", "style", "tabindex" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
