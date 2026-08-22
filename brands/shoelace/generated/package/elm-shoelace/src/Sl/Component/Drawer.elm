module Sl.Component.Drawer exposing (DrawerIs, DrawerAttrs, DrawerBuilder, DrawerAttrCaps, DrawerSlotCaps, DrawerChildAdmittedBy, DrawerPlacement, drawer, drawerPlacement, drawerContained, drawerLabel, drawerNoHeader, drawerOpen, drawerOnShow, drawerOnAfterShow, drawerOnHide, drawerOnAfterHide, drawerOnInitialFocus, drawerOnRequestClose, drawerChild)

{-| The **Drawer** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Drawer`](Sl.Element.Drawer) as `drawer`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs DrawerIs, DrawerAttrs, DrawerBuilder, DrawerAttrCaps, DrawerSlotCaps, DrawerChildAdmittedBy, DrawerPlacement, drawer, drawerPlacement, drawerContained, drawerLabel, drawerNoHeader, drawerOpen, drawerOnShow, drawerOnAfterShow, drawerOnHide, drawerOnAfterHide, drawerOnInitialFocus, drawerOnRequestClose, drawerChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Drawer as Drawer_


{-| The `drawer` element of this family — delegates to [`Sl.Element.Drawer.component`](Sl.Element.Drawer#component).
-}
drawer :
    List (Attr DrawerAttrs msg)
    -> List (Element childAccepts (DrawerChildAdmittedBy childAdm) msg)
    -> Element (DrawerIs s) admittedBy msg
drawer =
    Drawer_.component


{-| See [`Sl.Element.Drawer.Is`](Sl.Element.Drawer#Is).
-}
type alias DrawerIs s =
    Drawer_.Is s


{-| See [`Sl.Element.Drawer.Attrs`](Sl.Element.Drawer#Attrs).
-}
type alias DrawerAttrs =
    Drawer_.Attrs


{-| See [`Sl.Element.Drawer.Builder`](Sl.Element.Drawer#Builder).
-}
type alias DrawerBuilder attrCaps slotCaps msg kind =
    Drawer_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Drawer.AttrCaps`](Sl.Element.Drawer#AttrCaps).
-}
type alias DrawerAttrCaps =
    Drawer_.AttrCaps


{-| See [`Sl.Element.Drawer.SlotCaps`](Sl.Element.Drawer#SlotCaps).
-}
type alias DrawerSlotCaps =
    Drawer_.SlotCaps


{-| See [`Sl.Element.Drawer.ChildAdmittedBy`](Sl.Element.Drawer#ChildAdmittedBy).
-}
type alias DrawerChildAdmittedBy childAdm =
    Drawer_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Drawer.Placement`](Sl.Element.Drawer#Placement).
-}
type alias DrawerPlacement =
    Drawer_.Placement


{-| See [`Sl.Element.Drawer.placement`](Sl.Element.Drawer#placement).
-}
drawerPlacement : Value DrawerPlacement -> Attr { c | placement : Supported } msg
drawerPlacement =
    Drawer_.placement


{-| See [`Sl.Element.Drawer.contained`](Sl.Element.Drawer#contained).
-}
drawerContained : Bool -> Attr { c | contained : Supported } msg
drawerContained =
    Drawer_.contained


{-| See [`Sl.Element.Drawer.label`](Sl.Element.Drawer#label).
-}
drawerLabel : String -> Attr { c | label : Supported } msg
drawerLabel =
    Drawer_.label


{-| See [`Sl.Element.Drawer.noHeader`](Sl.Element.Drawer#noHeader).
-}
drawerNoHeader : Bool -> Attr { c | noHeader : Supported } msg
drawerNoHeader =
    Drawer_.noHeader


{-| See [`Sl.Element.Drawer.open`](Sl.Element.Drawer#open).
-}
drawerOpen : Bool -> Attr { c | open : Supported } msg
drawerOpen =
    Drawer_.open


{-| See [`Sl.Element.Drawer.onShow`](Sl.Element.Drawer#onShow).
-}
drawerOnShow : msg -> Attr { c | onShow : Supported } msg
drawerOnShow =
    Drawer_.onShow


{-| See [`Sl.Element.Drawer.onAfterShow`](Sl.Element.Drawer#onAfterShow).
-}
drawerOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
drawerOnAfterShow =
    Drawer_.onAfterShow


{-| See [`Sl.Element.Drawer.onHide`](Sl.Element.Drawer#onHide).
-}
drawerOnHide : msg -> Attr { c | onHide : Supported } msg
drawerOnHide =
    Drawer_.onHide


{-| See [`Sl.Element.Drawer.onAfterHide`](Sl.Element.Drawer#onAfterHide).
-}
drawerOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
drawerOnAfterHide =
    Drawer_.onAfterHide


{-| See [`Sl.Element.Drawer.onInitialFocus`](Sl.Element.Drawer#onInitialFocus).
-}
drawerOnInitialFocus : msg -> Attr { c | onInitialFocus : Supported } msg
drawerOnInitialFocus =
    Drawer_.onInitialFocus


{-| See [`Sl.Element.Drawer.onRequestClose`](Sl.Element.Drawer#onRequestClose).
-}
drawerOnRequestClose : msg -> Attr { c | onRequestClose : Supported } msg
drawerOnRequestClose =
    Drawer_.onRequestClose


{-| See [`Sl.Element.Drawer.child`](Sl.Element.Drawer#child).
-}
drawerChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
drawerChild =
    Drawer_.child
