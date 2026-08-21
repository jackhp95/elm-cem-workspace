module Route.Guide.FirstComponent exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/first-component`): the happy path — import a
component and put it on screen. Starts the running "Account settings" example
with a card, a title, and a Save button, genuinely constructed and shown beside
their exact source. Written in the one-import barrel, options-list form
(`M3e.<name> [ attributes ] [ children ]`).
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Action
import M3e.Attributes
import M3e.Element.Button
import M3e.Element.Card
import M3e.Element.Heading
import M3e.Kind
import M3e.Values as Value
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
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
    BackendTask.File.rawFile "content/guides/FirstComponent.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Import a component and put it on screen — the start of the running settings example in the elm-m3e Guide."
        , locale = Nothing
        , title = "Your first component · elm-m3e"
        }
        |> Seo.website


{-| The running example, step 1: an Account settings card with a title and a
Save button, in the one-import barrel, options-list form. Genuinely constructed —
this is the value rendered on the page and printed in the source block below, so
the two can never drift.
-}
settingsCard : Element { s | card : M3e.Kind.Brand } adm_ msg
settingsCard =
    M3e.card [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Element.Card.header
            (M3e.Element.Heading.component { content = M3e.text "Account settings" } [ M3e.Attributes.variant Value.title, M3e.Attributes.level 2 ] [])
        , M3e.Element.Card.content
            (M3e.Element.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Attributes.variant Value.filled ] [])
        ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        body : String
        body =
            Doc.section "body" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Your first component"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Your first component"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown body
                    , settingsCard
                    , Doc.codeBlock Doc.Elm source
                    , Doc.userlandNote
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


source : String
source =
    """import M3e
import M3e.Attributes
import M3e.Element.Card
import M3e.Values as Value
import M3e.Element.Heading
import M3e.Element.Button


settingsCard =
    M3e.card [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Element.Card.header
            (M3e.Element.Heading.component { content = M3e.text "Account settings" } [ M3e.Attributes.variant Value.title, M3e.Attributes.level 2 ] [])
        , M3e.Element.Card.content
            (M3e.Element.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Attributes.variant Value.filled ] [])
        ]"""
