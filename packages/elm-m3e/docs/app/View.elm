module View exposing
    ( View
    , fromElement, fromElements
    , title, body
    , map
    , Freezable, freeze, freezableToHtml, htmlToFreezable
    )

{-| The elm-pages view record for this app.

The page body is stored **erased** — as untyped IR nodes — because elm-pages
requires `View` to take exactly one type parameter, and a type alias cannot
carry the two phantom rows a typed `Element` needs.

That erasure is an implementation detail, not an interface.
[`fromElement`](#fromElement) accepts an `Element` with free rows and
[`body`](#body) hands one back, so no route and no shell module ever names a
`Node` or reaches for the IR itself. The type is opaque precisely so the
erasure cannot leak: this module is the only place it happens.

There is deliberately no TOC field here. An earlier version carried a
hand-built `List TocEntry` that every route had to enumerate itself
(`View.withToc [ { id = "api", label = "API" } ]`) -- which meant any
heading a route added without also updating that list silently never showed
up in the table of contents (exactly what happened: a whole page's
Usage/Variants/Sizes sections went missing this way). `Shared.tocPanel`
now mounts a single `m3e-toc` pointed at the content container instead; it
discovers headings from the real rendered DOM at runtime, so there is
nothing for a route to enumerate or forget.


## The view

@docs View
@docs fromElement, fromElements
@docs title, body
@docs map


## Frozen content

@docs Freezable, freeze, freezableToHtml, htmlToFreezable

-}

import Html exposing (Html)
import M3e.Html
import M3e.Unsafe


{-| A page: a title, and a body of renderable content.
-}
type View msg
    = View
        { title : String
        , body : List (M3e.Html.Node msg)
        }


{-| A page whose body is a single root element — the shape every route here
uses. The element's phantom rows are free, so any typed content fits.
-}
fromElement : String -> M3e.Html.Element accepts admittedBy msg -> View msg
fromElement pageTitle element =
    fromElements pageTitle [ element ]


{-| [`fromElement`](#fromElement) for a body with several roots.
-}
fromElements : String -> List (M3e.Html.Element accepts admittedBy msg) -> View msg
fromElements pageTitle elements =
    View
        { title = pageTitle
        , body = List.map M3e.Html.toNode elements
        }


{-| The page title.
-}
title : View msg -> String
title (View view) =
    view.title


{-| The page body, lifted back to typed elements for the shell to place.

The rows come back **free**: the body was erased on the way in, so nothing
about them was ever checked. This is the app's single re-assertion point, which
is the whole reason [`View`](#View) is opaque — one lift here instead of one at
every call site.

-}
body : View msg -> List (M3e.Html.Element accepts admittedBy msg)
body (View view) =
    List.map M3e.Unsafe.fromNode view.body


{-| Map the message type. Structural — the body is not rendered.
-}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn (View view) =
    View
        { title = view.title
        , body = List.map (M3e.Html.mapNode fn) view.body
        }


{-| The type of content that can be frozen. Must produce no messages (Never).
-}
type alias Freezable =
    Html Never


{-| Convert Freezable content to plain Html for server-side rendering.
-}
freezableToHtml : Freezable -> Html Never
freezableToHtml =
    identity


{-| Convert plain Html back to Freezable for client-side adoption.
-}
htmlToFreezable : Html Never -> Freezable
htmlToFreezable =
    identity


{-| Freeze a view so its content is rendered at build time.
-}
freeze : Freezable -> Html msg
freeze content =
    content
        |> freezableToHtml
        |> htmlToFreezable
        |> Html.map never
