module NoRedundantElementEscapeTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import NoRedundantElementEscape exposing (rule)
import Review.Rule exposing (Rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A slice of a component library's facts: `M3e.button` / `M3e.heading` (brand
components) plus `TypedHtml.div` (a typed-HTML tag). Every `Fact` field is written
explicitly (matching `tests/Fixtures.elm`) so a new field breaks this file loudly.
Only `.component` / `.module_` drive the covered-producer index the rule builds.
-}
coveredFacts : List Facts.Fact
coveredFacts =
    [ componentFact "button" "M3e.Button"
    , componentFact "heading" "M3e.Heading"
    , componentFact "div" "TypedHtml.Div"
    , componentFact "a" "TypedHtml.A"
    , componentFact "header" "TypedHtml.Sectioning"
    , componentFact "main_" "TypedHtml.Sectioning"
    ]


componentFact : String -> String -> Facts.Fact
componentFact component module_ =
    { component = component
    , module_ = module_
    , enums = []
    , requiredSlots = []
    , multiSlots = []
    , attrRewrites = []
    , slotRewrites = []
    , slotKinds = []
    , slotUpgrades = []
    , groupConstructors = []
    , facets = [ Standard, Build ]
    , requiredAttrs = []
    , actionMap = []
    , usesAction = False
    }


config : Rule
config =
    rule { seamEscapes = [ "Seam.fromHtml", "Seam.toElement" ] } coveredFacts


