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
      , slotKinds = []
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
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "SingularSlot"
        [ test "flags a singular slot filled twice" <|
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
    M3e.Record.ListItem.view {} [] [ trailing a, trailing b ]
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
    M3e.Record.ListItem.view {} [] [ child a, child b, child c ]
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        ]
