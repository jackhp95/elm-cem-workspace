module Sl.Element.TabGroup exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Activation, activation, Placement, placement
    , fixedScrollControls, noScrollControls, onTabShow, onTabHide
    )

{-| The `sl-tab-group` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Activation, activation, Placement, placement
@docs fixedScrollControls, noScrollControls, onTabShow, onTabHide

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.TabGroup
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tab-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.TabGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.TabGroup.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.TabGroup.ChildAdmittedBy childAdm


{-| The `activation` values valid on this component (compile-tight narrowing).
-}
type alias Activation =
    Sl.Internal.Types.TabGroup.Activation


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.TabGroup.Placement


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.TabGroup.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.TabGroup.AttrCaps


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
    H.tabGroup


{-| When set to auto, navigating tabs with the arrow keys will instantly show the corresponding tab panel. When set to
manual, the tab will receive focus but will not show until the user presses spacebar or enter. (default: `'auto'`)
-}
activation : Value Activation -> Attr { c | activation : Supported } msg
activation value_ =
    Ir.attribute "activation" (Val.toString value_)


{-| The placement of the tabs. (default: `'top'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| See `Sl.Attributes.fixedScrollControls`.
-}
fixedScrollControls : Bool -> Attr { c | fixedScrollControls : Supported } msg
fixedScrollControls =
    A.fixedScrollControls


{-| See `Sl.Attributes.noScrollControls`.
-}
noScrollControls : Bool -> Attr { c | noScrollControls : Supported } msg
noScrollControls =
    A.noScrollControls


{-| See `Sl.Events.onTabShow`.
-}
onTabShow : msg -> Attr { c | onTabShow : Supported } msg
onTabShow =
    Ev.onTabShow


{-| See `Sl.Events.onTabHide`.
-}
onTabHide : msg -> Attr { c | onTabHide : Supported } msg
onTabHide =
    Ev.onTabHide
