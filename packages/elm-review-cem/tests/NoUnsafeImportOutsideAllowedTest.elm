module NoUnsafeImportOutsideAllowedTest exposing (all)

import NoUnsafeImportOutsideAllowed exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "NoUnsafeImportOutsideAllowed"
        [ test "flags an *.Unsafe import from a non-allowed feature module" <|
            \() ->
                """module Route.Home exposing (v)

import M3e.Unsafe as Unsafe

v =
    Unsafe.fromHtml raw
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Unsafe` imported outside an allowed module"
                            , details =
                                [ "`M3e.Unsafe` is a loud legacy-interop escape surface: it wraps raw `Html` and re-kinds elements with FREE phantom rows, so the compiler checks nothing about the result (see docs/decisions.md §\"Seam-discipline rules live here\")."
                                , "Importing it here scatters unchecked escapes through feature code. Reach for the typed `M3e` API, or move this crossing into a designated Seam/escape module in the allow-list."
                                ]
                            , under = "M3e.Unsafe"
                            }
                        ]
        , test "flags a *.Unsafe.Attributes import (second-to-last segment)" <|
            \() ->
                """module App.Widget exposing (v)

import TypedHtml.Unsafe.Attributes as UA

v =
    UA.fromHtmlAttribute raw
"""
                    |> Review.Test.run (rule [ "M3e", "Seam", "Native" ])
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`TypedHtml.Unsafe.Attributes` imported outside an allowed module"
                            , details =
                                [ "`TypedHtml.Unsafe.Attributes` is a loud legacy-interop escape surface: it wraps raw `Html` and re-kinds elements with FREE phantom rows, so the compiler checks nothing about the result (see docs/decisions.md §\"Seam-discipline rules live here\")."
                                , "Importing it here scatters unchecked escapes through feature code. Reach for the typed `TypedHtml` API, or move this crossing into a designated Seam/escape module in the allow-list."
                                ]
                            , under = "TypedHtml.Unsafe.Attributes"
                            }
                        ]
        , test "allows *.Unsafe import from a generated M3e.* module" <|
            \() ->
                """module M3e.Button exposing (view)

import M3e.Unsafe as Unsafe

view raw =
    Unsafe.fromHtml raw
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        , test "allows *.Unsafe import from an allow-listed Seam module" <|
            \() ->
                """module Seam exposing (asElement)

import M3e.Unsafe as Unsafe

asElement =
    Unsafe.fromHtml
"""
                    |> Review.Test.run (rule [ "M3e", "Seam", "Native" ])
                    |> Review.Test.expectNoErrors
        , test "allows *.Unsafe import from a nested allow-listed module (dot-boundary prefix)" <|
            \() ->
                """module Kit.Badge exposing (on)

import TypedHtml.Unsafe as Unsafe

on raw =
    Unsafe.fromHtml raw
"""
                    |> Review.Test.run (rule [ "M3e", "Kit" ])
                    |> Review.Test.expectNoErrors
        , test "does not flag a public (non-Unsafe) import in a feature module" <|
            \() ->
                """module Route.Home exposing (v)

import M3e

v =
    M3e.button [] []
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        , test "does not treat a module merely containing 'Unsafe' mid-name as Unsafe" <|
            \() ->
                """module Route.Home exposing (v)

import M3e.Unsafely.Fine as Fine

v =
    Fine.thing
"""
                    |> Review.Test.run (rule [ "M3e", "Seam" ])
                    |> Review.Test.expectNoErrors
        , test "an empty allow-list gates *.Unsafe everywhere (even generated M3e.*)" <|
            \() ->
                """module M3e.Button exposing (view)

import M3e.Unsafe as Unsafe

view raw =
    Unsafe.fromHtml raw
"""
                    |> Review.Test.run (rule [])
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`M3e.Unsafe` imported outside an allowed module"
                            , details =
                                [ "`M3e.Unsafe` is a loud legacy-interop escape surface: it wraps raw `Html` and re-kinds elements with FREE phantom rows, so the compiler checks nothing about the result (see docs/decisions.md §\"Seam-discipline rules live here\")."
                                , "Importing it here scatters unchecked escapes through feature code. Reach for the typed `M3e` API, or move this crossing into a designated Seam/escape module in the allow-list."
                                ]
                            , under = "M3e.Unsafe"
                            }
                        ]
        ]
