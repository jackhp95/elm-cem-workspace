module Sl.Component.Tab exposing (TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabChildAdmittedBy, tab, tabActive, tabClosable, tabDisabled, tabPanel, tabOnClose)

{-| The **Tab** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Tab`](Sl.Element.Tab) as `tab`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabChildAdmittedBy, tab, tabActive, tabClosable, tabDisabled, tabPanel, tabOnClose

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Tab as Tab_


{-| The `tab` element of this family — delegates to [`Sl.Element.Tab.component`](Sl.Element.Tab#component).
-}
tab :
    List (Attr TabAttrs msg)
    -> List (Element childAccepts (TabChildAdmittedBy childAdm) msg)
    -> Element (TabIs s) admittedBy msg
tab =
    Tab_.component


{-| See [`Sl.Element.Tab.Is`](Sl.Element.Tab#Is).
-}
type alias TabIs s =
    Tab_.Is s


{-| See [`Sl.Element.Tab.Attrs`](Sl.Element.Tab#Attrs).
-}
type alias TabAttrs =
    Tab_.Attrs


{-| See [`Sl.Element.Tab.Builder`](Sl.Element.Tab#Builder).
-}
type alias TabBuilder attrCaps slotCaps msg kind =
    Tab_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Tab.AttrCaps`](Sl.Element.Tab#AttrCaps).
-}
type alias TabAttrCaps =
    Tab_.AttrCaps


{-| See [`Sl.Element.Tab.SlotCaps`](Sl.Element.Tab#SlotCaps).
-}
type alias TabSlotCaps =
    Tab_.SlotCaps


{-| See [`Sl.Element.Tab.ChildAdmittedBy`](Sl.Element.Tab#ChildAdmittedBy).
-}
type alias TabChildAdmittedBy childAdm =
    Tab_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Tab.active`](Sl.Element.Tab#active).
-}
tabActive : Bool -> Attr { c | active : Supported } msg
tabActive =
    Tab_.active


{-| See [`Sl.Element.Tab.closable`](Sl.Element.Tab#closable).
-}
tabClosable : Bool -> Attr { c | closable : Supported } msg
tabClosable =
    Tab_.closable


{-| See [`Sl.Element.Tab.disabled`](Sl.Element.Tab#disabled).
-}
tabDisabled : Bool -> Attr { c | disabled : Supported } msg
tabDisabled =
    Tab_.disabled


{-| See [`Sl.Element.Tab.panel`](Sl.Element.Tab#panel).
-}
tabPanel : String -> Attr { c | panel : Supported } msg
tabPanel =
    Tab_.panel


{-| See [`Sl.Element.Tab.onClose`](Sl.Element.Tab#onClose).
-}
tabOnClose : msg -> Attr { c | onClose : Supported } msg
tabOnClose =
    Tab_.onClose
