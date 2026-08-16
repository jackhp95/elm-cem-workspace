module M3e.Component.Badge exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Position, position, Size, size
    , for
    , child
    )

{-| The `m3e-badge` component — strict per-component surface.

A visual indicator used to label content.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Position, position, Size, size
@docs for
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Badge
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-badge` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Badge.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Badge.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Badge.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Badge.ChildAdmittedBy childAdm


{-| The `position` values valid on this component (compile-tight narrowing).
-}
type alias Position =
    M3e.Internal.Types.Badge.Position


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.Badge.Size


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Badge.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Badge.AttrCaps


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
    H.badge


{-| The position of the badge, when attached to another element. (default: `"above-after"`)
-}
position : Value Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (Val.toString value_)


{-| The size of the badge. (default: `"medium"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
