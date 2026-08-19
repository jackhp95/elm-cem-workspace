module NoInternalImportOutsideAllowedTest exposing (all)

import NoInternalImportOutsideAllowed exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoInternalImportOutsideAllowed"
        [ test "flags an *.Internal import from a non-allowed feature module" <|
            \() ->
                """module Route.Home exposing (v)

import M3e.Element.Internal as Element

v =
    Element.fromNode someNode
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Element.Internal` imported outside an allowed module"
                            , details =
                                [ "`M3e.Element.Internal` is an opaque-IR interior module: it exposes the raw-to-phantom constructors and free phantom-asserting operations that the public module deliberately withholds (see docs/decisions.md §\"Seam-discipline rules live here\")."
                                , "Importing it here would let this module mint typed IR from raw and assert any phantom row, defeating the boundary. Reach for the public `M3e.Element` API, or move this crossing into a designated Seam/escape module in the allow-list."
                                ]
                            , under = "M3e.Element.Internal"
                            }
                        ]
        , test "flags a nested Cem.Attr.Internal import" <|
            \() ->
                """module App.Widget exposing (v)

import M3e.Html.Attr.Internal as Attr

v =
    Attr.forget x
"""
                    |> Review.Test.run (rule [ "M3e", "Seam", "Native" ])
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Html.Attr.Internal` imported outside an allowed module"
                            , details =
                                [ "`M3e.Html.Attr.Internal` is an opaque-IR interior module: it exposes the raw-to-phantom constructors and free phantom-asserting operations that the public module deliberately withholds (see docs/decisions.md §\"Seam-discipline rules live here\")."
                                , "Importing it here would let this module mint typed IR from raw and assert any phantom row, defeating the boundary. Reach for the public `M3e.Html.Attr` API, or move this crossing into a designated Seam/escape module in the allow-list."
                                ]
                            , under = "M3e.Html.Attr.Internal"
                            }
                        ]
        , test "allows *.Internal import from a generated M3e.* module" <|
            \() ->
                """module M3e.Button exposing (view)

import M3e.Element.Internal as Element
import M3e.Node exposing (Node)

view node =
    Element.fromNode node
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        , test "allows *.Internal import from an allow-listed Seam module" <|
            \() ->
                """module Seam exposing (asElement)

import M3e.Element.Internal as Element
import M3e.Node exposing (Node)

asElement =
    Element.fromNode
"""
                    |> Review.Test.run (rule [ "M3e", "Seam", "Native" ])
                    |> Review.Test.expectNoErrors
        , test "allows *.Internal import from a nested allow-listed module (dot-boundary prefix)" <|
            \() ->
                """module Kit.Badge exposing (on)

import M3e.Element.Internal as Element

on node =
    Element.fromNode node
"""
                    |> Review.Test.run (rule [ "M3e", "Kit" ])
                    |> Review.Test.expectNoErrors
        , test "does not flag a public (non-Internal) import in a feature module" <|
            \() ->
                """module Route.Home exposing (v)

import M3e.Element as Element

v =
    Element.toNode el
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        , test "does not treat a module merely containing 'Internal' mid-name as Internal" <|
            \() ->
                """module Route.Home exposing (v)

import M3e.Internally.Fine as Fine

v =
    Fine.thing
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        ]
