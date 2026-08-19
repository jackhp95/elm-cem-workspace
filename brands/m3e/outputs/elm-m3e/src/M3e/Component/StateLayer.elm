module M3e.Component.StateLayer exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , disableHover, disabled, enablePressed, for
    )

{-| The `m3e-state-layer` component — strict per-component surface.

Provides focus and hover state layer treatment for an interactive element.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs disableHover, disabled, enablePressed, for

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.StateLayer
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-state-layer` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.StateLayer.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.StateLayer.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.StateLayer.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.StateLayer.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.StateLayer.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.stateLayer


{-| See `M3e.Attributes.disableHover`.
-}
disableHover : Bool -> Attr { c | disableHover : Supported } msg
disableHover =
    A.disableHover


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.enablePressed`.
-}
enablePressed : Bool -> Attr { c | enablePressed : Supported } msg
enablePressed =
    A.enablePressed


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for
