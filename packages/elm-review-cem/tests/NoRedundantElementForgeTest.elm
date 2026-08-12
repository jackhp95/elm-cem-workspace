module NoRedundantElementForgeTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import NoRedundantElementForge exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A slice of the tags `TypedHtml.*` covers — the shape of
`TypedHtml.Review.Facts.facts`, one entry per HTML tag with `component` = the tag
name. Every `Fact` field is written explicitly (matching `tests/Fixtures.elm`),
so a new field breaks this file loudly rather than silently defaulting. Only
`.component` drives the covered-tag set the rule builds.
-}
coveredFacts : List Facts.Fact
coveredFacts =
    [ tagFact "div"
    , tagFact "span"
    , tagFact "a"
    , tagFact "label"

    -- `<main>` is escaped by elm-cem to the producer `main_` (a top-level `main`
    -- is the program entry), so its fact carries `component = "main_"` /
    -- `module_ = "TypedHtml.Main_"`. The covered set must still key on the raw
    -- tag `"main"` so a forged `Ir.node "main"` is flagged.
    , { component = "main_"
      , module_ = "TypedHtml.Main_"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


tagFact : String -> Facts.Fact
tagFact tag =
    { component = tag
    , module_ = "TypedHtml." ++ capitalize tag
    , enums = []
    , requiredSlots = []
    , multiSlots = []
    , attrRewrites = []
    , slotRewrites = []
    , slotKinds = []
    , slotUpgrades = []
    , facets = [ Standard, Build ]
    , requiredAttrs = []
    , actionMap = []
    , groupConstructors = []
    , usesAction = False
    }


capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s


all : Test
all =
    describe "NoRedundantElementForge"
        [ describe "positive (flagged)"
            [ test "point-free producer through a local forge helper: `div = node \"div\"`" <|
                \() ->
                    """module Native exposing (div, node)

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir


node tagName attrs kids =
    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))


div =
    node "div"
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`div` re-implements `TypedHtml.div` over the IR forge"
                                , details = expectedDetails "div"
                                , under = "\"div\""
                                }
                            ]
            , test "direct producer forging `Ir.node \"span\"` under a local helper module" <|
                \() ->
                    """module Native exposing (span)

import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir


span attrs kids =
    Ir.fromNode
        (Ir.node "span" attrs (List.map HtmlIr.Element.toNode kids))
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`span` re-implements `TypedHtml.span` over the IR forge"
                                , details = expectedDetails "span"
                                , under = "\"span\""
                                }
                            ]
            , test "forged `<main>` is flagged though its producer/component name is escaped to `main_`" <|
                \() ->
                    """module Native exposing (main_)

import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir


main_ attrs kids =
    Ir.fromNode
        (Ir.node "main" attrs (List.map HtmlIr.Element.toNode kids))
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`main_` re-implements `TypedHtml.main` over the IR forge"
                                , details = expectedDetails "main"
                                , under = "\"main\""
                                }
                            ]
            , test "top-level `foo = Ir.fromNode (Ir.node \"a\" ...)` direct form" <|
                \() ->
                    """module Native exposing (foo)

import HtmlIr.Internal as Ir


foo =
    Ir.fromNode (Ir.node "a" [] [])
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`foo` re-implements `TypedHtml.a` over the IR forge"
                                , details = expectedDetails "a"
                                , under = "\"a\""
                                }
                            ]
            ]
        , describe "negative (not flagged)"
            [ test "custom element via literal but uncovered tag: `Ir.node \"compass-passkey\"`" <|
                \() ->
                    """module Native exposing (passkey)

import HtmlIr.Internal as Ir


passkey attrs kids =
    Ir.fromNode
        (Ir.node "compass-passkey" attrs (List.map HtmlIr.Element.toNode kids))
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "variable tag through a local helper: `custom name = node name`" <|
                \() ->
                    """module Native exposing (custom, node)

import HtmlIr.Internal as Ir


node tagName attrs kids =
    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))


custom name =
    node name
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "variable tag forged directly: `node tagName = Ir.node tagName`" <|
                \() ->
                    """module Native exposing (node)

import HtmlIr.Internal as Ir


node tagName attrs kids =
    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "a `div`-named function that does NOT forge is untouched" <|
                \() ->
                    """module Native exposing (div)

import HtmlIr.Internal as Ir


div x =
    x + 1
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "attribute/event escapes (fromHtmlAttribute, not node) are not flagged" <|
                \() ->
                    """module Native exposing (attribute, onClick, style)

import Html.Attributes
import Html.Events
import HtmlIr.Internal as Ir


attribute name value =
    Ir.fromHtmlAttribute (Html.Attributes.attribute name value)


style key value =
    Ir.fromHtmlAttribute (Html.Attributes.style key value)


onClick msg =
    Ir.fromHtmlAttribute (Html.Events.onClick msg)
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "a module that does NOT import HtmlIr.Internal is never inspected" <|
                \() ->
                    """module Widget exposing (div)

import Html
import Html.Attributes


div attrs kids =
    Html.node "div" attrs kids
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "false-positive bait (advisory silence)"
            [ test "tag chosen in a `case` (unresolvable) is not flagged" <|
                \() ->
                    """module Native exposing (heading, node)

import HtmlIr.Internal as Ir


node tagName attrs kids =
    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))


heading level attrs kids =
    let
        tag =
            case level of
                1 ->
                    "h1"

                _ ->
                    "h2"
    in
    node tag attrs kids
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "tag chosen in an `if` (unresolvable) is not flagged" <|
                \() ->
                    """module Native exposing (either)

import HtmlIr.Internal as Ir


either cond attrs kids =
    Ir.fromNode
        (Ir.node
            (if cond then
                "div"

             else
                "span"
            )
            attrs
            (List.map HtmlIr.Element.toNode kids)
        )
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            , test "tag returned by a helper function (unresolvable) is not flagged" <|
                \() ->
                    """module Native exposing (fromPicked, node)

import HtmlIr.Internal as Ir


node tagName attrs kids =
    Ir.fromNode
        (Ir.node tagName attrs (List.map HtmlIr.Element.toNode kids))


pick =
    "div"


fromPicked attrs kids =
    node pick attrs kids
"""
                        |> Review.Test.run (rule coveredFacts)
                        |> Review.Test.expectNoErrors
            ]
        ]


expectedDetails : String -> List String
expectedDetails tag =
    [ "This producer forges a plain `<" ++ tag ++ ">` through `HtmlIr.Internal`, but `TypedHtml." ++ tag ++ "` already provides that element with a closed, element-natural attribute row. The hand-rolled forge accepts a fully-open attribute row (any `Attr` on any element), so it re-implements the typed producer layer while dropping the very constraint that layer exists to give."
    , "Use `TypedHtml." ++ tag ++ "` and reserve `HtmlIr.Internal` for what the typed layer cannot express: custom elements, event escapes, and arbitrary attributes or styles. Retargeting is left to you (no autofix), because narrowing the open row to the closed one surfaces real type errors — attributes that were silently accepted on the wrong element — that need a human decision."
    ]
