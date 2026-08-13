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


byName : String -> Maybe Fact
byName name =
    List.filter (\f -> f.component == name) all |> List.head
