module TypedHtml.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "a"
      , module_ = "TypedHtml.A"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "href", "href" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "div"
      , module_ = "TypedHtml.Grouping"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "fieldset"
      , module_ = "TypedHtml.Form"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "div", "legend", "p" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "legend"
      , module_ = "TypedHtml.Form"
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
    , { component = "optgroup"
      , module_ = "TypedHtml.Select"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "option" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "option"
      , module_ = "TypedHtml.Select"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "valueAsNumber", "valueAsNumber" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "p"
      , module_ = "TypedHtml.Grouping"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "shared:text", "span" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "picture"
      , module_ = "TypedHtml.Media"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "pictureSource" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "pictureSource"
      , module_ = "TypedHtml.Media"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "srcset", "srcset" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "select"
      , module_ = "TypedHtml.Select"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "disabled", "disabled" ), ( "size", "size" ), ( "onChange", "onChange" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "optgroup", "option" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "source"
      , module_ = "TypedHtml.Media"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "src", "src" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "span"
      , module_ = "TypedHtml.Grouping"
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
    , { component = "track"
      , module_ = "TypedHtml.Media"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "src", "src" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "video"
      , module_ = "TypedHtml.Media"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text", "source", "track" ] ) ]
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
    [ "autofocus", "class", "dir", "hidden", "id", "slot", "style", "tabindex" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
