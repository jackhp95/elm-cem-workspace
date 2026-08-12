module HtmlIr.Attribute exposing
    ( Attr
    , map, toHtmlAttributes
    )

{-| The phantom-typed attribute shared by every library on this substrate. An
`Attr capability msg` is a list of DOM-facing facts carrying a phantom row of
the element capabilities that admit it; producers keep the row open
(`{ c | href : Supported }`) and each element constructor closes it, so the
compiler rejects an attribute on an element that does not admit it — including
events (`onClick` on a non-interactive element is a type error).

This module is the safe surface: minting an `Attr` — which asserts its row —
happens only in brand setters or the fenced forge in
[`HtmlIr.Internal`](HtmlIr-Internal).

@docs Attr
@docs map, toHtmlAttributes

-}

import Html
import HtmlIr.Internal as I


{-| The opaque phantom-typed attribute.
-}
type alias Attr capability msg =
    I.Attr capability msg


{-| Map the message type. Capability row preserved.
-}
map : (a -> b) -> Attr capability a -> Attr capability b
map =
    I.mapAttribute


{-| Unwrap to the underlying `Html.Attribute`s — the safe out-bound direction.

A list, because an `Attr` carries a list of facts: an absent attribute unwraps
to `[]`, and one setter may stand in for several attributes. `class` / `style`
facts within the `Attr` are merged, exactly as they would be on a node.

-}
toHtmlAttributes : Attr capability msg -> List (Html.Attribute msg)
toHtmlAttributes =
    I.toHtmlAttributes
