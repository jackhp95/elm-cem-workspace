port module FromHtmlTest exposing (main)

{-| Unit tests for `Compose.FromHtml`'s HTML→`ExampleNode`/`Msg` parsing,
against real `html` strings copied verbatim from `data/examples.json`
(`list`, `appbar`, `button`).

Run via `elm make` + a tiny node runner (see `scripts/run-elm-worker-test.cjs`,
invoked as `node scripts/run-elm-worker-test.cjs <compiled-elm.js> FromHtmlTest`);
the docs project has no `elm-test` runner wired, so this is a self-checking
`Platform.worker` that emits per-case `PASS`/`FAIL` diagnostics plus a final
structured `RESULT ok=<passed>/<total>` line through a port, matching
`tests/FoldTest.elm`'s convention.

`Compose.FromHtml` itself must stay brand-agnostic (no `M3e` import); this
test module is the one place allowed to reach for real `M3e` facts, since it
exercises the parser against real component data rather than defining it.

-}

import Cem.Compose
import Cem.Facts exposing (Fact)
import Compose.Attrs as Attrs
import Compose.FromHtml as FromHtml exposing (ExampleChild(..), ExampleNode)
import Dict exposing (Dict)
import M3e.Review.Facts


port emit : String -> Cmd msg


parseCtx : { facts : List Fact, attrKinds : Dict String Cem.Compose.AttrKind }
parseCtx =
    { facts = M3e.Review.Facts.facts, attrKinds = Attrs.kinds }


{-| `data/examples.json`'s `list.examples[0].html` — Anatomy. Exercises
nesting (`list` > `listItem`), a `slot="..."` child that resolves to a real
component (`m3e-icon slot="leading"`), slotted children with no matching
component (the `overline`/`supporting-text`/`trailing` `<span>`s, dropped),
and a bare, unwrapped text child (`Headline`).
-}
listHtml : String
listHtml =
    """<m3e-list>
  <m3e-list-item>
    <m3e-icon slot="leading" name="person"></m3e-icon>
    <span slot="overline">Overline</span>
    Headline
    <span slot="supporting-text">Supporting text</span>
    <span slot="trailing">100+</span>
  </m3e-list-item>
</m3e-list>"""


{-| `data/examples.json`'s `appbar.examples[0].html` — Anatomy. Exercises two
`slot="..."` children resolving to real components (`iconButton` in
`leading`/`trailing`), an enum attr on one of them (`variant="tonal"`), a
dropped non-enum attr (`aria-label`), and two dropped slotted children with no
matching component (the `title`/`subtitle` `<span>`s).
-}
appBarHtml : String
appBarHtml =
    """<m3e-app-bar>
  <m3e-icon-button slot="leading" aria-label="Back">
    <m3e-icon name="arrow_back"></m3e-icon>
  </m3e-icon-button>
  <span slot="title">Top 10 hiking trails</span>
  <span slot="subtitle">Discover popular trails</span>
  <m3e-icon-button slot="trailing" aria-label="Bookmark" variant="tonal">
    <m3e-icon name="bookmark" filled=""></m3e-icon>
  </m3e-icon-button>
</m3e-app-bar>"""


{-| `data/examples.json`'s `button.examples[0].html` — five sibling top-level
buttons; `parse` only ever takes the first. Exercises a bare text child with
no nesting at all, alongside an enum attr (`variant="elevated"`).
-}
buttonHtml : String
buttonHtml =
    """<m3e-button variant="elevated">Elevated</m3e-button>
<m3e-button variant="filled">Filled</m3e-button>
<m3e-button variant="tonal">Tonal</m3e-button>
<m3e-button variant="outlined">Outlined</m3e-button>
<m3e-button variant="text">Text</m3e-button>"""


expectedList : ExampleNode
expectedList =
    { component = "list"
    , attrs = []
    , children =
        [ ( "unnamed"
          , [ ChildElem
                { component = "listItem"
                , attrs = []
                , children =
                    [ ( "leading", [ ChildIcon "person" ] )
                    , ( "unnamed", [ ChildText "Headline" ] )
                    ]
                }
            ]
          )
        ]
    }


