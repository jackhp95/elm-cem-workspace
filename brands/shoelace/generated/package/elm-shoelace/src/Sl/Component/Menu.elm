module Sl.Component.Menu exposing (MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuChildAdmittedBy, menu, menuOnSelect)

{-| The **Menu** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Menu`](Sl.Element.Menu) as `menu`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs MenuIs, MenuAttrs, MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuChildAdmittedBy, menu, menuOnSelect

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Menu as Menu_


{-| The `menu` element of this family — delegates to [`Sl.Element.Menu.component`](Sl.Element.Menu#component).
-}
menu :
    List (Attr MenuAttrs msg)
    -> List (Element childAccepts (MenuChildAdmittedBy childAdm) msg)
    -> Element (MenuIs s) admittedBy msg
menu =
    Menu_.component


{-| See [`Sl.Element.Menu.Is`](Sl.Element.Menu#Is).
-}
type alias MenuIs s =
    Menu_.Is s


{-| See [`Sl.Element.Menu.Attrs`](Sl.Element.Menu#Attrs).
-}
type alias MenuAttrs =
    Menu_.Attrs


{-| See [`Sl.Element.Menu.Builder`](Sl.Element.Menu#Builder).
-}
type alias MenuBuilder attrCaps slotCaps msg kind =
    Menu_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Menu.AttrCaps`](Sl.Element.Menu#AttrCaps).
-}
type alias MenuAttrCaps =
    Menu_.AttrCaps


{-| See [`Sl.Element.Menu.SlotCaps`](Sl.Element.Menu#SlotCaps).
-}
type alias MenuSlotCaps =
    Menu_.SlotCaps


{-| See [`Sl.Element.Menu.ChildAdmittedBy`](Sl.Element.Menu#ChildAdmittedBy).
-}
type alias MenuChildAdmittedBy childAdm =
    Menu_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Menu.onSelect`](Sl.Element.Menu#onSelect).
-}
menuOnSelect : msg -> Attr { c | onSelect : Supported } msg
menuOnSelect =
    Menu_.onSelect
