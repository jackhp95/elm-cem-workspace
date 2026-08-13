module Route.Guide.GeneratedAndInspectable exposing (ActionData, Data, Model, Msg, route)

{-| Guide (`/guide/generated-and-inspectable`): why the API is
trustworthy. The typed Elm modules are generated — from the component library's
published manifest plus a hand-authored `config/slots.json` — so no one types
the API by hand, and a component is not opaque HTML but inspectable data the
library turns into HTML exactly once, at the app root. That single fact is what
makes the later chapters (the linter, the seams) possible. No visual change to
the running example; the same Save button, seen for what it really is.
-}

import BackendTask
import Doc
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
view _ _ =
    View.fromElement "Generated, and data underneath"
        (Doc.pane
            [ TypedHtml.div [ TA.class "space-y-12" ]
                [ TypedHtml.section [ TA.class "space-y-4" ]
                    [ Doc.pageHeading "Generated, and data underneath"
                    , TypedHtml.div [ TA.class "max-w-2xl text-on-surface-variant" ] [ Doc.markdown intro ]
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


intro : String
intro =
    """You've built real things on this API. Before we lean on it any harder, one question: can you trust it? Two facts make the answer yes — and they're also what makes everything later in this guide possible."""


generated : String
generated =
    """**You don't type the API by hand — a generator writes it.** The component library ships a *manifest* — a machine-readable list of every component, its attributes, and its slots. A generator turns that manifest, together with one hand-authored file (`config/slots.json`, which records slot kinds and required attributes the manifest doesn't carry), into the typed Elm you import. The names, the attributes, the slots you'll learn are the components' own — not a per-component wrapper someone hand-maintains and forgets to update.

That does mean the API isn't *fully* automatic: when a new version of the components ships, you regenerate, and any component the manifest adds that `config/slots.json` doesn't yet cover falls back to loose `any` slots until the config is updated. So the API stays in step by a regen you run — not on its own — and because an uncovered component surfaces as loose `any` slots, that gap is visible in the generated output rather than silent."""


inspectable : String
inspectable =
    """**A component isn't opaque HTML — it's inspectable data.** `M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]` doesn't produce HTML on the spot. It builds a small value the library can *read*: it knows this is a button, that it's filled, that its content is the text "Save". Your whole page stays as this readable data right up until one conversion — `M3e.toNode` — at your app's root, which turns the entire tree into HTML exactly once.

Because the library can inspect what you built *before* it becomes HTML, it can enforce rules a plain HTML wrapper never could — the next chapters are all cashing in on this one fact."""


rootCode : String
rootCode =
    """-- your page stays inspectable data all the way up…
saveButton =
    M3e.button [ M3e.Attributes.variant Value.filled ] [ M3e.text "Save" ]


-- …and becomes HTML exactly once, at the root:
view model =
    M3e.toNode saveButton"""


recap : String
recap =
    """- The Elm API is **generated from the components' published manifest + a hand-authored `config/slots.json`** — you regenerate on each upstream release; anything the config doesn't cover yet surfaces as loose `any` slots.
- A component is **inspectable data** the library reads, then turns into HTML **once, at the root** (`M3e.toNode`).
- That's why the library can catch mistakes the browser never sees.
- **Next: [The surface map](/guide/the-layers) →** the same button, shown through each of its interchangeable surfaces — and the loud escapes for leaving the typed tree."""