all : Test
all =
    describe "NoRedundantElementEscape"
        [ describe "positive (flagged)"
            [ test "toHtml wrapping a barrel producer: `toHtml (M3e.button [] [])`" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.toHtml (M3e.button [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.toHtml` wraps the already-typed `button` Element"
                                , details = expectedDetails "M3e.toHtml" "button"
                                , under = "M3e.toHtml"
                                }
                            ]
            , test "Unsafe.recast wrapping a producer: `Unsafe.recast (M3e.heading …)`" <|
                \() ->
                    """module Feature exposing (view)

import M3e
import M3e.Unsafe as Unsafe


view =
    Unsafe.recast (M3e.heading [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.Unsafe.recast` wraps the already-typed `heading` Element"
                                , details = expectedDetails "M3e.Unsafe.recast" "heading"
                                , under = "Unsafe.recast"
                                }
                            ]
            , test "Unsafe.fromHtml wrapping a producer is flagged" <|
                \() ->
                    """module Feature exposing (view)

import M3e
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (M3e.button [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.Unsafe.fromHtml` wraps the already-typed `button` Element"
                                , details = expectedDetails "M3e.Unsafe.fromHtml" "button"
                                , under = "Unsafe.fromHtml"
                                }
                            ]
            , test "a configured Seam escape wrapping a producer is flagged" <|
                \() ->
                    """module Feature exposing (view)

import M3e
import Seam


view =
    Seam.fromHtml (M3e.button [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `Seam.fromHtml` wraps the already-typed `button` Element"
                                , details = expectedDetails "Seam.fromHtml" "button"
                                , under = "Seam.fromHtml"
                                }
                            ]
            , test "a typed-HTML producer is covered too: `toHtml (TypedHtml.div [] [])`" <|
                \() ->
                    """module Feature exposing (view)

import TypedHtml


view =
    TypedHtml.toHtml (TypedHtml.div [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `TypedHtml.toHtml` wraps the already-typed `div` Element"
                                , details = expectedDetails "TypedHtml.toHtml" "div"
                                , under = "TypedHtml.toHtml"
                                }
                            ]
            , test "pipe form is flagged: `M3e.button [] [] |> M3e.toHtml`" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.button [] [] |> M3e.toHtml
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.toHtml` wraps the already-typed `button` Element"
                                , details = expectedDetails "M3e.toHtml" "button"
                                , under = "M3e.toHtml"
                                }
                            ]
            , test "backward-pipe form is flagged: `M3e.toHtml <| M3e.button [] []`" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.toHtml <| M3e.button [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.toHtml` wraps the already-typed `button` Element"
                                , details = expectedDetails "M3e.toHtml" "button"
                                , under = "M3e.toHtml"
                                }
                            ]
            ]
        , describe "raw covered tag through an Html-accepting escape"
            [ test "`Unsafe.fromHtml (Html.a …)` — the typed producer exists" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (Html.a [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = rawTagMessage "M3e.Unsafe.fromHtml" "a" "TypedHtml.a"
                                , details = rawTagDetails "M3e.Unsafe.fromHtml" "a" "TypedHtml.a"
                                , under = "Unsafe.fromHtml"
                                }
                            ]
            , test "`Unsafe.fromHtml (Html.header …)` — the typed producer exists" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (Html.header [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = rawTagMessage "M3e.Unsafe.fromHtml" "header" "TypedHtml.header"
                                , details = rawTagDetails "M3e.Unsafe.fromHtml" "header" "TypedHtml.header"
                                , under = "Unsafe.fromHtml"
                                }
                            ]
            , test "the reserved-word spelling is covered too: `Html.main_`" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (Html.main_ [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = rawTagMessage "M3e.Unsafe.fromHtml" "main_" "TypedHtml.main_"
                                , details = rawTagDetails "M3e.Unsafe.fromHtml" "main_" "TypedHtml.main_"
                                , under = "Unsafe.fromHtml"
                                }
                            ]
            , test "`Html.node` with a covered literal tag is flagged" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (Html.node "a" [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = rawTagMessage "M3e.Unsafe.fromHtml" "a" "TypedHtml.a"
                                , details = rawTagDetails "M3e.Unsafe.fromHtml" "a" "TypedHtml.a"
                                , under = "Unsafe.fromHtml"
                                }
                            ]
            , test "a configured Seam escape of a covered raw tag is flagged" <|
                \() ->
                    """module Feature exposing (view)

import Html
import Seam


view =
    Seam.fromHtml (Html.a [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = rawTagMessage "Seam.fromHtml" "a" "TypedHtml.a"
                                , details = rawTagDetails "Seam.fromHtml" "a" "TypedHtml.a"
                                , under = "Seam.fromHtml"
                                }
                            ]
            ]
        , describe "customElement"
            [ test "`customElement` of a covered literal tag is redundant" <|
                \() ->
                    """module Feature exposing (view)

import M3e.Unsafe as Unsafe


view =
    Unsafe.customElement "a" [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Redundant escape: `M3e.Unsafe.customElement` forges `<a>`, which `TypedHtml.a` already provides"
                                , details = customElementTagDetails "M3e.Unsafe.customElement" "a" "TypedHtml.a"
                                , under = "Unsafe.customElement"
                                }
                            ]
            , test "`customElement` applied to an element expression is mis-shaped" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.customElement (Html.node "avt-snackbar") [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Unsafe.customElement` takes a tag NAME, but is applied to an element expression"
                                , details = customElementShapeDetails "M3e.Unsafe.customElement"
                                , under = "Unsafe.customElement"
                                }
                            ]
            , test "`customElement` of a genuinely custom tag is legitimate" <|
                \() ->
                    """module Feature exposing (view)

import M3e.Unsafe as Unsafe


view =
    Unsafe.customElement "model-viewer" [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "the FIXED forms are clean: typed producers and a real custom element" <|
                \() ->
                    """module Feature exposing (view)

import M3e.Unsafe as Unsafe
import TypedHtml


view =
    [ TypedHtml.a [] []
    , TypedHtml.header [] []
    , TypedHtml.main_ [] []
    , Unsafe.customElement "avt-snackbar" [] []
    ]
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "`customElement` with a dynamic tag is silent" <|
                \() ->
                    """module Feature exposing (view)

import M3e.Unsafe as Unsafe


view tagName =
    Unsafe.customElement tagName [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            ]
        , describe "negative (not flagged)"
            [ test "escape of genuine Html is legitimate: `toHtml (Html.div [] [])`" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e


view =
    M3e.toHtml (Html.div [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "escape of a caller-supplied `Html msg` variable is legitimate" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view html =
    M3e.toHtml html
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "Unsafe.fromHtml of genuine Html is legitimate" <|
                \() ->
                    """module Feature exposing (view)

import Html
import M3e.Unsafe as Unsafe


view =
    Unsafe.fromHtml (Html.node "custom" [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "escape of a non-producer helper is not flagged" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.toHtml (viewThing 1)
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "escape of an unknown `M3e.*` value (not a component fact) is not flagged" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.toHtml (M3e.text "hello")
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "a plain producer call with no escape is untouched" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.button [] []
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "an UNconfigured Seam function wrapping a producer is not flagged" <|
                \() ->
                    """module Feature exposing (view)

import M3e
import Seam


view =
    Seam.asButton (M3e.button [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            , test "`fromHtml` outside the Unsafe module is not a render escape" <|
                \() ->
                    """module Feature exposing (view)

import M3e


view =
    M3e.fromHtml (M3e.button [] [])
"""
                        |> Review.Test.run config
                        |> Review.Test.expectNoErrors
            ]
        ]


rawTagMessage : String -> String -> String -> String
rawTagMessage escapeName tag producer =
    "Redundant escape: `" ++ escapeName ++ "` wraps a hand-written `<" ++ tag ++ ">` that `" ++ producer ++ "` already provides"


rawTagDetails : String -> String -> String -> List String
rawTagDetails escapeName tag producer =
    [ "`" ++ producer ++ "` produces `<" ++ tag ++ ">` as a typed `Element` with a closed, element-natural attribute row and a checked content model. Writing the tag by hand and lifting it through `" ++ escapeName ++ "` re-implements that producer with FREE rows, so the compiler checks neither the attributes nor where the result may be slotted."
    , "Use `" ++ producer ++ "` and reserve `" ++ escapeName ++ "` for `Html` the typed layer cannot produce — a custom element with no generated producer, or a caller-supplied `Html msg`. Retargeting is left to you (no autofix): the raw attribute list has to be translated to the typed setters, which surfaces attributes that were silently accepted on the wrong element."
    ]


customElementTagDetails : String -> String -> String -> List String
customElementTagDetails escapeName tag producer =
    [ "`" ++ escapeName ++ "` exists for a tag this library has NO generated producer for. `<" ++ tag ++ ">` is not such a tag: `" ++ producer ++ "` provides it as a typed `Element`, so forging it here discards the closed attribute row and the checked content model for nothing."
    , "Use `" ++ producer ++ "` and keep `" ++ escapeName ++ "` for genuine custom elements. Retargeting is left to you (no autofix): narrowing the free row to the typed one surfaces real type errors that need a human decision."
    ]


customElementShapeDetails : String -> List String
customElementShapeDetails escapeName =
    [ "`" ++ escapeName ++ "` has the shape `String -> List Attr -> List Element -> Element`: its first argument is the raw tag name of a custom element. Here it is applied to something that produces an element (a raw `Html.*` call or a known component producer), so the attributes and children that follow are being handed to the wrong function."
    , "Pass the tag name as a string literal (`" ++ escapeName ++ " \"my-element\" [] []`). Note the compiler rejects this call too, so this is a fast-feedback duplicate of a type error rather than a silent defect — you will see it whether or not this rule runs."
    ]


expectedDetails : String -> String -> List String
expectedDetails escapeName producerNoun =
    [ "`" ++ producerNoun ++ "` already returns a typed `Element` whose slot admittance the compiler checks. Applying `" ++ escapeName ++ "` to it drops to plain `Html` (or re-brands the phantom row), discarding exactly that checking — the reflexive \"drop to plain Html\" escape. A design pass showed heterogeneous typed composition already works, so this escape is usually redundant."
    , "Compose the typed `Element` directly — typed children of different components compose heterogeneously — and reserve `" ++ escapeName ++ "` for genuine `Html` the typed layer cannot produce (e.g. `Html.node`, or a caller-supplied `Html msg`). Retargeting is left to you (no autofix): removing the escape changes the expression's type, which propagates to whatever consumes the result and needs a human decision."
    ]
