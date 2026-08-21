module M3e.Component.MultiYearView exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , active, activeDate, date, maxDate, minDate, today, onChange, onActiveChange
    )

{-| The `m3e-multi-year-view` component — strict per-component surface.

An internal component used to display a year selector in a calendar.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs active, activeDate, date, maxDate, minDate, today, onChange, onActiveChange

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.MultiYearView
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-multi-year-view` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.MultiYearView.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.MultiYearView.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.MultiYearView.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.MultiYearView.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.MultiYearView.AttrCaps


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
    H.multiYearView


{-| See `M3e.Attributes.active`.
-}
active : Bool -> Attr { c | active : Supported } msg
active =
    A.active


{-| See `M3e.Attributes.activeDate`.
-}
activeDate : String -> Attr { c | activeDate : Supported } msg
activeDate =
    A.activeDate


{-| See `M3e.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


{-| See `M3e.Attributes.maxDate`.
-}
maxDate : String -> Attr { c | maxDate : Supported } msg
maxDate =
    A.maxDate


{-| See `M3e.Attributes.minDate`.
-}
minDate : String -> Attr { c | minDate : Supported } msg
minDate =
    A.minDate


{-| See `M3e.Attributes.today`.
-}
today : String -> Attr { c | today : Supported } msg
today =
    A.today


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onActiveChange`.
-}
onActiveChange : msg -> Attr { c | onActiveChange : Supported } msg
onActiveChange =
    Ev.onActiveChange
