module Or.Component2.Widget exposing (WidgetIs, WidgetAttrs, WidgetBuilder, WidgetAttrCaps, WidgetSlotCaps, WidgetContent, WidgetChildAdmittedBy, widget, widgetLabel, widgetChild)

{-| The **Widget** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Or.Element.Widget`](Or.Element.Widget) as `widget`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs WidgetIs, WidgetAttrs, WidgetBuilder, WidgetAttrCaps, WidgetSlotCaps, WidgetContent, WidgetChildAdmittedBy, widget, widgetLabel, widgetChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Or.Element.Widget as Widget_


{-| The `widget` element of this family — delegates to [`Or.Element.Widget.component`](Or.Element.Widget#component).
-}
widget :
    List (Attr WidgetAttrs msg)
    -> List (Element WidgetContent (WidgetChildAdmittedBy childAdm) msg)
    -> Element (WidgetIs s) admittedBy msg
widget =
    Widget_.component


{-| See [`Or.Element.Widget.Is`](Or.Element.Widget#Is).
-}
type alias WidgetIs s =
    Widget_.Is s


{-| See [`Or.Element.Widget.Attrs`](Or.Element.Widget#Attrs).
-}
type alias WidgetAttrs =
    Widget_.Attrs


{-| See [`Or.Element.Widget.Builder`](Or.Element.Widget#Builder).
-}
type alias WidgetBuilder attrCaps slotCaps msg kind =
    Widget_.Builder attrCaps slotCaps msg kind


{-| See [`Or.Element.Widget.AttrCaps`](Or.Element.Widget#AttrCaps).
-}
type alias WidgetAttrCaps =
    Widget_.AttrCaps


{-| See [`Or.Element.Widget.SlotCaps`](Or.Element.Widget#SlotCaps).
-}
type alias WidgetSlotCaps =
    Widget_.SlotCaps


{-| See [`Or.Element.Widget.Content`](Or.Element.Widget#Content).
-}
type alias WidgetContent =
    Widget_.Content


{-| See [`Or.Element.Widget.ChildAdmittedBy`](Or.Element.Widget#ChildAdmittedBy).
-}
type alias WidgetChildAdmittedBy childAdm =
    Widget_.ChildAdmittedBy childAdm


{-| See [`Or.Element.Widget.label`](Or.Element.Widget#label).
-}
widgetLabel : String -> Attr { c | label : Supported } msg
widgetLabel =
    Widget_.label


{-| See [`Or.Element.Widget.child`](Or.Element.Widget#child).
-}
widgetChild : Element WidgetContent admittedBy msg -> Element free freeAdmittedBy msg
widgetChild =
    Widget_.child
