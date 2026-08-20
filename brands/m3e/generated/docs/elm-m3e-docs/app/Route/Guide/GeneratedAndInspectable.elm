module Route.Guide.GeneratedAndInspectable exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/generated-and-inspectable`): why the API is
trustworthy. The typed Elm modules are generated — from the component library's
published manifest plus a hand-authored `config/slots.json` — so no one types
the API by hand, and a component is not opaque HTML but inspectable data the
library turns into HTML exactly once, at the app root. That single fact is what
makes the later chapters (the linter, the seams) possible. No visual change to
the running example; the same Save button, seen for what it really is.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
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
    BackendTask.File.rawFile "content/guides/GeneratedAndInspectable.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "The API is generated from the components' published manifest plus a hand-authored config/slots.json, and is inspectable data underneath — turned into HTML exactly once, at the app root."
        , locale = Nothing
        , title = "Generated, and data underneath · elm-m3e"
        }
        |> Seo.website


{-| The same Save button from "Your first component" — unchanged. The point of this chapter is
not a new visual, but seeing that this value is data the library holds and
controls until the single conversion at the root.
-}
saveButton : Element { s | button : M3e.Kind.Brand } adm_ msg
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    let
        d : Dict String String
        d =
            app.data

        intro : String
        intro =
            Doc.section "intro" d

        generated : String
        generated =
            Doc.section "generated" d

        inspectable : String
        inspectable =
            Doc.section "inspectable" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Generated, and data underneath"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Generated, and data underneath"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown generated ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown inspectable
                    , Doc.showcase saveButton
                    , Doc.codeBlock Doc.Elm rootCode
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


rootCode : String
rootCode =
    """-- your page stays inspectable data all the way up…
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]


-- …and becomes HTML exactly once, at the root:
view model =
    M3e.toNode saveButton"""
