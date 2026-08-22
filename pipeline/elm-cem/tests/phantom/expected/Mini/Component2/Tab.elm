module Mini.Component2.Tab exposing (TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabChildAdmittedBy, TabAdmittedBy, tab, tabChild)

{-| The **Tab** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Tab`](Mini.Element.Tab) as `tab`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TabIs, TabAttrs, TabBuilder, TabAttrCaps, TabSlotCaps, TabContent, TabChildAdmittedBy, TabAdmittedBy, tab, tabChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Mini.Element.Tab as Tab_


{-| The `tab` element of this family — delegates to [`Mini.Element.Tab.component`](Mini.Element.Tab#component).
-}
tab :
    List (Attr TabAttrs msg)
    -> List (Element TabContent (TabChildAdmittedBy childAdm) msg)
    -> Element (TabIs s) TabAdmittedBy msg
tab =
    Tab_.component


{-| See [`Mini.Element.Tab.Is`](Mini.Element.Tab#Is).
-}
type alias TabIs s =
    Tab_.Is s


{-| See [`Mini.Element.Tab.Attrs`](Mini.Element.Tab#Attrs).
-}
type alias TabAttrs =
    Tab_.Attrs


{-| See [`Mini.Element.Tab.Builder`](Mini.Element.Tab#Builder).
-}
type alias TabBuilder attrCaps slotCaps msg kind =
    Tab_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Tab.AttrCaps`](Mini.Element.Tab#AttrCaps).
-}
type alias TabAttrCaps =
    Tab_.AttrCaps


{-| See [`Mini.Element.Tab.SlotCaps`](Mini.Element.Tab#SlotCaps).
-}
type alias TabSlotCaps =
    Tab_.SlotCaps


{-| See [`Mini.Element.Tab.Content`](Mini.Element.Tab#Content).
-}
type alias TabContent =
    Tab_.Content


{-| See [`Mini.Element.Tab.ChildAdmittedBy`](Mini.Element.Tab#ChildAdmittedBy).
-}
type alias TabChildAdmittedBy childAdm =
    Tab_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Tab.AdmittedBy`](Mini.Element.Tab#AdmittedBy).
-}
type alias TabAdmittedBy =
    Tab_.AdmittedBy


{-| See [`Mini.Element.Tab.child`](Mini.Element.Tab#child).
-}
tabChild : Element TabContent admittedBy msg -> Element free freeAdmittedBy msg
tabChild =
    Tab_.child
