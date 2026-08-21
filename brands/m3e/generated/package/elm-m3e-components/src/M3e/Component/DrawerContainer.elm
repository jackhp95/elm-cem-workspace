module M3e.Component.DrawerContainer exposing (DrawerContainerIs, DrawerContainerAttrs, DrawerContainerBuilder, DrawerContainerAttrCaps, DrawerContainerSlotCaps, DrawerContainerChildAdmittedBy, DrawerContainerEndMode, DrawerContainerStartMode, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, drawerContainer, drawerContainerEndMode, drawerContainerStartMode, drawerContainerEndDivider, drawerContainerStartDivider, drawerContainerOnChange, drawerContainerEnd, drawerContainerStart, drawerContainerChild, toggle, toggleFor)

{-| The **DrawerContainer** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.DrawerContainer`](M3e.Element.DrawerContainer) as `drawerContainer`, [`M3e.Element.DrawerToggle`](M3e.Element.DrawerToggle) as `toggle`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs DrawerContainerIs, DrawerContainerAttrs, DrawerContainerBuilder, DrawerContainerAttrCaps, DrawerContainerSlotCaps, DrawerContainerChildAdmittedBy, DrawerContainerEndMode, DrawerContainerStartMode, ToggleIs, ToggleAttrs, ToggleBuilder, ToggleAttrCaps, ToggleSlotCaps, ToggleChildAdmittedBy, drawerContainer, drawerContainerEndMode, drawerContainerStartMode, drawerContainerEndDivider, drawerContainerStartDivider, drawerContainerOnChange, drawerContainerEnd, drawerContainerStart, drawerContainerChild, toggle, toggleFor

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.DrawerContainer as DrawerContainer_
import M3e.Element.DrawerToggle as Toggle_


{-| The `drawerContainer` element of this family — delegates to [`M3e.Element.DrawerContainer.component`](M3e.Element.DrawerContainer#component).
-}
drawerContainer :
    List (Attr DrawerContainerAttrs msg)
    -> List (Element childAccepts (DrawerContainerChildAdmittedBy childAdm) msg)
    -> Element (DrawerContainerIs s) admittedBy msg
drawerContainer =
    DrawerContainer_.component


{-| See [`M3e.Element.DrawerContainer.Is`](M3e.Element.DrawerContainer#Is).
-}
type alias DrawerContainerIs s =
    DrawerContainer_.Is s


{-| See [`M3e.Element.DrawerContainer.Attrs`](M3e.Element.DrawerContainer#Attrs).
-}
type alias DrawerContainerAttrs =
    DrawerContainer_.Attrs


{-| See [`M3e.Element.DrawerContainer.Builder`](M3e.Element.DrawerContainer#Builder).
-}
type alias DrawerContainerBuilder attrCaps slotCaps msg kind =
    DrawerContainer_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DrawerContainer.AttrCaps`](M3e.Element.DrawerContainer#AttrCaps).
-}
type alias DrawerContainerAttrCaps =
    DrawerContainer_.AttrCaps


{-| See [`M3e.Element.DrawerContainer.SlotCaps`](M3e.Element.DrawerContainer#SlotCaps).
-}
type alias DrawerContainerSlotCaps =
    DrawerContainer_.SlotCaps


{-| See [`M3e.Element.DrawerContainer.ChildAdmittedBy`](M3e.Element.DrawerContainer#ChildAdmittedBy).
-}
type alias DrawerContainerChildAdmittedBy childAdm =
    DrawerContainer_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DrawerContainer.EndMode`](M3e.Element.DrawerContainer#EndMode).
-}
type alias DrawerContainerEndMode =
    DrawerContainer_.EndMode


{-| See [`M3e.Element.DrawerContainer.endMode`](M3e.Element.DrawerContainer#endMode).
-}
drawerContainerEndMode : Value DrawerContainerEndMode -> Attr { c | endMode : Supported } msg
drawerContainerEndMode =
    DrawerContainer_.endMode


{-| See [`M3e.Element.DrawerContainer.StartMode`](M3e.Element.DrawerContainer#StartMode).
-}
type alias DrawerContainerStartMode =
    DrawerContainer_.StartMode


{-| See [`M3e.Element.DrawerContainer.startMode`](M3e.Element.DrawerContainer#startMode).
-}
drawerContainerStartMode : Value DrawerContainerStartMode -> Attr { c | startMode : Supported } msg
drawerContainerStartMode =
    DrawerContainer_.startMode


{-| See [`M3e.Element.DrawerContainer.endDivider`](M3e.Element.DrawerContainer#endDivider).
-}
drawerContainerEndDivider : Bool -> Attr { c | endDivider : Supported } msg
drawerContainerEndDivider =
    DrawerContainer_.endDivider


{-| See [`M3e.Element.DrawerContainer.startDivider`](M3e.Element.DrawerContainer#startDivider).
-}
drawerContainerStartDivider : Bool -> Attr { c | startDivider : Supported } msg
drawerContainerStartDivider =
    DrawerContainer_.startDivider


{-| See [`M3e.Element.DrawerContainer.onChange`](M3e.Element.DrawerContainer#onChange).
-}
drawerContainerOnChange : msg -> Attr { c | onChange : Supported } msg
drawerContainerOnChange =
    DrawerContainer_.onChange


{-| See [`M3e.Element.DrawerContainer.end`](M3e.Element.DrawerContainer#end).
-}
drawerContainerEnd : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
drawerContainerEnd =
    DrawerContainer_.end


{-| See [`M3e.Element.DrawerContainer.start`](M3e.Element.DrawerContainer#start).
-}
drawerContainerStart : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
drawerContainerStart =
    DrawerContainer_.start


{-| See [`M3e.Element.DrawerContainer.child`](M3e.Element.DrawerContainer#child).
-}
drawerContainerChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
drawerContainerChild =
    DrawerContainer_.child


{-| The `toggle` element of this family — delegates to [`M3e.Element.DrawerToggle.component`](M3e.Element.DrawerToggle#component).
-}
toggle :
    List (Attr ToggleAttrs msg)
    -> List (Element childAccepts (ToggleChildAdmittedBy childAdm) msg)
    -> Element (ToggleIs s) admittedBy msg
toggle =
    Toggle_.component


{-| See [`M3e.Element.DrawerToggle.Is`](M3e.Element.DrawerToggle#Is).
-}
type alias ToggleIs s =
    Toggle_.Is s


{-| See [`M3e.Element.DrawerToggle.Attrs`](M3e.Element.DrawerToggle#Attrs).
-}
type alias ToggleAttrs =
    Toggle_.Attrs


{-| See [`M3e.Element.DrawerToggle.Builder`](M3e.Element.DrawerToggle#Builder).
-}
type alias ToggleBuilder attrCaps slotCaps msg kind =
    Toggle_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.DrawerToggle.AttrCaps`](M3e.Element.DrawerToggle#AttrCaps).
-}
type alias ToggleAttrCaps =
    Toggle_.AttrCaps


{-| See [`M3e.Element.DrawerToggle.SlotCaps`](M3e.Element.DrawerToggle#SlotCaps).
-}
type alias ToggleSlotCaps =
    Toggle_.SlotCaps


{-| See [`M3e.Element.DrawerToggle.ChildAdmittedBy`](M3e.Element.DrawerToggle#ChildAdmittedBy).
-}
type alias ToggleChildAdmittedBy childAdm =
    Toggle_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.DrawerToggle.for`](M3e.Element.DrawerToggle#for).
-}
toggleFor : String -> Attr { c | for : Supported } msg
toggleFor =
    Toggle_.for
