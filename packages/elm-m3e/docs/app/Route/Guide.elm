module Route.Guide exposing (ActionData, Data, Model, Msg, route)

{-| The Guide index (`/guide`): the thesis and the chapter path. A single linear
walkthrough that teaches the library by building one real account settings panel,
one idea at a time.
-}

import BackendTask
import Doc
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Kind
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
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image = { url = [ "favicon.svg" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
        , description = "The Guide: build a real Material 3 UI in Elm where invalid states don't compile, one small step at a time."
        , locale = Nothing
        , title = "The Guide · elm-m3e"
        }
        |> Seo.website


chapterLink : String -> String -> Element { s | assistChip : M3e.Kind.Brand } admittedBy msg
chapterLink href label =
    Doc.anchorPill { href = href, label = label }


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "The Guide"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "The Guide"
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown intro ]
                    ]
                , TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.markdown chaptersLead
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/first-component" "Your first component"
                        , chapterLink "/guide/invalid-states" "Invalid states don't compile"
                        , chapterLink "/guide/strictness" "The strictness dial"
                        , chapterLink "/guide/accessible-by-construction" "Accessibility you can't forget"
                        , chapterLink "/guide/accessibility" "Accessibility reference"
                        , chapterLink "/guide/composition-text-field" "Composition, not injection"
                        , chapterLink "/guide/theming" "Theming with tokens"
                        , chapterLink "/guide/motion" "Motion"
                        , chapterLink "/guide/generated-and-inspectable" "Generated & inspectable"
                        , chapterLink "/guide/the-layers" "The surface map"
                        , chapterLink "/guide/seams" "Your own seam"
                        , chapterLink "/guide/tooling-refactors" "The tooling refactors for you"
                        , chapterLink "/guide/troubleshooting" "Troubleshooting"
                        , chapterLink "/guide/how-we-prove-it" "How we prove it"
                        ]
                    , TypedHtml.div [ TA.class "max-w-2xl" ] [ Doc.markdown chaptersNote ]
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/cheat-sheet" "Cheat sheet"
                        , chapterLink "/guide/glossary" "Glossary"
                        , chapterLink "/guide/reference" "Full API reference"
                        , chapterLink "/guide/roundtrip" "Round-trip report"
                        ]
                    ]
                ]
            ]
        )


intro : String
intro =
    """Build a real Material 3 UI in Elm where invalid states don't compile — and know exactly what to do when you need to break the rules. This guide gets you there a small step at a time, building one account settings panel and teaching the idea behind each step.

The whole thing in one line: **the correct way and the easy way are the same way. You step outside the typed tree, loudly and on purpose, only to escape.** A few checks stay loose by default so the tax doesn't land on every call site; [the strictness dial](/guide/strictness) is how you turn those back up when you want them."""


chaptersLead : String
chaptersLead =
    """### Chapters

Each chapter is one win, and each builds on the last. Start at the top."""


chaptersNote : String
chaptersNote =
    """Eleven chapters, build-first: put a component on screen, feel invalid states refuse to compile, turn the strictness dial, keep accessibility, compose real things, then step back for the map of *why* it works — generated and inspectable, the surface map, your own seams, the tooling that refactors for you, and how it all stays honest. Work them top to bottom."""
