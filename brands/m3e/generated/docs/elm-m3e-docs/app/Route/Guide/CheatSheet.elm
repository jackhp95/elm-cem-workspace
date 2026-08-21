module Route.Guide.CheatSheet exposing (ActionData, Data, Model, Msg, route)

{-| Guide · Cheat sheet (`/guide/cheat-sheet`): the return-worthy tables in one
place — the surfaces, the strictness dial, loose vs. tight vocabulary, and where
a seam is allowed to live. Scannable reference, not narrative; the chapters teach
these, this is where you come back to look them up.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import M3e
import M3e.Attributes
import M3e.Element.Heading
import M3e.Values as Value
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Element.Sectioning
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    Dict String String


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = data }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.File.rawFile "content/guides/CheatSheet.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "The Guide cheat sheet: the surfaces, the strictness dial, loose vs. tight vocabulary, and the seam allow-list — the return-worthy tables in one place."
        , locale = Nothing
        , title = "Cheat sheet · elm-m3e"
        }
        |> Seo.website


card : String -> List (M3e.Element (M3e.Element.Heading.Is s) (TypedHtml.Element.Sectioning.SectionChildAdmittedBy childAdm) msg) -> M3e.Element (TypedHtml.Element.Sectioning.SectionIs s2) adm_ msg
card title items =
    TypedHtml.section [ TA.class "space-y-3" ]
        (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text title ] :: items)


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        layers : String
        layers =
            Doc.section "layers" d

        barrelVsSpecific : String
        barrelVsSpecific =
            Doc.section "barrelVsSpecific" d

        shapes : String
        shapes =
            Doc.section "shapes" d

        dial : String
        dial =
            Doc.section "dial" d

        seams : String
        seams =
            Doc.section "seams" d
    in
    View.fromElement "Cheat sheet"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-10" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Cheat sheet"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    , Doc.userlandNote
                    ]
                , card "The surfaces" [ Doc.markdown layers ]
                , card "Barrel vs component module" [ Doc.markdown barrelVsSpecific, Doc.codeBlock Doc.Elm barrelVsSpecificCode ]
                , card "The three forms" [ Doc.markdown shapes, Doc.codeBlock Doc.Elm shapesCode ]
                , card "The strictness dial" [ Doc.markdown dial ]
                , card "Where a seam may live" [ Doc.markdown seams ]
                ]
            ]
        )


barrelVsSpecificCode : String
barrelVsSpecificCode =
    """-- barrel — one import, shared vocabulary (M3e.Attributes.* unions, lint-checked)
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.Element.Button.icon (M3e.icon [ TA.name "save" ] []), M3e.text "Save" ]

-- component module — component-scoped setters, compile-tight tokens
M3e.Element.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Element.Button.variant Value.filled ] []"""


shapesCode : String
shapesCode =
    """-- the standard form — everything optional; the tersest
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- required-record form — the compiler demands the parts it can't do without
M3e.Element.Button.component { content = M3e.text "Save", action = M3e.Action.onClick Save } [] []

-- builder pipe — a one-only setter is unwritable twice; order-free
M3e.Build.Button.build { content = M3e.text "Save", action = M3e.Action.onClick Save }
    |> M3e.Build.Button.toElement"""
