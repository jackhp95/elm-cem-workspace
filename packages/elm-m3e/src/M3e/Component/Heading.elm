module M3e.Component.Heading exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Size, size, Variant, variant
    , emphasized, level, tocIgnore
    , child
    )

{-| The `m3e-heading` component — strict per-component surface.

A heading to a page or section.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs emphasized, level, tocIgnore
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Heading
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-heading` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Heading.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Heading.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Heading.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Heading.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.Heading.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Heading.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Heading.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Heading.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.heading attrs (required_.content :: children)


{-| The size of the heading. (default: `"medium"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The appearance variant of the heading. (default: `"display"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.emphasized`.
-}
emphasized : Bool -> Attr { c | emphasized : Supported } msg
emphasized =
    A.emphasized


{-| See `M3e.Attributes.level`.
-}
level : Int -> Attr { c | level : Supported } msg
level =
    A.level


{-| See `M3e.Attributes.tocIgnore`.
-}
tocIgnore : Bool -> Attr { c | tocIgnore : Supported } msg
tocIgnore =
    A.tocIgnore


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
