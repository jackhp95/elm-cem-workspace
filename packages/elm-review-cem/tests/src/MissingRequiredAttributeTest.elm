module MissingRequiredAttributeTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.MissingRequiredAttribute exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


iconButtonFacts : List Facts.Fact
iconButtonFacts =
    [ { component = "iconButton"
      , module_ = "M3e.IconButton"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = [ "aria-label" ]
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


fabFacts : List Facts.Fact
fabFacts =
    [ { component = "fab"
      , module_ = "M3e.Fab"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ), ( "label", "label" ), ( "close-icon", "closeIcon" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "fabSlotDefault" ), ( "slotLabel", "fabSlotLabel" ), ( "slotCloseIcon", "fabSlotCloseIcon" ) ]
      , facets = [ Standard, Record ]
      , requiredAttrs = [ "aria-label" ]
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "MissingRequiredAttribute"
        [ test "flags Standard call missing aria-label" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
v = M3e.IconButton.view [] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.IconButton.view"
                            }
                        ]
        , test "accepts Standard call with M3e.Aria.label" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import M3e.Aria
v = M3e.IconButton.view [ M3e.Aria.label "Close" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts phantom-axis TypedHtml.Aria.label (any *.Aria module)" <|
            \() ->
                [ """module A exposing (v)
import M3e.IconButton
import TypedHtml.Aria
v = M3e.IconButton.view [ TypedHtml.Aria.label "Close" ] []
"""
                , """module TypedHtml.Aria exposing (label)
label : String -> Int
label _ = 0
"""
                ]
                    |> Review.Test.runOnModules (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts raw M3e.Html.Attr.attribute escape hatch" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import M3e.Html.Attr
v = M3e.IconButton.view [ M3e.Html.Attr.attribute "aria-label" "Close" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "flags Record call missing aria-label" <|
            \() ->
                """module A exposing (v)
import M3e.Record.IconButton
v = M3e.Record.IconButton.view { content = a } [] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.Record.IconButton.view"
                            }
                        ]
        , test "silent when attrs list is unresolved" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
v = M3e.IconButton.view dynamicAttrs []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op on component with no requiredAttrs" <|
            \() ->
                """module A exposing (v)
import M3e.Card
v = M3e.Card.view [] []
"""
                    |> Review.Test.run
                        (rule [ { component = "card", module_ = "M3e.Card", enums = [], requiredSlots = [], multiSlots = [], attrRewrites = [], slotRewrites = [], slotKinds = [], slotUpgrades = [], facets = [ Standard ], requiredAttrs = [], actionMap = [], groupConstructors = [], usesAction = False } ])
                    |> Review.Test.expectNoErrors
        , test "flags call whose attrs is a let-bound empty list" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
v =
    let
        attrs = []
    in
    M3e.IconButton.view attrs []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.IconButton.view"
                            }
                        ]
        , test "scope reset: second declaration does not inherit let-bindings of first" <|
            \() ->
                """module A exposing (v1, v2)
import M3e.IconButton
import M3e.Aria
v1 =
    let
        attrs = [ M3e.Aria.label "Close" ]
    in
    M3e.IconButton.view attrs []
v2 =
    let
        attrs = []
    in
    M3e.IconButton.view attrs []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.IconButton.view"
                            }
                            |> Review.Test.atExactly { start = { row = 13, column = 5 }, end = { row = 13, column = 24 } }
                        ]
        , test "Fab with label slot filled does not flag aria-label" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
v = M3e.Fab.view [] [ M3e.Fab.label [ M3e.Fab.child icon ] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "IconButton (no label slot) still requires aria-label even with content" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
v = M3e.IconButton.view [] [ M3e.IconButton.child icon ]
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.IconButton.view"
                            }
                        ]

        -- Facet-agnostic satisfier recognition (issues B/C): the SAME required
        -- attribute must be detected and satisfied identically on the barrel
        -- facet (`M3e.iconButton`, `M3e.ariaLabel`, generalized `M3e.slotLabel`)
        -- as on the per-component facet above.
        , test "barrel: flags M3e.iconButton missing aria-label" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.iconButton [] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `iconButton` requires attribute `aria-label` but this call doesn't provide it"
                            , details =
                                [ "The component declares `aria-label` as required for iconButton (and accessibility guidance treats an accessible name as non-optional)."
                                , "Add `M3e.Aria.label \"...\"` to the attrs list."
                                ]
                            , under = "M3e.iconButton"
                            }
                        ]
        , test "barrel: accepts M3e.ariaLabel satisfier" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.iconButton [ M3e.ariaLabel "Close" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "barrel: Fab with generalized slotLabel filled does not flag aria-label" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.fab [] [ M3e.slotLabel [ M3e.slotDefault icon ] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors

        -- Issue #3: the barrel-form ARIA satisfier must be brand-agnostic,
        -- matching isCallToAnyAriaAxis's stance on the per-component form.
        -- Otherwise PreferBarrel's own suggested rewrite of
        -- `TypedHtml.Aria.label` -> `TypedHtml.ariaLabel` on an `M3e.iconButton`
        -- call flips this rule from silent to a false positive.
        , test "barrel: accepts cross-brand TypedHtml.ariaLabel satisfier" <|
            \() ->
                """module A exposing (v)
import M3e
import TypedHtml
v = M3e.iconButton [ TypedHtml.ariaLabel "Close" ] []
"""
                    |> Review.Test.run
                        (rule
                            (iconButtonFacts
                                ++ [ { component = "unused"
                                     , module_ = "TypedHtml.Unused"
                                     , enums = []
                                     , requiredSlots = []
                                     , multiSlots = []
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
                            )
                        )
                    |> Review.Test.expectNoErrors
        ]
