module FakeFacts exposing (all, blank, byName)

import Cem.Facts exposing (Facet(..), Fact)


blank : String -> Fact
blank name =
    { component = name
    , module_ = "Fake." ++ name
    , enums = []
    , requiredSlots = []
    , multiSlots = []
    , attrRewrites = []
    , slotRewrites = []
    , slotKinds = []
    , slotUpgrades = []
    , groupConstructors = []
    , facets = [ Standard ]
    , requiredAttrs = []
    , actionMap = []
    , usesAction = False
    }


all : List Fact
all =
    [ { blankWidget
        | enums = [ ( "variant", [ "filled", "outlined" ] ) ]
        , attrRewrites =
            [ ( "disabled", "disabled" )
            , ( "label", "label" )
            , ( "count", "count" )
            , ( "ratio", "ratio" )
            , ( "variant", "variant" )
            , ( "onClick", "onClick" )
            , ( "label", "label" )
            ]
      }
    , { blankContainer
        | multiSlots = [ "unnamed" ]
        , slotKinds = [ ( "unnamed", [ "widget", "ghost", "container" ] ) ]
      }
    , { blankLabelled
        | requiredSlots = [ "headline" ]
        , slotKinds = [ ( "headline", [ "shared:text" ] ) ]
      }
    , { blankIconic | slotKinds = [ ( "lead", [ "shared:icon" ] ) ] }
    , { blankSingle | slotKinds = [ ( "only", [ "widget", "single" ] ) ] }
    , { blankMixed
        | slotKinds =
            [ ( "any", [ "shared:text", "shared:icon", "widget", "ghost" ] )
            , ( "flowy", [ "shared:flow", "widget" ] )
            , ( "unconstrained", [] )
            ]
      }
    , { blankGadget | attrRewrites = [ ( "disabled", "disabled" ), ( "label", "label" ) ] }
    , { blankNarrow | slotKinds = [ ( "unnamed", [ "container" ] ) ] }
    ]


blankWidget : Fact
blankWidget =
    blank "widget"


blankContainer : Fact
blankContainer =
    blank "container"


blankLabelled : Fact
blankLabelled =
    blank "labelled"


blankIconic : Fact
blankIconic =
    blank "iconic"


blankSingle : Fact
blankSingle =
    blank "single"


blankMixed : Fact
blankMixed =
    blank "mixed"


{-| Shares an attr with `widget` (`disabled`, `label`) so a `SetComponent`
swap from `widget` has something to keep, and lacks `count`/`ratio`/the
`variant` enum so a swap has something to drop.
-}
blankGadget : Fact
blankGadget =
    blank "gadget"


{-| Names the SAME slot as `container` (`"unnamed"`) but affords only
`"container"` there (not `"widget"`) and is non-multi — so a `SetComponent`
swap from `container` exercises "the slot survives (both declare `unnamed`)
but a child's KIND may no longer fit" independently of "the slot itself is
gone", and exercises the non-multi cap landing on a slot that used to be
unbounded. Deliberately affords a component `container.unnamed` ALSO
affords (`"container"`, not `"single"`, which `container.unnamed` never
named) so both a survivor and a casualty can legally exist there before the
swap.
-}
blankNarrow : Fact
blankNarrow =
    blank "narrow"


byName : String -> Maybe Fact
byName name =
    List.filter (\f -> f.component == name) all |> List.head
