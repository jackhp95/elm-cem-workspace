module Hz.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "attrSlot"
      , module_ = "Hz.Component.AttrSlot"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "withHint", "withHint" ), ( "withLabel", "withLabel" ) ]
      , slotRewrites = [ ( "hint", "hint" ), ( "label", "label" ) ]
      , slotKinds = [ ( "hint", [] ), ( "label", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "blocked"
      , module_ = "Hz.Component.Blocked"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "duplicate"
      , module_ = "Hz.Component.Duplicate"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "errorOnly"
      , module_ = "Hz.Component.ErrorOnly"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "onHzError", "onHzError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "eventClash"
      , module_ = "Hz.Component.EventClash"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "onError", "onError" ), ( "onHzError", "onHzError" ), ( "onLoad", "onLoad" ), ( "onHzLoad", "onHzLoad" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "global"
      , module_ = "Hz.Component.Global"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "placement"
      , module_ = "Hz.Component.Placement"
      , enums = [ ( "position", [ "blank_", "parent_", "self_", "top_", "top" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "position", "position" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "text"
      , module_ = "Hz.Component.Text"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "textElement"
      , module_ = "Hz.Component.TextElement"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
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
