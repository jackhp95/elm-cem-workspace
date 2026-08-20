module Sl.Component.Drawer exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Placement, placement
    , contained, label, noHeader, open, onShow, onAfterShow, onHide, onAfterHide, onInitialFocus, onRequestClose
    )

{-| The `sl-drawer` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Placement, placement
@docs contained, label, noHeader, open, onShow, onAfterShow, onHide, onAfterHide, onInitialFocus, onRequestClose

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Drawer
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-drawer` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Drawer.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Drawer.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Drawer.ChildAdmittedBy childAdm


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.Drawer.Placement


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Drawer.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Drawer.AttrCaps


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
    H.drawer


{-| The direction from which the drawer will open. (default: `'end'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| See `Sl.Attributes.contained`.
-}
contained : Bool -> Attr { c | contained : Supported } msg
contained =
    A.contained


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Attributes.noHeader`.
-}
noHeader : Bool -> Attr { c | noHeader : Supported } msg
noHeader =
    A.noHeader


{-| See `Sl.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `Sl.Events.onShow`.
-}
onShow : msg -> Attr { c | onShow : Supported } msg
onShow =
    Ev.onShow


{-| See `Sl.Events.onAfterShow`.
-}
onAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
onAfterShow =
    Ev.onAfterShow


{-| See `Sl.Events.onHide`.
-}
onHide : msg -> Attr { c | onHide : Supported } msg
onHide =
    Ev.onHide


{-| See `Sl.Events.onAfterHide`.
-}
onAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
onAfterHide =
    Ev.onAfterHide


{-| See `Sl.Events.onInitialFocus`.
-}
onInitialFocus : msg -> Attr { c | onInitialFocus : Supported } msg
onInitialFocus =
    Ev.onInitialFocus


{-| See `Sl.Events.onRequestClose`.
-}
onRequestClose : msg -> Attr { c | onRequestClose : Supported } msg
onRequestClose =
    Ev.onRequestClose
