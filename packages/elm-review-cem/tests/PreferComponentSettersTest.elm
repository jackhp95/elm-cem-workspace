module PreferComponentSettersTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.PreferComponentSetters exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A container component with named `leading`/`trailing` slots, so its content
carries the generalized barrel setters `M3e.slotLeading`/`M3e.slotTrailing`,
which upgrade to the component-specific `listItemSlot*` forms.
-}
listItemFacts : List Facts.Fact
listItemFacts =
    [ { component = "listItem"
      , module_ = "M3e.ListItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attrSelected", "selected" ) ]
      , slotRewrites = [ ( "unnamed", "child" ), ( "leading", "leading" ), ( "trailing", "trailing" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "listItemSlotDefault" ), ( "slotLeading", "listItemSlotLeading" ), ( "slotTrailing", "listItemSlotTrailing" ) ]
      , groupConstructors = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


message : String -> String -> String
message generalized specific =
    "The generic setter `M3e." ++ generalized ++ "` can be replaced with the component setter `M3e." ++ specific ++ "`"


details : List String
details =
    [ "The generic barrel slot setter accepts any element valid in some component's version of the slot; the component setter is scoped to this component, so the compiler rejects a wrong-kind child. Both are re-exposed by the `M3e` barrel, so this changes no imports." ]


all : Test
all =
    describe "PreferComponentSetters"
        [ test "upgrades a generalized slot setter to the component-specific one inside a barrel constructor" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.slotLeading icon ]
"""
                    |> Review.Test.run (rule listItemFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message "slotLeading" "listItemSlotLeading"
                            , details = details
                            , under = "M3e.slotLeading"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.listItemSlotLeading icon ]
"""
                        ]
        , test "upgrades every generalized slot in the content list" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.slotLeading a, M3e.slotTrailing b ]
"""
                    |> Review.Test.run (rule listItemFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message "slotLeading" "listItemSlotLeading"
                            , details = details
                            , under = "M3e.slotLeading"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.listItemSlotLeading a, M3e.slotTrailing b ]
"""
                        , Review.Test.error
                            { message = message "slotTrailing" "listItemSlotTrailing"
                            , details = details
                            , under = "M3e.slotTrailing"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.slotLeading a, M3e.listItemSlotTrailing b ]
"""
                        ]
        , test "leaves raw default children (not slot setters) alone" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.icon [] [] ]
"""
                    |> Review.Test.run (rule listItemFacts)
                    |> Review.Test.expectNoErrors
        , test "leaves a generalized slot the enclosing component does not declare" <|
            \() ->
                -- `listItem` has no `overline`-... actually no `slotHeader`; its
                -- slotUpgrades lists only default/leading/trailing. A `slotHeader`
                -- here is cross-component misuse, left for `ValidSlotKind` — not a
                -- rewrite target (no specific form exists for this component).
                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.slotHeader h ]
"""
                    |> Review.Test.run (rule listItemFacts)
                    |> Review.Test.expectNoErrors
        , test "already-specific slots are left alone (idempotent)" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.listItem [] [ M3e.listItemSlotLeading icon ]
"""
                    |> Review.Test.run (rule listItemFacts)
                    |> Review.Test.expectNoErrors
        ]
