module Mini.Element.Icon exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , child
    )

{-| The `mini-icon` component — strict per-component surface.

A shared icon atom.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Html as H
import Mini.Internal.Types.Icon
import Mini.Kind exposing (Available, Ctx, Used)
import Mini.Values


{-| The kind row `mini-icon` produces — the SHARED icon atom kind, admissible
into any library's opted-in slot.
-}
type alias Is s =
    Mini.Internal.Types.Icon.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Icon.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Mini.Internal.Types.Icon.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Icon.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Mini.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Mini.Internal.Types.Icon.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Mini.Internal.Types.Icon.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.icon


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
