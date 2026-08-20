module Route.Guide.TheLayers exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/the-layers`): the orienting map. A component is not a
stack of layers you descend; it is one typed value you can write through a
handful of interchangeable **surfaces** (barrel, `component`, `build`), plus a
few loud **escapes** for leaving the typed tree. The running example doesn't
change; the same Save button is shown live once and its surfaces are shown as
code, with the "hand-writing raw HTML the library already ships" tell.
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
    BackendTask.File.rawFile "content/guides/TheLayers.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "A component is one typed value written through interchangeable surfaces — barrel, view, el, build. You leave the typed tree only through a few loud, named escapes."
        , locale = Nothing
        , title = "The surface map · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, written through the barrel surface — the one you
reach for by default. The chapter shows the other surfaces as code; they all
produce this same slottable value, so one live demo covers them all.
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

        layers : String
        layers =
            Doc.section "layers" d

        sameButton : String
        sameButton =
            Doc.section "sameButton" d

        tell : String
        tell =
            Doc.section "tell" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "The surface map"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The surface map"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown layers
                    , Doc.codeBlock Doc.NoLang layersDiagram
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown sameButton
                    , Doc.showcase saveButton
                    , Doc.codeBlock Doc.Elm descentCode
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown tell ]
                , Doc.recapBox recap
                ]
            ]
        )


layersDiagram : String
layersDiagram =
    """SURFACES — same typed value, different call shape (a horizontal choice)
  M3e.button …                     barrel: one import, every component's `component`
  M3e.Component.Divider.component [ … ] …           the standard/list form (no required record)
  M3e.Component.Button.component { … } …            required-record form (the 29 with a required record)
  M3e.Build.Button.build { … } |> …      builder pipe, closed by M3e.Build.Button.toElement

LOOSENESS — opt out of the strict phantom rows, still in the IR
  M3e.Html.button …                the loose producer (open rows, no slot checking)

ESCAPES — leave the typed tree (loud, greppable, lint-fenced)
  M3e.Unsafe.fromHtml …            wrap raw elm/html; free rows, checks nothing
  M3e.Unsafe.recast …              re-kind an Element so it fits any slot
  M3e.Unsafe.customElement …       forge a custom-element tag as a slot-ready Element"""


descentCode : String
descentCode =
    """-- barrel: one import, the standard form — the default
M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]

-- component module: same output, component-scoped tighter types
M3e.Component.Button.component { content = M3e.text "Save", action = M3e.Action.none } [ M3e.Component.Button.variant Value.filled ] []

-- required-record form: the compiler demands the parts a button can't omit
M3e.Component.Button.component { content = M3e.text "Save", action = M3e.Action.onClick Save } [] []

-- builder pipe: a one-only setter is unwritable twice; order-free
M3e.Build.Button.build { content = M3e.text "Save", action = M3e.Action.onClick Save }
    |> M3e.Build.Button.withVariant Value.filled
    |> M3e.Build.Button.toElement"""
