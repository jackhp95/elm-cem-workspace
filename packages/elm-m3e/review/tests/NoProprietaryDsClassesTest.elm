module NoProprietaryDsClassesTest exposing (all)

import NoProprietaryDsClasses exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


message : String
message =
    "Proprietary CSS class — not Material, ships no CSS"


details : List String
details =
    [ "`ds-*` and `t-*` classes are project-proprietary tokens that are not part of Material and ship no CSS in this library, so they render nothing."
    , "Use a typed M3e slot/role binding or a real utility class instead."
    ]


all : Test
all =
    describe "NoProprietaryDsClasses"
        [ test "flags Attr.class \"ds-…\"" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "ds-card-media" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "\"ds-card-media\""
                            }
                        ]
        , test "flags a t- theme token" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "t-primary" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "\"t-primary\""
                            }
                        ]
        , test "flags a withClass setter carrying a ds- class" <|
            \() ->
                """module A exposing (view)
import Ui.Shape
view = Ui.Shape.withClass "ds-w-16"
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "\"ds-w-16\""
                            }
                        ]
        , test "flags a ds- class buried among utility classes in one string" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "flex ds-card items-center" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "\"flex ds-card items-center\""
                            }
                        ]
        , test "flags a ds- token inside classList" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view active = Html.div [ Attr.classList [ ( "ds-active", active ) ] ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "\"ds-active\""
                            }
                        ]
        , test "passes a real utility class" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "flex items-center" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "passes class names that merely contain ds/t mid-token" <|
            \() ->
                """module A exposing (view)
import Html
import Html.Attributes as Attr
view = Html.div [ Attr.class "cards tools grid-ds" ] []
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        ]
