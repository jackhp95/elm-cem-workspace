module M3e.Component.Heading exposing (HeadingIs, HeadingAttrs, HeadingBuilder, HeadingAttrCaps, HeadingSlotCaps, HeadingContent, HeadingChildAdmittedBy, HeadingSize, HeadingVariant, heading, headingSize, headingVariant, headingEmphasized, headingLevel, headingTocIgnore, headingChild)

{-| The **Heading** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Heading`](M3e.Element.Heading) as `heading`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs HeadingIs, HeadingAttrs, HeadingBuilder, HeadingAttrCaps, HeadingSlotCaps, HeadingContent, HeadingChildAdmittedBy, HeadingSize, HeadingVariant, heading, headingSize, headingVariant, headingEmphasized, headingLevel, headingTocIgnore, headingChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Heading as Heading_


{-| The `heading` element of this family — delegates to [`M3e.Element.Heading.component`](M3e.Element.Heading#component).
-}
heading :
    { content : Element HeadingContent (HeadingChildAdmittedBy childAdm) msg }
    -> List (Attr HeadingAttrs msg)
    -> List (Element HeadingContent (HeadingChildAdmittedBy childAdm) msg)
    -> Element (HeadingIs s) admittedBy msg
heading =
    Heading_.component


{-| See [`M3e.Element.Heading.Is`](M3e.Element.Heading#Is).
-}
type alias HeadingIs s =
    Heading_.Is s


{-| See [`M3e.Element.Heading.Attrs`](M3e.Element.Heading#Attrs).
-}
type alias HeadingAttrs =
    Heading_.Attrs


{-| See [`M3e.Element.Heading.Builder`](M3e.Element.Heading#Builder).
-}
type alias HeadingBuilder attrCaps slotCaps msg kind =
    Heading_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Heading.AttrCaps`](M3e.Element.Heading#AttrCaps).
-}
type alias HeadingAttrCaps =
    Heading_.AttrCaps


{-| See [`M3e.Element.Heading.SlotCaps`](M3e.Element.Heading#SlotCaps).
-}
type alias HeadingSlotCaps =
    Heading_.SlotCaps


{-| See [`M3e.Element.Heading.Content`](M3e.Element.Heading#Content).
-}
type alias HeadingContent =
    Heading_.Content


{-| See [`M3e.Element.Heading.ChildAdmittedBy`](M3e.Element.Heading#ChildAdmittedBy).
-}
type alias HeadingChildAdmittedBy childAdm =
    Heading_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Heading.Size`](M3e.Element.Heading#Size).
-}
type alias HeadingSize =
    Heading_.Size


{-| See [`M3e.Element.Heading.size`](M3e.Element.Heading#size).
-}
headingSize : Value HeadingSize -> Attr { c | size : Supported } msg
headingSize =
    Heading_.size


{-| See [`M3e.Element.Heading.Variant`](M3e.Element.Heading#Variant).
-}
type alias HeadingVariant =
    Heading_.Variant


{-| See [`M3e.Element.Heading.variant`](M3e.Element.Heading#variant).
-}
headingVariant : Value HeadingVariant -> Attr { c | variant : Supported } msg
headingVariant =
    Heading_.variant


{-| See [`M3e.Element.Heading.emphasized`](M3e.Element.Heading#emphasized).
-}
headingEmphasized : Bool -> Attr { c | emphasized : Supported } msg
headingEmphasized =
    Heading_.emphasized


{-| See [`M3e.Element.Heading.level`](M3e.Element.Heading#level).
-}
headingLevel : Int -> Attr { c | level : Supported } msg
headingLevel =
    Heading_.level


{-| See [`M3e.Element.Heading.tocIgnore`](M3e.Element.Heading#tocIgnore).
-}
headingTocIgnore : Bool -> Attr { c | tocIgnore : Supported } msg
headingTocIgnore =
    Heading_.tocIgnore


{-| See [`M3e.Element.Heading.child`](M3e.Element.Heading#child).
-}
headingChild : Element HeadingContent admittedBy msg -> Element free freeAdmittedBy msg
headingChild =
    Heading_.child
