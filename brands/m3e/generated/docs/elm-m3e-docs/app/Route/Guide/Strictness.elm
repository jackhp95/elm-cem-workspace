module Route.Guide.Strictness exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/strictness`): choose how strict your project is.
The compiler enforces kinds and valid tokens but deliberately leaves the softer
"did you fill the required slot?" loose on the standard surface, so that tax
doesn't land on every call site. You dial those back up two ways: a linter that knows
your components, and stricter call-shapes you opt into per component (options
list, required record, pipeline) — peers, each promoting one advisory check to a
compile guarantee. The live demo stays the barrel Save button; the alternative
shapes are shown as code with their real compiler output.
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
import M3e.Element.Button
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
    BackendTask.File.rawFile "content/guides/Strictness.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Start easy and turn safety up by choice. A linter that knows your components, plus stricter call-shapes you opt into per component — no all-or-nothing."
        , locale = Nothing
        , title = "The strictness dial · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, in the default options-list shape — the standard,
easy top. The stricter shapes are shown as code below, each rendering the same
button; they only change what you're allowed to leave out.
-}
saveButton : Element { s | button : M3e.Kind.Brand } adm_ msg
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ]
        [ M3e.Element.Button.icon (M3e.icon [ TA.name "save" ] [])
        , M3e.text "Save"
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

        linter : String
        linter =
            Doc.section "linter" d

        shapes : String
        shapes =
            Doc.section "shapes" d

        recordAha : String
        recordAha =
            Doc.section "recordAha" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "The strictness dial"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The strictness dial"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown linter ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown shapes
                    , Doc.showcase saveButton
                    , Doc.codeBlock Doc.Elm shapesCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown recordAha
                    , Doc.codeBlock Doc.NoLang recordError
                    ]
                , Doc.recapBox recap
                ]
            ]
        )


shapesCode : String
shapesCode =
    """-- the standard form — everything optional; the tersest, easiest form
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- required-record form (`component`) — the compiler now DEMANDS the parts a button can't do without
M3e.Element.Button.component
    { content = M3e.text "Save", action = M3e.Action.onClick SaveClicked }
    []
    []

-- builder pipe (`build`/`toElement`) — a one-only setter becomes UNWRITABLE twice; order-free
M3e.Build.Button.build
    { content = M3e.text "Save", action = M3e.Action.onClick SaveClicked }
    |> M3e.Build.Button.toElement"""


recordError : String
recordError =
    """The 1st argument to `component` is not what I expect:

4| M3e.Element.Button.component { content = M3e.text "Save" } [] []
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This argument is a record of type:

    { content : … }

But `component` needs the 1st argument to be:

    { action : Action { … } msg, content : … }"""
