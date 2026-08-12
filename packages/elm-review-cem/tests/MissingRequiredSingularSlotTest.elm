module MissingRequiredSingularSlotTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.MissingRequiredSingularSlot exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A component with a NAMED required-singular slot (`header`), so the slot is
filled by an explicit setter — per-component `M3e.ExpansionPanel.header` or the
generalized barrel `M3e.slotHeader`. Exercises facet-agnostic slot detection.
-}
expansionPanelFacts : List Facts.Fact
expansionPanelFacts =
    [ { component = "expansionPanel"
      , module_ = "M3e.ExpansionPanel"
      , enums = []
      , requiredSlots = [ "header" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ), ( "header", "header" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "expansionPanelSlotDefault" ), ( "slotHeader", "expansionPanelSlotHeader" ) ]
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "MissingRequiredSingularSlot"
        [ test "flags Standard call missing required-singular slot" <|
            \() ->
                """module A exposing (v)
import M3e.Button
v = M3e.Button.view [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the content list doesn't fill it"
                            , details =
                                [ "Add `M3e.Button.child <value>` to the content list, or use `M3e.Record.Button.view` which enforces this at the type level."
                                ]
                            , under = "M3e.Button.view"
                            }
                        ]
        , test "accepts Standard call with child" <|
            \() ->
                """module A exposing (v)
import M3e.Button
v = M3e.Button.view [] [ M3e.Button.child a ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts a raw default child (another component's view) as filling the content slot" <|
            \() ->
                """module A exposing (v)
import M3e.Button
import M3e.Icon
v = M3e.Button.view [] [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts a userland helper (e.g. Kit.text) as filling the content slot" <|
            \() ->
                -- Mirrors the real `SuggestionChip.view [] [ Kit.text cat ]` usage:
                -- `Kit.text` is not a named-slot setter, so it is a raw default child.
                """module A exposing (v)
import M3e.Button
import Kit
v = M3e.Button.view [] [ Kit.text "hi" ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "silent on Record call (record is compile-time enforced)" <|
            \() ->
                """module A exposing (v)
import M3e.Record.Button
v = M3e.Record.Button.view { content = a } [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when content list is unresolved" <|
            \() ->
                """module A exposing (v)
import M3e.Button
v = M3e.Button.view [] dynamicContent
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "flags call whose content is a let-bound empty list" <|
            \() ->
                """module A exposing (v)
import M3e.Button
v =
    let
        content = []
    in
    M3e.Button.view [] content
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the content list doesn't fill it"
                            , details =
                                [ "Add `M3e.Button.child <value>` to the content list, or use `M3e.Record.Button.view` which enforces this at the type level."
                                ]
                            , under = "M3e.Button.view"
                            }
                        ]
        , test "scope reset: second declaration does not inherit let-bindings of first" <|
            \() ->
                """module A exposing (v1, v2)
import M3e.Button
v1 =
    let
        content = [ M3e.Button.child someText ]
    in
    M3e.Button.view [] content
v2 =
    let
        content = []
    in
    M3e.Button.view [] content
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the content list doesn't fill it"
                            , details =
                                [ "Add `M3e.Button.child <value>` to the content list, or use `M3e.Record.Button.view` which enforces this at the type level."
                                ]
                            , under = "M3e.Button.view"
                            }
                            |> Review.Test.atExactly { start = { row = 12, column = 5 }, end = { row = 12, column = 20 } }
                        ]

        -- Facet-agnostic named-slot detection (issue B): a NAMED required
        -- slot must be recognised as filled on either facet.
        , test "per-component: accepts M3e.ExpansionPanel.header filling the named slot" <|
            \() ->
                """module A exposing (v)
import M3e.ExpansionPanel
v = M3e.ExpansionPanel.view [] [ M3e.ExpansionPanel.header [ title ] ]
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectNoErrors
        , test "barrel: accepts generalized M3e.slotHeader filling the named slot" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.expansionPanel [] [ M3e.slotHeader [ title ] ]
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectNoErrors
        , test "barrel: flags M3e.expansionPanel missing the named header slot" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.expansionPanel [] []
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `expansionPanel` requires content slot `header` but the content list doesn't fill it"
                            , details =
                                [ "Add `M3e.ExpansionPanel.header <value>` to the content list, or use `M3e.Record.ExpansionPanel.view` which enforces this at the type level."
                                ]
                            , under = "M3e.expansionPanel"
                            }
                        ]
        ]
