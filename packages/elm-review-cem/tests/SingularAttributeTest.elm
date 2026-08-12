module SingularAttributeTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.SingularAttribute exposing (rule)
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
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "SingularAttribute"
        [ test "flags a genuinely singular attribute set twice" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.id "a", TypedHtml.Attributes.id "b" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Attribute `id` is set more than once on this call"
                            , details =
                                [ "HTML allows only one value per attribute; the browser will silently keep one and discard the others."
                                , "Merge or delete the extras."
                                ]
                            , under = "TypedHtml.Attributes.id"
                            }
                            -- Both duplicates share the same source text, so
                            -- pin the first: the rule reports the earliest
                            -- occurrence (`dedupeByName` keeps insertion order).
                            |> Review.Test.atExactly
                                { start = { row = 4, column = 27 }, end = { row = 4, column = 50 } }
                        ]
        , test "accepts a single attribute" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.id "a" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors

        -- `class` is a token list the IR MERGES (`HtmlIr.Internal` routes it to
        -- a structural fact "so it merges"; `TypedHtml.Attributes.class`
        -- "accumulates with every other `class` / `classList`"). Splitting one
        -- long class string across several calls to group it by concern is
        -- idiomatic, and the old error text -- "the browser will silently keep
        -- one and discard the others" -- was simply false for this stack.
        , test "does not flag `class` set more than once (it merges)" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.class "w-max", TypedHtml.Attributes.class "p-4" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "does not flag `classList` alongside `class`" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.class "a", TypedHtml.Attributes.classList [], TypedHtml.Attributes.classList [] ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors

        -- The per-property `style` setter is how elm/html has always been
        -- written (`style "color" "red", style "top" "0"`); flagging it would
        -- have made the rule unusable on ordinary code.
        , test "does not flag per-property `style` repeated" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.style "color" "red", TypedHtml.Attributes.style "top" "0" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "still flags a singular attribute when a multi-attribute is also present" <|
            \() ->
                """module A exposing (v)
import M3e.IconButton
import TypedHtml.Attributes
v = M3e.IconButton.view [ TypedHtml.Attributes.class "a", TypedHtml.Attributes.class "b", TypedHtml.Attributes.id "x", TypedHtml.Attributes.id "y" ] []
"""
                    |> Review.Test.run (rule iconButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Attribute `id` is set more than once on this call"
                            , details =
                                [ "HTML allows only one value per attribute; the browser will silently keep one and discard the others."
                                , "Merge or delete the extras."
                                ]
                            , under = "TypedHtml.Attributes.id"
                            }
                            |> Review.Test.atExactly
                                { start = { row = 4, column = 91 }, end = { row = 4, column = 114 } }
                        ]
        ]
