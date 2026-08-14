module Or.Component.Plain exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , child
    )

{-| The `or-plain` component — strict per-component surface.

An element declaring NO attributes of its own, so every field in its `Attrs` row came from `_globals` — which makes an open global's absence from that row unambiguous.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Or.Attributes as A
import Or.Html as H
import Or.Internal.Types.Plain
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


{-| The kind row `or-plain` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Or.Internal.Types.Plain.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Or.Internal.Types.Plain.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Or.Internal.Types.Plain.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Or.Internal.Types.Plain.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.plain


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