expectedAppBar : ExampleNode
expectedAppBar =
    { component = "appBar"
    , attrs = []
    , children =
        [ ( "leading"
          , [ ChildElem
                { component = "iconButton"
                , attrs = []
                , children = [ ( "unnamed", [ ChildIcon "arrow_back" ] ) ]
                }
            ]
          )
        , ( "trailing"
          , [ ChildElem
                { component = "iconButton"
                , attrs = [ ( "variant", Cem.Compose.AttrEnum "tonal" ) ]
                , children = [ ( "unnamed", [ ChildIcon "bookmark" ] ) ]
                }
            ]
          )
        ]
    }


expectedButton : ExampleNode
expectedButton =
    { component = "button"
    , attrs = [ ( "variant", Cem.Compose.AttrEnum "elevated" ) ]
    , children = [ ( "unnamed", [ ChildText "Elevated" ] ) ]
    }


parseCases : List ( String, String, Maybe ExampleNode )
parseCases =
    [ ( "list Anatomy: nesting, a resolved slot child, dropped slot children, a bare text child", listHtml, Just expectedList )
    , ( "appbar Anatomy: two resolved slot children (one with an enum attr), a dropped non-enum attr, two dropped slot children", appBarHtml, Just expectedAppBar )
    , ( "button: bare text child with an enum attr, no nesting", buttonHtml, Just expectedButton )
    ]


runParseCase : ( String, String, Maybe ExampleNode ) -> ( Bool, String )
runParseCase ( name, html, expected ) =
    let
        got : Maybe ExampleNode
        got =
            FromHtml.parse parseCtx html
    in
    if got == expected then
        ( True, "PASS  " ++ name )

    else
        ( False
        , "FAIL  "
            ++ name
            ++ "\n        expected: "
            ++ Debug.toString expected
            ++ "\n        got:      "
            ++ Debug.toString got
        )


{-| `toMsgs` applied to the parsed `list` example, replayed through
`Cem.Compose.update` from a fresh `"list"` root, must produce the same tree
the HTML described: one `listItem` holding a `"person"` leading icon and an
unnamed `"Headline"` text child.
-}
toMsgsCase : ( Bool, String )
toMsgsCase =
    let
        name : String
        name =
            "toMsgs replayed through Cem.Compose.update rebuilds the list example"

        model : Cem.Compose.Model
        model =
            Cem.Compose.init { facts = M3e.Review.Facts.facts, attrKinds = Attrs.kinds, root = "list" }

        applied : Cem.Compose.Model
        applied =
            case FromHtml.parse parseCtx listHtml of
                Just parsed ->
                    List.foldl Cem.Compose.update model (FromHtml.toMsgs [] parsed)

                Nothing ->
                    model

        listItemSlots : List ( String, List Cem.Compose.Child )
        listItemSlots =
            Cem.Compose.nodeAt [ Cem.Compose.IntoSlot "unnamed" 0 ] applied
                |> Maybe.map Cem.Compose.slotsOf
                |> Maybe.withDefault []

        got : ( String, List String, List ( String, List Cem.Compose.Child ) )
        got =
            ( Cem.Compose.componentOf applied.root
            , Cem.Compose.slotsOf applied.root |> List.map Tuple.first
            , listItemSlots
            )

        expected : ( String, List String, List ( String, List Cem.Compose.Child ) )
        expected =
            ( "list"
            , [ "unnamed" ]
            , [ ( "leading", [ Cem.Compose.ChildIcon "person" ] )
              , ( "unnamed", [ Cem.Compose.ChildText "Headline" ] )
              ]
            )
    in
    if got == expected then
        ( True, "PASS  " ++ name )

    else
        ( False
        , "FAIL  "
            ++ name
            ++ "\n        expected: "
            ++ Debug.toString expected
            ++ "\n        got:      "
            ++ Debug.toString got
        )


report : String
report =
    let
        results : List ( Bool, String )
        results =
            List.map runParseCase parseCases ++ [ toMsgsCase ]

        passed : Int
        passed =
            List.filter Tuple.first results |> List.length

        total : Int
        total =
            List.length results

        lines : String
        lines =
            List.map Tuple.second results |> String.join "\n"

        summary : String
        summary =
            "\n"
                ++ String.fromInt passed
                ++ "/"
                ++ String.fromInt total
                ++ " passed"
                ++ (if passed == total then
                        " — OK"

                    else
                        " — FAILURES"
                   )

        result : String
        result =
            "\nRESULT ok=" ++ String.fromInt passed ++ "/" ++ String.fromInt total
    in
    lines ++ summary ++ result


main : Program () () ()
main =
    Platform.worker
        { init = \_ -> ( (), emit report )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
