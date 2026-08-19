module SingularSlotTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.SingularSlot exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A List whose default (`child`) slot is repeatable, but `trailing` is singular.
-}
facts : List Facts.Fact
facts =
    [ { component = "listItem"
      , module_ = "M3e.ListItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "default", [] ), ( "trailing", [] ) ]
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


shape4Facts : List Facts.Fact
shape4Facts =
    [ { component = "listItem"
      , module_ = "M3e.ListItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "default", [] ), ( "trailing", [] ) ]
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| REAL-SHAPED facts: `module_` carries the `.Component.` segment exactly like the
generated `M3e.Review.Facts` (all 130 real facts are `"M3e.Component.<X>"`). The
`trailing` slot is singular. A BARREL call (`M3e.listItem`, resolved under namespace
`["M3e"]` → `siteKey = "M3e\0listItem"`) only resolves if the index carries the
barrel-alias key that `Cem.Internal.Facts.buildIndex` inserts. A private
`factKey`-only index holds only `"M3e.Component\0listItem"` → barrel MISS → DEAD.

This fixture is the one the flat `M3e.ListItem` fixtures above CANNOT express: with a
flat `module_`, `factKey == siteKey`, so the barrel call resolves even against the
buggy private index — which is exactly why the barrel bug hid behind green tests.

-}
realShapeFacts : List Facts.Fact
realShapeFacts =
    [ { component = "listItem"
      , module_ = "M3e.Component.ListItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "default" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "default", [] ), ( "trailing", [] ) ]
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "SingularSlot"
        [ test "flags a repeated singular slot on a BARREL call with real-shaped facts (module_ = M3e.Component.ListItem)" <|
            \() ->
                -- Regression for the barrel-alias index bug. RED against a private
                -- `factKey`-only index (barrel call does not resolve → no error);
                -- GREEN once `buildIndex` derives from `Facts.buildIndex`.
                """module A exposing (v)

import M3e exposing (listItem, trailing)

v =
    listItem [] [ trailing a, trailing b ]
"""
                    |> Review.Test.run (rule realShapeFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Singular slot `trailing` is filled more than once"
                            , details =
                                [ "This slot renders a single element, but it's set multiple times here — the extra will silently win or be dropped."
                                , "Keep one, or (if this component genuinely repeats the slot) it should be in the multi set — check the component's slot config."
                                ]
                            , under = "trailing a"
                            }
                        ]
        , test "does NOT flag a repeated non-slot barrel wrapper (e.g. mapMsg) in the content list" <|
            \() ->
                -- False-positive guard found by live check:review on real elm-m3e code:
                -- `M3e.mapMsg` is a message mapper, not a slot setter, and is legitimately
                -- applied once per child. Only actual singular SLOT setters may be flagged.
                """module A exposing (v)

import M3e exposing (listItem, mapMsg)

v =
    listItem [] [ mapMsg f (child a), mapMsg f (child b) ]
"""
                    |> Review.Test.run (rule realShapeFacts)
                    |> Review.Test.expectNoErrors
        , test "flags a singular slot filled twice" <|
            \() ->
                """module A exposing (v)

import M3e exposing (listItem, child, trailing)

v =
    listItem [] [ trailing a, trailing b ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Singular slot `trailing` is filled more than once"
                            , details =
                                [ "This slot renders a single element, but it's set multiple times here — the extra will silently win or be dropped."
                                , "Keep one, or (if this component genuinely repeats the slot) it should be in the multi set — check the component's slot config."
                                ]
                            , under = "trailing a"
                            }
                        ]
        , test "allows a multi slot filled many times" <|
            \() ->
                """module A exposing (v)

import M3e exposing (listItem, child)

v =
    listItem [] [ child a, child b, child c ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "does not treat repeated attrs as repeated slots" <|
            \() ->
                """module A exposing (v)

import M3e exposing (listItem, klass)

v =
    listItem [ klass "a", klass "b" ] [ child x ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "flags a singular slot filled twice at Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.ListItem
import M3e exposing (trailing)

v =
    M3e.Record.ListItem.component {} [] [ trailing a, trailing b ]
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Singular slot `trailing` is filled more than once"
                            , details =
                                [ "This slot renders a single element, but it's set multiple times here — the extra will silently win or be dropped."
                                , "Keep one, or (if this component genuinely repeats the slot) it should be in the multi set — check the component's slot config."
                                ]
                            , under = "trailing a"
                            }
                        ]
        , test "allows a multi slot filled many times at Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.ListItem
import M3e exposing (child)

v =
    M3e.Record.ListItem.component {} [] [ child a, child b, child c ]
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        ]
