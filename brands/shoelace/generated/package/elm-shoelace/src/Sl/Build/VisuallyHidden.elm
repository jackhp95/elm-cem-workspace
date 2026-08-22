module Sl.Build.VisuallyHidden exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle)

{-| The **VisuallyHidden** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.VisuallyHidden`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.VisuallyHidden as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.VisuallyHiddenIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.VisuallyHiddenBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.VisuallyHiddenAttrCaps


{-| -}
type alias SlotCaps =
    Component.VisuallyHiddenSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.VisuallyHiddenChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-visually-hidden" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.VisuallyHiddenIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)
