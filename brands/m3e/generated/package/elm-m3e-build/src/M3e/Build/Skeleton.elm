module M3e.Build.Skeleton exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAnimation, withClass, withId, withLoaded, withShape, withSlot, withStyle, withChild)

{-| The **Skeleton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Skeleton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAnimation, withClass, withId, withLoaded, withShape, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Skeleton as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


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
    B.init "m3e-skeleton" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SkeletonIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withAnimation : Value Component.SkeletonAnimation -> Builder { a | animation : Available } slotCaps msg kind -> Builder { a | animation : Used } slotCaps msg kind
withAnimation value_ =
    B.withAttribute (Component.skeletonAnimation value_)


{-| -}
withLoaded : Bool -> Builder { a | loaded : Available } slotCaps msg kind -> Builder { a | loaded : Used } slotCaps msg kind
withLoaded value_ =
    B.withAttribute (A.loaded value_)


{-| -}
withShape : Value Component.SkeletonShape -> Builder { a | shape : Available } slotCaps msg kind -> Builder { a | shape : Used } slotCaps msg kind
withShape value_ =
    B.withAttribute (Component.skeletonShape value_)
