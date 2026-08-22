module Mini.Component2.Tabs exposing (TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsChildAdmittedBy, tabs, tabsChild)

{-| The **Tabs** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Tabs`](Mini.Element.Tabs) as `tabs`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs TabsIs, TabsAttrs, TabsBuilder, TabsAttrCaps, TabsSlotCaps, TabsContent, TabsChildAdmittedBy, tabs, tabsChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import Mini.Element.Tabs as Tabs_


{-| The `tabs` element of this family — delegates to [`Mini.Element.Tabs.component`](Mini.Element.Tabs#component).
-}
tabs :
    List (Attr TabsAttrs msg)
    -> List (Element TabsContent (TabsChildAdmittedBy childAdm) msg)
    -> Element (TabsIs s) admittedBy msg
tabs =
    Tabs_.component


{-| See [`Mini.Element.Tabs.Is`](Mini.Element.Tabs#Is).
-}
type alias TabsIs s =
    Tabs_.Is s


{-| See [`Mini.Element.Tabs.Attrs`](Mini.Element.Tabs#Attrs).
-}
type alias TabsAttrs =
    Tabs_.Attrs


{-| See [`Mini.Element.Tabs.Builder`](Mini.Element.Tabs#Builder).
-}
type alias TabsBuilder attrCaps slotCaps msg kind =
    Tabs_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Tabs.AttrCaps`](Mini.Element.Tabs#AttrCaps).
-}
type alias TabsAttrCaps =
    Tabs_.AttrCaps


{-| See [`Mini.Element.Tabs.SlotCaps`](Mini.Element.Tabs#SlotCaps).
-}
type alias TabsSlotCaps =
    Tabs_.SlotCaps


{-| See [`Mini.Element.Tabs.Content`](Mini.Element.Tabs#Content).
-}
type alias TabsContent =
    Tabs_.Content


{-| See [`Mini.Element.Tabs.ChildAdmittedBy`](Mini.Element.Tabs#ChildAdmittedBy).
-}
type alias TabsChildAdmittedBy childAdm =
    Tabs_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Tabs.child`](Mini.Element.Tabs#child).
-}
tabsChild : Element TabsContent admittedBy msg -> Element free freeAdmittedBy msg
tabsChild =
    Tabs_.child
