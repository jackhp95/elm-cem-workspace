module Sl.Build.Skeleton exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withEffect, withId, withSlot, withStyle)

{-| The **Skeleton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Skeleton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withEffect, withId, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Skeleton as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.SkeletonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SkeletonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SkeletonAttrCaps


{-| -}
type alias SlotCaps =
    Component.SkeletonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SkeletonChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-skeleton" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SkeletonIs kind) admittedBy msg
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


{-| -}
withEffect : Value Component.SkeletonEffect -> Builder { a | effect_ : Available } slotCaps msg kind -> Builder { a | effect_ : Used } slotCaps msg kind
withEffect value_ =
    B.withAttribute (Component.skeletonEffect_ value_)
