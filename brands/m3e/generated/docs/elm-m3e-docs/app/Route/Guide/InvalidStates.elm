module Route.Guide.InvalidStates exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/invalid-states`): the headline promise, felt.
Every piece carries an invisible tag for the KIND of content it is; every slot
says which kinds it accepts; a mismatch is a compile error. The running Save
button gains an icon (valid), and putting the wrong kind of thing in the icon
slot stops the build — shown as the real compiler output, not an assertion.
-}

import BackendTask exposing (BackendTask)
import BackendTask.File
import Dict exposing (Dict)
import Doc
import FatalError exposing (FatalError)
import Guide.Samples as Samples
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
    BackendTask.File.rawFile "content/guides/InvalidStates.md"
        |> BackendTask.map Doc.sections
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "Every piece is tagged with its kind of content and every slot says which kinds it accepts, so a wrong composition is a compile error — the browser never sees the mistake."
        , locale = Nothing
        , title = "Invalid states don't compile · elm-m3e"
        }
        |> Seo.website


{-| The running Save button, now with a leading icon in its dedicated icon slot.
This is the VALID version — the one that renders. The chapter's failures are
shown as real compiler text, not built here.
-}



-- @sample-source-body guideSavedButton


savedButton : Element { s | button : M3e.Kind.Brand } adm_ msg
savedButton =
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

        valid : String
        valid =
            Doc.section "valid" d

        broken : String
        broken =
            Doc.section "broken" d

        readError : String
        readError =
            Doc.section "readError" d

        recap : String
        recap =
            Doc.section "recap" d
    in
    View.fromElement "Invalid states don't compile"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Invalid states don't compile"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown valid
                    , Doc.showcase savedButton
                    , Doc.codeBlock Doc.Elm Samples.guideSavedButton
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown broken
                    , Doc.codeBlock Doc.Elm brokenCode
                    , Doc.codeBlock Doc.NoLang errorText
                    , Doc.markdown readError
                    ]
                , Doc.recapBox recap
                ]
            ]
        )



-- @sample expect-compile-error: this page's subject. The `icon` slot admits the
-- `icon` kind and a Chip does not name it, so the compiler refuses this call —
-- which is exactly what the page tells the reader, and now proves.


brokenCode : String
brokenCode =
    """M3e.button [ M3e.Attributes.variant Value.filled ]
    [ M3e.Element.Button.icon (M3e.chip [] [ M3e.text "not an icon" ])
    , M3e.text "Save"
    ]"""


errorText : String
errorText =
    """The 1st argument to `icon` is not what I expect:

9|     [ M3e.Element.Button.icon (M3e.chip [] [ M3e.text "not an icon" ])
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This `chip` call produces:

    Element { a | chip : M3e.Kind.Brand, icon : M3e.Kind.Brand, ... } adm_ msg

But `icon` needs the 1st argument to be:

    Element { icon : M3e.Kind.Brand, loadingIndicator : M3e.Kind.Brand } adm_ msg

Hint: Seems like a record field typo. Maybe chip should be icon?"""
